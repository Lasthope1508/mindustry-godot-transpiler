# Handoff N2220 — SolidPump updateTile Advance

**Status: DONE** (coordinator lượt 4 — wave advances-1). Slice `bd8b7dc0` trên branch `slice/N2220-solid-pump-update-tile` (base `2b6e6a33`, đã push 16:19, remote tip bd8b7dc0). Integration `integration/wave-advances-1-n2219-n2223`: cherry-pick `5c84850b` + SSOT gộp `bde67d63` (11470/1664/1587/2965).

## What changed

- `SourceSolidPumpBuildState.gd`: frame keys warmup/pump_time/last_pump (+ valid_tiles/boost/attribute_env fraction inputs); pure `source_solid_pump_update_tile_advance_state(frame, ...)` → 5 result symbols; `pump_amount` is a parameter so N2224 Fracker can reuse with 0.25f; driver wiring after consumption, enabled-gated.
- New: `test_c07_solid_pump_update_tile.py`, `register_c07_solid_pump_update_tile.py`, `C07SolidPumpUpdateTileProof.gd/.tscn` (6 keys).

## Java ground truth

SolidPumpBuild.updateTile (SolidPump.java:**122–141** — scope said 121–141). fraction = max(validTiles + boost + attribute.env(), 0). onProximityUpdate :**150–159** (scope said 137–147). result = water, capacity 40f. SolidPumpBuild redeclares `warmup` (:90), shadowing PumpBuild.warmup.

## Tests

- Targeted post-register: 3/4 PASS, chỉ proof test fail `AssertionError: unexpectedly None` (Godot-absent).
- SSOT: +5/+1/+1/+2 → 11440/1660/1583/2957 (slice riêng), audit 1336, legacy 0. Exact exprs 44. DEFERRED 258 (258 − 2 + 2: advance + frame liquids intake removed — the advance IS the intake). Shard đổi: 4 production shards.

## Godot debt (chưa chạy — chờ agent Godot test)

- `C07SolidPumpUpdateTileProof` — 6 keys: max_pump_folds_fraction_efficiency, last_pump_rate_from_max_pump, warmup_approaches_one_when_pumping, pump_time_advances_with_warmup, no_pump_when_full, frame_defaults_zero.

## Deferred (không trong slice này)

- Live fraction fill (onProximityUpdate validTiles/boost), dumpLiquid(result), updateEffect chance. N2087 helper does not apply (floor liquid, not solid-tile attributes).
