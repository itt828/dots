package search

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"

	"github.com/pelletier/go-toml/v2"
)

var tools = []Result{
	{Kind: "tool", Value: "control-center", Title: "Control Center", Subtitle: "音量・ネットワーク・設定"},
	{Kind: "tool", Value: "notifications", Title: "通知", Subtitle: "通知履歴を開く"},
	{Kind: "tool", Value: "screenshot", Title: "スクリーンショット", Subtitle: "範囲を選んで撮影"},
	{Kind: "tool", Value: "lens", Title: "Google Lens", Subtitle: "画面の範囲を画像検索"},
	{Kind: "tool", Value: "qr", Title: "QRコードを読み取る", Subtitle: "画面の範囲を選択"},
	{Kind: "tool", Value: "color", Title: "色を取得", Subtitle: "画面から色をコピー"},
	{Kind: "tool", Value: "lock", Title: "画面をロック", Subtitle: "セッションをロック"},
	{Kind: "tool", Value: "suspend", Title: "サスペンド", Subtitle: "ロックしてスリープ"},
}

func (s *Store) shortcuts() []Result {
	var config struct {
		Search struct {
			Shortcuts struct {
				Apps  []string `toml:"apps"`
				Tools []string `toml:"tools"`
			} `toml:"shortcuts"`
		} `toml:"search"`
	}
	data, err := os.ReadFile(filepath.Join(s.Root, "config", "config.toml"))
	if err != nil || toml.Unmarshal(data, &config) != nil {
		return []Result{}
	}
	apps := map[string]Result{}
	for _, app := range s.applications() {
		apps[app.DesktopID] = app
	}
	byID := map[string]Result{}
	for _, tool := range tools {
		byID[tool.Value] = tool
	}
	result := []Result{}
	for _, id := range config.Search.Shortcuts.Apps {
		if app, ok := apps[id]; ok {
			result = append(result, app)
		}
	}
	for _, id := range config.Search.Shortcuts.Tools {
		if tool, ok := byID[id]; ok {
			result = append(result, tool)
		}
	}
	return result
}

func rankResults(items []Result, query string, tool bool, limit int) []Result {
	type ranked struct {
		score float64
		item  Result
	}
	list := []ranked{}
	for _, item := range items {
		secondary := item.Subtitle
		if tool {
			secondary += " " + item.Value
		}
		if score, ok := rankedMatch(item.Title, secondary, query); ok {
			list = append(list, ranked{score, item})
		}
	}
	sort.SliceStable(list, func(i, j int) bool {
		a, b := list[i], list[j]
		if a.score != b.score {
			return a.score < b.score
		}
		if tool {
			return a.item.Title < b.item.Title
		}
		if len([]rune(a.item.Title)) != len([]rune(b.item.Title)) {
			return len([]rune(a.item.Title)) < len([]rune(b.item.Title))
		}
		return fold(a.item.Title) < fold(b.item.Title)
	})
	result := []Result{}
	for _, entry := range list[:min(limit, len(list))] {
		result = append(result, entry.item)
	}
	return result
}

func (s *Store) Query(ctx context.Context, query, category string) ([]Result, error) {
	switch category {
	case "all", "apps", "web", "files", "tools", "clipboard":
	default:
		return nil, fmt.Errorf("unknown search category: %s", category)
	}
	query = strings.TrimSpace(query)
	if query == "" && category == "all" {
		return s.shortcuts(), nil
	}
	result := []Result{}
	limit := 35
	if category == "all" {
		limit = 8
	}
	if category == "all" || category == "apps" {
		result = append(result, rankResults(s.applications(), query, false, limit)...)
	}
	if category == "all" || category == "web" {
		if query != "" {
			result = append(result, Result{Kind: "web", Title: "Google で検索: " + query, Subtitle: "ブラウザで検索", Value: query})
		}
		result = append(result, Result{Kind: "lens", Title: "Google Lens", Subtitle: "画面の範囲を選んで検索", Value: "lens"})
	}
	if category == "all" || category == "files" {
		files, err := s.fileResults(ctx, query, limit)
		if err != nil && category == "files" {
			return nil, err
		}
		result = append(result, files...)
	}
	if category == "all" || category == "tools" {
		result = append(result, rankResults(tools, query, true, limit)...)
	}
	if category == "all" || category == "clipboard" {
		clipLimit := 35
		if category == "all" {
			clipLimit = 5
		}
		clips, err := s.clipboardResults(ctx, query, clipLimit)
		if err != nil && category == "clipboard" {
			return nil, err
		}
		result = append(result, clips...)
	}
	return result, nil
}
