# N2267 Accelerator Item Rows (core-nucleus requirements) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 8 — wave dynamic/special, integration branch `integration/wave-dynamic-special-n2265-n2269`, base `e07aac89`).

## Source

Def: interplanetary-accelerator (Blocks.java:6823-6832) — `consumePower(10f)` (:6829), size 7, `powerBufferRequirement = 1_000_000f` (:6826), `buildCostMultiplier = 0.5f` (:6830). `init()` (Accelerator.java:84-92): `itemCapacity = 0`, `capacities[item.id] = stack.amount` per stack of `launchBlock.requirements`, `itemCapacity += stack.amount`, `consumeItems(launchBlock.requirements)`. `launchBlock = Blocks.coreNucleus` (class default :40; the def does NOT override). Core-nucleus requirements (Blocks.java:3154): copper 8000, lead 8000, silicon 5000, thorium 4000 → **itemCapacity 25000**. `getMaximumAccepted(item) = capacities[item.id] + (isCoreBuilt() ? launchBlock.itemCapacity : 0)` (:293-295); core-nucleus itemCapacity 13000 (Blocks.java:3158). `acceptItem = items.get(item) < getMaximumAccepted(item)` (:297-299). `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0; `items.has(ItemStack[], float)` (ItemModule.java:153-157). The catalog has NO consumeItem for interplanetary-accelerator (init-registered) → Java source is the def authority. **Scope corrections (grep-verified): core-nucleus itemCapacity 13000 is Blocks.java:3158 (not :3159); `ItemModule.has` closes at :157.**

## Implementation

`SourceAcceleratorBuildState.gd`: 4 pure functions — `source_accelerator_item_consumer_row_state(frame, stacks)` (BINARY 1.0/0.0 via `inventory.item_count`, full 4 stacks → 1.0) → `required_results` (first pass); `source_accelerator_capacities_state()` → `{capacities: {copper 8000, lead 8000, silicon 5000, thorium 4000}, item_capacity: 25000}` (sum computed in-loop, mirroring `itemCapacity += stack.amount`); `source_accelerator_get_maximum_accepted_state(item, is_core_built)` → `{maximum_accepted, capacity, core_bonus}` (13000 bonus only when built; unknown item capacity 0); `source_accelerator_accept_item_state(item, held, is_core_built)` → `{accept, held, maximum_accepted}` (strict `<`; held == max rejects). `_initial_frame` gains `"items": {}`. **NO removal** — consume() happens at launch (:258-291) → deferred launch slice. Launch + battery gate untouched. The capacities function is no-arg so it carries a result schema only (the schema validator requires non-empty keys; 197 result-only schemas already exist in the catalog).

## Commits

Slice `cbdce69a` (worker-N2267, branch `slice/N2267-accelerator-item-rows`, 5 files, +1122/−4, đã push, remote tip verified by ls-remote). Integration cherry-pick `92910a1d` on `integration/wave-dynamic-special-n2265-n2269` (base e07aac89). The cross-proof seeding fix e5412ae9 seeds the full 4 stacks in the N2183/N2191 proofs — the required row folds 0.0 on a fresh accelerator, so their live-tick keys would read 0 without the seed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 31/31, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, update_tile: 6/8 PASS), the fails both their Godot proof tests — 0 other failures. Full wave gate (PID 8064, launch 23:07 by coordinator lượt 8, done 23:27 +07): Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269).

## SSOT / DEFERRED

SSOT single-slice +10/+1/+4/+7 → 11759/1715/1642/3074; audit stays 1336. **Differs from the SCOPE estimate (+6/+1/+3/+6)**: the brief specifies 4 pure functions, not 3 (accept separate from max-accepted), giving 10 symbols / 4 contracts / 7 schemas. No shard changes (slice java_source is Accelerator.java, so `consumer_slices` doesn't select it). DEFERRED 290 (289 − 1 resolved + 2 new: Accelerator frame items intake + launch consume() item removal). Merged wave DEFERRED: 290 entries (DEFERRED-after-dynamic-special.py) — 289 − 6 resolved + 7 new, resolved by entry TEXT not number.

## Godot debt

`C07AcceleratorItemRowsProof` — 6 keys: item_row_binary_core_nucleus_stacks, item_row_zero_missing_thorium, capacities_sum_item_capacity_25000, max_accepted_adds_core_bonus_when_built, accept_item_below_max_only, live_tick_folds_item_row (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
