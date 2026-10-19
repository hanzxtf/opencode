# opencode

Config, skills, plugins, and hooks for Claude Code, Crush, and opencode.

---

## Attribution

`hooks/ponytail-statusline.sh` is from [@dietrichgebert/ponytail](https://github.com/DietrichGebert/ponytail) v4.10.0 by Dietrich Gebert, licensed under the [MIT License](https://opensource.org/licenses/MIT).

The `skills/creative-director` skill is from [smixs/creative-director-skill](https://github.com/smixs/creative-director-skill) by Serge Shima, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See `skills/creative-director/LICENSE` and `skills/creative-director/NOTICE`.

The `skills/image-visual-skills` and `skills/video-visual-skills` skills are from [smixs/visual-skills](https://github.com/smixs/visual-skills) by Serge Shima, licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). See `skills/image-visual-skills/LICENSE` and `skills/image-visual-skills/NOTICE`.

The `skills/viral-*` skills (`viral-hooks`, `viral-short-form`, `viral-short-form-ideas`, `viral-instagram-reels`, `viral-tiktok-content`, `viral-youtube-shorts`, `viral-captions-and-ctas`) are from [vyralcontent/content-skills](https://github.com/vyralcontent/content-skills), licensed under the [MIT License](https://opensource.org/licenses/MIT). See each skill's `LICENSE`.

The `skills/ig-*` skills (`ig-hook-extractor`, `ig-caption-writer`, `ig-carousel-planner`, `ig-content-planner`, `ig-hashtag-strategist`, `ig-audience-insights`, `ig-repurposer`, `ig-profile-optimizer`, `ig-humanizer`) are from [sergebulaev/instagram-skills](https://github.com/sergebulaev/instagram-skills), licensed under the [MIT License](https://opensource.org/licenses/MIT). See each skill's `LICENSE`. Not vendored: the repo root router (`name: instagram-marketing`) — it links to `skills/<name>` paths that do not resolve in this flat layout — and the `.codex-marketplace/` duplicate tree.

The `skills/ffmpeg` skill is from [n0an/ffmpeg-skill](https://github.com/n0an/ffmpeg-skill), licensed under the [MIT License](https://opensource.org/licenses/MIT). See `skills/ffmpeg/LICENSE`.

The `skills/auto-subtitles` skill is from [sketch-man/claude-skill-auto-subtitles](https://github.com/sketch-man/claude-skill-auto-subtitles), licensed under the [MIT License](https://opensource.org/licenses/MIT). See `skills/auto-subtitles/LICENSE`.

The `skills/video-script` skill is from [xnomad-dev/claude-skills](https://github.com/xnomad-dev/claude-skills) (only `video-script-writer` was vendored, not the rest of that collection). The upstream repo ships **no license file**, so no explicit rights are granted. See `skills/video-script/NOTICE`.

The ten `skills/hyperframes*` and `skills/media-use` skills (`hyperframes`, `hyperframes-core`, `hyperframes-cli`, `hyperframes-animation`, `hyperframes-keyframes`, `hyperframes-creative`, `hyperframes-audio`, `hyperframes-registry`, `hyperframes-studio`, `media-use`) are the HyperFrames core skill set from [heygen-com/hyperframes](https://github.com/heygen-com/hyperframes), licensed under [Apache 2.0](https://www.apache.org/licenses/LICENSE-2.0). See each skill's `LICENSE`.

Not vendored from that repo: the 11 on-demand workflow skills (`product-launch-video`, `faceless-explainer`, `general-video`, `motion-graphics`, `music-to-video`, `slideshow`, `embedded-captions`, `talking-head-recut`, `pr-to-video`, `figma`, `remotion-to-hyperframes`), the `registry/blocks/` examples, and the six repo-internal skills under `.claude/skills` / `.agents/skills`. Install those per project with `npx hyperframes skills update` or the `hyperframes-registry` skill.

