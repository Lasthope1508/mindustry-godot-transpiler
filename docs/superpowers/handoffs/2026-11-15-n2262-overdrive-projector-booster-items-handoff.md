# N2262 OverdriveProjector Booster Items (projector phaseFabric optional + dome phaseFabric/silicon required) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave booster items, coordinator lượt 7).

## What this slice did

Booster item rows in `SourceOverdriveProjectorBuildState.gd` (overdrive-projector phaseFabric boost, Blocks.java:1948; overdrive-dome `consumeItems(phaseFabric 1, silicon 1)` REQUIRED, :1961, hasBoost=false, useTime 300f; `ConsumeItems.efficiency` binary 1/0, ConsumeItems.java:51-53; booster `optional(true, true)` → optional pass BuildingComp.java:1980-1981; required folds in the first pass :1969-1976, result 0 → shouldConsumePower=false :1972-1973). ONE pure `source_overdrive_projector_item_consumer_row_state` serves both rows (the efficiency formula is identical; Java distinguishes them only by which consumer list they join); the tick routes each catalog consumeItem row by its `optional` flag (projector → optional pass, dome → required pass). Removal follows `use_ready` with no extra gating. The N2194 advance (useProgress + wrap at useTime) is untouched. `_initial_frame` gains `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: useProgress += delta() when efficiency > 0; >= useTime (400f default, dome 300f) → consume() + %= useTime (OverdriveProjector.java:114-120); phaseHeat lerps toward optionalEfficiency when hasBoost (:102-104). **`consume()` is at :118, not :119 (:119 is `useProgress %= useTime;`).** **Scope doc DEFERRED numbers are file LINE numbers, not entry indices** (Overdrive entries are lines 44 and 242) — resolve DEFERRED by entry TEXT. Removal follows `use_ready` with no extra gating (inherits the known driver-wide disabled-gap deviation). Register: 26 exact exprs, all grep-verified verbatim. DEFERRED: 292 (293 − 2 resolved: booster item rows + useProgress consume() rows; + 1 new: OverdriveProjector frame items intake). NO live intake fills `frame["items"]` yet (Separator precedent). Slice commit `a867f416` (branch `slice/N2262-overdrive-projector-booster-items`, đã push). Integration cherry-pick `60f84bd4`.

## Godot debt (this slice)

`C07OverdriveProjectorBoosterItemsProof` — 6 keys: dome_row_folds_min_when_starved, dome_row_needs_both_stacks, dome_row_stops_power_when_starved, projector_row_folds_optional_when_absent, use_ready_removes_dome_stacks, use_ready_removes_projector_stack. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
