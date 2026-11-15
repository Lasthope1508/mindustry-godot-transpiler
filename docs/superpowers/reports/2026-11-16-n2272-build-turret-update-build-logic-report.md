# N2272 BuildTurret UpdateBuildLogic — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## Source

`updateTile` calls `unit.updateBuildLogic();` (BuildTurret.java:225 — the N2243 comment's :231 is WRONG, fixed in the driver). `updateBuildLogic` (BuilderComp.java:76+): `buildSpeed <= 0` return (:78); validatePlans (:80); updateBuilding/canBuild (:82-83); finalPlaceDst (:84-87); infinite (:88-90); buildCounter += Time.delta (ticks) (:92); NaN/Inf → 0 (:93-95); clamp 10f (:96-98); instant (:99-100); maxPerFrame (:101-102); core null check (:103-107); while loop (:108+). `validatePlans` (:57-74, not :60-71): plan skipped if tile null (:60-62), block null (:63-65), config invalid (:66-68), or the plan is DONE (:69-70, `tile.block() == plan.block` + rotation match + config match); plan removed from the queue via `plans.remove(i);` (ArraySeq indices shift — iteration runs i-- on removal, not index 0). Plan selection (:114-146, not :106-145): select the FIRST valid plan in queue order whose `dst2 <= finalPlaceDst` and NOT `shouldSkip` (:116-133; `shouldSkip` :246-251: in-progress `buildPlan != plan` + block null — no frame row yet for in-progress, so this slice evaluates it false); removeFirst + addLast (:134-135); if none, fallback = the nearest valid plan by `bestIndex` (:137-145). **dst2 does NOT use tile.x*8+4** — Java uses drawx = x*tilesize + block.offset (BuildPlan.java:142-144; offset is 0 for odd blocks, 4 for even blocks, Block.java:761); the "+4" is the tile center of the placement check (:155) — the port reads per-plan `block_offset` (default 0.0, N2244's x*8.0 precedent). **The loop within is `<=` (:124, NON-strict) but the fallback within() is STRICT `<` (Position.java:44-46)** — the fallback also re-uses the same dst2 offset. **The 1-plan case**: Java skips the selection loop when size ≤ 1 but still builds the first plan if within (:148-155) — the port evaluates the single plan with the same within/shouldSkip predicates. `buildRange = 200f` (BuildTurret.java:65, :76; build-tower range 200f Blocks.java:2001; buildSpeed 1.5f Blocks.java:2003). The placement step (:148-155) and the core-null check are NOT part of this slice (deferred).

## Implementation

`SourceBuildTurretBuildState.gd`: 2 pure functions — (1) `source_build_turret_build_counter_state` (counter accumulate + NaN reset + clamp 10f); (2) `source_build_turret_validate_and_select_state` (validate + select). Wiring is UNGATED on enabled (N2244 precedent). The validated+rotated plans persist even when selected == null; the counter only subtracts 1.0 when a plan is selected (documented deviation — Java's buildCounter decrements 1.0 per built plan inside the while loop). The driver runs validate+select ONCE/tick (one plan per tick — documented limit); sets frame key `last_plan` = selected plan (or null); `build_counter` persists on the frame. NO placement (the Java placement step is its own slice), NO change to the N2244 plan logic. Proof key selection renamed to true Java semantics (first valid in-range plan, not nearest — "nearest" is only correct at the fallback bestIndex).

## Commits

Slice `48ec98f0` (worker-N2272, branch `slice/N2272-build-turret-update-build-logic`, 5 files, +1267/−11, đã push, remote tip verified by ls-remote). Integration cherry-pick `34461391` on `integration/wave-power-launch-build-n2270-n2273` (base 3bca6665). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 60/60, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (15/20 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate (PID 14057, launch 23:50 by coordinator lượt 9, done 00:11 +07 16/11): Ran 6182 in 1189.124s, failures=222, skipped=5, 0 errors — 222/222 Godot-absent (218 inherited + 4 new proof tests N2270–N2273).

## SSOT / DEFERRED

SSOT single-slice +8/+1/+2/+4 → 11781/1720/1650/3092; audit stays 1336. +8 symbols, not the SCOPE-estimated +4 — the 2 result dicts carry 4+4 keys (2 contracts + 4 schemas as estimated). DEFERRED 291 (290 − 1 entry line 260 partial-resolve + 2 new: placement rows + live frame inputs). Merged wave DEFERRED: 290 entries (DEFERRED-after-power-launch-build.py) — 290 − 5 resolved/removed + 5 new, resolved by entry TEXT not number.

## Godot debt

`C07BuildTurretUpdateBuildLogicProof` — 6 keys: counter_accumulates_and_clamps, counter_nan_resets_to_zero, selection_fallback_rotates_to_nearest, selection_picks_first_valid_in_range, validate_keeps_valid_plan, validate_removes_null_tile_plan (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
