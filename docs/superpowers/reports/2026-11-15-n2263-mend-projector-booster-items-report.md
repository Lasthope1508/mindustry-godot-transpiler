# N2263 MendProjector Booster Items (mender silicon + mend-projector phaseFabric) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 7 — wave booster items, integration branch `integration/wave-booster-items-n2260-n2264`, base `22164673`).

## Source

Mend defs: mender silicon boost (Blocks.java:1929); mend-projector phaseFabric boost (:1941). `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0: `consumeTriggerValid() || items.has(items, multiplier)? 1f: 0f`; `items.has(ItemStack[], float)` (ItemModule.java:153-158, check :154): EVERY stack must have `round(amount * multiplier)`. Booster = `optional(true, true)` (Consume.java:33-35) → optional pass (BuildingComp.java:1980-1981), cap by minEfficiency (:1986), zero when !update (:1992-1994). Mend timer-gated consume (useTime 400f, MendProjector.java:102-104) → DEFERRED (timer-infra). **Scope note (verified by grep): the Mend timer-consume DEFERRED entry is #1 in the merged file (line 5), not #5 — it stays deferred.**

## Implementation

`SourceMendProjectorBuildState.gd`: pure `source_mend_projector_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count` over frame items; stacks explicit per def: mender `[{"item": "silicon", "amount": 1}]`, mend-projector `[{"item": "phase-fabric", "amount": 1}]`) → `optional_results`; the N2193 advance already reads `frame["optional_efficiency"]` for phaseHeat, untouched. `_initial_frame` gains `"items": {}`. NO live intake fills `frame["items"]` yet (Separator precedent — the rows read the frame as-is, documented as a limit); the timer-gated consume stays deferred.

## Commits

Slice `ac718a0a` (worker-N2263, branch `slice/N2263-mend-projector-booster-items`, 5 files, +913/−13, đã push, remote tip verified by ls-remote). Integration cherry-pick `cf4e1633` on `integration/wave-booster-items-n2260-n2264` (base 22164673). No coordinator fix needed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 21/21, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, update_tile, heal_scan: 9/12 non-proof PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 1856, launch 22:29 by coordinator lượt 7, done 22:47 +07): Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264). Run 1 (PID 25034, launch 22:09) was killed by VM restart #5 ~22:27 after ~17.8 min, no footer.

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11734/1710/1632/3055; audit stays 1336. DEFERRED 293 (293 − 1 resolved + 1 new: MendProjector frame items intake). Merged wave DEFERRED: 289 entries (DEFERRED-after-booster-items.py) — 293 − 8 resolved + 4 new, resolved by entry TEXT not number.

## Godot debt

`C07MendProjectorBoosterItemsProof` — 6 keys: booster_row_folds_optional_only, live_tick_folds_booster_row, mend_projector_row_binary_phase_fabric, mender_row_binary_silicon, optional_capped_by_min_efficiency, phase_heat_lerps_toward_optional (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
