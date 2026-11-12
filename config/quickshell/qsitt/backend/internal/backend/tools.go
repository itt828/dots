package backend

import (
	"bytes"
	"context"
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"time"
)

var geometryPattern = regexp.MustCompile(`^-?\d+,-?\d+ ([1-9]\d*)x([1-9]\d*)$`)

func (b *Backend) copy(ctx context.Context, data []byte) error {
	return b.run(ctx, bytes.NewReader(data), "wl-copy")
}

func (b *Backend) tool(ctx context.Context, args []string) error {
	if len(args) == 1 {
		switch args[0] {
		case "timer-notify":
			return b.run(ctx, nil, "notify-send", "タイマー", "設定した時間になりました", "-u", "critical")
		case "color":
			return b.pickColor(ctx)
		}
	}
	if len(args) == 2 && geometryPattern.MatchString(args[1]) {
		switch args[0] {
		case "qr":
			return b.readQR(ctx, args[1])
		case "lens":
			return b.lens(ctx, args[1])
		}
	}
	return errors.New("invalid tool arguments or geometry")
}

func (b *Backend) capture(ctx context.Context, geometry string) ([]byte, error) {
	return b.output(ctx, nil, "grim", "-g", geometry, "-t", "png", "-")
}

func (b *Backend) readQR(ctx context.Context, geometry string) error {
	image, err := b.capture(ctx, geometry)
	if err != nil {
		return err
	}
	value, err := b.output(ctx, bytes.NewReader(image), "zbarimg", "--quiet", "--raw", "-")
	value = bytes.TrimRight(value, "\r\n")
	if err != nil || len(value) == 0 {
		return &ExitError{30, "no QR code found"}
	}
	if err = b.copy(ctx, value); err != nil {
		return &ExitError{40, "could not copy QR code"}
	}
	// A missing notification daemon must not turn a successful scan into an error.
	_, _ = b.output(ctx, nil, "notify-send", "QRコード", "クリップボードにコピーしました")
	return nil
}

func (b *Backend) pickColor(ctx context.Context) error {
	for _, name := range []string{"slurp", "grim", "magick", "wl-copy"} {
		if _, err := exec.LookPath(name); err != nil {
			return &ExitError{20, "missing tool: " + name}
		}
	}
	// Give the control center time to disappear before requesting a selection.
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-time.After(250 * time.Millisecond):
	}
	selection, err := b.output(ctx, nil, "slurp", "-p", "-f", "%x,%y 1x1")
	geometry := strings.TrimSpace(string(selection))
	if err != nil || geometry == "" {
		return &ExitError{10, "color selection cancelled"}
	}
	if !geometryPattern.MatchString(geometry) {
		return errors.New("invalid color selection")
	}
	image, err := b.capture(ctx, geometry)
	if err != nil {
		return err
	}
	color, err := b.output(ctx, bytes.NewReader(image), "magick", "png:-", "-alpha", "off", "-depth", "8", "-format", "#%[hex:p{0,0}]", "info:-")
	color = bytes.TrimSpace(color)
	if err != nil || len(color) == 0 {
		return &ExitError{30, "could not read color"}
	}
	if err = b.copy(ctx, color); err != nil {
		return &ExitError{40, "could not copy color"}
	}
	_, err = b.Out.Write(color)
	return err
}

func (b *Backend) lens(ctx context.Context, geometry string) error {
	image, err := b.capture(ctx, geometry)
	if err != nil {
		return err
	}
	match := geometryPattern.FindStringSubmatch(geometry)
	page := fmt.Sprintf(`<!doctype html>
<meta charset="utf-8"><title>Google Lensへ送信中</title>
<p>Google Lensへ送信しています…</p>
<script>
(async () => {
 const response = await fetch("data:image/png;base64,%s");
 const file = new File([await response.blob()], "capture.png", {type: "image/png"});
 const transfer = new DataTransfer(); transfer.items.add(file);
 const form = document.createElement("form"); form.method = "POST";
 form.enctype = "multipart/form-data";
 form.action = "https://lens.google.com/v3/upload?ep=ccm&s=&st=%d";
 const image = document.createElement("input"); image.type = "file";
 image.name = "encoded_image"; image.files = transfer.files; form.appendChild(image);
 const size = document.createElement("input"); size.type = "hidden";
 size.name = "processed_image_dimensions"; size.value = "%s,%s"; form.appendChild(size);
 document.body.appendChild(form); form.submit();
})().catch(error => { document.body.textContent = "Google Lensへの送信に失敗しました: " + error; });
</script>`, base64.StdEncoding.EncodeToString(image), time.Now().UnixMilli(), match[1], match[2])
	file, err := os.CreateTemp("", "qsitt-lens-*.html")
	if err != nil {
		return err
	}
	defer os.Remove(file.Name())
	_, err = file.WriteString(page)
	closeErr := file.Close()
	if err != nil {
		return err
	}
	if closeErr != nil {
		return closeErr
	}
	if err = b.run(ctx, nil, "xdg-open", file.Name()); err != nil {
		return err
	}
	// xdg-open may return before the browser has read the file.
	select {
	case <-ctx.Done():
		return ctx.Err()
	case <-time.After(5 * time.Second):
		return nil
	}
}
