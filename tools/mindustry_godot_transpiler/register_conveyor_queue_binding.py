"""Register ConveyorBuild queue primitives binding (N2053-N2055)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/ConveyorQueueProof'
TESTS = ['test_conveyor_queue_binding_registration', 'test_all_conveyor_queue_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_queue']
DEFERRED = [
    'The queue primitives shift the parallel arrays only; the caller (handleItem) sets ids/index, xs/index and ys/index at the insertion slot after add.',
    'The scan models the updateTile mid/minitem pass over the ys array; per-frame movement and the pass itself stay with the existing conveyor path-progress runtime.',
    'ConveyorBuild.removeStack (bulk removal over the queue) is a later slice; the drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

ADD_SIG = 'public final void add(int o){'
ADD_LOOP = 'for(int i = Math.max(o + 1, len); i > o; i--){'
ADD_IDS = 'ids[i] = ids[i - 1];'
ADD_XS = 'xs[i] = xs[i - 1];'
ADD_YS = 'ys[i] = ys[i - 1];'
ADD_LEN = 'len++;'
REMOVE_SIG = 'public final void remove(int o){'
REMOVE_LOOP = 'for(int i = o; i < len - 1; i++){'
REMOVE_IDS = 'ids[i] = ids[i + 1];'
REMOVE_XS = 'xs[i] = xs[i + 1];'
REMOVE_YS = 'ys[i] = ys[i + 1];'
REMOVE_LEN = 'len--;'
SCAN_MINITEM = 'minitem = 1f;'
SCAN_MID = 'mid = 0;'
SCAN_MID_COND = 'if(ys[i] > 0.5 && i > 0) mid = i - 1;'
SCAN_MINITEM_COND = 'else if(ys[i] < minitem){'
SCAN_PASS = 'if(ys[i] >= 1f && pass(ids[i])){'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    queue_inputs = {
        'ids': f('Array', ADD_IDS, 'Item ids on the belt in queue order.'),
        'xs': f('Array', ADD_XS, 'Item x offsets on the belt in queue order.'),
        'ys': f('Array', ADD_YS, 'Item y positions on the belt in queue order.'),
        'len': f('int', ADD_LEN, 'Current item count on the belt.'),
        'index': f('int', ADD_LOOP, 'Queue index to insert at (add) or remove at (remove).'),
    }
    queue_outputs = {
        'ids_after': f('Array', ADD_IDS, 'Item ids after the shift.'),
        'xs_after': f('Array', ADD_XS, 'Item x offsets after the shift.'),
        'ys_after': f('Array', ADD_YS, 'Item y positions after the shift.'),
        'len_before': f('int', ADD_LEN, 'Item count before the operation.'),
        'len_after': f('int', ADD_LEN, 'Item count after the operation.'),
        'shifted': f('int', ADD_LOOP, 'Elements moved by the shift.'),
        'reason': f('String', ADD_SIG, 'Queue outcome: shifted, invalid_index.'),
    }
    # N2053: ConveyorBuild.add — shift right from the insertion index, len++.
    n2053_inputs = copy.deepcopy(queue_inputs)
    n2053_outputs = copy.deepcopy(queue_outputs)
    # N2054: ConveyorBuild.remove — shift left from the removal index, len--.
    n2054_inputs = copy.deepcopy(queue_inputs)
    n2054_outputs = copy.deepcopy(queue_outputs)
    # N2055: the updateTile mid/minitem scan over the ys array.
    n2055_inputs = {
        'ys': f('Array', SCAN_MID_COND, 'Item y positions on the belt in queue order.'),
        'passed_by_index': f('Array[bool]', SCAN_PASS, 'Whether the item at each index passed forwards this tick; passed items do not update minitem.'),
    }
    n2055_outputs = {
        'mid': f('int', SCAN_MID_COND, 'Mid insertion index: the last item before the first one past halfway, or 0.'),
        'minitem': f('float', SCAN_MINITEM_COND, 'Smallest y among items that did not pass, starting from 1.0.'),
    }

    entries = [
        ('N2053', 'SourceConveyorRuntimeState.source_conveyor_queue_add_state', 'source_conveyor_queue_add_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'add', n2053_inputs, n2053_outputs, [ADD_SIG, ADD_LOOP, ADD_IDS, ADD_XS, ADD_YS, ADD_LEN]),
        ('N2054', 'SourceConveyorRuntimeState.source_conveyor_queue_remove_state', 'source_conveyor_queue_remove_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'remove', n2054_inputs, n2054_outputs, [REMOVE_SIG, REMOVE_LOOP, REMOVE_IDS, REMOVE_XS, REMOVE_YS, REMOVE_LEN]),
        ('N2055', 'SourceConveyorRuntimeState.source_conveyor_queue_scan_state', 'source_conveyor_queue_scan_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'updateTile', n2055_inputs, n2055_outputs, [SCAN_MINITEM, SCAN_MID, SCAN_MID_COND, SCAN_MINITEM_COND, SCAN_PASS]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ConveyorBuild queue primitive.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ConveyorBuild queue primitive; the result reports the shifted queue and the new count.'))
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
