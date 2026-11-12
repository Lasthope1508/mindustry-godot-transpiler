# Handoff — N2145: factory power.status live read (GenericCrafter family) (C07)

Date: 2026-11-13. Batch: N2145 (single slice). Status: **GREEN DONE 2026-11-13 ~03:15 +07 (03:15 cron run, TIMED OUT before logging). Targeted 4/4 OK, neighbours 24/24 OK, Godot proof GREEN. Full gate attempt 1 RUNNING (main-thread, PID 3745, SID 3745, started ~03:31, log growing). Awaiting gate certification before report/spec/commit/push.**

## RED progress (03:00 cron run)

- State at RED time: main at 203d2f5 (N2144 merged + pushed to the fork 2026-11-13 ~02:50; C07 assembler drones_in_position done). Working tree clean except untracked `*.gd.uid` files (never stage) and untracked gate/targeted logs (pre-existing env noise, not this slice).
- javalang 0.13.0 present at run start (no reinstall needed — no VM restart since the 02:45 run). Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_factory_power_status.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 1.020s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2145'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `static func source_factory_power_status_row_state` not found in `SourceFactoryBuildState.gd` (the pure power row does not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07FactoryPowerStatusProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## What this batch is

The first of the remaining `power.status` consumer families named in the N2142/N2144 handoffs ("the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far"). N2142's live loop stamps `frame["power_status"]` each tick before the factory tick runs (`SourceFactoryRuntimeState.gd:163` vs `:192`), but the GenericCrafter tick driver never reads it: it builds its first-pass rows from the bound actors with `is_power: false` and the comment says "the power consumer stays the power graph's domain (N2080/N2107) and is not bound here" (`SourceFactoryBuildState.gd:925`), so a factory with no power still runs at full efficiency and its progress climbs by `getProgressIncrease(craftTime)` (GenericCrafter.java:238) as if `power.status` were 1.0. N2145 is the factory family's live read.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state`, via `update_consumption_non_optional_pass_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2145 does not touch it. N2145 supplies the missing pure power row over the stamped frame value + the tick-driver append.

## Scope decision (decided in RED — factory only; the other three families stay deferred)

- **Factory (GenericCrafter) — IN N2145.** One live driver (`SourceFactoryBuildState.source_factory_tick_buildings_state`, ~lines 934-957), one pure function to add, one gate (`block.properties.has("consumePower")`, the drill driver's gate). Covers GenericCrafter + AttributeCrafter + HeatCrafter + HeatProducer (all tick through `GenericCrafterBuild.updateTile()`, GenericCrafter.java:235).
- **Drill — DEFERRED, not N2145.** `SourceDrillConsumptionRuntimeState.gd:103` SKIPS blocks with a power consumer entirely (`or block.properties.has("consumePower")` → `continue`); a drill power read needs that driver's exclusion lifted first, a separate slice.
- **Turret — DEFERRED, not N2145.** Four+ implementations with their own drivers (Item/Liquid/Power/Laser/ContinuousTurret; `SourceContinuousLiquidTurretBuildState.gd:279` is only one of them) — each needs its own wiring slice.
- **Adjacent factory — DEFERRED, not N2145.** Mirrors the factory driver in a separate file (`SourceAdjacentFactoryBuildState.gd:343`); wire it after the factory pattern is proven, as its own slice.

## Exact upstream evidence (all 8 exprs verified verbatim in this VM)

- Power read (ConsumePower.java:38-40): `return build.power.status;`
- First pass (BuildingComp.java:1969, 1976): `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`
- Early return (BuildingComp.java:1944): `if(!block.hasConsumers || cheating()){`
- Progress (GenericCrafter.java:238): `progress += getProgressIncrease(craftTime);`
- Field default (PowerModule.java:13): `public float status = 0.0f;`
- Null fold convention (UnitAssembler.java:469): `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
- hasConsumers includes power (Block.java:1449, 1487): `hasConsumers = consumers.length > 0;`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceFactoryBuildState.source_factory_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update); `!enabled` is handled by the machinery's disabled branch, not here. Header comment quotes `return build.power.status;` (ConsumePower.java:39) and the null-fold line — the source-text test asserts both.
- **Driver wiring** in `source_factory_tick_buildings_state` (after the actor loop, ~line 947): if `block.properties.has("consumePower")`, append `source_factory_power_status_row_state(frame, true)["row"]` to `required_results`; and the `has_consumers` argument to `update_consumption_state` becomes `groups["has_consumers"] or has_power_consumer` (Java: `hasConsumers` counts the power consumer, Block.java:1449, so a power-only factory must not take the early return). Update the stale comment at ~line 925 ("the power consumer stays the power graph's domain (N2080/N2107) and is not bound here") to the live-read note.
- **Do NOT change** `source_factory_update_consumption_state`'s signature — N2111's `test_factory_update_consumption.py` asserts it verbatim (6 params, `[], [], []` call). It stays the caller-less pure adapter; the live driver is the wiring point.
- **Register script** `register_c07_factory_power_status.py` (modeled on the N2142 one): 2 new result symbols:
  - `source_factory_power_status_row_state_result.row` ← `return build.power.status;` (ConsumePower.java, the canonical power.status read)
  - `source_factory_power_status_row_state_result.has_power_row` ← `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969, the first pass the row joins)
  - Slice `java_source` GenericCrafter.java, `java_class` `mindustry.world.blocks.production.GenericCrafter.GenericCrafterBuild`, `java_method` `GenericCrafterBuild.updateTile()`.
  - Expected SSOT +2 symbols / +1 slice / +1 contract / +2 schemas → **11300 / 1596 / 1517 / 2825**; audit 1335. GREEN verifies actuals.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07FactoryPowerStatusProof.gd` + `.tscn` (modeled on `FactoryUpdateConsumptionProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_FACTORY_POWER_STATUS_PROOF `, 7 keys:
  - `smelter_has_power_consumer`: catalog `silicon-smelter` properties has `consumePower` (grounds the driver gate).
  - `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
  - `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
  - `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
  - `efficiency_folds_power_min`: live tick — place silicon-smelter at `Vector2i(30, 7)`, stamp `frame["power_status"] = 0.5`, call `source_factory_tick_buildings_state(game, 1.0/60.0)` → frame efficiency 0.5.
  - `progress_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0, progress unchanged.
  - `progress_half_at_half_power`: same, `power_status` 0.5 → progress increase equals `source_factory_progress_increase_state(craftTime, 0.5, ...)` (half of the full-power increase).
  - Proof JSON is gitignored, never stage it. Note: call the tick driver directly (as the N2111 proof does), not `simulate_factory`, so the graph update does not overwrite the stamped `power_status`; the write-back itself is already proven by N2142.
- **Neighbours to run in GREEN** (targeted, sequential, Godot on PATH): N2111 `test_factory_update_consumption`, `test_factory_should_consume`, N2142 `test_c07_power_status_live`, N2139 `test_c06_unit_assembler_production_tick` (shares the power_status fold convention), plus the battery power-status binding test (`test_battery_power_status_binding`) and the power-graph live-update binding test (`test_power_graph_live_update_binding`) since the frame stamp is shared.

## Files changed (RED only; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_factory_power_status.py` (new, 4 tests): registration (ledger N2145, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 8 exprs over ConsumePower.java + BuildingComp.java + GenericCrafter.java + PowerModule.java + UnitAssembler.java + Block.java), source-text (pure function exists + the two quoted Java lines in its comment + driver appends an `"is_power": true` row gated on `block.properties.has("consumePower")` + `hasConsumers = consumers.length > 0;` in its comment; proof has the 7 new keys), Godot proof (`C07FactoryPowerStatusProof.tscn`, prefix `C_07_FACTORY_POWER_STATUS_PROOF `, the 7 new keys true).
- This handoff (new, untracked).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 1.020s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2145'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **8/8 exprs found verbatim** in the 6 slice sources (ConsumePower.java, BuildingComp.java, GenericCrafter.java, PowerModule.java, UnitAssembler.java, Block.java).
- Negatives confirmed before RED: `source_factory_power_status_row_state` 0 times in `SourceFactoryBuildState.gd`; `power_status` 0 times in `SourceFactoryBuildState.gd`; `"is_power": true` 0 times in `SourceFactoryBuildState.gd`; `N2145` not in the slice ledger.
- `git diff --check` clean.
- State at RED time: main at 203d2f5 (N2144 merged + pushed to the fork 2026-11-13 ~02:50); SSOT 11298 / 1595 / 1516 / 2823; audit 1335.
- javalang 0.13.0 present at run start (no reinstall needed); Godot 4.6.2 on `~/workspace/godot-bin`.

## GREEN progress (03:15 cron run, completed by main thread ~03:31)

- Pure `source_factory_power_status_row_state(frame, has_power_consumer)` added to `SourceFactoryBuildState.gd` (definition line 237) + driver wiring (call site line 983); register script executed (SSOT actuals **11300/1596/1517/2825**, matching the RED expectation exactly); proof scene `C07FactoryPowerStatusProof` (.gd + .tscn + .json) GREEN — proof JSON 10 keys, all true, `matches: true` (7 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`; the worker counted 9 excluding `matches`). Targeted **4/4 OK** + neighbours **22/22 OK** (re-verified this run: 4+4+4+4+3+3 = 22 — correction to the worker's "24/24", the six neighbour modules total 22 tests, all pass). Neighbour fix (proof/test-harness only, no gameplay change): `FactoryShouldConsumeProof.gd` now places a thorium-reactor so `power_status=1.0` (line 82). `git diff --check` clean.

## Gate certification (03:45 cron run)

- Full gate **attempt 1 (main thread, PID 3745, setsid, SID 3745, ~03:31) FINISHED ~03:47, VERIFIED clean except Godot in this run — Ran 5677 tests in 906.499s, FAILED (failures=96, skipped=5), 0 errors. All 96 `FAIL:` blocks verified Godot-absent (`assertIsNotNone(godot)` / `unexpectedly None`), 0 `ERROR:` blocks; the N2145 module shows no failure other than its Godot-proof test.** First-attempt finish — no session-end death this time. Targeted 4/4 re-verified this run (15.479s); neighbours 22/22 re-verified this run (68.3s combined). Report + design-spec N2145 row + Status Summary 1595→1596 written this run; slice commit + docs commit + push follow.
- NO proof scene run while the gate runs (port-7777 rule). **Do NOT commit/push until the gate is certified clean except Godot.** — certified above; proceed.

## Deferred (not this slice)

- `power.status` live read for drill (driver skips power-consumer blocks), turret (four implementations), adjacent factory (separate file) — each its own slice after the factory pattern lands.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.
