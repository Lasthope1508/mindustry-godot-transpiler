# Handoff N2335 — MendProjector heal scan within/privileged narrow filter

## What this slice did

Wired the MendProjector heal scan narrow filter: a new pure admits only
candidates within `range + hitSize/2` (STRICT) and NOT privileged, chained
after the N2329 rect. 7 files, +1924/−16, commit `30dc19bf` on
`slice/N2335-mend-projector-heal-scan-narrow`.

## Key facts for the next agent

- Pure `source_mend_projector_supplied_heal_candidates_narrow_state` →
  `{candidates}`: STRICT dst2 circle + !privileged
  (BlockIndexer.java:345-348; within STRICT dst2 Position.java:44-46;
  hitSize BuildingComp.java:2048; privileged Block.java:148).
- **CHAIN design (a):** the narrow pure runs AFTER the N2329 rect (broad
  phase) — extending the N2329 pure would break N2329 semantics (the N2329
  test pins exact return lines + the N2329 proof pure keys admit rect
  corners). The tick passes the narrowed list into the N2242 heal scan.
- **Follow-through on N2329 (2 files in this commit):** the N2329 test pin
  moved to `narrowed_candidates` (FULL call pin, not prefix) + the N2329
  proof live tick now expects 1 heal (was 2: the rect corner at dst 65.05
  is beyond the live realRange ~49.98) → **the N2329 proof needs a RE-RUN**.
- No scope corrections (all cites grep-verified).
- SSOT +1/+1/+1/+2 (exactly the SCOPE estimate). DEFERRED net 0 (resolved
  #327 + 1 new: rect broad-phase hitbox miss — large-hitbox buildings whose
  center sits outside the rect but within range + hitSize/2 never reach the
  narrow check).

## Godot debt (this slice)

- NEW proof `C07MendProjectorHealScanNarrowProof` (6 keys) — never run.
- RE-RUN: `C07MendProjectorHealScanRangeProof` (N2329) — live tick now
  expects 1 heal (was 2).
