# Report N2473 — BeamDrill drillMultipliers / blockedItem rows

**Slice:** N2473 — BeamDrill drillMultipliers lookup + blockedItems
init promotion as two pure-only pures. **Wave:** advances-32.
**Commit:** `6f850ebac` on
`slice/N2473-beam-drill-multipliers-blocked-item-rows` (base
`99a167e15`). **Files:** 5, +949/−8.

## Source

BeamDrill.java (core/src/mindustry/world/blocks/production/):
drillMultipliers :47, blockedItem :49, blockedItems :51, init
:84-85 (the blockedItem → blockedItems promotion). getDrillTime
:216-218 (`return drillTime / drillMultipliers.get(item, 1f);`).
updateTile :247 calls getDrillTime every tick; the result drives
lastDrillSpeed (:249), the drop threshold (:253) and the reset
(:261); drawPlace reads it too (:183). setStats :122. canPlaceOn
:198-214, drawPlace :138-195. arc ObjectFloatMap.get(key,
defaultValue) :286 (null key → default :287).

## Implementation

Two pure-only pures (no tick wiring):
`source_beam_drill_blocked_items_state(blocked_item,
blocked_items)` → {blocked_items_after} (the init promotion,
BeamDrill.java:84-85) + `source_beam_drill_drill_multiplier_state
(item, drill_multipliers)` → {multiplier} (the getDrillTime lookup,
BeamDrill.java:216-218). The multiplier pure returns ONLY the
multiplier — dividing the base drillTime (160f/100f) by it is the
drop-loop slice's wiring (the drop-loop entry was rewritten in
place to record the live lookup from N2473).

**Verify-first findings (Java wins over the brief):**
- **drillMultipliers ARE used at drill time — the brief was wrong.**
  getDrillTime(item) is called by updateTile every tick (:247) and
  drives lastDrillSpeed (:249), the drop threshold (:253) and the
  reset (:261). The brief's grep only saw setStats (:122) because
  it missed the indirect use through getDrillTime. The 1f default
  is confirmed on two layers: the call site passes 1f + arc
  ObjectFloatMap.get(key, defaultValue) (:286, null key → default
  :287).
- **Entry cite :36-40 is WRONG** — the real lines are :47
  (drillMultipliers) / :49 (blockedItem) / :51 (blockedItems),
  init :84-85. The old facing-scan docstring cites (:40/:38/:78-83)
  were also wrong, fixed to :51/:49/:81-87.
- **:154/:205 are drawPlace/canPlaceOn — two separate, UNPORTED
  methods** — the brief's claim that the gates "are already in the
  facing-scan pure" is NOT accurate: the facing-scan pure (N2339)
  only ports gate :391 of updateFacing (the same shape). The init
  pure supplies the input for all three gates; a NEW DEFERRED entry
  "BeamDrill canPlaceOn / drawPlace rows" was added.
- **Defs:** BOTH BeamDrill defs (plasma-bore Blocks.java:3038-3050,
  large-plasma-bore :3052-3068) do NOT set drillMultipliers/
  blockedItem — blockedItem = thorium (:3080) and beryllium 2f
  (:3083/:3114) are BurstDrill defs (impact-drill/eruption-drill).
  So the `multiplier_def` key asserts the BeamDrill def map is
  empty → every item reads 1.0 (including beryllium); the thorium
  / 2f values are only caller-supplied proof inputs.

## Commits

- Slice: `6f850ebac` (5 files, +949/−8).
- Integration cherry-pick: `b80d8bcc1` (clean).

## Tests

Targeted (new module
`tests.test_c07_beam_drill_multipliers_blocked_item_rows`): 3/4
PASS (registration, exact-evidence, row-state) + proof test FAIL
exactly AssertionError: unexpectedly None — NO Godot binary on this
VM (user order 2026-11-15). Neighbours (12 BeamDrill modules): Ran
48 (36 PASS + 12 proof Godot-absent), 0 errors.
Full gate (wave advances-32 integration, PID 1721, from 00:31): Ran 6874 tests in 1607.276s, FAILED (failures=393, skipped=5), 0 errors — 393/393 Godot-absent (386 inherited + 7 new proof tests N2469–N2475; Ran 6874 = 6846 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+2/+1/+2/+4 → 12370/1885/1838/3468** (exactly as
estimated). DEFERRED **#13 RESOLVED + 1 NEW ENTRY** (238→238, by
entry TEXT): the drop-loop entry was rewritten in place (multiplier
lookup live since N2473) and "BeamDrill canPlaceOn / drawPlace
rows" was added (canPlaceOn :198-214 / drawPlace :138-195 unported).

## Godot debt

- NEW proof `C07BeamDrillMultipliersBlockedItemRowsProof` (6 keys:
  `blocked_init_keeps`, `blocked_init_null`, `blocked_init_sets`,
  `multiplier_def`, `multiplier_default`, `multiplier_hit`) —
  written but NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run.
