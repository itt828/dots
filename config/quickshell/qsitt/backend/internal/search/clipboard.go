package search

import (
	"context"
	"database/sql"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"
	"time"
)

func clipboardSuppressed() bool {
	switch os.Getenv("CLIPBOARD_STATE") {
	case "nil", "clear", "sensitive":
		return true
	}
	return false
}

func (s *Store) AddText(ctx context.Context, input io.Reader) error {
	if clipboardSuppressed() {
		return nil
	}
	data, err := readLimited(input, maxTextBytes)
	if err != nil {
		return err
	}
	value := strings.TrimSpace(strings.ToValidUTF8(string(data), "\uFFFD"))
	if value == "" || strings.ContainsRune(value, 0) {
		return nil
	}
	db, err := s.clipboardDB(ctx)
	if err != nil {
		return err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err = tx.ExecContext(ctx, "DELETE FROM clips WHERE text = ?", value); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "INSERT INTO clips (text, copied_at) VALUES (?, ?)", value, time.Now().Unix()); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "DELETE FROM clips WHERE id NOT IN (SELECT id FROM clips ORDER BY copied_at DESC, id DESC LIMIT 100)"); err != nil {
		return err
	}
	return tx.Commit()
}

type media struct {
	ID                                         int64
	Digest, Kind, MIME, Source, Preview, Title string
	CopiedAt                                   int64
}

func (s *Store) mediaDir() string { return filepath.Join(s.State, "clipboard-media") }

func (s *Store) deleteOwned(paths []string) error {
	for _, path := range paths {
		if filepath.Dir(path) != s.mediaDir() {
			continue
		}
		if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
			return err
		}
	}
	return nil
}

func (s *Store) saveMedia(ctx context.Context, item media) error {
	db, err := s.clipboardDB(ctx)
	if err != nil {
		return err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	obsolete := []string{}
	var source, preview string
	err = tx.QueryRowContext(ctx, "SELECT source, preview FROM media WHERE digest = ?", item.Digest).Scan(&source, &preview)
	if err == nil {
		obsolete = append(obsolete, source, preview)
	} else if err != sql.ErrNoRows {
		return err
	}
	if _, err = tx.ExecContext(ctx, "DELETE FROM media WHERE digest = ?", item.Digest); err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "INSERT INTO media (digest,kind,mime,source,preview,title,copied_at) VALUES (?,?,?,?,?,?,?)", item.Digest, item.Kind, item.MIME, item.Source, item.Preview, item.Title, time.Now().Unix()); err != nil {
		return err
	}
	rows, err := tx.QueryContext(ctx, "SELECT source, preview FROM media ORDER BY copied_at DESC, id DESC LIMIT -1 OFFSET 30")
	if err != nil {
		return err
	}
	for rows.Next() {
		if err = rows.Scan(&source, &preview); err != nil {
			_ = rows.Close()
			return err
		}
		obsolete = append(obsolete, source, preview)
	}
	err = rows.Err()
	_ = rows.Close()
	if err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "DELETE FROM media WHERE id NOT IN (SELECT id FROM media ORDER BY copied_at DESC, id DESC LIMIT 30)"); err != nil {
		return err
	}
	active := map[string]bool{}
	rows, err = tx.QueryContext(ctx, "SELECT source, preview FROM media")
	if err != nil {
		return err
	}
	for rows.Next() {
		if err = rows.Scan(&source, &preview); err != nil {
			_ = rows.Close()
			return err
		}
		active[source], active[preview] = true, true
	}
	err = rows.Err()
	_ = rows.Close()
	if err != nil {
		return err
	}
	if err = tx.Commit(); err != nil {
		return err
	}
	// Callers hold the media lock until publication and pruning are both complete.
	for _, path := range obsolete {
		if !active[path] {
			if err = s.deleteOwned([]string{path}); err != nil {
				return err
			}
		}
	}
	return nil
}

func (s *Store) Clear(ctx context.Context) error {
	unlock, err := s.lockMedia(ctx)
	if err != nil {
		return err
	}
	defer unlock()
	db, err := s.clipboardDB(ctx)
	if err != nil {
		return err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	rows, err := tx.QueryContext(ctx, "SELECT source, preview FROM media")
	if err != nil {
		return err
	}
	paths := []string{}
	for rows.Next() {
		var source, preview string
		if err = rows.Scan(&source, &preview); err != nil {
			_ = rows.Close()
			return err
		}
		paths = append(paths, source, preview)
	}
	err = rows.Err()
	_ = rows.Close()
	if err != nil {
		return err
	}
	if _, err = tx.ExecContext(ctx, "DELETE FROM clips; DELETE FROM media;"); err != nil {
		return err
	}
	if err = tx.Commit(); err != nil {
		return err
	}
	return s.deleteOwned(paths)
}

func (s *Store) Copy(ctx context.Context, id string) error {
	db, err := s.clipboardDB(ctx)
	if err != nil {
		return err
	}
	if kind, rowID, ok := strings.Cut(id, ":"); ok {
		if kind != "image" && kind != "file" {
			return fmt.Errorf("invalid clipboard kind: %s", kind)
		}
		key, err := strconv.ParseInt(rowID, 10, 64)
		if err != nil || key < 1 {
			return fmt.Errorf("invalid clipboard id: %s", id)
		}
		var item media
		err = db.QueryRowContext(ctx, "SELECT kind,mime,source FROM media WHERE id = ?", key).Scan(&item.Kind, &item.MIME, &item.Source)
		if err == sql.ErrNoRows {
			return nil
		}
		if err != nil {
			return err
		}
		if item.Kind != kind || !isFile(item.Source) {
			return nil
		}
		if kind == "image" {
			file, err := os.Open(item.Source)
			if err != nil {
				return err
			}
			defer file.Close()
			return s.run(ctx, file, "wl-copy", "--type", item.MIME)
		}
		return s.run(ctx, strings.NewReader(fileURI(item.Source)+"\r\n"), "wl-copy", "--type", "text/uri-list")
	}
	key, err := strconv.ParseInt(id, 10, 64)
	if err != nil || key < 1 {
		return fmt.Errorf("invalid clipboard id: %s", id)
	}
	var text string
	err = db.QueryRowContext(ctx, "SELECT text FROM clips WHERE id = ?", key).Scan(&text)
	if err == sql.ErrNoRows {
		return nil
	}
	if err != nil {
		return err
	}
	return s.run(ctx, strings.NewReader(text), "wl-copy", "--type", "text/plain;charset=utf-8")
}

func truncate(value string, limit int) string {
	chars := []rune(value)
	return string(chars[:min(len(chars), limit)])
}

func (s *Store) clipboardResults(ctx context.Context, query string, limit int) ([]Result, error) {
	db, err := s.clipboardDB(ctx)
	if err != nil {
		return nil, err
	}
	type ranked struct {
		score        float64
		copiedAt, id int64
		item         Result
	}
	items := []ranked{}
	rows, err := db.QueryContext(ctx, "SELECT id,text,copied_at FROM clips ORDER BY copied_at DESC,id DESC LIMIT 100")
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		var id, copiedAt int64
		var value string
		if err = rows.Scan(&id, &value, &copiedAt); err != nil {
			_ = rows.Close()
			return nil, err
		}
		if score, ok := FuzzyScore(truncate(value, 2000), query); ok {
			items = append(items, ranked{score, copiedAt, id, Result{Kind: "clipboard", Title: truncate(strings.ReplaceAll(value, "\n", " ⏎ "), 100), Subtitle: "クリップボードにコピー", Value: strconv.FormatInt(id, 10)}})
		}
	}
	err = rows.Err()
	_ = rows.Close()
	if err != nil {
		return nil, err
	}
	rows, err = db.QueryContext(ctx, "SELECT id,kind,mime,source,preview,title,copied_at FROM media ORDER BY copied_at DESC,id DESC LIMIT 30")
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		var item media
		if err = rows.Scan(&item.ID, &item.Kind, &item.MIME, &item.Source, &item.Preview, &item.Title, &item.CopiedAt); err != nil {
			_ = rows.Close()
			return nil, err
		}
		if !isFile(item.Source) {
			continue
		}
		keywords := "media"
		switch {
		case strings.HasPrefix(item.MIME, "image/"):
			keywords = "picture photo 画像"
		case strings.HasPrefix(item.MIME, "video/"):
			keywords = "video movie 動画"
		case strings.HasPrefix(item.MIME, "audio/"):
			keywords = "audio music 音声"
		}
		if score, ok := rankedMatch(item.Title, item.MIME+" "+keywords, query); ok {
			preview := ""
			if isFile(item.Preview) {
				preview = fileURI(item.Preview)
			}
			items = append(items, ranked{score, item.CopiedAt, item.ID, Result{Kind: "clipboard-" + item.Kind, Title: item.Title, Subtitle: "クリックで再コピー", Value: item.Kind + ":" + strconv.FormatInt(item.ID, 10), Preview: preview, MIME: item.MIME}})
		}
	}
	err = rows.Err()
	_ = rows.Close()
	if err != nil {
		return nil, err
	}
	sort.SliceStable(items, func(i, j int) bool {
		a, b := items[i], items[j]
		if a.score != b.score {
			return a.score < b.score
		}
		if a.copiedAt != b.copiedAt {
			return a.copiedAt > b.copiedAt
		}
		return a.id > b.id
	})
	result := []Result{}
	for _, item := range items[:min(len(items), limit)] {
		result = append(result, item.item)
	}
	return result, nil
}
