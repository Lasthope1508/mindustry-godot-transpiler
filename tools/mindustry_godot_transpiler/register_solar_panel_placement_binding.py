"""Register solar panel placement binding (N2078).

N2078 places a solar panel in the bootstrap world, so the live power
graph has a producer: the placed graph gains one producer with
powerProduction 0.12 (Blocks.java) and the live update returns real
produced power. The panel sits at (21, 7), east of the duo, on a free
size-1 cell. A battery and a power consumer are the follow-up that
makes the power flow (charge/discharge, 0/partial/full) testable.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/SolarPanelPlacementProof'
TESTS = ['test_solar_panel_placement_binding_registration', 'test_all_solar_panel_placement_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_solar_panel_placement']
DEFERRED = [
    'Adding a battery and a power consumer to the bootstrap world so the power flow (charge/discharge, 0/partial/full, multiple consumers) is testable; the C03 gate needs those.',
    'C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEF = 'solarPanel = new SolarGenerator("solar-panel"){{'
PROD = 'powerProduction = 0.12f;'
REQ = 'requirements(Category.power, with(Items.lead, 10, Items.silicon, 8));'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, BLOCKS, expr, rule, **extra)

    n2078_inputs = {
        'tile_size': f('int', DEF, 'The world units per tile, for the placement world position.'),
    }
    n2078_outputs = {
        'block_id': f('String', DEF, 'The placed block id: solar-panel.'),
        'role': f('String', DEF, 'The initial-build role: solar-panel.'),
        'cell': f('Vector2i', DEF, 'The placement cell: (21, 7), east of the duo.'),
        'x': f('float', DEF, 'The placement world x.'),
        'y': f('float', DEF, 'The placement world y.'),
        'power_production': f('float', PROD, 'The panel power production: 0.12 per tick at full efficiency.'),
    }

    entries = [
        ('N2078', 'SourceWorldInitialBuildRuntimeState.source_solar_panel_placement_state', 'source_solar_panel_placement_state', BLOCKS, 'mindustry.content.Blocks', 'solarPanel', n2078_inputs, n2078_outputs, [DEF, PROD, REQ], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed solar panel placement in the initial build.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed solar panel placement; the panel is placed at (21, 7) with powerProduction 0.12.'))
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
