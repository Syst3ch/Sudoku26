#!/usr/bin/env python3
"""תמלול וידאו/אודיו עם Whisper (faster-whisper) — כולל מודל עברית של ivrit.ai.

יוצר שלושה קבצים ב-media/transcripts/:
  <name>.srt        כתוביות רגילות
  <name>.vtt        כתוביות לווב
  <name>.words.json חותמות זמן לכל מילה (בשביל Remotion / HyperFrames)

דוגמאות:
  python scripts/transcribe.py media/input/clip.mp4                 # עברית, ivrit.ai (ברירת מחדל)
  python scripts/transcribe.py media/input/clip.mp4 --lang en       # אנגלית, Whisper רגיל
  python scripts/transcribe.py clip.mp4 --model large-v3 --lang he  # Whisper רגיל בעברית
"""

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "media" / "transcripts"

# מודל העברית של ivrit.ai בפורמט CTranslate2 (מתאים ל-faster-whisper)
IVRIT_MODEL = "ivrit-ai/whisper-large-v3-turbo-ct2"
DEFAULT_EN_MODEL = "large-v3-turbo"


def ts(seconds: float, sep: str) -> str:
    ms = int(round(seconds * 1000))
    h, ms = divmod(ms, 3_600_000)
    m, ms = divmod(ms, 60_000)
    s, ms = divmod(ms, 1000)
    return f"{h:02}:{m:02}:{s:02}{sep}{ms:03}"


def main() -> None:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("input", help="קובץ וידאו או אודיו")
    p.add_argument("--lang", default="he", help="קוד שפה (he, en, ...). ברירת מחדל: he")
    p.add_argument("--model", help=f"שם מודל. ברירת מחדל: {IVRIT_MODEL} לעברית, {DEFAULT_EN_MODEL} לשאר")
    p.add_argument("--device", default="auto", help="cpu / cuda / auto")
    p.add_argument("--compute-type", default="auto", help="int8 (מהיר ב-CPU), float16 (GPU), auto")
    p.add_argument("--out", type=Path, default=OUT_DIR, help="תיקיית פלט")
    args = p.parse_args()

    from faster_whisper import WhisperModel  # import מאוחר כדי ש---help יעבוד גם בלי ההתקנה

    model_name = args.model or (IVRIT_MODEL if args.lang == "he" else DEFAULT_EN_MODEL)
    print(f"טוען מודל: {model_name}")
    model = WhisperModel(model_name, device=args.device, compute_type=args.compute_type)

    segments, info = model.transcribe(
        args.input, language=args.lang, word_timestamps=True, vad_filter=True
    )
    print(f"שפה: {info.language}  אורך: {info.duration:.1f}s")

    args.out.mkdir(parents=True, exist_ok=True)
    stem = Path(args.input).stem
    srt, vtt, words, segs = [], ["WEBVTT", ""], [], []
    for i, seg in enumerate(segments, 1):
        text = seg.text.strip()
        print(f"[{seg.start:7.2f} → {seg.end:7.2f}] {text}")
        srt += [str(i), f"{ts(seg.start, ',')} --> {ts(seg.end, ',')}", text, ""]
        vtt += [f"{ts(seg.start, '.')} --> {ts(seg.end, '.')}", text, ""]
        segs.append({"start": seg.start, "end": seg.end, "text": text})
        for w in seg.words or []:
            words.append({"text": w.word.strip(), "start": round(w.start, 3), "end": round(w.end, 3)})

    (args.out / f"{stem}.srt").write_text("\n".join(srt), encoding="utf-8")
    (args.out / f"{stem}.vtt").write_text("\n".join(vtt), encoding="utf-8")
    (args.out / f"{stem}.words.json").write_text(
        json.dumps({"language": info.language, "duration": info.duration, "segments": segs, "words": words},
                   ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(f"נשמר ב-{args.out}/{stem}.(srt|vtt|words.json)")


if __name__ == "__main__":
    main()
