# Report — N2173: Radar power.status live read (radar) (C07)

Date: 2026-11-14. Batch: N2173 (single slice). Status: **DONE + PUSHED (2026-11-14 ~15:1x +07 — targeted 4/4 OK, neighbours 148/148 OK, Godot proof GREEN 6 keys matches:true, full gate attempt 2 Ran 5789 in 951.387s, failures=124, skipped=5, 0 errors — all 124 verified Godot-absent asserts).**

## What changed

The next `power.status` consumer family after the N2172 launch-pad slice: the Radar implementation family — ONE def, **radar** (consumePower 0.6f, Blocks.java:1994; size 1, fogRadius 34, Blocks.java:1991; discoveryTime 60f * 10f, Radar.java:18; rotateSpeed 2f, Radar.java:19). Radar extends Block (Radar.java:17, `public class Radar extends Block{`); its build extends Building (Radar.java:48, `public class RadarBuild extends Building{`). Catalog confirms implementation Radar + consumePower 0.6 + hasPower true + consumesPower true + powerUsage 0.6 (source_modules/content_registry_blocks.json, radar entry). Blocks.java def is the source of truth, see Exact exprs.

The radar has NO driver at all — no `SourceRadar*` file exists in godot-mindustry/src/game, it extends Block, not a factory or crafter, so no existing driver matches it, and no frame key exists for it, so the N2142 stamp never reaches a radar frame. Its updateTile progress advance (Radar.java:68, `progress += edelta() / discoveryTime;`) advances progress by edelta() (BuildingComp.java:1927-1929, `return efficiency * delta();`), so a radar with no power would never discover — its progress would sit frozen as if power.status were 1.0. N2173 is the radar's live read — the same proven N2145–N2172 pure-row pattern, on the N2172 launch-pad precedent (new family file + own driver + own frame key + simulate_factory wiring): one new pure function on a new state file + a driver fold + a new frame key + the wiring. The same driver covers the one def via the catalog consumePower.

RadarBuild has NO shouldConsume override — the BuildingComp default (BuildingComp.java:755-757, `return enabled;`) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). No deferred shouldConsume gate is needed beyond that note.

New file `godot-mindustry/src/game/SourceRadarBuildState.gd`, class_name SourceRadarBuildState, with `SOURCE_RADAR_BUILD_IMPLEMENTATIONS := ["Radar"]` and frame meta key `"source_radar_building"`:

- Pure `source_radar_power_status_row_state(frame, has_power_consumer)` (mirrors `source_launch_pad_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_radar_tick_frame_state` (mirrors the launch-pad tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_radar_bind_frame_state` (mirrors the launch-pad bind: empty frame under the radar meta key, no-op for other blocks / already-bound sprites).
- Driver `source_radar_tick_buildings_state(game, seconds)` (mirrors the launch-pad driver: iterate placed buildings, match implementation, bind frame, tick frame, when `block.properties.has("consumePower")` and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile advance).

New frame key `"source_radar_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the radar frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `source_radar_build_state` + call `source_radar_tick_buildings_state(game, delta)` (next to the launch-pad call).

Documented limits in the pure function's comment, same discipline as N2148–N2172: (1) power-only first pass — the radar's power consumer is static (consumePower 0.6f, Blocks.java:1994), so the folded efficiency is the min over the *modeled* consumers (power only). (2) No shouldConsume override — RadarBuild has NO shouldConsume override, so the BuildingComp default (`return enabled;`, BuildingComp.java:755-757) applies; the machinery runs with should_consume=true when enabled (the MendProjector suppression precedent). (3) No updateTile advance — smoothEfficiency / fogRadius forceUpdate / progress / totalProgress (Radar.java:60-72) wait for their own slices; the proof carries no progress/smooth-efficiency/fog-radius keys, the progress advance (Radar.java:68) is what the efficiency keys prove. (4) One def — radar is the only Radar def; fogRadius 34 (Blocks.java:1991) and discoveryTime 60f * 10f (Radar.java:18) wait for their own verification slice.

Scope decision (verified this run): the candidate order after LaunchPad listed Radar next. Verified against the catalog and the driver list: radar carries consumePower 0.6f with hasPower + consumesPower true, and NO driver covers it — no SourceRadar* file, no Radar entry in any SOURCE_*_IMPLEMENTATIONS list (the turret driver covers ItemTurret/LiquidTurret/PowerTurret/LaserTurret/ContinuousTurret only — its line-28 comment mentions RepairTurret/BuildTurret but does NOT list them; the adjacent driver covers Separator/Incinerator/WallCrafter/SingleBlockProducer only; the base-shield driver covers BaseShield only). The Incinerator lesson was applied: each candidate was checked for an existing driver before scoping.

## Proof keys (new scene, 6 keys)

New scene `C07RadarPowerStatusProof` (modeled on the N2172 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_RADAR_POWER_STATUS_PROOF `:

- `radar_has_power_consumer`: catalog `radar` properties have `consumePower` 0.6.
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place radar live, stamp `frame["power_status"] = 0.5`, call the driver directly so the graph update does not overwrite the stamp → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Exact exprs (13, all verified verbatim at scoping/RED)

- `return build.power.status;` (ConsumePower.java:39)
- `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;` (UnitAssembler.java:469)
- `hasConsumers = consumers.length > 0;` (Block.java:1449)
- `consumePower(0.6f);` (Blocks.java:1994)
- `public class Radar extends Block{` (Radar.java:17)
- `public boolean shouldConsume(){` (BuildingComp.java:755)
- `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969)
- `minEfficiency = Math.min(minEfficiency, result);` (BuildingComp.java:1976)
- `public class RadarBuild extends Building{` (Radar.java:48)
- `smoothEfficiency = Mathf.lerpDelta(smoothEfficiency, efficiency, 0.05f);` (Radar.java:61)
- `progress += edelta() / discoveryTime;` (Radar.java:68)
- `totalProgress += efficiency * edelta();` (Radar.java:71)
- `return enabled;` (BuildingComp.java:756)

## Verified numbers (measured in this VM)

- Test module `test_c07_radar_power_status.py`: **4/4 OK in 27.343s** (GREEN ~13:5x). Godot on PATH via `PATH="$HOME/workspace/godot-bin:$PATH"`.
- RED run (~13:3x +07, 2026-11-14): Ran 4 tests in 5.132s, FAILED (failures=1, errors=3), all expected — registration ERROR KeyError 'N2173', evidence ERROR KeyError 'N2173', source-text ERROR FileNotFoundError (new state file did not exist yet), proof FAIL returncode 1 (scene missing, Godot 4.6.2-stable Linux). Port 7777 was FREE. 13/13 exact exprs verified verbatim at RED. SSOT baseline 11354/1623/1544/2879 (main 163b5bd), audit 1335. javalang 0.13.0 confirmed present at RED (no reinstall needed — no VM restart since the N2172 reinstall).
- Neighbours: **148/148 OK** — C07 power-status family 29 modules / 116 tests in 716.087s (log `tools/mindustry_godot_transpiler/n2173-neighbours.log`) + wiring-sensitive 9 modules / 32 tests re-run by main thread ~14:17 (discover per-module, no flake this time). Targeted re-run 4/4 OK in 24.823s by main thread.
- Godot proof: **GREEN ~13:5x +07** (2026-11-14) — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), verified by the passing proof test in the targeted run, on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this slice's commit.
- `git diff --check` clean (verified at GREEN).
- SSOT +2/+1/+1/+2 → **11356 / 1624 / 1545 / 2881** (registry `symbols` 11356, ledger `slices` 1624, contracts 1545, schemas 2881); audit stays 1335. Defense shard changed this time: `defense_slices.json` + `defense_api_contracts.json` carry the N2173 entry (Radar.java is a defense block) — unlike N2171/N2172, where no shard selection matched.
- Environment note: Godot binary is at ~/workspace/godot-bin/godot (symlink to Godot_v4.6.2-stable_linux.x86_64) — NOT on PATH by default; targeted/neighbours ran with PATH="$HOME/workspace/godot-bin:$PATH". javalang 0.13.0 reinstalled after the ~14:38 VM restart (system-wide pip install wiped by the restart; reinstalled by the 14:45 cron run).

## Gate / suite

- Full gate attempt 1 (main thread, PID 11763, ~14:17 +07) **DIED ~14:38 +07 — VM restarted again** (uptime 8 min at the 14:46 check). Log `tools/mindustry_godot_transpiler/full-suite-n2173-gate.log` stopped at 5,464 bytes, ~5,459 tests, 108 F's, 0 E's, NO footer — ~94% through, the 108 F's so far match the expected Godot-absent pattern. Nothing lost: all N2173 slice files intact (state file, test, register script, proof JSON matches:true, SSOT JSONs). javalang wiped by the restart — reinstalled 0.13.0 by the 14:45 cron run.
- Full gate attempt 2 (main thread, PID 2614, ~14:46 +07, fresh log) **finished ~15:02 +07: Ran 5789 tests in 951.387s, FAILED (failures=124, skipped=5), 0 errors** — all 124 verified Godot-absent asserts from the log by this run (123 plain `assertIsNotNone(godot)` bodies — 122 inherited + 1 new N2173 proof test `test_reference_graph_and_actual_c07_radar_power_status` — + 1 hydration `test_live_block_shared_consumers_and_optional_efficiency_runtime`, "Godot required for hydration proof"). No real failures. The gate took 951s (~16 min) — faster than N2172's 1735s.
- Next after gate + push: N2174 — next C07 power.status family; scope at the next run from the catalog, checking the driver first (Incinerator lesson). Remaining consumePower families without a live read: RepairTower (repair-point/repair-turret, catalog consumePower None — verify in Blocks.java) / ShieldWall (shielded-wall, 0.05) / ShockwaveTower (1.6667) / ItemBridge (phase-conveyor, 0.3) / LiquidBridge (bridge-conduit, consumePower None — verify) / StackConveyor (plastanium-conveyor None / surge-conveyor 0.0167) / StackRouter / ImpactReactor (25.0 — generator, verify consume vs produce) / Accelerator (interplanetary-accelerator, 10.0) / BuildTurret (build-tower, consumePower 3f, Blocks.java:2005 — NOT in catalog). Design-spec Status Summary 1623→1624 + GOAL.md §5 debt line + handoff Commits section written at completion (after gate verification).
