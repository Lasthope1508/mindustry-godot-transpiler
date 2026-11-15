# N2249 UnitCargoLoader liquid consumer row — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave second-consumers-1, coordinator lượt 5).

## What this slice did

- UnitCargoLoader required ConsumeLiquid row (nitrogen 10f/60f, Blocks.java:2279) as a pure row in `SourceUnitCargoLoaderBuildState.gd` (ConsumeLiquid.efficiency, ConsumeLiquid.java:42-47), folded into the first pass alongside the power row, with the second-pass removal (ConsumeLiquid.java:37-39) wired as a direct removal after apply_update_consumption_state.
- 2 result symbols. Folded efficiency is now the min over power + liquid; a starved liquid row stops power draw (shared fold, is_power false).

## Key facts for the next agent

- **Second-pass removal is DIRECT, not the updates-actor pattern**: the AdjacentFactory precedent (SourceAdjacentFactoryBuildState.gd:382) dispatches through RuntimeConsumer actors this driver doesn't have; the direct removal uses the same guard (`update && efficiency > 0`, BuildingComp.java:1999) with edelta from the FOLDED efficiency. Pattern reference for N2250–N2255.
- **Do NOT register a family row slice under ConsumeLiquid.java**: the consumer shards require a generated_owner on every mirrored slice and the shard build crashes with `KeyError: 'generated_owner'` (verified this slice). Family precedent stands: slice java_source is the block file; symbols still cite ConsumeLiquid.java.
- Cite corrections: ConsumeLiquid.update :37-39 (not :40-43), efficiency :42-47 (not :45-51).
- Register: 25 exact exprs, 0 missing. DEFERRED: 294 (294 − 1 + 1 new: liquid consumer build/display rows). **NO shard changes**.
- Slice commit on branch `slice/N2249-unit-cargo-loader-liquid-row`, đã push (hash điền khi tích hợp); SSOT slice riêng +2/+1/+1/+2 → 11708/1699/1621/3033.

## Godot debt (this slice)

- `C07UnitCargoLoaderLiquidRowProof` — 6 keys (row_folds_below_one_when_starved, row_caps_at_one_when_full, row_zeroes_when_edelta_zero, row_zeroes_without_liquid, live_tick_folds_liquid_row, live_tick_removes_liquid_when_running). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
