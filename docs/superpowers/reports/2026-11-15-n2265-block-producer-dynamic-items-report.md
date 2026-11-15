# N2265 BlockProducer Dynamic Item Row (ConsumeItemDynamic over recipe requirements) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 8 — wave dynamic/special, integration branch `integration/wave-dynamic-special-n2265-n2269`, base `e07aac89`).

## Source

Defs: constructor (Blocks.java:6658-6667) + large-constructor (:6670-6680), same dynamic consumer. `ConsumeItemDynamic.efficiency` (ConsumeItemDynamic.java:60-62) is BINARY 1/0: `consumeTriggerValid() || items.has(dynamicStacks, multiplier)? 1f: 0f`; `trigger` (:53-57) removes `round(amount * multiplier)` per stack. Dynamic func (BlockProducer.java:39-55): recipe() != null → clone `block.requirements` with `ceil(amount * state.rules.buildCostMultiplier)`; null → `ItemStack.empty` (row = 1). `Rules.buildCostMultiplier = 1f` default (Rules.java:115). `items.has(ItemStack[], float)` (ItemModule.java:153-157): EVERY stack must have `round(amount * multiplier)`; empty array → true. `ItemModule.remove` clamps to held (:258-262). `shouldConsume() = super && recipe() != null` (:102-104, live since N2216). consume() only at progress completion (:116). **Scope corrections (grep-verified): trigger :53-57 (not :49-53), efficiency :60-62 (not :56-60), dynamic func :39-55 (not :39-58 — :58 is inside `icons()`), consume() call :116 only, `ItemModule.remove` :258-262, `has` closes :157.**

## Implementation

`SourceConstructorBuildState.gd`: 3 pure functions — `source_constructor_dynamic_item_stacks_state` (recipe requirements × buildCostMultiplier, `ceil` per amount; empty → `[]`), `source_constructor_dynamic_item_consumer_row_state` (BINARY 1.0/0.0 via `inventory.item_count` over frame items; stacks empty → 1.0), `source_constructor_dynamic_item_trigger_state` (removes `round(amount * multiplier)` per stack, clamped — tested pure, **NOT wired live**, consume() waits for the advance slice). Tick resolves the recipe id → catalog `properties.requirements` ([{amount, item}] kebab-case), reads `rules_state.get("buildCostMultiplier", 1.0)` (port rules_state has no such key yet — 1.0 default documented), folds the row into `required_results` (first pass, min; optional untouched). `_initial_frame` gains `"items": {}`. Recipe shape: family precedent (N2161/N2216 proofs) stores `frame["recipe"]` as the dict fixture `{"block": <id>}` — the driver accepts BOTH shapes. Catalog gap: `tungsten-wall-large` (a Constructor filter block) has `requirements: null` → treated as `[]` (row folds 1.0).

## Commits

Slice `81a94e9a` (worker-N2265, branch `slice/N2265-block-producer-dynamic-items`, 5 files, +942/−4, đã push, remote tip verified by ls-remote). Integration cherry-pick `046fe357` on `integration/wave-dynamic-special-n2265-n2269` (base e07aac89). No coordinator fix needed for this slice (the cross-proof seeding fix e5412ae9 seeds copper 1 in the N2161/N2216 proofs — the conveyor recipe fixture now folds the dynamic row).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 16/16, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, should_consume: Ran 8, 6 PASS), the fails all their Godot proof tests — 0 other failures. Payload shard test OK (20.6s). Full wave gate (PID 8064, launch 23:07 by coordinator lượt 8, done 23:27 +07): Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269).

## SSOT / DEFERRED

SSOT single-slice +4/+1/+2/+6 → 11753/1715/1640/3073; audit stays 1336. **First case of a pure function with NO API contract**: the stacks function returns `Array` and the contract validator only accepts `Dictionary`/`void` returns (register failed first, fixed with `has_contract=False`); its schemas + symbol are still registered. DEFERRED 290 (289 − 1 resolved + 2 new: trigger live wiring + Constructor frame items intake). Merged wave DEFERRED: 290 entries (DEFERRED-after-dynamic-special.py) — 289 − 6 resolved + 7 new, resolved by entry TEXT not number. **Caveat: the N2265 register was built on a stale 291-entry base (pre-booster-items); its ledger snapshot re-adds 5 booster-wave entries already resolved by lượt 7 and drops the 4 booster intake entries — the merged file uses only the genuine −1/+2 delta; do not use the N2265 ledger list as the master.**

## Godot debt

`C07ConstructorDynamicItemRowProof` — 6 keys: dynamic_stacks_ceil_cost_multiplier, dynamic_row_binary_full_stacks, dynamic_row_zero_missing_stack, dynamic_row_one_empty_recipe, trigger_removes_rounded_amounts, live_tick_folds_dynamic_row (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
