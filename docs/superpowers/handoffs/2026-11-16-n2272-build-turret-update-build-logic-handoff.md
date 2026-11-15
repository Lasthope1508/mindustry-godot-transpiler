# N2272 BuildTurret UpdateBuildLogic — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## What this slice did

BuildTurret updateBuildLogic (BuilderComp): build counter (accumulate + NaN reset + clamp 10f) + validate-and-select (validatePlans + first-valid-in-range selection + nearest fallback). 2 pure functions (`source_build_turret_build_counter_state`, `source_build_turret_validate_and_select_state`). Driver runs validate+select ONCE/tick (one plan per tick — documented limit); frame keys `last_plan` and `build_counter`. NO placement, NO change to the N2244 plan logic.

## Key facts for the next agent

- **`unit.updateBuildLogic();` is at BuildTurret.java:225** — the N2243 comment's :231 is WRONG (fixed in the driver).
- **validatePlans :57–74** (not :60–71); **plan selection :114–146** (not :106–145). Removal runs `plans.remove(i);` with i-- on removal (ArraySeq indices shift — not index 0).
- **dst2 does NOT use tile.x*8+4** — Java uses drawx = x*tilesize + block.offset (BuildPlan.java:142–144; offset 0 odd blocks, 4 even blocks, Block.java:761). The "+4" is the tile center of the placement check (:155). The port reads per-plan `block_offset` (default 0.0; N2244's x*8.0 precedent).
- **The loop within is `<=` (:124, NON-strict) but the fallback within() is STRICT `<`** (Position.java:44–46). removeFirst/addLast :134–135.
- **The 1-plan case**: Java skips the selection loop when size ≤ 1 but still builds the first plan if within (:148–155) — the port evaluates the single plan with the same within/shouldSkip predicates.
- Proof key selection renamed to true Java semantics (first valid in-range plan, not nearest — "nearest" is only correct at the fallback bestIndex).
- Wiring is UNGATED on enabled (N2244 precedent). Validated+rotated plans persist even when selected == null; the counter only subtracts 1.0 when a plan is selected (documented deviation — Java's buildCounter decrements 1.0 per built plan inside the while loop).
- `buildRange = 200f` (BuildTurret.java:65, :76; build-tower range 200f Blocks.java:2001; buildSpeed 1.5f Blocks.java:2003). The placement step (:148–155) and the core-null check are NOT part of this slice (deferred).
- SSOT +8/+1/+2/+4 → 11781/1720/1650/3092 (audit 1336). +8 symbols, not the SCOPE-estimated +4 — the 2 result dicts carry 4+4 keys (2 contracts + 4 schemas as estimated). Exact-evidence 60/60. DEFERRED 291 (−1 entry line 260 partial-resolve + 2 new: placement rows + live frame inputs).

## Godot debt (this slice)

`C07BuildTurretUpdateBuildLogicProof` — 6 keys: counter_accumulates_and_clamps, counter_nan_resets_to_zero, selection_fallback_rotates_to_nearest, selection_picks_first_valid_in_range, validate_keeps_valid_plan, validate_removes_null_tile_plan (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_build_turret_update_build_logic`. Do NOT mark done until it passes there.
