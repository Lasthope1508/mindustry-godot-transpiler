# Report — N2177: ShockwaveTower power.status live read (shockwave-tower) (C07)

Date: 2026-11-14. Batch: N2177 (single slice). Status: **DONE — push next (gate clean except Godot; targeted 4/4 OK, neighbours 164/164 OK, Godot proof GREEN 9 keys matches:true, full gate attempt 2 Ran 5805 in 973.411s, failures=128, skipped=5, 0 errors — all 128 verified Godot-absent asserts). Slice commit `444aa04`.**

## What changed

The next `power.status` consumer family after the N2176 repair-tower slice: the ShockwaveTower implementation family — a SINGLE def, **shockwave-tower** (`consumePower(100f / 60f)`, Blocks.java:2042; size 3, range 170f, reload 80f, Blocks.java:2038-2044). ShockwaveTower extends Block (ShockwaveTower.java:22, `public class ShockwaveTower extends Block{`); its build extends Building (ShockwaveTower.java:66, `public class ShockwaveTowerBuild extends Building`). Catalog confirms implementation ShockwaveTower + hasPower true + consumesPower true + consumePower 1.6666666666666667 + outputsPower false + powerUsage 1.6666666666666667 + connectedPower true (content_registry_blocks.json, `content_registry.blocks.shockwave-tower`). Blocks.java defs are the source of truth, see Exact exprs in the handoff.

The shockwave tower had NO driver at all — no `SourceShockwaveTower*` file exists in godot-mindustry/src/game, no `"ShockwaveTower"` entry in any `SOURCE_*_IMPLEMENTATIONS` list (grep for `"ShockwaveTower"` in `godot-mindustry/src/game/` returns nothing), and no frame key existed, so the N2142 stamp never reached a shockwave-tower frame. The Incinerator lesson was applied: the candidate was checked for an existing driver before scoping.

**Naming note:** "ShockwaveTower" is a defense block (`world/blocks/defense/ShockwaveTower.java`), NOT related to RepairTower (N2176) or ShieldWall (N2175). Single def **shockwave-tower** (Blocks.java:2038), Category.effect.

The efficiency coupling that makes this slice matter: `updateTile` fires only inside `if(potentialEfficiency > 0 && (reloadCounter += edelta()) >= reload && timer(timerCheck, checkInterval)){` (ShockwaveTower.java:73) — so a shockwave tower with no power never charges its reload counter (edelta() = efficiency * delta(), BuildingComp.java:1928) and never fires its wave, while the port without this slice would behave as if power.status were 1.0. `potentialEfficiency` is assigned the folded efficiency before the `if(!update)` zeroing (BuildingComp.java:1988-1994), so the firing coupling follows the folded value. N2177 is the shockwave tower's live read — the same proven N2145–N2176 pure-row pattern, on the N2173 radar precedent (new family file + own driver + own frame key + simulate_factory wiring): one new pure function on a new state file + a driver fold + a new frame key + the wiring.

**Power is STATIC here** — unlike RepairTurret's conditional draw: `consumePower(100f / 60f)` registers a plain ConsumePower, so the catalog `consumePower: 1.6666666666666667` is present and the plain radar gate `block.properties.has("consumePower")` works — no RepairTurret-style `or consumesPower` adaptation needed. The pure row is the same ConsumePower read (`return build.power.status;`, ConsumePower.java:39).

**shouldConsume override — reload-gated, deferred per the N2174/N2176 precedent:** `ShockwaveTowerBuild.shouldConsume()` returns `reloadCounter < reload;` (ShockwaveTower.java:121-122). When the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994). Decided at scoping, per the N2174 precedent (fold power-only per PointDefenseTurret N2151): the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) and the gate is DEFERRED — when the tower is fully reloaded (reloadCounter >= reload) power.status reads 1.0 while Java efficiency is 0. The gap is recorded in the pure function's comment, not silently skipped.

New file `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd`, class_name SourceShockwaveTowerBuildState, with `SOURCE_SHOCKWAVE_TOWER_BUILD_IMPLEMENTATIONS := ["ShockwaveTower"]` and frame meta key `"source_shockwave_tower_building"`:

- Pure `source_shockwave_tower_power_status_row_state(frame, has_power_consumer)` (mirrors `source_repair_tower_power_status_row_state`): without a consumer → `{"has_power_row": false, "row": {}}`; else `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live is the stamped frame value, null folding to 1.0 (the assembler convention, UnitAssembler.java:469).
- `source_shockwave_tower_tick_frame_state` (mirrors the repair-tower tick-frame: block_implementation / team_id / rules_state / cheating via TeamComp.cheating(), preserve disabled frame).
- `source_shockwave_tower_bind_frame_state` (mirrors the repair-tower bind: empty frame under the shockwave-tower meta key, no-op for other blocks / already-bound sprites).
- Driver `source_shockwave_tower_tick_buildings_state(game, seconds)` (mirrors the repair-tower driver: iterate placed buildings, match implementation, bind frame, tick frame, when the block has the static power consumer and enabled and not cheating fold the pure row via `source_building_efficiency_state.update_consumption_state(true, ...)` with has_consumers=true — the power consumer counts toward hasConsumers, Block.java:1449 — and apply it; no consumer actors, no production tick, no updateTile wave advance).

Header quotes all 26 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.

New frame key `"source_shockwave_tower_building"` added to `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` so the N2142 graph stamp/write-back finds the shockwave-tower frame. Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload `source_shockwave_tower_build_state` (:39) + call `source_shockwave_tower_tick_buildings_state(game, delta)` (:439, immediately after the repair-tower call :430).

Documented limits in the pure function's comment, same discipline as N2148–N2176: (1) power-only first pass — the folded efficiency is the min over the *modeled* consumers (power only); the cyanogen liquid consumer (`consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f))`, Blocks.java:2041, 1.5f/60f = 0.025) waits for its own slice (the N2174 coolant / N2176 ozone precedent). (2) shouldConsume gate deferred — ShockwaveTowerBuild overrides shouldConsume (`return reloadCounter < reload;`, ShockwaveTower.java:121-122); when the gate is false Java forces efficiency to 0 (BuildingComp.java:1960 + 1992-1994); the driver runs with should_consume=true when enabled (the MendProjector suppression precedent) — when fully reloaded power.status reads 1.0 while Java efficiency is 0. (3) No updateTile wave advance — reloadCounter charge / bullet scan / wave damage / heat / cooldown (ShockwaveTower.java:73-104) wait for their own slices; the proof carries no wave/heat/target keys, the reload charge (ShockwaveTower.java:73) is what the efficiency keys prove. (4) No sense/warmup modeling — `sense(LAccess.progress)` (:110) and `warmup()` returning heat (:117) wait for their own slices. (5) Single def — shockwave-tower only (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100); per-def stat values wait for their own verification slice. (6) No draw modeling — heatRegion / shape draw (:128-138) wait for their own slices.

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_shockwave_tower_power_status.py` + register script `tools/mindustry_godot_transpiler/register_c07_shockwave_tower_power_status.py` written, modeled on the N2176 pair. Register script: docstring rewritten for ShockwaveTower, EXACT_EXPRS = the 26 verified exprs, DEFERRED 162 (154 inherited + 8 new ShockwaveTower entries: updateTile advance, shouldConsume gate, liquid cyanogen row, sense/warmup, draw/drawSelect, shape/timer fields, trigger, per-def stats). Both files py_compile OK.

RED run: Ran 4 tests in 1.435s, FAILED (failures=1, errors=3) — exactly as expected for a new-file slice: registration + exact-evidence error on missing N2177 ledger entry (KeyError: 'N2177'), row-state errors FileNotFoundError on the not-yet-existing `SourceShockwaveTowerBuildState.gd`, proof fails `Cannot open file 'res://tools/runtime_proofs/C07ShockwaveTowerPowerStatusProof.tscn'` — all four fail for the expected missing-artifact reasons, none passes spuriously. Port 7777 was FREE before the run. 26/26 exact exprs verified verbatim at scoping. SSOT baseline 11362/1627/1548/2887, audit 1335. `git diff --check` OK.

**javalang 0.13.0 confirmed present at run start** (no reinstall needed — no VM restart since the N2176 scoping reinstall).

## GREEN

- New `godot-mindustry/src/game/SourceShockwaveTowerBuildState.gd` (radar N2173 precedent): pure row + tick-frame + bind + driver, plain `block.properties.has("consumePower")` gate — static power, no RepairTurret-style adaptation; folds via `update_consumption_state` with has_consumers=true. Header quotes all 26 exact exprs, each on ONE comment line. All 6 documented limits recorded in the pure function's comment.
- Frame key `"source_shockwave_tower_building"` appended to `SOURCE_CONSUMER_FRAME_META_KEYS` (SourcePlacedPowerGraphState.gd, after the repair-tower key). Wiring in `SourceFactoryRuntimeState.simulate_factory`: preload (:39) + call immediately after the repair-tower call (:439).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07ShockwaveTowerPowerStatusProof.gd` + `.tscn` (N2174/N2176 model, prefix `C_07_SHOCKWAVE_TOWER_POWER_STATUS_PROOF `, 6 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run: SSOT **11364/1628/1549/2889** — exactly the expected values (+2/+1/+1/+2); audit 1335 unchanged; ledger N2177 status done. Defense shard changed (`defense_slices.json` + `defense_api_contracts.json`) — ShockwaveTower.java is in `world/blocks/defense/`, same pattern as N2173/N2175.
- Targeted: **Ran 4 tests, OK** — main-thread re-run 4/4 OK in 16.222s (Godot 4.6.2 on PATH). Port 7777 FREE before the run. `git diff --check` OK.
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `shockwave_tower_has_power_consumer`, `power_row_half`, `power_row_absent_without_consumer`, `power_row_null_folds_one`, `efficiency_folds_power_min`, `efficiency_zero_at_no_power`, `registry_valid`, `one_headquarter_per_ssot`, `matches`. No ERROR in output.

## Neighbours

Main-thread verification, ~20:40 +07: targeted re-run **4/4 OK in 16.222s**; family **132/132 OK in 490.657s** (33 modules, log `tools/mindustry_godot_transpiler/n2177-neighbours.log`, footer verified on disk — 132 dots, no F); wiring-standard set **32/32 OK** (9 modules, main-thread re-run, no flake, each ~15s). Total **164/164 OK**.

**Correction of the 20:30 worker's wiring claim:** the worker reported "36 tests, 2 failures" for the wiring set — that claim is WRONG. The standard wiring set is 9 modules / 32 tests; the clean re-run of exactly those 9 modules gives 32/32 OK. The worker's 36 = 32 + 4, i.e. it ran one extra module (most likely the N2177 test module itself) and its 2 failures are not a regression in any wiring module. No wiring failure exists.

## Gate

Full gate attempt 1 **launched from the MAIN THREAD ~20:49 +07** by main thread: `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2177-gate.log 2>&1 < /dev/null &` — **PID 16505, SID 16505 (own session), PPID 16502 (background subshell), CPU ~83%, log growing**. Single gate only. No Godot on PATH. No proof scene ran while the gate ran (port-7777 rule).

Attempt 1 **DIED ~21:03 +07 on a VM restart** (94% done): `uptime` showed "up 1 min" at 21:04, javalang wiped (ModuleNotFoundError — reinstalled 0.13.0 right after), no unittest process left. Log `full-suite-n2177-gate.log` ends mid-stream at **5,475/5,805 tests (5,363 dots + 112 F, 0 E), NO footer** — ~330 tests short. No port-7777 error in the log — the death is environmental (restart), NOT a regression.

Attempt 2 **launched from the MAIN THREAD ~21:05 +07** by main thread (javalang 0.13.0 reinstalled BEFORE the launch): `cd tools/mindustry_godot_transpiler && python3 -c "import javalang" && setsid nohup python3 -m unittest discover -s tests > full-suite-n2177-gate2.log 2>&1 < /dev/null &` — **PID 1784, SID 1784 (own session), PPID 1781 (background subshell), CPU ~88%**. Single gate only.

Finished ~21:22 +07: **Ran 5805 tests in 973.411s, FAILED (failures=128, skipped=5)** — no errors field, 0 `ERROR:` lines. All 128 verified Godot-absent (grep on the log by the 21:30 cron worker): **128 × `AssertionError: unexpectedly None`** (127 inherited + 1 new N2177 proof test), 128 `FAIL:` lines, 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected. No VM restart during attempt 2 (uptime 27 min at 21:30, javalang 0.13.0 still present). Gate back to normal speed (973s vs N2175's 1774s, N2176's 1136s).

**Transient overlap note:** at gate launch a 20:45 cron worker was mid-run of a targeted test (PID 16484/16485) — it finished ~20:49, seconds after the gate started, while the gate was still in its early fast tests. No port-7777 error appears anywhere in the attempt-2 log, so the overlap caused no failure.

## Commits

- Slice: `444aa04` — C07: N2177 ShockwaveTower power.status live read (shockwave-tower; pure power row + driver wiring; proof 6 keys), 13 files.
- Docs: (this commit) — Docs: N2177 report + design spec + handoff (gate clean except Godot).
- GOAL: (next commit) — Docs: GOAL.md names the N2177 slice commit (444aa04) that carries its proof to Windows.
- Pushed (pending) to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- ShockwaveTower updateTile wave advance (reloadCounter charge / bullet scan / wave damage / heat / cooldown, ShockwaveTower.java:73-104) — its own slice.
- shouldConsume gate (`return reloadCounter < reload;`, ShockwaveTower.java:121-122) — its own slice; observable gap efficiency 1.0 vs 0.0 when fully reloaded.
- Cyanogen liquid consumer (`consumeLiquids(LiquidStack.with(Liquids.cyanogen, 1.5f / 60f))`, Blocks.java:2041) — its own slice.
- sense / warmup (`sense(LAccess.progress)` returns `reloadCounter / reload`, ShockwaveTower.java:110; `warmup()` returns `heat`, ShockwaveTower.java:117) — their own slices.
- Draw modeling (heatRegion / shape draw, ShockwaveTower.java:128-138) — its own slice.
- Per-def stat values (size 3, range 170f, reload 80f, surge-alloy 50 / silicon 150 / oxide 30 / tungsten 100) — their own verification slice.
- Next candidates (verified in the N2176 report, not yet scoped): ItemBridge (phase-conveyor, 0.30f), LiquidBridge (bridge-conduit: NO power def — but phase-conduit, same implementation, HAS consumePower 0.30f; family split needs care at scoping), StackConveyor (plastanium-conveyor: NO power def; surge-conveyor: 1f/60f = 0.0167), StackRouter (surge-router, 3f/60f = 0.05), ImpactReactor (impact-reactor, consumePower 25f BUT outputsPower true — generator, consume-vs-produce needs care at scoping), Accelerator (interplanetary-accelerator, 10f), BuildTurret (build-tower, 3f, Blocks.java:2005).
