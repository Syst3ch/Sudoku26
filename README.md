# VideoEditor

עורך וידאו מבוסס קוד, עם תמיכה מלאה בעברית.

| כלי | תפקיד |
|---|---|
| [FFmpeg](https://ffmpeg.org) | חיתוך, חיבור, אודיו, כתוביות, המרות |
| [yt-dlp](https://github.com/yt-dlp/yt-dlp) | הורדת וידאו מהרשת |
| [Whisper](https://github.com/SYSTRAN/faster-whisper) + [ivrit.ai](https://huggingface.co/ivrit-ai) | תמלול מדויק בעברית, עם חותמת זמן לכל מילה |
| [Remotion](https://remotion.dev) | וידאו מקוד React (כתוביות מונפשות, תבניות) |
| [HyperFrames](https://hyperframes.heygen.com) | וידאו מ-HTML ו-GSAP (מושן-גרפיקס, אינטרו) |

## התקנה

```bash
bash scripts/setup.sh
source .venv/bin/activate
```

## התחלה מהירה

```bash
scripts/download.sh "<url>"                                   # הורדה
scripts/ff.sh cut media/downloads/x.mp4 10 40 media/input/clip.mp4
python scripts/transcribe.py media/input/clip.mp4             # תמלול עברית
scripts/ff.sh subs media/input/clip.mp4 media/transcripts/clip.srt media/output/clip_subs.mp4
```

## מבנה

```
media/        input, downloads, transcripts, assets, output (לא נכנסים ל-git)
scripts/      setup.sh, download.sh, ff.sh, transcribe.py
remotion/     קומפוזיציות Remotion
hyperframes/  פרויקט HyperFrames
docs/         editing-guide.md: מדריך עריכה מלא
```

המדריך המלא נמצא ב-[docs/editing-guide.md](docs/editing-guide.md).
