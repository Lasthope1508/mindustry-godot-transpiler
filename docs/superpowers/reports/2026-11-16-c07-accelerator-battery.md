# Report — N2218: Accelerator battery side (PowerGraph.java / Accelerator.java, C07)

Date: 2026-11-16. Batch: N2218 (single slice). Status: **DONE + GATE VERIFIED (2026-11-16 ~23:2x +07 — targeted 4/4, family 8/8, wiring 32/32; full gate Ran 5965, failures=168, skipped=5, 0 errors, all 168 verified Godot-absent). Slice (this commit) / docs (this commit) / GOAL (next commit). Ready to push (origin/main bd47fc2f — PR #14 validation merge fast-forwarded into local main in this tick, no conflicts).**

## What changed

N2217 is DONE + PUSHED (main 70540538); this slice is the Accelerator battery side — the piece the N2217 handoff named ("Accelerator battery side or RepairTurret drawBeam rows per backlog"). Java: `public float getBatteryStored(){` with `float totalAccumulator = 0f;` and `totalAccumulator += battery.power.status * battery.block.consPower.capacity;` and `return totalAccumulator;` (PowerGraph.java:123-132), recorded each update as `lastPowerStored = getBatteryStored();` (PowerGraph.java:236); the canLaunch battery half-gate `power.graph.getBatteryStored() >= powerBufferRequirement-0.00001f` (Accelerator.java:239-240) at the 1,000,000f requirement (`powerBufferRequirement = 1_000_000f;`, Blocks.java:6826); the powerBufferRequirement bar `() -> b.power.graph.getBatteryStored() / powerBufferRequirement` (Accelerator.java:105-109). No gameplay change; slice committed in this tick, docs + push below.

What N2218 adds (11 files, NO shard change):

- **One pure function + one const.** `SourceAcceleratorBuildState.source_accelerator_battery_state(frame, power_buffer_requirement)` (:100) — returns `{"battery_stored": stored, "battery_fraction": stored / power_buffer_requirement, "can_launch_battery": stored >= power_buffer_requirement - 0.00001}` where stored is the stamped `frame["battery_stored"]` (0.0 when absent). `const SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT := 1000000.0` (:98). The verbatim Java comment lines the test pins are in the file (getBatteryStored / totalAccumulator / lastPowerStored / useBatteries).
- **One driver tick line** in `source_accelerator_tick_buildings_state` (:166) — stamps `frame["battery_stored"]` / `frame["battery_fraction"]` / `frame["can_launch_battery"]` for every ticked accelerator, after the power-consumer block.
- **Graph-update stamp (N2142 write-back pattern, extended).** `SourcePlacedPowerGraphState.source_consumer_set_battery_stored_for_cell_state(game, cell, stored)` (:111) writes `frame["battery_stored"]` onto each consumer's family frame; `SourceFactoryRuntimeState.source_factory_update_power_graph_state` (:1120-1123) reads `last_power_stored` from the graph update and stamps it onto every updated consumer via the same fallback list as the power_status write-back, so the cheat branch is covered.
- **Test module + register script** `test_c07_accelerator_battery.py` + `register_c07_accelerator_battery.py`. SSOT baseline re-verified from disk: 11452/1667/1591/2973, audit 1335. After GREEN: **11455/1668/1592/2975** (+3/+1/+1/+2), audit 1335. NO shard change (Accelerator family is not in the power shards — N2183 precedent; verified from `git status` at completion). NOTE: the register script has NO --verify mode — the RED turn's `--verify` call silently REGISTERED N2218 (ledger mtime 22:49:35 +07). Do NOT re-run the register script to "verify" it; verify registration by reading the ledger entry + the passing targeted registration test instead.
- **Proof scene** `C07AcceleratorBatteryProof.gd` (+ `.tscn`, `.json` untracked per .gitignore:6). 6 semantic keys: battery_half / battery_full / battery_gate_epsilon / battery_gate_below / battery_absent_defaults_zero / battery_live_tick_stamps_gate.
- **Handoff** `docs/superpowers/handoffs/2026-11-16-c07-accelerator-battery-handoff.md` — design, RED decisions, Java evidence, scope, gate result.

## RED → GREEN (22:30 cron worker; verified by main thread ~23:00 +07)

Targeted RED: Ran 4, failures=2, errors=2 — classic RED (KeyError 'N2218' ×2, missing `source_accelerator_battery_state`, missing proof scene). After the accidental register, targeted re-run: Ran 4, failures=2, errors=0 — the 2 remaining failures were the TRUE RED signal. GREEN: targeted **4/4 OK in 15.942s** (worker, log `hidden_files/n2218-green.log` in repo + goal). Main-thread re-run **4/4 OK in 20.807s** (log goal `hidden_files/n2218-targeted-verify-2300.log`, live Godot proof). Proof JSON 9 keys (6 semantic + matches + 2 harness), matches:true, 0 false, Godot headless 4.6.2-stable Linux in this VM. The epsilon boundary (stored 999999.99999) passes.

## Family/wiring (22:45 cron worker; verified by main thread ~23:00 +07)

Family Accelerator **8/8 OK in 29.345s** (N2183 power_status + N2218 battery; log `n2218-family.log`). Wiring-standard set **32/32 OK in 121.807s** (same 9 modules as N2209–N2217; log `n2218-wiring.log`). **GREEN total 44/44.** Port 7777 free before every proof run; no parallel run active. VM restart #27 ~22:19 +07 happened BEFORE the worker run (javalang 0.13.0 survived, nothing lost). `git diff --check` clean.

## Gate (VERIFIED 2026-11-16 ~23:2x +07)

Full gate `python3 -m unittest discover -s tests` launched from the MAIN thread (~23:01; godot NOT on PATH, javalang OK). Finished ~23:18: **Ran 5965 tests in 1025.895s — FAILED (failures=168, skipped=5), 0 errors.** All 168 failures verified Godot-absent: 168 × `AssertionError: unexpectedly None` (plain `assertIsNotNone(godot)`), zero `ERROR:` lines in the log. +4 tests / +1 failure vs N2217's 5961/167: the 4 new N2218 tests; the +1 failure is the new N2218 proof test, also Godot-absent in the gate (its real Godot proof ran green headless at GREEN and again in the main-thread targeted re-run). No failure names any N2218 function except that one proof test. Gate clean except Godot — the expected signature. Log `tools/mindustry_godot_transpiler/full-suite-n2218-gate.log` (untracked, never staged). Gate ran ~2× faster than usual (1025.895s vs ~1930s).

## PUSH (in this tick)

Gate verified: report → spec (Done/ledger 1667 → 1668 + N2218 row) → GOAL.md §5 (Windows proof stays debt). Slice commit (11 files, no shard change) → docs + GOAL → hash-naming commit → handoff-status commit → push to origin main in this tick (origin/main already fast-forwarded to bd47fc2f in this tick).

## Deferred (NOT this slice)

- The launch itself drains the battery (`power.graph.useBatteries(powerBufferRequirement);`, Accelerator.java:270) — waits for its own slice; this read never drains stored power.
- The drawSelect warning (Accelerator.java:265-268) is presentation — waits for its own slice; the gate value it compares is what this slice stamps as can_launch_battery.
- `getBatteryCapacity` / `getTotalBatteryCapacity` rows (PowerGraph.java:134-157) — capacity reads wait for their own slice.
- Combined `canLaunch()` evaluation (efficiency + battery + progress + campaign/net/validity gates) — no single evaluation exists yet; progress and the other gates wait for their own slices.
- RepairTurret drawBeam rows — next candidate per backlog.
- Windows Godot proof — debt in GOAL.md §5, same as N2217.
- C08 inventory — NOT started unless the user asks.

## Commits

- Slice: (this commit)
- Docs: (this commit)
- GOAL: (next commit)
