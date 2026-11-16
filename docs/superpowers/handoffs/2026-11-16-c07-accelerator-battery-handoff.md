# Handoff — N2218 Accelerator battery side (C07)

## Status: GREEN + GATE VERIFIED (23:30 +07 run — targeted 4/4, family 8/8, wiring 32/32, proof 9 keys matches:true; full gate Ran 5965, failures=168, skipped=5, 0 errors, all Godot-absent). NOT committed/pushed yet — slice commit follows in this tick.

## RED

- Test `tools/mindustry_godot_transpiler/tests/test_c07_accelerator_battery.py` (4 tests), register `tools/mindustry_godot_transpiler/register_c07_accelerator_battery.py`. Proof scene `godot-mindustry/tools/runtime_proofs/C07AcceleratorBatteryProof.gd` + `.tscn` NOT yet written (see below).
- Targeted RED (worker run + main-thread re-run, identical): Ran 4, failures=2, errors=2 — KeyError 'N2218' ×2 (registration + input-evidence tests, slice not yet in the ledger), state-test FAIL (missing `getBatteryStored` battery function in SourceAcceleratorBuildState.gd), reference-test FAIL (Godot cannot open `res://tools/runtime_proofs/C07AcceleratorBatteryProof.tscn` — the proof scene file does not exist yet).
- Register --verify: see the nuance below — the script has NO --verify handling.
- SSOT before (N2217 end state, verified from disk): 11452/1667/1591/2973, audit 1335.
- No VM restart during the worker run; VM restart #27 ~22:19 +07 happened BEFORE the worker run (uptime 31 min at verification) — javalang 0.13.0 survived it, nothing lost. Port 7777 free, no parallel run active. origin/main == HEAD == 70540538 (N2217 DONE + PUSHED).

## CORRECTION — the register ran during main-thread verification (read this before GREEN)

- The register script has NO `--verify` support: `if __name__ == '__main__': main()` and main() registers unconditionally — the string 'verify' does not appear anywhere in the file. The main thread's verification call `python3 register_c07_accelerator_battery.py --verify` therefore REGISTERED N2218 (ledger mtime 22:49:35 +07 matches that call; the worker never ran the register — its report only says the file was "created").
- SSOT on disk NOW: **11455/1668/1592/2975** (+3 symbols, +1 ledger, +1 contracts, +2 schema), N2218 in the ledger with godot_owner `SourceAcceleratorBuildState.source_accelerator_battery_state`, 3 result symbols, 78 exact exprs, 223 deferred exprs, runtime_proof `/root/C07AcceleratorBattery`. The 223 deferred exprs are the shared cumulative pool (N2216 has 255, N2217 has 258, all starting with the same UnitCargoLoader entry) — NOT a worker error.
- Targeted re-run AFTER the register: Ran 4, failures=2, errors=0 — the registration + input-evidence tests now PASS (all 78 exact exprs verified against upstream Java by the passing test). The 2 remaining failures are the TRUE RED signal: (1) missing battery function in SourceAcceleratorBuildState.gd, (2) missing proof scene file.
- LESSON: never run a register script with `--verify` unless the file actually implements it — grep for 'verify' first. A silent exit 0 from a script with no verify handling means it registered. (The N2217 rule "silent --verify exit 0 = success" only holds for scripts that implement --verify.)
- The worker's report was wrong on two points: it claimed a red log at `hidden_files/n2218-red.log` (the file does NOT exist — it was never written), and it did not mention that the proof scene files were never written. The handoff (this file) and the daily-log entry were also not written before the timeout — the main thread wrote them in this turn.

## Scoping pinned in RED (do not re-decide in GREEN)

- N2183 folded the CONSUMER-side read (power.status -> efficiency) and deferred the BATTERY side. N2218 is the accelerator's live battery read: the graph-update stamp (the N2142 write-back pattern, extended to battery_stored) + a pure battery read over the stamped frame value + a driver tick line that stamps battery_stored / battery_fraction / can_launch_battery on the accelerator frame.
- Java: `public float getBatteryStored(){` with `float totalAccumulator = 0f;` and `totalAccumulator += battery.power.status * battery.block.consPower.capacity;` and `return totalAccumulator;` (PowerGraph.java:123-132) sums the enabled batteries' stored power; Java records it each update as lastPowerStored (`lastPowerStored = getBatteryStored();`, PowerGraph.java update) before the deficit/surplus branches use or charge the batteries. A frame with no stamp reads 0.0 before the first graph update, so the gate is false and the fraction is 0.0 until the graph stamps the live total — the same null-fold shape as the N2183 power row.
- The canLaunch battery half-gate (Accelerator.java:239-240, `power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f`) needs the stored total at the 1,000,000f requirement (Blocks.java:6826, `powerBufferRequirement = 1_000_000f;`); the powerBufferRequirement bar (Accelerator.java:105-109, `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`) shows the fraction.
- One pure function on SourceAcceleratorBuildState.gd (the file N2183 built — it already has the power-status driver, tick wiring, and frame binding):
  - `static func source_accelerator_battery_state(frame: Dictionary, power_buffer_requirement: float) -> Dictionary:` returning `{"battery_stored": ..., "battery_fraction": stored / power_buffer_requirement, "can_launch_battery": stored >= power_buffer_requirement - 0.00001}` — stored is the stamped `frame["battery_stored"]` (0.0 when absent).
  - Const `SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT` (1,000,000f), used by the driver tick line `source_accelerator_battery_state(frame, SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT)`; the driver stamps `frame["battery_stored"]`, `frame["battery_fraction"]`, `frame["can_launch_battery"]`.
  - The test also pins the Java comment lines verbatim in the state file (`public float getBatteryStored(){`, `float totalAccumulator = 0f;`, `totalAccumulator += battery.power.status * battery.block.consPower.capacity;`, `return totalAccumulator;`, `lastPowerStored = getBatteryStored();`, `power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f`, `() -> b.power.graph.getBatteryStored() / powerBufferRequirement`, `powerBufferRequirement = 1_000_000f;`, `public float useBatteries(float needed){`, `float stored = getBatteryStored();`, `power.graph.useBatteries(powerBufferRequirement);`) — read the full test file before writing GREEN; the middle asserts (graph stamp, driver wiring) were not re-read in this turn.
- Three new result symbols: `source_accelerator_battery_state_result.battery_stored`, `.battery_fraction`, `.can_launch_battery` (java_source PowerGraph.java / Accelerator.java).
- The launch itself consumes the battery (Accelerator.java:270, `power.graph.useBatteries(powerBufferRequirement);` with PowerGraph.java:162-163) — the launch waits for its own slice, so this read never drains stored power. The drawSelect warning (Accelerator.java:265-268) is presentation and waits for its own slice, but the gate value it compares is what this slice stamps as can_launch_battery.
- Proof math pinned (6 semantic keys): battery_half / battery_full / battery_gate_epsilon / battery_gate_below / battery_absent_defaults_zero / battery_live_tick_stamps_gate. Proof output line prefix `C_07_ACCELERATOR_BATTERY_PROOF `, scene `tools/runtime_proofs/C07AcceleratorBatteryProof.tscn`. The proof files still need to be written — the reference test currently fails on the missing .tscn, not on function behavior.
- SSOT after register (already on disk, see the correction above): 11455/1668/1592/2975. NO shard change expected — verify at completion (the Accelerator family was not in the power shards at N2183; check `git status` before staging).

## GREEN plan

1. Write the proof scene `C07AcceleratorBatteryProof.gd` + `.tscn` (6 semantic keys above) — RED is not complete until the reference test fails on function behavior instead of a missing file.
2. Implement the pure function + const + driver tick line + graph-update stamp (extend the N2142 write-back to battery_stored) with the EXACT lines the test pins. Read the full test file first — the state-test middle asserts were not re-read in the RED turn.
3. Targeted GREEN 4/4 (write a real `hidden_files/n2218-green.log`), family Accelerator (N2183 + N2218, 8 tests — verify at GREEN), wiring-standard set (same 9 modules / 32 tests as N2217), Godot proof (9 keys: 6 semantic + matches + 2 harness), full gate from the main thread only, then the classic 5-commit pattern + push. SSOT before GREEN: 11455/1668/1592/2975 (already registered).
4. Check port 7777 free before any proof run; never run proof scenes in parallel with another run. Check `git fetch origin` + origin/main before pushing (validation agent merges regularly). NOTE: godot is NOT on PATH in this shell — the binary lives at `~/workspace/godot-bin/godot`; GREEN must run the reference/proof tests with `PATH=~/workspace/godot-bin:$PATH`, otherwise the reference test fails with `godot is None`.
5. Do NOT re-run the register script to "verify" it — it has no --verify mode and re-running it re-registers (idempotent but confusing). Verify registration by reading the ledger entry and running the targeted registration test instead.

## GREEN verification (this run, 22:45 cron, ~22:55 +07)

- GREEN code added (proof scene first, per plan):
  - Proof `godot-mindustry/tools/runtime_proofs/C07AcceleratorBatteryProof.gd` + `.tscn` (6 semantic keys; live tick mirrors the N2183 proof: placed interplanetary-accelerator, frame pre-stamped battery_stored 1,000,000 + power_status 1.0, driver tick, re-read frame).
  - `SourceAcceleratorBuildState.gd`: const `SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT := 1000000.0` + pure `source_accelerator_battery_state(frame, power_buffer_requirement)` returning `{"battery_stored", "battery_fraction": stored / power_buffer_requirement, "can_launch_battery": stored >= power_buffer_requirement - 0.00001}` (stored = `frame.get("battery_stored", 0.0)`), with the verbatim Java comment lines the test pins (getBatteryStored / totalAccumulator / lastPowerStored / useBatteries); + 1 driver tick line in `source_accelerator_tick_buildings_state` (after the power-consumer block, for every ticked accelerator) stamping `frame["battery_stored"]` / `frame["battery_fraction"]` / `frame["can_launch_battery"]`.
  - `SourcePlacedPowerGraphState.gd`: `source_consumer_set_battery_stored_for_cell_state(game, cell, stored)` mirroring the N2142 power_status write-back (first family frame present, `frame["battery_stored"] = stored`).
  - `SourceFactoryRuntimeState.gd`: in `source_factory_update_power_graph_state`, after the consumer power_status write-back, `battery_stored_total = float(update.get("last_power_stored", 0.0))` stamped onto every updated consumer via `source_consumer_set_battery_stored_for_cell_state(game, consumer.get("origin_cell"), battery_stored_total)` (same fallback list as the power_status write-back, so the cheat branch is covered).
- Targeted GREEN: Ran 4 OK in 15.942s, log `hidden_files/n2218-green.log` (repo) + copy in goal `hidden_files/n2218-green.log`. Proof JSON 9 keys, all true, matches:true (battery_half / full / gate_epsilon / gate_below / absent_defaults_zero / live_tick_stamps_gate + matches + 2 harness). The epsilon boundary (stored 999999.99999) passes.
- Family Accelerator 8/8 OK in 29.345s (N2183 power_status + N2218 battery; log goal `hidden_files/n2218-family.log`).
- Wiring-standard 32/32 OK in 121.807s (same 9 modules as N2209–N2217; log goal `hidden_files/n2218-wiring.log`).
- GREEN total 44/44. `git diff --check` clean. SSOT 11455/1668/1592/2975, N2218 status "done" in ledger. NO shard change (empty `git diff` on `source_modules/`). Slice files: 3 modified .gd + 4 SSOT JSONs + test + register + proof .gd/.tscn (+ handoff); proof .json generated, never stage. Port 7777 free before the proof run; no parallel run active; no VM restart during this run (restart #27 was ~22:19, before RED).
- CORRECTION to the RED section above: `hidden_files/n2218-red.log` DOES exist — at repo-root `hidden_files/n2218-red.log` (verified this run with `ls` + `cat`: Ran 4, failures=2, errors=2, the pre-register RED). It is absent only from the goal `hidden_files/` dir. The worker's claim was right; the main-thread note was checking the wrong directory.
- The register script has no --verify mode (grep: 0 occurrences of 'verify'); do NOT re-run it. Registration verified by reading the ledger entry + the passing targeted registration test instead.

## Remaining (main thread)

1. Full gate from the main thread only (worker-launched gates die with the session), then the classic 5-commit pattern + push (spec Done 1667 → 1668 + N2218 row; GOAL.md §5 Windows debt line for N2218). Check `git fetch origin` + origin/main before pushing (validation agent merges regularly).

## After N2218

RepairTurret drawBeam rows, or the next deferred C07 item per backlog. (Do NOT start the C08 inventory unless the user asks.)

## CORRECTION — the red log DOES exist (main thread, ~23:0x +07)

- The RED turn's claim that `n2218-red.log` "was never written" was WRONG. The file exists at the REPO ROOT: `hidden_files/n2218-red.log` (not the goal hidden_files/, not tools/) — Ran 4 in 0.537s, FAILED (failures=2, errors=2). The main thread checked the wrong two paths in the RED turn; the 22:45 worker found it and fixed the discrepancy. Lesson: search with `find` (repo root + goal hidden_files + tools/) instead of guessing the log's home. The repo-root `hidden_files/` directory is working logs — never stage it.

## GREEN verification + gate (main thread, ~23:0x +07)

- GREEN verified by main thread: targeted re-run Ran 4 OK in 14.523s; family log Ran 8 OK (Accelerator N2183 + N2218); wiring log Ran 32 OK. GREEN total 44/44. Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false.
- GREEN code (all pure additions, 79 insertions across 3 files): const SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT := 1000000.0 (:98) + `source_accelerator_battery_state(frame, power_buffer_requirement)` (:100) + driver tick line (:166) in SourceAcceleratorBuildState.gd; new `source_consumer_set_battery_stored_for_cell_state(game, cell, stored)` in SourcePlacedPowerGraphState.gd (writes frame["battery_stored"] onto each consumer's family frame — the N2142 write-back pattern extended); `source_factory_update_power_graph_state` in SourceFactoryRuntimeState.gd now writes `last_power_stored` back to each consumer frame after the power_status write-back.
- SSOT 11452/1667/1591/2973 → **11455/1668/1592/2975** (symbols +3, ledger +1, contracts +1, schema +2; audit 1335). NO shard change (verified from `git status` — no `source_modules/` diff). Slice commit: 11 files (3 .gd + 4 SSOT JSONs + proof .gd/.tscn + register + test). The repo-root `hidden_files/` dir is working logs — never stage.
- Gate (main thread, PID 6333, SID 6333, ~23:01): godot NOT on PATH, javalang OK, no stray gate before launch. Finished ~23:18: **Ran 5965 tests in 1025.895s — FAILED (failures=168, skipped=5), 0 errors.** All 168 failures verified Godot-absent (168 × `AssertionError: unexpectedly None`, zero `ERROR:` lines). +4 tests / +1 failure vs N2217's 5961/167 — the +1 failure is the new N2218 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN and again in the main-thread targeted re-run). Log `tools/mindustry_godot_transpiler/full-suite-n2218-gate.log` (untracked, never staged). Gate ran ~2× faster than usual (1025.895s vs ~1930s). Gate VERIFIED by the 23:30 cron run; slice committed + pushed in the same tick.

## Commits

- Slice: 5652bba4 (C07: N2218 Accelerator battery side, 11 files)
- Docs: f959f50b (report + handoff + design spec, Done 1668 + N2218 row)
- GOAL: 8d904b01 (§5 Windows debt line for N2218)
- Hash-naming: (this commit)
- Handoff-status: (next commit)
