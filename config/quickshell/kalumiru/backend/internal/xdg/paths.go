package xdg

import "path/filepath"

// AppDir returns the Kalumiru data directory under base.
func AppDir(base string) string {
	return filepath.Join(base, "kalumiru")
}
