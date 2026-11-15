# N2244 BuildTurret Plan Logic — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-5, coordinator lượt 5).

## What this slice did

- BuildTurret plan logic as a pure advance in `SourceBuildTurretBuildState.gd` (BuildTurret.java:141-225): follower validation, team-plan search with tail rotation, nearby-builder mimic, break-plan discard, suicide-plan removal. updateBuildLogic (BuilderComp.java:76+) defers to its own slice.
- 6 result symbols: plans, following, last_plan, team_plans, branch, plan_discarded.

## Key facts for the next agent

- **Verified line numbers (the scope doc was wrong)**: search :156-173, mimic :174-188, validation :189-216, controlled :217-220, suicide :223, updateBuildLogic :225.
- **The break-plan discard has an early `return;` (:201)** — it skips suicide removal + updateBuildLogic that tick; the pure function returns early identically. **`within` is STRICT `<`** on squared distance. buildPlan() = queue head. The `following = null` reset at :175 is dead code (kept for faithfulness).
- **The driver wiring is NOT gated on enabled** (BuildTurret sets no noUpdateDisabled; Java runs updateTile even when disabled). The driver passes no live team plans / builders / players yet.
- The N2243 sync/warmup wiring runs BEFORE this wiring per Java order (merged at integration, commit `340cec5d`); `_initial_frame` is the union of both slices' keys.
- Register: 60 exact exprs, 0 missing. DEFERRED: 282 (plan search/mimic + plan validation/break resolved; updateBuildLogic entry added). **Defense shard CHANGED**.
- Slice commit `f0077463` (branch `slice/N2244-build-turret-plan-logic`, đã push 19:49); integration cherry-pick `340cec5d` (hand merge); SSOT gộp `9296c64f` (11706/1698/1620/3031).

## Godot debt (this slice)

- `C07BuildTurretPlanLogicProof` — 6 keys (`follower_validation_clears_invalid`, `plan_search_picks_in_range`, `plan_search_rotates_queue`, `mimic_follows_nearby_builder`, `invalid_plan_discarded`, `suicide_plan_removed`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
