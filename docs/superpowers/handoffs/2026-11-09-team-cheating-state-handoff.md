# Handoff — C05 live TeamRules cheating (N2099)

Date: 2026-11-09. Batch: N2099 (single slice, fifth C05 batch). Commit: ed2aa3b.

## Done

- `SourceRulesRuntimeState.source_team_cheating_state(rules_state, team_id)` — whether the team cheats: `TeamComp.cheating()` (TeamComp.java:17-19 `return team.rules().cheat;`; Team.java:88-90 `return state.rules.teams.get(this);`; Rules.java:391-394 `TeamRules.get` creates a fresh `TeamRule` for a missing team; Rules.java:328 `TeamRule.cheat`, default false). A missing team or missing/empty rules state reads `false`.
- The drill tick refreshes the frame's `cheating` flag from the live rules every tick instead of its hardcoded `false`; a cheating drill skips its consumers and counts everything as valid (BuildingComp.java:1944-1945).
- `SourceRulesDefaults.TEAM_CHEAT_DEFAULT` (`false`) holds the Java boolean default.
- Register script `tools/mindustry_godot_transpiler/register_team_cheating_state.py`; test `tools/mindustry_godot_transpiler/tests/test_team_cheating_state.py`; proof `godot-mindustry/tools/runtime_proofs/TeamCheatingStateProof.gd/.tscn`.
- SSOT +3/+1/+1/+2 → 10829 symbols / 1552 slices / 1440 contracts / 2671 schemas; audit `totalSourceFunctions` stays 1335. No module shard mirrors the owner (TeamComp.java).

## Verification

- Test RED before the register script (1 failure, 2 errors), GREEN after: 3 tests OK.
- Godot proof `TeamCheatingStateProof` 13/13 true on the real Main scene.
- Targeted gate (log `~/workspace/logs/targeted-n2099.log`): 5496 tests, 2 failures — `test_drill_live_consumption` (autonomous_process, no_ore) and `test_pump_update_binding` (pump_update_warmup). Neither is an N2099 regression:
  - Pump warmup: reproduced 4/4 on the current tree AND on the clean N2098 tree (N2099 stashed). Debug print: `before_warmup=1.0, before_progress=32.94` — the live loop had already saturated warmup during setup because headless frames carry large real deltas (edelta >> 1.0), so `move_toward` clamps instead of adding 0.019. Passes with `--fixed-fps 60`. Fix (test-only, this batch): `PumpUpdateProof.gd` now resets the pump frame's warmup/total_progress to 0.0 before the measured update, so the delta assertion measures exactly one frame from a known state.
  - Drill live consumption: flaky, not deterministic — failed in the gate run and on reruns (3 of 7 runs before the fix), then passed. Debug prints showed the only wrong component was the drill's liquid amount (3.89 instead of 1.0 at the full-output step; efficiency 0.0 and dominant_item null were correct). Root cause: the conduit flow timer (1s) + water stored during setup — headless setup frames carry large real deltas, so the pump floods the conduits and a conduit's timer fires mid-proof, pushing ~2.9 water into the drill in one tick. Fix (test-only, this batch): `DrillLiveConsumptionProof.gd` now drains the conduit network (each conduit's water → 0, flow timer → 0; pump water → 0) before the measured steps, and the autonomous step uses two direct `tick(game)` calls at the controlled 1/60s delta instead of two real frames (same `_process` entry, no wall-clock race). No runtime code changed.
- Full Python suite: rerunning after the proof fixes (log `~/workspace/logs/full-suite-n2099.log`).

## Collision note (2026-11-09 ~11:45 +07)

While this batch was being written, a background worker was writing the same N2099 slice in the same worktree: it appended a second `source_team_cheating_state` (Dictionary signature, wrong Java line cites: Rules.java:379-382/326) to `SourceRulesRuntimeState.gd` and a second identical `frame["cheating"]` assignment to the drill tick. Both duplicates were removed; the kept version is the one with verified citations (TeamComp.java:17-19, Team.java:88-90, Rules.java:391-394, Rules.java:328, BuildingComp.java:1944-1945) and null/empty-rules handling. If the worker writes more N2099 files, check `git status` / `git diff` before the next gate run — do not run two gates on the same slice at once.

## Still open

- C05 next: cache invalidation on Block reinit/reload; wiring other buildings to the live cheating value. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.

## Files

- `godot-mindustry/src/game/SourceRulesRuntimeState.gd` (new function `source_team_cheating_state`)
- `godot-mindustry/src/game/SourceRulesDefaults.gd` (new const `TEAM_CHEAT_DEFAULT`)
- `godot-mindustry/src/game/SourceDrillConsumptionRuntimeState.gd` (tick refreshes `frame["cheating"]` from the live rules)
- `godot-mindustry/src/generated/source_api_contracts.json`, `source_slice_ledger.json`, `source_state_schema.json`, `source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/PumpUpdateProof.gd` (test-only: reset pump frame warmup/total_progress before the measured update — headless setup frames can saturate warmup at 1.0 via large real deltas; no runtime code changed)
- `godot-mindustry/tools/runtime_proofs/DrillLiveConsumptionProof.gd` (test-only: drain the conduit network before the measured steps and drive the autonomous step with two controlled 1/60s ticks instead of two real frames; no runtime code changed)
- `godot-mindustry/tools/runtime_proofs/TeamCheatingStateProof.gd`, `TeamCheatingStateProof.tscn`
- `tools/mindustry_godot_transpiler/register_team_cheating_state.py`
- `tools/mindustry_godot_transpiler/tests/test_team_cheating_state.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`
- `docs/superpowers/reports/2026-11-09-team-cheating-state.md`
- `docs/superpowers/handoffs/2026-11-09-team-cheating-state-handoff.md`
