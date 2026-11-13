# Handoff — N2146: adjacent-factory power.status live read (Separator/Incinerator/WallCrafter/SingleBlockProducer family) (C07)

Date: 2026-11-13. Batch: N2146 (single slice). Status: **DONE 2026-11-13 ~07:40 +07. Targeted 4/4 OK, neighbours 16/16 OK, Godot proof GREEN (8/8 keys, matches:true), full gate certified clean except Godot (Ran 5681 in 900.886s, failures=97, skipped=5, 0 errors — all 97 Godot-absent asserts). Report + design spec written; committing + pushing this run (slice + docs + handoff-hash, see "Commits" below).**

## RED progress (04:00 cron run)

- State at RED time: main at b969e04 (N2145 merged + pushed to the fork 2026-11-13 ~03:50; C07 factory power.status live read done). Working tree clean except untracked `*.gd.uid` files (never stage).
- javalang 0.13.0 present at run start (no reinstall needed — no VM restart since the 03:45 run). Godot 4.6.2 present (`~/workspace/godot-bin/godot`; `godot` is NOT on the default PATH — targeted runs must `export PATH="$HOME/workspace/godot-bin:$PATH"`).
- Test module written: `tools/mindustry_godot_transpiler/tests/test_c07_adjacent_factory_power_status.py` (4 tests). RED run (Godot on PATH): **Ran 4 tests in 1.065s, FAILED (failures=2, errors=2)** — all expected:
  - registration `KeyError: 'N2146'` (ledger entry not written yet);
  - evidence errors on the missing ledger entry (same KeyError);
  - source-text `AssertionError`: `static func source_adjacent_factory_power_status_row_state` not found in `SourceAdjacentFactoryBuildState.gd` (the pure power row does not exist yet);
  - proof: Godot returncode 1, `Cannot open file 'res://tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.tscn'` — the proof scene does not exist yet.
- `git diff --check` clean (no tracked changes yet — only the new untracked test module + this handoff).

## GREEN progress (04:15–06:15, finished by the 06:00 main-thread run)

- GREEN code: pure `source_adjacent_factory_power_status_row_state(frame, has_power_consumer)` in `godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd` (definition:224, driver call site:379 — append power row when `block.properties.has("consumePower")`) + stale comment fixed. Diff: 41 insertions, 2 deletions.
- Register script `tools/mindustry_godot_transpiler/register_c07_adjacent_factory_power_status.py` written 04:42, RUN 04:45 — SSOT actuals verified: **11302/1597/1518/2827**, audit 1335, exactly the RED expectation (+2 symbols/+1 slice/+1 contract/+2 schemas). 9 SSOT files modified (incl. production_* shards).
- Proof scene `godot-mindustry/tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.gd` + `.tscn` created 05:00 (6 keys, modeled on N2145). Godot proof RAN GREEN — output `.json` (05:15): **8 keys, all true, `matches: true`** (6 semantic keys + 2 harness keys `registry_valid`, `one_headquarter_per_ssot`).
- Targeted `test_c07_adjacent_factory_power_status`: **4/4 OK** (re-verified 06:00 main thread, 12.966s; worker re-ran 13.8s).
- Neighbours **16/16 OK** (06:00 main thread, sequential): `test_adjacent_factory_consumer_binding` 4/4 + `test_adjacent_factory_live_loop` 4/4 + N2142 `test_c07_power_status_live` 4/4 + N2145 `test_c07_factory_power_status` 4/4. Two neighbour proof scenes needed harness-only fixes first (see below) — no gameplay touched.
- Neighbour harness fix (proof/test-harness only, same class as N2145's FactoryShouldConsumeProof reactor fix): both scenes placed power-consuming adjacent blocks but no power producer, so after N2146 the graph stamped `power_status=0` → efficiency 0 (correct Java). Fix: place a thorium-reactor (`blocks_by_id["thorium-reactor"]`, cell (25,7), powerProduction 15.0, no fuel in the port's producer model) in `AdjacentFactoryConsumerBindingProof.gd` and `AdjacentFactoryLiveLoopProof.gd`, with the N2145-style comment. Diagnosed with temporary debug copies of the scenes (deleted after use — never committed):
  - LiveLoop: efficiency/power_status printed 1.0000000000 (10 decimals) yet the exact `== 1.0` keys were false — the graph coverage ratio carries float64 noise (~1e-13 under 1.0). Fix: the two live keys (`adjacent_live_loop_efficiency_one`, `adjacent_live_loop_room_separator_restores`) now use `is_equal_approx(..., 1.0)`, matching the binding proof's idiom for the same live efficiency.
  - ConsumerBinding: after restoring scrap, one tick read efficiency 0.4103194103 (power_status 0.4103194103) — the graph update runs before the driver re-stamps `shouldConsumePower`, so the first tick reads the distribute estimate for a non-consuming building instead of the coverage. One extra `simulate_factory` tick settles it: efficiency 1.0000000000, `matches: true`. Fix: one extra tick before asserting `adjacent_disassembler_scrap_restored_efficiency_one`, with a comment recording the one-tick settle (the same lag Java's own `shouldConsumePower` flag carries).
- Full gate attempt 1: launched from the main thread 06:15 with the proven backgrounded-`&&`-chain method — **PID 10075, SID == 10075, PPID 10072 (background subshell alive), %CPU ~97.8, log `tools/mindustry_godot_transpiler/full-suite-n2146-gate.log`** (3478 bytes at launch, grows in bursts). Expected: Ran ~5681, failures=97 (96 inherited + 1 new N2146 proof test), skipped=5, 0 errors, all Godot-absent. **Do NOT launch a second gate — one is running.**
- VM restarted ~05:41 (uptime verified, up 20 min at 05:45); javalang reinstalled 0.13.0 by the 05:45 worker, import verified OK by the main thread.
- Cron workers timed out at 900s on 8 consecutive runs (04:15–06:00) and kept re-verifying the same state without landing the neighbour fix; the main thread did the fix + verification + gate launch at 06:00–06:15.

## Gate + DONE (07:30–07:40, main thread)

- Full gate attempt 1 (setsid PID 10075, main-thread launch) **FINISHED ~07:33 +07: Ran 5681 tests in 900.886s, FAILED (failures=97, skipped=5), 0 errors.** Certified in this run: 97 `FAIL:` blocks, 0 `ERROR:` blocks — 96 × `AssertionError: unexpectedly None` (plain Godot-absent asserts) + 1 × `AssertionError: unexpectedly None : Godot required for hydration proof`; the N2146 proof test (`test_reference_graph_and_actual_c07_adjacent_factory_power_status`) is the 1 new failure, as expected (96 inherited + 1 new). Zero real failures. Log `tools/mindustry_godot_transpiler/full-suite-n2146-gate.log` (67141 bytes). Gate ran with no Godot on PATH (established pattern); the proof itself was run separately with Godot present and is green. No proof scene ran while the gate ran (port-7777 rule).
- Report `docs/superpowers/reports/2026-11-13-c07-adjacent-factory-power-status.md` + design-spec N2146 row + changelog row + Status Summary 1596→1597 written (spec/register already carried the summary bump + rows; verified against the measured numbers in this run).
- `git diff --check` clean.

## Commits

- Slice commit: (hash below on commit)
- Docs commit: (hash below on commit)
- Handoff-hash commit: (hash below on commit)

## What this batch is

The second of the remaining `power.status` consumer families named in the N2142/N2144/N2145 handoffs. N2142's live loop stamps `frame["power_status"]` each tick before the factory tick runs, and the write-back is generic: `SourcePlacedPowerGraphState.SOURCE_CONSUMER_FRAME_META_KEYS` includes `"source_adjacent_factory_building"`, so adjacent-family frames already receive the live status. But the adjacent-family tick driver never reads it: it builds its first-pass rows from the bound actors with `is_power: false` and the comment says "the power consumer stays the power graph's domain (N2080/N2107) and is not bound here" (`SourceAdjacentFactoryBuildState.gd:326`), so a separator with no power still runs at full efficiency and its progress would climb by `getProgressIncrease(craftTime)` (Separator.java:142) as if `power.status` were 1.0. N2146 is the adjacent family's live read — the same proven N2145 pattern, one file over.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state`, via `update_consumption_non_optional_pass_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2146 does not touch it. N2146 supplies the missing pure power row over the stamped frame value + the tick-driver append.

## Scope decision (decided in RED — adjacent only; no progress keys)

- **Adjacent factory (Separator/Incinerator/WallCrafter/SingleBlockProducer) — IN N2146.** One live driver (`SourceAdjacentFactoryBuildState.source_adjacent_factory_tick_buildings_state`, ~lines 256-350), one pure function to add, one gate (`block.properties.has("consumePower")`, the drill driver's gate). Catalog grounds the gate: `separator` has `consumePower: 1.1`, `incinerator` 0.5, `disassembler` 4.0 (content_registry.json).
- **No progress keys in the proof — DEFERRED to its own slice.** Unlike the factory driver, the adjacent driver does not advance progress at all: `SourceAdjacentFactoryBuildState.gd` contains zero occurrences of `progress` / `getProgressIncrease` / `craftTime`. Separator's `progress += getProgressIncrease(craftTime);` (Separator.java:142, gated on `efficiency > 0`) is unwired, so the proof cannot assert progress through the tick driver. The proof has 6 keys (pure row ×3 + live efficiency ×2 + catalog gate ×1) instead of N2145's 7.
- **No `has_consumers` fix needed — unlike N2145.** The adjacent driver already passes `_has_consumers_state(block)` to `update_consumption_state`, and that helper already counts the power consumer (`properties.has("consumeItem") or properties.has("consumeLiquid") or properties.has("consumePower")`, with the comment "the separator and disassembler consume slag and power, the incinerator consumes power, the cliff-crushers consume power plus a booster row"). A power-only adjacent block (incinerator) already takes no early return. The pure function's header comment quotes `hasConsumers = consumers.length > 0;` (Block.java:1449) to record that.
- **Drill — DEFERRED, not N2146.** `SourceDrillConsumptionRuntimeState.gd:102` SKIPS blocks with a power consumer entirely (`or block.properties.has("consumePower")` → `continue`); a drill power read needs that driver's exclusion lifted first, a separate slice.
- **Turret — DEFERRED, not N2146.** Four+ implementations with their own drivers (Item/Liquid/Power/Laser/ContinuousTurret) — each needs its own wiring slice.

## Exact upstream evidence (all 8 exprs verified verbatim in this VM)

- Power read (ConsumePower.java:38-40): `return build.power.status;`
- First pass (BuildingComp.java:1969, 1976): `for(var cons : block.nonOptionalConsumers){` / `minEfficiency = Math.min(minEfficiency, result);`
- Early return (BuildingComp.java:1944): `if(!block.hasConsumers || cheating()){`
- Progress (Separator.java:142): `progress += getProgressIncrease(craftTime);`
- Field default (PowerModule.java:13): `public float status = 0.0f;`
- Null fold convention (UnitAssembler.java:469): `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`
- hasConsumers includes power (Block.java:1449, 1487): `hasConsumers = consumers.length > 0;`

## Design (decided in RED, implement in GREEN)

- **New pure function** `SourceAdjacentFactoryBuildState.source_adjacent_factory_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update); `!enabled` is handled by the machinery's disabled branch, not here. Header comment quotes `return build.power.status;` (ConsumePower.java:39), the null-fold line, and `hasConsumers = consumers.length > 0;` (Block.java:1449) — the source-text test asserts all three.
- **Driver wiring** in `source_adjacent_factory_tick_buildings_state` (after the actor loop, ~line 340): if `block.properties.has("consumePower")`, append `source_adjacent_factory_power_status_row_state(frame, true)["row"]` to `required_results`. Update the stale comment at ~line 326 ("the power consumer stays the power graph's domain (N2080/N2107) and is not bound here") to the live-read note.
- **Do NOT change** `source_adjacent_factory_update_consumption_state`'s signature — it stays the caller-less pure adapter; the live driver is the wiring point. Do NOT touch `_has_consumers_state` — it already counts consumePower.
- **Register script** `register_c07_adjacent_factory_power_status.py` (modeled on the N2145 one): 2 new result symbols:
  - `source_adjacent_factory_power_status_row_state_result.row` ← `return build.power.status;` (ConsumePower.java, the canonical power.status read)
  - `source_adjacent_factory_power_status_row_state_result.has_power_row` ← `for(var cons : block.nonOptionalConsumers){` (BuildingComp.java:1969, the first pass the row joins)
  - Slice `java_source` Separator.java, `java_class` `mindustry.world.blocks.production.Separator.SeparatorBuild`, `java_method` `SeparatorBuild.updateTile()`.
  - Expected SSOT +2 symbols / +1 slice / +1 contract / +2 schemas → **11302 / 1597 / 1518 / 2827**; audit 1335. GREEN verifies actuals.
- **Proof**: new scene `godot-mindustry/tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.gd` + `.tscn` (modeled on `C07FactoryPowerStatusProof` — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_ADJACENT_FACTORY_POWER_STATUS_PROOF `, 6 keys:
  - `separator_has_power_consumer`: catalog `separator` properties has `consumePower` (grounds the driver gate).
  - `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
  - `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
  - `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
  - `efficiency_folds_power_min`: live tick — place separator, stamp `frame["power_status"] = 0.5`, call `source_adjacent_factory_tick_buildings_state(game, 1.0/60.0)` → frame efficiency 0.5.
  - `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.
  - Proof JSON is gitignored, never stage it. Note: call the tick driver directly (as the N2145 proof does), not `simulate_factory`, so the graph update does not overwrite the stamped `power_status`; the write-back itself is already proven by N2142.
- **Neighbours to run in GREEN** (targeted, sequential, Godot on PATH): `test_adjacent_factory_consumer_binding` (4), `test_adjacent_factory_live_loop` (4), N2142 `test_c07_power_status_live` (4), N2145 `test_c07_factory_power_status` (4) — 16 total, since the frame stamp is shared and the pattern is N2145's.

## Files changed (RED + GREEN; uncommitted)

- `tools/mindustry_godot_transpiler/tests/test_c07_adjacent_factory_power_status.py` (new, 4 tests): registration (ledger N2146, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 8 exprs over ConsumePower.java + BuildingComp.java + Separator.java + PowerModule.java + UnitAssembler.java + Block.java), source-text (pure function exists + the three quoted Java lines in its comment + driver appends an `"is_power": true` row gated on `block.properties.has("consumePower")`; proof has the 6 new keys), Godot proof (`C07AdjacentFactoryPowerStatusProof.tscn`, prefix `C_07_ADJACENT_FACTORY_POWER_STATUS_PROOF `, the 6 new keys true).
- `godot-mindustry/src/game/SourceAdjacentFactoryBuildState.gd` (modified, GREEN): pure function + driver wiring + stale comment fix.
- 9 SSOT files under `godot-mindustry/src/generated/` (modified, register run 04:45): registry, ledger, contracts, state schema + 5 production_* shards.
- `tools/mindustry_godot_transpiler/register_c07_adjacent_factory_power_status.py` (new, GREEN).
- `godot-mindustry/tools/runtime_proofs/C07AdjacentFactoryPowerStatusProof.gd` + `.tscn` (new, GREEN; the `.json` output is gitignored, never stage).
- `godot-mindustry/tools/runtime_proofs/AdjacentFactoryConsumerBindingProof.gd` + `AdjacentFactoryLiveLoopProof.gd` (modified, GREEN neighbour harness fix: thorium-reactor placement + LiveLoop `is_equal_approx` + ConsumerBinding extra settle tick).
- This handoff (new, untracked).
- Gate log `tools/mindustry_godot_transpiler/full-suite-n2146-gate.log` (untracked working log, never stage).

## Verified numbers (do not re-derive, these are measured in this VM)

- RED run: **4 tests in 1.065s, FAILED (failures=2, errors=2), all expected** — registration `KeyError: 'N2146'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function does not exist yet), proof returncode 1 (proof scene does not exist yet).
- Exact-expr pre-check: **8/8 exprs found verbatim** in the 6 slice sources (ConsumePower.java, BuildingComp.java, Separator.java, PowerModule.java, UnitAssembler.java, Block.java).
- Negatives confirmed before RED: `source_adjacent_factory_power_status_row_state` 0 times in `SourceAdjacentFactoryBuildState.gd`; `power_status` 0 times in `SourceAdjacentFactoryBuildState.gd`; `"is_power": true` 0 times in `SourceAdjacentFactoryBuildState.gd`; `N2146` not in the slice ledger; the three quoted Java lines (`return build.power.status;`, `float powerStatus = !enabled ? 0f : power == null ? 1f : power.status;`, `hasConsumers = consumers.length > 0;`) absent from the file.
- Catalog grounding: `separator` `consumePower: 1.1`, `incinerator` 0.5, `disassembler` 4.0 (content_registry.json); write-back covers adjacent frames (`SOURCE_CONSUMER_FRAME_META_KEYS` includes `"source_adjacent_factory_building"`, SourcePlacedPowerGraphState.gd:140).
- `git diff --check` clean.
- State at RED time: main at b969e04 (N2145 merged + pushed to the fork 2026-11-13 ~03:50); SSOT 11300 / 1596 / 1517 / 2825; audit 1335.
- javalang 0.13.0 present at run start (no reinstall needed); Godot 4.6.2 on `~/workspace/godot-bin`.

## Deferred (not this slice)

- `power.status` live read for drill (driver skips power-consumer blocks) and turret (four implementations) — each its own slice after the adjacent pattern lands.
- Adjacent-family progress advance (`progress += getProgressIncrease(craftTime)` gated on `efficiency > 0`, Separator.java:139-145) — the adjacent driver advances no progress at all; needs its own slice.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.
