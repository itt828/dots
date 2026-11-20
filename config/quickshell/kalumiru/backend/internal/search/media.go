package search

import (
	"bytes"
	"context"
	"crypto/sha256"
	"fmt"
	"image"
	"image/color"
	_ "image/gif"
	_ "image/jpeg"
	"image/png"
	"io"
	"mime"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	_ "golang.org/x/image/bmp"
	xdraw "golang.org/x/image/draw"
	_ "golang.org/x/image/webp"
)

var imageFormats = map[string]struct{ mime, extension string }{
	"png": {"image/png", "png"}, "jpeg": {"image/jpeg", "jpg"}, "webp": {"image/webp", "webp"}, "gif": {"image/gif", "gif"}, "bmp": {"image/bmp", "bmp"},
}

type orientedImage struct {
	image.Image
	orientation int
}

func (img orientedImage) ColorModel() color.Model { return img.Image.ColorModel() }
func (img orientedImage) Bounds() image.Rectangle {
	b := img.Image.Bounds()
	if img.orientation >= 5 && img.orientation <= 8 {
		return image.Rect(0, 0, b.Dy(), b.Dx())
	}
	return image.Rect(0, 0, b.Dx(), b.Dy())
}
func (img orientedImage) At(x, y int) color.Color {
	b := img.Image.Bounds()
	w, h := b.Dx(), b.Dy()
	switch img.orientation {
	case 2:
		x = w - 1 - x
	case 3:
		x, y = w-1-x, h-1-y
	case 4:
		y = h - 1 - y
	case 5:
		x, y = y, x
	case 6:
		x, y = y, h-1-x
	case 7:
		x, y = w-1-y, h-1-x
	case 8:
		x, y = w-1-y, x
	}
	return img.Image.At(x+b.Min.X, y+b.Min.Y)
}

func makePreview(raw []byte) ([]byte, string, int, int, error) {
	config, format, err := image.DecodeConfig(bytes.NewReader(raw))
	if err != nil {
		return nil, "", 0, 0, err
	}
	if _, ok := imageFormats[format]; !ok || config.Width <= 0 || config.Height <= 0 || int64(config.Width)*int64(config.Height) > 50000000 {
		return nil, "", 0, 0, fmt.Errorf("unsupported image or too many pixels")
	}
	var source image.Image
	if format == "webp" {
		source, err = decodeWebP(raw, config)
	} else {
		source, _, err = image.Decode(bytes.NewReader(raw))
	}
	if err != nil {
		return nil, "", 0, 0, err
	}
	oriented := orientedImage{source, imageOrientation(raw, format)}
	w, h := oriented.Bounds().Dx(), oriented.Bounds().Dy()
	if w > 320 || h > 240 {
		if int64(w)*240 > int64(h)*320 {
			h = max(1, h*320/w)
			w = 320
		} else {
			w = max(1, w*240/h)
			h = 240
		}
	}
	thumb := image.NewNRGBA(image.Rect(0, 0, w, h))
	xdraw.CatmullRom.Scale(thumb, thumb.Bounds(), oriented, oriented.Bounds(), xdraw.Src, nil)
	var preview bytes.Buffer
	if err = png.Encode(&preview, thumb); err != nil {
		return nil, "", 0, 0, err
	}
	return preview.Bytes(), format, config.Width, config.Height, nil
}

func writeAsset(path string, data []byte) error {
	if err := os.MkdirAll(filepath.Dir(path), 0700); err != nil {
		return err
	}
	file, err := os.CreateTemp(filepath.Dir(path), ".media-*")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	_, err = file.Write(data)
	closeErr := file.Close()
	if err != nil {
		return err
	}
	if closeErr != nil {
		return closeErr
	}
	return os.Rename(file.Name(), path)
}

func (s *Store) AddImage(ctx context.Context, input io.Reader) error {
	if clipboardSuppressed() {
		return nil
	}
	raw, err := readLimited(input, maxImageBytes)
	if err != nil || len(raw) == 0 {
		return err
	}
	preview, format, width, height, err := makePreview(raw)
	// Unsupported or corrupt clipboard data is ignored, without saving it.
	if err != nil {
		return nil
	}
	unlock, err := s.lockMedia(ctx)
	if err != nil {
		return err
	}
	defer unlock()
	digest := fmt.Sprintf("%x", sha256.Sum256(raw))
	info := imageFormats[format]
	source := filepath.Join(s.mediaDir(), digest+"."+info.extension)
	thumbnail := filepath.Join(s.mediaDir(), digest+"-preview.png")
	if err = writeAsset(source, raw); err != nil {
		return err
	}
	if err = writeAsset(thumbnail, preview); err != nil {
		return err
	}
	return s.saveMedia(ctx, media{Digest: digest, Kind: "image", MIME: info.mime, Source: source, Preview: thumbnail, Title: fmt.Sprintf("画像 / Image %d×%d • %s", width, height, strings.ToUpper(info.extension))})
}

func mediaMIME(path string) string {
	// Keep common media types available independently of /etc/mime.types.
	ext := strings.ToLower(filepath.Ext(path))
	known := map[string]string{".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg", ".gif": "image/gif", ".webp": "image/webp", ".bmp": "image/bmp", ".svg": "image/svg+xml", ".mp4": "video/mp4", ".mkv": "video/x-matroska", ".webm": "video/webm", ".mov": "video/quicktime", ".mp3": "audio/mpeg", ".flac": "audio/flac", ".wav": "audio/x-wav", ".ogg": "audio/ogg", ".m4a": "audio/mp4"}
	if value := known[ext]; value != "" {
		return value
	}
	value := mime.TypeByExtension(ext)
	if base, _, err := mime.ParseMediaType(value); err == nil {
		return base
	}
	return value
}

func (s *Store) AddFiles(ctx context.Context, input io.Reader) error {
	if clipboardSuppressed() {
		return nil
	}
	raw, err := readLimited(input, maxTextBytes)
	if err != nil || len(raw) == 0 {
		return err
	}
	unlock, err := s.lockMedia(ctx)
	if err != nil {
		return err
	}
	defer unlock()
	lines := strings.Split(strings.ReplaceAll(string(raw), "\r\n", "\n"), "\n")
	for _, line := range lines[:min(len(lines), 10)] {
		if ctx.Err() != nil {
			return ctx.Err()
		}
		line = strings.TrimSpace(line)
		if strings.HasPrefix(line, "#") {
			continue
		}
		uri, err := url.Parse(line)
		if err != nil || uri.Scheme != "file" || (uri.Host != "" && uri.Host != "localhost") || uri.User != nil || !filepath.IsAbs(uri.Path) || !isFile(uri.Path) {
			continue
		}
		path := filepath.Clean(uri.Path)
		kind := mediaMIME(path)
		if !strings.HasPrefix(kind, "image/") && !strings.HasPrefix(kind, "video/") && !strings.HasPrefix(kind, "audio/") {
			continue
		}
		digest := fmt.Sprintf("%x", sha256.Sum256([]byte(path)))
		preview, label := "", "音声"
		if strings.HasPrefix(kind, "image/") {
			preview, label = path, "画像"
		}
		if strings.HasPrefix(kind, "video/") {
			label = "動画"
			if _, err := exec.LookPath("ffmpeg"); err == nil {
				thumbnail := filepath.Join(s.mediaDir(), digest+"-video.png")
				if !isFile(thumbnail) {
					if err = os.MkdirAll(s.mediaDir(), 0700); err != nil {
						return err
					}
					// Publish complete previews only; failed/timeout encodes leave no asset.
					tmp, err := os.CreateTemp(s.mediaDir(), ".video-*.png")
					if err != nil {
						return err
					}
					name := tmp.Name()
					_ = tmp.Close()
					timeout, cancel := context.WithTimeout(ctx, 8*time.Second)
					err = s.run(timeout, nil, "ffmpeg", "-v", "error", "-y", "-ss", "1", "-i", path, "-frames:v", "1", "-vf", "scale=320:-1", name)
					cancel()
					if err == nil {
						_ = os.Rename(name, thumbnail)
					}
					_ = os.Remove(name)
				}
				if isFile(thumbnail) {
					preview = thumbnail
				}
			}
		}
		if err = s.saveMedia(ctx, media{Digest: digest, Kind: "file", MIME: kind, Source: path, Preview: preview, Title: label + " / " + filepath.Base(path)}); err != nil {
			return err
		}
	}
	return nil
}
