#!/usr/bin/env bash
# הורדת וידאו עם yt-dlp אל media/downloads/
#   scripts/download.sh <url>            וידאו באיכות הטובה ביותר (MP4)
#   scripts/download.sh <url> --audio    אודיו בלבד (MP3)
#   scripts/download.sh <url> --subs     וידאו + כתוביות קיימות (עברית/אנגלית)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
for a in "$ROOT/.venv/bin/activate" "$ROOT/.venv/Scripts/activate"; do [ -f "$a" ] && . "$a" && break; done
OUT="$ROOT/media/downloads/%(title).80s [%(id)s].%(ext)s"

url="${1:?שימוש: download.sh <url> [--audio|--subs]}"
mode="${2:-}"

case "$mode" in
  --audio) yt-dlp -x --audio-format mp3 -o "$OUT" "$url" ;;
  --subs)  yt-dlp -f "bv*+ba/b" --merge-output-format mp4 --write-subs --write-auto-subs \
             --sub-langs "he,iw,en" --convert-subs srt -o "$OUT" "$url" ;;
  *)       yt-dlp -f "bv*+ba/b" --merge-output-format mp4 -o "$OUT" "$url" ;;
esac
