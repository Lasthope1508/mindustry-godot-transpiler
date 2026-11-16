# Handoff N2350 — MendProjector heal scan hitbox broad phase

## What this slice did

Replaced the MendProjector heal scan's rect center test with the
Java-exact QuadTree hitbox-overlap broad phase (the N2329 pure now
delegates to it). 8 files, +1186/−89, commit `ed49a44b` on
`slice/N2350-mend-hitbox-broad-phase`.

## Key facts for the next agent

- Pure `source_mend_projector_heal_candidates_hitbox_state(candidates,
  real_range, building_x, building_y)` → `{candidates}` (STRICT
  Rect.overlaps between each candidate's hitbox — a hit_size-sided square
  centered on the candidate — and the query rect).
- Missing hit_size → 0.0 (the N2335 precedent — NOT 4.0 like the
  ShockwaveTower bullets; buildings have no type default). Missing x/y or
  non-Dict excluded; entries never rewritten. Tick unchanged (broad →
  N2335 narrow → N2242 heal scan).
- SSOT +1/+1/+1/+2 (1 symbol, java_source arc-core Rect.java). DEFERRED
  332→331 (−1+0).
- ⚠️ **The brief's "no hit_size → identical outcome → NO re-run"
  conditional is WRONG for N2329** — default 0.0 makes edge/corner
  candidates degenerate point hitboxes, and STRICT overlap drops boundary
  points (simulation: `scan_admits_in_range` 6→1 unseeded). Fix: seeded
  `"hit_size": 8.0` (size-1 building) on the 6 in-range candidates → back
  to 6. **N2329 proof NEEDS RE-RUN** (SECOND re-run note on the N2329
  entry, after N2335 — the count does NOT increment). Do NOT seed the
  out-of-range near-edge candidates (breaks `scan_excludes_out_of_range`).
- **N2335 does NOT need a re-run** (pure keys call the untouched narrow
  pure; live tick simulates identically — 1 heal; proof file untouched).
- Test pins N2329/N2335 updated (FULL call pins preserved).
- Lesson: STRICT-overlap broad phases change degenerate-point outcomes —
  always simulate proof outcomes in Python (the N2340 pattern) before
  concluding "no re-run".

## Godot debt (this slice)

- NEW proof `C07MendProjectorHealScanHitboxProof` (6 keys) — never run.
- RE-RUN `C07MendProjectorHealScanRangeProof` (N2329) with the hit_size-seeded scene (2nd re-run note).
