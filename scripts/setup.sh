#!/usr/bin/env bash
# התקנת כל כלי העריכה: FFmpeg, Node (Remotion + HyperFrames), Python (Whisper/ivrit.ai + yt-dlp)
# מריצים פעם אחת מתיקיית הפרויקט:  bash scripts/setup.sh
set -euo pipefail
cd "$(dirname "$0")/.."

echo "== FFmpeg =="
if ! command -v ffmpeg >/dev/null; then
  if command -v apt-get >/dev/null; then sudo apt-get update && sudo apt-get install -y ffmpeg fonts-dejavu-core
  elif command -v brew >/dev/null; then brew install ffmpeg
  elif command -v winget >/dev/null; then winget install --id Gyan.FFmpeg
  else echo "התקן FFmpeg ידנית: https://ffmpeg.org/download.html"; exit 1; fi
fi
ffmpeg -version | head -1

echo "== Node: Remotion + HyperFrames =="
command -v node >/dev/null || { echo "צריך Node.js 22 ומעלה: https://nodejs.org"; exit 1; }
npm install

echo "== Python: Whisper (faster-whisper) + ivrit.ai + yt-dlp =="
# ב-Windows הפקודה היא python וה-venv נמצא ב-.venv/Scripts
PY="${PYTHON:-$(command -v python3 >/dev/null && python3 -c '' 2>/dev/null && echo python3 || echo python)}"
[ -d .venv ] || "$PY" -m venv .venv
if [ -f .venv/Scripts/activate ]; then ACT=.venv/Scripts/activate; else ACT=.venv/bin/activate; fi
. "$ACT"
pip install -q -U pip
pip install -q -r requirements.txt
yt-dlp --version

echo "== מיומנויות (skills) של HyperFrames ל-Claude Code =="
npx --yes hyperframes skills >/dev/null 2>&1 && echo "הותקנו ב-~/.claude/skills" || echo "דילוג (אין רשת?)"

echo
echo "מוכן. הפעל את הסביבה עם:  source $ACT"
echo "המודל של ivrit.ai (~1.6GB) יורד אוטומטית בתמלול העברי הראשון."
