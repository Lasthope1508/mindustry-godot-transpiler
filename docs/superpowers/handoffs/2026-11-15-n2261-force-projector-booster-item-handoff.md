# N2261 ForceProjector Booster Item (phaseFabric, optional fold beside coolant) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave booster items, coordinator lượt 7).

## What this slice did

PhaseFabric booster item row in `SourceForceProjectorBuildState.gd` (Blocks.java:1974; `ConsumeItems.efficiency` binary 1/0, ConsumeItems.java:51-53; `items.has(ItemStack[], float)` ItemModule.java:153-158, check :154; booster `optional(true, true)` → optional pass BuildingComp.java:1980-1981). Pure `source_force_projector_item_consumer_row_state` → `optional_results`, appended beside the N2258 coolant row. Live inputs go via frame-stamp + advance frame-fallback (the N2258 coolant precedent) instead of changing the advance call site — the N2235 sibling test pins the exact call string. `_initial_frame` gains `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: phaseFabric boost Blocks.java:1974; phaseValid = itemConsumer.efficiency > 0 (ForceProjector.java:207), phaseHeat lerps toward num(phaseValid) (:209), timer-gated consume with phaseUseTime 350f (:32, :211-213) → DEFERRED (timer-infra); `itemConsumer` and `coolantConsumer` declared together on :54. **phaseUseTime = 350f is at :32, not :33.** **The optional pass is BuildingComp.java:1980-1981 (loop+body; :1979 is the `//same for optionals` comment).** **phaseHeat reads itemConsumer.efficiency DIRECTLY, not optionalEfficiency** — but the row still folds into the optional pass for Java faithfulness. **The N2235 sibling test pins the exact advance call string** — ForceProjector live inputs must go via frame-stamp + advance frame-fallback, not a changed call site. Register: 20 exact exprs, all grep-verified verbatim. DEFERRED: 293 (293 − 1 resolved + 1 new: ForceProjector live items intake). NO live intake fills `frame["items"]` yet (Separator precedent); the timer-gated consume stays deferred. Slice commit `073ecde1` (branch `slice/N2261-force-projector-booster-item`, đã push). Integration cherry-pick `b364beea`.

## Godot debt (this slice)

`C07ForceProjectorBoosterItemProof` — 6 keys: item_row_binary_one_when_present, item_row_zero_when_absent, live_tick_folds_item_row, optional_folds_min_of_coolant_and_item, phase_heat_lerps_toward_phase_valid, phase_valid_follows_item_row. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
