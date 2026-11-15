# N2220 SolidPump updateTile Advance — Report

**Status: DONE, gate clean except Godot-absent failures** (coordinator lượt 4 — wave advances-1, integration branch `integration/wave-advances-1-n2219-n2223`, base `2b6e6a33`).

## Source

- SolidPumpBuild.updateTile (SolidPump.java:**122–141** — worker corrected the scope cite 121–141 by grep): liquidDrop = result; fraction = max(validTiles + boost + (attribute == null ? 0 : attribute.env()), 0); if efficiency > 0 && typeLiquid() < liquidCapacity - 0.001f: maxPump = min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency); liquids.add(result, maxPump); lastPump = maxPump / Time.delta; warmup lerpDelta → 1f 0.02f; updateEffect chance deferred — presentation; else warmup → 0, lastPump = 0; pumpTime += warmup * edelta(); dumpLiquid(result) deferred.
- onProximityUpdate (SolidPump.java:**150–159** — scope said 137–147, corrected by grep): boost = sumAttribute(attribute)/size/size; validTiles from canPump scan over linked tiles.
- result = water (SolidPump.java:22), capacity 40f def constant (Blocks.java:2925), baseEfficiency 1f (:26). SolidPumpBuild redeclares `warmup` (SolidPump.java:90), shadowing PumpBuild.warmup (Pump.java:111) — noted in code; frame warmup is the SolidPumpBuild one.
- BuildingComp.java:2274/2276–2278 — updateConsumption runs BEFORE updateTile.

## Implementation

- `SourceSolidPumpBuildState.gd`:
  - Frame keys: warmup, pump_time, last_pump (+ valid_tiles, boost, attribute_env as explicit fraction inputs, default 0f).
  - Pure `source_solid_pump_update_tile_advance_state(frame, source_delta, time_scale, result_liquid_id, liquid_capacity, pump_amount)` → 5 result symbols: warmup, pump_time, last_pump, max_pump, fraction.
  - `lastPump = maxPump / Time.delta` on raw delta; `pumpTime += warmup * edelta()` with the NEW warmup. `liquids.add` via shared `SourceLiquidModuleState.source_add_state`.
  - `pump_amount` is a parameter (not a const) so N2224 Fracker can reuse the function with 0.25f (Blocks.java:2969; Fracker.java:37 `super.updateTile()`).
  - Driver wires after consumption, only when enabled, with `game_source_delta` + live `time_scale`; `@warning_ignore` removed since `seconds` is now used.
  - N2087 proximity helper checked: does NOT apply (scans floor liquidDrop/liquidMultiplier, not solid-tile attributes). Dump: routing gate exists but no solid-pump driver wires the transfer (only the scenario pump does).

## Commits

- Slice `bd8b7dc0` (worker-N2220, branch `slice/N2220-solid-pump-update-tile`, 5 files +965/−20; đã push 16:19, remote tip bd8b7dc0).
- Integration cherry-pick `5c84850b`; SSOT gộp `bde67d63` (wave advances-1): 11470/1664/1587/2965 (slice riêng +5/+1/+1/+2 → 11440/1660/1583/2957).

## Tests

- RED confirmed first (KeyError 'N2220' ×2, state assertIn fail, proof Godot-absent).
- Post-register: 3/4 PASS + proof FAIL đúng `AssertionError: unexpectedly None` (Godot-absent; `which godot` rc=1, không chạy Godot).
- SSOT: register exit 0, **+5/+1/+1/+2 → 11440/1660/1583/2957; audit totalSourceFunctions 1336, legacy 0**.
- **Exact exprs: 44**, tất cả verify verbatim trong upstream (slice sources incl. Pump.java).
- **DEFERRED: 258 (258 − 2 + 2)** — REMOVE entry "SolidPump updateTile advance (…)" AND "SolidPump frame liquids intake (…)" (the advance IS the intake, so that N2206 entry's premise is now false — coordinator accepted); ADD 2 entries: live fraction fill (onProximityUpdate validTiles/boost, SolidPump.java:150-159; attribute env(), Attribute.java:31-34) + dumpLiquid + updateEffect (dumpLiquid(result), SolidPump.java:140; updateEffect chance, SolidPump.java:131-132). The older "water-attribute / validTiles / boost fraction rows" entry is kept (its live-fill aspect is still genuinely deferred).
- **Shard đổi: 4 production shards** (production_api_contracts 50→51, production_slices 56→57, production_state_schema 52→54, production_symbols 464→469) + 4 file SSOT chính. Audit report + module manifest unchanged.
- Same-file family sanity: N2150 + N2206 modules 6/8 PASS, only their 2 pre-existing Godot-absent proof failures — no regression.

## Godot proof (debt — chưa chạy, chờ agent Godot test)

- `C07SolidPumpUpdateTileProof` — 6 keys: max_pump_folds_fraction_efficiency, last_pump_rate_from_max_pump, warmup_approaches_one_when_pumping, pump_time_advances_with_warmup, no_pump_when_full, frame_defaults_zero. Values hand-computed from Java (e.g. 0.11 pumped at fraction 2.0/efficiency 0.5; 0.05 capacity clamp; warmup 0.02/tick, 1−0.98^60 ≈ 0.703 after 60 ticks; pumpTime 0.255 / 0.51 at timeScale 1/2 with warmup 0.51 in both). Ghi nợ trong GOAL.md §5 + handoff + STATUS.md.
