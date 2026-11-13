# Handoff — N2150: SolidPump power.status live read (water-extractor) (C07)

Date: 2026-11-13. Batch: N2150 (single slice). Status: **DONE + PUSHED 2026-11-13 ~12:2x +07 (12:15 cron run). Targeted 4/4 OK, neighbours 36/36 OK, Godot proof GREEN (9 keys, matches:true). Full gate finished ~12:13: Ran 5697 in 1075.735s, failures=101, skipped=5, 0 errors — all 101 Godot-absent asserts. SSOT 11310/1601/1522/2835, audit 1335. Slice commit 765c2f3 + docs commit 6f6ad13, pushed to origin main. Next: PointDefenseTurret power (segment) / TractorBeamTurret power (parallax) — own drivers, own slices.**

## Scope

- Family: the SolidPump implementation — **water-extractor** (consumePower 1.5f, pumpAmount 0.11f, size 2, liquidCapacity 40f, rotateSpeed 1.4f, attribute water, envRequired groundWater, result water). The ONLY SolidPump block in the game (Blocks.java:2920-2930). Catalog confirms implementation SolidPump + consumePower 1.5 (content_registry_blocks.json, properties consumePower 1.5 / consumesPower true / hasPower true / connectedPower true).
- Why: the pump runtime (SourcePumpRuntimeState.gd) ticks only the scenario mechanical pump at PUMP_POS with efficiency hardcoded 1.0 ("consumes no power", `source_pump_update_state`), so the water-extractor never ticks at all and would run as if power.status were 1.0. N2150 is the SolidPump family's live read — the same proven N2145/N2146/N2147/N2148/N2149 pure-row pattern, one new file over.
- Base Pump (mechanical-pump, no power) untouched — the SolidPump driver is separate, like BurstDrill vs base Drill.

## Design (decided in RED)

- New file `godot-mindustry/src/game/SourceSolidPumpBuildState.gd` (mirrors SourceBurstDrillBuildState.gd): pure `source_solid_pump_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_solid_pump_tick_buildings_state(game, seconds)` mirroring the burst-drill driver's shape — iterate placed SolidPump buildings (`source_unique_buildings_state`), bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the solid-pump speed (SolidPump.java:121) follows power.status.
- Frame key (decided in RED): the driver uses its OWN family frame key `"source_solid_pump_building"` (the turret precedent — the mechanical-pump per-cell frame `source_pump_building`, managed by SourcePumpRuntimeState with liquid_drop/amount/warmup/total_progress, stays untouched). N2142's stamp/write-back only reaches frames whose meta key is in `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS`, and that list has NO pump key — so GREEN must add `"source_solid_pump_building"` to that list (one line, same mechanism as the turret key). BurstDrill needed no list change because it reuses the drill frame key (`source_drill_building`).
- Wiring: call the driver from `SourceFactoryRuntimeState.simulate_factory` (preload const + one call after the burst-drill tick, N2149 precedent).
- Header comment quotes: `return build.power.status;` (ConsumePower.java:39), the null-fold line (UnitAssembler.java:469), `hasConsumers = consumers.length > 0;` (Block.java:1449), and the speed fold `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:121) — **keep the maxPump line on ONE comment line** (the N2148 shootWarmup lesson: a split line fails the source-text test).
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2148/N2149): (1) power-only first pass — the water-attribute / validTiles / boost fraction (SolidPump.java:118, 137-147) is NOT a first-pass row; the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — `SolidPumpBuild.shouldConsume()` (SolidPump.java:113-115, `return liquids.get(result) < liquidCapacity - 0.01f;`) needs liquid state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — warmup / pumpTime / lastPump / validTiles / boost (SolidPump.java:118-133) waits for its own slice; the proof carries no progress keys, the speed fold (SolidPump.java:121) is what the efficiency keys prove.
- Proof scene (new, modeled on the N2149 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_SOLID_PUMP_POWER_STATUS_PROOF `, 6 keys: `water_extractor_has_power_consumer` (catalog water-extractor properties has consumePower), `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min` (live tick — place water-extractor live, stamp frame["power_status"] = 0.5, call `source_solid_pump_tick_buildings_state` directly so the graph update does not overwrite the stamp), `efficiency_zero_at_no_power`.

## Exact exprs (9, all verified verbatim at RED)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(1.5f);` (Blocks.java:2929)
- `pumpAmount = 0.11f;` (Blocks.java:2923)
- `float maxPump = Math.min(liquidCapacity - typeLiquid(), pumpAmount * delta() * fraction * efficiency);` (SolidPump.java:121)
- `return liquids.get(result) < liquidCapacity - 0.01f;` (SolidPump.java:114)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java)

## RED

- RED run (main thread, ~11:4x +07): test module `tools/mindustry_godot_transpiler/tests/test_c07_solid_pump_power_status.py`, Ran 4 tests in 1.268s, FAILED (failures=1, errors=3) — exactly as expected: registration ERROR KeyError 'N2150', evidence ERROR KeyError 'N2150', source-text ERROR FileNotFoundError on `SourceSolidPumpBuildState.gd` (file does not exist yet), proof FAIL returncode 1 (scene missing). Port 7777 was FREE. 9/9 exact exprs verified verbatim at RED (7 read in the Java sources during scoping + the 2 BuildingComp lines grepped: 1 hit each). SSOT baseline 11308/1600/1521/2833.

## GREEN

- GREEN (main thread, ~11:5x +07): register script run, SSOT **11310/1601/1522/2835** (+2/+1/+1/+2 as expected), N2150 registered with its 2 symbols, audit 1335; pure `source_solid_pump_power_status_row_state` + driver `source_solid_pump_tick_buildings_state` in new `SourceSolidPumpBuildState.gd` (own frame key `"source_solid_pump_building"`); `"source_solid_pump_building"` added to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd:140); driver wired into `SourceFactoryRuntimeState.simulate_factory` (preload + call after the burst-drill tick); proof scene `C07SolidPumpPowerStatusProof` (6 semantic keys).
- Targeted 4/4 OK first attempt (14.199s; re-run 13.577s OK) — registration, exact-evidence, source-text, Godot proof test.
- Godot proof GREEN: proof JSON 9 keys, all true, `matches: true` (6 semantic + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM. Port 7777 was free; no proof scene ran while a gate ran.
- Neighbours: first run 35/36 OK in 144.854s (1 failure); re-run 29/36 OK in 181.209s (7 failures) — **ALL failures are spurious port-7777 collisions, NOT an N2150 regression**: every failing proof printed `matches:true` with all keys true; the only failure line is `assertNotIn('ERROR:')` tripped by `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` (the other agent's Godot held the port intermittently during the run — the failing tests are the pump-binding + N2145/N2146/N2147/N2148 proof tests; N2142 + N2149 + pump-update passed). Non-proof tests (registration / evidence / source-text) passed in both runs. Third run (11:45 cron run, ~11:50, log `/tmp/n2150-neighbours.log`): **36/36 OK in 130.129s** — neighbours verified clean, no port collision that time. Targeted re-verified in the same run: 4/4 OK (first attempt hit the same transient port-7777 bind ERROR, retry OK).
- `git diff --check` clean.

## Gate result

- Full gate attempt 1 **launched from the MAIN THREAD ~11:55 +07**: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2150-gate.log 2>&1 < /dev/null &` — **PID 10309, SID 10309 (own session), PPID 10306 (background subshell), CPU ~91%, log growing** (578 → 1,002 bytes in 3s, verified ~11:55). No Godot on PATH. No proof scene will run while the gate runs (port-7777 rule). Expect: Ran ~5697, failures=101 (100 inherited + 1 new N2150 proof test), skipped=5, 0 errors, all Godot-absent. Finish ~12:15–12:25 +07 (N2149 took 1159s; recent gates 1159–1722s).
- (pending verification when the gate finishes)
- **FINISHED ~12:13 +07, VERIFIED clean except Godot (12:15 cron run): Ran 5697 tests in 1075.735s, FAILED (failures=101, skipped=5), 0 errors — all 101 verified Godot-absent asserts (101 `FAIL:` blocks, every one a `test_reference_graph_and_actual_*` Godot-proof test failing on `assertIsNotNone(godot)` / `unexpectedly None`; 0 non-Godot-absent FAILs by block inspection; 0 `ERROR:` blocks; the N2150 module shows no failure other than its Godot-proof test). Gate finished on the FIRST attempt (no worker-launch death this time). 1075.7s — back in the usual ~900–1150s band (N2149: 1159.2s).**

## Gate (main thread)

- Verified ~12:15 +07 by the 12:15 cron run: Ran 5697 in 1075.735s, failures=101, skipped=5, 0 errors — all 101 Godot-absent asserts. Slice is DONE per the repo process (targeted 4/4, neighbours 36/36, Godot proof GREEN, full gate clean except Godot). Report + spec updated this run; commit + push this run.

## Commits

- Slice commit **765c2f3** — `C07: N2150 solid-pump power.status live read (pure power row + driver wiring; proof 6 keys)` (15 files, +870/−1).
- Docs commit **6f6ad13** — `Docs: N2150 report + design spec + handoff (gate clean except Godot)` (3 files: handoff + report + spec, Status Summary 1600→1601).
- Pushed 2026-11-13 ~12:2x +07 by the 12:15 cron run: `0c06603..6f6ad13 main -> main` on origin (fork Lasthope1508). Verified: `git log --oneline -3` shows 6f6ad13 on top.

## Deferred (NOT this slice)

- SolidPump updateTile advance, SolidPump shouldConsume gate, SolidPump water-attribute / validTiles / boost fraction rows (see register script DEFERRED).
- BurstDrill updateTile advance / shouldConsume gate / liquid rows / ore-dominant binding.
- PointDefenseTurret power (segment) / TractorBeamTurret power (parallax) — own drivers, own slices.
- spawn_occupied / allow_update / moveOutPayload, net drone sync (see register script DEFERRED).
- C07–C12 remain open.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Environment note: javalang was reinstalled 0.13.0 at the 10:45 run (VM restart wiped it); import verified OK before the register script runs. If the VM restarted since, reinstall first (`pip install --break-system-packages -r tools/mindustry_godot_transpiler/requirements.txt` from the repo root) before any gate.
