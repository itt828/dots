# qsitt AGS

## インストール

[`ackerman/nexus`](https://copr.fedorainfracloud.org/coprs/ackerman/nexus/)

```sh
sudo dnf install dnf5-plugins
sudo dnf copr enable ackerman/nexus
sudo dnf install \
  aylurs-gtk-shell \
  astal-io \
  astal-gtk4 \
  astal-libs
```
- `aylurs-gtk-shell`: `ags` コマンド、AGS の TypeScript ライブラリ、GNIM
- `astal-io`: Astal の CLI／入出力ライブラリ
- `astal-gtk4`: GTK4 用 Astal と `gtk4-layer-shell`
- `astal-libs`: `AstalTray`、`AstalNotifd` などの GI ライブラリ
