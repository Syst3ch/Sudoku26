import { z } from "zod";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";

export const titleCardSchema = z.object({
  title: z.string(),
  subtitle: z.string(),
});

export const TitleCard: React.FC<z.infer<typeof titleCardSchema>> = ({ title, subtitle }) => {
  const frame = useCurrentFrame();
  const { fps, durationInFrames } = useVideoConfig();

  const pop = spring({ frame, fps, config: { damping: 14 } });
  const subOpacity = interpolate(frame, [15, 30], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" });
  const fadeOut = interpolate(frame, [durationInFrames - 15, durationInFrames], [1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: "linear-gradient(135deg, #0f172a, #1e3a8a)",
        justifyContent: "center",
        alignItems: "center",
        direction: "rtl",
        fontFamily: "Heebo, 'DejaVu Sans', Arial, sans-serif",
        opacity: fadeOut,
      }}
    >
      <h1 style={{ color: "white", fontSize: 120, margin: 0, transform: `scale(${pop})` }}>{title}</h1>
      <p style={{ color: "#93c5fd", fontSize: 48, marginTop: 24, opacity: subOpacity }}>{subtitle}</p>
    </AbsoluteFill>
  );
};
