"""Register noSleep wake-on-activity binding (N2044-N2046)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/NoSleepWakeProof'
TESTS = ['test_no_sleep_wake_binding_registration', 'test_all_no_sleep_wake_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_no_sleep_wake']
DEFERRED = [
    'Entity group membership (Groups add/remove) has no runtime equivalent; the wake transition records add_called with the Java add() call instead of moving the Building between groups.',
    'Conveyor.unitOn also calls noSleep, but its unit-pushing body is out of scope for this batch; only handleStack, removeStack and onProximityUpdate wake the Building here.',
    'Controller pickup and world transition invalidation stay open in C01; they need the unit system and campaign state machine.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

HANDLE_STACK = 'public void handleStack(Item item, int amount, @Nullable Teamc source){'
HANDLE_ADD = 'items.add(item, amount);'
REMOVE_STACK = 'public int removeStack(Item item, int amount){'
REMOVE_NULL = 'if(items == null) return 0;'
REMOVE_MIN = 'amount = Math.min(amount, items.get(item));'
REMOVE_CALL = 'items.remove(item, amount);'
REMOVE_RETURN = 'return amount;'
PROXIMITY_UPDATE = 'public void onProximityUpdate(){'
NO_SLEEP = 'public void noSleep(){'
SLEEP_RESET = 'sleepTime = 0f;'
SLEEP_GUARD = 'if(sleeping){'
SLEEP_ADD = 'add();'
SLEEP_CLEAR = 'sleeping = false;'
SLEEP_DECREMENT = 'sleepingEntities--;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    wake_outputs = {
        'sleep_time_before': f('float', SLEEP_RESET, 'Actual sleepTime before the wake; noSleep resets it to 0.'),
        'sleep_time_after': f('float', SLEEP_RESET, 'Actual sleepTime after the wake: 0 when noSleep ran, unchanged when the null guard returned first.'),
        'sleeping_before': f('bool', SLEEP_GUARD, 'Actual sleeping flag before the wake.'),
        'sleeping_after': f('bool', SLEEP_CLEAR, 'Actual sleeping flag after the wake: false when noSleep ran, unchanged when the null guard returned first.'),
        'sleeping_entities_before': f('int', SLEEP_DECREMENT, 'Actual sleepingEntities count before the wake.'),
        'sleeping_entities_after': f('int', SLEEP_DECREMENT, 'Actual sleepingEntities count after the wake: one less when the Building was sleeping and noSleep ran.'),
        'woke': f('bool', SLEEP_GUARD, 'Whether the Building was sleeping and noSleep woke it.'),
        'add_called': f('bool', SLEEP_ADD, 'Whether the Java add() group rejoin ran (only when the Building was sleeping).'),
    }
    # N2044: handleStack wakes the Building, then adds the stack.
    n2044_inputs = {
        'current_count': f('int', HANDLE_STACK, 'Actual item count before the stack is handled.'),
        'amount': f('int', HANDLE_STACK, 'Actual stack amount being handled.'),
        'sleep_time': f('float', SLEEP_RESET, 'Actual sleepTime before the wake.'),
        'sleeping': f('bool', SLEEP_GUARD, 'Actual sleeping flag before the wake.'),
        'sleeping_entities': f('int', SLEEP_DECREMENT, 'Actual sleepingEntities count before the wake.'),
    }
    n2044_outputs = {
        'count_before': f('int', HANDLE_STACK, 'Actual item count before the stack is handled.'),
        'count_after': f('int', HANDLE_ADD, 'Actual item count after the stack is added.'),
    }
    n2044_outputs.update(copy.deepcopy(wake_outputs))
    # N2045: removeStack wakes the Building (unless the null guard returns first), then removes the stack.
    n2045_inputs = {
        'has_items_module': f('bool', REMOVE_NULL, 'Whether the Building has an items module; without one removeStack returns 0 before noSleep.'),
        'item_count': f('int', REMOVE_MIN, 'Actual item count before the stack is removed.'),
        'amount': f('int', REMOVE_MIN, 'Actual stack amount requested for removal.'),
        'sleep_time': f('float', SLEEP_RESET, 'Actual sleepTime before the wake.'),
        'sleeping': f('bool', SLEEP_GUARD, 'Actual sleeping flag before the wake.'),
        'sleeping_entities': f('int', SLEEP_DECREMENT, 'Actual sleepingEntities count before the wake.'),
    }
    n2045_outputs = {
        'removed': f('int', REMOVE_MIN, 'Actual amount removed: the minimum of the requested amount and the item count.'),
        'remaining': f('int', REMOVE_CALL, 'Actual item count after the stack is removed.'),
        'return_value': f('int', REMOVE_RETURN, 'Actual removeStack return value, equal to the removed amount.'),
    }
    n2045_outputs.update(copy.deepcopy(wake_outputs))
    # N2046: onProximityUpdate is just noSleep.
    n2046_inputs = {
        'sleep_time': f('float', SLEEP_RESET, 'Actual sleepTime before the wake.'),
        'sleeping': f('bool', SLEEP_GUARD, 'Actual sleeping flag before the wake.'),
        'sleeping_entities': f('int', SLEEP_DECREMENT, 'Actual sleepingEntities count before the wake.'),
    }
    n2046_outputs = copy.deepcopy(wake_outputs)

    entries = [
        ('N2044', 'SourceBuildingItemState.source_handle_stack_wake_state', 'source_handle_stack_wake_state', COMP, 'mindustry.entities.comp.BuildingComp', 'handleStack', n2044_inputs, n2044_outputs, [HANDLE_STACK, HANDLE_ADD, NO_SLEEP, SLEEP_RESET, SLEEP_GUARD, SLEEP_ADD, SLEEP_CLEAR, SLEEP_DECREMENT]),
        ('N2045', 'SourceBuildingItemState.source_remove_stack_wake_state', 'source_remove_stack_wake_state', COMP, 'mindustry.entities.comp.BuildingComp', 'removeStack', n2045_inputs, n2045_outputs, [REMOVE_STACK, REMOVE_NULL, REMOVE_MIN, REMOVE_CALL, REMOVE_RETURN, NO_SLEEP, SLEEP_RESET, SLEEP_GUARD, SLEEP_ADD, SLEEP_CLEAR, SLEEP_DECREMENT]),
        ('N2046', 'SourceBuildingAccessState.source_on_proximity_update_wake_state', 'source_on_proximity_update_wake_state', COMP, 'mindustry.entities.comp.BuildingComp', 'onProximityUpdate', n2046_inputs, n2046_outputs, [PROXIMITY_UPDATE, NO_SLEEP, SLEEP_RESET, SLEEP_GUARD, SLEEP_ADD, SLEEP_CLEAR, SLEEP_DECREMENT]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed noSleep wake; the group add() is recorded, not executed, because the runtime has no entity groups.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed noSleep wake; the result reports the stack change and the sleep transition.'))
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
