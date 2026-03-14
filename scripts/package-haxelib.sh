#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OUT_FILE="${1:-$ROOT_DIR/.haxelib.zip}"

python3 - <<'PY' "$ROOT_DIR" "$OUT_FILE"
import fnmatch
import os
import pathlib
import sys
import zipfile

root = pathlib.Path(sys.argv[1])
out_file = pathlib.Path(sys.argv[2])
ignore_file = root / ".haxelibignore"
patterns = []
if ignore_file.exists():
    for line in ignore_file.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            patterns.append(line.lstrip("/"))

def ignored(path_str: str) -> bool:
    normalized = path_str.replace("\\", "/")
    return any(fnmatch.fnmatch(normalized, pattern) for pattern in patterns)

with zipfile.ZipFile(out_file, "w", compression=zipfile.ZIP_DEFLATED) as zf:
    for path in root.rglob("*"):
        if path.is_dir():
            continue
        rel = path.relative_to(root).as_posix()
        if ignored(rel):
            continue
        zf.write(path, rel)

print(out_file)
PY
