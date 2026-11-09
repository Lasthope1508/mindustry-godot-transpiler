"""Register the power-graph consumer live cheating value (N2107).

N2099 wired the drill tick to refresh its frame's cheating flag from
the live rules (TeamComp.cheating(): team.rules().cheat) and N2106 did
the same for the ContinuousLiquidTurret tick, but the power graph never
saw that value: its consumer dicts are rebuilt from the catalog every
frame (SourcePlacedPowerGraphState._group_state) and carry no cheating
key, so PowerGraph.update()'s cheat gate (PowerGraph.java:217-224) —
if the first consumer cheats, set every consumer's power.status to 1,
lastPowerNeeded = lastPowerProduced = 1, return — could never fire live
even for a cheating drill, and SourcePowerGraphState.update_state
computed the cheat state without honouring it. N2107 stamps each
grouped consumer with its building's live cheating value (read live
from the placed building's team and the game rules, the same live-rules
read the drill/CLT ticks use) and makes update_state take the cheat
branch when the first consumer cheats.

Java: PowerGraph.update() (PowerGraph.java:217-224):
    if(!consumers.isEmpty() && consumers.first().cheating()){
        //when cheating, just set status to 1
        for(Building tile : consumers){
            tile.power.status = 1f;
        }
        lastPowerNeeded = lastPowerProduced = 1f;
        return;
    }
TeamComp.cheating() (TeamComp.java:17-19) returns team.rules().cheat;
Team.rules() (Team.java:88-90) returns state.rules.teams.get(this);
TeamRules.get (Rules.java:391-394) creates a fresh TeamRule when the
team has none, and TeamRule.cheat (Rules.java:328, "If true, blocks
don't require power or resources.") defaults to false. While a team
cheats, its buildings' consumers are skipped and everything counts as
valid (BuildingComp.java:1944-1945).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
TEAM_COMP = 'core/src/mindustry/entities/comp/TeamComp.java'
TEAM = 'core/src/mindustry/game/Team.java'
RULES = 'core/src/mindustry/game/Rules.java'
BUILDING_COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
HELPER_OWNER = 'SourcePlacedPowerGraphState.source_consumer_cheating_for_cell_state'
DRIVER_OWNER = 'SourceFactoryRuntimeState.source_factory_update_power_graph_state'
PROOF = '/root/PowerGraphLiveUpdateProof'
TESTS = ['test_power_graph_consumer_cheating_binding_registration', 'test_all_power_graph_consumer_cheating_input_evidence_is_exact', 'test_live_loop_stamps_consumers_with_live_cheating', 'test_reference_graph_and_actual_power_graph_consumer_cheating']
DEFERRED = [
    'Wiring the turret and factory families\' own ticks to the live cheating value is a later slice; their ticks do not exist in the live loop yet, so only the power-graph consumer path reads the value live here.',
    'C06-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EXACT_EXPRS = [
    'if(!consumers.isEmpty() && consumers.first().cheating()){',
    '//when cheating, just set status to 1',
    'for(Building tile : consumers){',
    'tile.power.status = 1f;',
    'lastPowerNeeded = lastPowerProduced = 1f;',
    '        return team.rules().cheat;',
    '        return state.rules.teams.get(this);',
    '        public boolean cheat;',
    '            return out == null ? (values[team.id] = new TeamRule(team)) : out;',
    '        //everything is valid when cheating',
    '        if(!block.hasConsumers || cheating()){',
]


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=POWER_GRAPH, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2107_inputs = {
        'game': f('Object', 'public void update(){', 'The game whose placed buildings form the power graph (PowerGraph.update runs over its consumers).'),
        'cell': f('Vector2i', 'if(!consumers.isEmpty() && consumers.first().cheating()){', 'The origin cell of the placed building whose live team cheating the consumer dict carries (PowerGraph.add puts each placed building in the graph once).'),
    }
    n2107_outputs = {
        'cheating': f('bool', '        return team.rules().cheat;', 'Whether the building\'s team cheats: its TeamRule cheat flag (false by default).', source=TEAM_COMP),
        'team_id': f('int', '        return state.rules.teams.get(this);', 'The placed building\'s team id, read off the sprite (derelict 0 when the sprite carries none).', source=TEAM),
        'found': f('bool', 'public void add(Building build){', 'Whether a placed building (a graph member) was found at the cell.'),
        'reason': f('String', 'public void update(){', 'Why the lookup resolved the way it did (no_sprite when the cell holds no building, live_rules otherwise).'),
    }

    entries = [
        ('N2107', HELPER_OWNER, 'source_consumer_cheating_for_cell_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'update', n2107_inputs, n2107_outputs, True, 'Dictionary'),
    ]
    all_names = []
    for sid, owner, prefix, source, cls, method, inputs, outputs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs), ('result', outputs)]:
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed power-graph consumer live cheating value.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed power-graph consumer live cheating value; the helper reads a placed building\'s live TeamRule cheat flag from its team and the game rules, so the grouped consumer dict carries what PowerGraph.update()\'s cheat gate reads.'))
        all_names.extend(names)

    # The live-loop driver (N2077) gains the cheating stamp: deepcopy
    # the existing contract and extend its rule, keeping the N2077
    # source_slice and the same params/return keys (the signature does
    # not change — the stamp only fills the consumer dicts' cheating
    # key before the update runs).
    contracts = source_symbols.load_source_api_contracts(GODOT)['contracts']
    driver_contract = copy.deepcopy(contracts[DRIVER_OWNER])
    driver_contract['tests'] = sorted(set(driver_contract['tests']) | set(TESTS))
    driver_contract['rule'] = 'Source-backed live-loop power graph update; each frame the placed graph runs PowerGraph.update(). Each grouped consumer dict is stamped with its building\'s live cheating value (TeamComp.cheating() from the live rules) before the update runs, so the cheat gate fires when the first consumer\'s team cheats.'
    source_symbols.upsert_source_api_contract(GODOT, DRIVER_OWNER, driver_contract)

    by_slice['N2107'] = sorted(all_names)
    # One slice row: the live-loop driver is the primary owner; the
    # helper shares the slice (its symbols carry their own owner).
    source_symbols.upsert_source_slice(GODOT, 'N2107', dict(status='done', java_source=POWER_GRAPH, java_class='mindustry.world.blocks.power.PowerGraph', java_method='update', godot_owner=DRIVER_OWNER, exact_exprs=EXACT_EXPRS, source_symbols=sorted(all_names), tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))

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
