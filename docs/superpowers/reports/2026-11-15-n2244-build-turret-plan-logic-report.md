# N2244 BuildTurret Plan Logic — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 5 — wave advances-5, integration branch `integration/wave-advances-5-n2242-n2248`, base `00f5feb3`).

## Source

- BuildTurretBuild.updateTile() plan half (BuildTurret.java:141-225): autonomous `if(!isControlled()){` (:141) + `unit.updateBuilding(true);` (:142); follower validation (:144-155); plan search (:156-173); mimic (:174-188); validation (:189-216); controlled (:217-220); suicide-plan removal (:223); `unit.updateBuildLogic();` (:225, BuilderComp.java:76+ — deferred to its own slice).
- **Scope corrections (all verified by grep — the scope doc numbers were wrong)**: search :156-173 (not :156-175), mimic :174-188 (not :178-193), validation :189-216 (not :194-221), controlled :217-220 (not :223-225), suicide :223 (not :228-229), updateBuildLogic :225 (not :231). **The break-plan discard has an early `return;` (:201)** — it skips the suicide removal + updateBuildLogic that tick; the pure function returns early identically. **`within` is STRICT `<` on squared distance** (Arc Position.java:44-46). buildPlan() = queue head (BuilderComp.java:313-315). The suicide check needs an explicit `build_is_self` bool per plan. The `following = null` reset at :175 is dead code in the elif chain (kept for faithfulness).
- Single def build-tower (Blocks.java:1997-2006); targetInterval 15 (:29); timerTarget/timerTarget2 (:28).

## Implementation

- `SourceBuildTurretBuildState.gd`:
  - Pure `source_build_turret_plan_logic_state(frame, ...)` → 6 result symbols: plans, following, last_plan, team_plans, branch, plan_discarded.
  - **Driver wiring is NOT gated on enabled** (BuildTurret sets no noUpdateDisabled, so Java runs updateTile even when disabled, BuildingComp.java:2274-2277). The driver passes no live team plans / nearby builders / players yet (empty lists, both timers false, controlled false) and assumes the current request stays valid (req_valid_place_or_break true — the port cannot evaluate Build.validPlace / validBreak live).
  - Integration: the N2244 function was placed after `source_build_turret_power_status_row_state` in its branch (N2243's function absent there); the coordinator merged it AFTER the N2243 function in Java order (6-hunk hand merge, commit `340cec5d`); `_initial_frame` is the union of both slices' keys; the N2243 wiring runs BEFORE the N2244 wiring per Java order.

## Commits

- Slice `f0077463` (worker-N2244, branch `slice/N2244-build-turret-plan-logic`, 5 files +1086/−10; đã push 19:49, remote tip f0077463).
- Integration cherry-pick `340cec5d` (MERGE TAY driver BuildTurret, 6 hunk — constants + `_initial_frame` union + bind comment + power-row docstring + 2 pure functions + 2 wirings); SSOT gộp `9296c64f` (wave advances-5): 11706/1698/1620/3031 (slice riêng +6/+1/+1/+2 → 11648/1692/1614/3019).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 60/60, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Siblings N2184/N2215: 3/4 PASS, proof Godot-absent — không regression.
- Targeted wave (7 module): Ran 28, 21 PASS + 7 proof Godot-absent. Neighbours 8 module: Ran 32, 24 PASS + 8 proof Godot-absent, 0 error.
- Full gate wave advances-5: Ran 6082 in 1118.145s, failures=197, skipped=5, 0 errors — 197/197 Godot-absent (190 inherited + 7 new proof tests N2242–N2248).

## SSOT / DEFERRED

- SSOT slice riêng +6/+1/+1/+2 → 11648/1692/1614/3019; audit 1336, legacy 0. **Defense shard CHANGED** (`defense_slices` + `defense_api_contracts`).
- DEFERRED 282 (ledger diff −4 +3: plan search/mimic + plan validation/break entries resolved; updateTile advance + live-plans/suppression entries reworded; updateBuildLogic entry added).
- DEFERRED gộp sau wave advances-5: 294 entries (283 − 11 resolved + 22 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07BuildTurretPlanLogicProof` — 6 keys: `follower_validation_clears_invalid`, `plan_search_picks_in_range`, `plan_search_rotates_queue`, `mimic_follows_nearby_builder`, `invalid_plan_discarded`, `suicide_plan_removed`.
