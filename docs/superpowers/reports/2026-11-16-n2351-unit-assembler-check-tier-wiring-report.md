# Report N2351 — UnitAssembler checkTier cross-building wiring

**Slice:** N2351 — UnitAssembler checkTier cross-building wiring (link-cell
events; DEFERRED #325 resolved, getLink discovery deferred). **Wave:**
advances-17. **Commit:** `9f42a3950` on
`slice/N2351-unit-assembler-check-tier-wiring` (base `9282b27a`).
**Files:** 6, +1050/−7.

## Source

Java: UnitAssembler.java:355-358 `updateModules` (`modules.addUnique(build);`
`checkTier();`) and :359-362 `removeModule` (`modules.remove(build);`
`checkTier();`); checkTier :323-378 (sort by tier, climb while each module is
max or max + 1, stop at the first gap, `currentTier = max;`); findLink/getLink
UnitAssemblerModule.java:65-83 (`link = getLink(team, tile.x, tile.y,
rotation);` `link.updateModules(this);` / `link.removeModule(this);`).
17 exact exprs, all verified verbatim.

## Implementation

New pure `source_unit_assembler_modules_event_state(modules, tier, event)` →
`{modules, current_tier, tier_gap}`: add/remove events over the module list,
addUnique dedupes by BUILD identity (two distinct tier-1 modules both enter,
[1, 1]); remove drops ONE occurrence; the tier re-derives through the N2133
climb (sort, climb while max or max + 1, stop at the first gap). A cell-level
helper `source_unit_factory_modules_event_for_cell_state` wires link-cell
events into the factory tick. The coordinator defined the frame-input format
`link`/`link_candidate` = `{"block", "cell": Vector2i}` (cell format verified:
`block_sprite_at_cell(cell: Vector2i)`, SourcePlacedBlockPortBridge.gd:35);
wiring is defensive — a link without a cell is skipped, and the 4 old UAM
proofs keep their block-only links unchanged.

## Commits

- Slice: `9f42a3950` (6 files, +1050/−7).
- Integration cherry-pick: `a31789af4` (clean).

## Tests

Targeted (new module `tests.test_c07_unit_assembler_check_tier_wiring`):
3/4 PASS + proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15). Exact-evidence 17/17.
14 sibling suites green except the slice's own proof.
Full gate (wave advances-17 integration, PID 12882, 10:58–11:23): Ran
6468 tests in 1457.080s, FAILED (failures=293, skipped=5), 0 errors —
293/293 Godot-absent `AssertionError: unexpectedly None` (287 inherited +
6 new proof tests N2351–N2354, N2356–N2357; N2355 has no proof test).

## SSOT / DEFERRED

SSOT single-slice **+5/+1/+2/+4** → 11989/1789/1722/3236 (brief est
+1/+1/+1/+2 low — 2 functions = 5 symbols, 2 contracts, 4 schemas). Audit
stays 1336.
DEFERRED **326 → 326 (−1+1)**: resolved #325, +1 new entry (getLink
discovery) + rewrite of the link/findLink rows.

## Godot debt

- NEW proof `C07UnitAssemblerCheckTierWiringProof` (11 keys:
  `event_add_climbs_tier`, `event_add_duplicate_tier_keeps_both`,
  `event_remove_absent_noop`, `event_remove_gap_resets_tier`,
  `event_remove_one_of_duplicate`, `helper_add_writes_frame`,
  `helper_missing_sprite_skips`, `helper_non_factory_skips`,
  `live_tick_block_only_link_skips`, `live_tick_two_modules_link`,
  `live_tick_unlink_removes_one`) — written but NEVER run; debt in GOAL.md
  §5. Live tick links two modules then unlinks one.
- No old proof needs a re-run (the 4 old UAM proofs keep block-only links
  and are skipped by the defensive wiring).
- ⚠️ **Scope correction (worker 1 blocked 10:44):** the link ref in all 4
  old UAM proofs is `{"block": ...}` only — it carries NO cell, so the
  wiring had no cell to call. Worker 1 stopped per brief, no code/commit,
  clean worktree. Coordinator re-scope 10:45: (a) coordinator-defined
  frame-input format `{"block", "cell": Vector2i}` (the getLink discovery
  slice MUST conform); (b) defensive wiring — cell-less links skip; (c)
  getLink discovery is a separate later slice (Java getLink scans
  `indexer.getFlagged(team, BlockFlag.unitAssembler)` team-wide +
  moduleFits — new infrastructure, not a proximity lookup). Brief rewritten
  (brief-n2351.md), worker-N2351 (lượt 2) re-spawned 10:46.
