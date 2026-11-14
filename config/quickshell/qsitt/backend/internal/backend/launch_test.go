package backend

import (
	"context"
	"encoding/json"
	"os"
	"os/signal"
	"path/filepath"
	"reflect"
	"syscall"
	"testing"
	"time"
)

// Simulate an app logging after gio/xdg-open and the QML pipes have closed.
func TestLaunchedAppHelper(t *testing.T) {
	if os.Getenv("QSITT_TEST_LAUNCHED_APP") != "1" {
		return
	}
	signal.Ignore(syscall.SIGPIPE)
	deadline := time.Now().Add(5 * time.Second)
	for {
		if _, err := os.Stat(os.Getenv("QSITT_TEST_GATE")); err == nil {
			break
		}
		if time.Now().After(deadline) {
			os.Exit(2)
		}
		time.Sleep(10 * time.Millisecond)
	}
	result := struct {
		Args   []string
		Errors []string
	}{Args: os.Args[3:]}
	for _, stream := range []*os.File{os.Stdout, os.Stderr} {
		if _, err := stream.WriteString("late app log\n"); err != nil {
			result.Errors = append(result.Errors, err.Error())
		}
	}
	data, _ := json.Marshal(result)
	if err := os.WriteFile(os.Getenv("QSITT_TEST_RESULT"), data, 0600); err != nil {
		os.Exit(3)
	}
	os.Exit(0)
}

func TestLaunchSurvivesClosedFrontendPipes(t *testing.T) {
	for _, operation := range []string{"launch", "open"} {
		t.Run(operation, func(t *testing.T) {
			dir := t.TempDir()
			executable, err := os.Executable()
			if err != nil {
				t.Fatal(err)
			}
			t.Setenv("PATH", dir)
			t.Setenv("QSITT_TEST_EXECUTABLE", executable)
			t.Setenv("QSITT_TEST_LAUNCHED_APP", "1")
			gate, resultPath := filepath.Join(dir, "gate"), filepath.Join(dir, "result")
			t.Setenv("QSITT_TEST_GATE", gate)
			t.Setenv("QSITT_TEST_RESULT", resultPath)
			name := "gio"
			value := filepath.Join(dir, "Discord with spaces; literal.desktop")
			want := []string{"launch", value}
			if operation == "open" {
				name, value = "xdg-open", "https://example.com/?q=a&b=c"
				want = []string{value}
			}
			launcher := "#!/bin/sh\n\"$QSITT_TEST_EXECUTABLE\" -test.run=TestLaunchedAppHelper -- \"$@\" &\n"
			if err := os.WriteFile(filepath.Join(dir, name), []byte(launcher), 0700); err != nil {
				t.Fatal(err)
			}
			stdout, out, err := os.Pipe()
			if err != nil {
				t.Fatal(err)
			}
			defer stdout.Close()
			defer out.Close()
			stderr, errOut, err := os.Pipe()
			if err != nil {
				t.Fatal(err)
			}
			defer stderr.Close()
			defer errOut.Close()
			b := Backend{Out: out, Err: errOut}
			ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
			defer cancel()
			if err := b.Run(ctx, []string{operation, value}); err != nil {
				t.Fatal(err)
			}
			// Closing the readers reproduces QML disposing the launcher's pipes.
			_ = stdout.Close()
			_ = stderr.Close()
			if err := os.WriteFile(gate, nil, 0600); err != nil {
				t.Fatal(err)
			}
			deadline := time.Now().Add(5 * time.Second)
			for {
				data, err := os.ReadFile(resultPath)
				var result struct {
					Args   []string
					Errors []string
				}
				if err == nil && json.Unmarshal(data, &result) == nil {
					if !reflect.DeepEqual(result.Args, want) || len(result.Errors) != 0 {
						t.Fatalf("launched app: %+v, want args %v and no write errors", result, want)
					}
					break
				}
				if time.Now().After(deadline) {
					t.Fatalf("app did not report after launcher exited: %s, %v", data, err)
				}
				time.Sleep(10 * time.Millisecond)
			}
			if err := os.WriteFile(filepath.Join(dir, name), []byte("#!/bin/sh\nexit 7\n"), 0700); err != nil {
				t.Fatal(err)
			}
			if err := b.Run(ctx, []string{operation, value}); err == nil || ExitCode(err) != 7 {
				t.Fatalf("launcher failure not preserved: %v", err)
			}
		})
	}
}
