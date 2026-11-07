"""Register conveyor queue storage binding (N2065-N2067).

N2065/N2066 read and write a conveyor's item queue on its sprite meta
(the drill-frame pattern); N2067 resolves the queues for a list of
cells, which is what the drill dump step takes as its queues_by_cell.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/ConveyorQueueStorageProof'
TESTS = ['test_conveyor_queue_storage_binding_registration', 'test_all_conveyor_queue_storage_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_queue_storage']
DEFERRED = [
    'The live loop still dumps straight to the core; swapping it to the dump step over stored queues stays open.',
    'The drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

IDS = 'public Item[] ids = new Item[capacity];'
XS_YS = 'public float[] xs = new float[capacity], ys = new float[capacity];'
LEN = 'public int len = 0;'
CAPACITY = 'private static final int capacity = 3;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2065_inputs = {
        'game': f('Object', IDS, 'Actual game world containing the conveyor buildings whose queues are stored on their sprites.'),
        'cell': f('Vector2i', LEN, 'Cell of the conveyor whose queue is read.'),
    }
    n2065_outputs = {
        'ids': f('Array', IDS, 'Item ids on the belt, in queue order.'),
        'xs': f('Array', XS_YS, 'X offsets of the items on the belt.'),
        'ys': f('Array', XS_YS, 'Y offsets of the items on the belt.'),
        'len': f('int', LEN, 'Number of items on the belt.'),
        'found': f('bool', IDS, 'Whether a conveyor sprite exists at the cell.'),
        'reason': f('String', IDS, 'Queue outcome: queue, no_queue, no_sprite.'),
    }
    n2066_inputs = {
        'game': f('Object', IDS, 'Actual game world containing the conveyor buildings whose queues are stored on their sprites.'),
        'cell': f('Vector2i', LEN, 'Cell of the conveyor whose queue is written.'),
        'queue': f('Dictionary', IDS, 'Queue to store: ids, xs, ys, len.'),
    }
    n2066_outputs = {
        'stored': f('bool', IDS, 'Whether the queue was stored on the conveyor sprite.'),
        'reason': f('String', IDS, 'Store outcome: stored, no_sprite.'),
    }
    n2067_inputs = {
        'game': f('Object', IDS, 'Actual game world containing the conveyor buildings whose queues are resolved.'),
        'cells': f('Array', IDS, 'Cells whose conveyor queues are resolved.'),
    }
    n2067_outputs = {
        'queues_by_cell': f('Dictionary', IDS, 'Conveyor queues keyed by cell, only for cells with a conveyor sprite.'),
        'found_count': f('int', LEN, 'Number of cells with a conveyor sprite.'),
        'reason': f('String', IDS, 'Resolve outcome: resolved, none_found.'),
    }

    entries = [
        ('N2065', 'SourceConveyorRuntimeState.source_conveyor_queue_for_cell_state', 'source_conveyor_queue_for_cell_state', CONV, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'ConveyorBuild', n2065_inputs, n2065_outputs, [IDS, XS_YS, LEN, CAPACITY]),
        ('N2066', 'SourceConveyorRuntimeState.source_conveyor_set_queue_for_cell_state', 'source_conveyor_set_queue_for_cell_state', CONV, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'ConveyorBuild', n2066_inputs, n2066_outputs, [IDS, XS_YS, LEN, CAPACITY]),
        ('N2067', 'SourceConveyorRuntimeState.source_conveyor_queues_for_cells_state', 'source_conveyor_queues_for_cells_state', CONV, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'ConveyorBuild', n2067_inputs, n2067_outputs, [IDS, XS_YS, LEN, CAPACITY]),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs in entries:
        names = []
        for suffix, keys in [('input', inputs)] + ([('result', outputs)] if outputs is not None else []):
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed conveyor queue storage.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed conveyor queue storage; the queue lives on the conveyor sprite meta, following the drill-frame pattern.'))
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
