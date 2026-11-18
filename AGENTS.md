# Mindustry Java -> Godot Migration Rules

This worktree ports `mindustry-upstream` Java behavior into `godot-mindustry` GDScript slice by slice.

Before each slice:
- Read `docs/superpowers/GOAL.md` — the ultimate goal (finish C01–C12, faithful port, release candidate) and the boundaries that keep this work on track.
- Read `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md`.
- Read all five SSOT files under `godot-mindustry/src/generated/`:
  - `source_symbol_registry.json`
  - `source_symbol_audit_report.json`
  - `source_slice_ledger.json`
  - `source_api_contracts.json`
  - `source_state_schema.json`
- Read SSOT extension manifest `godot-mindustry/src/generated/source_ssot_modules.json` and any shard JSON it registers under `godot-mindustry/src/generated/source_modules/`.
- Read exact upstream Java source for the slice from `mindustry-upstream`.

Hard rules:
- Do not invent variable names, parameters, defaults, behavior, or formulas.
- New runtime state, API shape, source symbol, or variable name must be source-backed and registered in SSOT in the same slice.
- New SSOT JSON shard must be registered in `source_ssot_modules.json`, must live under `src/generated/source_modules/`, and must expose one canonical `root_key`.
- Prefer existing names from SSOT and upstream Java. If two names mean the same thing, normalize to SSOT instead of adding another synonym.
- Defer behavior that needs another Java line into a later slice instead of guessing.
- Keep each slice small and source-backed. Maximum 1-3 slices per turn.

Required slice flow:
1. Read checklist, SSOT, and exact upstream Java.
2. Write RED tests first.
3. Run targeted tests and confirm expected failure.
4. Implement minimal GREEN code.
5. Run targeted tests.
6. Run full JSON and Python test gate.
7. Prove behavior through Godot MCP runtime, not headless-only.
8. Update checklist totals and add slice row.
9. Run `git diff --check`.
10. Stage exact slice files only.
11. Commit the slice.

Godot MCP:
- Use project path `C:/Users/Admin/.config/superpowers/worktrees/Game/mindustry-godot-transpiler/godot-mindustry`.
- Runtime MCP uses TCP port `7777`.
- After runtime calls, check editor debug output and stop the project. Require empty errors.

Do not stage or revert known workspace noise unless the user explicitly asks:
- `godot-mindustry/project.godot`
- `arc-upstream/`
- `*.gd.uid`

Agent use:
- Spawn agents only for independent non-conflicting work.
- Do not spawn agents for slices touching shared SSOT JSON, checklist totals, or `godot-mindustry/src/game/PortGame.gd`.

## Family ownership split between lines (Isabella, 2026-11-17 ~19:06 +07)

Two lines work on this repo in parallel (this VM + the Windows/other line) and
each family lives in ONE GD file, so two lines touching the same family edit
the same file. After two divergences in one day (remote N2233 RepairTurret
colliding with local N2233 on SourceRepairTurretBuildState.gd), families are
split — each line works ONLY its own families:
- This VM line: Turret, BurstDrill, Radar, Game.
- Windows/other line: RepairTower, RepairTurret, PointDefenseTurret (Isabella 2026-11-18 ~16:08 +07, after 9 straight PointDefenseTurret slices N2239–N2247 from the Windows line).
Ambient B (N2260, RepairTurret driver tick line) belongs to the Windows line;
ambient C (N2264, SoundControl mixer, game-level) belongs to this VM line but
waits for B. Never start a slice in another line's family. If the other line
has already pushed a number you need, renumber yours (precedent N2228) — never
take their number. (Restored 2026-11-18: this section was lost in the round-3
reset to 7dfdec3; B/C renumbered from N2242/N2243 — remote took both numbers,
divergences #11/#13.)

## Standing hourly Godot validation duty (user-authorized 2026-11-15)

- At every scheduled validation run or context recovery, read `docs/superpowers/tasks/hourly-godot-validation.md` before acting. This is the persistent scope and recovery contract for the validation agent, not an instruction for migration agents to change their slices.
- Audit new main revisions hourly. A passing actual Godot Linux proof already satisfies this duty; Windows is also acceptable. Never repeat tests solely because Windows evidence is absent.
- Validate only slices without credible passing Godot evidence for their current implementation. Missing-engine full-gate failures alone do not imply missing proof when a separate real engine run passed.
- Do not implement or modify unrelated slices, gameplay, SSOT, migration totals, or another agent's in-progress work. Do not weaken assertions to obtain a pass.
- Publish and merge only this agent's narrowly scoped passing validation reports/evidence and necessary isolated proof-fixture repairs, following the task contract. Unresolved failures must be reported, never merged as GREEN.
- Preserve dirty workspaces, use an isolated validation branch, stage exact files, check main again before merging, and never force-push main or resolve another agent's changes by overwriting them.
- Save the tested SHA, evidence, pending work and next action to the on-disk checkpoint after each run. Do not rely on chat history or memory alone.

## Wiring-standard test set (pinned 2026-11-18, research agent 4deb807f)

Every slice re-verifies this fixed set after targeted + family, before
committing. 9 modules, 32 tests, run from
`tools/mindustry_godot_transpiler/` with pytest (one command, ~135s):
`test_power_graph_live_update_binding`, `test_battery_power_status_binding`,
`test_battery_placement_binding`, `test_adjacent_factory_live_loop`,
`test_unit_factory_live_loop`, `test_turret_live_loop`,
`test_continuous_liquid_turret_live_loop`,
`test_power_graph_consumer_cheating`, `test_factory_live_loop`
(all `tests/<name>.py`). Subtest total drifts as slices land (235 at
N2270/N2271 in worktrees, 250 in main at N2271, 250 also at N2231) —
registry/Godot-dependent, not a module-list change. Reference-graph
tests in this set fail transiently on port-7777 contention with a
sibling worker's Godot proof; re-run the failed module alone before
calling it a real failure.
