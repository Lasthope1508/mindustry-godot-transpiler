# N2261 ForceProjector Booster Item (phaseFabric, optional fold beside coolant) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 7 — wave booster items, integration branch `integration/wave-booster-items-n2260-n2264`, base `22164673`).

## Source

ForceProjector def (Blocks.java:1974): phaseFabric boost. `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0: `consumeTriggerValid() || items.has(items, multiplier)? 1f: 0f`; `items.has(ItemStack[], float)` (ItemModule.java:153-158, check :154): EVERY stack must have `round(amount * multiplier)`. Booster = `optional(true, true)` (Consume.java:33-35) → optional pass (BuildingComp.java:1980-1981), cap by minEfficiency (:1986), zero when !update (:1992-1994). ForceProjector phaseValid = itemConsumer.efficiency > 0 (:207), phaseHeat lerps toward num(phaseValid) (:209), timer-gated consume with phaseUseTime 350f (:32, :211-213) → DEFERRED (timer-infra). `itemConsumer` and `coolantConsumer` are declared together on :54. **Note: phaseHeat reads itemConsumer.efficiency DIRECTLY, not optionalEfficiency — but the row still folds into the optional pass for Java faithfulness.** **Scope corrections (verified by grep): phaseUseTime = 350f is at ForceProjector.java:32, not :33. The optional pass is BuildingComp.java:1980-1981 (loop+body; :1979 is the `//same for optionals` comment).**

## Implementation

`SourceForceProjectorBuildState.gd`: pure `source_force_projector_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count` over frame items) → `optional_results`, appended beside the N2258 coolant row. Live inputs go via frame-stamp + advance frame-fallback (the N2258 coolant precedent) instead of changing the advance call site — the N2235 sibling test pins the exact call string `source_force_projector_update_tile_advance_state(frame, source_delta, time_scale, advance_building_x, advance_building_y, [], false)`. `_initial_frame` gains `"items": {}`. NO live intake fills `frame["items"]` yet (Separator precedent — the row reads the frame as-is, documented as a limit); the timer-gated consume stays deferred.

## Commits

Slice `073ecde1` (worker-N2261, branch `slice/N2261-force-projector-booster-item`, 5 files, +1010/−24, đã push, remote tip verified by ls-remote). Integration cherry-pick `b364beea` on `integration/wave-booster-items-n2260-n2264` (base 22164673). No coordinator fix needed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 20/20, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, coolant, update_tile: 9/12 non-proof PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 1856, launch 22:29 by coordinator lượt 7, done 22:47 +07): Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264). Run 1 (PID 25034, launch 22:09) was killed by VM restart #5 ~22:27 after ~17.8 min, no footer.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11735/1710/1632/3055; audit stays 1336. DEFERRED 293 (293 − 1 resolved + 1 new: ForceProjector live items intake). Merged wave DEFERRED: 289 entries (DEFERRED-after-booster-items.py) — 293 − 8 resolved + 4 new, resolved by entry TEXT not number.

## Godot debt

`C07ForceProjectorBoosterItemProof` — 6 keys: item_row_binary_one_when_present, item_row_zero_when_absent, live_tick_folds_item_row, optional_folds_min_of_coolant_and_item, phase_heat_lerps_toward_phase_valid, phase_valid_follows_item_row (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
