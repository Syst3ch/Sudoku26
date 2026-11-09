# VideoEditor: הנחיות ל-Claude

הפרויקט הוא סביבת עריכת וידאו שמבוססת על קוד. המשתמש מבקש בעברית משהו כמו "תחתוך", "תוסיף כתוביות" או "תעשה מזה רילס", ו-Claude מבצע את העריכה עם הכלים שכאן. מדריך העריכה המלא נמצא ב-`docs/editing-guide.md`. כדאי לקרוא אותו לפני עריכה ראשונה.

## הכלים ומתי להשתמש בכל אחד

| צורך | כלי | איך |
|---|---|---|
| הורדת וידאו מיוטיוב, אינסטגרם, טיקטוק וכו' | yt-dlp | `scripts/download.sh <url>` |
| חיתוך, חיבור, אודיו, שינוי גודל, מהירות, צריבת כתוביות | FFmpeg | `scripts/ff.sh <פקודה>` (`scripts/ff.sh help`) |
| תמלול עברית | Whisper + ivrit.ai | `python scripts/transcribe.py <file>` |
| תמלול בשפה אחרת | Whisper | `python scripts/transcribe.py <file> --lang en` |
| כתוביות מונפשות מילה-מילה, גרפיקה מבוססת React | Remotion | `remotion/src/`, `npm run studio`, `npx remotion render` |
| מושן-גרפיקס, כותרות, אינטרו, אוברליי (HTML + GSAP) | HyperFrames | `hyperframes/`, קודם הסקיל `/hyperframes` |

## מבנה התיקיות

```
media/input/        קבצי מקור מהמשתמש (לא נכנסים ל-git)
media/downloads/    הורדות של yt-dlp
media/transcripts/  srt / vtt / words.json מ-transcribe.py
media/assets/       מוזיקה, לוגו, תמונות
media/output/       תוצרים מוכנים
scripts/            setup.sh, download.sh, ff.sh, transcribe.py
remotion/src/       קומפוזיציות Remotion (Root.tsx רושם אותן)
hyperframes/        פרויקט HyperFrames (index.html + compositions/)
docs/               מדריכים
```

`media/` מוגדרת כ-publicDir של Remotion. ב-Remotion פונים לקבצים כך: `staticFile("input/clip.mp4")`.

## כללי עבודה

1. לא דורסים את המקור. כל פעולה כותבת קובץ חדש ל-`media/output/`, או קובץ ביניים עם שם תיאורי.
2. לפני עריכה מריצים `scripts/ff.sh info <file>` כדי לדעת אורך, רזולוציה ו-fps.
3. אחרי רינדור בודקים את התוצאה בעין. מוציאים פריים עם `scripts/ff.sh frame <out> <sec> /tmp/x.png`, קוראים את התמונה ומוודאים שהטקסט בעברית לא הפוך ולא חתוך.
4. עברית:
   - ב-Remotion ובחלון HTML משתמשים ב-`direction: rtl`.
   - פונטים: ב-HyperFrames משתמשים ב-Heebo המקומי (`hyperframes/assets/fonts`). ב-FFmpeg משתמשים ב-DejaVu Sans, Noto Sans Hebrew או Arial.
5. תמלול עברית: ברירת המחדל היא `ivrit-ai/whisper-large-v3-turbo-ct2`. המודל יורד מ-huggingface.co (כ-1.6GB) בהרצה הראשונה. במקרה של שגיאת רשת, צריך שהסשן ירוץ בסביבת הענן `VideoEditor`, שבה Hugging Face פתוח.
6. רינדור בענן (בלי דפדפן מותקן): ב-Remotion מוסיפים `--browser-executable=/opt/pw-browsers/chromium`. HyperFrames מוצא את Chromium לבד.
7. ב-HyperFrames אין CDN. GSAP נטען מ-`assets/gsap.min.js`, כי jsdelivr חסום בענן. אחרי כל שינוי מריצים `npx hyperframes check` בתוך `hyperframes/`. ההנחיות המלאות נמצאות ב-`hyperframes/CLAUDE.md`.

## תהליכי עבודה נפוצים (בקצרה)

- **סרטון לרילס עם כתוביות בעברית:**
  1. `download.sh` או קובץ שהמשתמש העלה.
  2. `ff.sh cut` לקטע הרצוי.
  3. `transcribe.py`.
  4. Remotion `CaptionedVideo` עם `--props` (וידאו, תמלול ו-`durationInSeconds`). אפשר במקום זה `ff.sh vertical` ואחריו `ff.sh subs`.
- **פודקאסט לקליפים:** קודם `transcribe.py`. אחר כך מאתרים ב-`words.json` את הרגעים החזקים ומריצים `ff.sh cut` על כל אחד מהם.
- **אינטרו או כותרת:** HyperFrames (`hyperframes/index.html`) או Remotion `TitleCard`. מחברים לווידאו עם `ff.sh concat`.

## התקנה

`bash scripts/setup.sh` מתקין FFmpeg, את חבילות npm, את ה-venv של Python (faster-whisper ו-yt-dlp) ואת הסקילים של HyperFrames ל-Claude Code. בסשן ענן חדש מריצים אותו פעם אחת, ואחרי זה `source .venv/bin/activate`.
