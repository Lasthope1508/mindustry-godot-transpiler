"""Register Building.dump(todump) composition binding (N2047-N2049)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/BuildingDumpProof'
TESTS = ['test_building_dump_binding_registration', 'test_all_building_dump_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_building_dump']
DEFERRED = [
    'The dump composition transfers one item per call to the first accepting neighbor in cdump order; multi-item and per-frame dump accumulation stay with the existing dump-accumulate state.',
    'Receiver-side accept/handle/canDump are caller-supplied hooks; the runtime has no per-building acceptItem/handleItem yet, so the proof supplies them from a neighbor accept map.',
    'The drill runtime bridge still reads the game-global drill_output_item_id; making it use the actual dominant item stays open in C02.',
    'C02 conveyor transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_DEFAULT_SIG = 'public boolean dump(){'
DUMP_DEFAULT_CALL = 'return dump(null);'
DUMP_SIG = 'public boolean dump(Item todump){'
GUARD = 'if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;'
CDUMP_ASSIGN = 'int dump = this.cdump;'
NULL_BRANCH = 'if(todump == null){'
ACCEPT_ITEM = 'if(other.acceptItem(self(), item) && canDump(other, item)){'
HANDLE_ITEM = 'other.handleItem(self(), item);'
REMOVE_ITEM = 'items.remove(item, 1);'
ACCEPT_TODUMP = 'if(other.acceptItem(self(), todump) && canDump(other, todump)){'
HANDLE_TODUMP = 'other.handleItem(self(), todump);'
REMOVE_TODUMP = 'items.remove(todump, 1);'
INCREMENT = 'incrementDump(proximity.size);'
RETURN_TRUE = 'return true;'
RETURN_FALSE = 'return false;'
INCREMENT_DEF = 'public void incrementDump(int prox){'
INCREMENT_GUARD = 'if(prox != 0){'
INCREMENT_ASSIGN = 'cdump = ((cdump + 1) % prox);'
CAN_DUMP_DEF = 'public boolean canDump(Building to, Item item){'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=COMP, **extra):
        return backed(typ, source, expr, rule, **extra)

    dump_outputs = {
        'dumped': f('bool', RETURN_TRUE, 'Whether one item was transferred to a neighbor; false when no neighbor accepted.'),
        'item_id': f('Variant', HANDLE_TODUMP, 'The item id transferred, or null when nothing was dumped.'),
        'receiver_index': f('int', CDUMP_ASSIGN, 'Index of the receiving neighbor in the proximity array, or -1 when nothing was dumped.'),
        'receiver': f('Variant', HANDLE_TODUMP, 'The receiving neighbor, or null when nothing was dumped.'),
        'cdump_before': f('int', CDUMP_ASSIGN, 'The cdump cursor before the dump; the scan starts at this neighbor.'),
        'cdump_after': f('int', INCREMENT_ASSIGN, 'The cdump cursor after the dump; it advances once per neighbor visited, including the receiving one.'),
        'items_after': f('Dictionary', REMOVE_TODUMP, 'The items dict after the dump; one unit of the dumped item is removed.'),
        'removed': f('int', REMOVE_TODUMP, 'Units removed from the items dict: 1 when an item was dumped, 0 otherwise.'),
        'reason': f('String', RETURN_FALSE, 'Dump outcome: dumped, no_items_block, empty_items, no_proximity, item_not_held, no_receiver.'),
    }
    hooks = {
        'accept_item_hook': f('Callable', ACCEPT_TODUMP, 'Caller-supplied acceptItem: whether a neighbor accepts an item.'),
        'handle_item_hook': f('Callable', HANDLE_TODUMP, 'Caller-supplied handleItem: the receiver-side item intake.'),
        'can_dump_hook': f('Callable', CAN_DUMP_DEF, 'Caller-supplied canDump: defaults to true, matching the Java default.'),
    }
    # N2047: dump a specific item.
    n2047_inputs = {
        'items': f('Dictionary', GUARD, 'The Building items dict (item id to count).'),
        'proximity': f('Array', GUARD, 'The proximity builds in updateProximity order.'),
        'todump': f('String', ACCEPT_TODUMP, 'The item id to dump.'),
        'cdump': f('int', CDUMP_ASSIGN, 'The cdump cursor; the scan starts at this neighbor.'),
        'has_items': f('bool', GUARD, 'Whether the block hasItems; without it dump returns false.'),
    }
    n2047_inputs.update(copy.deepcopy(hooks))
    n2047_outputs = copy.deepcopy(dump_outputs)
    # N2048: dump(null) — any item, in content order, to the first accepting neighbor.
    n2048_inputs = {
        'items': f('Dictionary', GUARD, 'The Building items dict (item id to count).'),
        'proximity': f('Array', GUARD, 'The proximity builds in updateProximity order.'),
        'cdump': f('int', CDUMP_ASSIGN, 'The cdump cursor; the scan starts at this neighbor.'),
        'has_items': f('bool', GUARD, 'Whether the block hasItems; without it dump returns false.'),
        'content_item_ids': f('Array', NULL_BRANCH, 'Content-order item ids; the null branch tries them in this order per neighbor.'),
    }
    n2048_inputs.update(copy.deepcopy(hooks))
    n2048_outputs = copy.deepcopy(dump_outputs)
    # N2049: the dump() entry — todump null dispatches to the any-item branch.
    n2049_inputs = {
        'items': f('Dictionary', GUARD, 'The Building items dict (item id to count).'),
        'proximity': f('Array', GUARD, 'The proximity builds in updateProximity order.'),
        'todump': f('Variant', DUMP_DEFAULT_CALL, 'The item id to dump, or null to dump any item.'),
        'cdump': f('int', CDUMP_ASSIGN, 'The cdump cursor; the scan starts at this neighbor.'),
        'has_items': f('bool', GUARD, 'Whether the block hasItems; without it dump returns false.'),
        'content_item_ids': f('Array', NULL_BRANCH, 'Content-order item ids for the null branch.'),
    }
    n2049_inputs.update(copy.deepcopy(hooks))
    n2049_outputs = copy.deepcopy(dump_outputs)

    entries = [
        ('N2047', 'SourceBuildingItemDumpState.source_building_dump_specific_state', 'source_building_dump_specific_state', COMP, 'mindustry.entities.comp.BuildingComp', 'dump', n2047_inputs, n2047_outputs, [DUMP_SIG, GUARD, CDUMP_ASSIGN, ACCEPT_TODUMP, HANDLE_TODUMP, REMOVE_TODUMP, INCREMENT, RETURN_TRUE, RETURN_FALSE, INCREMENT_DEF, INCREMENT_GUARD, INCREMENT_ASSIGN, CAN_DUMP_DEF]),
        ('N2048', 'SourceBuildingItemDumpState.source_building_dump_any_state', 'source_building_dump_any_state', COMP, 'mindustry.entities.comp.BuildingComp', 'dump', n2048_inputs, n2048_outputs, [DUMP_SIG, GUARD, CDUMP_ASSIGN, NULL_BRANCH, ACCEPT_ITEM, HANDLE_ITEM, REMOVE_ITEM, INCREMENT, RETURN_TRUE, RETURN_FALSE, INCREMENT_DEF, INCREMENT_GUARD, INCREMENT_ASSIGN, CAN_DUMP_DEF]),
        ('N2049', 'PortGame.source_building_dump_state', 'source_building_dump_state', COMP, 'mindustry.entities.comp.BuildingComp', 'dump', n2049_inputs, n2049_outputs, [DUMP_DEFAULT_SIG, DUMP_DEFAULT_CALL, DUMP_SIG, GUARD, CDUMP_ASSIGN, NULL_BRANCH, ACCEPT_TODUMP, ACCEPT_ITEM, INCREMENT, RETURN_TRUE, RETURN_FALSE]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed Building.dump composition; one item per call to the first accepting neighbor in cdump order.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed Building.dump composition; the result reports the dumped item, the receiver and the advanced cdump cursor.'))
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
