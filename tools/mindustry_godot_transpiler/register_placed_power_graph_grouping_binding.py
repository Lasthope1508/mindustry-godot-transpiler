"""Register per-building power graph grouping (N2081).

N2081 fixes the placed power graph to group each building once, as
Java does: PowerGraph.add(Building) adds a building once to `all`
and to exactly one role list, guarded by `build.power.graph !=
this || !build.power.init`. The GDScript _group_state iterated every
key of placed_block_origins, and that map holds one key per
footprint cell, so a size-2 building was grouped 4 times (its usage
counted 4x: the lancer needed 0.4 instead of 0.1, coverage 0.005
instead of 0.02). The new source_group_buildings_by_origin_state
returns the unique origins (one per building); _group_state groups
over those, so the graph now has 11 consumers / 1 producer / 1
battery, needs 0.1, produces 0.002, coverage 0.02. The four earlier
power proofs are updated to the grouped counts (the stale-pin
pattern).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
POWER_GRAPH = 'core/src/mindustry/world/blocks/power/PowerGraph.java'
PROOF = '/root/PlacedPowerGraphGroupingProof'
TESTS = ['test_placed_power_graph_grouping_binding_registration', 'test_all_placed_power_graph_grouping_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_placed_power_graph_grouping']
DEFERRED = [
    'The battery discharge path (a charged battery covering a deficit) and the full-power case (coverage 1.0); the C03 gate needs those.',
    'C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

ADD = 'public void add(Building build){'
GUARD = 'if(build.power.graph != this || !build.power.init){'
ALL = 'all.add(build);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, POWER_GRAPH, expr, rule, **extra)

    n2081_inputs = {
        'placed_block_origins': f('Dictionary', ADD, 'The placed-block origins map: every footprint cell keyed to its origin cell.'),
    }
    n2081_outputs = {
        'origins': f('Array', ALL, 'The unique building origins, one per building.'),
        'count': f('int', GUARD, 'The number of buildings: one per unique origin.'),
    }

    entries = [
        ('N2081', 'SourcePlacedPowerGraphState.source_group_buildings_by_origin_state', 'source_group_buildings_by_origin_state', POWER_GRAPH, 'mindustry.world.blocks.power.PowerGraph', 'add', n2081_inputs, n2081_outputs, [ADD, GUARD, ALL], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed per-building grouping of the placed power graph.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed per-building grouping; each building is grouped once, as PowerGraph.add adds each building once.'))
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
