import { Composition } from "remotion";
import { TitleCard, titleCardSchema } from "./TitleCard";
import { CaptionedVideo, captionedVideoSchema } from "./CaptionedVideo";

const FPS = 30;

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* כרטיס כותרת מונפש — דוגמה בסיסית */}
      <Composition
        id="TitleCard"
        component={TitleCard}
        schema={titleCardSchema}
        durationInFrames={FPS * 4}
        fps={FPS}
        width={1920}
        height={1080}
        defaultProps={{ title: "עורך הווידאו שלי", subtitle: "Remotion + FFmpeg + ivrit.ai" }}
      />

      {/* וידאו עם כתוביות מילה-מילה מתוך scripts/transcribe.py */}
      <Composition
        id="CaptionedVideo"
        component={CaptionedVideo}
        schema={captionedVideoSchema}
        fps={FPS}
        width={1080}
        height={1920}
        durationInFrames={FPS * 10}
        defaultProps={{
          video: "input/clip.mp4",
          transcript: "transcripts/clip.words.json",
          durationInSeconds: 10,
        }}
        calculateMetadata={({ props }) => ({
          durationInFrames: Math.ceil(props.durationInSeconds * FPS),
        })}
      />
    </>
  );
};
