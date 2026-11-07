"""Register conveyor belt-advance binding (N2069-N2070).

N2069 binds the ConveyorBuild updateTile movement loop: the per-frame
item movement along the belt (clamped by the item ahead and by the next
belt), the mid/minitem scan, the x centering, and the clog heat, reporting
whether the front item is ready to pass. N2070 wires the live loop: it
advances all the conveyor queues front-to-back each frame and hands the
ready item to the next belt (via the accept/handle-for-cell hooks) or to
the core (via the game's core accept/handle methods).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
CORE = 'core/src/mindustry/world/blocks/storage/CoreBlock.java'
PROOF = '/root/ConveyorAdvanceProof'
TESTS = ['test_conveyor_advance_binding_registration', 'test_all_conveyor_advance_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_advance']
DEFERRED = [
    'The queue-to-sprite sync for the visual item sprites stays open.',
    'The drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

MINITEM = 'minitem = 1f;'
MID = 'mid = 0;'
SLEEP = 'if(len == 0 && Mathf.equal(timeScale, 1f)){'
NEXT_MAX = 'float nextMax = aligned ? 1f - Math.max(itemSpace - nextc.minitem, 0) : 1f;'
MOVED = 'float moved = speed * edelta();'
NEXTPOS = 'float nextpos = (i == len - 1 ? 100f : ys[i + 1]) - itemSpace;'
MAXMOVE = 'float maxmove = Mathf.clamp(nextpos - ys[i], 0, moved);'
CLAMP_MAX = 'if(ys[i] > nextMax) ys[i] = nextMax;'
MID_SCAN = 'if(ys[i] > 0.5 && i > 0) mid = i - 1;'
CENTER = 'xs[i] = Mathf.approach(xs[i], 0, moved*2);'
PASS_COND = 'if(ys[i] >= 1f && pass(ids[i])){'
PASS_REMOVE = 'items.remove(ids[i], len - i);'
CLOG = 'if(minitem < itemSpace + (blendbits == 1 ? 0.3f : 0f)){'
NO_SLEEP = 'noSleep();'
PASS_SIG = 'if(item != null && next != null && next.team == team && next.acceptItem(this, item)){'
PASS_HANDLE = 'next.handleItem(this, item);'
CORE_ACCEPT = 'return state.rules.coreIncinerates || items.get(item) < getMaximumAccepted(item);'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2069_inputs = {
        'ids': f('Array', NEXTPOS, 'Item ids on the belt, index 0 is the newest.'),
        'xs': f('Array', CENTER, 'Item x offsets on the belt.'),
        'ys': f('Array', MAXMOVE, 'Item y progress on the belt, 0 at the entrance, 1 at the exit.'),
        'len': f('int', SLEEP, 'Number of items on the belt.'),
        'speed': f('float', MOVED, 'Belt speed in tile units per second (0.03 for the base conveyor).'),
        'delta': f('float', MOVED, 'Effective frame delta (edelta).'),
        'time_scale': f('float', SLEEP, 'Block time scale; an empty belt sleeps when it is 1.'),
        'aligned': f('bool', NEXT_MAX, 'Whether the next building is a conveyor with the same rotation.'),
        'next_minitem': f('float', NEXT_MAX, 'The next conveyor minitem, used for the exit cap when aligned.'),
        'blendbits': f('int', CLOG, 'Blend bits for the clog threshold (1 adds 0.3).'),
        'clog_heat_before': f('float', CLOG, 'Clog heat before this frame.'),
    }
    n2069_outputs = {
        'ids_after': f('Array', PASS_REMOVE, 'Item ids after the frame.'),
        'xs_after': f('Array', CENTER, 'Item x offsets after the frame.'),
        'ys_after': f('Array', MAXMOVE, 'Item y progress after the frame.'),
        'len_after': f('int', PASS_REMOVE, 'Number of items after the frame.'),
        'mid': f('int', MID_SCAN, 'Mid index from the scan.'),
        'minitem': f('float', MINITEM, 'Smallest y among the items after the frame.'),
        'pass_ready': f('bool', PASS_COND, 'Whether the front item reached the exit and is ready to pass.'),
        'pass_item_id': f('Variant', PASS_COND, 'The front item id when ready to pass, or null.'),
        'clog_heat': f('float', CLOG, 'Clog heat after the frame.'),
        'no_sleep_called': f('bool', NO_SLEEP, 'Whether noSleep ran (the belt stayed awake this frame).'),
        'reason': f('String', SLEEP, 'Advance outcome: advanced, empty_sleep.'),
    }
    n2070_inputs = {
        'game': f('Object', PASS_SIG, 'Actual game world containing the conveyor line and the core.'),
        'conveyor_cells': f('Array', MOVED, 'Conveyor cells front-to-back (closest to the core first).'),
        'delta': f('float', MOVED, 'Effective frame delta.'),
    }
    n2070_outputs = {
        'results_by_cell': f('Dictionary', PASS_HANDLE, 'Per-cell advance results, keyed by conveyor cell.'),
        'passed_count': f('int', PASS_HANDLE, 'Items passed to the next belt or the core this frame.'),
        'reason': f('String', CORE_ACCEPT, 'Advance outcome: advanced, no_conveyors, no_sprite.', source=CORE),
    }

    entries = [
        ('N2069', 'SourceConveyorRuntimeState.source_conveyor_advance_state', 'source_conveyor_advance_state', CONV, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'updateTile', n2069_inputs, n2069_outputs, [MINITEM, MID, SLEEP, NEXT_MAX, MOVED, NEXTPOS, MAXMOVE, CLAMP_MAX, MID_SCAN, CENTER, PASS_COND, CLOG, NO_SLEEP], True, 'Dictionary'),
        ('N2070', 'SourceFactoryRuntimeState.source_factory_advance_conveyors_state', 'source_factory_advance_conveyors_state', CONV, 'mindustry.world.blocks.distribution.Conveyor$ConveyorBuild', 'updateTile', n2070_inputs, n2070_outputs, [PASS_SIG, PASS_HANDLE, PASS_REMOVE], True, 'Dictionary'),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed conveyor belt advance.'))
        if has_contract:
            source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_type=return_type, return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed conveyor belt advance; the belt moves its items and hands the front item to the next belt or the core.'))
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
