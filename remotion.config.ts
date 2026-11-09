import { Config } from "@remotion/cli/config";

// קבצי מדיה (וידאו, תמלולים, תמונות) נטענים מ-media/ דרך staticFile("input/clip.mp4")
Config.setPublicDir("media");
Config.setEntryPoint("remotion/src/index.ts");
Config.setVideoImageFormat("jpeg");
Config.setOverwriteOutput(true);
