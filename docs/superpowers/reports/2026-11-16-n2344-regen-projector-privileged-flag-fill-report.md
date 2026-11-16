# Report N2344 — RegenProjector live privileged flag fill

**Slice:** N2344 — RegenProjector updateTargets live privileged flag fill
(the tick stamps the live privileged verdict instead of literal `false`).
**Wave:** advances-16. **Commit:** `005f0e3d` on
`slice/N2344-regen-privileged-flag-fill` (base `4f31a099`). **Files:** 6,
+2042/−14.

## Source

Java: `BlockIndexer.java:372` (pred + !privileged); `Block.java:148`
(privileged flag); exactly 4 `privileged = true` defs in Blocks.java
(:6955/6965/6974/6981 — world-processor / world-cell / world-message /
world-switch, defs at :6948/:6961/:6970/:6977, all 4 ids in
content_registry.json). The tick already reads `other_block_id` from
SOURCE_BLOCK_ID_META_KEY (SourceRegenProjectorBuildState.gd:866).

## Implementation

New pure `source_regen_projector_privileged_state(block_id)` →
`{privileged}` (const SOURCE_REGEN_PROJECTOR_PRIVILEGED_BLOCK_IDS, the 4
defs); the tick stamps the pure result replacing the literal `false` at
:871. The N2277/N2338 pures are untouched (only docstring notes updated).

## Commits

- Slice: `005f0e3d` (6 files, +2042/−14).
- Integration cherry-pick: `be7f238d` (clean).

## Tests

Targeted (new module `tests.test_c07_regen_projector_privileged_flag_fill`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 8/8.
Siblings 7 RegenProjector modules green.
Full gate (wave advances-16 integration, run 2 PID 1743, 09:24–09:46): Ran
6443 tests in 1290.524s, FAILED (failures=287, skipped=5), 0 errors —
287/287 Godot-absent `AssertionError: unexpectedly None` (280 inherited +
7 new proof tests N2344–N2350). Gate run 1 (PID 9349, 09:10–09:24) was
killed by VM restart #11 ~09:24 (javalang wiped, reinstalled 09:24, no
commit/file loss).

## SSOT / DEFERRED

SSOT single-slice **+1/+1/+1/+2** → 11977/1782/1714/3220, exactly as
estimated (1 symbol, Blocks.java). Audit stays 1336.
DEFERRED **−1+0** (resolve #328, no new entry; the register was built on
the merged 332 base — unlike N2345/N2349, which built on the stale 334
snapshot).

## Godot debt

- NEW proof `C07RegenProjectorPrivilegedFlagFillProof` (3 keys:
  `privileged_pure_four_defs`, `privileged_pure_false_otherwise`,
  `live_tick_excludes_privileged`) — written but NEVER run; debt in GOAL.md
  §5. The live tick seeds hydrogen 1.0 + power_status 1.0 + any_targets
  true; a damaged world-processor at (32,20) in-rect is excluded while the
  in-rect copper-wall + projector stay in; 2nd tick stable.
- Follow-through: N2338 test pin changed (literal `'"privileged": false'`
  tick stamp → new stamp string); NO proof re-run needed (grep over all
  `C07RegenProjector*.gd` proofs: none places a privileged block).
- Scope corrections: NONE (the brief premise verified exactly).
