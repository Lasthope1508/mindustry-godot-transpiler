"""Register conveyor item draw-positions binding (N2076).

N2076 binds the Java conveyor draw formula (Conveyor.java draw): each
item in a belt queue is drawn at a world position computed from its
xs/ys queue coordinates, the belt's center, rotation and tilesize.
This is the source-backed core of the C02 queue-to-sprite sync: it
converts a queue (which has item identity) into the world positions
the visual sprites must occupy. The live-loop wiring that drives the
sprites from these positions is still open.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONVEYOR = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/ConveyorDrawPositionsProof'
TESTS = ['test_conveyor_draw_positions_binding_registration', 'test_all_conveyor_draw_positions_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_draw_positions']
DEFERRED = [
    'The live-loop wiring that drives the visual item sprites from these queue-derived positions is still open in C02 (the transport keeps a fixed sprite count spaced by phase; syncing it to the queues is a design decision).',
    'C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

V1 = 'Tmp.v1.trns(rotation * 90, tilesize, 0);'
V2 = 'Tmp.v2.trns(rotation * 90, -tilesize / 2f, xs[i] * tilesize / 2f);'
IX = 'ix = (x + Tmp.v1.x * ys[i] + Tmp.v2.x),'
IY = 'iy = (y + Tmp.v1.y * ys[i] + Tmp.v2.y);'
DRAW = 'Draw.rect(item.fullIcon, ix, iy, itemSize, itemSize);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, **extra):
        return backed(typ, CONVEYOR, expr, rule, **extra)

    n2076_inputs = {
        'queue': f('Dictionary', DRAW, 'The belt queue: ids, xs, ys and len.'),
        'center': f('Vector2', IX, 'The belt building world center.'),
        'rotation': f('int', V1, 'The belt rotation (0 east, 1 north, 2 west, 3 south).'),
        'tilesize': f('float', V1, 'The world units per tile (Vars.tilesize = 8).'),
    }
    n2076_outputs = {
        'positions': f('Array', DRAW, 'One {item_id, x, y} per queue item, in queue order.'),
        'count': f('int', DRAW, 'How many queue items were positioned.'),
    }

    entries = [
        ('N2076', 'SourceConveyorRuntimeState.source_conveyor_item_draw_positions_state', 'source_conveyor_item_draw_positions_state', CONVEYOR, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'draw', n2076_inputs, n2076_outputs, [V1, V2, IX, IY, DRAW], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed conveyor item draw positions.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed conveyor draw; each queue item is positioned from its xs/ys, the belt center, rotation and tilesize.'))
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
