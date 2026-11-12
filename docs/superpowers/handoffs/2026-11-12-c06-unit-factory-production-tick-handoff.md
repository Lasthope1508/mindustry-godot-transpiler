# Handoff — N2137: UnitFactory live production tick (progress advance + completion call)

Date: 2026-11-12. Batch: N2137 (single slice). Status: **DONE + PUSHED 2026-11-12 ~18:15 +07 (18:15 cron run): gate attempt 4 FINISHED ~18:08 — Ran 5645 in 1082.282s, FAILED (failures=88, skipped=5), 0 errors — all 88 verified Godot-absent asserts (every AssertionError `unexpectedly None`, 0 ERROR lines; N2128 module shows no failure other than its Godot-proof test). Slice commit 8e0d265 pushed to origin main; docs commit follows in this run. Next slice: N2138 Reconstructor production tick.**

GREEN done (17:00 run): register script `register_c06_unit_factory_production_tick.py` (5 new symbols), tick-driver wiring in `source_unit_factory_tick_buildings_state` (production call for UnitFactory frames only), proof `C06UnitFactoryProductionProof` (matches:true, all keys true). Targeted 4/4 OK, neighbours 8/8 (N2124 + N2125 + live loop). Main-thread verification ~17:19: SSOT confirmed 11270/1588/1507/2805; proof content all true in a standalone re-run — the re-run's single failure was ONLY the port-7777 bind ERROR, caused by a concurrently-running neighbour proof scene (`UnitFactoryLiveLoopProof`, PID 2856, still running at 17:19) holding the port; environmental, not a slice regression. Do NOT re-run the proof test while that scene runs.
**VM restart ~17:08 +07** (uptime 8 min at 17:16; killed the 16:45 worker mid-run → its timeout): javalang was wiped and NOT yet reinstalled when the 17:00 worker ran — the N2137 test module does not import javalang (grep -c = 0), which is why the worker's GREEN work succeeded without it. Main thread reinstalled javalang 0.13.0 before launching gate attempt 2.

17:15 cron run verification (~17:16-17:21 +07): targeted module re-run independently **4/4 OK in 19.0s** (Godot on PATH, proof included). Neighbours re-run: 8 real tests OK (`test_c06_power_should_consume` + `test_unit_factory_live_loop`); the single error in that run was the worker's own wrong module name (`tests.test_c06_unit_factory_should_consume` does not exist — N2124's module is `test_unit_factory_should_consume.py`), not a slice failure. Gate attempt 2 checked alive ~17:21: PID 2618, SID 2618, elapsed 5:08, 74.9% CPU, log 4838 bytes, dots only, 0 F yet. SSOT re-verified read-only: symbols 11270, ledger 1588 slices, N2137 status done. No more proof scenes run while the gate runs (port-7777 rule). Next run: verify gate result, then report + design-spec N2137 row + Status Summary 1587→1588 + changelog, commit + push to origin main.

## RED progress (16:45 cron run, 2026-11-12 ~16:45-17:00 +07)

- State at RED time: main at 9c8672e (N2136 merged + pushed to the fork 2026-11-12 ~16:45); working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present (no VM restart since the 15:15 run); Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c06_unit_factory_production_tick.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 1.018s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2137'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `source_unit_factory_production_tick_state` not found in `SourceUnitFactoryBuildState.gd` (the pure function + tick-driver wiring do not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C06UnitFactoryProductionProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The UnitFactory half of the live production wiring, the next item on the N2136 "Next" list. The live tick driver (`SourceUnitFactoryBuildState.source_unit_factory_tick_buildings_state`, wired from `SourceFactoryRuntimeState.gd:192`) runs the consumption half of `updateTile` every tick but advances no progress and calls no completion: its own comment says "The frame delta is not consumed by the wiring itself beyond that; a later slice that ticks production reads it." N2137 is that slice for the ground factory: a pure `source_unit_factory_production_tick_state` that advances `progress`/`time`/`speedScl` per `UnitFactoryBuild.updateTile()` (UnitFactory.java:392-442) and fires the completion call (`payload = new UnitPayload(unit)` + `consume()` + `UnitCreateEvent`) when `progress >= plan.time`, wired into the tick driver for `UnitFactory` implementations only. Reconstructor and UnitAssembler keep the consumption-only tick until their own production slices (N2138, N2139).

## Exact upstream evidence (all 25 exprs verified verbatim in this VM)

- `UnitFactoryBuild.updateTile()` (UnitFactory.java:392-442): `public void updateTile(){` / `if(!configurable){` / `currentPlan = 0;` / `if(currentPlan < 0 || currentPlan >= plans.size){` / `currentPlan = -1;` / `if(efficiency > 0 && currentPlan != -1){` / `time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team);` / `progress += edelta() * Vars.state.rules.unitBuildSpeed(team);` / `speedScl = Mathf.lerpDelta(speedScl, 1f, 0.05f);` / `speedScl = Mathf.lerpDelta(speedScl, 0f, 0.05f);` / `moveOutPayload();` / `if(currentPlan != -1 && payload == null){` / `if(plan.unit.isBanned()){` / `if(progress >= plan.time){` / `progress %= 1f;` / `Unit unit = plan.unit.create(team);` / `payload = new UnitPayload(unit);` / `payVector.setZero();` / `consume();` / `Events.fire(new UnitCreateEvent(payload.unit, this));` / `progress = Mathf.clamp(progress, 0, plan.time);` / `progress = 0f;`
- `BuildingComp.edelta()` (BuildingComp.java:1927-1928): `return efficiency * delta();`
- `Rules.unitBuildSpeed` (Rules.java:271-272): `return unitBuildSpeedMultiplier * teams.get(team).unitBuildSpeedMultiplier;`
- `UnitType.isBanned()` (UnitType.java:759-761): `return state.rules.isBanned(this);`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceUnitFactoryBuildState.source_unit_factory_production_tick_state(frame, plan, plans_count, edelta, unit_build_speed, source_delta)` — one tick of `UnitFactoryBuild.updateTile()` (UnitFactory.java:392-442), UnitFactory only. `frame` carries `efficiency` (default 1.0), `current_plan` (default -1), `payload` (default null), `progress`/`time`/`speed_scl` (defaults 0.0 — `UnitBuild` float fields, Java default 0f), `configurable` (default true). `plan` is the current plan dict from `source_unit_factory_plan_requirements_state` (`unit` + `time`); `plans_count` is `block.properties.unitPlans.size()` for the bounds check. `edelta` is `efficiency * delta` (BuildingComp.java:1927-1928); `unit_build_speed` is `Rules.unitBuildSpeed(team)` (Rules.java:271-272); `source_delta` is the tick delta for `lerpDelta` (`SourceMathState.source_lerp_delta`, `Mathf.lerpDelta` = `lerp(from, to, clamp(progress * Time.delta))`).
  - `if(!configurable) current_plan = 0;` then `if(current_plan < 0 or current_plan >= plans_count) current_plan = -1;`
  - `if(efficiency > 0 and current_plan != -1)`: `time += edelta * speed_scl * unit_build_speed`; `progress += edelta * unit_build_speed`; `speed_scl = lerpDelta(speed_scl, 1.0, 0.05, source_delta)`; else `speed_scl = lerpDelta(speed_scl, 0.0, 0.05, source_delta)`.
  - `moveOutPayload()` is NOT modeled here — deferred (payload transport slice). Consequence, faithful to the code path: a payload created last tick stays in the frame, so the next tick's `payload != null` branch resets `progress = 0` until the move-out slice lands.
  - `if(current_plan != -1 and payload == null)`: banned check first — `plan.unit.isBanned()` reads the banned-units list from `rules_state` (GREEN check: `rules_state` key for `bannedUnits`, default empty; `Rules.isBanned` is already a registry symbol); if banned → `current_plan = -1`, return early (Java `return`s from `updateTile`, skipping the clamp). Then `if(progress >= plan.time)`: `progress = fmod(progress, 1.0)`; `completed = true`; `payload = {"unit": plan.unit}`; `consumed = true`; `unit_created_event = true` (no live event bus — the event is recorded as state, like the N2128 consume trigger). `payVector.setZero()` is presentation, not state — not modeled. Then `progress = clamp(progress, 0, plan.time)`. Else (payload present or no plan): `progress = 0`.
  - Returns `{"source_owner": <new registry const PORT_GAME_SOURCE_UNIT_FACTORY_BUILD_PRODUCTION_TICK_STATE>, "current_plan", "progress", "time", "speed_scl", "completed", "payload", "consumed", "unit_created_event", "banned"}`. The function's header comment quotes the two advance/completion lines verbatim (`progress += edelta() * Vars.state.rules.unitBuildSpeed(team);`, `payload = new UnitPayload(unit);`) — the source-text test asserts them.
- **Tick-driver wiring** in `source_unit_factory_tick_buildings_state`, after the consumption block, gated on `block.implementation == "UnitFactory"` (Reconstructor/Assembler keep the consumption-only tick): fetch the plan via `source_unit_factory_plan_requirements_state(block, current_plan)` and `plans_count` from `block.properties.unitPlans`; `edelta = frame["efficiency"] * seconds * TICK_RATE`; `unit_build_speed` from `rules_state` (`unitBuildSpeedMultiplier`, Rules.java:81 default 1f, × team multiplier default 1.0 — GREEN check: which `rules_state` key carries it, default 1.0 when absent); `source_delta = seconds * TICK_RATE`; call the pure function; write `progress`/`time`/`speed_scl`/`current_plan`/`payload` back into the frame; on `completed`, call the N2128 consume state `source_unit_factory_consume_state(frame, consumers, rows)` with the already-bound rows/consumers and record the result. Update the stale tick-driver comment ("a later slice that ticks production reads it" — the source-text test asserts it is gone): production is live for UnitFactory (N2137); Reconstructor/Assembler still read the consumption half only.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C06UnitFactoryProductionProof.gd` + `.tscn` (modeled on `C06UnitFactoryShouldConsumeProof`, same Main scene), prefix `C_06_UNIT_FACTORY_PRODUCTION_PROOF `, 5 keys driving the pure function directly on a bound ground-factory frame (dagger plan, 900 ticks — deterministic, no tick-driver timing):
  - `production_progress_advances`: efficiency 1.0, plan 0, edelta 1.0 → progress 0 → 1.0.
  - `production_time_advances`: speed_scl 1.0, edelta 1.0 → time 0 → 1.0.
  - `production_no_plan_no_progress`: current_plan -1 → progress unchanged, speed_scl lerps toward 0 (1.0 → 0.95 at source_delta 1.0).
  - `production_completes_payload`: progress 899.5 + edelta 1.0 = 900.5 ≥ 900 → completed true, payload unit dagger, progress fmod → 0.5 then clamp → 0.5, consumed true.
  - `production_payload_present_resets_progress`: payload present → progress 0.
  - GREEN check: cells free on the Main scene; proof JSON is gitignored, never stage it.
- **Register script** `register_c06_unit_factory_production_tick.py` (GREEN, modeled on the N2136 one): 5 new symbols, one per returned value, each with its Java line as `java_expr`:
  - `source_unit_factory_production_tick_state_result.progress` ← `progress += edelta() * Vars.state.rules.unitBuildSpeed(team);`
  - `source_unit_factory_production_tick_state_result.time` ← `time += edelta() * speedScl * Vars.state.rules.unitBuildSpeed(team);`
  - `source_unit_factory_production_tick_state_result.speed_scl` ← `speedScl = Mathf.lerpDelta(speedScl, 1f, 0.05f);`
  - `source_unit_factory_production_tick_state_result.completed` ← `if(progress >= plan.time){`
  - `source_unit_factory_production_tick_state_result.current_plan` ← `if(currentPlan < 0 || currentPlan >= plans.size){`
  - All share `java_source` UnitFactory.java, `godot_owner` `SourceUnitFactoryBuildState.source_unit_factory_production_tick_state`. Ledger N2137 entry: `status: done`, `java_source: core/src/mindustry/world/blocks/units/UnitFactory.java`, `java_class: mindustry.world.blocks.units.UnitFactory.UnitFactoryBuild`, `java_method: UnitFactoryBuild.updateTile()`, `godot_owner: SourceUnitFactoryBuildState.source_unit_factory_production_tick_state`, `exact_exprs`: the 25 exprs above, `source_symbols`: the 5 new symbols, `tests`: the 4 test names of the new module, `runtime_proof: /root/C06UnitFactoryProductionProof`, `deferred_exprs`: Reconstructor production tick, UnitAssembler production tick + spawned(), intake call site, moveOutPayload transport, Units.canCreate live evaluation, lastTier/progress reset, module link/unlink call sites, live-loop belt enabled gate, C06–C12 open.
  - Expected SSOT +5/+1/+2/+1 → **11270 / 1588 / 1508 / 2804**; audit 1335 — VERIFY in GREEN (N2134 precedent was +4/+1/+1/+2 for one new function; the register script prints the actuals).
- The N2124/N2125 test modules need NO change (shouldConsume and the stamp are untouched; the tick driver only gains the production call for UnitFactory frames). Verify in GREEN by running them as neighbours alongside the N2137 targeted module.

## Files changed (RED only)

- `tools/mindustry_godot_transpiler/tests/test_c06_unit_factory_production_tick.py` (new, 4 tests): registration (ledger N2137, 5 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (5 new symbols + 25 exprs over UnitFactory.java + Rules.java + BuildingComp.java + UnitType.java), source-text (pure function exists + tick driver calls it + the two quoted Java lines in the function comment + no "a later slice that ticks production reads it" comment; proof has the 5 new keys), Godot proof (`C06UnitFactoryProductionProof.tscn`, prefix `C_06_UNIT_FACTORY_PRODUCTION_PROOF `, the 5 new keys true).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 1.018s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2137'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **25/25 exprs found verbatim** in the 4 slice sources (UnitFactory.java, Rules.java, BuildingComp.java, UnitType.java).
- `git diff --check` clean.
- State at RED time: main at 9c8672e (N2136 merged + pushed to the fork 2026-11-12 ~16:45); SSOT 11265 / 1587 / 1506 / 2803; audit 1335.

## GREEN work remaining (next run)

1. Write + run the register script (verify SSOT totals, expected 11270 / 1588 / 1508 / 2804, audit 1335).
2. Implement the pure production tick function + registry const + tick-driver wiring (UnitFactory only) + stale-comment update.
3. Write the proof scene (5 new keys, dagger plan, 900 ticks).
4. Targeted tests GREEN 4/4 + neighbours (N2124 + N2125, verify no change needed).
5. Full Python gate (213 modules) — **attempt 1 DIED ~17:15 +07 (session-end, log frozen 2793 bytes, preserved as `full-suite-n2137-gate-attempt1.log`); attempt 2 FINISHED ~17:45 +07: Ran 5645 in 1159.3s, FAILED (failures=89, skipped=5), 0 errors — 88 Godot-absent asserts + 1 REAL failure (N2128 consume-trigger blanket assert, fixed test-only — see status line; result log preserved as `full-suite-n2137-gate-attempt2.log`); attempt 3 DIED ~17:49 +07 (session-end, log frozen 3433 bytes, preserved as `full-suite-n2137-gate-attempt3.log`); attempt 4 (setsid, PID 6018, ~17:50) FINISHED ~18:08 +07: Ran 5645 in 1082.282s, FAILED (failures=88, skipped=5), 0 errors — all 88 verified Godot-absent (`unexpectedly None`, 0 ERROR lines), verified clean except Godot in the 18:15 cron run.** javalang 0.13.0 reinstalled by the main thread before attempt 2 (VM restart ~17:08 had wiped it; attempt 1 ran in a javalang-less env, so its results would have been invalid anyway).
6. Godot proof GREEN (5 keys, all true, `matches: true`) — via the targeted proof test.
7. Report + design-spec N2137 row + Status Summary 1587→1588 + changelog row + this handoff, then commit + push to the fork (origin main) only when the gate is verified clean except Godot. Stage the exact slice files only (never `*.gd.uid`, `project.godot`, `arc-upstream/`, `mindustry-upstream/`, proof `.json`, gate logs).

## Next (after N2137 lands)

- N2138: Reconstructor live production tick (Reconstructor.java:317-356 — constructing cache, progress advance, upgrade on completion, `progress %= 1f`, `consume()`, `UnitCreateEvent`).
- N2139: UnitAssembler live production tick (UnitAssembler.java:429-571 — progress advance, `spawned()` call at completion, drone progress, tier/lastTier reset; intake call site `moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503).
- Then C07–C12 per the completion backlog.

## Deferred (not this slice)

- Reconstructor production tick (Reconstructor.java:317-356) — N2138.
- UnitAssembler production tick + `spawned()` (UnitAssembler.java:429-571) — N2139.
- The intake call site (`moveInPayload() && !wasOccupied`, UnitAssembler.java:500-503) — belongs to the UnitAssembler production wiring.
- `moveOutPayload()` transport — the production tick does not move a completed payload out yet; a completed factory's next tick resets progress to 0 until the move-out slice lands.
- `Units.canCreate` live evaluation (needs C07: live per-type unit counts + the unit cap); the assembler branch keeps reading `frame["can_create"]`, default true, until then.
- `lastTier` tracking + progress reset on tier change (UnitAssembler.java:441-447) — belongs to the UnitAssembler production/tick wiring.
- The live-loop module link/unlink call sites: `updateModules`/`removeModule` are called from `UnitAssemblerModuleBuild` link/unlink (UnitAssemblerModule.java:80-83) — the port has no live module-linking frame event yet.
- Live-loop belt enabled gate (sprite-`enabled` seam) — the pure advance function takes efficiency since N2135; the caller is the missing half.
- C06–C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.

## Commit

DONE + PUSHED 2026-11-12 ~18:15 +07 (18:15 cron run): slice commit 8e0d265 (15 files, `git diff --check` clean) + docs commit (this handoff + report + design spec) on origin main. Gate verified clean except Godot (Ran 5645, failures=88, skipped=5, 0 errors — all 88 Godot-absent asserts).
