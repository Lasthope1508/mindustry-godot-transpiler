# Report — N2189: Give C06UnitFactoryShouldConsumeProof a power producer (C07)

Date: 2026-11-15. Batch: N2189 (single slice, proof-harness-only). Status: **DONE + PUSHED (2026-11-15 ~14:0x +07 — Godot proof GREEN 45 keys matches:true, neighbours 8/8 OK, wiring 32/32 OK, full gate Ran 5849, failures=139, skipped=5, 0 errors — all 139 verified Godot-absent asserts, baseline unchanged). Slice commit `bcde8e4`.**

## What changed

The documented N2188 follow-up, the smallest deferred item: the shared proof scene `C06UnitFactoryShouldConsumeProof` placed 3 power consumers (ground-factory 1.2f, additive-reconstructor 3f, tank-assembler 2.5f) with NO producer, so the live graph stamped `power_status = 0.0` and the three `efficiency == 1.0` live keys failed no matter what shouldConsume said. The port was behaving faithfully (in real Java the same scene also yields power.status 0 → efficiency 0); the mismatch was the proof scene's scenario, not game code. **Proof-harness-only: no game code, no SSOT change, no new test module, no register script.**

What N2189 adds (one file, +19 lines):

- One thorium-reactor placed at (25, 7) — the exact N2146 precedent (`AdjacentFactoryConsumerBindingProof.gd:63-73`, same comment shape, same cell): "A thorium reactor (powerProduction 15.0, no fuel in the port's producer model) covers the whole graph, so the efficiency keys below are isolated from power." Coverage math verified this run: worst case needed = 1.2 + 3 + 2.5 = **6.7 < 15.0**, coverage = min(1.0, 15.0 / 6.7) = **1.0** with 2.2x margin.
- One new proof key: `should_consume_live_power_status_one` — after the 3 `simulate_factory` ticks, `factory_frame["power_status"] == 1.0`. Proof goes 43 → 44 keys + `matches` = 45 assignments.
- Why NOT the cheating-team option (also listed in the N2188 handoff): cheating skips the live distribute path entirely, so the proof would stop exercising the live graph it is a live-loop proof of. Why NOT solar panels: solar-panel is 0.12f (56 panels for 6.7), solar-panel-large 1.6f (5 panels) — more clutter, no precedent.
- The reactor relies on the port's producer simplification (no fuel/efficiency gating — `SourceBuildingPowerState.gd:189-202` reads catalog `powerProduction` directly), exactly as N2146 did. Known harness limitation, not a game-code change.

## RED (carried from the N2188 handoff, NOT re-run this tick)

`test_c06_unit_assembler_payload_should_consume` + `test_unit_factory_should_consume`: **Ran 8, FAILED (failures=2)**, zero-contention, port 7777 FREE — the SAME 3 live keys False in both modules (40/43 keys True each): `should_consume_live_factory_efficiency_one`, `should_consume_live_reconstructor_efficiency_one`, `should_consume_live_reconstructor_payload_restored_one`, 0 ERROR lines. Third independent failure with identical keys — deterministic real regression in the proof scene's scenario. These two neighbour modules ARE the RED tests.

## GREEN

- Proof scene edit only (13:30 worker): thorium-reactor at (25, 7) + N2146-style comment + new key. `git diff --check` clean.
- **Godot proof (headless, Godot 4.6.2 on PATH, port 7777 FREE): exit 0, 0 ERROR lines, JSON 45 assignments, `matches: true`, 0 false keys** — the 3 previously-failing live keys now pass, and the new power-status key is true. (Key count reconciled: 44 assignments before = 40 true + 3 false + `matches` false; now 45 assignments, all true.) Verified from the JSON on disk by the main thread ~13:4x.
- **Neighbour modules (main-thread re-run, port 7777 FREE): Ran 8, OK in ~27s** (`test_c06_unit_assembler_payload_should_consume` Ran 4 OK + `test_unit_factory_should_consume` Ran 4 OK). The 13:30 worker's claim had NO log file on disk — main thread verified directly.
- **Wiring 9 modules / 32 tests: 32/32 OK** (log `tools/mindustry_godot_transpiler/n2189-wiring.log`, ~13-14s per module, no flake, port free throughout).
- **Full gate (main thread, relaunched ~13:44 +07, PID 5857, SID 5857, own session):** `which godot` → NOT on PATH (correct, the established no-Godot baseline). The 13:30 worker's "gate running detached (PID 5543)" was WRONG — no `unittest discover` process existed; that log (3637 bytes, dots only, no footer) died mid-run at ~3600 tests when the worker session ended — the standard worker-launched gate death (the N2167–N2181 lesson: a gate launched by a worker dies with the worker's session — launch gates from the main thread).
- Finished ~14:00 +07 (log mtime, verified from the log on disk): **Ran 5849 tests in 969.656s, FAILED (failures=139, skipped=5)** — no errors field, 0 `ERROR:` lines. All 139 verified Godot-absent (grep on the log): **139 × `AssertionError: unexpectedly None`** (the N2175 lesson — count by the error message, not the exact-no-message-arg awk), 0 port-7777 bind errors. The gate is clean except Godot — exactly the N2188 baseline (Ran 5849, failures 139, skipped 5), unchanged. No VM restart during the gate. javalang 0.13.0 reinstalled at 13:30 (VM restarted again, #11) before any gate work.
- SSOT unchanged (no new symbol, no new slice row — N2189 is a harness fix, not a port slice; ledger/SSOT totals stay 11390/1639/1560/2911, audit 1335).

## Commits

- Slice: `bcde8e4` — C07: N2189 Give C06UnitFactoryShouldConsumeProof a power producer (proof-harness-only; proof 45 keys), 1 file.
- Docs: `TBD` — Docs: N2189 report + handoff (gate clean except Godot).
- GOAL: `TBD` — Docs: GOAL.md names the N2189 slice commit that carries its proof to Windows.
- Pushed 2026-11-15 ~14:0x +07 to the fork (Lasthope1508). See the handoff Commits section for the hashes.

## Deferred (NOT this slice)

- The remaining C07 deferred items per the N2188 handoff table — RepairTower shouldConsume (`targets.size > 0`, needs the target-refresh slice first), ShockwaveTower shouldConsume (`reloadCounter < reload`, needs the updateTile charge advance), BuildTurret shouldConsume (plans count + suppression state), ShieldWall broken()/damage coupling, MassDriver / LaunchPad rows, RepairTurret coolant — each its own slice; or C08 inventory (classify the 5,390 null-body functions) when asked.
- Windows Godot proof — debt in GOAL.md §5, same as N2182–N2188.
