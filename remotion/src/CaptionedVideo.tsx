import { useEffect, useState } from "react";
import { z } from "zod";
import {
  AbsoluteFill,
  OffthreadVideo,
  continueRender,
  delayRender,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";

// נתיבים יחסיים לתיקיית media/ (מוגדרת כ-publicDir ב-remotion.config.ts)
export const captionedVideoSchema = z.object({
  video: z.string(),
  transcript: z.string(),
  durationInSeconds: z.number(),
});

type Word = { text: string; start: number; end: number };

const WORDS_PER_PAGE = 4;

export const CaptionedVideo: React.FC<z.infer<typeof captionedVideoSchema>> = ({ video, transcript }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const [words, setWords] = useState<Word[]>([]);
  const [handle] = useState(() => delayRender("טוען תמלול"));

  useEffect(() => {
    fetch(staticFile(transcript))
      .then((r) => r.json())
      .then((data) => setWords(data.words ?? []))
      .catch(() => setWords([]))
      .finally(() => continueRender(handle));
  }, [transcript, handle]);

  const t = frame / fps;
  const idx = words.findIndex((w) => t >= w.start && t < w.end);
  const pageStart = idx >= 0 ? Math.floor(idx / WORDS_PER_PAGE) * WORDS_PER_PAGE : -1;
  const page = pageStart >= 0 ? words.slice(pageStart, pageStart + WORDS_PER_PAGE) : [];

  return (
    <AbsoluteFill style={{ backgroundColor: "black" }}>
      <OffthreadVideo src={staticFile(video)} style={{ width: "100%", height: "100%", objectFit: "cover" }} />
      <AbsoluteFill style={{ justifyContent: "flex-end", alignItems: "center", paddingBottom: 380 }}>
        <div
          style={{
            direction: "rtl",
            display: "flex",
            gap: 18,
            flexWrap: "wrap",
            justifyContent: "center",
            maxWidth: 950,
            fontFamily: "Heebo, 'DejaVu Sans', Arial, sans-serif",
            fontWeight: 800,
            fontSize: 78,
            textShadow: "0 0 12px rgba(0,0,0,.9), 0 4px 0 #000",
          }}
        >
          {page.map((w, i) => (
            <span key={pageStart + i} style={{ color: pageStart + i === idx ? "#facc15" : "white" }}>
              {w.text}
            </span>
          ))}
        </div>
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
