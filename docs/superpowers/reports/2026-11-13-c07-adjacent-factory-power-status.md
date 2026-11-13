# Report — N2146: adjacent-factory power.status live read (Separator/Incinerator/WallCrafter/SingleBlockProducer family) (C07)

Date: 2026-11-13. Batch: N2146 (single slice). Status: **DONE + PUSHED 2026-11-13 ~07:52 +07 (07:45 cron run). Targeted tests 4/4 OK, neighbours 16/16 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5681, failures=97, skipped=5, 0 errors — all 97 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The second of the remaining `power.status` consumer families named in the N2142/N2144/N2145 handoffs. N2142's live loop stamps `frame["power_status"]` each tick before the factory tick runs, and the write-back is generic: `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` includes `"source_adjacent_factory_building"`, so adjacent-family frames already receive the live status. But the adjacent-family tick driver never read it: it built its first-pass rows from the bound actors with `is_power: false` and the comment said "the power consumer stays the power graph's domain (N2080/N2107) and is not bound here" (`SourceAdjacentFactoryBuildState.gd:326`), so a separator with no power still ran at full efficiency and its progress would climb by `getProgressIncrease(craftTime)` (Separator.java:142) as if `power.status` were 1.0. N2146 is the adjacent family's live read — the same proven N2145 pattern, one file over.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state`, via `update_consumption_non_optional_pass_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2146 does not touch it. N2146 supplies the missing pure power row over the stamped frame value + the tick-driver append.

Pure `SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update); `!enabled` is handled by the machinery's disabled branch, not here. Header comment quotes `return build.power.status;` (ConsumePower.java:39), the null-fold line, and `hasConsumers = consumers.length > 0;` (Block.java:1449).

Driver wiring in `source_adjacent_factory_tick_buildings_state` (call site line 379): if `block.properties.has("consumePower")`, append `source_adjacent_factory_power_status_row_state(frame, true)["row"]` to `required_results`. The stale comment at ~line 326 ("the power consumer stays the power graph's domain (N2080/N2107) and is not bound here") is replaced with the live-read note. No `has_consumers` fix needed — unlike N2145, the adjacent driver already passes `_has_consumers_state(block)` to `update_consumption_state`, and that helper already counts the power consumer, so a power-only adjacent block (incinerator) already takes no early return.

Scope decision (decided in RED): **adjacent factory only; no progress keys in the proof** — unlike the factory driver, the adjacent driver does not advance progress at all (`SourceAdjacentFactoryBuildState.gd` contains zero occurrences of `progress` / `getProgressIncrease` / `craftTime`), so Separator's `progress += getProgressIncrease(craftTime);` (Separator.java:142, gated on `efficiency > 0`) is unwired and the proof cannot assert progress through the tick driver; progress advance is its own later slice. Drill stays deferred (its driver skips power-consumer blocks entirely, `SourceDrillConsumptionRuntimeState.gd:102`); turret stays deferred (four implementations with their own drivers).

Neighbour fix (proof/test-harness only, no gameplay change): both adjacent neighbour scenes placed power-consuming adjacent blocks but no power producer, so after N2146 the graph stamped `power_status=0` → efficiency 0 (correct Java). Fix, same class as N2145's FactoryShouldConsumeProof reactor fix: place a thorium-reactor (`blocks_by_id["thorium-reactor"]`, cell (25,7), powerProduction 15.0, no fuel in the port's producer model) in `AdjacentFactoryConsumerBindingProof.gd` and `AdjacentFactoryLiveLoopProof.gd`. Two further harness-only diagnoses, both found with temporary debug copies of the scenes (deleted after use, never committed):
- LiveLoop: efficiency/power_status printed 1.0000000000 (10 decimals) yet the exact `== 1.0` keys were false — the graph coverage ratio carries float64 noise (~1e-13 under 1.0). Fix: the two live keys (`adjacent_live_loop_efficiency_one`, `adjacent_live_loop_room_separator_restores`) now use `is_equal_approx(..., 1.0)`, matching the binding proof's idiom for the same live efficiency.
- ConsumerBinding: after restoring scrap, one tick read efficiency 0.4103194103 (power_status 0.4103194103) — the graph update runs before the driver re-stamps `shouldConsumePower`, so the first tick reads the distribute estimate for a non-consuming building instead of the coverage. One extra `simulate_factory` tick settles it: efficiency 1.0000000000, `matches: true`. Fix: one extra tick before asserting `adjacent_disassembler_scrap_restored_efficiency_one`, with a comment recording the one-tick settle (the same lag Java's own `shouldConsumePower` flag carries).

## Proof keys (new scene, 6 keys)

New scene `C07AdjacentFactoryPowerStatusProof` (modeled on `C07FactoryPowerStatusProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_ADJACENT_FACTORY_POWER_STATUS_PROOF `:

- `separator_has_power_consumer`: catalog `separator` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place separator, stamp `frame["power_status"] = 0.5`, call `source_adjacent_factory_tick_buildings_state(game, 1.0/60.0)` → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_adjacent_factory_power_status.py`: **4/4 OK in 14.7s** (Godot on PATH, re-verified this run; 14.656s) — registration (ledger N2146, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 8 exprs over ConsumePower.java + BuildingComp.java + Separator.java + PowerModule.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the three quoted Java lines in its comment + driver appends an `"is_power": true` row gated on `block.properties.has("consumePower")`; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (04:00 cron run): 4 tests in 1.065s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2146'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet).
- Neighbours (Godot on PATH, sequential, re-verified this run): **16/16 OK in 43.3s** — `test_adjacent_factory_consumer_binding` 4/4 + `test_adjacent_factory_live_loop` 4/4 + N2142 `test_c07_power_status_live` 4/4 + N2145 `test_c07_factory_power_status` 4/4.
- Godot proof: **GREEN 2026-11-13 ~05:15 +07** (05:00 cron run) — proof JSON 9 keys, all true, `matches: true` (6 semantic keys + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11302 / 1597 / 1518 / 2827**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2146 4/4 (proof green, see above); neighbours 16/16.
- Full Python suite, inclusive gate with the N2146 module (log `tools/mindustry_godot_transpiler/full-suite-n2146-gate.log`, 211 modules): **FINISHED ~07:31 +07, VERIFIED clean except Godot in this run — Ran 5681 tests in 900.886s, FAILED (failures=97, skipped=5), 0 errors. All 97 failures verified Godot-absent: 97 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None`, 0 `ERROR:` blocks; the N2146 module shows no failure other than its Godot-proof test.** Gate attempt 1 (main-thread, setsid, PID 10075, ~06:15) finished clean on the first attempt — no session-end death this time. The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule). VM restarted ~05:41 (uptime verified); javalang reinstalled 0.13.0 by the 05:45 worker, import verified OK by the main thread.

## Deferred

- `power.status` live read for drill (driver skips power-consumer blocks — the exclusion must be lifted first) and turret (four implementations, each its own wiring slice) — each its own slice after the adjacent pattern lands.
- Adjacent-family progress advance (`progress += getProgressIncrease(craftTime)` gated on `efficiency > 0`, Separator.java:139-145) — the adjacent driver advances no progress at all; needs its own slice.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open. Next candidate: N2147 scopes from the deferred list at RED — leading candidate is `power.status` for drill or turret.

See `handoffs/2026-11-13-c07-adjacent-factory-power-status-handoff.md` for the full detail.
