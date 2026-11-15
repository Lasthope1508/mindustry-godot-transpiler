# Handoff N2305 — Fracker live fraction fill

## What this slice did

Filled the Fracker proximity fraction live: pure
`source_fracker_proximity_fraction_state(linked_tiles, attribute_env)`
delegating to the N2292 SolidPump pure; tick wiring before the N2224 advance.
5 files, +2026/−11, commit `ab74a162` on `slice/N2305-fracker-fraction-fill`.

## Key facts for the next agent

- **The brief was WRONG about the def:** the only Fracker def (oil-extractor)
  sets `attribute = Attribute.oil` (Blocks.java:2972) + `baseEfficiency = 0f`
  (:2973) → validTiles is ALWAYS 0, fraction = boost + env ONLY. ALWAYS check
  the def in Blocks.java, not just the class file.
- Fracker has NO onProximityUpdate override (inherits SolidPump's, :150-159).
- Consts: `SOURCE_FRACKER_SIZE := 3`, `SOURCE_FRACKER_BASE_EFFICIENCY := 0.0`.
- Entry 35's cites (:118/:137-147) are stale; real cites :150-159/:80-83/
  :575-582/:124. Resolved DEFERRED entry is #32 in the merged base, not #35.
- SSOT +3/+1/+1/+2 (brief estimated +5 — the pure mirrors N2292's 3 keys).
  DEFERRED 327 (−1+3: linked-tiles live fill, attribute env live fill,
  onProximityUpdate trigger).

## Godot debt (this slice)

NEW proof `C07FrackerFractionFillProof` (6 keys) — never run.
