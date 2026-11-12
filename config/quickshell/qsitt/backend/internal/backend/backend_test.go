package backend

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"
)

func TestLinuxMetrics(t *testing.T) {
	cpu, err := cpuMetric("2.00 1.00 0.50 1/10 123", 8)
	if err != nil || cpu.Usage != .25 || cpu.Label != "2.00" {
		t.Fatalf("cpu: %+v, %v", cpu, err)
	}
	for _, bad := range []string{"", "broken", "NaN", "-1", "+Inf"} {
		if _, err := cpuMetric(bad, 4); err == nil {
			t.Errorf("accepted invalid load %q", bad)
		}
	}
	mem, err := memoryMetric("MemTotal: 1000 kB\nMemFree: 100 kB\nMemAvailable: 400 kB\nCached: 300 kB\n")
	if err != nil || mem.Usage != .6 || mem.Label != "60%" {
		t.Fatalf("memory: %+v, %v", mem, err)
	}
	for _, bad := range []string{"", "MemTotal: 0\nMemAvailable: 0", "MemTotal: 100", "MemTotal: 100\nMemAvailable: 200"} {
		if _, err := memoryMetric(bad); err == nil {
			t.Errorf("accepted invalid meminfo %q", bad)
		}
	}
}

func TestBacklightParsing(t *testing.T) {
	value, err := parseBacklight("intel_backlight,backlight,25,25%,100\n")
	if err != nil || value.Current != 25 || value.Maximum != 100 || value.Brightness != .25 {
		t.Fatalf("%+v, %v", value, err)
	}
	for _, bad := range []string{"", "kbd,leds,1,0%,0", "kbd,leds,-1,0%,2", "kbd,leds,3,0%,2"} {
		if _, err := parseBacklight(bad); err == nil {
			t.Errorf("accepted %q", bad)
		}
	}
}

func TestStateRoundTripAndValidation(t *testing.T) {
	t.Setenv("XDG_CONFIG_HOME", t.TempDir())
	t.Setenv("XDG_STATE_HOME", t.TempDir())
	var out bytes.Buffer
	b := Backend{Out: &out, Err: io.Discard}
	for _, test := range []struct{ kind, value string }{{"settings", `{"lidClamshellMode":true}`}, {"theme", "qsitt"}, {"mode", "dark"}} {
		if err := b.state([]string{"load", test.kind}); err != nil || out.Len() != 0 {
			t.Fatalf("missing state: %v", err)
		}
		if err := b.state([]string{"save", test.kind, test.value}); err != nil {
			t.Fatal(err)
		}
		if err := b.state([]string{"load", test.kind}); err != nil {
			t.Fatal(err)
		}
		if out.String() != test.value+"\n" {
			t.Fatalf("round trip: %q", out.String())
		}
		out.Reset()
		path, _ := statePath(test.kind)
		info, err := os.Stat(path)
		if err != nil || info.Mode().Perm() != 0600 {
			t.Fatalf("state permissions: %v, %v", info, err)
		}
	}
	for _, args := range [][]string{{"save", "mode", "invalid"}, {"save", "theme", "../evil"}, {"save", "settings", "null"}, {"save", "settings", "[]"}, {"load", "../evil"}} {
		if err := b.state(args); err == nil {
			t.Errorf("accepted %v", args)
		}
	}
	if err := b.state([]string{"load", "mode"}); err != nil || out.String() != "dark\n" {
		t.Fatal("invalid save changed existing state")
	}
}

func TestAudioProfiles(t *testing.T) {
	var out bytes.Buffer
	err := writeAudioProfile(&out, []byte(`[{"name":"alsa_card.test","active_profile":"HiFi (Speaker)","profiles":{"HiFi (Headphones)":{},"HiFi (Speaker)":{}}}]`))
	if err != nil {
		t.Fatal(err)
	}
	var result map[string]string
	if err = json.Unmarshal(out.Bytes(), &result); err != nil {
		t.Fatal(err)
	}
	if result["card"] != "alsa_card.test" || result["headphones"] != "HiFi (Headphones)" || result["speaker"] != "HiFi (Speaker)" {
		t.Fatalf("%v", result)
	}
}

// Execute the test binary as a fake niri to inspect actual argv across the OS boundary.
func TestCommandHelper(t *testing.T) {
	if os.Getenv("QSITT_TEST_HELPER") != "1" {
		return
	}
	file, err := os.OpenFile(os.Getenv("QSITT_TEST_LOG"), os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0600)
	if err != nil {
		os.Exit(2)
	}
	_ = json.NewEncoder(file).Encode(os.Args[3:])
	_ = file.Close()
	if strings.Contains(strings.Join(os.Args[3:], " "), "failed-monitor") {
		os.Exit(7)
	}
	os.Exit(0)
}

func fakeNiri(t *testing.T) string {
	t.Helper()
	dir := t.TempDir()
	log := filepath.Join(dir, "args.jsonl")
	executable, err := os.Executable()
	if err != nil {
		t.Fatal(err)
	}
	// A tiny launcher injects the test flags; backend arguments stay separate.
	launcher := "#!/bin/sh\nexec '" + strings.ReplaceAll(executable, "'", "'\\''") + "' -test.run=TestCommandHelper -- \"$@\"\n"
	if err := os.WriteFile(filepath.Join(dir, "niri"), []byte(launcher), 0700); err != nil {
		t.Fatal(err)
	}
	t.Setenv("PATH", dir)
	t.Setenv("QSITT_TEST_HELPER", "1")
	t.Setenv("QSITT_TEST_LOG", log)
	return log
}

func TestNiriFocusUsesSeparateArgumentsAndStopsOnFailure(t *testing.T) {
	log := fakeNiri(t)
	b := Backend{Out: io.Discard, Err: io.Discard}
	name := `DP-1"; touch /tmp/should-never-exist; echo "`
	if err := b.niri(context.Background(), []string{"focus", name, "2"}); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(log)
	if err != nil {
		t.Fatal(err)
	}
	lines := strings.Split(strings.TrimSpace(string(data)), "\n")
	var first, second []string
	_ = json.Unmarshal([]byte(lines[0]), &first)
	_ = json.Unmarshal([]byte(lines[1]), &second)
	if !reflect.DeepEqual(first, []string{"msg", "action", "focus-monitor", name}) || !reflect.DeepEqual(second, []string{"msg", "action", "focus-workspace", "2"}) {
		t.Fatalf("%v / %v", first, second)
	}
	err = b.niri(context.Background(), []string{"focus", "failed-monitor", "2"})
	if err == nil || ExitCode(err) != 7 {
		t.Fatalf("failure not preserved: %v", err)
	}
	data, _ = os.ReadFile(log)
	if len(strings.Split(strings.TrimSpace(string(data)), "\n")) != 3 {
		t.Fatal("focused workspace after failed monitor switch")
	}
}

func TestInvalidOperationsDoNotStartPrograms(t *testing.T) {
	t.Setenv("PATH", t.TempDir())
	b := Backend{Out: io.Discard, Err: io.Discard}
	for _, args := range [][]string{{"power", "invalid"}, {"niri", "focus", "DP-1", "0"}, {"niri", "output", "DP-1", "invalid"}, {"desktop-theme", "anything"}, {"clipboard", "watch", "unknown"}, {"tool", "qr", "1,2 0x100"}} {
		if err := b.Run(context.Background(), args); err == nil || strings.Contains(err.Error(), "executable file") {
			t.Errorf("invalid operation reached process execution: %v: %v", args, err)
		}
	}
}

func TestGoClipboardCommandsWithoutPython(t *testing.T) {
	dir := t.TempDir()
	t.Setenv("HOME", dir)
	t.Setenv("XDG_STATE_HOME", filepath.Join(dir, "state"))
	t.Setenv("XDG_CACHE_HOME", filepath.Join(dir, "cache"))
	t.Setenv("CLIPBOARD_STATE", "")
	t.Setenv("PATH", dir)
	var out bytes.Buffer
	b := Backend{Root: dir, In: strings.NewReader("Go の履歴"), Out: &out, Err: io.Discard}
	ctx := context.Background()
	if err := b.Run(ctx, []string{"clipboard", "add", "text"}); err != nil {
		t.Fatal(err)
	}
	if err := b.Run(ctx, []string{"search", "query", "Go", "clipboard"}); err != nil {
		t.Fatal(err)
	}
	var items []struct{ Kind, Title string }
	if err := json.Unmarshal(out.Bytes(), &items); err != nil || len(items) != 1 || items[0].Title != "Go の履歴" {
		t.Fatalf("search: %s %v", out.String(), err)
	}
	if err := b.Run(ctx, []string{"clipboard", "clear"}); err != nil {
		t.Fatal(err)
	}
	out.Reset()
	if err := b.Run(ctx, []string{"search", "query", "", "clipboard"}); err != nil || out.String() != "[]\n" {
		t.Fatalf("clear: %s %v", out.String(), err)
	}
}

func TestClipboardWatcherInvokesSelf(t *testing.T) {
	log := fakeNiri(t)
	dir := os.Getenv("PATH")
	launcher, err := os.ReadFile(filepath.Join(dir, "niri"))
	if err != nil {
		t.Fatal(err)
	}
	if err = os.WriteFile(filepath.Join(dir, "wl-paste"), launcher, 0700); err != nil {
		t.Fatal(err)
	}
	b := Backend{Out: io.Discard, Err: io.Discard}
	if err = b.Run(context.Background(), []string{"clipboard", "watch", "text/uri-list"}); err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(log)
	if err != nil {
		t.Fatal(err)
	}
	var args []string
	if err = json.Unmarshal(data, &args); err != nil {
		t.Fatal(err)
	}
	executable, _ := os.Executable()
	want := []string{"--type", "text/uri-list", "--watch", executable, "clipboard", "add", "files"}
	if !reflect.DeepEqual(args, want) {
		t.Fatalf("watcher args: %v, want %v", args, want)
	}
}
