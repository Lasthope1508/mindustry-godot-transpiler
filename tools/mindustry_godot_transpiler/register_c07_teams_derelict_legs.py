"""Register the TeamData destroyToDerelict/timeDestroy leftover legs (N2427).

TeamData.destroyToDerelict() (Teams.java:328-360) +
TeamData.timeDestroy() (Teams.java:362-394): the 8 legs N2395
did not register --
`for(var b : builds){` (:340),
`if(b instanceof CoreBuild){` (:343),
`b.kill();` (:344),
`u.kill();` (:356, in the `units.each(u -> Time.run(...))`
lambda),
`for(var build : builds){` (:368),
`scheduleDerelict(build);` (:370),
`if(any){` (:384), and
`if(result != null && !cores.contains(c -> c.within(t, range))){`
(:388).
Everything else in the two methods is already owned at N2395
(26 exprs) and is NOT re-registered here.

This slice extends the existing GD functions
source_team_data_destroy_to_derelict_state and
source_team_data_time_destroy_state (N2395): it adds no new
owner, no new contract and no new schema (the N2425
findEnemy-leg precedent). The two `for` loops are the
`for b in builds:` / `for build in builds:` loops the
functions already implement; the CoreBuild branch arrives as
the precomputed `is_core` flag and the core kill as the
kill_build Callable; the per-unit kill arrives as the
kill_unit Callable inside the recorded Time.run action (the
action re-checks the unit team when it runs, so a unit that
switched teams by then is spared); the timeDestroy loop
qualifies builds by the precomputed `within_range` /
`near_core` flags and the qualifying build goes through the
scheduleDerelict callee; the `if(any){` gate arrives as the
`any_replacement` flag (a replacement key present in
`present_keys`) and opens the Geometry.circle tile walk; the
result/non-core floor gate arrives as the tile record's
`near_core` flag plus the replacement lookup (null result
means no floor change). The 7 result symbols are shared with
N2395 (the shared-symbol precedent: building_cursor.* is
listed by several slices).

NOT re-registered here: `scheduleDerelict(b);` (:347,
variable `b`) is already owned at N2395 -- it is a
different expr from `scheduleDerelict(build);` (:370,
variable `build`), which IS registered here.
`plans.clear();` (:335) stays the exact_expr of N1143
(evidence only). `active()` (:447) stays N2074/N2075.
"""
import json
import sys
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_c07_teams_derelict import DEFERRED as N2395_DEFERRED

ROOT = Path(__file__).resolve().parents[2]
GODOT = ROOT / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/C07TeamsDerelictLegsProof'
DESTROY_OWNER = 'SourceTeamsRuntimeState.source_team_data_destroy_to_derelict_state'
TESTS = ['test_c07_teams_derelict_legs_registration', 'test_all_c07_teams_derelict_legs_input_evidence_is_exact', 'test_teams_derelict_legs_state', 'test_reference_graph_and_actual_c07_teams_derelict_legs']
SLICE_SOURCES = [
    'core/src/mindustry/game/Teams.java',
]
EXACT_EXPRS = [
    'for(var b : builds){',
    'if(b instanceof CoreBuild){',
    'b.kill();',
    'u.kill();',
    'for(var build : builds){',
    'scheduleDerelict(build);',
    'if(any){',
    'if(result != null && !cores.contains(c -> c.within(t, range))){',
]
SOURCE_SYMBOLS = [
    'source_team_data_destroy_to_derelict_state_result.builds',
    'source_team_data_destroy_to_derelict_state_result.killed_cores',
    'source_team_data_destroy_to_derelict_state_result.scheduled_unit_kills',
    'source_team_data_time_destroy_state_result.builds',
    'source_team_data_time_destroy_state_result.scheduled_kills',
    'source_team_data_time_destroy_state_result.any_replacement_present',
    'source_team_data_time_destroy_state_result.floor_changes',
]

# DEFERRED is carried from the N2395 register script via import --
# never retyped. One entry is added: the N2427 Windows Godot
# proof debt (GOAL.md section 5).
DEFERRED = N2395_DEFERRED + [
    'TeamData.destroyToDerelict()+timeDestroy() leftover legs Windows Godot proof -- debt in GOAL.md section 5, same as N2395: the N2427 proof runs headless on Linux here and waits for a Windows Godot run.',
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
    source_symbols.upsert_source_slice(GODOT, 'N2427', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='TeamData.destroyToDerelict()/TeamData.timeDestroy()', godot_owner=DESTROY_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=SOURCE_SYMBOLS, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {DESTROY_OWNER}
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
