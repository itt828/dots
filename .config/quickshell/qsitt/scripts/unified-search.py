#!/usr/bin/env python3
"""Local search backend for qsitt. Prints one JSON result list per query."""

import argparse
import configparser
from io import BytesIO
import hashlib
import json
import mimetypes
import os
from pathlib import Path
import shutil
import sqlite3
import subprocess
import sys
import time
from urllib.parse import unquote, urlsplit


HOME = Path.home()
STATE = Path(os.environ.get("XDG_STATE_HOME", HOME / ".local/state")) / "qsitt"
CACHE = Path(os.environ.get("XDG_CACHE_HOME", HOME / ".cache")) / "qsitt"
CLIP_DB = STATE / "clipboard.sqlite3"
FILE_DB = CACHE / "files.sqlite3"
MEDIA_DIR = STATE / "clipboard-media"
MAX_IMAGE_BYTES = 8 * 1024 * 1024
IMAGE_FORMATS = {"PNG": ("image/png", "png"), "JPEG": ("image/jpeg", "jpg"), "WEBP": ("image/webp", "webp"), "GIF": ("image/gif", "gif"), "BMP": ("image/bmp", "bmp")}
PREFERRED_ROOTS = [HOME / name for name in ("Desktop", "Documents", "Downloads", "Pictures", "Music", "Videos", "dev", "Projects")]
SEARCH_ROOTS = list(dict.fromkeys(PREFERRED_ROOTS + [p for p in HOME.iterdir() if p.is_dir() and not p.name.startswith(".")]))
SKIP_DIRS = {".git", "node_modules", "target", "build", "dist", ".venv", "venv", "__pycache__"}
MAX_FILES = 150_000

TOOLS = [
    ("control-center", "Control Center", "音量・ネットワーク・設定"),
    ("notifications", "通知", "通知履歴を開く"),
    ("screenshot", "スクリーンショット", "範囲を選んで撮影"),
    ("lens", "Google Lens", "画面の範囲を画像検索"),
    ("qr", "QRコードを読み取る", "画面の範囲を選択"),
    ("color", "色を取得", "画面から色をコピー"),
    ("lock", "画面をロック", "セッションをロック"),
    ("suspend", "サスペンド", "ロックしてスリープ"),
]


def connect(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    db = sqlite3.connect(path, timeout=3)
    db.execute("PRAGMA busy_timeout=3000")
    return db


def clipboard_db():
    db = connect(CLIP_DB)
    db.execute("CREATE TABLE IF NOT EXISTS clips (id INTEGER PRIMARY KEY, text TEXT NOT NULL UNIQUE, copied_at INTEGER NOT NULL)")
    db.execute("CREATE TABLE IF NOT EXISTS media (id INTEGER PRIMARY KEY, digest TEXT NOT NULL UNIQUE, kind TEXT NOT NULL, mime TEXT NOT NULL, source TEXT NOT NULL, preview TEXT NOT NULL, title TEXT NOT NULL, copied_at INTEGER NOT NULL)")
    return db


def add_clipboard():
    if os.environ.get("CLIPBOARD_STATE") in ("nil", "clear", "sensitive"):
        return
    raw = sys.stdin.buffer.read(65537)
    if len(raw) > 65536:
        return
    value = raw.decode("utf-8", "replace").strip()
    if not value or "\x00" in value:
        return
    with clipboard_db() as db:
        db.execute("DELETE FROM clips WHERE text = ?", (value,))
        db.execute("INSERT INTO clips (text, copied_at) VALUES (?, ?)", (value, int(time.time())))
        db.execute("DELETE FROM clips WHERE id NOT IN (SELECT id FROM clips ORDER BY copied_at DESC, id DESC LIMIT 100)")


def delete_owned_media(paths):
    for path in paths:
        candidate = Path(path)
        if candidate.parent == MEDIA_DIR:
            candidate.unlink(missing_ok=True)


def save_media(digest, kind, mime, source, preview, title):
    with clipboard_db() as db:
        old = db.execute("SELECT source, preview FROM media WHERE digest = ?", (digest,)).fetchone()
        db.execute("DELETE FROM media WHERE digest = ?", (digest,))
        db.execute("INSERT INTO media (digest, kind, mime, source, preview, title, copied_at) VALUES (?, ?, ?, ?, ?, ?, ?)",
                   (digest, kind, mime, source, preview, title, int(time.time())))
        expired = db.execute("SELECT source, preview FROM media ORDER BY copied_at DESC, id DESC LIMIT -1 OFFSET 30").fetchall()
        db.execute("DELETE FROM media WHERE id NOT IN (SELECT id FROM media ORDER BY copied_at DESC, id DESC LIMIT 30)")
        active = {path for row in db.execute("SELECT source, preview FROM media") for path in row}
    obsolete = [path for row in expired for path in row if path not in active]
    if old:
        obsolete += [path for path in old if path not in active]
    delete_owned_media(obsolete)


def add_clipboard_image():
    if os.environ.get("CLIPBOARD_STATE") in ("nil", "clear", "sensitive"):
        return
    raw = sys.stdin.buffer.read(MAX_IMAGE_BYTES + 1)
    if not raw or len(raw) > MAX_IMAGE_BYTES:
        return
    try:
        from PIL import Image, ImageOps, UnidentifiedImageError
        with Image.open(BytesIO(raw)) as image:
            if image.format not in IMAGE_FORMATS or image.width * image.height > 50_000_000:
                return
            mime, extension = IMAGE_FORMATS[image.format]
            size = (image.width, image.height)
            thumb = ImageOps.exif_transpose(image)
            thumb.thumbnail((320, 240))
            if thumb.mode not in ("RGB", "RGBA"):
                thumb = thumb.convert("RGBA")
            digest = hashlib.sha256(raw).hexdigest()
            MEDIA_DIR.mkdir(parents=True, exist_ok=True)
            source = MEDIA_DIR / (digest + "." + extension)
            preview = MEDIA_DIR / (digest + "-preview.png")
            source.write_bytes(raw)
            thumb.save(preview, format="PNG")
    except (OSError, ValueError, UnidentifiedImageError, Image.DecompressionBombError):
        return
    save_media(digest, "image", mime, str(source), str(preview), f"画像 / Image {size[0]}×{size[1]} • {extension.upper()}")


def add_clipboard_files():
    if os.environ.get("CLIPBOARD_STATE") in ("nil", "clear", "sensitive"):
        return
    raw = sys.stdin.buffer.read(65537)
    if len(raw) > 65536:
        return
    for line in raw.decode("utf-8", "replace").splitlines()[:10]:
        if line.startswith("#"):
            continue
        uri = urlsplit(line.strip())
        if uri.scheme != "file" or uri.netloc not in ("", "localhost"):
            continue
        path = Path(unquote(uri.path))
        if not path.is_file():
            continue
        mime = mimetypes.guess_type(path.name)[0] or ""
        if not mime.startswith(("image/", "video/", "audio/")):
            continue
        digest = hashlib.sha256(str(path).encode()).hexdigest()
        preview = str(path) if mime.startswith("image/") else ""
        if mime.startswith("video/") and shutil.which("ffmpeg"):
            MEDIA_DIR.mkdir(parents=True, exist_ok=True)
            thumbnail = MEDIA_DIR / (digest + "-video.png")
            if not thumbnail.exists():
                subprocess.run(["ffmpeg", "-v", "error", "-y", "-ss", "1", "-i", str(path), "-frames:v", "1", "-vf", "scale=320:-1", str(thumbnail)],
                               timeout=8, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=False)
            if thumbnail.exists():
                preview = str(thumbnail)
        title = ("画像" if mime.startswith("image/") else "動画" if mime.startswith("video/") else "音声") + " / " + path.name
        save_media(digest, "file", mime, str(path), preview, title)


def copy_clipboard(clip_id):
    if clip_id.startswith("image:") or clip_id.startswith("file:"):
        kind, _, row_id = clip_id.partition(":")
        with clipboard_db() as db:
            row = db.execute("SELECT kind, mime, source FROM media WHERE id = ?", (int(row_id),)).fetchone()
        if not row or row[0] != kind or not Path(row[2]).is_file():
            return
        if kind == "image":
            with Path(row[2]).open("rb") as source:
                subprocess.run(["wl-copy", "--type", row[1]], stdin=source, check=False)
        else:
            subprocess.run(["wl-copy", "--type", "text/uri-list"], input=Path(row[2]).as_uri() + "\r\n", text=True, check=False)
        return
    with clipboard_db() as db:
        row = db.execute("SELECT text FROM clips WHERE id = ?", (int(clip_id),)).fetchone()
    if row:
        subprocess.run(["wl-copy", "--type", "text/plain;charset=utf-8"], input=row[0], text=True, check=False)


def app_dirs():
    data_home = Path(os.environ.get("XDG_DATA_HOME", HOME / ".local/share"))
    dirs = [data_home / "applications"]
    dirs += [Path(p) / "applications" for p in os.environ.get("XDG_DATA_DIRS", "/usr/local/share:/usr/share").split(":") if p]
    return dirs


def applications():
    seen = set()
    apps = []
    for directory in app_dirs():
        if not directory.is_dir():
            continue
        for path in directory.rglob("*.desktop"):
            desktop_id = str(path.relative_to(directory)).replace("/", "-")
            if desktop_id in seen:
                continue
            seen.add(desktop_id)
            parser = configparser.ConfigParser(interpolation=None, strict=False)
            parser.optionxform = str
            try:
                parser.read(path, encoding="utf-8")
                entry = parser["Desktop Entry"]
                if entry.get("Type") != "Application" or entry.get("Hidden", "false").lower() == "true" or entry.get("NoDisplay", "false").lower() == "true":
                    continue
                check = entry.get("TryExec", "")
                if check and not (shutil.which(check) or Path(check).is_file()):
                    continue
                name = entry.get("Name[ja]", entry.get("Name", desktop_id))
                apps.append({"kind": "app", "title": name, "subtitle": entry.get("GenericName[ja]", entry.get("GenericName", "アプリを起動")), "value": str(path), "icon": entry.get("Icon", "")})
            except (OSError, configparser.Error, KeyError):
                continue
    return apps


def index_files():
    db = connect(FILE_DB)
    db.execute("CREATE TABLE IF NOT EXISTS files (path TEXT PRIMARY KEY, name TEXT NOT NULL, name_lower TEXT NOT NULL)")
    db.execute("CREATE INDEX IF NOT EXISTS files_name ON files(name_lower)")
    db.execute("CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)")
    batch = []
    count = 0
    for root in SEARCH_ROOTS:
        if not root.is_dir():
            continue
        for base, dirs, files in os.walk(root, followlinks=False):
            dirs[:] = [d for d in dirs if not d.startswith(".") and d not in SKIP_DIRS]
            for name in dirs + files:
                if name.startswith("."):
                    continue
                path = str(Path(base) / name)
                batch.append((path, name, name.casefold()))
                count += 1
                if count >= MAX_FILES:
                    break
            if count >= MAX_FILES:
                break
        if count >= MAX_FILES:
            break
    with db:
        db.execute("DELETE FROM files")
        db.executemany("INSERT OR IGNORE INTO files VALUES (?, ?, ?)", batch)
        db.execute("INSERT OR REPLACE INTO meta VALUES ('updated', ?)", (str(int(time.time())),))
    db.close()
    print(count)


def file_results(query, limit=12):
    if not query or not FILE_DB.exists():
        return []
    try:
        with connect(FILE_DB) as db:
            words = query.casefold().split()
            where = " AND ".join("(name_lower LIKE ? ESCAPE '\\' OR lower(path) LIKE ? ESCAPE '\\')" for _ in words)
            args = []
            for word in words:
                pattern = "%" + "%".join(char.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_") for char in word) + "%"
                args.extend([pattern] * 2)
            rows = db.execute("SELECT path, name FROM files WHERE " + where + " ORDER BY length(name), name LIMIT 10000", args).fetchall()
            ranked = []
            for path, name in rows:
                name_score = fuzzy_score(name, query)
                path_score = fuzzy_score(path, query)
                score = min(name_score if name_score is not None else float("inf"),
                            path_score + 50 if path_score is not None else float("inf"))
                if score != float("inf"):
                    ranked.append((score, len(name), name.casefold(), path, name))
            ranked.sort()
            return [{"kind": "file", "title": name, "subtitle": path, "value": path}
                    for _, _, _, path, name in ranked if Path(path).exists()][:limit]
    except sqlite3.Error:
        return []


def clipboard_results(query, limit=8):
    try:
        with clipboard_db() as db:
            text_rows = db.execute("SELECT id, text, copied_at FROM clips ORDER BY copied_at DESC, id DESC LIMIT 100").fetchall()
            media_rows = db.execute("SELECT id, kind, mime, source, preview, title, copied_at FROM media ORDER BY copied_at DESC, id DESC LIMIT 30").fetchall()
        ranked = []
        for clip_id, value, copied_at in text_rows:
            score = fuzzy_score(value[:2000], query)
            if score is not None:
                ranked.append((score, -copied_at, -clip_id, {"kind": "clipboard", "title": value.replace("\n", " ⏎ ")[:100], "subtitle": "クリップボードにコピー", "value": str(clip_id)}))
        for clip_id, kind, mime, source, preview, title, copied_at in media_rows:
            if not Path(source).is_file():
                continue
            keywords = "picture photo 画像" if mime.startswith("image/") else "video movie 動画" if mime.startswith("video/") else "audio music 音声" if mime.startswith("audio/") else "media"
            score = ranked_match(title, mime + " " + keywords, query)
            if score is not None:
                ranked.append((score, -copied_at, -clip_id, {"kind": "clipboard-" + kind, "title": title, "subtitle": "クリックで再コピー", "value": kind + ":" + str(clip_id), "preview": Path(preview).as_uri() if preview and Path(preview).is_file() else "", "mime": mime}))
        ranked.sort(key=lambda entry: entry[:3])
        return [item for _, _, _, item in ranked[:limit]]
    except sqlite3.Error:
        return []


def fuzzy_score(text, query):
    """Rank ordered-character matches. Lower scores are better."""
    words = query.casefold().split()
    if not words:
        return 0.0
    value = text.casefold()
    total = 0.0
    for word in words:
        if word == value:
            total -= 1000
            continue
        if value.startswith(word):
            total -= 500 - min(len(value), 200) * 0.1
            continue
        found = value.find(word)
        if found >= 0:
            total -= 200 - found * 2 - min(len(value), 200) * 0.1
            continue

        previous = [None] * len(value)
        for i, char in enumerate(value):
            if char == word[0]:
                boundary = i == 0 or not value[i - 1].isalnum() or (i < len(text) and text[i].isupper() and text[i - 1].islower())
                previous[i] = i * 1.5 - (6 if boundary else 0)
        for char in word[1:]:
            current = [None] * len(value)
            best_gap = float("inf")
            for i, candidate in enumerate(value):
                if i > 0 and previous[i - 1] is not None:
                    best_gap = min(best_gap, previous[i - 1] - 2 * (i - 1))
                if candidate != char or best_gap == float("inf"):
                    continue
                boundary = i == 0 or not value[i - 1].isalnum() or (i < len(text) and text[i].isupper() and text[i - 1].islower())
                score = best_gap + 2 * (i - 1) - (6 if boundary else 0)
                if i > 0 and previous[i - 1] is not None:
                    score = min(score, previous[i - 1] - 3 - (6 if boundary else 0))
                current[i] = score
            previous = current
        scores = [score for score in previous if score is not None]
        if not scores:
            return None
        total += min(scores) + min(len(value), 200) * 0.1
    return total


def ranked_match(primary, secondary, query, secondary_penalty=35):
    first = fuzzy_score(primary, query)
    second = fuzzy_score(secondary, query)
    combined = fuzzy_score(primary + " " + secondary, query)
    score = min(first if first is not None else float("inf"),
                second + secondary_penalty if second is not None else float("inf"),
                combined + secondary_penalty if combined is not None else float("inf"))
    return None if score == float("inf") else score


def query_results(query, category):
    query = query.strip()
    result = []
    if category in ("all", "apps"):
        apps = [(ranked_match(a["title"], a["subtitle"], query), a) for a in applications()]
        apps = [(score, a) for score, a in apps if score is not None]
        apps.sort(key=lambda pair: (pair[0], len(pair[1]["title"]), pair[1]["title"].casefold()))
        result += [a for _, a in apps[:8 if category == "all" else 35]]
    if category in ("all", "web"):
        if query:
            result.append({"kind": "web", "title": "Google で検索: " + query, "subtitle": "ブラウザで検索", "value": query})
        result.append({"kind": "lens", "title": "Google Lens", "subtitle": "画面の範囲を選んで検索", "value": "lens"})
    if category in ("all", "files"):
        result += file_results(query, 8 if category == "all" else 35)
    if category in ("all", "tools"):
        tools = [(ranked_match(title, description + " " + key, query), key, title, description) for key, title, description in TOOLS]
        tools.sort(key=lambda entry: (entry[0] if entry[0] is not None else float("inf"), entry[2]))
        result += [{"kind": "tool", "title": title, "subtitle": description, "value": key} for score, key, title, description in tools if score is not None][:8 if category == "all" else 35]
    if category in ("all", "clipboard"):
        result += clipboard_results(query, 5 if category == "all" else 35)
    return result


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="command", required=True)
    search = sub.add_parser("query")
    search.add_argument("query")
    search.add_argument("category", choices=("all", "apps", "web", "files", "tools", "clipboard"))
    sub.add_parser("index")
    sub.add_parser("clipboard-add")
    copy = sub.add_parser("clipboard-copy")
    copy.add_argument("id")
    sub.add_parser("clipboard-clear")
    sub.add_parser("clipboard-add-image")
    sub.add_parser("clipboard-add-files")
    args = parser.parse_args()
    if args.command == "query":
        print(json.dumps(query_results(args.query, args.category), ensure_ascii=False))
    elif args.command == "index":
        index_files()
    elif args.command == "clipboard-add":
        add_clipboard()
    elif args.command == "clipboard-add-image":
        add_clipboard_image()
    elif args.command == "clipboard-add-files":
        add_clipboard_files()
    elif args.command == "clipboard-copy":
        copy_clipboard(args.id)
    elif args.command == "clipboard-clear":
        with clipboard_db() as db:
            db.execute("DELETE FROM clips")
            old = db.execute("SELECT source, preview FROM media").fetchall()
            db.execute("DELETE FROM media")
        delete_owned_media(path for row in old for path in row)


if __name__ == "__main__":
    main()
