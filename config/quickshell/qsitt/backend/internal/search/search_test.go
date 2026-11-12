package search

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"io"
	"math"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
)

func testStore(t *testing.T) *Store {
	t.Helper()
	root := t.TempDir()
	s := &Store{Root: filepath.Join(root, "shell"), Home: filepath.Join(root, "home"), State: filepath.Join(root, "state"), Cache: filepath.Join(root, "cache")}
	if err := os.MkdirAll(s.Home, 0700); err != nil {
		t.Fatal(err)
	}
	t.Setenv("XDG_DATA_HOME", filepath.Join(root, "data"))
	t.Setenv("XDG_DATA_DIRS", filepath.Join(root, "system-data"))
	t.Setenv("CLIPBOARD_STATE", "")
	t.Cleanup(s.Close)
	return s
}

func writeTestFile(t *testing.T, path string, data []byte) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, data, 0600); err != nil {
		t.Fatal(err)
	}
}

func TestFuzzyCompatibility(t *testing.T) {
	// Scores captured from the previous Python implementation before removing it.
	data, err := os.ReadFile("testdata/fuzzy.json")
	if err != nil {
		t.Fatal(err)
	}
	var cases []struct {
		Text, Query string
		Score       *float64
	}
	if err = json.Unmarshal(data, &cases); err != nil {
		t.Fatal(err)
	}
	for _, test := range cases {
		score, matched := FuzzyScore(test.Text, test.Query)
		if (test.Score != nil) != matched || matched && math.Abs(score-*test.Score) > 1e-9 {
			t.Errorf("%q / %q: score=%v matched=%v expected=%v", test.Text, test.Query, score, matched, test.Score)
		}
	}
}

func TestAppsAndShortcuts(t *testing.T) {
	s := testStore(t)
	local := filepath.Join(os.Getenv("XDG_DATA_HOME"), "applications")
	system := filepath.Join(os.Getenv("XDG_DATA_DIRS"), "applications")
	writeTestFile(t, filepath.Join(system, "hidden.desktop"), []byte("[Desktop Entry]\nType=Application\nName=Visible system\n"))
	writeTestFile(t, filepath.Join(local, "hidden.desktop"), []byte("[Desktop Entry]\nHidden=true\n"))
	writeTestFile(t, filepath.Join(local, "nested", "firefox.desktop"), []byte("[Desktop Entry]\nType=Application\nName=Firefox\nName[ja]=Firefox 日本語\nGenericName=Browser\nIcon=firefox\n"))
	writeTestFile(t, filepath.Join(local, "missing.desktop"), []byte("[Desktop Entry]\nType=Application\nName=Missing\nTryExec=/does/not/exist\n"))
	writeTestFile(t, filepath.Join(local, "nodisplay.desktop"), []byte("[Desktop Entry]\nType=Application\nName=Hidden\nNoDisplay=true\n"))
	writeTestFile(t, filepath.Join(s.Root, "config", "search-shortcuts.json"), []byte(`{"apps":["nested-firefox.desktop","hidden.desktop"],"tools":["qr","unknown"]}`))
	results, err := s.Query(context.Background(), "", "all")
	if err != nil || len(results) != 2 || results[0].DesktopID != "nested-firefox.desktop" || results[1].Value != "qr" {
		t.Fatalf("shortcuts: %+v %v", results, err)
	}
	results, err = s.Query(context.Background(), "frfx", "apps")
	if err != nil || len(results) != 1 || results[0].Title != "Firefox 日本語" {
		t.Fatalf("apps: %+v %v", results, err)
	}
	if _, err = s.Query(context.Background(), "query", "invalid"); err == nil {
		t.Fatal("accepted invalid category")
	}
}

func TestIndexSkipsGeneratedFilesAndEscapesSQL(t *testing.T) {
	s := testStore(t)
	for _, name := range []string{"Documents/Research notes.txt", "Documents/100%_report.txt", "Documents/100xxreport.txt", "Documents/.secret", "Documents/node_modules/dependency.js", "Documents/build/output", "Documents/.hidden/inside", "Documents/日本語.txt"} {
		writeTestFile(t, filepath.Join(s.Home, name), []byte("fixture"))
	}
	ctx := context.Background()
	if _, err := s.Index(ctx); err != nil {
		t.Fatal(err)
	}
	for query, want := range map[string]string{"rs nt": "Research notes.txt", "%_": "100%_report.txt", "日本": "日本語.txt"} {
		results, err := s.Query(ctx, query, "files")
		if err != nil || len(results) == 0 || results[0].Title != want {
			t.Fatalf("query %q: %+v %v", query, results, err)
		}
		if query == "%_" && len(results) != 1 {
			t.Fatalf("SQL wildcards were not escaped: %+v", results)
		}
	}
	for _, name := range []string{"dependency.js", "output", ".secret", "inside"} {
		var count int
		if err := s.files.QueryRow("SELECT count(*) FROM files WHERE name = ?", name).Scan(&count); err != nil || count != 0 {
			t.Fatalf("indexed excluded file %q: %d %v", name, count, err)
		}
	}
	if err := os.Remove(filepath.Join(s.Home, "Documents", "Research notes.txt")); err != nil {
		t.Fatal(err)
	}
	results, err := s.Query(ctx, "rs nt", "files")
	if err != nil {
		t.Fatal(err)
	}
	for _, result := range results {
		if result.Title == "Research notes.txt" {
			t.Fatalf("stale path returned: %+v", result)
		}
	}
	if _, err = s.Index(ctx); err != nil {
		t.Fatal(err)
	}
	var count int
	if err = s.files.QueryRow("SELECT count(*) FROM files WHERE name = 'Research notes.txt'").Scan(&count); err != nil || count != 0 {
		t.Fatalf("index not replaced: %d %v", count, err)
	}
}

func TestLegacyClipboardAndIndexDatabases(t *testing.T) {
	s := testStore(t)
	ctx := context.Background()
	// Create the exact old schema and fixed IDs, independently of Store's schema setup.
	if err := os.MkdirAll(s.State, 0700); err != nil {
		t.Fatal(err)
	}
	db, err := sql.Open("sqlite3", filepath.Join(s.State, "clipboard.sqlite3"))
	if err != nil {
		t.Fatal(err)
	}
	_, err = db.Exec(`CREATE TABLE clips (id INTEGER PRIMARY KEY,text TEXT NOT NULL UNIQUE,copied_at INTEGER NOT NULL);
CREATE TABLE media (id INTEGER PRIMARY KEY,digest TEXT NOT NULL UNIQUE,kind TEXT NOT NULL,mime TEXT NOT NULL,source TEXT NOT NULL,preview TEXT NOT NULL,title TEXT NOT NULL,copied_at INTEGER NOT NULL);
INSERT INTO clips VALUES (42,'既存の履歴',1700000000);`)
	if err != nil {
		t.Fatal(err)
	}
	_ = db.Close()
	results, err := s.Query(ctx, "既存", "clipboard")
	if err != nil || len(results) != 1 || results[0].Value != "42" {
		t.Fatalf("old clipboard: %+v %v", results, err)
	}
	var copied string
	s.Run = func(_ context.Context, input io.Reader, name string, args ...string) error {
		if name != "wl-copy" || len(args) != 2 || args[1] != "text/plain;charset=utf-8" {
			t.Fatalf("copy command: %s %v", name, args)
		}
		data, _ := io.ReadAll(input)
		copied = string(data)
		return nil
	}
	if err = s.Copy(ctx, "42"); err != nil || copied != "既存の履歴" {
		t.Fatalf("old copy: %q %v", copied, err)
	}
	path := filepath.Join(s.Home, "old-file.txt")
	writeTestFile(t, path, []byte("old"))
	if err = os.MkdirAll(s.Cache, 0700); err != nil {
		t.Fatal(err)
	}
	db, err = sql.Open("sqlite3", filepath.Join(s.Cache, "files.sqlite3"))
	if err != nil {
		t.Fatal(err)
	}
	_, err = db.Exec("CREATE TABLE files(path TEXT PRIMARY KEY,name TEXT NOT NULL,name_lower TEXT NOT NULL)")
	if err != nil {
		t.Fatal(err)
	}
	_, err = db.Exec("INSERT INTO files VALUES (?,?,?)", path, "old-file.txt", "old-file.txt")
	if err != nil {
		t.Fatal(err)
	}
	_ = db.Close()
	results, err = s.Query(ctx, "old", "files")
	if err != nil || len(results) != 1 || results[0].Value != path {
		t.Fatalf("old files: %+v %v", results, err)
	}
}

func TestTextLimitsPrivacyRetentionAndConcurrentWriters(t *testing.T) {
	s := testStore(t)
	ctx := context.Background()
	for _, state := range []string{"nil", "clear", "sensitive"} {
		t.Setenv("CLIPBOARD_STATE", state)
		if err := s.AddText(ctx, strings.NewReader("private")); err != nil {
			t.Fatal(err)
		}
	}
	t.Setenv("CLIPBOARD_STATE", "")
	for _, value := range []string{strings.Repeat("x", maxTextBytes+1), "bad\x00text", " \n "} {
		if err := s.AddText(ctx, strings.NewReader(value)); err != nil {
			t.Fatal(err)
		}
	}
	results, err := s.Query(ctx, "", "clipboard")
	if err != nil || len(results) != 0 {
		t.Fatalf("saved rejected input: %+v %v", results, err)
	}
	// Independent connections model simultaneous wl-paste watcher processes.
	var writers sync.WaitGroup
	errors := make(chan error, 4)
	for worker := 0; worker < 4; worker++ {
		writers.Add(1)
		go func(worker int) {
			defer writers.Done()
			other := &Store{Home: s.Home, Root: s.Root, State: s.State, Cache: s.Cache}
			defer other.Close()
			for index := 0; index < 30; index++ {
				if err := other.AddText(ctx, strings.NewReader(fmt.Sprintf("clip %d %d", worker, index))); err != nil {
					errors <- err
					return
				}
			}
		}(worker)
	}
	writers.Wait()
	close(errors)
	for err := range errors {
		t.Fatal(err)
	}
	var count int
	if err = s.clips.QueryRow("SELECT count(*) FROM clips").Scan(&count); err != nil || count != 100 {
		t.Fatalf("retention: %d %v", count, err)
	}
	for range 2 {
		if err = s.AddText(ctx, strings.NewReader("重複\nテキスト")); err != nil {
			t.Fatal(err)
		}
	}
	results, err = s.Query(ctx, "重複", "clipboard")
	if err != nil || len(results) != 1 || results[0].Title != "重複 ⏎ テキスト" {
		t.Fatalf("dedup: %+v %v", results, err)
	}
}

func imageData(t *testing.T, width, height int) []byte {
	t.Helper()
	img := image.NewNRGBA(image.Rect(0, 0, width, height))
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			img.SetNRGBA(x, y, color.NRGBA{R: uint8(x % 255), G: uint8(y % 255), A: 255})
		}
	}
	var out bytes.Buffer
	if err := png.Encode(&out, img); err != nil {
		t.Fatal(err)
	}
	return out.Bytes()
}

func TestImageRoundTripClearAndExternalFiles(t *testing.T) {
	s := testStore(t)
	ctx := context.Background()
	data := imageData(t, 640, 480)
	if err := s.AddImage(ctx, bytes.NewReader(data)); err != nil {
		t.Fatal(err)
	}
	if err := s.AddImage(ctx, bytes.NewReader(data)); err != nil {
		t.Fatal(err)
	}
	results, err := s.Query(ctx, "画像", "clipboard")
	if err != nil || len(results) != 1 || results[0].MIME != "image/png" || !strings.HasPrefix(results[0].Preview, "file:") {
		t.Fatalf("image: %+v %v", results, err)
	}
	var source, preview string
	if err = s.clips.QueryRow("SELECT source,preview FROM media").Scan(&source, &preview); err != nil {
		t.Fatal(err)
	}
	thumb, err := os.Open(preview)
	if err != nil {
		t.Fatal(err)
	}
	config, _, err := image.DecodeConfig(thumb)
	_ = thumb.Close()
	if err != nil || config.Width != 320 || config.Height != 240 {
		t.Fatalf("thumbnail: %+v %v", config, err)
	}
	var copied []byte
	s.Run = func(_ context.Context, input io.Reader, name string, args ...string) error {
		if name != "wl-copy" || args[1] != "image/png" {
			t.Fatalf("copy %s %v", name, args)
		}
		copied, _ = io.ReadAll(input)
		return nil
	}
	if err = s.Copy(ctx, results[0].Value); err != nil || !bytes.Equal(data, copied) {
		t.Fatalf("image copy: %v", err)
	}
	external := filepath.Join(s.Home, "a space 日本語.png")
	writeTestFile(t, external, data)
	if err = s.AddFiles(ctx, strings.NewReader("# comment\r\n"+fileURI(external)+"\r\nfile://remote/not-allowed.png\r\n")); err != nil {
		t.Fatal(err)
	}
	results, err = s.Query(ctx, "", "clipboard")
	if err != nil || len(results) != 2 {
		t.Fatalf("file media: %+v %v", results, err)
	}
	for _, result := range results {
		if result.Kind == "clipboard-file" {
			s.Run = func(_ context.Context, input io.Reader, name string, args ...string) error {
				copied, _ = io.ReadAll(input)
				if name != "wl-copy" || args[1] != "text/uri-list" {
					t.Fatalf("file copy: %s %v", name, args)
				}
				return nil
			}
			if err = s.Copy(ctx, result.Value); err != nil || string(copied) != fileURI(external)+"\r\n" {
				t.Fatalf("URI copy: %q %v", copied, err)
			}
		}
	}
	if err = s.Clear(ctx); err != nil {
		t.Fatal(err)
	}
	for _, path := range []string{source, preview} {
		if _, err = os.Stat(path); !os.IsNotExist(err) {
			t.Fatalf("owned asset remains: %s", path)
		}
	}
	if !isFile(external) {
		t.Fatal("clear deleted an external source file")
	}
	results, err = s.Query(ctx, "", "clipboard")
	if err != nil || len(results) != 0 {
		t.Fatalf("clear: %+v %v", results, err)
	}
}
