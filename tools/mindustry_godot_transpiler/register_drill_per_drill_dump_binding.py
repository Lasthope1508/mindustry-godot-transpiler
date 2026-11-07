"""Register per-drill dump binding (N2072).

N2072 makes the drill dump step use each drill's own inventory (one
inventory owner): the primary drill dumps from the game-global
drill_items (kept in sync with its frame), and every other drill dumps
from its own frame inventory. Before this slice the dump step always
read the game-global, so a second drill's output never reached a belt
or the core.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
COMP = 'core/src/mindustry/entities/comp/BuildingComp.java'
PROOF = '/root/DrillPerDrillDumpProof'
TESTS = ['test_drill_per_drill_dump_binding_registration', 'test_all_drill_per_drill_dump_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_drill_per_drill_dump']
DEFERRED = [
    'The live loop still dumps only the primary drill; the two-Drill gate (simulate_factory dumping each drill) stays open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_TIMER = 'if(timer(timerDump, dumpTime / timeScale)){'
DUMP_DISPATCH = 'dump(dominantItem != null && items.has(dominantItem) ? dominantItem : null);'
NULL_GATE = 'if(dominantItem == null){'
TIME_DRILLED = 'timeDrilled += warmup * delta();'
DELAY = 'float delay = getDrillTime(dominantItem);'
CDUMP_FIELD = 'transient int cdump;'
CDUMP_INC = 'cdump = ((cdump + 1) % prox);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=DRILL, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2072_inputs = {
        'game': f('Object', DUMP_TIMER, 'Actual game world containing the drill and its belts.'),
        'drill_cell': f('Vector2i', DUMP_DISPATCH, 'The drill cell whose output is dumped.'),
        'drill_output_item_id': f('Variant', DUMP_DISPATCH, 'The dominant item id for this drill, or null.'),
    }
    n2072_outputs = {
        'dumped': f('bool', DUMP_DISPATCH, 'Whether an item was dumped to a receiver.'),
        'item_id': f('Variant', DUMP_DISPATCH, 'The dumped item id, or null.'),
        'receiver_index': f('int', DUMP_DISPATCH, 'The receiver index in the proximity ring, or -1.'),
        'receiver_cell': f('Variant', DUMP_DISPATCH, 'The receiver cell, or null.'),
        'cdump_before': f('int', CDUMP_FIELD, 'The cdump cursor before the dump.', source=COMP),
        'cdump_after': f('int', CDUMP_INC, 'The cdump cursor after the dump.', source=COMP),
        'items_after': f('Dictionary', DUMP_DISPATCH, 'This drill inventory after the dump.'),
        'queues_after': f('Dictionary', DUMP_DISPATCH, 'The conveyor queues after the dump.'),
        'removed': f('int', DUMP_DISPATCH, 'Items removed from this drill inventory.'),
        'destination': f('String', DUMP_DISPATCH, 'The dump destination: conveyor, none.'),
        'reason': f('String', NULL_GATE, 'Dump outcome: dumped, no_receiver, no_items_block, empty_items, no_proximity, item_not_held, no_sprite, no_frame.'),
    }

    entries = [
        ('N2072', 'SourceFactoryRuntimeState.source_factory_dump_drill_output_for_cell_state', 'source_factory_dump_drill_output_for_cell_state', DRILL, 'mindustry.world.blocks.production.Drill$DrillBuild', 'updateTile', n2072_inputs, n2072_outputs, [DUMP_TIMER, DUMP_DISPATCH, NULL_GATE, TIME_DRILLED, DELAY], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed per-drill dump.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed per-drill dump; each drill dumps from its own inventory (the primary from the game-global, every other from its frame).'))
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
