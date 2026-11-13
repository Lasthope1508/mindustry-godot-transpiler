# Report — N2150: SolidPump power.status live read (water-extractor) (C07)

Date: 2026-11-13. Batch: N2150 (single slice). Status: **DONE + PUSHED 2026-11-13 ~12:2x +07 (12:15 cron run). Targeted tests 4/4 OK, neighbours 36/36 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5697, failures=101, skipped=5, 0 errors — all 101 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The next `power.status` consumer family after the N2149 burst-drill slice: the SolidPump implementation — **water-extractor** (consumePower 1.5f, pumpAmount 0.11f, size 2, liquidCapacity 40f, rotateSpeed 1.4f, attribute water, envRequired groundWater, result water). The ONLY SolidPump block in the game (Blocks.java:2920-2930). The catalog confirms implementation SolidPump + consumePower 1.5 (content_registry_blocks.json, properties consumePower 1.5 / consumesPower true / hasPower true / connectedPower true). The pump runtime (SourcePumpRuntimeState.gd) ticks only the scenario mechanical pump at PUMP_POS with efficiency hardcoded 1.0 ("consumes no power", `source_pump_update_state`), so the water-extractor never ticks at all and would run as if power.status were 1.0. N2150 is the SolidPump family's live read — the same proven N2145/N2146/N2147/N2148/N2149 pure-row pattern, one new file over. Base Pump (mechanical-pump, no power) untouched — the SolidPump driver is separate, like BurstDrill vs base Drill.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2150 does not touch it. N2150 supplies the missing pure power row + wires it into the driver.

Pure `SourceSolidPumpBuildState.source_solid_pump_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_solid_pump_tick_buildings_state(game, seconds)`: iterate placed SolidPump buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the solid-pump speed fold (SolidPump.java:121, `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);`) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd after the burst-drill tick.

Frame key (decided in RED): the driver uses its OWN family frame key `"source_solid_pump_building"` (the turret precedent — the mechanical-pump per-cell frame `source_pump_building`, managed by SourcePumpRuntimeState with liquid_drop/amount/warmup/total_progress, stays untouched). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list had NO pump key — so GREEN added `"source_solid_pump_building"` to that list (one line, SourcePlacedPowerGraphState.gd:140, same mechanism as the turret key). BurstDrill needed no list change because it reuses the drill frame key (`source_drill_building`).

Scope decision (decided in RED): **the SolidPump implementation only — water-extractor**. Documented limits in the pure function's comment, same discipline as N2148/N2149: (1) power-only first pass — the water-attribute / validTiles / boost fraction (SolidPump.java:118, 137-147) is NOT a first-pass row; the folded efficiency is the min over the *modeled* consumers (power only); (2) no shouldConsume gate — `SolidPumpBuild.shouldConsume()` (SolidPump.java:113-115, `return liquids.get(result) < liquidCapacity - 0.01f;`) needs liquid state the tick does not track yet; the machinery runs with should_consume=true when enabled; (3) no updateTile advance — warmup / pumpTime / lastPump / validTiles / boost (SolidPump.java:118-133) waits for its own slice; the proof carries no progress keys, the speed fold (SolidPump.java:121) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07SolidPumpPowerStatusProof` (modeled on the N2149 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_SOLID_PUMP_POWER_STATUS_PROOF `:

- `water_extractor_has_power_consumer`: catalog `water-extractor` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place water-extractor live, stamp `frame["power_status"] = 0.5`, call `source_solid_pump_tick_buildings_state` directly (as the N2147/N2148/N2149 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_solid_pump_power_status.py`: **4/4 OK in 14.199s** (re-run 13.577s OK) — registration (ledger N2150, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 9 exprs over ConsumePower.java + BuildingComp.java + SolidPump.java + Blocks.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (main thread, ~11:4x +07): 4 tests in 1.268s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2150'`, evidence errors on the missing ledger entry, source-text errors on the missing `SourceSolidPumpBuildState.gd`, proof returncode 1 (proof scene did not exist yet). 9/9 exact exprs verified verbatim at RED (7 read in the Java sources during scoping + the 2 BuildingComp lines grepped: 1 hit each). SSOT baseline 11308/1600/1521/2833.
- Neighbours (Godot on PATH, sequential): first run 35/36 OK in 144.854s (1 failure); re-run 29/36 OK in 181.209s (7 failures) — **ALL failures are spurious port-7777 collisions, NOT an N2150 regression**: every failing proof printed `matches:true` with all keys true; the only failure line is `assertNotIn('ERROR:')` tripped by `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` (the other agent's Godot held the port intermittently during the run — the failing tests are the pump-binding + N2145/N2146/N2147/N2148 proof tests; N2142 + N2149 + pump-update passed). Non-proof tests (registration / evidence / source-text) passed in both runs. Third run (11:45 cron run, ~11:50, log `/tmp/n2150-neighbours.log`): **36/36 OK in 130.129s** — neighbours verified clean, no port collision that time. Targeted re-verified in the same run: 4/4 OK (first attempt hit the same transient port-7777 bind ERROR, retry OK).
- Godot proof: **GREEN ~11:5x +07** — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Port 7777 was free before the proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11310 / 1601 / 1522 / 2835** (registry `symbols` 11310, ledger `slices` 1601, contracts 1522, schemas 2835); audit stays 1335.
- Environment note: javalang was reinstalled 0.13.0 at the 10:45 run (VM restart wiped it); import verified OK before the register script runs.

## Gate / suite

- Test modules standalone: N2150 4/4 (proof green, see above); neighbours 36/36.
- Full Python suite, inclusive gate with the N2150 module (log `tools/mindustry_godot_transpiler/full-suite-n2150-gate.log`, 211 modules): **FINISHED ~12:13 +07, VERIFIED clean except Godot in this run — Ran 5697 tests in 1075.735s, FAILED (failures=101, skipped=5), 0 errors. All 101 failures verified Godot-absent: 101 `FAIL:` blocks, every one a `test_reference_graph_and_actual_*` Godot-proof test failing on `assertIsNotNone(godot)` / `unexpectedly None` (0 non-Godot-absent FAILs by block inspection; 0 `ERROR:` blocks); the N2150 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_solid_pump_power_status`).** Gate attempt 1 launched from the main thread (PID 10309, SID 10309, ~11:55 +07) with the proven backgrounded-`setsid`-`nohup` method; it finished on the FIRST attempt (no worker-launch death this time). The gate took 1075.7s — back in the usual ~900–1150s band (N2149: 1159.2s). The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- SolidPump updateTile advance (warmup / pumpTime / lastPump / validTiles / boost, SolidPump.java:118-133) — own slice.
- SolidPump shouldConsume gate (`liquids.get(result) < liquidCapacity - 0.01f`, SolidPump.java:114) — needs liquid state the tick does not track yet.
- SolidPump water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147) — the folded efficiency is currently the min over the modeled (power-only) consumers.
- BurstDrill updateTile advance / shouldConsume gate / liquid rows / ore-dominant binding.
- PointDefenseTurret power (segment) / TractorBeamTurret power (parallax) — own drivers, own slices.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.

See `handoffs/2026-11-13-c07-solid-pump-power-status-handoff.md` for the full detail.
