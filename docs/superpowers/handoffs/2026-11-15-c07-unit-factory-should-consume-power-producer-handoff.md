# Handoff — N2189 Give C06UnitFactoryShouldConsumeProof a power producer

Date: 2026-11-15. Batch: N2189 (single slice, proof-harness-only). Status: **DONE + PUSHED (gate clean except Godot; slice bcde8e4, docs 0607d3e, GOAL 32a13c8, main a9dd441).**

## Scope (verified against upstream Java + the port this run)

- **N2189 gives `C06UnitFactoryShouldConsumeProof` a power producer, and
  nothing else.** One proof scene
  (`godot-mindustry/tools/runtime_proofs/C06UnitFactoryShouldConsumeProof.gd`),
  one placed block (thorium-reactor), one new proof key pinning the fix.
  It closes the exact gap the N2188 handoff root-caused and documented as
  the follow-up: the scene places 3 power consumers with NO producer, so
  the live graph stamps `power_status = 0.0` and the three
  `efficiency == 1.0` live keys fail no matter what shouldConsume says.
- **Proof-harness-only: no game code, no SSOT change, no new test module,
  no register script.** The two existing neighbour modules
  (`test_c06_unit_assembler_payload_should_consume.py`,
  `test_unit_factory_should_consume.py`) ARE the RED tests — both fail
  deterministically today on the same 3 live keys (3 independent runs in
  the N2188 handoff, zero-contention confirmed). The gate baseline is
  unchanged (Ran ~5849, failures ~139, 0 errors): no new test is added.
- **Why this item, why now:** it is the documented N2188 follow-up, the
  smallest deferred item, and it unblocks the two neighbour modules that
  have been red since the N2142 + N2160–N2187 power.status campaign.

## Design (decided in scoping, to confirm at GREEN)

- **Producer: one thorium-reactor at (25, 7), the exact N2146 precedent**
  (`AdjacentFactoryConsumerBindingProof.gd:63-73`, same comment shape,
  same cell): "A thorium reactor (powerProduction 15.0, no fuel in the
  port's producer model) covers the whole graph, so the efficiency keys
  below are isolated from power." That proof solved the identical failure
  mode the identical way and is GREEN.
- **Coverage math (verified this run):** worst case needed = ground-factory
  1.2f + additive-reconstructor 3f + tank-assembler 2.5f = **6.7 < 15.0**,
  so coverage = min(1.0, 15.0 / 6.7) = **1.0** with 2.2x margin. (In this
  scene the assembler never shouldConsumes, so live needed peaks at 4.2;
  the 6.7 bound covers every tick of the proof either way.)
- **Why NOT the cheating-team option** (also listed in the N2188 handoff):
  it would work — Java `PowerGraph.update()` (PowerGraph.java:217-224)
  sets every consumer's power.status to 1f when the first consumer
  cheats, and the port implements that branch
  (`SourcePowerGraphState.update_state`, cheat branch) — and Java
  `BuildingComp.updateConsumption()` (BuildingComp.java:1944-1948) keeps
  `efficiency = shouldConsume() ? potentialEfficiency : 0f` while cheating,
  so the assembler-zero keys would survive. But cheating skips the live
  distribute path entirely (the update returns before
  getPowerNeeded/getPowerProduced/distributePower), so the proof would stop
  exercising the live graph it is a live-loop proof of; and it changes
  consumption semantics (items/liquids not drained) for the whole scene.
  The reactor keeps the real distribute path running and changes nothing
  else — same reason N2146 chose it.
- **Why NOT solar panels:** solar-panel is 0.12f (Blocks.java:2609) — 56
  panels for 6.7; solar-panel-large is 1.6f (Blocks.java:2615) — 5 panels.
  Both are more clutter than one reactor and neither is the established
  precedent for this exact failure.
- **Placement:** right after the assembler placement, before the frame
  setup, mirroring the adjacent proof (reactor at (25, 7); the factories
  sit at (30, 7), (35, 7), (40, 7) — no overlap). The reactor joins the
  graph through the same `record_placed_block` + `_group_state` path as
  every other placed block; it carries no unit-factory frame, so
  `ticked_count` stays 3.
- **New proof key (1):** `should_consume_live_power_status_one` —
  after the 3 `simulate_factory` ticks, `factory_frame["power_status"]
  == 1.0` (the graph update writes `frame["power_status"]` onto the
  placed building's family frame — `SourcePlacedPowerGraphState.gd:89-104`
  — and the unit-factory driver reads `frame.get("power_status", null)`
  at `SourceUnitFactoryBuildState.gd:655`). The test modules assert only
  `matches`, no exact key count, so adding a key is safe as long as it
  is true. Proof goes 43 → 44 keys.
- **No .tscn change** (it references the .gd only). **No SSOT change
  expected** (no new symbol, no new slice row — N2189 is a harness fix,
  not a port slice; the ledger/SSOT totals stay 11390/1639/1560/2911,
  audit 1335 — verify at the GREEN register run).

## Java source evidence (all verified verbatim this run — grep 2026-11-15 ~13:3x)

- `consumePower(1.2f);` (Blocks.java:6276, ground-factory)
- `consumePower(3f);` (Blocks.java:6306, additive-reconstructor)
- `consumePower(2.5f);` (Blocks.java:6532, tank-assembler)
- `powerProduction = 15f;` (Blocks.java:2625, thorium-reactor,
  `thoriumReactor = new NuclearReactor("thorium-reactor")`)
- `return build.power.status;` (ConsumePower.java:39, the power row the
  factory driver folds)
- `consumer.power.status = coverage;` (PowerGraph.java:203, the distribute
  write-back)
- `coverage = min(1.0, produced / needed)` — via `distributePower`
  (PowerGraph.java:203 context; port `distribute_power_state`,
  `SourcePowerGraphBatteryDistributionState.gd:186-210`)
- Cheat branch, considered and rejected (see Design):
  `if(!consumers.isEmpty() && consumers.first().cheating()){` +
  `//when cheating, just set status to 1` (PowerGraph.java:217-218);
  `//everything is valid when cheating` +
  `efficiency = optionalEfficiency = shouldConsume() ? potentialEfficiency : 0f;`
  (BuildingComp.java:1944-1946)
- Port evidence: `block_producer_state` reads catalog `powerProduction`
  directly, no fuel/efficiency gating
  (`SourceBuildingPowerState.gd:189-202`); the port's producer model is
  why the N2146 comment says "no fuel in the port's producer model".
  (In real Java a fuel-less NuclearReactor produces 0 — the reactor
  placement relies on the port's simplification, exactly as N2146 did.
  That is a known harness limitation, not a game-code change.)

## RED state (carried from the N2188 handoff, NOT re-run this tick)

- `test_c06_unit_assembler_payload_should_consume` +
  `test_unit_factory_should_consume`: **Ran 8, FAILED (failures=2)**,
  zero-contention, port 7777 FREE, no Godot running — the SAME 3 live
  keys False in both modules (40/43 keys True each):
  `should_consume_live_factory_efficiency_one`,
  `should_consume_live_reconstructor_efficiency_one`,
  `should_consume_live_reconstructor_payload_restored_one`, 0 ERROR lines.
  Third independent failure with identical keys — deterministic real
  regression in the proof scene's scenario, not a flake, not contention,
  not N2188 (N2188's diff is additive-only and touches none of the code
  the failing scene reads).

## GREEN steps (not yet run)

1. Edit `C06UnitFactoryShouldConsumeProof.gd`: place the thorium-reactor
   (+ N2146-style comment) and add the `should_consume_live_power_status_one`
   key after the 3-tick frame re-read.
2. Run the proof scene headless (Godot 4.6.2 on PATH, port 7777 FREE) and
   read `C06UnitFactoryShouldConsumeProof.json` from disk: expect 45 keys,
   `matches: true`, no ERROR lines.
3. Run both neighbour modules (`test_c06_unit_assembler_payload_should_consume`
   + `test_unit_factory_should_consume`): expect Ran 8, OK.
4. Neighbours: wiring 9 modules / 32 tests (unaffected — no game code
   touched; re-run to confirm, isolated, port free).
5. Full gate (main thread, no Godot on PATH, log
   `full-suite-n2189-gate.log` truncated fresh): expect Ran ~5849,
   failures ~139, skipped 5, 0 errors — the N2188 baseline, unchanged.
6. Report + handoff update + GOAL.md §5 (Windows-debt line already covers
   N2188; N2189's proof is Linux-green, Windows run stays debt until run
   there). Commit + push only after the gate verifies (slice commit:
   proof scene only; docs commit: report + handoff; GOAL commit if §5
   changes; verify origin/main before pushing — the N2187 lesson).
7. **Next after N2189:** the remaining C07 deferred items per the N2188
   handoff table — RepairTower shouldConsume (`targets.size > 0`,
   needs the target-refresh slice first), ShockwaveTower shouldConsume
   (`reloadCounter < reload`, needs the updateTile charge advance),
   BuildTurret shouldConsume (plans count + suppression state),
   ShieldWall broken()/damage coupling, MassDriver / LaunchPad rows,
   RepairTurret coolant — each its own slice; or C08 inventory (classify
   the 5,390 null-body functions) when asked.

## GREEN done (cron tick 13:30, ~13:4x +07, main-thread verified)

- Proof scene edit only: thorium-reactor placed at (25, 7) + N2146-style
  comment + new key `should_consume_live_power_status_one`. No game code,
  no SSOT, no test-module change. `git diff --check` clean.
- **Godot proof (headless, Godot 4.6.2 on PATH, port 7777 FREE): exit 0,
  0 ERROR lines, JSON 45 keys, `matches: true`, 0 false keys** — the 3
  previously-failing live keys now pass, and the new power-status key is
  true. (Key count reconciled: 44 assignments before = 40 true + 3 false
  + `matches` false; now 45 assignments, all true.)
- **Neighbour modules: Ran 8, OK in 28.061s** (assembler 4 + factory 4).
- **Wiring 9 modules / 32 tests: 32/32 OK** (log `n2189-wiring.log`,
  ~13-14s per module, no flake, port free throughout).
- **Full gate LAUNCHED (this tick): PID 5543, SID 5543** (own session,
  detached via setsid — survives this run ending), log
  `full-suite-n2189-gate.log` truncated fresh, Godot NOT on PATH
  (verified `command -v godot` empty before launch), growing dots + F's
  at launch check. Expected Ran ~5849, failures ~139, skipped 5, 0
  errors. Do NOT launch another gate while PID 5543 runs. Next tick:
  verify the gate from the log on disk, then report + GOAL.md §5 +
  commit + push (re-check origin/main first — at launch it was still
  18818ad, same as HEAD).
- NOT done: gate result, report, GOAL.md §5, commit + push. Windows Godot
  proof stays debt in GOAL.md §5.

## Environment (checked this run, 13:30 +07)

- Port 7777 FREE; no other Godot running.
- **javalang was NOT importable (VM restarted again, #11) — reinstalled
  0.13.0 this run** (`pip install --break-system-packages -r
  tools/mindustry_godot_transpiler/requirements.txt` from the repo root;
  the rule holds: reinstall after every restart before any gate).
- Godot binary exists at `~/workspace/godot-bin/godot` (4.6.2-stable) but
  is NOT on PATH in the worker shell — the GREEN proof run must export
  `PATH="$HOME/workspace/godot-bin:$PATH"` first (the N2177 lesson).
- Worktree: main at 18818ad (N2188 DONE + PUSHED); clean except
  pre-existing untracked `*.gd.uid` noise (never stage). This handoff is
  the only new file, untracked, NOT staged, NOT committed.

## CORRECTION — gate + neighbours (main thread ~13:4x +07)

- The 13:30 worker's "gate running detached (PID 5543)" is WRONG: no `unittest discover` process exists; the gate log (`full-suite-n2189-gate.log`, 3637 bytes, dots only, no footer) died mid-run at ~3600 tests when the worker session ended — the standard worker-launched gate death. Main thread relaunched the gate (PID 5857, SID 5857, ~13:44): `which godot` → NOT on PATH (correct baseline), log truncated fresh and growing with dots + F's.
- The worker's "neighbour 2 module Ran 8 OK" had NO log file on disk (only `n2189-wiring.log` existed). Main thread verified it directly: `test_c06_unit_assembler_payload_should_consume` Ran 4 OK (13.478s) + `test_unit_factory_should_consume` Ran 4 OK (13.581s), port 7777 FREE → **neighbours 8/8 confirmed**.
- Wiring 32/32 verified from `n2189-wiring.log` (9× OK).
- Proof JSON verified: **45 keys, matches:true, 0 false keys**.
- The N2189 change is harness-only and minimal: +19 lines in `C06UnitFactoryShouldConsumeProof.gd` (thorium reactor at (25,7), powerProduction 15.0, covers worst case 6.7) + handoff. No game code, no SSOT change.
- NOT done: gate result, then commit + push (N2189 is a harness fix — commit scope is the proof scene + handoff/report only; no spec/GOAL slice row unless the slice process requires it — decide at completion from the handoff).

## COMPLETION — gate verified + pushed (main thread ~14:0x +07)

- **Full gate VERIFIED from the log on disk** (log `full-suite-n2189-gate.log`, finished ~14:00 +07, mtime): **Ran 5849 tests in 969.656s, FAILED (failures=139, skipped=5)** — no errors field, 0 `ERROR:` lines, **139 × `AssertionError: unexpectedly None`**, 0 port-7777 bind errors. Exactly the N2188 baseline, unchanged. Gate clean except Godot. No VM restart during the gate.
- **Proof JSON re-verified from disk:** 44 keys + `matches` = 45 assignments, all true, `matches: true`, 0 ERROR lines; new key `should_consume_live_power_status_one` true; the 3 previously-failing live keys true.
- **Neighbours 8/8 OK + wiring 32/32 OK** (main-thread verified ~13:4x, see GREEN done above).
- **origin/main re-checked before pushing: still 18818ad, same as HEAD** — no validation-agent PR landed mid-run.
- **Commits + push:** slice `bcde8e4` (proof scene only, +19 lines); docs commit (this handoff + report `docs/superpowers/reports/2026-11-15-c07-unit-factory-should-consume-power-producer.md`); GOAL commit (GOAL.md §5 names `bcde8e4` as the commit carrying the proof to Windows). Pushed ~14:0x +07 to the fork (Lasthope1508). Status: **DONE + PUSHED**.
- SSOT unchanged: 11390/1639/1560/2911, audit 1335. Windows Godot proof stays debt in GOAL.md §5.
