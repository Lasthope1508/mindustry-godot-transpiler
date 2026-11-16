# Report N2448 — StackConveyor blends / drawPlanRegion / rotatedOutput rows

**Slice:** N2448 — StackConveyor.blends() + drawPlanRegion() +
rotatedOutput(): three pure-only pures model the autotiler blend
verdict, the plan region, and the rotated-output verdict. **Wave:**
advances-29. **Commit:** `9636bd0ce` on
`slice/N2448-stack-conveyor-blends-plan-rows` (base `27b5ced7f`).
**Files:** 5, driver +169/−1.

## Source

blends() (StackConveyor.java:71-88): if tile.build is a
StackConveyorBuild: state == stateLoad → otherblock.outputsItems()
&& lookingAtEither(...); state == stateUnload && !outputRouter →
otherblock.acceptsItems && (!otherblock.noSideBlend ||
lookingAtEither(...)) && (notLookingAt(...) || (otherblock
instanceof StackConveyor && facing(...))) && !(world.build(other)
is a StackConveyorBuild in stateUnload) && !(world.build(other)
is a StackConveyorBuild in stateMove && !facing(...)). Fallback:
otherblock.outputsItems() && blendsArmored(...) && otherblock
instanceof StackConveyor. drawPlanRegion() (:90-104): bits =
getTiling(plan, list); null → return; rect(regions[0],
plan.drawx(), plan.drawy(), plan.rotation * 90); per i 0..3: bit
clear in bits[3] → rect(edgeRegion, plan.drawx(), plan.drawy(),
(plan.rotation − i) * 90). rotatedOutput() (:106-112):
world.build(x, y) is a StackConveyorBuild → state != stateUnload,
else super.rotatedOutput(x, y). State constants (StackConveyor.java:25):
stateMove = 0, stateLoad = 1, stateUnload = 2.

## Implementation

Three pure-only pures (no tick wiring):
- `source_stack_conveyor_blends_state(state, output_router,
  other_outputs_items, other_accepts_items, other_no_side_blend,
  looking_at_either, not_looking_at, other_facing,
  other_build_unload, other_build_move_not_facing, blends_armored,
  other_is_stack_conveyor)` → `{blends}`. All geometry/indexer
  predicates are caller-supplied bools (the N2435 precedent); the
  pure never reads the world. **`state` is a Variant: null = not
  a StackConveyorBuild** (the N2434 Variant-null precedent) — the
  brief's 12-param signature had no `instanceof` input, so null
  carries the gate. The fallback covers null, stateMove, and
  unload-with-outputRouter exactly as Java.
- `source_stack_conveyor_draw_plan_state(bits, plan_x, plan_y,
  rotation)` → `{base_call, edge_calls}`. `bits` is null-or-Array
  of 4 ints (getTiling is a CALL record — not ported); null → both
  null; `edge_calls` is an Array of rects keyed `"rotation"` (the
  N2438/N2442/N2434 plan convention, not the brief's "rot").
- `source_stack_conveyor_rotated_output_state(other_is_stack_build,
  other_state, super_rotated_output)` → `{rotated_output}`.

**Findings beyond the brief:**
1. **BRIEF ERROR — Java wins:** the brief said `state ==
   stateLoad (0)`; Java is `stateMove = 0, stateLoad = 1,
   stateUnload = 2` (StackConveyor.java:25). The pure + proof use
   stateLoad = 1. Documented in register, driver, and test.
2. **setStats (:64-68) verified uncovered** (the per-def stat
   entry covers size/speed/itemCapacity/health only) → the worker
   **added 1 new DEFERRED entry** as briefed (N2430 precedent);
   not ported. Its register list is 258 (258−1+1); the merge
   script allows the genuine addition through.
3. Family modules re-run after the driver edit (power/updateTile/
   draw, 12 tests): 9 PASS + 3 proof Godot-absent, no breakage.

## Commits

- Slice: `9636bd0ce` (5 files, driver +169/−1).
- Integration cherry-pick: `0495359cc` (clean).

## Tests

Targeted (new module
`tests.test_c07_stack_conveyor_blends_plan_rows`): 3/4 PASS
(registration, exact-evidence 42/42 exprs verbatim, row-state) +
proof test FAIL exactly AssertionError: unexpectedly None — NO
Godot binary on this VM (user order 2026-11-15).
Full gate (wave advances-29 integration, PID 5146, from 20:43): Ran 6790 tests in 3014.832s, FAILED (failures=372, skipped=5), 0 errors — 372/372 Godot-absent (365 inherited + 7 new proof tests N2447–N2453; Ran 6790 = 6762 + 28 new tests, exact arithmetic).

## SSOT / DEFERRED

SSOT single-slice **+4/+1/+3/+6** → 12295/1865/1804/3400 (exactly
as estimated). No shard changes — only the 4 canonical SSOT files
moved. Audit stays 1336. DEFERRED **#58 RESOLVED** (258→257 by
entry TEXT) **+ 1 new entry** (StackConveyor setStats rows) — the
register list is 258.

## Godot debt

- NEW proof `C07StackConveyorBlendsPlanRowsProof` (6 keys:
  `blends_load`, `blends_unload_router`, `blends_fallback`,
  `plan_bits_null`, `plan_edges`, `rotated_output`) — written but
  NEVER run; debt in GOAL.md §5.
- No old proof needs a re-run (pure-only, no tick wiring).
