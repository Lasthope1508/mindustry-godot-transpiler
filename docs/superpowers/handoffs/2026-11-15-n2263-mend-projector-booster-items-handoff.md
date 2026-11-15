# N2263 MendProjector Booster Items (mender silicon + mend-projector phaseFabric) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave booster items, coordinator lượt 7).

## What this slice did

Booster item rows in `SourceMendProjectorBuildState.gd` (mender silicon boost, Blocks.java:1929; mend-projector phaseFabric boost, :1941; `ConsumeItems.efficiency` binary 1/0, ConsumeItems.java:51-53; `items.has(ItemStack[], float)` ItemModule.java:153-158, check :154; booster `optional(true, true)` → optional pass BuildingComp.java:1980-1981). Pure `source_mend_projector_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count` over frame items; stacks explicit per def: mender `[{"item": "silicon", "amount": 1}]`, mend-projector `[{"item": "phase-fabric", "amount": 1}]`) → `optional_results`; the N2193 advance already reads `frame["optional_efficiency"]` for phaseHeat, untouched. `_initial_frame` gains `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: mender silicon boost Blocks.java:1929, mend-projector phaseFabric boost :1941; Mend timer-gated consume (useTime 400f, MendProjector.java:102-104) → DEFERRED (timer-infra). **The Mend timer-consume DEFERRED entry is #1 in the merged file (line 5), not #5 — it stays deferred.** Register: 21 exact exprs, all grep-verified verbatim. DEFERRED: 293 (293 − 1 resolved + 1 new: MendProjector frame items intake). NO live intake fills `frame["items"]` yet (Separator precedent); the timer-gated consume stays deferred. Slice commit `ac718a0a` (branch `slice/N2263-mend-projector-booster-items`, đã push). Integration cherry-pick `cf4e1633`.

## Godot debt (this slice)

`C07MendProjectorBoosterItemsProof` — 6 keys: booster_row_folds_optional_only, live_tick_folds_booster_row, mend_projector_row_binary_phase_fabric, mender_row_binary_silicon, optional_capped_by_min_efficiency, phase_heat_lerps_toward_optional. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
