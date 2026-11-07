"""Register lancer turret placement binding (N2080).

N2080 places a lancer turret in the bootstrap world, so the live
power graph has a real power consumer: the lancer consumes 6.0 power
(Blocks.java consumePower(6f)), so the graph needs 6.0/60 per frame
against the panel's 0.12/60 produced — coverage 0.02, the partial-
power case the C03 gate needs, and the battery stops charging (a
deficit, not a surplus). The lancer is a PowerTurret, size 2, at
(25, 7), east of the battery, on free cells. It registers as a
turret cell (Block.is_turret includes PowerTurret), but the turret
sim iterates it with the duo's stats and finds no enemy target in
the bootstrap world, so it idles. The discharge path (a charged
battery covering a deficit) is still open: the battery starts empty.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BLOCKS = 'core/src/mindustry/content/Blocks.java'
PROOF = '/root/LancerPlacementProof'
TESTS = ['test_lancer_placement_binding_registration', 'test_all_lancer_placement_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_lancer_placement']
DEFERRED = [
    'The battery discharge path (a charged battery covering a deficit) and the full-power case (coverage 1.0); the C03 gate needs those.',
    'C04-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DEF = 'lancer = new PowerTurret("lancer"){{'
POWER = 'consumePower(6f);'
REQ = 'requirements(Category.turret, with(Items.copper, 60, Items.lead, 70, Items.silicon, 60, Items.titanium, 30));'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, BLOCKS, expr, rule, **extra)

    n2080_inputs = {
        'tile_size': f('int', DEF, 'The world units per tile, for the placement world position.'),
    }
    n2080_outputs = {
        'block_id': f('String', DEF, 'The placed block id: lancer.'),
        'role': f('String', DEF, 'The initial-build role: lancer.'),
        'cell': f('Vector2i', DEF, 'The placement cell: (25, 7), east of the battery.'),
        'x': f('float', DEF, 'The placement world x.'),
        'y': f('float', DEF, 'The placement world y.'),
        'power_usage': f('float', POWER, 'The lancer power usage: 6.0.'),
    }

    entries = [
        ('N2080', 'SourceWorldInitialBuildRuntimeState.source_lancer_placement_state', 'source_lancer_placement_state', BLOCKS, 'mindustry.content.Blocks', 'lancer', n2080_inputs, n2080_outputs, [DEF, POWER, REQ], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed lancer placement in the initial build.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed lancer placement; the lancer is placed at (25, 7) with powerUsage 6.0.'))
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
