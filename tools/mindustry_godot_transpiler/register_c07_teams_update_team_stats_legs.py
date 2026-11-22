"""Register the Teams.updateTeamStats() leftover legs (N2430).

Teams.updateTeamStats() (Teams.java:181-251): the 2 legs N2383
did not register --
`TeamData data = team.data();` (:186 + :244, the per-team
lookup, registered ONCE despite the two positions) and
`data.tree().insert(unit);` (:217, the unit-tree insert).
Everything else in the method is already owned at N2383
(28 exprs) or N2141 (header, unitCount, typeCounts fill,
Groups.unit loop header, units.add, count helper) and is NOT
re-registered here.

This slice extends the existing GD function
source_teams_update_team_stats_state (N2383): it adds no new
owner, no new contract and no new schema (the N2425
findEnemy-leg precedent; same shape as N2427). The lookup
reads each team's own dict from teams_state["teams"] and
creates a missing entry via `_teams_data`, exactly as Java
`team.data()` creates it (the reset had already run on it
in the first loop); the tree insert appends the unit to its
team's unit_tree {"inserted": [...]} list, created lazily
when the team had none (Teams.java:437-439) and cleared
first by the reset. The 4 result symbols are shared with
N2383 (the shared-symbol precedent).

NOT re-registered here: `TeamData data = unit.team.data();`
(:215, variable `unit.team`) is already owned at N2383 --
it is a different expr from `TeamData data = team.data();`
(:186/:244, variable `team`), which IS registered here.
`data.presentFlag = data.buildings.size > 0;` /
`data.units.add(unit);` /
`data.unitsByType[unit.type.id].add(unit);` / `count(unit);`
stay owned at N2383/N2141.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_update_team_stats import DEFERRED as N2383_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsUpdateTeamStatsLegsProof'
UPDATE_OWNER = 'SourceTeamsRuntimeState.source_teams_update_team_stats_state'
TESTS = ['test_c07_teams_update_team_stats_legs_registration', 'test_all_c07_teams_update_team_stats_legs_input_evidence_is_exact', 'test_teams_update_team_stats_legs_state', 'test_reference_graph_and_actual_c07_teams_update_team_stats_legs']
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'TeamData data = team.data();',
    'data.tree().insert(unit);',
]
SOURCE_SYMBOLS = [
    'source_teams_update_team_stats_state_result.teams_state',
    'source_teams_update_team_stats_state_result.present',
    'source_teams_update_team_stats_state_result.bosses',
    'source_teams_update_team_stats_state_result.unit_counts_by_team',
]

# DEFERRED is carried from the N2383 register script via import --
# never retyped. One entry is added: the N2430 Windows Godot
# proof debt (GOAL.md section 5).
DEFERRED = N2383_DEFERRED + [
    'Teams.updateTeamStats() leftover legs Windows Godot proof -- debt in GOAL.md section 5, same as N2383: the N2430 proof runs headless on Linux here and waits for a Windows Godot run.',
]


def verify():
    """Check every EXACT_EXPRS line appears verbatim in its
    upstream source, without touching any SSOT JSON. Exit 0
    when all are present."""
    upstream = {}
    for source in SLICE_SOURCES:
        upstream[source] = (ROOT / 'mindustry-upstream' / source).read_text(encoding='utf-8')
    missing = []
    for expr in EXACT_EXPRS:
        if not any(expr in text for text in upstream.values()):
            missing.append(expr)
    total = len(EXACT_EXPRS)
    if missing:
        for expr in missing:
            print('MISSING: %s' % expr)
        print('%d/%d exprs present' % (total - len(missing), total))
        return 1
    print('%d/%d exprs present' % (total, total))
    return 0


def main():
    source_symbols.upsert_source_slice(GODOT, 'N2430', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='Teams.updateTeamStats()', godot_owner=UPDATE_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {UPDATE_OWNER}
    for name, module in modules.items():
        if module.get('canonical_module') == 'api_contracts':
            selected = source_ssot.build_extension_shard(GODOT, name)[module['root_key']]
            if new_owners.intersection(selected):
                optional = module.setdefault('optional_mirror_fields', [])
                if 'return_type' not in optional:
                    optional.append('return_type')
    source_ssot.write_registered_json(GODOT, 'module_manifest', manifest)
    for canonical in ['slice_ledger', 'api_contracts', 'state_schema', 'registry', 'audit_report', 'module_manifest']:
        for name, module in modules.items():
            if module.get('canonical_module') == canonical:
                source_ssot.write_registered_json(GODOT, name, source_ssot.build_extension_shard(GODOT, name))


if __name__ == '__main__':
    if '--verify' in sys.argv:
        sys.exit(verify())
    main()
