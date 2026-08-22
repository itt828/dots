## 準備

フォントのダウンロード
https://phosphoricons.com/
からDownload all

Fonts/Regular/Phosphor.ttfをCommon/Assetsにコピー

## ダッシュボードのQRコード読取ツール

範囲選択、画面取得、QRコード読取、クリップボードへのコピーに以下のコマンドを使用します。

- `slurp`
- `grim`
- `zbarimg`（多くのディストリビューションでは `zbar` パッケージに収録）
- `wl-copy`（`wl-clipboard` パッケージに収録）

カラーピッカーは上記の `slurp`、`grim`、`wl-copy` に加えてImageMagickの `magick` コマンドを使用します。タイマー終了通知には、利用可能な場合のみ `notify-send` を使用します。
