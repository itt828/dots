#! /usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = []
# ///

import os
from pathlib import Path

dots = [
    {
        "dir": Path("."),
        "targetPrefix": Path(os.environ["HOME"]),
        "paths": [
            ".zshenv",
            ".zshrc",
            ".bin",
        ],
    },
    {
        "dir": Path(".config"),
        "targetPrefix": Path(
            os.getenv("XDG_CONFIG_HOME") or (Path(os.environ["HOME"]) / ".config")
        ),
        "paths": [
            "ags",
            "fish",
            "fuzzel",
            "helix",
            "niri",
            "quickshell",
            "swaync",
            "starship.toml",
            "steel-lsp",
        ],
    },
]


def main() -> None:
    for dot in dots:
        for path in dot["paths"]:
            p: Path = dot["targetPrefix"] / path
            if p.exists():
                print(f"{p} exist and skipped.")
            else:
                from_path: Path = (dot["dir"] / path).absolute()
                p.absolute().symlink_to(from_path)
                print(f"{p} created.")


if __name__ == "__main__":
    main()
