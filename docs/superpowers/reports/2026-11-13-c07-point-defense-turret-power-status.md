# Report — N2151: PointDefenseTurret power.status live read (segment) (C07)

Date: 2026-11-13. Batch: N2151 (single slice). Status: **DONE + PUSHED 2026-11-13 ~13:3x +07 (13:30 cron run). Targeted tests 4/4 OK, neighbours 54/54 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5701, failures=102, skipped=5, 0 errors — all 102 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The next `power.status` consumer family after the N2150 solid-pump slice: the PointDefenseTurret implementation — **segment** (consumePower 8f, size 2, range 180f, reload 8f, bulletDamage 30f, shootLength 5f, hasPower true). The ONLY PointDefenseTurret block in the game (Blocks.java:3835-3847). The catalog confirms implementation PointDefenseTurret + consumePower 8.0 (content_registry_blocks.json, properties consumePower 8.0 / consumesPower true / hasPower true / connectedPower true). PointDefenseTurret extends ReloadTurret, NOT Turret, so the turret driver (SourceTurretBuildState.gd:27-28) explicitly excludes it and no driver ticked it at all — it would rotate and reload as if power.status were 1.0. N2151 is the PointDefenseTurret family's live read — the same proven N2145/N2146/N2147/N2148/N2149/N2150 pure-row pattern, one new file over. Base ReloadTurret/Turret tick untouched — the PointDefense driver is separate, like BurstDrill vs base Drill and SolidPump vs mechanical Pump.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2151 does not touch it. N2151 supplies the missing pure power row + wires it into the driver.

Pure `SourcePointDefenseTurretBuildState.source_point_defense_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_point_defense_turret_tick_buildings_state(game, seconds)`: iterate placed PointDefenseTurret buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the point-defense edelta fold (PointDefenseTurret.java:81-82, `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());` with `return efficiency * delta();` in BuildingComp.java:1928) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd after the solid-pump tick.

Frame key (decided in RED): the driver uses its OWN family frame key `"source_point_defense_turret_building"` (the turret precedent — the generic turret frame `source_turret_building` stays untouched, segment never binds it). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list had NO point-defense key — so GREEN added `"source_point_defense_turret_building"` to that list (one line, SourcePlacedPowerGraphState.gd:140, same mechanism as the solid-pump key).

Scope decision (decided in RED): **the PointDefenseTurret implementation only — segment**. Documented limits in the pure function's comment, same discipline as N2148/N2149/N2150: (1) power-only first pass — segment has no other consumers; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — `PointDefenseBuild.shouldConsume()` (PointDefenseTurret.java:105-107, `return super.shouldConsume() && target != null;`) needs live bullet-target state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — retarget / rotation / reloadCounter / beam effects (PointDefenseTurret.java:62-103) wait for their own slice; the proof carries no progress keys, the edelta fold (PointDefenseTurret.java:81-82) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07PointDefenseTurretPowerStatusProof` (modeled on the N2150 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_POINT_DEFENSE_TURRET_POWER_STATUS_PROOF `:

- `segment_has_power_consumer`: catalog `segment` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place segment live, stamp `frame["power_status"] = 0.5`, call `source_point_defense_turret_tick_buildings_state` directly (as the N2147/N2148/N2149/N2150 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_point_defense_turret_power_status.py`: **4/4 OK in 16.7s** (main-thread re-run 4/4 OK in 13.6s) — registration (ledger N2151, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 10 exprs over ConsumePower.java + BuildingComp.java + PointDefenseTurret.java + Blocks.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment — the moveToward line on ONE comment line, the N2148 shootWarmup lesson — + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (main thread, ~12:30 +07): 4 tests in 1.189s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2151'`, evidence errors on the missing ledger entry, source-text errors on the missing `SourcePointDefenseTurretBuildState.gd`, proof returncode 1 (proof scene did not exist yet). 10/10 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11310/1601/1522/2835.
- Neighbours (Godot on PATH, sequential): **54/54 OK in 187.6s** (C07 power family N2142/N2145–N2150 + power-graph binding + factory/adjacent/unit-factory/turret live loops). No port-7777 collision this time.
- Godot proof: **GREEN ~12:45 +07** — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Port 7777 was free before the proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11312 / 1602 / 1523 / 2837** (registry `symbols` 11312, ledger `slices` 1602, contracts 1523, schemas 2837); audit stays 1335.
- Environment note: VM restarted ~13:00 +07 (uptime 1 min at 13:01, javalang wiped); javalang 0.13.0 reinstalled before the gate relaunch (pip install from repo root, as per the durability rule).

## Gate / suite

- Test modules standalone: N2151 4/4 (proof green, see above); neighbours 54/54.
- Full Python suite, inclusive gate with the N2151 module (log `tools/mindustry_godot_transpiler/full-suite-n2151-gate.log`, 211 modules): **FINISHED ~13:17 +07, VERIFIED clean except Godot in this run — Ran 5701 tests in 913.985s, FAILED (failures=102, skipped=5), 0 errors. All 102 failures verified Godot-absent: 102 `FAIL:` blocks, 0 `ERROR:` blocks; 101 plain `assertIsNotNone(godot)` + 1 hydration `assertIsNotNone(godot, 'Godot required for hydration proof')` (test_liquid_consumer_hydration); the N2151 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_point_defense_turret_power_status`).** Gate attempt 3 launched from the main thread (PID 1776, SID 1776, ~13:02 +07) with the proven backgrounded-`setsid`-`nohup` method; it finished on the third attempt (attempt 1 worker-launched PID 16626 died at session end ~12:51; attempt 2 main-thread PID 17040 died in the ~13:00 VM restart). The gate took 913.985s — back in the usual ~900–1150s band (N2150: 1075.7s). The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- TractorBeamTurret power (parallax) — own driver, own slice (N2152).
- PointDefenseTurret updateTile advance (retarget / rotation / reloadCounter / beam effects, PointDefenseTurret.java:62-103) — own slice.
- PointDefenseTurret shouldConsume gate (`return super.shouldConsume() && target != null;`, PointDefenseTurret.java:106) — needs live bullet-target state the tick does not track yet.
- SolidPump updateTile advance (warmup / pumpTime / lastPump / validTiles / boost, SolidPump.java:118-133) — own slice.
- SolidPump shouldConsume gate (`liquids.get(result) < liquidCapacity - 0.01f`, SolidPump.java:114) — needs liquid state the tick does not track yet.
- SolidPump water-attribute / validTiles / boost fraction rows (SolidPump.java:118, 137-147) — the folded efficiency is currently the min over the modeled (power-only) consumers.
- BurstDrill updateTile advance / shouldConsume gate / liquid rows / ore-dominant binding.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.

See `handoffs/2026-11-13-c07-point-defense-turret-power-status-handoff.md` for the full detail.
