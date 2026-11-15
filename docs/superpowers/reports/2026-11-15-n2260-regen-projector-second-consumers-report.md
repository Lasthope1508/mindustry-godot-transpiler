# N2260 RegenProjector Second Consumers (hydrogen 1f/60f required row + phaseFabric booster item row) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 7 — wave booster items, integration branch `integration/wave-booster-items-n2260-n2264`, base `22164673`).

## Source

RegenProjector def (Blocks.java:2016-2017): hydrogen 1f/60f REQUIRED + phaseFabric booster. `ConsumeLiquid.efficiency` :42-47 (ed = edelta × efficiencyScale, ed ≤ 1e-8 → 0, cap 1f); `update` :37-39. `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0: `consumeTriggerValid() || items.has(items, multiplier)? 1f: 0f`; `consumeTriggerValid()` base returns false (BuildingComp.java:764-766); `items.has(ItemStack[], float)` (ItemModule.java:153-158, check :154): EVERY stack must have `round(amount * multiplier)`; `consumeItem(item)` = ItemStack(item, 1) (Block.java:1167-1168). `ConsumeItems.trigger` (:44-48) removes `round(amount * multiplier)` per stack; `ItemModule.remove` clamps to held (:258-263). Booster = `optional(true, true)` (Consume.java:33-35) → optional pass (BuildingComp.java:1980-1981), cap by minEfficiency (:1986), zero when !update (:1992-1994); required folds in the first pass (:1969-1976). RegenProjector consume cadence: optionalTimer += edelta() * optionalEfficiency, >= optionalUseTime 480f (60f*8f) → consume() + reset, guard efficiency > 0 (RegenProjector.java:141-145); healAmount = lerp(1, optionalMultiplier=2f, optionalEfficiency) * healPercent (:147). **Scope corrections (verified by grep): the brief's "Fracker guard :139-144" is WRONG — the liquid-row guard is SourceFrackerBuildState.gd:221 (139-144 is the bind-frame function); sync :361 is correct. The scope doc's DEFERRED numbers are file LINE numbers, not entry indices: booster item row is idx 29, liquid row idx 30, updateTile live-fill idx 201.**

## Implementation

`SourceRegenProjectorBuildState.gd`: pure `source_regen_projector_liquid_consumer_row_state` (Fracker guard, ed ≤ 1e-8 → 0, cap 1f) → `required_results`; pure `source_regen_projector_item_consumer_row_state(frame, stacks, consume_trigger_valid, multiplier=1.0)` (BINARY 1.0/0.0 via `inventory.item_count` over frame items) → `optional_results` (was `[]`). The tick syncs `frame["liquids"]` from sprite meta before the fold (Fracker:361 precedent); direct hydrogen second-pass removal after `apply_update_consumption_state` (guard `update && efficiency > 0`, edelta from folded efficiency); when the N2228 advance reports `consumed=true`, removes 1 phaseFabric via `inventory.remove_item_state` (clamped to held). The advance is untouched. `_initial_frame` gains `"liquids": {}` + `"items": {}`. The catalog carries no `hasLiquids` for regen-projector, but `PortGame.record_placed_block` applies the liquid consumers (Java `ConsumeLiquidBase.apply` sets `hasLiquids`, ConsumeLiquidBase.java:17-19), so the live liquids store IS initialized — no defensive init needed. Doc limits (1) + (4) and advance scoping note (3) updated. NO live intake fills `frame["items"]` yet (Separator precedent — the row reads the frame as-is, documented as a limit).

## Commits

Slice `752a8b27` (worker-N2260, branch `slice/N2260-regen-projector-second-consumers`, 5 files, +1093/−22, đã push, remote tip verified by ls-remote). Integration cherry-pick `aa4d94f3` on `integration/wave-booster-items-n2260-n2264` (base 22164673). No coordinator fix needed.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 32/32, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status, should_consume, update_tile: all 3/4), the fails all their Godot proof tests — 0 other failures. Full wave gate run 2 (PID 1856, launch 22:29 by coordinator lượt 7, done 22:47 +07): Ran 6146 in 1091.013s, failures=213, skipped=5, 0 errors — 213/213 Godot-absent (208 inherited + 5 new proof tests N2260–N2264). Run 1 (PID 25034, launch 22:09) was killed by VM restart #5 ~22:27 after ~17.8 min, no footer.

## SSOT / DEFERRED

SSOT single-slice +4/+1/+2/+4 → 11736/1710/1633/3057; audit stays 1336. Shards touched: `defense_api_contracts.json`, `defense_slices.json`. DEFERRED 292 (293 − 2 resolved + 1 new: RegenProjector items live intake; updateTile live-fill entry trimmed — the consume() item-removal part is now wired). Merged wave DEFERRED: 289 entries (DEFERRED-after-booster-items.py) — 293 − 8 resolved + 4 new, resolved by entry TEXT not number.

## Godot debt

`C07RegenProjectorSecondConsumersProof` — 6 keys: hydrogen_row_folds_min_when_starved (0.01 held → 0.6), phase_fabric_row_folds_optional_when_absent (0.0), item_row_binary_one_when_present (1.0), optional_capped_by_min_efficiency (power 0.5 → efficiency 0.5, optional 0.5), live_tick_removes_hydrogen_when_running (10.0 → 10−1/60), consumed_tick_removes_phase_fabric (timer 479 + 1 tick → consumed, 2 → 1 held) (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
