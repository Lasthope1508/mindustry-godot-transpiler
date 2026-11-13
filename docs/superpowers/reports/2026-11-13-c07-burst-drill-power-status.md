# Report — N2149: BurstDrill power.status live read (eruption-drill / impact-drill) (C07)

Date: 2026-11-13. Batch: N2149 (single slice). Status: **DONE + PUSHED 2026-11-13 ~11:3x +07 (11:30 cron run). Targeted tests 4/4 OK, neighbours 24/24 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5693, failures=100, skipped=5, 0 errors — all 100 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The next `power.status` consumer family after the N2148 turret slice: the BurstDrill implementation — **eruption-drill** (consumePower 6f, hydrogen 4f/60f + cyanogen 0.75f/60f booster, liquidBoostIntensity 2f, drillTime 281.25f, tier 7, size 5, itemCapacity 60) and **impact-drill** (consumePower 160f/60f, water 10f/60f + ozone 3f/60f booster, liquidBoostIntensity 1.75f, drillTime 720f, tier 6, size 4, itemCapacity 40). Both havePower=true; the catalog confirms implementation BurstDrill + consumePower 6.0 / 2.6667. N2142's live loop stamps `frame["power_status"]` each tick and the generic write-back already covers burst-drill frames (the frame reuses the drill meta key `"source_drill_building"` — BurstDrillBuild extends DrillBuild, BurstDrill.java:17, and N2142's `SOURCE_CONSUMER_FRAME_META_KEYS` already includes it, so no N2142 change was needed), but no driver ever read it for burst drills: there was no `SourceBurstDrillBuildState.gd` at all. N2149 is the burst-drill family's live read — the same proven N2145/N2146/N2147/N2148 pure-row pattern, one file over.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2149 does not touch it. N2149 supplies the missing pure power row + wires it into the driver.

Pure `SourceBurstDrillBuildState.source_burst_drill_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update).

Driver wiring in `source_burst_drill_tick_buildings_state(game, seconds)`: iterate placed BurstDrill buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the burst-drill speed fold (BurstDrill.java:94, `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;`) follows it. Live-loop wiring: the driver is called from `simulate_factory` in SourceFactoryRuntimeState.gd next to the turret tick.

Scope decision (decided in RED): **the BurstDrill implementation only — eruption-drill and impact-drill**. Documented limits in the pure function's comment, same discipline as N2146/N2148: (1) power-only first pass — eruption's hydrogen/cyanogen and impact's water/ozone liquid rows wait for their own slices, so the folded efficiency is the min over the *modeled* consumers (power only); (2) no shouldConsume gate — `BurstDrillBuild.shouldConsume()` (BurstDrill.java:129, `return items.total() <= itemCapacity - dominantItems && enabled;`) needs items/dominant state the tick does not track yet; the machinery runs with should_consume=true when enabled; (3) no updateTile advance — progress/timeDrilled/offload/invertTime/speedCurve (BurstDrill.java:70-125) waits for its own slice; the proof carries no progress keys, the speed fold (BurstDrill.java:94) is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07BurstDrillPowerStatusProof` (modeled on the N2147/N2148 proofs — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_BURST_DRILL_POWER_STATUS_PROOF `:

- `eruption_has_power_consumer`: catalog `eruption-drill` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place eruption-drill live at (28,20) on ore-copper, stamp `frame["power_status"] = 0.5`, call `source_burst_drill_tick_buildings_state` directly (as the N2147/N2148 proofs call their drivers directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_burst_drill_power_status.py`: **4/4 OK in 13.877s** (Godot on PATH) — registration (ledger N2149, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 9 exprs over ConsumePower.java + BuildingComp.java + BurstDrill.java + Drill.java + Blocks.java + PowerModule.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (10:30 cron run, ~10:30 +07): 4 tests in 3.6s, FAILED (failures=1, errors=3), all expected — registration `KeyError: 'N2149'`, evidence errors on the missing ledger entry, source-text errors on the missing `SourceBurstDrillBuildState.gd`, proof returncode 1 (proof scene did not exist yet). 9/9 exact exprs verified verbatim at RED (plus eruption/impact catalog values cross-checked: consumePower 6.0 / 2.6667).
- First GREEN attempt 3/4: `test_burst_drill_power_status_row_state` failed only because the BurstDrill.java:94 speed expr was wrapped across two comment lines; fixed by putting the expr on one comment line, re-ran 4/4 OK — test-harness text, no gameplay change.
- Neighbours (Godot on PATH, sequential): **24/24 OK in 72.670s** — `test_turret_live_loop` + N2142 `test_c07_power_status_live` + N2145 `test_c07_factory_power_status` + N2146 `test_c07_adjacent_factory_power_status` + N2147 `test_c07_drill_power_status` + N2148 `test_c07_turret_power_status`.
- Godot proof: **GREEN 2026-11-13 ~10:50 +07** (10:45 cron run) — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Port 7777 was free before every proof run; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11308 / 1600 / 1521 / 2833** (verified live in this run: registry `symbols` 11308, ledger `slices` 1600, contracts 1521, schemas 2833); audit stays 1335.
- Environment note: javalang was missing at run start (VM restart wiped it) — reinstalled 0.13.0 from `tools/mindustry_godot_transpiler/requirements.txt` before the register script, import verified OK.

## Gate / suite

- Test modules standalone: N2149 4/4 (proof green, see above); neighbours 24/24.
- Full Python suite, inclusive gate with the N2149 module (log `tools/mindustry_godot_transpiler/full-suite-n2149-gate.log`, 211 modules): **FINISHED ~11:2x +07, VERIFIED clean except Godot in this run — Ran 5693 tests in 1159.218s, FAILED (failures=100, skipped=5), 0 errors. All 100 failures verified Godot-absent: 100 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (99 plain + 1 hydration with message 'Godot required for hydration proof'; 0 `ERROR:` blocks); the N2149 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_burst_drill_power_status`).** Gate attempt 2 launched from the main thread (PID 4089, SID 4089, ~11:02 +07) with the proven backgrounded-`setsid`-`nohup` method; attempt 1 (worker-launched PID 3798, ~10:59) died at the worker session timeout (log stopped at 3,490 bytes, no footer — the known worker-launch failure mode, same as N2146 PID 9699 / N2147 PID 3427). Duplicate gate incident: the 11:00 cron run misread attempt 1's death and launched a second gate at 11:02:57 (PID 4281); it was identified by parentage (4086/4089 = main-thread relaunch) and killed ~11:07, its partial log preserved as `full-suite-n2149-gate-attempt2-duplicate.log` (4,483 bytes, frozen). The gate took 1159.2s vs N2148's 1666.8s — back near the usual ~900–1150s band. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- SolidPump power (water-extractor) — own driver, own slice; next per the backlog.
- BurstDrill updateTile advance (progress/timeDrilled/offload/invertTime/speedCurve, BurstDrill.java:70-125) — own slice.
- BurstDrill shouldConsume gate (`items.total() <= itemCapacity - dominantItems && enabled`, BurstDrill.java:129) — needs items/dominant state the tick does not track yet.
- BurstDrill liquid rows (eruption hydrogen/cyanogen, impact water/ozone) — the folded efficiency is currently the min over the modeled (power-only) consumers.
- BurstDrill ore/dominant-item binding.
- PointDefenseTurret power (segment, 8f) and TractorBeamTurret power (parallax, 3.3f) — own drivers (ReloadTurret / BaseTurret), own slices.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.

See `handoffs/2026-11-13-c07-burst-drill-power-status-handoff.md` for the full detail.
