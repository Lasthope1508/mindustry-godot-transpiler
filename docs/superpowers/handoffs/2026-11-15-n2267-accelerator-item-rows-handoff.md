# N2267 Accelerator Item Rows (core-nucleus requirements) — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave dynamic/special, coordinator lượt 8).

## What this slice did

Launch-block item consumer rows + capacities in `SourceAcceleratorBuildState.gd` (interplanetary-accelerator def Blocks.java:6823-6832; `init()` Accelerator.java:84-92; `launchBlock = Blocks.coreNucleus` :40; core-nucleus requirements copper 8000 / lead 8000 / silicon 5000 / thorium 4000, Blocks.java:3154 → itemCapacity 25000; `getMaximumAccepted` :293-295; `acceptItem` :297-299; `ConsumeItems.efficiency` BINARY 1/0, ConsumeItems.java:51-53). 4 pure functions: row (BINARY via `inventory.item_count`) → `required_results`; capacities (`{capacities, item_capacity: 25000}`); getMaximumAccepted (capacity + 13000 core bonus when built); acceptItem (strict `<`). `_initial_frame` gains `"items": {}`. NO removal — consume() happens at launch (deferred launch slice).

## Key facts for the next agent

**Verified line numbers**: core-nucleus itemCapacity 13000 is Blocks.java:3158 (not :3159); `ItemModule.has` closes at :157. **The catalog has NO consumeItem for interplanetary-accelerator** (init-registered) — Java source is the def authority. **4 pure functions, not 3** (accept separate from max-accepted) → SSOT +10/+1/+4/+7, not the SCOPE-estimated +6/+1/+3/+6. The capacities function is no-arg so it carries a result schema only. Register: 31 exact exprs, all grep-verified verbatim. DEFERRED: 290 (289 − 1 resolved + 2 new: Accelerator frame items intake + launch consume() item removal). Slice commit `cbdce69a` (branch `slice/N2267-accelerator-item-rows`, đã push). Integration cherry-pick `92910a1d`.

## Godot debt (this slice)

`C07AcceleratorItemRowsProof` — 6 keys: item_row_binary_core_nucleus_stacks, item_row_zero_missing_thorium, capacities_sum_item_capacity_25000, max_accepted_adds_core_bonus_when_built, accept_item_below_max_only, live_tick_folds_item_row. Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
