"""Register mechanical pump placement binding (N2085).

N2085 places a mechanical pump in the bootstrap world, on the
water region from N2084, so the C04 gate has a water source: the
pump extracts water from the shallow-water floor (Blocks.java
mechanicalPump = new Pump("mechanical-pump"), pumpAmount = 7f/60f,
liquidCapacity = 20f). The pump is size 1 and floating, placed at
(5, 14) — the north-west corner of the water region (5,14)-(8,17) —
so its linked tiles include water tiles it can pump from. The
pump's proximity scan (onProximityUpdate: amount and liquidDrop)
and its live-loop update (updateTile: pumping into liquids, then
dumpLiquid) are still open; this slice is the placement only.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/MechanicalPumpPlacementProof'
TESTS = ['test_mechanical_pump_placement_binding_registration', 'test_all_mechanical_pump_placement_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_mechanical_pump_placement']
DEFERRED = [
    'The pump proximity scan (onProximityUpdate: amount and liquidDrop from the linked water tiles) and the live-loop pump update (updateTile: pumping into liquids, then dumpLiquid to the conduits).',
    'The conduit line from the pump to the drill and the live-loop liquid flow (the C04 gate).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEF = 'mechanicalPump = new Pump("mechanical-pump"){{'
PUMP_AMOUNT = 'pumpAmount = 7f / 60f;'
CAPACITY = 'liquidCapacity = 20f;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, BLOCKS, expr, rule, **extra)

    n2085_inputs = {
        'tile_size': f('int', DEF, 'The world units per tile, for the placement world position.'),
    }
    n2085_outputs = {
        'block_id': f('String', DEF, 'The placed block id: mechanical-pump.'),
        'role': f('String', DEF, 'The initial-build role: mechanical-pump.'),
        'cell': f('Vector2i', DEF, 'The placement cell: (5, 14), on the water region.'),
        'x': f('float', DEF, 'The placement world x.'),
        'y': f('float', DEF, 'The placement world y.'),
        'pump_amount': f('float', PUMP_AMOUNT, 'The pump amount per tile: 7/60.'),
        'liquid_capacity': f('float', CAPACITY, 'The pump liquid capacity: 20.'),
    }

    entries = [
        ('N2085', 'SourceWorldInitialBuildRuntimeState.source_mechanical_pump_placement_state', 'source_mechanical_pump_placement_state', BLOCKS, 'mindustry.content.Blocks', 'mechanicalPump', n2085_inputs, n2085_outputs, [DEF, PUMP_AMOUNT, CAPACITY], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed mechanical pump placement in the bootstrap world.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed mechanical pump placement; the pump extracts water from the shallow-water floor.'))
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
