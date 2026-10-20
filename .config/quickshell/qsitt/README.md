## 準備

フォントのダウンロード
https://phosphoricons.com/
からDownload all

Fonts/Regular/Phosphor.ttfをassets/fonts/Phosphor.ttfとしてコピー

## 構成

- `modules/qsitt/`: 画面に現れる機能
- `modules/common/`: 共有 UI と表示用 Theme
- `services/`: OS連携と共有状態（UIを置かない）
- `config.toml`: 旧設定の初回読み込み用
- `config/`: 配布用の静的設定
- `assets/`: フォントなどの素材

詳しくは [docs/architecture.md](docs/architecture.md) を参照してください。

## パレット生成

`matugen` と `jq` をインストールしたうえで、画像を指定して実行します。

```sh
./scripts/generate-palette.sh ~/Pictures/wallpaper.png
```

画像名から `modules/common/theme/palettes/wallpaper.toml` が生成されます。名前を指定する場合は第2引数へ渡します。

```sh
./scripts/generate-palette.sh ~/Pictures/wallpaper.png my-palette
```

既存パレットを更新する場合は `--force` を付けます。生成後は Control Center または `theme` IPC から選択できます。

## 設定の保存先

通常の設定は既定値との差分だけを `${XDG_CONFIG_HOME:-~/.config}/qsitt/settings.json` に保存します。選択中のパレットと light/dark は `${XDG_STATE_HOME:-~/.local/state}/qsitt/theme` と `mode` に保存します。`config.toml` はこれらのファイルがまだない場合の初回読み込みに使い、Control Center と IPC は書き換えません。

## 蓋を閉じたときの画面

Control Center の Tools でクラムシェルモードを切り替えられます。オンにして有効な外部画面があるときは、蓋を閉じると内蔵画面だけをオフにし、有効な外部画面をすべて点灯して作業を続けられます。無効化中の外部画面は変更しません。クラムシェルモードがオフ、または有効な外部画面がないときは、画面をロックしてサスペンドします。外部画面が閉じたまま外れた場合もサスペンドします。蓋を開いて復帰するとロック画面が表示されます。設定は `settings.json` に保存されます。

蓋の状態に応じた動作を qsitt 側で選ぶため、systemd-logind の蓋操作を無効にする設定を一度インストールして再起動してください。

```sh
sudo install -Dm644 config/90-qsitt-lid.conf /etc/systemd/logind.conf.d/90-qsitt-lid.conf
sudo reboot
```

蓋の検出には UPower と `gdbus`、クラムシェル時の画面制御には Niri、サスペンドには `systemctl suspend` を使います。画面のオフは Niri の一時的な出力設定なので、作業領域の配置が一時的に変わることがあります。
