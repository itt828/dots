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
