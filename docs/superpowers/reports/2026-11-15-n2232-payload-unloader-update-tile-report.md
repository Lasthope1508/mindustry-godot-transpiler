# N2232 PayloadUnloader updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-3, integration branch `integration/wave-advances-3-n2229-n2234`, base `ff82ab1d`).

## Source

- PayloadUnloaderBuild.updateTile (PayloadUnloader.java:50-110): `lastOutputPower = 0f` reset at tick start (:33/:51); shouldExport → instantDeconstruct clear or moveOut; moveIn → unload items (:62-75, NO acceptedAny logic — loop `while(!full())`) / liquids (:77-90) / battery (:92-106, unloaded = min(maxPowerUnload 80f * edelta, total); `lastOutputPower = unloaded` — **POWER PRODUCTION**, getPowerProduction :44-47); dumpLiquid + offloadSpeed 4 × dumpAccumulate (:108-109 — deferred).
- PayloadUnloader extends PayloadLoader (PayloadUnloader.java:8) — `rotate = true` is INHERITED, so moveIn's moveToward target is rotdeg() (verified at integration; the N2231 rotate correction applies here too).
- Constants: offloadSpeed 4, maxPowerUnload 80f (:9-11); loadTime 2f / itemsLoaded 8 / liquidsLoaded 40f inherited from PayloadLoader.

## Implementation

- `SourcePayloadUnloaderBuildState.gd`:
  - Pure `source_payload_unloader_update_tile_advance_state(frame, ...)` → 13 result symbols: should_export, moved_in, deconstructed, pay_vector, pay_rotation, items, items_unloaded, liquids, liquids_unloaded, payload, payload_moved, payload_dumped, last_output_power.
  - moveOut REUSES the ported helper `SourceBlockProducerMoveOutPayloadState.move_out_payload_state` via preload (N2224 precedent), including its `source_vec2_approach` for the moveIn center approach; rotation reuses `SourceMathState.source_angles_move_toward`.
  - `last_output_power` is a frame key (default 0.0, reset at tick start per Java :51); the advance returns the unloaded amount as `last_output_power` — the **power-production graph wiring** (getPowerProduction returning lastOutputPower, into the N2163 power driver) is DEFERRED (new DEFERRED row), not wired in this slice.
  - `_initial_frame` extended: `{"payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "last_output_power": 0.0}` (keeps `"payload": null` for N2209).

## Commits

- Slice `76ecc3b5` (worker-N2232 re-spawn after VM restart 4, branch `slice/N2232-payload-unloader-update-tile`, 5 files +1240/−7; đã push 17:43, remote tip 76ecc3b5). Worker handoff chưa tới lúc coordinator verify — coordinator verify trực tiếp từ git (commit + register + SSOT + targeted + proof keys từ file).
- Integration cherry-pick `195077bd`; SSOT gộp `b5129382` (wave advances-3): 11568/1675/1598/2987 (slice riêng +13/+1/+1/+2 → 11520/1670/1593/2977).

## Tests

- Targeted post-register: 3/4 PASS (registration, exact-evidence 86/86, row-state) + proof test FAIL đúng `AssertionError: unexpectedly None` — Godot-absent.
- Targeted wave (6 module): Ran 24, 18 PASS + 6 proof Godot-absent. Neighbours 12 module power+gate: Ran 48, 36 PASS + 12 proof Godot-absent, 0 error.
- Full gate wave advances-3: Ran 5993 in 1036.683s, failures=175, skipped=5, 0 errors — 175/175 Godot-absent (169 inherited + 6 new proof tests N2229–N2234).

## SSOT / DEFERRED

- SSOT slice riêng +13/+1/+1/+2 → 11520/1670/1593/2977; audit 1336, legacy 0. Payload shards đổi (`payload_slices` + `payload_api_contracts`).
- DEFERRED 261 (260 − 5 resolved: updateTile advance + battery-unload rows + shouldExport gate + power-production rows + load params + 6 new: timer cadence, dump rows, power-production graph wiring, movePayload/dumpPayload application, payload entity update + breakEffect presentation, live front query).
- DEFERRED gộp sau wave advances-3: 265 entries (260 − 14 resolved + 19 new).

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07PayloadUnloaderUpdateTileProof` — 7 keys: move_in_arrives_at_center, unload_items_on_timer_tick, unload_liquids_folds_edelta, battery_unloads_to_last_output_power, instant_deconstruct_clears_payload, move_out_pushes_payload, live_tick_advances_unloader_frame.
