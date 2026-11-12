// Package search implements launcher search, the file index and clipboard history.
package search

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"net/url"
	"os"
	"path/filepath"

	_ "github.com/mattn/go-sqlite3"
)

const (
	maxFiles      = 150000
	maxTextBytes  = 65536
	maxImageBytes = 8 * 1024 * 1024
)

type Result struct {
	Kind      string `json:"kind"`
	Title     string `json:"title"`
	Subtitle  string `json:"subtitle"`
	Value     string `json:"value"`
	DesktopID string `json:"desktop_id,omitempty"`
	Icon      string `json:"icon,omitempty"`
	Preview   string `json:"preview,omitempty"`
	MIME      string `json:"mime,omitempty"`
}

type Store struct {
	Root, Home, State, Cache string
	Run                      func(context.Context, io.Reader, string, ...string) error
	clips, files             *sql.DB
}

func New(root string) (*Store, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	state := os.Getenv("XDG_STATE_HOME")
	if state == "" {
		state = filepath.Join(home, ".local", "state")
	}
	cache := os.Getenv("XDG_CACHE_HOME")
	if cache == "" {
		cache = filepath.Join(home, ".cache")
	}
	return &Store{Root: root, Home: home, State: filepath.Join(state, "qsitt"), Cache: filepath.Join(cache, "qsitt")}, nil
}

func (s *Store) Close() {
	if s.clips != nil {
		_ = s.clips.Close()
	}
	if s.files != nil {
		_ = s.files.Close()
	}
}

func openDB(path string) (*sql.DB, error) {
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return nil, err
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_RDWR, 0600)
	if err != nil {
		return nil, err
	}
	if err = f.Close(); err != nil {
		return nil, err
	}
	u := url.URL{Scheme: "file", Path: path}
	query := url.Values{"_busy_timeout": {"3000"}, "_txlock": {"immediate"}}
	u.RawQuery = query.Encode()
	db, err := sql.Open("sqlite3", u.String())
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	if err = db.Ping(); err != nil {
		_ = db.Close()
		return nil, err
	}
	return db, nil
}

func (s *Store) clipboardDB(ctx context.Context) (*sql.DB, error) {
	if s.clips != nil {
		return s.clips, nil
	}
	db, err := openDB(filepath.Join(s.State, "clipboard.sqlite3"))
	if err != nil {
		return nil, err
	}
	_, err = db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS clips (id INTEGER PRIMARY KEY, text TEXT NOT NULL UNIQUE, copied_at INTEGER NOT NULL);
CREATE TABLE IF NOT EXISTS media (id INTEGER PRIMARY KEY, digest TEXT NOT NULL UNIQUE, kind TEXT NOT NULL, mime TEXT NOT NULL, source TEXT NOT NULL, preview TEXT NOT NULL, title TEXT NOT NULL, copied_at INTEGER NOT NULL);`)
	if err != nil {
		_ = db.Close()
		return nil, err
	}
	s.clips = db
	return db, nil
}

func (s *Store) fileDB(ctx context.Context) (*sql.DB, error) {
	if s.files != nil {
		return s.files, nil
	}
	db, err := openDB(filepath.Join(s.Cache, "files.sqlite3"))
	if err != nil {
		return nil, err
	}
	_, err = db.ExecContext(ctx, `CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, name TEXT NOT NULL, name_lower TEXT NOT NULL);
CREATE INDEX IF NOT EXISTS files_name ON files(name_lower);
CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL);`)
	if err != nil {
		_ = db.Close()
		return nil, err
	}
	s.files = db
	return db, nil
}

func readLimited(input io.Reader, limit int64) ([]byte, error) {
	data, err := io.ReadAll(io.LimitReader(input, limit+1))
	if err != nil {
		return nil, err
	}
	if int64(len(data)) > limit {
		return nil, nil
	}
	return data, nil
}

func fileURI(path string) string { return (&url.URL{Scheme: "file", Path: path}).String() }
func isFile(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.Mode().IsRegular()
}

func (s *Store) run(ctx context.Context, input io.Reader, name string, args ...string) error {
	if s.Run == nil {
		return fmt.Errorf("process runner unavailable: %s", name)
	}
	return s.Run(ctx, input, name, args...)
}
