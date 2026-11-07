"""Register live loop dump swap binding (N2068).

N2068 binds the live-loop dump step: on the drill dump timer the drill
dumps through the dump composition over the stored conveyor queues
(Drill.java:288), dispatching to the specific step when the dominant
item is held and to the any step otherwise, and simulate_factory calls
it instead of dumping straight to the core. The wiring is part of this
slice: simulate_factory is not a source_-prefixed function, so it cannot
carry its own contract (the catalog validator only discovers source_
functions, and every module shard test requires each slice owner to have
one).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
BUILD = 'core/src/mindustry/entities/comp/BuildingComp.java'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/FactoryDumpSwapProof'
TESTS = ['test_factory_dump_swap_binding_registration', 'test_all_factory_dump_swap_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_factory_dump_swap']
DEFERRED = [
    'The belt-advance step (queue items moving along the belt and passing to the next building or the core) stays open; a dumped item waits on the belt until then.',
    'The queue-to-sprite sync for the visual item sprites stays open.',
    'The drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_TIMER = 'if(timer(timerDump, dumpTime / timeScale)){'
DUMP_CALL = 'dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);'
DUMP_SIG = 'public boolean dump(Item todump){'
DUMP_GUARD = 'if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;'
DUMP_OTHER = 'Building other = proximity.get((i + dump) % proximity.size);'
DUMP_HANDLE = 'other.handleItem(self(), todump);'
DUMP_REMOVE = 'items.remove(todump, 1);'
DUMP_CDUMP = 'int dump = this.cdump;'
DUMP_INCREMENT = 'cdump = ((cdump + 1) % prox);'
DUMP_CDUMP_FIELD = 'transient int cdump;'
IDS = 'public Item[] ids = new Item[capacity];'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2068_inputs = {
        'game': f('Object', DUMP_TIMER, 'Actual game world containing the drill and its conveyors.'),
        'drill_cell': f('Vector2i', DUMP_CALL, 'Cell of the dumping drill.'),
        'drill_output_item_id': f('Variant', DUMP_CALL, 'Dominant item id, or null when the drill has no dominant item.'),
    }
    n2068_outputs = {
        'dumped': f('bool', DUMP_HANDLE, 'Whether the item reached a neighbor belt.', source=BUILD),
        'item_id': f('String', DUMP_CALL, 'Item dumped, or null when nothing was dumped.'),
        'receiver_index': f('int', DUMP_OTHER, 'Index of the receiving neighbor in the proximity list, or -1.', source=BUILD),
        'receiver_cell': f('Variant', DUMP_OTHER, 'Cell of the receiving neighbor belt, or null.', source=BUILD),
        'cdump_before': f('int', DUMP_CDUMP, 'Dump cursor before the step.', source=BUILD),
        'cdump_after': f('int', DUMP_INCREMENT, 'Dump cursor after the step.', source=BUILD),
        'items_after': f('Dictionary', DUMP_REMOVE, 'The drill inventory after the step.', source=BUILD),
        'queues_after': f('Dictionary', IDS, 'Conveyor queues keyed by neighbor cell after the step.', source=CONV),
        'removed': f('int', DUMP_REMOVE, 'Units removed from the drill inventory.', source=BUILD),
        'destination': f('String', DUMP_HANDLE, 'Where the item went: conveyor, none.', source=BUILD),
        'reason': f('String', DUMP_GUARD, 'Dump outcome: dumped, no_receiver, no_items_block, empty_items, no_proximity, item_not_held, no_sprite, no_frame.', source=BUILD),
    }
    entries = [
        ('N2068', 'SourceFactoryRuntimeState.source_factory_dump_drill_output_state', 'source_factory_dump_drill_output_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'updateTile', n2068_inputs, n2068_outputs, [DUMP_TIMER, DUMP_CALL], True, 'Dictionary'),
    ]
    for sid, owner, prefix, source, cls, method, inputs, outputs, exprs, has_contract, return_type in entries:
        names = []
        for suffix, keys in [('input', inputs)] + ([('result', outputs)] if outputs is not None else []):
            name = prefix + '_' + suffix
            for field, meta in keys.items():
                meta['used_by'] = [owner]
                # N2029 symbol naming: schema name + '.' + field.
                symbol = name + '.' + field
                names.append(symbol)
                symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed live-loop drill dump.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs) if outputs is not None else [], tests=TESTS, runtime_proof=PROOF, rule='Source-backed live-loop drill dump; the drill dumps through the dump composition over the stored conveyor queues, and simulate_factory calls this step instead of dumping straight to the core.'))
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
