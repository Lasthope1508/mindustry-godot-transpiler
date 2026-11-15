# N2270 PayloadLoader Dynamic Power Usage — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## Source

`loadPowerDynamic = true` (PayloadLoader.java:27); `maxPowerConsumption = 40f` (:26). `init()` (:77-84) registers the dynamic consumer with the lambda (:80): `consumePowerDynamic(basePowerUse, (PayloadLoaderBuild loader) -> loader.shouldConsume() ? (loader.hasBattery() && !loader.exporting ? maxPowerConsumption + basePowerUse : basePowerUse) : 0f);`. `basePowerUse = consPower.usage` = 2f (PayloadLoader.java:79, from the def `consumePower(2f)`, Blocks.java:6686). `hasBattery()` (:235-237): `payload != null && payload.block().consPower != null && payload.block().consPower.buffered`. `shouldConsume()` (:240-242): `payload != null`. `exporting` field (:87), set false in handlePayload (:106), set true in updateTile when load fails/full (:171/:179/:195/:212). Battery charge in updateTile (:200-214). ConsumePowerDynamic has NO `getUsage` method — the graph queries `requestedPower(Building)` (ConsumePowerDynamic.java:24, `return usage.get(entity);` :25). **Scope corrections (grep-verified): loadPowerDynamic :27 (not :30); maxPowerConsumption :26 (not :29); init() :77-84 (not :79-84); exporting field :87 (not :95); handlePayload exporting=false :106 (not :118-121 — that cite is also stale in the N2231 docstring + DEFERRED, outside N2270 scope); exporting=true :171/:179/:195/:212 (not :177/:185/:193/:208); battery charge :200-214 (not :199-212).**

## Implementation

`SourcePayloadLoaderBuildState.gd`: pure `source_payload_loader_dynamic_power_usage_state` → `{usage, charging}` (!shouldConsume → 0f; hasBattery && !exporting → 42f; else 2f). The driver computes/stores frame key `power_usage` every tick at fold time, BEFORE the advance (usage reflects fold-time state; `exporting` is the previous tick's value, matching the Java graph querying usage live), OUTSIDE the enabled guard. `has_battery` comes from the payload dict (`block_cons_power_buffered`, N2231 contract). The port power graph does NOT read per-building usage (it reads the static catalog consPower; `requested_power_state` takes usage as a param from the graph computation) → the value is only stamped on the frame; graph wiring deferred (N2232 Unloader `last_output_power` precedent).

## Commits

Slice `5a11de4e` (worker-N2270, branch `slice/N2270-payload-loader-dynamic-power`, 5 files, +742/−3, đã push, remote tip verified by ls-remote). Integration cherry-pick `69816678` on `integration/wave-power-launch-build-n2270-n2273` (base 3bca6665). No coordinator fix needed for this slice.

## Tests

Targeted post-register: 3/4 PASS (registration, exact-evidence 19/19, row-state) + proof test FAIL exactly `AssertionError: unexpectedly None` — Godot-absent. Siblings (9/12 PASS), the fails all their Godot proof tests — 0 other failures. Full wave gate (PID 14057, launch 23:50 by coordinator lượt 9, done 00:11 +07 16/11): Ran 6182 in 1189.124s, failures=222, skipped=5, 0 errors — 222/222 Godot-absent (218 inherited + 4 new proof tests N2270–N2273).

## SSOT / DEFERRED

SSOT single-slice +2/+1/+1/+2 → 11775/1720/1649/3090; audit stays 1336. DEFERRED 290 (290 − 1 resolved: PayloadLoader dynamic power row + 1 new: dynamic power graph wiring). Merged wave DEFERRED: 290 entries (DEFERRED-after-power-launch-build.py) — 290 − 5 resolved/removed + 5 new, resolved by entry TEXT not number.

## Godot debt

`C07PayloadLoaderDynamicPowerProof` — 6 keys: usage_base_when_exporting, usage_base_when_no_battery, usage_charging_when_battery_and_not_exporting, usage_reads_catalog_base_power, usage_stored_on_frame_each_tick, usage_zero_when_no_payload (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
