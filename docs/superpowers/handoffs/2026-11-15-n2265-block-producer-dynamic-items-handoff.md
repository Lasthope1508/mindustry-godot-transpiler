# N2265 BlockProducer Dynamic Item Row (ConsumeItemDynamic over recipe requirements) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave dynamic/special, coordinator lượt 8).

## What this slice did

Dynamic item consumer row in `SourceConstructorBuildState.gd` (constructor + large-constructor, Blocks.java:6658-6680; `ConsumeItemDynamic.efficiency` BINARY 1/0, ConsumeItemDynamic.java:60-62; dynamic func BlockProducer.java:39-55: recipe requirements × `ceil(amount * buildCostMultiplier)`; `items.has(ItemStack[], float)` ItemModule.java:153-157). 3 pure functions: stacks (ceil), row (BINARY via `inventory.item_count`), trigger (removes `round(amount * multiplier)` per stack, clamped — tested pure, NOT wired live). Tick resolves recipe → catalog `properties.requirements`, reads `rules_state.get("buildCostMultiplier", 1.0)`, folds the row into `required_results`. `_initial_frame` gains `"items": {}`.

## Key facts for the next agent

**Verified line numbers**: ConsumeItemDynamic.trigger :53-57, efficiency :60-62; BlockProducer dynamic func :39-55; consume() call :116; `ItemModule.remove` :258-262, `has` closes :157; `Rules.buildCostMultiplier` default 1f (Rules.java:115). **Recipe shape**: `frame["recipe"]` is the dict fixture `{"block": <id>}` (N2161/N2216 precedent) — the driver accepts both shapes. **Catalog gap**: `tungsten-wall-large` has `requirements: null` → `[]` (row 1.0). **First no-contract pure function**: the stacks function returns `Array`, so it has schemas + symbol but NO API contract (`has_contract=False`). Register: 16 exact exprs, all grep-verified verbatim. DEFERRED: 290 (289 − 1 resolved + 2 new: trigger live wiring + Constructor frame items intake). **Caveat: the N2265 register was built on a stale 291-entry DEFERRED base (pre-booster-items) — its ledger snapshot is NOT the master; the merged file DEFERRED-after-dynamic-special.py (290) is.** Slice commit `81a94e9a` (branch `slice/N2265-block-producer-dynamic-items`, đã push). Integration cherry-pick `046fe357`.

## Godot debt (this slice)

`C07ConstructorDynamicItemRowProof` — 6 keys: dynamic_stacks_ceil_cost_multiplier, dynamic_row_binary_full_stacks, dynamic_row_zero_missing_stack, dynamic_row_one_empty_recipe, trigger_removes_rounded_amounts, live_tick_folds_dynamic_row. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
