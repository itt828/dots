package search

import (
	"bytes"
	"context"
	"encoding/base64"
	"encoding/binary"
	"hash/crc32"
	"image"
	"image/color"
	"image/gif"
	"image/jpeg"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"golang.org/x/image/bmp"
)

func exif(orientation int) []byte {
	data := make([]byte, 26)
	copy(data, "II")
	binary.LittleEndian.PutUint16(data[2:], 42)
	binary.LittleEndian.PutUint32(data[4:], 8)
	binary.LittleEndian.PutUint16(data[8:], 1)
	binary.LittleEndian.PutUint16(data[10:], 0x112)
	binary.LittleEndian.PutUint16(data[12:], 3)
	binary.LittleEndian.PutUint32(data[14:], 1)
	binary.LittleEndian.PutUint16(data[18:], uint16(orientation))
	return data
}

func TestImageFormatsOrientationAndMalformedInput(t *testing.T) {
	// A generated lossless 2x2 WebP fixture; no encoder or external tool at test time.
	webp, err := base64.StdEncoding.DecodeString("UklGRhwAAABXRUJQVlA4TA8AAAAvAUAAAAcQ9Y/+ByKi/wEA")
	if err != nil {
		t.Fatal(err)
	}
	if _, format, w, h, err := makePreview(webp); err != nil || format != "webp" || w != 2 || h != 2 {
		t.Fatalf("WebP: %s %dx%d %v", format, w, h, err)
	}
	animated, err := base64.StdEncoding.DecodeString("UklGRoQAAABXRUJQVlA4WAoAAAACAAAAAwAAAwAAQU5JTQYAAAD/////AABBTk1GKAAAAAAAAAAAAAMAAAMAAOgDAAJWUDhMDwAAAC8DwAAABxD1j/4HIqL/AQBBTk1GKAAAAAAAAAAAAAMAAAMAAOgDAABWUDhMDwAAAC8DwAAABxDR//4HIqL/AQA=")
	if err != nil {
		t.Fatal(err)
	}
	firstFrame, format, w, h, err := makePreview(animated)
	if err != nil || format != "webp" || w != 4 || h != 4 {
		t.Fatalf("animated WebP: %s %dx%d %v", format, w, h, err)
	}
	frame, _, err := image.Decode(bytes.NewReader(firstFrame))
	if err != nil {
		t.Fatal(err)
	}
	r, g, b, _ := frame.At(0, 0).RGBA()
	if r < 60000 || g > 2000 || b > 2000 {
		t.Fatalf("preview is not the first (red) frame: %d,%d,%d", r, g, b)
	}
	badCanvas := append([]byte{}, animated...)
	putUint24(badCanvas[24:27], 0)
	if _, _, _, _, err = makePreview(badCanvas); err == nil {
		t.Fatal("accepted a frame outside the canvas")
	}
	img := image.NewNRGBA(image.Rect(0, 0, 4, 2))
	img.Set(0, 0, color.NRGBA{R: 255, A: 255})
	for name, encode := range map[string]func(*bytes.Buffer) error{
		"jpeg": func(out *bytes.Buffer) error { return jpeg.Encode(out, img, nil) },
		"gif":  func(out *bytes.Buffer) error { return gif.Encode(out, img, nil) },
		"bmp":  func(out *bytes.Buffer) error { return bmp.Encode(out, img) },
	} {
		var raw bytes.Buffer
		if err := encode(&raw); err != nil {
			t.Fatal(err)
		}
		if _, format, w, h, err := makePreview(raw.Bytes()); err != nil || format != name || w != 4 || h != 2 {
			t.Fatalf("%s: %s %dx%d %v", name, format, w, h, err)
		}
	}
	var jpegData bytes.Buffer
	if err := jpeg.Encode(&jpegData, img, nil); err != nil {
		t.Fatal(err)
	}
	payload := append([]byte("Exif\x00\x00"), exif(6)...)
	segment := []byte{0xff, 0xe1, 0, byte(len(payload) + 2)}
	original := jpegData.Bytes()
	oriented := append(append(append([]byte{}, original[:2]...), segment...), payload...)
	oriented = append(oriented, original[2:]...)
	preview, _, _, _, err := makePreview(oriented)
	if err != nil {
		t.Fatal(err)
	}
	config, _, err := image.DecodeConfig(bytes.NewReader(preview))
	if err != nil || config.Width != 2 || config.Height != 4 {
		t.Fatalf("EXIF was not applied: %+v %v", config, err)
	}
	// Read equivalent metadata from PNG and WebP containers as well.
	pngEXIF := make([]byte, 8)
	pngEXIF = append(pngEXIF, 0, 0, 0, 26, 'e', 'X', 'I', 'f')
	pngEXIF = append(pngEXIF, exif(8)...)
	pngEXIF = append(pngEXIF, 0, 0, 0, 0)
	webpEXIF := append(make([]byte, 12), []byte{'E', 'X', 'I', 'F', 26, 0, 0, 0}...)
	webpEXIF = append(webpEXIF, exif(3)...)
	if imageOrientation(pngEXIF, "png") != 8 || imageOrientation(webpEXIF, "webp") != 3 {
		t.Fatal("container EXIF orientation not read")
	}
	// A large decompression header must be rejected before allocating its pixels.
	huge := imageData(t, 1, 1)
	binary.BigEndian.PutUint32(huge[16:], 50000001)
	binary.BigEndian.PutUint32(huge[29:], crc32.ChecksumIEEE(huge[12:29]))
	if _, _, _, _, err = makePreview(huge); err == nil {
		t.Fatal("accepted a decompression bomb")
	}
	for _, raw := range [][]byte{nil, []byte("not an image"), oriented[:12]} {
		if _, _, _, _, err = makePreview(raw); err == nil {
			t.Fatal("accepted malformed image")
		}
	}
}

func TestAllOrientationMappings(t *testing.T) {
	img := image.NewNRGBA(image.Rect(0, 0, 2, 3))
	for y := 0; y < 3; y++ {
		for x := 0; x < 2; x++ {
			img.SetNRGBA(x, y, color.NRGBA{R: uint8(y*2 + x + 1), A: 255})
		}
	}
	expected := map[int][]uint8{
		1: {1, 2, 3, 4, 5, 6}, 2: {2, 1, 4, 3, 6, 5}, 3: {6, 5, 4, 3, 2, 1}, 4: {5, 6, 3, 4, 1, 2},
		5: {1, 3, 5, 2, 4, 6}, 6: {5, 3, 1, 6, 4, 2}, 7: {6, 4, 2, 5, 3, 1}, 8: {2, 4, 6, 1, 3, 5},
	}
	for orientation, want := range expected {
		source := orientedImage{img, orientation}
		actual := []byte{}
		for y := 0; y < source.Bounds().Dy(); y++ {
			for x := 0; x < source.Bounds().Dx(); x++ {
				r, _, _, _ := source.At(x, y).RGBA()
				actual = append(actual, uint8(r>>8))
			}
		}
		if !bytes.Equal(actual, want) {
			t.Errorf("orientation %d: %v, want %v", orientation, actual, want)
		}
	}
}

func TestMediaRetentionAndRejectedInputs(t *testing.T) {
	s := testStore(t)
	ctx := context.Background()
	if err := s.AddImage(ctx, strings.NewReader(strings.Repeat("x", maxImageBytes+1))); err != nil {
		t.Fatal(err)
	}
	if err := s.AddFiles(ctx, strings.NewReader(strings.Repeat("x", maxTextBytes+1))); err != nil {
		t.Fatal(err)
	}
	t.Setenv("CLIPBOARD_STATE", "sensitive")
	if err := s.AddImage(ctx, bytes.NewReader(imageData(t, 2, 2))); err != nil {
		t.Fatal(err)
	}
	t.Setenv("CLIPBOARD_STATE", "")
	items, err := s.Query(ctx, "", "clipboard")
	if err != nil || len(items) != 0 {
		t.Fatalf("saved private/oversized input: %v %v", items, err)
	}
	firstSource, firstPreview := "", ""
	for index := 1; index <= 31; index++ {
		if err = s.AddImage(ctx, bytes.NewReader(imageData(t, index, 2))); err != nil {
			t.Fatal(err)
		}
		if index == 1 {
			if err = s.clips.QueryRow("SELECT source,preview FROM media").Scan(&firstSource, &firstPreview); err != nil {
				t.Fatal(err)
			}
		}
	}
	var count int
	if err = s.clips.QueryRow("SELECT count(*) FROM media").Scan(&count); err != nil || count != 30 {
		t.Fatalf("retention: %d %v", count, err)
	}
	for _, path := range []string{firstSource, firstPreview} {
		if _, err = os.Stat(path); !os.IsNotExist(err) {
			t.Fatalf("expired asset remains: %s", path)
		}
	}
	// Sources outside the owned media directory survive retention as well as clear.
	outside := filepath.Join(s.Home, "original.flac")
	writeTestFile(t, outside, []byte("source"))
	if err = s.AddFiles(ctx, strings.NewReader(fileURI(outside))); err != nil {
		t.Fatal(err)
	}
	if err = s.Clear(ctx); err != nil || !isFile(outside) {
		t.Fatalf("external source deleted: %v", err)
	}
}

func FuzzOrientationMetadata(f *testing.F) {
	f.Add([]byte("Exif\x00\x00"))
	f.Add(exif(6))
	f.Add([]byte{0xff, 0xd8, 0xff, 0xe1, 0xff, 0xff})
	f.Fuzz(func(t *testing.T, data []byte) {
		for _, format := range []string{"jpeg", "png", "webp"} {
			if got := imageOrientation(data, format); got < 1 || got > 8 {
				t.Fatalf("invalid orientation: %d", got)
			}
		}
		if got := tiffOrientation(data); got < 1 || got > 8 {
			t.Fatalf("invalid TIFF orientation: %d", got)
		}
	})
}

func TestMediaLockCancellationAndConcurrentClear(t *testing.T) {
	s := testStore(t)
	ctx := context.Background()
	unlock, err := s.lockMedia(ctx)
	if err != nil {
		t.Fatal(err)
	}
	wait, cancel := context.WithTimeout(ctx, 20*time.Millisecond)
	_, err = s.lockMedia(wait)
	cancel()
	unlock()
	if err != context.DeadlineExceeded {
		t.Fatalf("lock ignored cancellation: %v", err)
	}
	inputs := [][]byte{}
	for width := 1; width <= 10; width++ {
		inputs = append(inputs, imageData(t, width, 3))
	}
	var workers sync.WaitGroup
	errors := make(chan error, 2)
	for writer := 0; writer < 2; writer++ {
		workers.Add(1)
		go func(writer int) {
			defer workers.Done()
			store := &Store{Root: s.Root, Home: s.Home, State: s.State, Cache: s.Cache}
			defer store.Close()
			for _, input := range inputs {
				var err error
				if writer == 0 {
					err = store.AddImage(ctx, bytes.NewReader(input))
				} else {
					err = store.Clear(ctx)
				}
				if err != nil {
					errors <- err
					return
				}
			}
		}(writer)
	}
	workers.Wait()
	close(errors)
	for err := range errors {
		t.Fatal(err)
	}
	db, err := s.clipboardDB(ctx)
	if err != nil {
		t.Fatal(err)
	}
	rows, err := db.Query("SELECT source,preview FROM media")
	if err != nil {
		t.Fatal(err)
	}
	defer rows.Close()
	for rows.Next() {
		var source, preview string
		if err = rows.Scan(&source, &preview); err != nil {
			t.Fatal(err)
		}
		if !isFile(source) || !isFile(preview) {
			t.Fatalf("concurrent cleanup deleted retained media: %s / %s", source, preview)
		}
	}
	if err = rows.Err(); err != nil {
		t.Fatal(err)
	}
}
