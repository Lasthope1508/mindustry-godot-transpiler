# Handoff N2339 — BeamDrill facing scan / updateFacing count

## What this slice did

Ported the live facingAmount computation: a pure facing scan over frame
`facing_tiles`, stamped each enabled tick before the N2195 advance. 14
files, +1962/−21, commit `54697121` on
`slice/N2339-beam-drill-facing-scan`.

## Key facts for the next agent

- Pure `source_beam_drill_facing_scan_state(facing_tiles, size, beam_range,
  tier, blocked_items)` → `{facing_amount}`. First solid tile breaks the
  ray (even if unmineable); count on mineable wallDrop (:391).
- **updateFacing is BeamDrill.java:375-411** (:375-410 was off by one;
  :368-373 is updateLasers). Coordinator fixed the cite in the spec + the
  N2202 test comments at integration (`1bfe4322`).
- Preload cycle: `load()` at call time for SourceDrillRuntimeState
  (BurstDrill precedent); test pins assertNotIn on the preload.
- Param is `beam_range` (GDScript reserves `range()`).
- DEFERRED net 0 (#27 rewritten in place). SSOT +1/+1/+1/+2; 44 exact
  exprs; 4 production shards changed.
- Old proofs N2155/N2195/N2202/N2256/N2289 SAFE, no re-run. Known
  deviation: disabled drill keeps the previous count (Java recomputes).

## Godot debt (this slice)

- NEW proof `C07BeamDrillFacingScanProof` (6 keys) — never run.
