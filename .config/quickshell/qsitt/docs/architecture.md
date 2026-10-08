# qsitt の構成

qsitt は、変更箇所を見つけやすくすることを優先する。抽象化は、実際に複数箇所で共有するときだけ追加する。

## ディレクトリ

```text
qsitt/
├── shell.qml       # 機能を並べるだけのエントリーポイント
├── Features/       # 画面に現れる機能
│   ├── Bar/
│   ├── ControlCenter/
│   ├── Lock/
│   ├── Notifications/
│   ├── PowerMenu/
│   ├── QrScanner/
│   └── Search/
├── Services/       # OS連携と共有状態。UIを持たない
├── Widgets/        # 機能に依存しない小さなUI部品
├── Config/         # モニターなどの動作設定
├── Theme/          # 色、フォント、アイコン
└── Scripts/        # QMLだけでは扱いにくいOS処理
```

依存方向は次の一方向にする。

```text
shell.qml -> Features -> Services
                     -> Widgets -> Theme
                     -> Config
                     -> Theme
```

## ルール

### Feature

- ユーザーから見て一つの機能を `Features/<Name>` に置く。
- その機能だけで使う部品は同じディレクトリか、その下の `Widgets/` に置く。
- 別Featureの内部部品を直接使わない。共有が必要になった時点で `Widgets/` へ移す。
- 将来の差し替えを想定したRegistryやLoaderは、実際に差し替え要件が生まれるまで作らない。

### UIとService

- UIは描画、入力、画面内だけの一時状態を担当する。
- ServiceはOS API、外部コマンド、複数画面で共有する状態を担当する。
- Serviceは `pragma Singleton` とし、表示要素を生成しない。
- UIからOS処理が必要な場合はServiceの関数を呼ぶ。

### Theme

`Theme/Theme.qml` はUIが参照する窓口で、`config.toml` の `[theme]` と `Theme/Palettes/<palette>.toml` を監視する。`palette` は現在の配色ファイル、`mode` はその中の `[light]` / `[dark]` を選ぶ。Control CenterやIPCからの変更は `config.toml` に書き戻す。利用可能なパレットは `Theme/Palettes/*.toml` から自動検出する。

UIでは色と通常フォントを直接記述せず、`Theme` の値を使う。アイコンだけは `Theme/Phosphor.ttf` を利用する。

### Config

`Config/SettingsData.qml` は `config.toml` の `[settings]` を監視し、画面、アニメーション速度、デバッグ設定を公開する。設定値はQMLへ直書きせず、TOMLを編集する。

## 機能を追加する

1. `Features/<Name>/<Name>.qml` を作る。
2. OS連携や共有状態が必要なら `Services/<Name>Service.qml` を作る。
3. 汎用化できる場合だけ部品を `Widgets/` に置く。
4. `shell.qml` でFeatureを生成する。

この4段階で収まらない場合も、まずFeature内に実装し、重複が確認できてから共通化する。
