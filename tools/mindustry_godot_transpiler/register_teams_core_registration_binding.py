"""Register Teams core registration binding (N2074-N2075).

N2074-N2075 bind Teams.registerCore / unregisterCore (Teams.java),
the C01 complete-removal piece: a core's placement registers it in
the team's core list (and activates the team), and a core's removal
unregisters it (and deactivates the team when it has nothing left).
The active() check and updateEnemies() recompute (each active team's
coreEnemies are the other active teams) are part of both slices.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
PROOF = '/root/TeamsCoreRegistrationProof'
TESTS = ['test_teams_core_registration_binding_registration', 'test_all_teams_core_registration_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_teams_core_registration']
DEFERRED = [
    'Entity group membership, controller pickup/world transitions and the remaining Tile/Floor side effects stay open in C01 (they need the entity groups, unit system and campaign state machine the runtime does not own yet).',
    'C02 queue-to-sprite sync and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

REGISTER_DATA = 'TeamData data = get(core.team);'
REGISTER_CONTAINS = 'if(!data.cores.contains(core)){'
REGISTER_ADD = 'data.cores.add(core);'
REGISTER_ACTIVE = 'if(data.active() && !active.contains(data)){'
REGISTER_ACTIVE_ADD = 'active.add(data);'
UNREGISTER_DATA = 'TeamData data = get(entity.team);'
UNREGISTER_REMOVE = 'data.cores.remove(entity);'
UNREGISTER_ACTIVE = 'if(!data.active()){'
UNREGISTER_ACTIVE_REMOVE = 'active.remove(data);'
UPDATE_ENEMIES = 'updateEnemies();'
ACTIVE_BODY = 'return (team == state.rules.waveTeam && state.rules.waves) || cores.size > 0 || buildings.size > 0 || (team == Team.neoplastic && units.size > 0);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, TEAMS, expr, rule, **extra)

    n2074_inputs = {
        'teams_state': f('Dictionary', REGISTER_DATA, 'The teams state: teams keyed by team id, the active list, and the wave rules.'),
        'team_id': f('int', REGISTER_DATA, 'The team id of the core being registered.'),
        'core_ref': f('Variant', REGISTER_ADD, 'The core reference being registered.'),
    }
    n2074_outputs = {
        'registered': f('bool', REGISTER_CONTAINS, 'Whether the core was added (false when it was already present).'),
        'active_changed': f('bool', REGISTER_ACTIVE, 'Whether the team was added to the active list.'),
        'active': f('Array', REGISTER_ACTIVE_ADD, 'The active team ids after registration.'),
        'enemies_by_team': f('Dictionary', UPDATE_ENEMIES, 'Each active team id mapped to the other active team ids.'),
        'teams_state': f('Dictionary', REGISTER_DATA, 'The teams state after registration.'),
    }
    n2075_inputs = {
        'teams_state': f('Dictionary', UNREGISTER_DATA, 'The teams state: teams keyed by team id, the active list, and the wave rules.'),
        'team_id': f('int', UNREGISTER_DATA, 'The team id of the core being unregistered.'),
        'core_ref': f('Variant', UNREGISTER_REMOVE, 'The core reference being unregistered.'),
    }
    n2075_outputs = {
        'unregistered': f('bool', UNREGISTER_REMOVE, 'Whether the core was removed (false when it was not present).'),
        'active_changed': f('bool', UNREGISTER_ACTIVE, 'Whether the team was removed from the active list.'),
        'active': f('Array', UNREGISTER_ACTIVE_REMOVE, 'The active team ids after unregistration.'),
        'enemies_by_team': f('Dictionary', UPDATE_ENEMIES, 'Each active team id mapped to the other active team ids.'),
        'teams_state': f('Dictionary', UNREGISTER_DATA, 'The teams state after unregistration.'),
    }

    entries = [
        ('N2074', 'SourceTeamsRuntimeState.source_teams_register_core_state', 'source_teams_register_core_state', TEAMS, 'mindustry.game.Teams', 'registerCore', n2074_inputs, n2074_outputs, [REGISTER_DATA, REGISTER_CONTAINS, REGISTER_ADD, REGISTER_ACTIVE, REGISTER_ACTIVE_ADD, UPDATE_ENEMIES, ACTIVE_BODY], True, 'Dictionary'),
        ('N2075', 'SourceTeamsRuntimeState.source_teams_unregister_core_state', 'source_teams_unregister_core_state', TEAMS, 'mindustry.game.Teams', 'unregisterCore', n2075_inputs, n2075_outputs, [UNREGISTER_DATA, UNREGISTER_REMOVE, UNREGISTER_ACTIVE, UNREGISTER_ACTIVE_REMOVE, UPDATE_ENEMIES, ACTIVE_BODY], True, 'Dictionary'),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Teams core registration.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Teams core registration; a core placement registers it in the team core list and activates the team, a removal unregisters it and deactivates the team when it has nothing left.'))
        by_slice[sid] = names
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class=cls, java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in entries}
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
    main()
