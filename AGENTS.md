# Mindustry Java -> Godot Migration Rules

This worktree ports `mindustry-upstream` Java behavior into `godot-mindustry` GDScript slice by slice.

Before each slice:
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
