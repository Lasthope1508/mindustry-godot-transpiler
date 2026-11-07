# Handoff — Teams core registration binding (N2074–N2075)

Date: 2026-11-07. Parent: `cb64abd`. Sequential C01–C12 goal, C01 batch. Read with `docs/superpowers/handoffs/2026-11-02-mindustry-completion-backlog.md` and `docs/superpowers/reports/2026-11-07-teams-core-registration-binding.md`; this handoff does not replace upstream Java or root SSOT.

## What these slices did

Bound Teams.registerCore / unregisterCore (Teams.java), the C01 complete-removal piece, in a new file `SourceTeamsRuntimeState.gd` operating on a `teams_state` dict (`{"teams": {team_id: {"cores": [...], "buildings": [...], "units": [...], "core_enemies": [...]}}, "active": [team_ids], "rules": {"wave_team": int, "waves": bool}}`). Team ids follow the runtime convention (derelict 0, sharded 1, crux 2, neoplastic 6 from Team.java:41). The `active()` check and `updateEnemies()` recompute are internal helpers in the same file.

- **N2074 `SourceTeamsRuntimeState.source_teams_register_core_state(teams_state, team_id, core_ref) -> Dictionary`** — adds the core ref to the team's cores if not present, and if the team is now active and wasn't in the active list, adds it and recomputes enemies. Result keys: `registered, active_changed, active, enemies_by_team, teams_state`.
- **N2075 `SourceTeamsRuntimeState.source_teams_unregister_core_state(teams_state, team_id, core_ref) -> Dictionary`** — removes the core ref from the team's cores if present, and if the team is no longer active and was in the active list, removes it and recomputes enemies. Result keys: `unregistered, active_changed, active, enemies_by_team, teams_state`.

SSOT delta: **16 symbols / 4 schemas / 2 contracts / 2 slices**. Totals now: **10712 symbols / 1530 slices / 1418 contracts / 2627 schemas**. Content 425 blocks; manifest 100 direct modules; expanded validation 113 modules. The audit report was regenerated after the GDScript existed (the N2035 lesson); `totalSourceFunctions` stays 1335 — the audit's discovery only scans PortGame/PortBridge facade functions, so State `source_` functions are not counted there (validated by the catalog validator instead). No `source_modules` shard changed: there is no module whose java_source selection matches `game/Teams.java`, following the geometry-owner precedent.

## Why it exists

The backlog C01 "Còn thiếu" lists complete removal/overlap/events, and the earlier note flagged that the real core unregister is `Teams.unregisterCore` (Teams.java:158) — not a turret unregister (which does not exist in Turret.java). The runtime had only a caller-supplied register-core hook (N2038); there was no actual Teams core registry. Now placement/removal have a source-backed registry to operate on.

## What the Godot proof shows

`TeamsCoreRegistrationProof` — 9/9 checks true on the real Main scene: registering a core activates its team and recomputes enemies; a duplicate registration is a no-op; unregistering the last core deactivates the team; a missing unregister is a no-op; the wave team stays active even with no cores; neoplastic is active through its units alone.

## Verification

- Full Python suite: **5441 tests OK in 1169.666s** (log `~/workspace/logs/full-suite-n2074.log`). Editor parse, deterministic replay and native MCP proof are still open for these slices.

## Files changed

- `godot-mindustry/src/game/SourceTeamsRuntimeState.gd` (N2074–N2075)
- `godot-mindustry/src/generated/source_api_contracts.json`
- `godot-mindustry/src/generated/source_slice_ledger.json`
- `godot-mindustry/src/generated/source_state_schema.json`
- `godot-mindustry/src/generated/source_symbol_registry.json`
- `godot-mindustry/tools/runtime_proofs/TeamsCoreRegistrationProof.gd`
- `godot-mindustry/tools/runtime_proofs/TeamsCoreRegistrationProof.tscn`
- `tools/mindustry_godot_transpiler/register_teams_core_registration_binding.py`
- `tools/mindustry_godot_transpiler/tests/test_teams_core_registration_binding.py`
- `docs/superpowers/specs/2026-06-23-mindustry-godot-gdscript-transpiler-design.md` (totals 1528 → 1530, N2074–N2075 checklist/table/log rows)
- `docs/superpowers/reports/2026-11-07-teams-core-registration-binding.md` (this report)
- `docs/superpowers/handoffs/2026-11-07-teams-core-registration-binding-handoff.md` (this handoff)

## Open items

- Entity group membership, controller pickup/world transitions and the remaining Tile/Floor side effects stay open in C01. The queue-to-sprite sync stays open in C02. C03–C12 remain open. Editor parse, deterministic replay and native MCP proof are still open for these slices.
