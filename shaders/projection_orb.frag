#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;     // seconds, unbounded, continuously growing
uniform float uSeed;     // stable per-user offset — different, persistent star field per person
uniform float uProgress; // 0..13, completed-test count

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Personal star field over the shared cinematic video background — the
// video itself is the same asset for every user, but this layer is seeded
// from the user's own local id, so the exact pattern, sizes, colors and
// twinkle phases of "their sky" are unique to them and stay stable across
// sessions (not re-randomized on every open).
//
// Staging per the agreed storyboard: test 1 is a static frame (no stars,
// handled by the widget pausing the video), test 2 the video starts moving
// (still no stars), test 3 is a big, unmistakable first flare of stars
// (~40% of them at once — a small trickle here would be invisible, which
// is exactly what the first version of this got wrong), then the
// remaining ~60% light up in smaller batches across tests 4-12.
void main() {
  vec2 uv = FlutterFragCoord().xy / uSize.y;
  vec2 p = uv * 16.0;
  vec2 seedOffset = vec2(uSeed * 17.31, uSeed * 9.73);

  vec2 id = floor(p + seedOffset);
  vec2 gv = fract(p + seedOffset) - 0.5;
  float n = hash(id);
  float star = smoothstep(0.90, 1.0, n);

  float groupRoll = hash(id + vec2(90.1, 3.7));
  float unlockAt = groupRoll < 0.4 ? 3.0 : (4.0 + floor((groupRoll - 0.4) / 0.6 * 9.0));
  float unlocked = step(unlockAt, uProgress);
  // The single most-recently-unlocked batch reads as "the newest facet".
  float isNewest = unlocked * (1.0 - step(unlockAt, uProgress - 1.0));
  star *= unlocked;

  float sizeRoll = hash(id + vec2(31.7, 5.3));
  float colorRoll = hash(id + vec2(4.1, 17.9));
  float brightRoll = hash(id + vec2(62.4, 11.8));
  float twinkle = 0.5 + 0.5 * sin(uTime * 2.2 + n * 62.0);

  float baseRadius = mix(0.024, 0.05, sizeRoll);
  float radius = sizeRoll > 0.7 ? baseRadius * (0.7 + 0.6 * twinkle) : baseRadius;
  float d = length(gv);
  // A sharp bright core plus a much softer, wider glow around it — a flat
  // filled circle reads as a "dot", the added halo is what makes it read
  // as genuinely luminous instead of just bigger.
  float core = 1.0 - smoothstep(0.0, radius, d);
  float halo = 1.0 - smoothstep(0.0, radius * 3.2, d);
  star *= max(core, halo * 0.45);

  // ~1 in 5 stars is a standout "bright" one regardless of group, and the
  // freshly-unlocked group gets an extra boost on top of that so it's
  // unmistakably new, not just blending into the existing sky.
  float brightBoost = (brightRoll > 0.8 ? 2.4 : 1.4) + isNewest * 1.0;
  // Twinkle floor raised (was 0.35) — even at its dimmest a lit star stays
  // clearly visible instead of nearly fading out each cycle.
  float alpha = clamp(star * (0.6 + 0.4 * twinkle) * brightBoost, 0.0, 1.0);

  vec3 tint = colorRoll < 0.55
      ? vec3(1.0, 0.98, 0.92)      // white
      : colorRoll < 0.8
          ? vec3(1.0, 0.82, 0.45)  // gold
          : vec3(0.72, 0.58, 1.0); // violet
  tint = mix(tint, vec3(1.0, 1.0, 0.98), brightBoost > 1.6 ? 0.4 : 0.0);

  // Premultiplied alpha — required for correct SrcOver blending when this
  // layer is drawn on top of the video underneath it.
  fragColor = vec4(tint * alpha, alpha);
}
