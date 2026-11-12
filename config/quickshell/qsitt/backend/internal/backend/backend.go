// Package backend owns the operating-system boundary used by the QML frontend.
package backend

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"syscall"
	"time"

	"github.com/itt828/dots/config/quickshell/qsitt/backend/internal/search"
)

type Backend struct {
	Root string
	In   io.Reader
	Out  io.Writer
	Err  io.Writer
}

// ExitError preserves tool exit codes consumed by the frontend (e.g. cancellation).
type ExitError struct {
	Code    int
	Message string
}

func (e *ExitError) Error() string { return e.Message }

func ExitCode(err error) int {
	var explicit *ExitError
	if errors.As(err, &explicit) {
		return explicit.Code
	}
	var process *exec.ExitError
	if errors.As(err, &process) && process.ExitCode() > 0 {
		return process.ExitCode()
	}
	return 1
}

func (b *Backend) command(ctx context.Context, name string, args ...string) *exec.Cmd {
	cmd := exec.CommandContext(ctx, name, args...)
	// Shutdown includes descendants such as the clipboard watcher helpers.
	cmd.SysProcAttr = &syscall.SysProcAttr{Setpgid: true, Pdeathsig: syscall.SIGTERM}
	cmd.Cancel = func() error { return syscall.Kill(-cmd.Process.Pid, syscall.SIGTERM) }
	cmd.WaitDelay = 2 * time.Second
	cmd.Stderr = b.Err
	return cmd
}

func (b *Backend) run(ctx context.Context, input io.Reader, name string, args ...string) error {
	cmd := b.command(ctx, name, args...)
	cmd.Stdin, cmd.Stdout = input, b.Out
	return cmd.Run()
}

func (b *Backend) output(ctx context.Context, input io.Reader, name string, args ...string) ([]byte, error) {
	cmd := b.command(ctx, name, args...)
	cmd.Stdin = input
	return cmd.Output()
}

func (b *Backend) json(value any) error { return json.NewEncoder(b.Out).Encode(value) }

func (b *Backend) Run(ctx context.Context, args []string) error {
	if len(args) == 0 {
		return errors.New("usage: qsittd niri|metrics|backlight|lid|power|desktop-theme|audio|state|search|clipboard|open|launch|tool ...")
	}
	op, rest := args[0], args[1:]
	switch op {
	case "niri":
		return b.niri(ctx, rest)
	case "metrics":
		if len(rest) != 1 {
			break
		}
		return b.metrics(rest[0])
	case "backlight":
		return b.backlight(ctx, rest)
	case "lid":
		return b.lid(ctx, rest)
	case "power":
		if len(rest) != 1 {
			break
		}
		switch rest[0] {
		case "poweroff", "reboot", "suspend":
			return b.run(ctx, nil, "systemctl", rest[0])
		case "logout":
			return b.run(ctx, nil, "loginctl", "terminate-user", fmt.Sprint(os.Getuid()))
		}
	case "desktop-theme":
		if len(rest) != 1 || (rest[0] != "prefer-dark" && rest[0] != "prefer-light") {
			break
		}
		return b.run(ctx, nil, "gsettings", "set", "org.gnome.desktop.interface", "color-scheme", rest[0])
	case "audio":
		return b.audio(ctx, rest)
	case "state":
		return b.state(rest)
	case "search":
		if len(rest) == 1 && rest[0] == "index" || len(rest) == 3 && rest[0] == "query" {
			return b.search(ctx, rest...)
		}
	case "clipboard":
		return b.clipboard(ctx, rest)
	case "open":
		if len(rest) == 1 {
			return b.run(ctx, nil, "xdg-open", rest[0])
		}
	case "launch":
		if len(rest) == 1 {
			return b.run(ctx, nil, "gio", "launch", rest[0])
		}
	case "tool":
		return b.tool(ctx, rest)
	}
	return fmt.Errorf("invalid %s arguments", op)
}

func (b *Backend) search(ctx context.Context, args ...string) error {
	store, err := search.New(b.Root)
	if err != nil {
		return err
	}
	defer store.Close()
	if len(args) == 1 && args[0] == "index" {
		count, err := store.Index(ctx)
		if err != nil {
			return err
		}
		_, err = fmt.Fprintln(b.Out, count)
		return err
	}
	if len(args) == 3 && args[0] == "query" {
		results, err := store.Query(ctx, args[1], args[2])
		if err != nil {
			return err
		}
		return b.json(results)
	}
	return errors.New("invalid search arguments")
}

func (b *Backend) clipboard(ctx context.Context, args []string) error {
	// wl-paste invokes this same executable with clipboard bytes on stdin.
	if len(args) == 2 && args[0] == "watch" {
		methods := map[string]string{"text": "text", "image": "image", "text/uri-list": "files"}
		if method, ok := methods[args[1]]; ok {
			executable, err := os.Executable()
			if err != nil {
				return err
			}
			return b.run(ctx, nil, "wl-paste", "--type", args[1], "--watch", executable, "clipboard", "add", method)
		}
		return errors.New("invalid clipboard MIME type")
	}
	store, err := search.New(b.Root)
	if err != nil {
		return err
	}
	defer store.Close()
	store.Run = b.run
	if len(args) == 1 && args[0] == "clear" {
		return store.Clear(ctx)
	}
	if len(args) == 2 && args[0] == "copy" {
		return store.Copy(ctx, args[1])
	}
	if len(args) == 2 && args[0] == "add" {
		input := b.In
		if input == nil {
			input = os.Stdin
		}
		switch args[1] {
		case "text":
			return store.AddText(ctx, input)
		case "image":
			return store.AddImage(ctx, input)
		case "files":
			return store.AddFiles(ctx, input)
		}
	}
	return errors.New("invalid clipboard arguments")
}
