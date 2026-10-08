## 準備

フォントのダウンロード
https://phosphoricons.com/
からDownload all

Fonts/Regular/Phosphor.ttfをTheme/Phosphor.ttfとしてコピー

## 構成

- `Features/`: 画面に現れる機能
- `Services/`: OS連携と共有状態（UIを置かない）
- `Widgets/`: 機能に依存しないUI部品
- `Config/`: モニターなどの動作設定
- `Theme/DefaultTheme.qml`: 色と通常フォント

詳しくは [docs/architecture.md](docs/architecture.md) を参照してください。

## パレット生成

`matugen` と `jq` をインストールしたうえで、画像を指定して実行します。

```sh
./Scripts/generate-palette.sh ~/Pictures/wallpaper.png
```

画像名から `Theme/Palettes/wallpaper.toml` が生成されます。名前を指定する場合は第2引数へ渡します。

```sh
./Scripts/generate-palette.sh ~/Pictures/wallpaper.png my-palette
```

既存パレットを更新する場合は `--force` を付けます。生成後はControl Centerまたは `config.toml` の `theme.palette` から選択できます。
