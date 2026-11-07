"""Register ConveyorBuild stack API binding (N2056-N2058)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/ConveyorStackProof'
TESTS = ['test_conveyor_stack_binding_registration', 'test_all_conveyor_stack_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_stack']
DEFERRED = [
    'The stack functions operate on the queue primitives (N2053-N2055); the caller supplies the items-module count before the call and applies the count after it.',
    'The live drill->conveyor->core wiring, the drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

REMOVESTACK_SIG = 'public int removeStack(Item item, int amount){'
REMOVESTACK_LOOP = 'for(int j = 0; j < amount; j++){'
REMOVESTACK_SCAN = 'for(int i = 0; i < len; i++){'
REMOVESTACK_MATCH = 'if(ids[i] == item){'
REMOVESTACK_REMOVE = 'remove(i);'
REMOVESTACK_ITEMS = 'items.remove(item, removed);'
REMOVESTACK_RETURN = 'return removed;'
ACCEPTSTACK_SIG = 'public int acceptStack(Item item, int amount, Teamc source){'
ACCEPTSTACK_EXPR = 'return Math.min((int)(minitem / itemSpace), amount);'
HANDLESTACK_SIG = 'public void handleStack(Item item, int amount, Teamc source){'
HANDLESTACK_CLAMP = 'amount = Math.min(amount, capacity - len);'
HANDLESTACK_LOOP = 'for(int i = amount - 1; i >= 0; i--){'
HANDLESTACK_ADD = 'add(0);'
HANDLESTACK_XS = 'xs[0] = 0;'
HANDLESTACK_YS = 'ys[0] = i * itemSpace;'
HANDLESTACK_IDS = 'ids[0] = item;'
HANDLESTACK_ITEMS = 'items.add(item, 1);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2056_inputs = {
        'ids': f('Array', REMOVESTACK_MATCH, 'Item ids on the belt in queue order.'),
        'xs': f('Array', REMOVESTACK_REMOVE, 'Item x offsets on the belt in queue order.'),
        'ys': f('Array', REMOVESTACK_REMOVE, 'Item y positions on the belt in queue order.'),
        'len': f('int', REMOVESTACK_SCAN, 'Current item count on the belt.'),
        'item_id': f('String', REMOVESTACK_MATCH, 'Item to remove from the belt.'),
        'amount': f('int', REMOVESTACK_LOOP, 'Maximum number of the item to remove.'),
        'item_count_before': f('int', REMOVESTACK_ITEMS, 'Items-module count of the item before the removal.'),
    }
    n2056_outputs = {
        'ids_after': f('Array', REMOVESTACK_REMOVE, 'Item ids after the removal.'),
        'xs_after': f('Array', REMOVESTACK_REMOVE, 'Item x offsets after the removal.'),
        'ys_after': f('Array', REMOVESTACK_REMOVE, 'Item y positions after the removal.'),
        'len_before': f('int', REMOVESTACK_SCAN, 'Item count before the removal.'),
        'len_after': f('int', REMOVESTACK_REMOVE, 'Item count after the removal.'),
        'removed': f('int', REMOVESTACK_RETURN, 'Number of the item removed from the belt.'),
        'item_count_after': f('int', REMOVESTACK_ITEMS, 'Items-module count of the item after the removal.'),
        'no_sleep_called': f('bool', REMOVESTACK_SIG, 'Whether noSleep ran first in removeStack.'),
    }
    n2057_inputs = {
        'minitem': f('float', ACCEPTSTACK_EXPR, 'Smallest y among items on the belt.'),
        'item_space': f('float', ACCEPTSTACK_EXPR, 'Spacing between items on the belt.'),
        'amount': f('int', ACCEPTSTACK_EXPR, 'Requested stack size.'),
    }
    n2057_outputs = {
        'accepted': f('int', ACCEPTSTACK_EXPR, 'Stack size the belt accepts: free slots in item-space units, capped by the request.'),
        'free_slots': f('int', ACCEPTSTACK_EXPR, 'Free slots in item-space units before capping by the request.'),
        'reason': f('String', ACCEPTSTACK_SIG, 'Stack outcome: accepted, invalid_item_space.'),
    }
    n2058_inputs = {
        'ids': f('Array', HANDLESTACK_IDS, 'Item ids on the belt in queue order.'),
        'xs': f('Array', HANDLESTACK_XS, 'Item x offsets on the belt in queue order.'),
        'ys': f('Array', HANDLESTACK_YS, 'Item y positions on the belt in queue order.'),
        'len': f('int', HANDLESTACK_CLAMP, 'Current item count on the belt.'),
        'capacity': f('int', HANDLESTACK_CLAMP, 'Maximum item count on the belt.'),
        'item_id': f('String', HANDLESTACK_IDS, 'Item to insert as a stack.'),
        'amount': f('int', HANDLESTACK_CLAMP, 'Requested stack size.'),
        'item_space': f('float', HANDLESTACK_YS, 'Spacing between items on the belt.'),
        'item_count_before': f('int', HANDLESTACK_ITEMS, 'Items-module count of the item before the insertion.'),
    }
    n2058_outputs = {
        'ids_after': f('Array', HANDLESTACK_IDS, 'Item ids after the insertion.'),
        'xs_after': f('Array', HANDLESTACK_XS, 'Item x offsets after the insertion.'),
        'ys_after': f('Array', HANDLESTACK_YS, 'Item y positions after the insertion.'),
        'len_before': f('int', HANDLESTACK_CLAMP, 'Item count before the insertion.'),
        'len_after': f('int', HANDLESTACK_ADD, 'Item count after the insertion.'),
        'inserted': f('int', HANDLESTACK_LOOP, 'Number of the item inserted on the belt.'),
        'item_count_after': f('int', HANDLESTACK_ITEMS, 'Items-module count of the item after the insertion.'),
        'no_sleep_called': f('bool', HANDLESTACK_SIG, 'Whether noSleep ran after the insertion in handleStack.'),
        'reason': f('String', HANDLESTACK_SIG, 'Stack outcome: inserted, at_capacity, empty_request.'),
    }

    entries = [
        ('N2056', 'SourceConveyorRuntimeState.source_conveyor_remove_stack_state', 'source_conveyor_remove_stack_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'removeStack', n2056_inputs, n2056_outputs, [REMOVESTACK_SIG, REMOVESTACK_LOOP, REMOVESTACK_SCAN, REMOVESTACK_MATCH, REMOVESTACK_REMOVE, REMOVESTACK_ITEMS, REMOVESTACK_RETURN]),
        ('N2057', 'SourceConveyorRuntimeState.source_conveyor_accept_stack_state', 'source_conveyor_accept_stack_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'acceptStack', n2057_inputs, n2057_outputs, [ACCEPTSTACK_SIG, ACCEPTSTACK_EXPR]),
        ('N2058', 'SourceConveyorRuntimeState.source_conveyor_handle_stack_state', 'source_conveyor_handle_stack_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'handleStack', n2058_inputs, n2058_outputs, [HANDLESTACK_SIG, HANDLESTACK_CLAMP, HANDLESTACK_LOOP, HANDLESTACK_ADD, HANDLESTACK_XS, HANDLESTACK_YS, HANDLESTACK_IDS, HANDLESTACK_ITEMS]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ConveyorBuild stack API.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ConveyorBuild stack API; the result reports the queue and the items-module count after the operation.'))
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
