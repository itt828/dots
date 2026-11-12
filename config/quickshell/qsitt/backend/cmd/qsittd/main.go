package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"

	"github.com/itt828/dots/config/quickshell/qsitt/backend/internal/backend"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	executable, err := os.Executable()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	if resolved, err := filepath.EvalSymlinks(executable); err == nil {
		executable = resolved
	}
	root := filepath.Dir(filepath.Dir(executable))
	if value := os.Getenv("QSITT_ROOT"); value != "" {
		root = value
	}
	b := backend.Backend{Root: root, In: os.Stdin, Out: os.Stdout, Err: os.Stderr}
	if err := b.Run(ctx, os.Args[1:]); err != nil {
		fmt.Fprintln(os.Stderr, "qsittd:", err)
		os.Exit(backend.ExitCode(err))
	}
}
