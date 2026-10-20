# qsitt の構成

[SekaiPop](https://github.com/Blapples/SekaiPop) の `modules/sekai`（機能 UI）、`modules/common`（共有 UI と表示用 Theme）、`services`（状態と OS 連携）、`scripts`（外部処理）という境界を qsitt の規模に合わせて採用する。名前と保存形式まで同一にはしない。

```text
qsitt/
├── shell.qml                   # 起動とトップレベルの組み立て
├── modules/
│   ├── qsitt/                  # bar、controlcenter、lock、notifications など
│   │   └── controlcenter/
│   │       ├── ControlCenter.qml
│   │       ├── ControlCenterIpc.qml
│   │       ├── pages/          # タブ全体
│   │       └── widgets/        # Control Center 専用部品
│   └── common/
│       ├── theme/              # 表示用 Theme、Icons、配色ファイル
│       │   └── palettes/       # light / dark を持つ TOML
│       └── widgets/            # 機能に依存しない UI 部品
├── services/                   # LegacyConfig、SettingsService、ThemeService、OS 連携
├── scripts/                    # QML 外で実行する処理
├── assets/fonts/               # Phosphor フォント
├── config/                     # systemd-logind など配布用の静的設定
└── config.toml                 # 旧設定の初回読み込み用
```

ディレクトリ名は小文字、QML の型ファイル名は PascalCase に統一する。

## 依存と責務

- `shell.qml` は機能と IPC 入口を生成する。画面固有の処理は持たない。
- `modules/qsitt/<name>` は画面と入力を担当する。複数ページは `pages/`、機能専用部品は `widgets/` に置く。
- 他機能の内部部品を直接使わない。通知一覧のように共有する画面は所有する機能が公開する `NotificationHistory.qml` を利用する。
- `modules/common/widgets` は機能に依存しない UI 部品だけを置く。
- `services` は OS API、設定・配色の読込、永続化、複数画面で共有する状態を担当する。Service は表示要素を生成しない。
- `*Ipc.qml` は外部コマンドを Service の操作へ変換する。画面 QML は IPC を登録しない。
- `modules/common/theme/Theme.qml` は UI が参照する色・サイズ・フォントのトークンを公開し、選択中の配色を `ThemeService` から読む。

## 設定と配色

qsitt の通常設定は `SettingsService` の既定値との差分だけを `${XDG_CONFIG_HOME:-~/.config}/qsitt/settings.json` に保存する。選択中のパレットと light/dark は `${XDG_STATE_HOME:-~/.local/state}/qsitt/theme` と `mode` に保存する。`scripts/state/` の補助スクリプトが一時ファイルからの置換で書き込む。起動時にはこれらを復元し、ファイルがない項目だけ旧 `config.toml` から読み込む。`LegacyConfig` は旧ファイルの読み取り専用であり、UI 操作では更新しない。

配色ファイルは `modules/common/theme/palettes/*.toml` に置き、`[light]` と `[dark]` の色値を持つ。`ThemeService` が選択・監視し、`Theme.qml` が表示用プロパティへ変換する。

Control Center と `theme` IPC は `ThemeService` の関数を呼ぶ。`DesktopThemeService` は mode をデスクトップのカラースキームへ同期する。パレット生成スクリプトは `modules/common/theme/palettes/` に出力する。

SekaiPop では、組み込みテーマの色定義と選択状態は `services/ThemeService.qml`、パレット編集ツールの作業状態とお気に入りは別の `services/PaletteService.qml` が持つ。壁紙由来の配色は matugen、適用済みのカスタム配色は `ThemeService` が扱う。表示用トークンは `modules/common/Theme.qml` にある。一般設定は `SettingsService.qml` の既定値から変更された分だけを `${XDG_CONFIG_HOME}/sekaipop/settings.json` に保存し、テーマ選択・ダークモード・適用済みカスタムパレットなどは `${XDG_STATE_HOME}/sekaipop/` に分けて保存する。qsitt にはパレット編集ツールがないため、`PaletteService` に相当する作業状態は設けない。

## 機能の追加

1. `modules/qsitt/<name>/<Name>.qml` を作る。
2. 共有状態や OS 連携が必要なら `services/<Name>Service.qml` を作る。
3. IPC が必要なら機能側に `*Ipc.qml` を置き、Service を呼ぶ。
4. 共通化が必要になった部品だけを `modules/common/widgets/` に移す。
5. `shell.qml` でトップレベルの型を生成する。
