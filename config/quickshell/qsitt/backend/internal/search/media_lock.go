package search

import (
	"context"
	"errors"
	"os"
	"path/filepath"
	"syscall"
	"time"
)

// Watchers run as separate processes. Serialize asset publication and cleanup,
// including the filesystem work outside SQLite transactions, so pruning/clear
// cannot delete a concurrent writer's newly published preview.
func (s *Store) lockMedia(ctx context.Context) (func(), error) {
	if err := os.MkdirAll(s.mediaDir(), 0700); err != nil {
		return nil, err
	}
	file, err := os.OpenFile(filepath.Join(s.mediaDir(), ".lock"), os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return nil, err
	}
	for {
		err = syscall.Flock(int(file.Fd()), syscall.LOCK_EX|syscall.LOCK_NB)
		if err == nil {
			return func() { _ = syscall.Flock(int(file.Fd()), syscall.LOCK_UN); _ = file.Close() }, nil
		}
		if !errors.Is(err, syscall.EWOULDBLOCK) && !errors.Is(err, syscall.EINTR) {
			_ = file.Close()
			return nil, err
		}
		select {
		case <-ctx.Done():
			_ = file.Close()
			return nil, ctx.Err()
		case <-time.After(10 * time.Millisecond):
		}
	}
}
