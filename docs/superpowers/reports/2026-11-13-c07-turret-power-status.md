# Report — N2148: turret power.status live read (ItemTurret / PowerTurret / LaserTurret / ContinuousTurret) (C07)

Date: 2026-11-13. Batch: N2148 (single slice). Status: **DONE + PUSHED 2026-11-13 ~10:2x +07 (10:15 cron run). Targeted tests 4/4 OK, neighbours 20/20 OK, Godot proof GREEN, full gate verified clean except Godot (Ran 5689, failures=99, skipped=5, 0 errors — all 99 Godot-absent asserts). Commit + push to origin main (fork Lasthope1508) this run — see handoff for the commit hashes.**

## What changed

The last of the remaining `power.status` consumer families named in the N2142/N2144/N2145 handoffs. N2142's live loop stamps `frame["power_status"]` each tick and the generic write-back covers turret frames, but the turret tick driver never read it: `SourceTurretBuildState.source_turret_tick_buildings_state` (N2108) only refreshed frame keys (block_implementation, team_id, rules_state, cheating, enabled) and never ran updateConsumption at all — unlike the factory/adjacent/drill drivers it had no first-pass `required_results`. So an unpowered power turret warmed up, rotated and reloaded as if `power.status` were 1.0. N2148 is the turret family's live read — the same proven N2145/N2146/N2147 pure-row pattern, one file over.

Composition, not re-implementation: the shared efficiency machinery (`SourceBuildingEfficiencyState.update_consumption_state` + `apply_update_consumption_state`, via `update_consumption_setup_state`) already folds `{"result": ..., "is_power": true}` rows into the min efficiency — the power consumer's `ConsumePower.efficiency` is `build.power.status` (ConsumePower.java:39). N2148 does not touch it. N2148 supplies the missing pure power row + wires it into the driver.

Pure `SourceTurretBuildState.source_turret_power_status_row_state(frame: Dictionary, has_power_consumer: bool) -> Dictionary` — `has_power_consumer` false → `{"has_power_row": false, "row": {}}`; true → `{"has_power_row": true, "row": {"result": <live>, "is_power": true}}` where live = 1.0 if `frame.get("power_status", null)` is null else `float(frame.get("power_status"))`. The null→1.0 fold is the assembler convention (UnitAssembler.java:469, before the first graph update). Header comment quotes `return build.power.status;` (ConsumePower.java:39), the null-fold line, `hasConsumers = consumers.length > 0;` (Block.java:1449), `return power == null ? 0f : power.status;` (PowerTurret.java:30), and the warmup fold `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget, shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));` (Turret.java:512).

Driver wiring in `source_turret_tick_buildings_state`: when `block.properties.has("consumePower")` and enabled and not cheating, the pure row runs through the shared machinery (`update_consumption_setup_state` + `update_consumption_state` + `apply_update_consumption_state`, should_consume=true when enabled, production_valid=true) as the only first-pass row, so `frame["efficiency"]` follows power.status and the warmup fold (Turret.java:512-514) follows it. Non-power turrets untouched.

Scope decision (decided in RED): **the four TurretBuild implementations with power consumers — ItemTurret (foreshadow, consumePower 10f), PowerTurret (lancer 6f, arc 3.3f, afflict 5f, malign 40f), LaserTurret (meltdown 17f), ContinuousTurret (lustre 200f/60f)** — verified per-block from Blocks.java with a regex over each `new XTurret("name"){{...}};` body (an earlier line-grep bled across neighbouring blocks and overstated tsunami/foreshadow/spectre). Out of scope: LiquidTurret (tsunami has no consumePower — no row); PointDefenseTurret (segment, 8f) and TractorBeamTurret (parallax, 3.3f) are NOT TurretBuild — they extend ReloadTurret / BaseTurret and have their own drivers; each waits for its own slice. Documented limits in the pure function's comment: (1) the tick models no other consumers — foreshadow's item ammo and lustre's liquid nitrogen are not first-pass rows in this driver yet, so the folded efficiency is the min over the *modeled* consumers (power only); (2) no shouldConsume gate — `TurretBuild.shouldConsume()` (Turret.java:364-366, `return isShooting || reloadCounter < reload;`) needs targeting/reload state the tick does not track yet; the machinery runs with should_consume=true when enabled. The warmup gate itself (Turret.java:512-514) is what gates shooting behaviour on the recorded efficiency. No progress keys in the proof — the turret tick advances no warmup/reload yet, so the warmup fold is what the efficiency keys prove.

## Proof keys (new scene, 6 keys)

New scene `C07TurretPowerStatusProof` (modeled on the N2147 proof — Main scene, campaign playable slice, `RuntimeProofState`), prefix `C_07_TURRET_POWER_STATUS_PROOF `:

- `lancer_has_power_consumer`: catalog `lancer` properties has `consumePower` (grounds the driver gate).
- `power_row_half`: pure row over frame `{"power_status": 0.5}`, has_power_consumer true → row result 0.5, `is_power` true.
- `power_row_absent_without_consumer`: has_power_consumer false → `has_power_row` false.
- `power_row_null_folds_one`: frame without `power_status` → row result 1.0.
- `efficiency_folds_power_min`: live tick — place lancer live, stamp `frame["power_status"] = 0.5`, call `source_turret_tick_buildings_state` directly (as the N2147 proof calls the drill driver directly, so the graph update does not overwrite the stamped power_status — the write-back itself is already proven by N2142) → frame efficiency 0.5.
- `efficiency_zero_at_no_power`: same, `power_status` 0.0 → efficiency 0.0.

## Verified numbers (measured in this VM)

- Test module `test_c07_turret_power_status.py`: **4/4 OK in 27.228s** (Godot on PATH) — registration (ledger N2148, 2 new symbols, runtime proof, test names, deferred_exprs), exact-evidence (2 new symbols + 9 exprs over ConsumePower.java + BuildingComp.java + Turret.java + PowerTurret.java + Blocks.java + PowerModule.java + UnitAssembler.java + Block.java, all found verbatim), source-text (pure function exists + the quoted Java lines in its comment + driver wires the pure row through the shared machinery; proof has the 6 new keys), and the Godot proof test (6 new keys, all true, `matches: true`).
- RED run (09:15 cron run, ~09:15 +07): 4 tests in 1.6s, FAILED (failures=2, errors=2), all expected — registration `KeyError: 'N2148'`, evidence errors on the missing ledger entry, source-text `AssertionError` (pure function did not exist yet), proof returncode 1 (proof scene did not exist yet). 9/9 exact exprs verified verbatim at RED (plus foreshadow/lustre/afflict/malign catalog values cross-checked).
- First GREEN attempt 3/4: `test_turret_power_status_row_state` failed only because the shootWarmup expr was split across comment lines; fixed by joining it onto one comment line — test-harness text, no gameplay change.
- Neighbours (Godot on PATH, sequential): **20/20 OK in 108.878s** — `test_turret_live_loop` 4/4 + N2142 `test_c07_power_status_live` 4/4 + N2145 `test_c07_factory_power_status` 4/4 + N2146 `test_c07_adjacent_factory_power_status` 4/4 + N2147 `test_c07_drill_power_status` 4/4.
- Godot proof: **GREEN 2026-11-13 ~09:35 +07** (09:30 cron run) — proof JSON 10 keys, all true, `matches: true` (6 semantic keys + `lancer_placed_live_sprite` + `registry_valid` + `one_headquarter_per_ssot` + `matches`), on Godot 4.6.2-stable Linux in this VM (build 71f334935, identical to the Windows 4.6.2 build). Port 7777 was free; no proof scene ran while a gate ran. Not yet run on Windows Godot — the scene/source reach Windows only with this commit.
- `git diff --check` clean.
- SSOT +2/+1/+1/+2 → **11306 / 1599 / 1520 / 2831**; audit stays 1335.

## Gate / suite

- Test modules standalone: N2148 4/4 (proof green, see above); neighbours 20/20.
- Full Python suite, inclusive gate with the N2148 module (log `tools/mindustry_godot_transpiler/full-suite-n2148-gate.log`, 211 modules): **FINISHED ~10:08 +07, VERIFIED clean except Godot in this run — Ran 5689 tests in 1666.816s, FAILED (failures=99, skipped=5), 0 errors. All 99 failures verified Godot-absent: 99 `FAIL:` blocks, every one `assertIsNotNone(godot)` / `unexpectedly None` (98 plain + 1 hydration with message 'Godot required for hydration proof'), 0 `ERROR:` blocks; the N2148 module shows no failure other than its Godot-proof test (`test_reference_graph_and_actual_c07_turret_power_status`).** Gate launched from the main thread (PID 10516, SID 10516, ~09:39 +07) with the proven backgrounded-`&&`-chain method; the worker-launch pattern was not used (worker-launched gates die at session end — N2146 PID 9699, N2147 PID 3427). The gate took 1666.8s vs N2146's 900.9s — roughly 2× slower, same as N2147's 1722.6s; likely VM contention (another agent is using Godot on this VM, per the user at 08:05). The gate ran with no Godot on PATH (the established gate pattern); the proof itself was run separately with Godot present and is green. No proof scene was run while the gate ran (port-7777 rule).

## Deferred

- `power.status` live read for PointDefenseTurret (segment, 8f) and TractorBeamTurret (parallax, 3.3f) — own drivers (ReloadTurret / BaseTurret), own slices.
- BurstDrill power (eruption-drill / impact-drill) and SolidPump power (water-extractor) — own drivers, own slices.
- Turret first-pass rows for foreshadow item ammo + lustre liquid nitrogen — the folded efficiency is currently the min over the modeled (power-only) consumers.
- Turret shouldConsume gate (`isShooting || reloadCounter < reload`) — needs targeting/reload state the tick does not track yet.
- Turret warmup/reload advance on the folded efficiency — the tick advances no warmup/reload yet.
- `spawn_occupied` / `spawn_visual_occupied` frame inputs — need tile solidity + nearby-units query; waits for a collision/tile-solidity frame-data slice.
- `allow_update` frame input — waits for a rules-state capture slice (env + map limits).
- Per-unit `AssemblerAI.inPosition()` evaluation from live unit pos/rotation — units list carries no pos/rotation yet.
- Net `readUnits` / `whenSyncedUnits` drone sync — presentation/net, not state.
- `moveOutPayload()` modeling — the assembler production tick still has no payload move-out.
- C07–C12 remain open.

See `handoffs/2026-11-13-c07-turret-power-status-handoff.md` for the full detail.
