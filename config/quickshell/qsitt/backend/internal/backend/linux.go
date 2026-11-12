package backend

import (
	"bufio"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"os"
	"regexp"
	"runtime"
	"strconv"
	"strings"
)

type Metric struct {
	Usage float64 `json:"usage"`
	Label string  `json:"label"`
}

func cpuMetric(data string, cores int) (Metric, error) {
	fields := strings.Fields(data)
	if len(fields) == 0 || cores < 1 {
		return Metric{}, errors.New("invalid loadavg")
	}
	load, err := strconv.ParseFloat(fields[0], 64)
	if err != nil || math.IsNaN(load) || math.IsInf(load, 0) || load < 0 {
		return Metric{}, errors.New("invalid CPU load")
	}
	return Metric{math.Min(load/float64(cores), 1), fields[0]}, nil
}

func memoryMetric(data string) (Metric, error) {
	values := map[string]float64{}
	for _, line := range strings.Split(data, "\n") {
		parts := strings.Fields(line)
		if len(parts) < 2 {
			continue
		}
		n, err := strconv.ParseFloat(parts[1], 64)
		if err != nil {
			return Metric{}, err
		}
		values[strings.TrimSuffix(parts[0], ":")] = n
	}
	available, ok := values["MemAvailable"]
	total := values["MemTotal"]
	if !ok || total <= 0 || available < 0 || available > total {
		return Metric{}, errors.New("invalid meminfo")
	}
	usage := (total - available) / total
	return Metric{usage, fmt.Sprintf("%.0f%%", math.Round(usage*100))}, nil
}

func (b *Backend) metrics(kind string) error {
	var metric Metric
	var err error
	switch kind {
	case "cpu":
		data, readErr := os.ReadFile("/proc/loadavg")
		if readErr != nil {
			return readErr
		}
		metric, err = cpuMetric(string(data), runtime.NumCPU())
	case "memory":
		data, readErr := os.ReadFile("/proc/meminfo")
		if readErr != nil {
			return readErr
		}
		metric, err = memoryMetric(string(data))
	default:
		return errors.New("unknown metric")
	}
	if err != nil {
		return err
	}
	return b.json(metric)
}

type Backlight struct {
	Current    int     `json:"current"`
	Maximum    int     `json:"maximum"`
	Brightness float64 `json:"brightness"`
}

func parseBacklight(data string) (Backlight, error) {
	parts := strings.Split(strings.TrimSpace(data), ",")
	if len(parts) < 5 {
		return Backlight{}, errors.New("invalid backlight response")
	}
	current, err := strconv.Atoi(parts[2])
	if err != nil {
		return Backlight{}, err
	}
	maximum, err := strconv.Atoi(parts[4])
	if err != nil || maximum <= 0 || current < 0 || current > maximum {
		return Backlight{}, errors.New("invalid backlight range")
	}
	return Backlight{current, maximum, float64(current) / float64(maximum)}, nil
}

func (b *Backend) backlight(ctx context.Context, args []string) error {
	if len(args) == 1 && args[0] == "watch" {
		return b.run(ctx, nil, "udevadm", "monitor", "-s", "backlight")
	}
	if len(args) == 2 && args[0] == "get" {
		command := []string{"-m"}
		switch args[1] {
		case "display":
		case "keyboard":
			command = append(command, "-d", "tpacpi::kbd_backlight")
		default:
			return errors.New("unknown backlight device")
		}
		data, err := b.output(ctx, nil, "brightnessctl", append(command, "info")...)
		if err != nil {
			return err
		}
		value, err := parseBacklight(string(data))
		if err != nil {
			return err
		}
		return b.json(value)
	}
	if len(args) == 2 && args[0] == "keyboard-set" {
		level, err := strconv.Atoi(args[1])
		if err != nil || level < 0 {
			return errors.New("invalid keyboard backlight level")
		}
		return b.run(ctx, nil, "brightnessctl", "-d", "tpacpi::kbd_backlight", "set", args[1])
	}
	return errors.New("invalid backlight arguments")
}

var lidValue = regexp.MustCompile(`<\s*(true|false)\s*>`)
var lidChanged = regexp.MustCompile(`['"]LidIsClosed['"]:\s*<\s*(true|false)\s*>`)

func (b *Backend) lid(ctx context.Context, args []string) error {
	if len(args) != 1 {
		return errors.New("invalid lid arguments")
	}
	base := []string{"--system", "--dest", "org.freedesktop.UPower", "--object-path", "/org/freedesktop/UPower"}
	switch args[0] {
	case "get":
		command := append([]string{"call"}, base...)
		command = append(command, "--method", "org.freedesktop.DBus.Properties.Get", "org.freedesktop.UPower", "LidIsClosed")
		data, err := b.output(ctx, nil, "gdbus", command...)
		if err != nil {
			return err
		}
		match := lidValue.FindSubmatch(data)
		if match == nil {
			return errors.New("invalid lid state")
		}
		return b.json(map[string]bool{"closed": string(match[1]) == "true"})
	case "watch":
		cmd := b.command(ctx, "gdbus", append([]string{"monitor"}, base...)...)
		pipe, err := cmd.StdoutPipe()
		if err != nil {
			return err
		}
		if err = cmd.Start(); err != nil {
			return err
		}
		scanner := bufio.NewScanner(pipe)
		for scanner.Scan() {
			match := lidChanged.FindStringSubmatch(scanner.Text())
			if match != nil {
				if err = b.json(map[string]bool{"closed": match[1] == "true"}); err != nil {
					break
				}
			}
		}
		if err != nil || scanner.Err() != nil {
			_ = cmd.Cancel()
		}
		waitErr := cmd.Wait()
		if err != nil {
			return err
		}
		if scanner.Err() != nil {
			return scanner.Err()
		}
		return waitErr
	}
	return errors.New("invalid lid arguments")
}

func (b *Backend) audio(ctx context.Context, args []string) error {
	if len(args) == 1 && args[0] == "profiles" {
		data, err := b.output(ctx, nil, "pactl", "-f", "json", "list", "cards")
		if err != nil {
			return err
		}
		return writeAudioProfile(b.Out, data)
	}
	if len(args) == 3 && args[0] == "set-profile" {
		return b.run(ctx, nil, "pactl", "set-card-profile", args[1], args[2])
	}
	return errors.New("invalid audio arguments")
}

func writeAudioProfile(out io.Writer, data []byte) error {
	var cards []struct {
		Name     string          `json:"name"`
		Active   string          `json:"active_profile"`
		Profiles json.RawMessage `json:"profiles"`
	}
	if err := json.Unmarshal(data, &cards); err != nil {
		return err
	}
	result := map[string]string{"card": "", "active": "", "headphones": "", "speaker": ""}
	for _, card := range cards {
		if !strings.HasPrefix(card.Name, "alsa_card.") {
			continue
		}
		result["card"], result["active"] = card.Name, card.Active
		// Decoder preserves the profile order returned by pactl.
		decoder := json.NewDecoder(bytes.NewReader(card.Profiles))
		first, err := decoder.Token()
		if err != nil || first != json.Delim('{') {
			return errors.New("invalid audio profiles")
		}
		for decoder.More() {
			token, err := decoder.Token()
			if err != nil {
				return err
			}
			name := token.(string)
			var value json.RawMessage
			if err = decoder.Decode(&value); err != nil {
				return err
			}
			if strings.Contains(name, "Headphones") && result["headphones"] == "" {
				result["headphones"] = name
			}
			if strings.Contains(name, "Speaker") && result["speaker"] == "" {
				result["speaker"] = name
			}
		}
		break
	}
	return json.NewEncoder(out).Encode(result)
}
