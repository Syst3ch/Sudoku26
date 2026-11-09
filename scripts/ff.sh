#!/usr/bin/env bash
# פעולות עריכה נפוצות עם FFmpeg. כל פקודה כותבת קובץ חדש ולא נוגעת במקור.
#
#   scripts/ff.sh info     <in>                          מידע על הקובץ (אורך, רזולוציה, קודקים)
#   scripts/ff.sh cut      <in> <start> <end> <out>      חיתוך מדויק (זמנים: 00:01:05.5 או 65.5)
#   scripts/ff.sh fastcut  <in> <start> <end> <out>      חיתוך מהיר בלי קידוד מחדש (חותך על keyframes)
#   scripts/ff.sh concat   <out> <in1> <in2> [...]       חיבור קטעים (מקודד מחדש, עובד גם בין קבצים שונים)
#   scripts/ff.sh audio    <in> <out.mp3|wav>            חילוץ אודיו
#   scripts/ff.sh mute     <in> <out>                    הסרת אודיו
#   scripts/ff.sh music    <video> <music> <out> [vol]   הוספת מוזיקת רקע (vol ברירת מחדל 0.15)
#   scripts/ff.sh subs     <in> <subs.srt> <out>         צריבת כתוביות לתוך הווידאו (תומך עברית)
#   scripts/ff.sh vertical <in> <out>                    המרה ל-9:16 (1080x1920) עם רקע מטושטש
#   scripts/ff.sh resize   <in> <height> <out>           שינוי גודל (למשל 720)
#   scripts/ff.sh speed    <in> <factor> <out>           שינוי מהירות (2 = פי 2 מהר, 0.5 = הילוך איטי)
#   scripts/ff.sh gif      <in> <out.gif> [width]        GIF איכותי
#   scripts/ff.sh frame    <in> <time> <out.png>         צילום פריים בודד
#   scripts/ff.sh loudnorm <in> <out>                    נרמול עוצמת שמע ל-‎-14 LUFS (סטנדרט רשתות)
set -euo pipefail

ENC=(-c:v libx264 -preset medium -crf 20 -pix_fmt yuv420p -c:a aac -b:a 192k -movflags +faststart)
cmd="${1:-help}"; shift || true

case "$cmd" in
  info)
    ffprobe -v error -show_entries format=duration,size,bit_rate:stream=codec_type,codec_name,width,height,r_frame_rate,sample_rate \
      -of default=noprint_wrappers=1 "$1" ;;
  cut)
    ffmpeg -y -ss "$2" -to "$3" -i "$1" "${ENC[@]}" "$4" ;;
  fastcut)
    ffmpeg -y -ss "$2" -to "$3" -i "$1" -c copy -avoid_negative_ts make_zero "$4" ;;
  concat)
    out="$1"; shift
    inputs=(); filter=""; i=0
    for f in "$@"; do
      inputs+=(-i "$f")
      filter+="[$i:v]scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=30[v$i];"
      filter+="[$i:a]aresample=48000[a$i];"
      i=$((i+1))
    done
    for ((j=0; j<i; j++)); do filter+="[v$j][a$j]"; done
    filter+="concat=n=$i:v=1:a=1[v][a]"
    ffmpeg -y "${inputs[@]}" -filter_complex "$filter" -map "[v]" -map "[a]" "${ENC[@]}" "$out" ;;
  audio)
    ffmpeg -y -i "$1" -vn "$2" ;;
  mute)
    ffmpeg -y -i "$1" -c:v copy -an "$2" ;;
  music)
    vol="${4:-0.15}"
    ffmpeg -y -i "$1" -stream_loop -1 -i "$2" -filter_complex \
      "[1:a]volume=$vol[m];[0:a][m]amix=inputs=2:duration=first:dropout_transition=2[a]" \
      -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -shortest "$3" ;;
  subs)
    # Alignment=2 = תחתית מרכז. FontName דורש פונט עם תמיכה בעברית (DejaVu Sans / Noto Sans Hebrew / Arial)
    subs="$(printf '%s' "$2" | sed "s/'/\\\\'/g; s/:/\\\\:/g")"
    ffmpeg -y -i "$1" -vf "subtitles='$subs':force_style='FontName=DejaVu Sans,FontSize=22,Outline=2,Shadow=0,MarginV=40,Alignment=2'" \
      "${ENC[@]}" "$3" ;;
  vertical)
    ffmpeg -y -i "$1" -filter_complex \
      "[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=30:5[bg];[0:v]scale=1080:-2[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2" \
      "${ENC[@]}" "$2" ;;
  resize)
    ffmpeg -y -i "$1" -vf "scale=-2:$2" "${ENC[@]}" "$3" ;;
  speed)
    f="$2"
    ffmpeg -y -i "$1" -filter_complex "[0:v]setpts=PTS/$f[v];[0:a]atempo=$f[a]" -map "[v]" -map "[a]" "${ENC[@]}" "$3" ;;
  gif)
    w="${3:-640}"
    ffmpeg -y -i "$1" -vf "fps=15,scale=$w:-1:flags=lanczos,split[a][b];[a]palettegen[p];[b][p]paletteuse" "$2" ;;
  frame)
    ffmpeg -y -ss "$2" -i "$1" -frames:v 1 "$3" ;;
  loudnorm)
    ffmpeg -y -i "$1" -c:v copy -af loudnorm=I=-14:TP=-1.5:LRA=11 -c:a aac -b:a 192k "$2" ;;
  *)
    sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//' ;;
esac
