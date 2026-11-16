# Report N2335 — MendProjector heal scan within/privileged narrow filter

**Slice:** N2335 — MendProjector heal scan within/privileged narrow filter
(STRICT dst2 circle + !privileged, chained after the N2329 rect). **Wave:**
advances-14.
**Commit:** `30dc19bf` on `slice/N2335-mend-projector-heal-scan-narrow`
(base `f3f7af8e`). **Files:** 7, +1924/−16.

## Source

Java: `if(b.within(wx, wy, range + b.hitSize() / 2f) && pred.get(b) &&
!b.block.privileged)` (BlockIndexer.java:345-348); `within` is a STRICT dst2
check (Position.java:44-46); `hitSize` (BuildingComp.java:2048);
`privileged` (Block.java:148). All cites grep-verified — no scope
corrections.

## Implementation

New pure `source_mend_projector_supplied_heal_candidates_narrow_state` →
`{candidates}`: the narrow filter admits only candidates within
`range + hitSize/2` (STRICT) and NOT privileged. **CHAIN design (a):** the
narrow pure runs AFTER the N2329 rect (broad phase) — extending the N2329
pure would break N2329 semantics, because the N2329 test pins exact return
lines and the N2329 proof pure keys admit rect corners. The tick passes the
narrowed list into the N2242 heal scan.

**Follow-through on N2329 (2 files in this commit):** the N2329 test pin
moved to `narrowed_candidates` (FULL call pin, not prefix) + the N2329 proof
live tick now expects 1 heal (was 2: the rect corner at dst 65.05 is beyond
the live realRange ~49.98, so it is excluded by the narrow check) →
**the N2329 proof needs a RE-RUN** (recorded as a bold note on the existing
GOAL.md §5 entry; re-run list grows to 17).

## Commits

- Slice: `30dc19bf` (7 files, +1924/−16).
- Integration cherry-pick: `6a4b1d1c` (clean).

## Tests

Targeted (new module `tests.test_c07_mend_projector_heal_scan_narrow`): 3/4
PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). RED confirmed first
(KeyError 'N2335'). Exact-evidence 7/7.
Siblings (6 MendProjector modules): Ran 24 = 18 PASS + 6 proof, all
Godot-absent.
Full gate (wave advances-14 integration, PID 11801, 07:14–07:36): Ran 6394 tests in 1305.500s, FAILED (failures=275, skipped=5), 0 errors — 275/275 Godot-absent `AssertionError: unexpectedly None` (268 inherited + 7 new proof tests N2330–N2336).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11961/1770/1702/3196 (exactly the SCOPE
estimate); audit stays 1336.
DEFERRED 329→329 net 0 (resolved #327 within/privileged refinement + 1 new
entry: rect broad-phase hitbox miss — large-hitbox buildings whose center
sits outside the rect but within range + hitSize/2 never reach the narrow
check).

## Godot debt

- NEW proof `C07MendProjectorHealScanNarrowProof` (6 keys:
  `narrow_admits_within_range`,
  `narrow_excludes_beyond_range_plus_hit_size`,
  `narrow_excludes_at_exact_range`, `narrow_excludes_privileged`,
  `narrow_keeps_candidate_entries_intact`,
  `live_tick_passes_narrowed_candidates`) — written but NEVER run; debt in
  GOAL.md §5.
- RE-RUN: `C07MendProjectorHealScanRangeProof` (N2329) — the live tick now
  expects 1 heal (was 2) after the narrow follow-through.
