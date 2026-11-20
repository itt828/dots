package search

import (
	"bufio"
	"io/fs"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func (s *Store) applications() []Result {
	home := os.Getenv("XDG_DATA_HOME")
	if home == "" {
		home = filepath.Join(s.Home, ".local", "share")
	}
	dirs := []string{filepath.Join(home, "applications")}
	dataDirs, exists := os.LookupEnv("XDG_DATA_DIRS")
	if !exists {
		dataDirs = "/usr/local/share:/usr/share"
	}
	for _, dir := range filepath.SplitList(dataDirs) {
		if dir != "" {
			dirs = append(dirs, filepath.Join(dir, "applications"))
		}
	}
	seen := map[string]bool{}
	apps := []Result{}
	for _, dir := range dirs {
		_ = filepath.WalkDir(dir, func(path string, entry fs.DirEntry, err error) error {
			if err != nil || entry.IsDir() || !strings.HasSuffix(path, ".desktop") {
				return nil
			}
			relative, err := filepath.Rel(dir, path)
			if err != nil {
				return nil
			}
			id := strings.ReplaceAll(relative, string(filepath.Separator), "-")
			if seen[id] {
				return nil
			}
			seen[id] = true
			values, err := desktopEntry(path)
			if err != nil || values["Type"] != "Application" || strings.EqualFold(values["Hidden"], "true") || strings.EqualFold(values["NoDisplay"], "true") {
				return nil
			}
			if check := values["TryExec"]; check != "" {
				if _, err := exec.LookPath(check); err != nil && !isFile(check) {
					return nil
				}
			}
			name := values["Name[ja]"]
			if name == "" {
				name = values["Name"]
			}
			if name == "" {
				name = id
			}
			description := values["GenericName[ja]"]
			if description == "" {
				description = values["GenericName"]
			}
			if description == "" {
				description = "アプリを起動"
			}
			apps = append(apps, Result{Kind: "app", DesktopID: id, Title: name, Subtitle: description, Value: path, Icon: values["Icon"]})
			return nil
		})
	}
	return apps
}

func desktopEntry(path string) (map[string]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	values := map[string]string{}
	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 4096), 1024*1024)
	active := false
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if strings.HasPrefix(line, "[") {
			active = line == "[Desktop Entry]"
			continue
		}
		if !active || strings.HasPrefix(line, "#") || strings.HasPrefix(line, ";") {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if ok {
			values[strings.TrimSpace(key)] = strings.TrimSpace(value)
		}
	}
	return values, scanner.Err()
}
