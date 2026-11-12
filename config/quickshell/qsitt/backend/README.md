| コマンド | 出力・処理 |
| --- | --- |
| `niri event-stream` | niri のイベントを JSON Lines で転送 |
| `niri workspaces` / `windows` / `focused-window` / `focused-output` | niri の JSON を転送 |
| `niri focus <output> <index>` | モニター選択が成功した後にワークスペースを選択 |
| `niri output <output> on\|off` | 出力の一時的な有効・無効化 |
| `niri power-on-monitors` / `screenshot` | niri action |
| `metrics cpu\|memory` | `{usage, label}`。CPU は1分平均負荷を論理 CPU 数で正規化 |
| `backlight get display\|keyboard` | `{current, maximum, brightness}` |
| `backlight watch` | udev の変更通知を転送 |
| `backlight keyboard-set <level>` | ThinkPad のキーボードバックライト設定 |
| `lid get` / `watch` | `{closed}`、監視は JSON Lines |
| `power poweroff\|reboot\|suspend\|logout` | 電源・セッション操作 |
| `desktop-theme prefer-light\|prefer-dark` | GNOME color-scheme 同期 |
| `audio profiles` / `set-profile <card> <profile>` | プロファイル取得・切替 |
| `state load <kind>` / `save <kind> <value>` | `settings`・`theme`・`mode` の読み書き |
| `search index` / `query <query> <category>` | Go で SQLite 索引を更新・検索し、結果を JSON 配列で返す |
| `clipboard watch <mime>` / `add text\|image\|files` / `copy <id>` / `clear` | Go で履歴を監視・保存・再コピー・削除。`add` は stdin から読む |
| `open <url-or-file>` / `launch <desktop-file>` | 外部アプリを起動 |
| `tool qr <geometry>` / `lens <geometry>` / `color` / `timer-notify` | 画面ツール・通知 |
