package search

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"image"
	"image/color"
	"image/draw"
)

type webpChunk struct {
	name string
	data []byte
}

func webpChunks(data []byte) ([]webpChunk, error) {
	chunks := []webpChunk{}
	for len(data) > 0 {
		if len(data) < 8 {
			return nil, fmt.Errorf("truncated WebP chunk")
		}
		length := uint64(binary.LittleEndian.Uint32(data[4:]))
		padded := length + (length & 1)
		if padded > uint64(len(data)-8) {
			return nil, fmt.Errorf("invalid WebP chunk size")
		}
		chunks = append(chunks, webpChunk{string(data[:4]), data[8 : 8+int(length)]})
		data = data[8+int(padded):]
	}
	return chunks, nil
}

func webpContainer(chunks []webpChunk) []byte {
	data := []byte("RIFF\x00\x00\x00\x00WEBP")
	for _, chunk := range chunks {
		data = append(data, []byte(chunk.name)...)
		header := make([]byte, 4)
		binary.LittleEndian.PutUint32(header, uint32(len(chunk.data)))
		data = append(data, header...)
		data = append(data, chunk.data...)
		if len(chunk.data)&1 != 0 {
			data = append(data, 0)
		}
	}
	binary.LittleEndian.PutUint32(data[4:], uint32(len(data)-8))
	return data
}

// Validate bitstream dimensions independently of VP8X before allocating pixels.
// Extended containers can otherwise claim a small canvas for a large bitstream.
func validateWebPFrame(chunks []webpChunk, width, height int) error {
	for _, chunk := range chunks {
		if chunk.name != "VP8 " && chunk.name != "VP8L" {
			continue
		}
		config, _, err := image.DecodeConfig(bytes.NewReader(webpContainer([]webpChunk{chunk})))
		if err != nil {
			return err
		}
		if config.Width != width || config.Height != height {
			return fmt.Errorf("WebP frame dimensions differ from its canvas")
		}
		return nil
	}
	return fmt.Errorf("WebP has no image bitstream")
}

func uint24(data []byte) int { return int(data[0]) | int(data[1])<<8 | int(data[2])<<16 }
func putUint24(data []byte, value int) {
	data[0], data[1], data[2] = byte(value), byte(value>>8), byte(value>>16)
}

// Animated WebP previews use the first frame, matching the old image pipeline.
// ANMF layout and blend flags: https://developers.google.com/speed/webp/docs/riff_container
func decodeWebP(raw []byte, config image.Config) (image.Image, error) {
	if len(raw) < 12 || string(raw[:4]) != "RIFF" || string(raw[8:12]) != "WEBP" {
		return nil, fmt.Errorf("invalid WebP header")
	}
	length := uint64(binary.LittleEndian.Uint32(raw[4:])) + 8
	if length < 12 || length > uint64(len(raw)) {
		return nil, fmt.Errorf("invalid WebP length")
	}
	chunks, err := webpChunks(raw[12:length])
	if err != nil {
		return nil, err
	}
	background := color.NRGBA{}
	for _, chunk := range chunks {
		if chunk.name == "ANIM" && len(chunk.data) >= 6 {
			background = color.NRGBA{R: chunk.data[2], G: chunk.data[1], B: chunk.data[0], A: chunk.data[3]}
		}
		if chunk.name != "ANMF" {
			continue
		}
		if len(chunk.data) < 16 {
			return nil, fmt.Errorf("invalid WebP frame header")
		}
		x, y := uint24(chunk.data[:3])*2, uint24(chunk.data[3:6])*2
		width, height := uint24(chunk.data[6:9])+1, uint24(chunk.data[9:12])+1
		if x+width > config.Width || y+height > config.Height {
			return nil, fmt.Errorf("WebP frame is outside its canvas")
		}
		frameChunks, err := webpChunks(chunk.data[16:])
		if err != nil {
			return nil, err
		}
		if err = validateWebPFrame(frameChunks, width, height); err != nil {
			return nil, err
		}
		header := make([]byte, 10)
		for _, frame := range frameChunks {
			if frame.name == "ALPH" {
				header[0] = 1 << 4
			}
		}
		putUint24(header[4:7], width-1)
		putUint24(header[7:10], height-1)
		frameChunks = append([]webpChunk{{"VP8X", header}}, frameChunks...)
		frame, _, err := image.Decode(bytes.NewReader(webpContainer(frameChunks)))
		if err != nil {
			return nil, err
		}
		canvas := image.NewNRGBA(image.Rect(0, 0, config.Width, config.Height))
		draw.Draw(canvas, canvas.Bounds(), image.NewUniform(background), image.Point{}, draw.Src)
		operation := draw.Over
		if chunk.data[15]&2 != 0 {
			operation = draw.Src
		}
		draw.Draw(canvas, image.Rect(x, y, x+width, y+height), frame, frame.Bounds().Min, operation)
		return canvas, nil
	}
	if err = validateWebPFrame(chunks, config.Width, config.Height); err != nil {
		return nil, err
	}
	source, _, err := image.Decode(bytes.NewReader(raw))
	return source, err
}
