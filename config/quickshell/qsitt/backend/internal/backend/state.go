package backend

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"regexp"
)

var paletteName = regexp.MustCompile(`^[a-z0-9][a-z0-9_-]*$`)

func statePath(kind string) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}
	var base string
	switch kind {
	case "settings":
		base = os.Getenv("XDG_CONFIG_HOME")
		if base == "" {
			base = filepath.Join(home, ".config")
		}
		return filepath.Join(base, "qsitt", "settings.json"), nil
	case "theme", "mode":
		base = os.Getenv("XDG_STATE_HOME")
		if base == "" {
			base = filepath.Join(home, ".local", "state")
		}
		return filepath.Join(base, "qsitt", kind), nil
	}
	return "", errors.New("unknown state kind")
}

func atomicWrite(path string, value []byte) error {
	dir := filepath.Dir(path)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	tmp, err := os.CreateTemp(dir, ".qsitt-*")
	if err != nil {
		return err
	}
	defer os.Remove(tmp.Name())
	_, writeErr := tmp.Write(value)
	if writeErr == nil {
		writeErr = tmp.Sync()
	}
	closeErr := tmp.Close()
	if writeErr != nil {
		return writeErr
	}
	if closeErr != nil {
		return closeErr
	}
	return os.Rename(tmp.Name(), path)
}

func (b *Backend) state(args []string) error {
	if len(args) < 2 {
		return errors.New("usage: state load|save settings|theme|mode [value]")
	}
	path, err := statePath(args[1])
	if err != nil {
		return err
	}
	if args[0] == "load" && len(args) == 2 {
		data, err := os.ReadFile(path)
		if os.IsNotExist(err) {
			return nil
		}
		if err != nil {
			return err
		}
		_, err = b.Out.Write(data)
		return err
	}
	if args[0] == "save" && len(args) == 3 {
		value := args[2]
		switch args[1] {
		case "settings":
			var object map[string]json.RawMessage
			if json.Unmarshal([]byte(value), &object) != nil || object == nil {
				return errors.New("settings must be a JSON object")
			}
		case "theme":
			if !paletteName.MatchString(value) {
				return errors.New("invalid palette name")
			}
		case "mode":
			if value != "light" && value != "dark" {
				return errors.New("invalid theme mode")
			}
		}
		return atomicWrite(path, []byte(value+"\n"))
	}
	return errors.New("invalid state arguments")
}
