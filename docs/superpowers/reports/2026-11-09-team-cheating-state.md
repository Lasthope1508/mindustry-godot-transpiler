# C05 live TeamRules cheating — N2099

Date: 2026-11-09. Batch: N2099 (single slice, fifth C05 batch). SSOT +3/+1/+1/+2 → 10829 / 1552 / 1440 / 2671; audit `totalSourceFunctions` stays 1335.

## What changed

The drill frame's `cheating` flag was hardcoded `false` forever: no live rules change could ever make a building cheat, even though Java reads it from the team's rules on every building. In Java, `TeamComp.cheating()` is `team.rules().cheat` (TeamComp.java:17-19); `Team.rules()` (Team.java:88-90) returns `state.rules.teams.get(this)`; `TeamRules.get` (Rules.java:391-394) creates a fresh `TeamRule` when the team has none, and `TeamRule.cheat` (Rules.java:328, "If true, blocks don't require power or resources.") defaults to false.

- N2099 `SourceRulesRuntimeState.source_team_cheating_state(rules_state, team_id)` — returns whether the team cheats: its `TeamRule` cheat flag, `false` for a missing team or a missing/empty rules state (the Java fresh `TeamRule`).
- The drill tick refreshes the frame's `cheating` flag from the live rules every tick instead of its hardcoded `false`, so a cheating drill skips its consumers and counts everything as valid (BuildingComp.java:1944-1945, "//everything is valid when cheating").
- `SourceRulesDefaults.TEAM_CHEAT_DEFAULT` (`false`) holds the Java boolean default for the flag.

## Verification

- New test `tools/mindustry_godot_transpiler/tests/test_team_cheating_state.py` (registration + exact-evidence + Godot proof) — RED before the register script ran (1 failure, 2 errors), GREEN after: 3 tests OK.
- Godot proof `TeamCheatingStateProof` **13/13 true** on the real Main scene: missing/null/empty rules and a missing team read `false`; team 1 with `cheat: true` reads `true`, team 2 reads `false`, a string team key reads `true`; the drill frame starts uncheating, sees `cheat: true` on its team after a tick, and sees `false` again after the flag is cleared.
- Targeted gate (log `~/workspace/logs/targeted-n2099.log`): 5496 tests, 2 failures — both in pre-existing Godot proofs, neither an N2099 regression. `test_pump_update_binding` (pump warmup): reproduced on the clean N2098 tree too; headless setup frames carry large real deltas, saturating pump warmup at 1.0 before the proof reads it. `test_drill_live_consumption` (autonomous/full/no-ore): flaky — the conduit flow timer + water stored during setup pushes ~2.9 water into the drill mid-proof. Both fixed test-only in the proof scripts (reset the measured frame / drain the conduit network before the measured steps; autonomous step now uses two controlled 1/60s ticks through the same `_process` entry). No runtime code changed. After the fixes the three affected modules pass: 9 tests OK.
- Full Python suite (log `~/workspace/logs/full-suite-n2099.log`): 5496 tests, 3 failures — all three are the MCP port-7777 `ERROR:` string in pre-existing conveyor proofs (`test_conveyor_queue_storage_binding`, `test_conveyor_stack_binding`, `test_drill_conveyor_dump_binding`); each proof's own JSON is all-true (`matches: true`), so they are environment flakes, not an N2099 regression. Rerun of the three affected modules: 9 tests OK.

## SSOT delta

+3 symbols / +1 slice / +1 contract / +2 schemas → 10829 / 1552 / 1440 / 2671; audit `totalSourceFunctions` stays 1335. No module shard mirrors the owner (`entities/comp/TeamComp.java` matches no selection).

## Still open

- C05: cache invalidation on Block reinit/reload; wiring other buildings (turrets, factories) to the live cheating value. C03 full-power live case deferred. C02 live-loop sprite wiring + clogHeat, C06–C12 still open. Editor parse, deterministic replay and native MCP proof still open.
