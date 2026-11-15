# Handoff N2303 — WallCrafter N2273 proof fix (FIX slice)

## What this slice did

Fixed the stale N2273 proof (`C07WallCrafterTimerConsumeProof`): N2301 stamps
`frame["efficiency_factor"]` unconditionally each enabled tick from
`frame["wall_edge_tiles"]`, overwriting the proof's seeded value with 0.0 (empty
edge) — the `timer_consume_removes_graphite` key needs eff > 0 for the consume
gate. The fix seeds `wall_edge_tiles` summing to 1.0 (3 tiles 0.5+0.25+0.25 —
both frames are large-cliff-crusher size 3, Blocks.java:3021). 1 file, +23/−10,
commit `51feaff4` on `slice/N2303-wall-crafter-n2273-proof-fix`.

## Key facts for the next agent

- Frame C zero-eff intentionally gets NO edge tiles (stamp yields 0.0, gate stays
  closed, same expected outcome). Frame D (cliff-crusher) untouched — its key
  doesn't depend on eff.
- 0.5+0.25+0.25 = 1.0 is exact in binary FP.
- Test module untouched; targeted 3/4 PASS + proof Godot-absent.
- SSOT +0/+0/+0/+0; DEFERRED unchanged.

## Godot debt (this slice)

RE-RUN of proof N2273 (`C07WallCrafterTimerConsumeProof`) — fixture changed.
