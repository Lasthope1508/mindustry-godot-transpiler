# Report — N2188: RepairTurret shouldConsume gate live read (C07)

Date: 2026-11-15. Batch: N2188 (single slice). Status: **DONE + PUSHED (2026-11-15 ~13:2x +07 — targeted 4/4 OK, Godot proof GREEN 9 keys matches:true, full gate Ran 5849, failures=139, skipped=5, 0 errors — all 139 verified Godot-absent asserts). Slice commit `TBD`.**

## What changed

The first C07 deferred item after the power.status campaign closed (N2185 LightBlock was the last catalog consumePower def with a driver). N2174 left this exact gap open with a documented limit: with no target Java forces efficiency to 0 through the shouldConsume gate, while the port folded power-only and reported efficiency 1.0. Single family (**RepairTurret: repair-point + repair-turret**), one pure function + one driver line in the existing `SourceRepairTurretBuildState.gd`, one proof scene.

What N2174 already did (NOT redone): the power-only fold (consumePower 1f repair-point / 5f repair-turret, Blocks.java:6391/6402) and the driver that stamps `power_status` from the N2142 graph update.

What N2188 adds:

- Pure `source_repair_turret_should_consume_state(frame) -> Dictionary` — returns `{"should_consume": bool}`, mirroring `source_adjacent_factory_should_consume_state(frame, block)`. Gate expression verbatim from Java: `return target != null && enabled;` (RepairTurret.java:221-222). **Frame key `has_target` (bool, NEW)** — name precedent: the port already uses `"has_target": selected_target != null` in turret targeting (SourceTurretTargetingState.gd:36); no building-frame key collides (verified by grep over `godot-mindustry/src/game/*.gd`).
- **RED decision — the absent-key default (pinned in the proof):** when the frame carries NO `has_target` key, preserve the N2174 behavior (`should_consume = enabled`). Rationale: no placed-building frame carries a live target today; defaulting absent to false would zero efficiency for every live repair turret — a live regression against N2174 GREEN, forbidden by the user boundary (the game must stay exactly as it is; only the proof/test harness may change). The gate activates when the future target-acquisition slice stamps `has_target` from `Units.closest(team, x, y, repairRadius, Unit::damaged)` (RepairTurret.java:216) plus the null-out conditions (:193-195). The pure function reads `frame.get("has_target", null)`; null means "no observation yet", not "no target".
- **Driver change — one line + comment** in `source_repair_turret_tick_buildings_state`: `var should_consume: bool = bool(frame.get("enabled", true))` replaced with the pure-function call. The setup / power row / `update_consumption_state` / `apply_update_consumption_state` calls are unchanged. The gate flows through the shared machinery: `update_consumption_initial_state` (SourceBuildingEfficiencyState.gd:93-99, `efficiency := potential_efficiency if should_consume_state else 0.0`) — a false gate zeroes `frame["efficiency"]` even when the power row folds 1.0.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.gd/.tscn` (mirror the N2174 proof, 5 keys): gate blocks without target (efficiency 0, overriding the power fold), gate passes with target (efficiency 0.5 from the power fold), gate blocks when disabled, gate absent preserves the power fold (efficiency 0.5 — pins the RED absent-default decision), gate passes with target and no power (efficiency 1.0, null fold). Live-tick style: place repair-point live, stamp the frame keys, call the driver directly (the N2174/N2187 proof precedent — no long live tick).
- No new frame meta key, no `SOURCE_CONSUMER_FRAME_META_KEYS` change (`has_target` lives inside the existing `source_repair_turret_building` frame), no `simulate_factory` wiring change, no shard change (no shard selects `/world/blocks/units/` — the N2183 campaign precedent).

## RED

Test module `tools/mindustry_godot_transpiler/tests/test_c07_repair_turret_should_consume.py` + register script `tools/mindustry_godot_transpiler/register_c07_repair_turret_should_consume.py`, written by the 12:00 worker. Register script: EXACT_EXPRS = the verified exprs (all present verbatim in upstream — script check, 0 missing), DEFERRED carried from the N2174 script via AST (never retyped) plus the new N2188 entries.

RED run: the classic RED signature (register NOT yet run, function + proof scene not yet written). Port 7777 FREE before the run. SSOT at RED — **symbols 11389 / slices 1638 / contracts 1559 / schemas 2909** (the N2187 baseline — register not yet run). `git diff --check` clean.

## GREEN

- `SourceRepairTurretBuildState.gd` extended (same file as N2174, +16 lines): pure `source_repair_turret_should_consume_state(frame)` (:73) + 1 driver line + comment updates.
- Proof scene `godot-mindustry/tools/runtime_proofs/C07RepairTurretShouldConsumeProof.gd` + `.tscn` (N2174 model, 5 keys + registry_valid / one_headquarter_per_ssot / matches). Proof `.json` is gitignored (never stage, per AGENTS.md rule on proof .json).
- Register script run at GREEN (`python3 register_c07_repair_turret_should_consume.py`, exit OK): SSOT **11390/1639/1560/2911** — exactly the expected values (+1/+1/+1/+2; symbols +1 — the pure function returns a 1-key dict, correcting the 11391 estimate); audit 1335 unchanged; ledger N2188 status done. No shard change.
- Targeted (main-thread re-run, Godot 4.6.2 on PATH, port 7777 FREE): **Ran 4 tests in 13.360s, OK** (log `tools/mindustry_godot_transpiler/n2188-green.log`). Two earlier attempts in the same run failed on the port-7777 flake only: 12:33 run — proof JSON matches:true 9/9 but the MCP autoload bind failed ERR_ALREADY_IN_USE (22) because the other agent's Godot was running a proof scene; 12:35 first attempt — same collision (the other agent runs scenes in a queue: PID 11332 `C06UnitFactoryShouldConsumeProof` seen 12:34). Port freed ~12:35:07, clean re-run passed. Proof content was matches:true 9/9 in all three runs — the flakes were environmental, never a slice bug (N2182 precedent).
- Godot proof (inside the targeted run, Linux headless 4.6.2): **9 keys all true, matches:true** — `gate_blocks_without_target`, `gate_passes_with_target`, `gate_blocks_when_disabled`, `gate_absent_preserves_power_fold`, `gate_passes_with_target_no_power`, `repair_turret_has_power_consumer`, `one_headquarter_per_ssot`, `registry_valid`, `matches`. No ERROR in output.

## Neighbours

Family run ~12:3x +07 (5 modules, 20 tests — the `test_*_should_consume.py` pattern), Godot 4.6.2 on PATH — log `tools/mindustry_godot_transpiler/n2188-neighbours.log`. **Ran 20 tests in 125.638s, FAILED (failures=2)** — `test_c06_unit_assembler_payload_should_consume` + `test_unit_factory_should_consume` (same shared proof scene `C06UnitFactoryShouldConsumeProof`). Both fail on `matches: False` with the SAME 3 live keys False (`should_consume_live_factory_efficiency_one`, `should_consume_live_reconstructor_efficiency_one`, `should_consume_live_reconstructor_payload_restored_one`); **0 ERROR lines in the family log** — NOT the port-7777 signature.

Wiring-standard set (9 modules / 32 tests, the N2177 lesson) — log `tools/mindustry_godot_transpiler/n2188-wiring.log`. **31/32** first pass — `test_battery_placement_binding` failed on the `assertNotIn('ERROR:')` assert with proof `matches:true` and `ERROR: [MCP Runtime] Failed to start server on port 7777: 22` — classic port-7777 flake. **Isolated re-run (port 7777 FREE): Ran 3, OK** (log `n2188-neighbours-rerun.log`) → wiring **32/32**.

The 2 family failures are a **confirmed deterministic pre-existing regression, NOT N2188, NOT a flake** (three independent failures with identical keys: family run ~12:34, isolated re-run ~12:55 with port FREE and no other Godot, zero-contention re-run after the gate finished — log `n2188-neighbours-zero-contention.log`: `test_c06_unit_assembler_payload_should_consume` + `test_unit_factory_should_consume` **Ran 8, FAILED (failures=2)**, same 3 keys False, 40/43 keys True each, 0 ERROR lines):

1. `simulate_factory` runs the live power-graph update FIRST (`SourceFactoryRuntimeState.gd:199`) and the unit-factory driver tick AFTER (`:562`).
2. The proof scene places 3 power consumers (ground-factory 1.2f, reconstructor 3f, assembler 2.5f) with **NO producer and NO battery**, so `distribute_power_state` (`SourcePowerGraphBatteryDistributionState.gd:186-210`) computes coverage = min(1.0, 0/needed) = **0.0**, and stamps every unbuffered consumer's `power_status = 0.0` (PowerGraph.java:203, written back by `source_factory_update_power_graph_state`).
3. The factory driver folds that live `power_status` into efficiency via the power row (`SourceUnitFactoryBuildState.gd:650-773`, the N2142/N2160–N2187 power.status campaign) → **efficiency 0.0**, so the three `efficiency == 1.0` keys fail. The zero-keys still pass because efficiency is 0 anyway; `should_consume_live_driver_ticked_three` passes because the driver still ticks.
4. At N2132 (last known green) the live loop did not stamp `power_status` (null folded to 1.0), so the same scene passed. **The regression was introduced by the N2142 power-graph live update + the factory power-row fold (N2160–N2187 campaign)** — the exact slice that first broke it is NOT bisected yet, but the breaking change is in that campaign, not in N2188 (N2188's diff is additive-only: `SourceRepairTurretBuildState.gd` + 4 SSOT JSONs, no factory/assembler/reconstructor/shared code touched; the failing scene reads none of the changed code).
5. **The port is behaving faithfully:** in real Java the same scene (3 consumers, no producer) also yields power.status 0 → efficiency 0. The mismatch is the PROOF SCENE's scenario, not the game code: the scene wants to test shouldConsume gating in isolation, but live power is now a confound. **Fix belongs to the proof harness only** (user boundary: game code untouched).

Neighbours final: targeted **4/4 OK**; family **18/20** (2 confirmed pre-existing regression, root-caused, out of scope); wiring **32/32 OK**.

## Gate

Full gate attempt 3 **launched from the MAIN THREAD ~12:41 +07** (PID 12219, SID 12219, own session): `cd tools/mindustry_godot_transpiler && python3 -m unittest discover -s tests > full-suite-n2188-gate.log 2>&1` — `which godot` → NOT on PATH (correct, the established no-Godot baseline). Two earlier attempts died: attempt 1 (worker-launched) `ImportError: Start directory is not importable` — wrong cwd; attempt 2 (chain-launched PID 11806) killed by main thread ~12:40 — the chain exported `godot-bin` on PATH, so the gate ran proof scenes live (a deviation from the baseline, slower and exposed to the other agent's port-7777 contention).

Finished ~13:00 +07 (log mtime, verified from the log on disk, not a worker claim): **Ran 5849 tests in 1011.758s, FAILED (failures=139, skipped=5)** — no errors field, 0 `ERROR:` lines. All 139 verified Godot-absent (grep on the log): **139 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), including the new N2188 proof test (`test_reference_graph_and_actual_c07_repair_turret_should_consume`, `assertIsNotNone(godot)` — expected, no Godot on PATH in the gate), 0 port-7777 bind errors. The gate is clean except Godot — exactly as expected (138 inherited + 1 new). No VM restart during the gate. Gate at normal speed (1011.8s, same as N2187's 966.1s).

## Commits

- Slice: `TBD` — C07: N2188 RepairTurret shouldConsume gate live read (pure function + 1 driver line; proof 5 keys), 9 files.
- Docs: `TBD` — Docs: N2188 report + design spec + handoff (gate clean except Godot).
- GOAL: `TBD` — Docs: GOAL.md names the N2188 slice commit that carries its proof to Windows.
- Pushed 2026-11-15 ~13:2x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- Target re-acquire (RepairTurret.java:214-217) + null-out (:193-195) + heal advance (:203-210) + rotation slerp (:211) + strength lerp (:212) — the target-acquisition / updateTile slice, which is also the slice that starts stamping `has_target` live.
- Coolant optional consumer (Blocks.java:6404-6406, coolantUse 0.16f, coolantMultiplier 1.6f) — second pass, own slice.
- Per-def repairSpeed / repairRadius / length / beamWidth / pulseRadius verification — own slice.
- RepairTower (`targets.size > 0`), ShockwaveTower (`reloadCounter < reload`), BuildTurret (`unit.plans().size > 0 && !isHealSuppressed()`) gates — each its own slice.
- ShieldWall broken() / damage coupling — own slice.
- MassDriver / LaunchPad rows (updateTile / shouldConsume / link / fire / handlePayload / sense / draw / read / write / acceptItem) — own slices.
- **N2189 (follow-up, documented in the handoff): give `C06UnitFactoryShouldConsumeProof` a power producer** (e.g. place a solar panel / combustion generator on the graph, or a cheating team) so coverage = 1.0 and shouldConsume is again the only gate under test; then re-run both neighbour modules green. Proof-harness-only change; no game code, no SSOT change expected. Bisect N2142–N2187 optional, not required for the fix.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2187.
