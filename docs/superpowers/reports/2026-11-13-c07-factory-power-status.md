# Report — N2145: factory power.status live read (GenericCrafter family) (C07)

Date: 2026-11-13. Batch: N2145 (single slice). Status: **DONE + PUSHED 2026-11-13 ~03:50 +07 (03:45 cron run). Targeted tests 4/4 OK, neighbours 22/22 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5677, failures=96, skipped=5, 0 errors — all 96 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The first of the remaining `power.status` consumer families named in the N2142/N2144 handoffs ("the write-back stamps every consumer's frame generically, but only the unit-factory driver reads `frame["power_status"]` so far"). N2142's live loop stamps `frame["power_status"]` each tick before the factory tick runs (`SourceFactoryRuntimeState.gd:163` vs `:192`), but the GenericCrafter tick driver never read it: it built its first-pass rows from the bound actors with `is_power: false` and the comment said "the power consumer stays the power graph's domain (N2080/N2107) and is not bound here" (`SourceFactoryBuildState.gd:925`), so a factory with no power still ran at full efficiency and its progress climbed by `getProgressIncrease(craftTime)` (GenericCrafter.java:238) as if `power.status` were 1.0. N2145 is the factory family's live read.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state`, via `update_consumption_non_optional_pass_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2145 does not touch it. N2145 supplies the missing pure power row over the stamped frame value + the tick-driver append.

Pure `SourceFactoryBuildState.source_factory_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update); `!enabled` is handled by the machinery's disabled branch, not here. Header comment quotes `return build.power.status;` (ConsumePower.java:39) and the null-fold line.

Driver wiring in `source_factory_tick_buildings_state` (call site line 983): if `block.properties.has("consumePower")` (and the frame is enabled and not cheating), append `source_factory_power_status_row_state(frame, true)["row"]` to `required_results`; and the `has_consumers` argument to `update_consumption_state` becomes `groups["has_consumers"] or has_power_consumer` (Java: `hasConsumers` counts the power consumer, Block.java:1449, so a power-only factory must not take the early return). The stale comment at ~line 925 ("the power consumer stays the power graph's domain (N2080/N2107) and is not bound here") is replaced with the live-read note.

Scope decision (decided in RED): **factory only**; drill, turret and adjacent factory stay deferred — drill's driver skips power-consumer blocks entirely (`SourceDrillConsumptionRuntimeState.gd:103`), turret has four implementations with their own drivers, adjacent factory mirrors the driver in a separate file (`SourceAdjacentFactoryBuildState.gd:343`).

Neighbour fix (proof/test-harness only, no gameplay change): `FactoryShouldConsumeProof.gd` now places a thorium-reactor so `power_status=1.0` — since N2145 the factory tick driver reads the live `power.status`, and the live loop's graph update stamps 0.0 when no producer feeds the graph, so an unpowered factory ticks at efficiency 0 no matter what shouldConsume says.

## Proof keys (new scene, 7 keys)

New scene `C07FactoryPowerStatusProof` (modeled on `FactoryUpdateConsumptionProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_FACTORY_POWER_STATUS_PROOF `:

- `smelter_has_power_consumer`: catalog `silicon-smelter` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place silicon-smelter at `Vector2i(30, 7)`, stamp `frame["power_status"] = 0.5`, call `source_factory_tick_buildings_state(game, 1.0/60.0)` → frame efficiency 0.5.
- `progress_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0, progress unchanged.
- `progress_half_at_half_power`: same, `power_status` 0.5 → progress increase equals `source_factory_progress_increase_state(craftTime, 0.5, ...)` (half of the full-power increase).

## Verified numbers (measured in this VM)

- Test module `test_c07_factory_power_status.py`: **4/4 OK in 15.5s** (Godot on PATH, re-verified this run; 15.479s) — registration (ledger N2145, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 8 exprs over ConsumePower.java + BuildingComp.java + GenericCrafter.java + PowerModule.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the two quoted Java lines in its comment + driver appends an `"is_power": true` row gated on `block.properties.has("consumePower")` + `hasConsumers = consumers.length > 0;` in its comment; proof has the 7 new keys), and the Godot proof test (7 new keys, all true, `matches: true`).
- RED run (03:00 cron run): 4 tests in 1.020s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2145'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential, re-verified this run): **22/22 OK** — `test_factory_update_consumption` 4/4 + `test_factory_should_consume` 4/4 + `test_c07_power_status_live` 4/4 + `test_c06_unit_assembler_production_tick` 4/4 + `test_battery_power_status_binding` 3/3 + `test_power_graph_live_update_binding` 3/3. (Correction to the GREEN handoff's "24/24": the six neighbour modules total 4+4+4+4+3+3 = 22 tests; all pass.)
- Godot proof: **GREEN 2026-11-13 ~03:15 +07** (03:15 cron run) — proof JSON 10 keys, all true, `matches: true` (7 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11300 / 1596 / 1517 / 2825**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2145 4/4 (proof green, see above); neighbours 22/22.
- Full Python suite, inclusive gate with the N2145 module (log `tools/mindustry_godot_transpiler/full-suite-n2145-gate.log`, 211 modules): **FINISHED ~03:47 +07, VERIFIED clean except Godot in this run — Ran 5677 tests in 906.499s, FAILED (failures=96, skipped=5), 0 errors. All 96 failures verified Godot-absent: 96 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None`, 0 `ERROR:` blocks; the N2145 module shows no failure other than its Godot-proof test.** Gate attempt 1 (main-thread, setsid, PID 3745, ~03:31) finished clean on the first attempt — no session-end death this time. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). No VM restart since the 02:45 run; javalang 0.13.0 present, no reinstall needed.

## Deferred

- `power.status` live read for drill (driver skips power-consumer blocks — the exclusion must be lifted first), turret (four implementations, each its own wiring slice), adjacent factory (separate file, mirrors the factory driver) — each its own slice after the factory pattern lands.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — `checkSolid(spawn, false/true)` (UnitAssembler.java:675-680) needs tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — canonical `allow_update_state` exists but the driver cannot supply its inputs (`rules_state` carries only `unitCostMultiplier` + `teams`, no `env` / map limits); waits for a rules-state capture slice.
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — the count reads the recorded `in_position` flag; the units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open. Next candidate: N2146 scopes from the deferred list at RED — leading candidate is `power.status` for the next consumer family (drill, turret, or adjacent factory).

See `handoffs/2026-11-13-c07-factory-power-status-handoff.md` for the full detail.
