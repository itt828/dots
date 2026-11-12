1. Install mise, rust (for regreet)
2. Run mise bootstrap

```sh
mise bootstrap \
  -E fedora,refind,regreet \
  --from https://github.com/itt828/dots.git \
  --from-dir ~/dots \
  --config-dir config/mise
```
