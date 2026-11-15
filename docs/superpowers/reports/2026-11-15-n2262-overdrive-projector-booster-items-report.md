# N2262 OverdriveProjector Booster Items (projector phaseFabric optional + dome phaseFabric/silicon required) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 7 — wave booster items, integration branch `integration/wave-booster-items-n2260-n2264`, base `22164673`).

## Source

Overdrive defs: overdrive-projector phaseFabric boost (Blocks.java:1948); overdrive-dome `consumeItems(phaseFabric 1, silicon 1)` REQUIRED (:1961), hasBoost=false, useTime 300f. `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0; `items.has(ItemStack[], float)` (ItemModule.java:153-158, check :154): EVERY stack must have `round(amount * multiplier)`. Booster = `optional(true, true)` (Consume.java:33-35) → optional pass (BuildingComp.java:1980-1981), cap by minEfficiency (:1986), zero when !update (:1992-1994); required ConsumeItems folds in the first pass (:1969-1976), result 0 → shouldConsumePower=false (:1972-1973). Overdrive cadence: useProgress += delta() when efficiency > 0; >= useTime (400f default, dome 300f) → consume() + %= useTime (:114-120; consume() itself at :118); phaseHeat lerps toward optionalEfficiency when hasBoost (:102-104). **Scope corrections (verified by grep): `consume()` is at OverdriveProjector.java:118, not :119 (:119 is `useProgress %= useTime;`). The scope doc's DEFERRED numbers are file LINE numbers, not entry indices: the Overdrive entries are lines 44 (booster item rows) and 242 (useProgress consume).**

## Implementation

`SourceOverdriveProjectorBuildState.gd`: ONE pure `source_overdrive_projector_item_consumer_row_state` serves both rows (the efficiency formula is identical; Java distinguishes them only by which consumer list they join) → 2 result symbols: row, has_item_row; the tick routes each catalog consumeItem row by its `optional` flag (projector → optional pass, dome → required pass). Removal follows `use_ready` with no extra gating (inherits the known driver-wide disabled-gap deviation). The N2194 advance (useProgress + wrap at useTime) is untouched. `_initial_frame` gains `"items": {}`. NO live intake fills `frame["items"]` yet (Separator precedent — the rows read the frame as-is, documented as a limit).

## Commits

Slice `a867f416` (worker-N2262, branch `slice/N2262-overdrive-projector-booster-items`, 5 files, +995/−27, đã push, remote tip verified by ls-remote). Integration cherry-pick `60f84bd4` on `integration/wave-booster-items-n2260-n2264` (base 22164673). No coordinator fix needed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 26/26, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status 3/4 + update_tile 3/4), the fails only their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 1856, launch 22:29 by coordinator lượt 7, done 22:47 +07): Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264). Run 1 (PID 25034, launch 22:09) was killed by VM restart #5 ~22:27 after ~17.8 min, no footer.

## SSOT / DEFERRED

SSOT single-slice +3/+1/+1/+2 → 11735/1710/1632/3055; audit stays 1336. DEFERRED 292 (293 − 2 resolved: booster item rows + useProgress consume() rows; + 1 new: OverdriveProjector frame items intake). Merged wave DEFERRED: 289 entries (DEFERRED-after-booster-items.py) — 293 − 8 resolved + 4 new, resolved by entry TEXT not number.

## Godot debt

`C07OverdriveProjectorBoosterItemsProof` — 6 keys: dome_row_folds_min_when_starved, dome_row_needs_both_stacks, dome_row_stops_power_when_starved, projector_row_folds_optional_when_absent, use_ready_removes_dome_stacks, use_ready_removes_projector_stack (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
