"""Register the live per-type unit counts -- TeamData.updateCount +
updateTeamStats rebuild (N2141).

The first deferred follow-up from N2140 and the next C07 item per
the completion backlog (unit lifecycle/teams). N2140's canCreate
helper reads `frame["team_unit_counts"]` (default 0 for a missing
unit, exactly `TeamData.countType`, Teams.java:442-444) but no frame
records it yet -- the tick driver comment says "the frame still
records no per-type unit counts, so the count reads 0 until the
unit-group slice lands." N2141 is that slice: the pure
`TeamData.updateCount` primitive plus a pure `updateTeamStats`
rebuild for one team, and the driver stamps the rebuilt
`frame["team_unit_counts"]` before the assembler can_create call.

Composition, not re-implementation: `countType` already has a
port-bridge pure function (`PortGame.source_unit_count_state`,
`SourceUnitUpdatePortBridge.gd:105-111`, registered symbols
`unit_count.*`); the N2140 helper already reads the name-keyed
frame map. N2141 supplies the missing live counts behind that
map -- it does not duplicate the cap formula, the count lookup,
or the canCreate predicate.
"""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TEAMS = 'core/src/mindustry/game/Teams.java'
UNITCOMP = 'core/src/mindustry/entities/comp/UnitComp.java'
PAYLOADCOMP = 'core/src/mindustry/entities/comp/PayloadComp.java'
PROOF = '/root/C07UnitGroupCountsProof'
OWNER_COUNT = 'SourceTeamsRuntimeState.source_team_data_update_count_state'
OWNER_STATS = 'SourceTeamsRuntimeState.source_team_data_update_team_stats_state'
TESTS = ['test_c07_unit_group_counts_registration', 'test_all_c07_unit_group_counts_input_evidence_is_exact', 'test_team_data_update_count_state', 'test_reference_graph_and_actual_c07_unit_group_counts']
DEFERRED = [
    'Live UnitComp.add() / remove() lifecycle hooks (UnitComp.java:591-598, 603-604, 752: cap-death and env-death updateCount(type, -1) calls) -- no live unit lifecycle in the port yet; the pure updateCount primitive is the state they will call, lifecycle wiring waits for a unit-lifecycle slice.',
    'PayloadComp add/remove count hooks (PayloadComp.java:101, 200) -- same, payload lifecycle not ported yet.',
    'Teams.updateTeamStats full multi-team rebuild (present/bosses/players/unitsByType/unitTree, Teams.java:182-245) -- N2141 rebuilds one team\'s counts only; presence/boss/player/tree state stays deferred.',
    'Units.notifyUnitSpawn / spawn path, Call.unitCapDeath / Call.unitEnvDeath net calls -- presentation/net, not state.',
    'power.status live read -- the driver folds frame["power_status"] (null -> 1.0) until a power-status slice lands.',
    'C07-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'public @Nullable int[] typeCounts;',
    'public void updateCount(UnitType type, int amount){',
    'if(type == null) return;',
    'unitCount = Math.max(amount + unitCount, 0);',
    'if(typeCounts == null || typeCounts.length <= type.id){',
    'typeCounts = typeCounts == null ? new int[Vars.content.units().size] : Arrays.copyOf(typeCounts, Vars.content.units().size);',
    'typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);',
    'public int countType(UnitType type){',
    'return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];',
    'public void updateTeamStats(){',
    'data.unitCount = 0;',
    'if(data.typeCounts != null){',
    'Arrays.fill(data.typeCounts, 0);',
    'for(Unit unit : Groups.unit){',
    'data.units.add(unit);',
    'private void count(Unit unit){',
    'unit.team.data().updateCount(unit.type, 1);',
    'count(payload.unit);',
    'team.data().updateCount(type, 1);',
    'team.data().updateCount(type, -1);',
    'if(unit.isAdded()) unit.team.data().updateCount(unit.type, 1);',
    'if(!u.isAdded()) u.team.data().updateCount(u.type, -1);',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=TEAMS, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2141_update_count_inputs = {
        'type_counts': f('Array', 'public @Nullable int[] typeCounts;', 'TeamData.typeCounts (Teams.java:302); the live per-type counts array, null/empty until the first updateCount grows it.'),
        'type_id': f('int', 'typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);', 'UnitType.id (Teams.java:435); the catalog exposes name-string ids only, so the caller passes the integer type id; type_id < 0 maps to type == null (Teams.java:430) and skips.'),
        'amount': f('int', 'public void updateCount(UnitType type, int amount){', 'The amount to add (Teams.java:429): +1 on add/spawn, -1 on remove/death.'),
        'unit_count': f('int', 'unitCount = Math.max(amount + unitCount, 0);', 'TeamData.unitCount (Teams.java:431) before this update; clamped at 0.'),
        'content_unit_size': f('int', 'typeCounts = typeCounts == null ? new int[Vars.content.units().size] : Arrays.copyOf(typeCounts, Vars.content.units().size);', 'Vars.content.units().size (Teams.java:433); the catalog exposes name-string ids only, so the caller passes the size (frame content_unit_size, proof passes it directly).'),
    }
    n2141_update_count_outputs = {
        'type_counts': f('Array', 'typeCounts[type.id] = Math.max(amount + typeCounts[type.id], 0);', 'The updated TeamData.typeCounts (Teams.java:435): grown to the content unit count when null/short, the type slot clamped at 0.'),
        'unit_count': f('int', 'unitCount = Math.max(amount + unitCount, 0);', 'The updated TeamData.unitCount (Teams.java:431): amount added, clamped at 0.'),
        'count_type': f('int', 'return typeCounts == null || typeCounts.length <= type.id ? 0 : typeCounts[type.id];', 'The updated per-type count read back through TeamData.countType (Teams.java:442-444).'),
    }

    n2141_update_team_stats_inputs = {
        'units': f('Array', 'for(Unit unit : Groups.unit){', 'Groups.unit (Teams.java:213); unit records {"team_id": int, "type_id": int, "type_name": String, "payload_units": [...]} -- no frame carries a live units list yet, so the driver reads frame.get("units", []) and the counts stay 0 until a unit-list slice lands.'),
        'team_id': f('int', 'TeamData data = unit.team.data();', 'The team whose TeamData is rebuilt (Teams.java:215); only units of this team are counted, the single-team restriction of the frame view.'),
        'content_unit_size': f('int', 'typeCounts = typeCounts == null ? new int[Vars.content.units().size] : Arrays.copyOf(typeCounts, Vars.content.units().size);', 'Vars.content.units().size (Teams.java:433); the catalog exposes name-string ids only, so the caller passes the size (frame content_unit_size, proof passes it directly).'),
    }
    n2141_update_team_stats_outputs = {
        'team_unit_counts': f('Dictionary', 'count(unit);', 'The rebuilt name-keyed per-type counts (Teams.java:213-230): every live unit of the team counted via count(unit), payload units recursed into exactly as Teams.count (Teams.java:168-179); the map the N2140 can_create helper reads.'),
        'unit_count': f('int', 'data.unitCount = 0;', 'The rebuilt TeamData.unitCount (Teams.java:187, reset then recount): the number of live units of the team, payload units included.'),
    }

    entries = [
        ('N2141', OWNER_COUNT, 'source_team_data_update_count_state', TEAMS, 'mindustry.game.Teams', 'TeamData.updateCount(UnitType, int)', n2141_update_count_inputs, n2141_update_count_outputs, True, 'Dictionary'),
        ('N2141', OWNER_STATS, 'source_team_data_update_team_stats_state', TEAMS, 'mindustry.game.Teams', 'Teams.updateTeamStats()', n2141_update_team_stats_inputs, n2141_update_team_stats_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                if suffix == 'result':
                    symbol = name + '.' + field
                    names.append(symbol)
                    symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed TeamData.updateCount / Teams.updateTeamStats state from Teams.java.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed TeamData.updateCount / Teams.updateTeamStats state from Teams.java.'))
        all_names.extend(names)

    by_slice = {}
    # The test pins this order: the three updateCount results, then
    # the two updateTeamStats results.
    by_slice['N2141'] = [
        'source_team_data_update_count_state_result.type_counts',
        'source_team_data_update_count_state_result.unit_count',
        'source_team_data_update_count_state_result.count_type',
        'source_team_data_update_team_stats_state_result.team_unit_counts',
        'source_team_data_update_team_stats_state_result.unit_count',
    ]
    source_symbols.upsert_source_slice(GODOT, 'N2141', dict(status='done', java_source=TEAMS, java_class='mindustry.game.Teams', java_method='TeamData.updateCount(UnitType, int)', godot_owner=OWNER_COUNT, exact_exprs=EXACT_EXPRS, source_symbols=by_slice['N2141'], tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
