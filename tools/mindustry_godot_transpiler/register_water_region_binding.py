"""Register bootstrap water region (N2084).

N2084 adds a water region to the bootstrap world, so a pump has
water to pump (C04 gate: pump -> conduit -> Drill uses water).
The shallow-water floor's liquidDrop is water (Blocks.java:224-234:
water = new Floor("shallow-water"), liquidDrop = Liquids.water,
isLiquid = true). The region is (5,14)-(8,17), south of the drill,
free of buildings and ore. source_game_world_tiles_state applies it
through the new source_water_region_state (the wiring is folded into
this slice, the N2068 lesson).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/WaterRegionProof'
TESTS = ['test_water_region_binding_registration', 'test_all_water_region_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_water_region']
DEFERRED = [
    'The pump placement on the water (mechanical-pump, pumpAmount 7/60), the conduit line to the drill, and the live-loop liquid flow (C04 gate).',
    'C05-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEF = 'water = new Floor("shallow-water"){{'
DROP = 'liquidDrop = Liquids.water;'
LIQUID = 'isLiquid = true;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, BLOCKS, expr, rule, **extra)

    n2084_inputs = {
        'world_tiles': f('Dictionary', DEF, 'The world tile store to apply the water region to.'),
        'water_block': f('Object', DROP, 'The shallow-water floor block (liquidDrop water).'),
    }
    n2084_outputs = {
        'cells': f('Array', LIQUID, 'The water region cells.'),
        'count': f('int', DROP, 'The number of tiles set to the water floor.'),
        'reason': f('String', DEF, 'Why the region was applied.'),
    }

    entries = [
        ('N2084', 'SourceWorldTerrainRuntimeState.source_water_region_state', 'source_water_region_state', BLOCKS, 'mindustry.content.Blocks', 'water', n2084_inputs, n2084_outputs, [DEF, DROP, LIQUID], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed water region in the bootstrap world.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed water region; the shallow-water floor drops water for a pump.'))
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
