# מדריך עריכה

המדריך מסביר איך עורכים וידאו בפרויקט הזה, כלי אחרי כלי, עם דוגמאות שאפשר להעתיק.
כל הפקודות רצות מתיקיית הפרויקט, אחרי `source .venv/bin/activate`.

---

## 1. הבנת הבסיס

כמה מושגים שחוזרים בכל המדריך:

- **רזולוציה**: 1920x1080 היא 16:9 ליוטיוב. 1080x1920 היא 9:16 לרילס, טיקטוק ושורטס.
- **FPS**: כמה פריימים יש בכל שנייה. הערכים הנפוצים הם 30 או 25.
- **קודק**: H.264 (libx264) עם AAC הוא השילוב שעובד בכל מקום.
- **CRF**: איכות הקידוד. 18 כמעט ללא איבוד, 23 ברירת מחדל, 28 קובץ קטן. בסקריפטים כאן משתמשים ב-20.
- **Keyframe**: חיתוך מהיר בלי קידוד מחדש (`fastcut`) יכול לחתוך רק על keyframe. לכן הוא עלול לזוז בשנייה או שתיים. חיתוך מדויק נעשה עם `cut`.

תמיד מתחילים בבדיקת הקובץ:

```bash
scripts/ff.sh info media/input/clip.mp4
```

---

## 2. yt-dlp: הורדת וידאו

```bash
scripts/download.sh "https://www.youtube.com/watch?v=..."          # וידאו MP4
scripts/download.sh "https://www.youtube.com/watch?v=..." --audio  # רק MP3
scripts/download.sh "https://www.youtube.com/watch?v=..." --subs   # כולל כתוביות קיימות
```

הקבצים נשמרים ב-`media/downloads/`. מורידים רק תוכן שמותר לך להשתמש בו.

---

## 3. FFmpeg: עריכה בסיסית

| מה | פקודה |
|---|---|
| חיתוך מדויק מ-1:05 עד 1:30 | `scripts/ff.sh cut in.mp4 00:01:05 00:01:30 media/output/cut.mp4` |
| חיתוך מהיר (בלי קידוד) | `scripts/ff.sh fastcut in.mp4 65 90 out.mp4` |
| חיבור כמה קטעים | `scripts/ff.sh concat out.mp4 intro.mp4 main.mp4 outro.mp4` |
| חילוץ אודיו | `scripts/ff.sh audio in.mp4 out.mp3` |
| השתקה | `scripts/ff.sh mute in.mp4 out.mp4` |
| מוזיקת רקע (עוצמה 15%) | `scripts/ff.sh music in.mp4 media/assets/song.mp3 out.mp4 0.15` |
| צריבת כתוביות | `scripts/ff.sh subs in.mp4 media/transcripts/in.srt out.mp4` |
| המרה לאנכי (רילס) | `scripts/ff.sh vertical in.mp4 out.mp4` |
| הקטנה ל-720p | `scripts/ff.sh resize in.mp4 720 out.mp4` |
| פי 2 מהר / הילוך איטי | `scripts/ff.sh speed in.mp4 2 out.mp4`, `scripts/ff.sh speed in.mp4 0.5 out.mp4` |
| GIF | `scripts/ff.sh gif in.mp4 out.gif 480` |
| צילום פריים | `scripts/ff.sh frame in.mp4 12.5 shot.png` |
| נרמול עוצמת שמע | `scripts/ff.sh loudnorm in.mp4 out.mp4` |

הערות:
- `concat` מקודד מחדש לגודל 1920x1080 ב-30fps. לכן אפשר לחבר בעזרתו קבצים ממקורות שונים.
- הפקודה `concat` דורשת שבכל קובץ יהיה ערוץ אודיו. קובץ שקט צריך קודם לקבל אודיו ריק:
  `ffmpeg -i in.mp4 -f lavfi -i anullsrc -shortest -c:v copy -c:a aac out.mp4`

---

## 4. Whisper ו-ivrit.ai: תמלול

```bash
python scripts/transcribe.py media/input/clip.mp4              # עברית (מודל ivrit.ai)
python scripts/transcribe.py media/input/clip.mp4 --lang en    # אנגלית
python scripts/transcribe.py clip.mp4 --compute-type int8      # מהיר יותר במעבד
```

הסקריפט יוצר שלושה קבצים ב-`media/transcripts/`:
- `clip.srt` לצריבה עם FFmpeg או להעלאה ליוטיוב.
- `clip.vtt` לנגני ווב.
- `clip.words.json` עם חותמת זמן לכל מילה. Remotion ו-HyperFrames משתמשים בקובץ הזה לכתוביות מונפשות.

**למה ivrit.ai?** ivrit.ai הוא פרויקט ישראלי פתוח שאימן את Whisper על אלפי שעות של עברית. התוצאה מדויקת בעברית בהרבה מ-Whisper הרגיל. המודל `ivrit-ai/whisper-large-v3-turbo-ct2` יורד אוטומטית בפעם הראשונה (כ-1.6GB).

**טיפים:**
- בלי כרטיס מסך התמלול לוקח בערך פי 0.5 עד פי 1 מאורך הקובץ. אם זה איטי, מוסיפים `--compute-type int8`.
- אחרי התמלול כדאי לקרוא את ה-SRT ולתקן שמות פרטיים ומונחים לפני שצורבים אותו.

---

## 5. Remotion: וידאו מקוד React

Remotion מתאים לגרפיקה עם הרבה היגיון: כתוביות מילה-מילה, תבניות שחוזרות על עצמן ונתונים דינמיים.

```bash
npm run studio                                    # עורך חזותי בדפדפן (localhost:3000)
npx remotion render TitleCard media/output/title.mp4
npx remotion render CaptionedVideo media/output/reel.mp4 \
  --props='{"video":"input/clip.mp4","transcript":"transcripts/clip.words.json","durationInSeconds":42}'
```

בענן מוסיפים `--browser-executable=/opt/pw-browsers/chromium`.

**הקומפוזיציות הקיימות** (`remotion/src/`):
- `TitleCard`: כותרת ותת-כותרת מונפשות, 1920x1080. מקבלת את ה-props `title` ו-`subtitle`.
- `CaptionedVideo`: וידאו אנכי עם כתוביות בעברית. מוצגות 4 מילים בכל פעם, והמילה הנוכחית בצהוב.

**איך זה עובד:**
- `useCurrentFrame()` מחזיר את מספר הפריים הנוכחי. כל אנימציה מחושבת ממנו, עם `interpolate()` או `spring()`.
- `<OffthreadVideo src={staticFile("input/x.mp4")} />` מציג וידאו מתוך `media/`.
- `<Sequence from={30} durationInFrames={60}>` מציג רכיב החל מפריים 30 למשך 60 פריימים.
- קומפוזיציה חדשה: יוצרים קובץ ב-`remotion/src/` ורושמים אותו ב-`Root.tsx`.

---

## 6. HyperFrames: וידאו מ-HTML

HyperFrames מתאים למושן-גרפיקס, אינטרו, כותרות, אוברליי ומצגות. כותבים HTML ו-CSS, מנפישים עם GSAP, ו-HyperFrames מרנדר את זה ל-MP4.

```bash
cd hyperframes
npx hyperframes preview --background   # סטודיו בדפדפן
npx hyperframes check                  # בדיקת שגיאות (תמיד אחרי שינוי)
npx hyperframes snapshot --at 1,3      # תמונות מהשניות 1 ו-3
npx hyperframes render -o ../media/output/intro.mp4
npx hyperframes catalog                # כ-450 בלוקים מוכנים (מעברים, כותרות, גרפים)
npx hyperframes docs gsap              # תיעוד
```

**הכללים החשובים:**
- לכל אלמנט מתוזמן יש `data-start`, `data-duration` ו-`class="clip"`.
- יש timeline אחד של GSAP במצב paused, והוא נרשם ב-`window.__timelines["main"]`.
- לא משתמשים ב-`Math.random()`, ב-`Date.now()` או בקריאות רשת. הרינדור חייב להיות דטרמיניסטי.
- עברית: `<html dir="rtl">` והפונט Heebo, שנטען מ-`assets/fonts/`.

---

## 7. מתכונים מלאים

### רילס מפודקאסט, עם כתוביות בעברית
```bash
scripts/download.sh "<url>"
scripts/ff.sh cut "media/downloads/<file>.mp4" 00:12:30 00:13:15 media/input/clip.mp4
scripts/ff.sh vertical media/input/clip.mp4 media/input/clip_v.mp4
python scripts/transcribe.py media/input/clip_v.mp4
npx remotion render CaptionedVideo media/output/reel.mp4 \
  --props='{"video":"input/clip_v.mp4","transcript":"transcripts/clip_v.words.json","durationInSeconds":45}'
```

### סרטון יוטיוב עם אינטרו, מוזיקה וכתוביות
```bash
npx remotion render TitleCard media/output/intro.mp4 --props='{"title":"הפרק החדש","subtitle":"פרק 12"}'
python scripts/transcribe.py media/input/main.mp4
scripts/ff.sh subs media/input/main.mp4 media/transcripts/main.srt media/output/main_subs.mp4
scripts/ff.sh concat media/output/full.mp4 media/output/intro.mp4 media/output/main_subs.mp4
scripts/ff.sh music media/output/full.mp4 media/assets/music.mp3 media/output/final.mp4 0.1
scripts/ff.sh loudnorm media/output/final.mp4 media/output/final_norm.mp4
```

### לעבוד עם Claude
אפשר פשוט לבקש, למשל:
- "תחתוך את הדקה הראשונה של clip.mp4 ותוסיף כתוביות"
- "תמצא את 3 הרגעים הכי מעניינים בפודקאסט ותכין מהם רילסים"
- "תעשה אינטרו של 5 שניות עם הלוגו שלי"

Claude יודע לבחור את הכלי הנכון לכל בקשה בעזרת `CLAUDE.md` שבתיקיית הפרויקט.
