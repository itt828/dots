package search

import (
	"context"
	"io/fs"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

var skippedDirs = map[string]bool{".git": true, "node_modules": true, "target": true, "build": true, "dist": true, ".venv": true, "venv": true, "__pycache__": true}

func (s *Store) searchRoots() []string {
	roots := []string{}
	seen := map[string]bool{}
	add := func(path string) {
		if !seen[path] {
			seen[path] = true
			roots = append(roots, path)
		}
	}
	for _, name := range []string{"Desktop", "Documents", "Downloads", "Pictures", "Music", "Videos", "dev", "Projects"} {
		add(filepath.Join(s.Home, name))
	}
	entries, _ := os.ReadDir(s.Home)
	for _, entry := range entries {
		if strings.HasPrefix(entry.Name(), ".") {
			continue
		}
		path := filepath.Join(s.Home, entry.Name())
		if info, err := os.Stat(path); err == nil && info.IsDir() {
			add(path)
		}
	}
	return roots
}

func (s *Store) Index(ctx context.Context) (int, error) {
	type item struct{ path, name string }
	items := make([]item, 0)
	for _, root := range s.searchRoots() {
		if len(items) >= maxFiles {
			break
		}
		if info, err := os.Stat(root); err != nil || !info.IsDir() {
			continue
		}
		// Read the root itself even when a user's Documents directory is a symlink.
		walkRoot, err := filepath.EvalSymlinks(root)
		if err != nil {
			continue
		}
		err = filepath.WalkDir(walkRoot, func(path string, entry fs.DirEntry, walkErr error) error {
			if ctx.Err() != nil {
				return ctx.Err()
			}
			if walkErr != nil {
				return nil
			}
			if path == walkRoot {
				return nil
			}
			if strings.HasPrefix(entry.Name(), ".") || (entry.IsDir() && skippedDirs[entry.Name()]) {
				if entry.IsDir() {
					return filepath.SkipDir
				}
				return nil
			}
			relative, err := filepath.Rel(walkRoot, path)
			if err != nil {
				return err
			}
			items = append(items, item{filepath.Join(root, relative), entry.Name()})
			if len(items) >= maxFiles {
				return filepath.SkipAll
			}
			return nil
		})
		if err != nil {
			return 0, err
		}
	}
	db, err := s.fileDB(ctx)
	if err != nil {
		return 0, err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return 0, err
	}
	defer tx.Rollback()
	if _, err = tx.ExecContext(ctx, "DELETE FROM files"); err != nil {
		return 0, err
	}
	stmt, err := tx.PrepareContext(ctx, "INSERT OR IGNORE INTO files VALUES (?, ?, ?)")
	if err != nil {
		return 0, err
	}
	defer stmt.Close()
	for _, item := range items {
		if _, err = stmt.ExecContext(ctx, item.path, item.name, fold(item.name)); err != nil {
			return 0, err
		}
	}
	if _, err = tx.ExecContext(ctx, "INSERT OR REPLACE INTO meta VALUES ('updated', ?)", strconv.FormatInt(time.Now().Unix(), 10)); err != nil {
		return 0, err
	}
	return len(items), tx.Commit()
}

func likePattern(word string) string {
	var pattern strings.Builder
	pattern.WriteByte('%')
	for _, char := range word {
		if char == '\\' || char == '%' || char == '_' {
			pattern.WriteByte('\\')
		}
		pattern.WriteRune(char)
		pattern.WriteByte('%')
	}
	return pattern.String()
}

func (s *Store) fileResults(ctx context.Context, query string, limit int) ([]Result, error) {
	result := []Result{}
	if query == "" {
		return result, nil
	}
	if _, err := os.Stat(filepath.Join(s.Cache, "files.sqlite3")); os.IsNotExist(err) {
		return result, nil
	}
	db, err := s.fileDB(ctx)
	if err != nil {
		return nil, err
	}
	conditions := []string{}
	args := []any{}
	for _, word := range strings.Fields(fold(query)) {
		conditions = append(conditions, `(name_lower LIKE ? ESCAPE '\' OR lower(path) LIKE ? ESCAPE '\')`)
		pattern := likePattern(word)
		args = append(args, pattern, pattern)
	}
	if len(conditions) == 0 {
		return result, nil
	}
	rows, err := db.QueryContext(ctx, "SELECT path, name FROM files WHERE "+strings.Join(conditions, " AND ")+" ORDER BY length(name), name LIMIT 10000", args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	type ranked struct {
		score      float64
		path, name string
	}
	rankedFiles := []ranked{}
	for rows.Next() {
		var path, name string
		if err = rows.Scan(&path, &name); err != nil {
			return nil, err
		}
		score, matched := FuzzyScore(name, query)
		if pathScore, ok := FuzzyScore(path, query); ok && (!matched || pathScore+50 < score) {
			score, matched = pathScore+50, true
		}
		if matched {
			rankedFiles = append(rankedFiles, ranked{score, path, name})
		}
	}
	if err = rows.Err(); err != nil {
		return nil, err
	}
	sort.SliceStable(rankedFiles, func(i, j int) bool {
		a, b := rankedFiles[i], rankedFiles[j]
		if a.score != b.score {
			return a.score < b.score
		}
		if len([]rune(a.name)) != len([]rune(b.name)) {
			return len([]rune(a.name)) < len([]rune(b.name))
		}
		if fold(a.name) != fold(b.name) {
			return fold(a.name) < fold(b.name)
		}
		return a.path < b.path
	})
	for _, file := range rankedFiles {
		if _, err := os.Stat(file.path); err != nil {
			continue
		}
		result = append(result, Result{Kind: "file", Title: file.name, Subtitle: file.path, Value: file.path})
		if len(result) == limit {
			break
		}
	}
	return result, nil
}
