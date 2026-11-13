# Handoff — N2149: BurstDrill power.status live read (eruption-drill / impact-drill) (C07)

Date: 2026-11-13. Batch: N2149 (single slice). Status: **DONE + PUSHED 2026-11-13 ~11:3x +07 (11:30 cron run). Targeted 4/4 OK (13.9s), neighbours 24/24 OK (72.7s), Godot proof GREEN (9 keys, all true, matches:true). SSOT 11308/1600/1521/2833, audit 1335. Full gate attempt 2 (main-thread PID 4089) FINISHED ~11:2x +07, VERIFIED clean except Godot in this run — Ran 5693 in 1159.218s, FAILED (failures=100, skipped=5), 0 errors — all 100 Godot-absent asserts (99 plain + 1 hydration). Report + spec + commit + push this run. Next: SolidPump power (water-extractor) per the deferred list.**

## Scope (decided at RED)

- Family: the BurstDrill implementation — **eruption-drill** (consumePower 6f, hydrogen 4f/60f + cyanogen 0.75f/60f booster, liquidBoostIntensity 2f, drillTime 281.25f, tier 7, size 5, itemCapacity 60) and **impact-drill** (consumePower 160f/60f, water 10f/60f + ozone 3f/60f booster, liquidBoostIntensity 1.75f, drillTime 720f, tier 6, size 4, itemCapacity 40). Both havePower=true. Catalog confirms implementation BurstDrill + consumePower 6.0 / 2.6667.
- New file `godot-mindustry/src/game/SourceBurstDrillBuildState.gd` (mirrors SourceTurretBuildState.gd): pure `source_burst_drill_power_status_row_state(frame, has_power_consumer)` returning `{"has_power_row": false, "row": {}}` without a consumer, else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469); plus driver `source_burst_drill_tick_buildings_state(game, seconds)` mirroring the turret driver's shape — iterate placed BurstDrill buildings, bind the frame if missing, refresh frame keys (block_implementation, team_id, rules_state, cheating, enabled), and when `block.properties.has("consumePower")` and enabled and not cheating, fold the pure row into frame["efficiency"] through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so the burst-drill speed (BurstDrill.java:94) follows power.status.
- Frame: reuse the drill frame meta key `"source_drill_building"` (BurstDrillBuild extends DrillBuild, BurstDrill.java:17; N2142's SOURCE_CONSUMER_FRAME_META_KEYS already includes it, so the graph write-back already stamps burst-drill frames — no N2142 change needed; verify at GREEN).
- Live-loop wiring: call the new driver from `simulate_factory` in SourceFactoryRuntimeState.gd next to the turret tick (preload pattern like `source_turret_build_state`), so burst drills tick every live-loop tick.
- Documented limits (GREEN must record in the pure function's comment, same discipline as N2146/N2148): (1) power-only first pass — eruption's hydrogen/cyanogen and impact's water/ozone liquid rows wait for their own slices, so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume gate — `BurstDrillBuild.shouldConsume()` (BurstDrill.java:129, `return items.total() <= itemCapacity - dominantItems && enabled;`) needs items/dominant state the tick does not track yet; the machinery runs with should_consume=true when enabled. (3) No updateTile advance — progress/timeDrilled/offload/invertTime/speedCurve (BurstDrill.java:70-125) waits for its own slice; the proof carries no progress keys, the speed fold (BurstDrill.java:94) is what the efficiency keys prove.
- Proof: new scene `C07BurstDrillPowerStatusProof` (6 semantic keys, modeled on the N2147/N2148 proofs): eruption_has_power_consumer / power_row_half / power_row_absent_without_consumer / power_row_null_folds_one / efficiency_folds_power_min / efficiency_zero_at_no_power. The live-tick keys place an eruption-drill live and call `source_burst_drill_tick_buildings_state` directly (as the N2147/N2148 proofs call their drivers directly), not simulate_factory, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142.
- Deferred (NOT this slice): SolidPump power (water-extractor), BurstDrill updateTile advance, BurstDrill shouldConsume gate, BurstDrill liquid rows, BurstDrill ore/dominant-item binding, PointDefenseTurret power (segment) / TractorBeamTurret power (parallax), spawn_occupied/allow_update/moveOutPayload, net drone sync.

## Exact Java evidence (9/9 verified verbatim at RED)

- ConsumePower.java:39 `return build.power.status;`
- UnitAssembler.java:469 `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
- Block.java:1449 `hasConsumers = consumers.length > 0;`
- Blocks.java eruption `consumePower(6f);` (def 3093, line 3118)
- Blocks.java impact `consumePower(160f / 60f);` (def 3070, line 3088)
- BurstDrill.java:94 `float speed = Mathf.lerp(1f, liquidBoostIntensity, optionalEfficiency) * efficiency;`
- BurstDrill.java:129 `return items.total() <= itemCapacity - dominantItems && enabled;`
- BuildingComp.java:1969 `for(var cons : block.nonOptionalConsumers){`
- BuildingComp.java:1976 `minEfficiency = Math.min(minEfficiency, result);`
- Also read: BurstDrill.java:17 `public class BurstDrill extends Drill{`; BurstDrill.java:70-125 updateTile; Drill.java:301 speed fold; PowerModule.java.
- Slice sources (8): ConsumePower.java, BuildingComp.java, BurstDrill.java, Drill.java, Blocks.java, PowerModule.java, UnitAssembler.java, Block.java.

## SSOT baseline (verified live at RED)

- Symbols 11306 / slices 1599 / contracts 1520 / schemas 2831 (post-N2148 state, main `0ac7f2d`). Audit report present (totalSourceFunctions 1335).
- Register script to write in GREEN: `tools/mindustry_godot_transpiler/register_c07_burst_drill_power_status.py` — 2 new symbols (row + has_power_row), expected SSOT +2/+1/+1/+2 → 11308/1600/1521/2833.

## Files

- Test module: `tools/mindustry_godot_transpiler/tests/test_c07_burst_drill_power_status.py` (4 tests, written at RED).
- GREEN code: `godot-mindustry/src/game/SourceBurstDrillBuildState.gd` (new file: pure function + driver + frame bind) + live-loop wiring in `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (call next to the turret tick).
- Proof: `godot-mindustry/tools/runtime_proofs/C07BurstDrillPowerStatusProof.gd` + `.tscn` (to write in GREEN).
- Register script: `tools/mindustry_godot_transpiler/register_c07_burst_drill_power_status.py` (written at RED, to run in GREEN).
- Report: `docs/superpowers/reports/2026-11-13-c07-burst-drill-power-status.md` (to write at DONE).
- Neighbours (to verify in GREEN): `test_burst_drill_power_status` targeted + `test_turret_live_loop` + N2142 `test_c07_power_status_live` + N2145 `test_c07_factory_power_status` + N2146 `test_c07_adjacent_factory_power_status` + N2147 `test_c07_drill_power_status` + N2148 `test_c07_turret_power_status` — exact counts to confirm at GREEN.

## Notes

- Another agent is using Godot to test the fail errors (user, 08:05). Port 7777 was FREE at RED. Before any proof run, re-check `ss -ltnp | grep 7777` and run proof scenes sequentially — never while a gate runs (port-7777 rule).
- Worktree at RED: main `0ac7f2d`, clean except untracked `*.gd.uid` (never stage). javalang 0.13.0 import verified OK at RED (no reinstall needed this run).
- Never stage: `*.gd.uid`, `project.godot`, proof `.json`, `full-suite-*.log`.

## RED run

- Command (10:30 cron run, ~10:30 +07): `cd tools/mindustry_godot_transpiler && PATH="$HOME/workspace/godot-bin:$PATH" python3 -m unittest tests.test_c07_burst_drill_power_status -v`
- Result: **Ran 4 tests in 3.6s, FAILED (failures=1, errors=3)** — as expected. Registration + evidence error on `KeyError: 'N2149'` (no ledger entry yet); source-text errors on the missing `SourceBurstDrillBuildState.gd`; proof test fails returncode 1 — `ERROR: Cannot open file 'res://tools/runtime_proofs/C07BurstDrillPowerStatusProof.tscn'` (scene does not exist yet). 9/9 exact exprs verified verbatim in the handoff (plus eruption/impact catalog values cross-checked: consumePower 6.0 / 2.6667).

## GREEN run

- Command (10:45 cron run, ~10:50 +07): `cd tools/mindustry_godot_transpiler && PATH="$HOME/workspace/godot-bin:$PATH" python3 -m unittest tests.test_c07_burst_drill_power_status -v`
- Result: **Ran 4 tests in 13.877s, OK** (first pass 3/4: `test_burst_drill_power_status_row_state` failed only because the BurstDrill.java:94 speed expr was wrapped across two comment lines; fixed by putting the expr on one comment line, re-ran 4/4 OK). Register script run first: SSOT **11308/1600/1521/2833** (expected +2/+1/+1/+2), audit 1335 unchanged. Proof JSON `C07BurstDrillPowerStatusProof.json`: 9 keys, all true, `matches: true` (6 semantic + registry_valid + one_headquarter_per_ssot + matches).
- Neighbours (10:45 run, ~10:55 +07): `python3 -m unittest tests.test_turret_live_loop tests.test_c07_power_status_live tests.test_c07_factory_power_status tests.test_c07_adjacent_factory_power_status tests.test_c07_drill_power_status tests.test_c07_turret_power_status` — **Ran 24 tests in 72.670s, OK**.
- GREEN code: new `godot-mindustry/src/game/SourceBurstDrillBuildState.gd` (pure row + tick-frame-state + bind + driver, mirrors SourceTurretBuildState.gd; frame reuses drill meta key `"source_drill_building"`) + live-loop wiring in `godot-mindustry/src/game/SourceFactoryRuntimeState.gd` (preload + `source_burst_drill_tick_buildings_state(game, delta)` call next to the turret tick). Proof: `godot-mindustry/tools/runtime_proofs/C07BurstDrillPowerStatusProof.gd` + `.tscn` (eruption-drill placed live at (28,20) on ore-copper, driver called directly).
- Environment note: javalang was missing at run start (VM restart wiped it) — reinstalled 0.13.0 from `tools/mindustry_godot_transpiler/requirements.txt` before the register script, import verified OK. Port 7777 FREE before every proof run; no gate was running.
- `git diff --check` clean.

## Gate result

- Full gate **LAUNCHED ~10:59 +07 (10:45 cron run)**: `cd tools/mindustry_godot_transpiler && setsid nohup python3 -m unittest discover -s tests > full-suite-n2149-gate.log 2>&1 < /dev/null &` — **PID 3798, SID 3798 (own session), PPID 3795 (background subshell, same shape as the N2148 launch), %CPU ~96, log growing** (verified 33s after launch). Discover count pre-verified 5693 (5689 + 4 new N2149 tests). No Godot on PATH (default PATH has no godot-bin; targeted runs added it explicitly). No proof scene ran / will run while the gate runs (port-7777 rule).
- Expected: **Ran 5693, failures=100, skipped=5, 0 errors** — 99 inherited Godot-absent asserts + 1 new N2149 proof test.
- Full gate attempt 1 (worker-launched PID 3798) **DIED ~11:00 +07** when the 10:45 cron worker session timed out (execution-phase timeout): `ps` finds no PID 3798; log stopped at 3,490 bytes (dots + 2 F's, no footer) — the same worker-launch failure mode as N2146 PID 9699 / N2147 PID 3427. The handoff's "verified 33s after launch" note was true at launch time but the gate did not survive the session end.
- Full gate attempt 2 **relaunched from the MAIN THREAD ~11:02 +07** (main-thread verification + relaunch): `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2149-gate.log 2>&1 < /dev/null &` — **PID 4089, SID 4089 (own session), PPID 4086 (background subshell), CPU ~96%, log growing** (2,558 → 2,973 bytes in 3s, verified ~11:02). Same log name (attempt 1's partial log truncated by the redirect). No Godot on PATH. No proof scene will run while the gate runs (port-7777 rule).
- Duplicate gate incident (11:00 cron run, ~11:03-11:07 +07): the worker run misread attempt 1's death and launched a second gate at 11:02:57 (PID 4281, own log `full-suite-n2149-gate.log` after renaming attempt 2's live log aside). The duplicate was identified by parentage (4086/4089 = main-thread relaunch) and killed ~11:07; its partial log is preserved as `full-suite-n2149-gate-attempt2-duplicate.log` (4483 bytes, frozen), and attempt 2's live log was renamed back to the canonical `full-suite-n2149-gate.log` (verified still growing, PID 4089 alive, ~81% CPU, elapsed 6:13 at 11:07:41). Single gate running from this point.
- Full gate attempt 2 (main-thread relaunch PID 4089) **FINISHED ~11:2x +07, VERIFIED clean except Godot in this run (11:30 cron run)**: `tail` shows the footer — **Ran 5693 tests in 1159.218s, FAILED (failures=100, skipped=5), 0 errors**. All 100 failures verified Godot-absent: 100 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` — 99 plain + 1 hydration (`AssertionError: unexpectedly None : Godot required for hydration proof`, test_liquid_consumer_hydration); 0 `ERROR:` blocks. The N2149 module's only failure is its Godot-proof test (`test_reference_graph_and_actual_c07_burst_drill_power_status`, log line 219). 99 inherited (98 plain + 1 hydration, same as N2148's 99) + 1 new N2149 proof test = 100, exactly as expected. Gate took 1159.2s vs N2148's 1666.8s — back near the usual ~900–1150s band. No Godot on PATH during the gate; the proof itself was run separately with Godot present and is green. No proof scene ran while the gate ran (port-7777 rule).

## Commits

- Slice: `ded31ea` — C07: N2149 burst-drill power.status live read (pure power row + driver wiring; proof 6 keys) — 14 files, 877 insertions, 0 deletions.
- Docs: `1ff78b1` — Docs: N2149 report + design spec + handoff (gate clean except Godot) — 3 files (report + spec + handoff).
- Pushed to origin main (fork Lasthope1508) 2026-11-13 ~11:3x +07 (11:30 cron run): `0ac7f2d..1ff78b1 main -> main`.
