package search

import (
	"bytes"
	"encoding/binary"
)

// imageOrientation reads just the EXIF orientation; it never follows external
// offsets or allocates based on metadata-controlled lengths.
func imageOrientation(data []byte, format string) int {
	switch format {
	case "jpeg":
		for offset := 2; offset+4 <= len(data); {
			if data[offset] != 0xff {
				break
			}
			marker := data[offset+1]
			if marker == 0xda || marker == 0xd9 {
				break
			}
			if marker == 0xff {
				offset++
				continue
			}
			if marker == 0x01 || marker >= 0xd0 && marker <= 0xd7 {
				offset += 2
				continue
			}
			length := int(binary.BigEndian.Uint16(data[offset+2:]))
			if length < 2 || length > len(data)-offset-2 {
				break
			}
			payload := data[offset+4 : offset+2+length]
			if marker == 0xe1 && bytes.HasPrefix(payload, []byte("Exif\x00\x00")) {
				return tiffOrientation(payload[6:])
			}
			offset += 2 + length
		}
	case "png":
		for offset := 8; offset+12 <= len(data); {
			length := uint64(binary.BigEndian.Uint32(data[offset:]))
			if length > uint64(len(data)-offset-12) {
				break
			}
			if string(data[offset+4:offset+8]) == "eXIf" {
				return tiffOrientation(data[offset+8 : offset+8+int(length)])
			}
			offset += 12 + int(length)
		}
	case "webp":
		for offset := 12; offset+8 <= len(data); {
			length := uint64(binary.LittleEndian.Uint32(data[offset+4:]))
			if length > uint64(len(data)-offset-8) {
				break
			}
			if string(data[offset:offset+4]) == "EXIF" {
				payload := data[offset+8 : offset+8+int(length)]
				payload = bytes.TrimPrefix(payload, []byte("Exif\x00\x00"))
				return tiffOrientation(payload)
			}
			offset += 8 + int(length) + (int(length) & 1)
		}
	}
	return 1
}

func tiffOrientation(data []byte) int {
	if len(data) < 8 {
		return 1
	}
	var order binary.ByteOrder
	switch string(data[:2]) {
	case "II":
		order = binary.LittleEndian
	case "MM":
		order = binary.BigEndian
	default:
		return 1
	}
	if order.Uint16(data[2:]) != 42 {
		return 1
	}
	offset := uint64(order.Uint32(data[4:]))
	if offset+2 > uint64(len(data)) {
		return 1
	}
	count := uint64(order.Uint16(data[offset:]))
	for index := uint64(0); index < count; index++ {
		pos := offset + 2 + index*12
		if pos+12 > uint64(len(data)) {
			return 1
		}
		entry := data[pos : pos+12]
		if order.Uint16(entry) == 0x112 && order.Uint16(entry[2:]) == 3 && order.Uint32(entry[4:]) == 1 {
			value := int(order.Uint16(entry[8:]))
			if value >= 1 && value <= 8 {
				return value
			}
			return 1
		}
	}
	return 1
}
