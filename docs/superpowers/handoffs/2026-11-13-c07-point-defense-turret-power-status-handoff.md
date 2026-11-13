# Handoff — N2151: PointDefenseTurret power.status live read (segment) (C07)

Date: 2026-11-13. Batch: N2151 (single slice). Status: **DONE + PUSHED 2026-11-13 ~13:3x +07 (13:30 cron run). Targeted 4/4 OK, neighbours 54/54 OK, Godot proof GREEN (9 keys, matches:true). Full gate attempt 3 finished ~13:17: Ran 5701 in 913.985s, failures=102, skipped=5, 0 errors — all 102 Godot-absent asserts. SSOT 11312/1602/1523/2837, audit 1335. Slice commit b92a4ff + docs commit (see Commits), pushed to origin main. Next: TractorBeamTurret power (parallax) — own driver, own slice (N2152).**

## Scope

- Family: the PointDefenseTurret implementation — **segment** (consumePower 8f, size 2, range 180f, reload 8f, bulletDamage 30f, shootLength 5f, hasPower true). The ONLY PointDefenseTurret block in the game (Blocks.java:3835-3847). Catalog confirms implementation PointDefenseTurret + consumePower 8.0 (content_registry_blocks.json, properties consumePower 8.0 / consumesPower true / hasPower true / connectedPower true).
- Why: PointDefenseTurret extends ReloadTurret, NOT Turret, so segment is NOT a TurretBuild — the turret driver (SourceTurretBuildState.gd:27-28) explicitly excludes it and no driver ticks it at all, so it would rotate and reload as if power.status were 1.0. N2151 is the PointDefenseTurret family's live read — the same proven N2145/N2146/N2147/N2148/N2149/N2150 pure-row pattern, one new file over.
- Base ReloadTurret/Turret tick untouched — the PointDefense driver is separate, like BurstDrill vs base Drill and SolidPump vs mechanical Pump.

## Design (decided in RED)

- New file `godot-mindustry/src/game/SourcePointDefenseTurretBuildState.gd` (mirrors SourceSolidPumpBuildState.gd): pure `source_point_defense_turret_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_point_defense_turret_tick_buildings_state(game, seconds)` mirroring the solid-pump driver's shape — iterate placed PointDefenseTurret buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the point-defense edelta fold (PointDefenseTurret.java:81-82, BuildingComp.java:1928) follows power.status.
- Frame key (decided in RED): the driver uses its OWN family frame key `"source_point_defense_turret_building"` (the turret precedent — the generic turret frame `source_turret_building` stays untouched, segment never binds it). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list has NO point-defense key — so GREEN must add `"source_point_defense_turret_building"` to that list (one line, same mechanism as the solid-pump key).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call after the solid-pump tick, N2150 precedent).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), the edelta fold `return efficiency * delta();` (BuildingComp.java:1928) and `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());` (PointDefenseTurret.java:81) — **keep the moveToward line on ONE comment line** (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148/N2149/N2150): (1) power-only first pass — segment has no other consumers; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — `PointDefenseBuild.shouldConsume()` (PointDefenseTurret.java:105-107, `return super.shouldConsume() && target != null;`) needs live bullet-target state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — retarget / rotation / reloadCounter / beam effects (PointDefenseTurret.java:62-103) wait for their own slice; the proof carries no progress keys, the edelta fold (PointDefenseTurret.java:81-82) is what the efficiency keys prove.
- Proof scene (new, modeled on the N2150 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_POINT_DEFENSE_TURRET_POWER_STATUS_PROOF `, 6 keys: `segment_has_power_consumer` (catalog segment properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place segment live, stamp frame["power_status"] = 0.5, call `source_point_defense_turret_tick_buildings_state` directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (10, all verified verbatim at RED)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(8f);` (Blocks.java:3841)
- `return efficiency * delta();` (BuildingComp.java:1928)
- `rotation = Angles.moveToward(rotation, dest, rotateSpeed * edelta());` (PointDefenseTurret.java:81)
- `reloadCounter += edelta();` (PointDefenseTurret.java:82)
- `return super.shouldConsume() && target != null;` (PointDefenseTurret.java:106)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)

## RED

- RED run (main thread, ~12:30 +07): test module `tools/mindustry_godot_transpiler/tests/test_c07_point_defense_turret_power_status.py`, Ran 4 tests in 1.189s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2151', evidence ERROR KeyError 'N2151', source-text ERROR FileNotFoundError on `SourcePointDefenseTurretBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 10/10 exact exprs verified verbatim at RED (grepped in the Java sources during scoping). SSOT baseline 11310/1601/1522/2835, audit 1335 (unchanged from N2150 — main at 4d12bae).
- Register script written (not yet run): `tools/mindustry_godot_transpiler/register_c07_point_defense_turret_power_status.py` (modeled on the N2150 register script; N2151 + 2 symbols, SSOT +2/+1/+1/+2 expected).

## GREEN

- GREEN run (main thread, ~12:45 +07): register script run (SSOT 11310/1601/1522/2835 → **11312/1602/1523/2837**, audit 1335 — exactly +2/+1/+1/+2); new file `SourcePointDefenseTurretBuildState.gd` (pure row + driver, moveToward line on ONE comment line); `"source_point_defense_turret_building"` added to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140); driver wired into `SourceFactoryRuntimeState.simulate_factory` (preload + one call after the solid-pump tick); proof scene `C07PointDefenseTurretPowerStatusProof.gd/.tscn` (6 keys). Targeted **4/4 OK in 16.7s**; neighbours **54/54 OK in 187.6s** (C07 power family N2142/N2145–N2150 + power-graph binding + factory/adjacent/unit-factory/turret live loops). Godot proof GREEN (6 keys + registry keys, matches:true) — part of targeted test 4, on Godot 4.6.2-stable Linux. Port 7777 was FREE; no proof scene ran while a gate ran.

## Gate result

- Full gate attempt 1 (PID 16626, launched by the 12:45 cron worker ~12:50, mislabeled "main thread" in this handoff) **DIED at session end ~12:51 +07** — verified by main thread: PID gone, log stopped at 3,487 bytes, no footer. Same worker-launched-gate failure as N2146 PID 9699, N2147 PID 3427, N2149 PID 3798.
- Full gate attempt 2 (PID 17040, main thread ~12:53) **DIED in a VM restart ~13:00 +07** — verified by main thread at 13:01: PID gone, log stopped at 5,353 bytes (all dots, no footer), `uptime` 1 min, javalang wiped (import failed). javalang 0.13.0 reinstalled before relaunch (pip install from repo root, as per the durability rule).
- Full gate attempt 3 **FINISHED ~13:17 +07, VERIFIED clean except Godot by the 13:30 cron run — Ran 5701 tests in 913.985s, FAILED (failures=102, skipped=5), 0 errors. All 102 failures verified Godot-absent: 102 `FAIL:` blocks, 0 `ERROR:` blocks; 101 plain `assertIsNotNone(godot)` + 1 hydration `assertIsNotNone(godot, 'Godot required for hydration proof')` (test_liquid_consumer_hydration); the N2151 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_point_defense_turret_power_status`).** Launched from the MAIN THREAD ~13:02 +07 (PID 1776, SID 1776, own session) with the proven backgrounded-`setsid`-`nohup` method; finished on the third attempt (attempt 1 worker-launched PID 16626 died at session end; attempt 2 PID 17040 died in the ~13:00 VM restart). The gate took 913.985s — back in the usual ~900–1150s band (N2150: 1075.7s). The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Commits

- Slice commit **b92a4ff** — `C07: N2151 point-defense-turret power.status live read (pure power row + driver wiring; proof 6 keys)` (13 files, +823/−1).
- Docs commit **(this commit — hash filled in the handoff-hash commit)** — `Docs: N2151 report + design spec + handoff (gate clean except Godot)` (3 files: handoff + report + spec, Status Summary 1601→1602).
- Pushed 2026-11-13 ~13:3x +07 by the 13:30 cron run (push range filled in the handoff-hash commit).

## Deferred (NOT this slice)

- PointDefenseTurret updateTile advance, PointDefenseTurret shouldConsume gate (see register script DEFERRED).
- TractorBeamTurret power (parallax) — own driver, own slice (N2152).
- SolidPump updateTile advance / shouldConsume gate / water-attribute rows; BurstDrill updateTile advance / shouldConsume gate / liquid rows / ore-dominant binding.
- spawn_occupied / allow_update / moveOutPayload, net drone sync (see register script DEFERRED).
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Environment note: javalang 0.13.0 verified OK at RED (no VM restart since the 10:45 reinstall). Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; RED ran with PATH="$HOME/workspace/godot-bin:$PATH" so the proof test reached returncode 1 (scene missing) instead of failing on assertIsNotNone(godot).
