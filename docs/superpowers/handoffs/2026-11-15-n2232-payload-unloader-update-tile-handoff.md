# N2232 PayloadUnloader updateTile Advance — Handoff

**Status: DONE, gate clean except Godot-absent failures** (wave advances-3, coordinator lượt 4).

## What this slice did

- PayloadUnloader shouldExport/instantDeconstruct/moveIn/moveOut/unload items+liquids/battery as a pure advance in `SourcePayloadUnloaderBuildState.gd` (PayloadUnloader.java:50-110). moveOut REUSES the ported helper `SourceBlockProducerMoveOutPayloadState.move_out_payload_state` via preload (N2224 precedent).
- 13 result symbols; `last_output_power` is a frame key (default 0.0, reset at tick start per Java :51) AND a pure result symbol.

## Key facts for the next agent

- **lastOutputPower is POWER PRODUCTION** (getPowerProduction :44-47) — but the graph wiring into the N2163 power driver is DEFERRED in this slice (new DEFERRED row "power-production graph wiring"), NOT wired here.
- PayloadUnloader extends PayloadLoader → `rotate = true` inherited → moveIn target is rotdeg() (N2231 rotate correction applies).
- Unload items loop has NO acceptedAny logic — `while(!full())` (PayloadUnloader.java:62-75), unlike the Loader's load loop.
- Register: 86 exact exprs, 0 missing. DEFERRED: 261 (260 − 5 resolved: advance + battery-unload + shouldExport gate + power-production + load params + 6 new: timer cadence, dump rows, power-production graph wiring, movePayload/dumpPayload application, payload entity update + breakEffect, live front query).
- Slice commit `76ecc3b5` (branch `slice/N2232-payload-unloader-update-tile`, đã push 17:43); integration cherry-pick `195077bd`; SSOT gộp `b5129382` (11568/1675/1598/2987).
- Worker handoff never arrived at verification time — coordinator verified directly from git (commit + register exit 0 + SSOT + targeted 3/4 + proof keys from file).

## Godot debt (this slice)

- `C07PayloadUnloaderUpdateTileProof` — 7 keys (6 scope + live_tick_advances_unloader_frame). Proof test fails `AssertionError: unexpectedly None` — run on Godot by the agent the user assigns. Do NOT mark done until it passes there.
