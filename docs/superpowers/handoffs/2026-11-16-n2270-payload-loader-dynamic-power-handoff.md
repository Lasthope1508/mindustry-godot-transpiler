# N2270 PayloadLoader Dynamic Power Usage — Handoff

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 9/10 — wave power-launch-build, integration branch `integration/wave-power-launch-build-n2270-n2273`, base `3bca6665`).

## What this slice did

PayloadLoader dynamic power usage (loadPowerDynamic=true): per-tick power usage 0f (no payload), 2f base (no battery OR exporting), 42f (has battery AND not exporting). Pure `source_payload_loader_dynamic_power_usage_state` → `{usage, charging}`; frame key `power_usage` stamped each tick at fold, BEFORE the advance, OUTSIDE the enabled guard.

## Key facts for the next agent

- **ConsumePowerDynamic has NO `getUsage` method** — the graph queries `requestedPower(Building)` (ConsumePowerDynamic.java:24, `return usage.get(entity);` :25). The port graph does NOT read per-building usage (it reads the static catalog consPower) → the value is only stamped on the frame; graph wiring deferred (N2232 Unloader `last_output_power` precedent).
- `loadPowerDynamic` :27 (not :30); `maxPowerConsumption` :26 (not :29); `init()` :77-84 (not :79-84); `exporting` field :87 (not :95); handlePayload exporting=false :106 (not :118-121 — that cite is also stale in the N2231 docstring + DEFERRED, outside N2270 scope); exporting=true :171/:179/:195/:212; battery charge :200-214. `hasBattery()` :235-237; `shouldConsume()` :240-242. Def consumePower(2f) Blocks.java:6686.
- `has_battery` comes from the payload dict (`block_cons_power_buffered`, N2231 contract). `usage` reflects fold-time state; `exporting` is the previous tick's value (matching the Java graph querying usage live).
- SSOT +2/+1/+1/+2 → 11775/1720/1649/3090 (audit 1336). Exact-evidence 19/19. DEFERRED 290 (−1 resolved PayloadLoader dynamic power row + 1 new dynamic power graph wiring).

## Godot debt (this slice)

`C07PayloadLoaderDynamicPowerProof` — 6 keys: usage_base_when_exporting, usage_base_when_no_battery, usage_charging_when_battery_and_not_exporting, usage_reads_catalog_base_power, usage_stored_on_frame_each_tick, usage_zero_when_no_payload (+ `registry_valid` / `one_headquarter_per_ssot` / `matches`). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Targeted test: `tests.test_c07_payload_loader_dynamic_power`. Do NOT mark done until it passes there.
