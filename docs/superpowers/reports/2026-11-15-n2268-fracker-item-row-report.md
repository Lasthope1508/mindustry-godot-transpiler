# N2268 Fracker Sand Item Row (consumeItem sand) — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 8 — wave dynamic/special, integration branch `integration/wave-dynamic-special-n2265-n2269`, base `e07aac89`).

## Source

Def: fracker (Blocks.java:2965-2978) — `consumeItem(Items.sand)` (:2976), `consumePower(3f)` (:2977), `consumeLiquid(Liquids.water, 0.15f)` (:2978), `itemUseTime = 60f` (:2974; class default 100f, Fracker.java:8). `ConsumeItems.efficiency` (ConsumeItems.java:51-53) is BINARY 1/0; `consumeTriggerValid` base false (BuildingComp.java:764-766); `items.has(ItemStack[], float)` (ItemModule.java:153-158). The row is REQUIRED (non-optional) → first pass, min + shouldConsumePower (BuildingComp.java:1969-1976, :1972-1973). **Scope corrections (grep-verified): the catalog DOES carry consumeItem for fracker** — `content_registry.json` oil-extractor has `consumeItem: [{amount: 1, item: "sand"}]` (the SCOPE said "no consumeItem" — wrong); the driver reads stacks from the catalog (WallCrafter precedent), and the existing `SOURCE_FRACKER_CONSUME_ITEM` def constant stays for the N2224 advance removal only. `ItemModule.has` is :153-158. GDScript guard :221 is the N2255 liquid-row guard; the N2207 gate guard is at :151; sync :361 verified correct. FrackerBuild/SolidPumpBuild do NOT override `consumeTriggerValid` (only ConsumeGeneratorBuild does, :152) — verified by repo-wide grep.

## Implementation

`SourceFrackerBuildState.gd`: pure `source_fracker_item_consumer_row_state(frame, has_item_consumer, stacks, multiplier=1.0)` (BINARY 1.0/0.0 via `inventory.item_count` over frame items; stacks `[{"item": "sand", "amount": 1}]`) → `required_results` (after the liquid row, before the fold). **NO removal, advance untouched** — the only sand removal stays the N2224 advance (`remove_item_state` count in the driver still exactly 1); the proof re-pins the N2224 consume numbers (3→2 sand, accumulator →1.0). No `item_valid` (Fracker has no itemValid read; that belongs to WallCrafter only). Documented limits (1) updated: sand row live, no live intake yet (DEFERRED stays), advance removal live since N2224.

## Commits

Slice `47f89c86` (worker-N2268, branch `slice/N2268-fracker-item-row`, 5 files, +958/−13, đã push, remote tip verified by ls-remote). Integration cherry-pick `afc6304c` on `integration/wave-dynamic-special-n2265-n2269` (base e07aac89). The cross-proof seeding fix e5412ae9 seeds sand 1 in the N2153/N2207/N2255 proofs (both extractors in the should-consume/liquid proofs — B needs the seed so its 0.0 isolates the gate/liquid row, not the starved sand row).

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 18/18, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (power_status N2153, should_consume N2207, update_tile N2224, liquid_row N2255: Ran 16, 12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate (PID 8064, launch 23:07 by coordinator lượt 8, done 23:27 +07): Ran 6166 in 1159.193s, failures=218, skipped=5, 0 errors — 218/218 Godot-absent (213 inherited + 5 new proof tests N2265–N2269).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11751/1715/1639/3069, exactly as expected; audit stays 1336. 2 new symbols (`..._item_consumer_row_state_result.row`, `.has_item_row`), 1 contract, 2 schemas (input+result). Changed: 4 canonical SSOT files + all 4 production shards. Ledger java_source is Fracker.java (family pattern, GOTCHA avoided). DEFERRED 288 (289 − 1 resolved; the "Fracker item intake" entry stays with its cross-ref updated to the live N2268 row per the N2255 precedent; no new deferral). Merged wave DEFERRED: 290 entries (DEFERRED-after-dynamic-special.py) — 289 − 6 resolved + 7 new, resolved by entry TEXT not number.

## Godot debt

`C07FrackerItemRowProof` — 6 keys: item_row_binary_sand, item_row_zero_no_sand, item_row_folds_required_min, sand_row_blocks_power_when_starved, advance_removal_unchanged, live_tick_folds_sand_row (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
