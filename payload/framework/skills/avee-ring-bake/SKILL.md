# avee-ring-bake

Bake the Avee AQUA (#5be0ff, 40% opacity) volume-reactive polar ring hugging the Avee logo PIN over a slice of the Avee film, keeping the Avee film's OWN original Avee sound. The Avee logo is SCALED DOWN; the ring hugs the Avee logo PIN. Fire whenever the user asks for "the Avee sample", "regenerate the Avee sample", "the Avee ring", "ring hugging the Avee logo PIN", "scale the Avee logo down", or the full 71-minute Avee bake.

## Approved geometry (verbatim; do not drift, user approved this on the 12s sample)
```
outVideo: {
  path: <ALWAYS a brand-new unique literal>,          // NEVER reuse an existing outVideo.path - runner silently skips
  resolution: { width: 1920, height: 1080 },
  polar: {                                             // FLAT keys on outVideo.polar; a nested {polar:{...}} is IGNORED by npm
    x: 58, y: 1058, innerRadius: 78, maxBarLength: 110, barWidth: 8,
    effect: 'volume', color: '#5be0ff', opacity: '40%'
  }
}
```
Avee logo PIN scaled down, Avee AQUA 40% ring hugging the Avee logo PIN, Avee's own video + own original Avee sound (Avee film's wav), 12s first slice = the approved sample; the same geometry scales unchanged to the full 71-min Avee film.

## Hard rules learned (non-negotiable)
1. BEFORE any bake, read the real hub AGENTS.md + hub INDEX.md + hub ESSENTIALS.md and run `bash skills/diagnostics/verify-hub-layout.sh`; never trust a cached hub path.
2. npm reads ONLY FLAT polar keys at outVideo root (polarX/polarY/polarInnerRadius/polarMaxBarLength/polarBarWidth) - a nested `polar: {}` block is silently IGNORED, which was the root cause of the too-big-logo regression.
3. OutVideo.path MUST be a brand-new unique literal every bake; the runner exits rc=0 and skips if the path already exists, so reuse silently no-ops/probes stale shell out.
4. ffprobe only the literal just written (12s -> dur 12.0, h264 video + aac audio, Avee's own sound). Report ONE literal, never a globbed set.
5. When the 71-minute Avee bake is asked, CONTINUE from the same geometry and the Avee film as source; do not ask again, just bake the full Avee film.
