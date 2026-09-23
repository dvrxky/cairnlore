---
name: bake-avee-polar-ring
description: >-
  Render an Avee-style Avee-AQUA (#5be0ff) 40%-opacity volume-reactive polar disk
  (ring of bars hugging the Avee logo PIN) over an Avee film slice or the full film,
  keeping the film's own original Avee sound, using nodejs-audio-visualizer from
  /private/tmp/bs-pkg. Use when the user says "bake the Avee ring", "Avee ring
  sample", "regenerate the Avee sample", "make the Avee ring hug the Avee logo",
  or during the full-film Avee bake. Critical: the npm tool reads FLAT polar keys
  only (polarX/polarY/polarInnerRadius/polarMaxBarLength/polarBarWidth at outVideo
  root, NOT a nested polar{} object - a nested block is silently ignored and the
  bake no-ops with rc=0), and it silently SKIPS an existing outVideo.path (rc=0,
  no overwrite) - so ALWAYS bake to a brand-new unique literal path and ALWAYS
  PROBE that exact literal.
---

# Skill: Bake Avee Polar Ring

Bake the Avee aqua 40% volume polar ring that hugs the Avee logo PIN over an Avee
film slice or the full Avee film, keeping the Avee film's own original Avee sound.

## Triggers

- "bake the Avee ring"
- "Avee ring sample"
- "regenerate the Avee sample"
- "make the Avee ring hug the Avee logo pin"
- "the Avee polar ring is too big / shrink it"
- "bake the 71 minutes with the Avee ring"
- "remove the right side waveform"

## Preconditions

- npm package installed: `/private/tmp/bs-pkg` (nodejs-audio-visualizer dist).
- Input film slice + its own original sound on disk (e.g. `/private/tmp/bs-node/film12b.mp4` + `/private/tmp/bs-node/film12b.wav`).
- Avee logo PIN geometry (1920x1080): Avee logo box 42x75 at 37,1021; pin center ~58,1058.

## Steps

1. Read the current config script verbatim (e.g. `/private/tmp/bs-node/rv-sm.js`)
   before baking. Confirm the outVideo block uses FLAT polar keys:
   `polarX`, `polarY`, `polarInnerRadius`, `polarMaxBarLength`, `polarBarWidth`,
   at the SAME level as `effect`/`color`/`opacity`. A NESTED `polar: {...}` object
   is silently ignored - that is the root cause of every no-op. If you see a nested
   block, rewrite to flat keys first.
2. Avee logo PIN ring geometry (the approved SMALL ring that hugs the logo PIN):
   - `polarX: 58, polarY: 1058` (pin center)
   - `polarInnerRadius: 78, polarMaxBarLength: 110, polarBarWidth: 8`
   - `effect: 'volume', color: '#5be0ff', opacity: '40%'`
   - resolution 1920x1080
3. CRITICAL - new literal every time: npm silently SKIPS `outVideo.path` if the
   file already exists (rc=0, no render, no error). ALWAYS choose a NEW unique
   literal path with a fresh timestamp in the name, and make sure it does NOT
   exist on disk before baking.
4. To remove the right-side waveform strip, add `spectrumWidth: 0,
   spectrumOpacity: 0` (and kill spectrum bar width) in the outVideo block.
5. Bake: `cd /private/tmp/bs-node && node rv-sm.js` (or the slice baker).
   Expect rc=0 AND a NEW file at the exact literal.
6. Verify ONLY that literal with ffprobe:
   `ffprobe -v error -show_entries format=duration -of csv=p=0 <literal>`
   `ffprobe -v error -show_entries stream=codec_type,codec_name -of csv=p=0 <literal>`
   Expect dur ~12.000000 (slice) and streams h264,video + aac,audio (the film's
   own original Avee sound).

## Validation

- rc=0 AND the exact literal exists on disk AND ffprobe of that literal shows
  dur 12.000000 and h264 video + aac audio.
- Output has NO right-side waveform strip (spectrumWidth:0). The Avee aqua ring
  hugs the Avee logo PIN (bottom-left, small) and the film's own original sound is
  preserved.

## Example prompts

- "bake the Avee ring on the 12s slice now"
- "regenerate the Avee sample"
- "shrink the Avee ring more, remove the right side waveform"
- "record everything, create the skill, then wait for my go on the 71 minutes"
