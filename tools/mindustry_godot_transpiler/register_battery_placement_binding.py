"""Register battery placement binding (N2079).

N2079 places a battery in the bootstrap world, so the live power
graph has a battery: the solar panel's surplus (0.12 produced, 0
needed) charges it each frame (PowerGraph.java chargeBatteries), and
the live update returns the charged amount. The battery sits at
(23, 7), east of the solar panel, on a free size-1 cell. A real power
consumer (e.g. a lancer turret) is the follow-up that makes the
0/partial/full coverage and the discharge path testable.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/BatteryPlacementProof'
TESTS = ['test_battery_placement_binding_registration', 'test_all_battery_placement_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_battery_placement']
DEFERRED = [
    'Adding a real power consumer (e.g. a lancer turret) to the bootstrap world so the 0/partial/full coverage and the battery discharge path are testable; the C03 gate needs those.',
    'C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEF = 'battery = new Battery("battery"){{'
BUF = 'consumePowerBuffered(4000f);'
REQ = 'requirements(Category.power, with(Items.copper, 5, Items.lead, 20));'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, BLOCKS, expr, rule, **extra)

    n2079_inputs = {
        'tile_size': f('int', DEF, 'The world units per tile, for the placement world position.'),
    }
    n2079_outputs = {
        'block_id': f('String', DEF, 'The placed block id: battery.'),
        'role': f('String', DEF, 'The initial-build role: battery.'),
        'cell': f('Vector2i', DEF, 'The placement cell: (23, 7), east of the solar panel.'),
        'x': f('float', DEF, 'The placement world x.'),
        'y': f('float', DEF, 'The placement world y.'),
        'power_capacity': f('float', BUF, 'The battery power capacity: 4000.'),
    }

    entries = [
        ('N2079', 'SourceWorldInitialBuildRuntimeState.source_battery_placement_state', 'source_battery_placement_state', BLOCKS, 'mindustry.content.Blocks', 'battery', n2079_inputs, n2079_outputs, [DEF, BUF, REQ], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed battery placement in the initial build.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed battery placement; the battery is placed at (23, 7) with powerCapacity 4000.'))
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
