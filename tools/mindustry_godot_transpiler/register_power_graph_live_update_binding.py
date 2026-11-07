"""Register live-loop power graph update binding (N2077).

N2077 wires the power graph update into the live loop: each frame
simulate_factory runs the placed power graph's update (PowerGraph.java
update()), so the graph's balance and consumer statuses are actually
recomputed instead of the bound update sitting unused. The bootstrap
world has no power producer or consumer, so the graph is empty and the
update is a no-op there; adding a producer is the follow-up that makes
the graph non-empty.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWERGRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/PowerGraphLiveUpdateProof'
TESTS = ['test_power_graph_live_update_binding_registration', 'test_all_power_graph_live_update_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_power_graph_live_update']
DEFERRED = [
    'Adding a power producer (and a power consumer) to the bootstrap world so the live power graph is non-empty; the C03 gate needs power 0/partial/full, battery charge/discharge and multiple consumers.',
    'C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

UPDATE = 'public void update(){'
NEEDED = 'float powerNeeded = getPowerNeeded();'
PRODUCED = 'float powerProduced = getPowerProduced();'
NONEMPTY = 'if(!(consumers.size == 0 && producers.size == 0 && batteries.size == 0)){'
DISTRIBUTE = 'distributePower(powerNeeded, powerProduced, charged);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, POWERGRAPH, expr, rule, **extra)

    n2077_inputs = {
        'game': f('Object', UPDATE, 'The game, whose placed blocks form the power graph.'),
        'delta': f('float', NEEDED, 'The frame delta (source_delta).'),
    }
    n2077_outputs = {
        'power_needed': f('float', NEEDED, 'The graph power needed this frame.'),
        'power_produced': f('float', PRODUCED, 'The graph power produced this frame.'),
        'consumer_count': f('int', NONEMPTY, 'How many consumers are in the placed graph.'),
        'producer_count': f('int', NONEMPTY, 'How many producers are in the placed graph.'),
        'battery_count': f('int', NONEMPTY, 'How many batteries are in the placed graph.'),
        'update': f('Dictionary', DISTRIBUTE, 'The full PowerGraph.update() result for this frame.'),
    }

    entries = [
        ('N2077', 'SourceFactoryRuntimeState.source_factory_update_power_graph_state', 'source_factory_update_power_graph_state', POWERGRAPH, 'mindustry.world.blocks.power.PowerGraph', 'update', n2077_inputs, n2077_outputs, [UPDATE, NEEDED, PRODUCED, NONEMPTY, DISTRIBUTE], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed live-loop power graph update.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed live-loop power graph update; each frame the placed graph runs PowerGraph.update().'))
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
