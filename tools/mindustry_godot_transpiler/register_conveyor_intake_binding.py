"""Register ConveyorBuild intake binding (N2050-N2052)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
PROOF = '/root/ConveyorIntakeProof'
TESTS = ['test_conveyor_intake_binding_registration', 'test_all_conveyor_intake_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_conveyor_intake']
DEFERRED = [
    'The facing direction is the direction from the source facing edge to the conveyor tile, computed by the caller with the existing tile_relative_cardinal_state; the multiblock facing-edge clamp (Edges.getFacingEdge) is a later slice.',
    'The intake inserts one item per call; per-frame movement along the belt stays with the existing conveyor path-progress runtime.',
    'The drill runtime bridge still reads the game-global drill_output_item_id; making it use the actual dominant item stays open in C02.',
    'C02 one-inventory-owner cleanup and the two-Drill gate, and C03-C12, remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

ACCEPT_SIG = 'public boolean acceptItem(Building source, Item item){'
ACCEPT_CAPACITY = 'if(len >= capacity) return false;'
ACCEPT_FACING = 'Tile facing = Edges.getFacingEdge(source.tile, tile);'
ACCEPT_FACING_NULL = 'if(facing == null) return false;'
ACCEPT_DIRECTION = 'int direction = Math.abs(facing.relativeTo(tile.x, tile.y) - rotation);'
ACCEPT_RETURN = 'return (((direction == 0) && minitem >= itemSpace) || ((direction % 2 == 1) && minitem > 0.7f)) && !(source.block.rotate && next == source);'
HANDLE_SIG = 'public void handleItem(Building source, Item item){'
HANDLE_CAPACITY = 'if(len >= capacity) return;'
HANDLE_ROTATION = 'int r = rotation;'
HANDLE_ANG = 'int ang = ((facing.relativeTo(tile.x, tile.y) - r));'
HANDLE_X = 'float x = (ang == -1 || ang == 3) ? 1 : (ang == 1 || ang == -3) ? -1 : 0;'
HANDLE_NO_SLEEP = 'noSleep();'
HANDLE_ADD = 'items.add(item, 1);'
HANDLE_STRAIGHT = 'if(Math.abs(facing.relativeTo(tile.x, tile.y) - r) == 0){ //idx = 0'
HANDLE_ADD_ZERO = 'add(0);'
HANDLE_XS_ZERO = 'xs[0] = x;'
HANDLE_YS_ZERO = 'ys[0] = 0;'
HANDLE_ADD_MID = 'add(mid);'
HANDLE_YS_MID = 'ys[mid] = 0.5f;'
ITEM_SPACE = 'private static final float itemSpace = 0.4f;'
CAPACITY_CONST = 'private static final int capacity = 3;'
PASS_SIG = 'public boolean pass(Item item){'
PASS_GUARD = 'if(item != null && next != null && next.team == team && next.acceptItem(this, item)){'
PASS_HANDLE = 'next.handleItem(this, item);'
PASS_RETURN_TRUE = 'return true;'
PASS_RETURN_FALSE = 'return false;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    # N2050: ConveyorBuild.acceptItem — the intake gate.
    n2050_inputs = {
        'len': f('int', ACCEPT_CAPACITY, 'Current item count on the belt.'),
        'capacity': f('int', CAPACITY_CONST, 'Belt capacity (3 for a conveyor).'),
        'facing_direction': f('int', ACCEPT_DIRECTION, 'Direction from the source facing edge to the conveyor tile (0 west, 1 north, 2 east, 3 south); -1 when there is no facing edge.'),
        'rotation': f('int', ACCEPT_DIRECTION, 'Conveyor rotation (0-3).'),
        'minitem': f('float', ACCEPT_RETURN, 'Smallest item y on the belt; the straight arm needs it at or past itemSpace, the side arm past 0.7.'),
        'item_space': f('float', ITEM_SPACE, 'Item spacing on the belt (0.4).'),
        'source_block_rotate': f('bool', ACCEPT_RETURN, 'Whether the source block rotates.'),
        'next_is_source': f('bool', ACCEPT_RETURN, 'Whether the next building is the source (a rotating source feeding its own next is refused).'),
    }
    n2050_outputs = {
        'accepted': f('bool', ACCEPT_RETURN, 'Whether the conveyor accepts the item.'),
        'direction': f('int', ACCEPT_DIRECTION, 'Absolute direction difference between the facing direction and the rotation.'),
        'reason': f('String', ACCEPT_RETURN, 'Intake outcome: accepted, at_capacity, no_facing, wrong_direction, rotate_loop.'),
    }
    # N2051: ConveyorBuild.handleItem — the intake, inserting at index 0 (straight) or mid (side).
    n2051_inputs = {
        'len': f('int', HANDLE_CAPACITY, 'Current item count on the belt.'),
        'capacity': f('int', CAPACITY_CONST, 'Belt capacity (3 for a conveyor).'),
        'facing_direction': f('int', HANDLE_ANG, 'Direction from the source facing edge to the conveyor tile (0 west, 1 north, 2 east, 3 south).'),
        'rotation': f('int', HANDLE_ROTATION, 'Conveyor rotation (0-3).'),
        'mid': f('int', HANDLE_ADD_MID, 'Mid insertion index from the last updateTile (the last item before the first one past halfway).'),
        'item_id': f('String', HANDLE_ADD, 'The item id being taken in.'),
        'item_count_before': f('int', HANDLE_ADD, 'Item count before the intake.'),
    }
    n2051_outputs = {
        'accepted': f('bool', HANDLE_CAPACITY, 'Whether the item was taken in (false at capacity).'),
        'index': f('int', HANDLE_ADD_ZERO, 'Insertion index: 0 for a straight entry, mid for a side entry, -1 when refused.'),
        'x': f('float', HANDLE_X, 'Inserted item x offset: 1 for a left-side entry, -1 for a right-side entry, 0 otherwise.'),
        'y': f('float', HANDLE_YS_MID, 'Inserted item y: 0 for a straight entry, 0.5 for a side entry.'),
        'len_after': f('int', HANDLE_ADD, 'Belt item count after the intake.'),
        'item_count_after': f('int', HANDLE_ADD, 'Item count after the intake.'),
        'no_sleep_called': f('bool', HANDLE_NO_SLEEP, 'Whether noSleep ran (only when the item was taken in).'),
        'reason': f('String', HANDLE_CAPACITY, 'Intake outcome: accepted, at_capacity.'),
    }
    # N2052: ConveyorBuild.pass — forward one item to the next building.
    n2052_inputs = {
        'item_id': f('Variant', PASS_GUARD, 'The item id to forward, or null.'),
        'next_present': f('bool', PASS_GUARD, 'Whether the next building exists.'),
        'next_same_team': f('bool', PASS_GUARD, 'Whether the next building is on the same team.'),
        'next_accepts_hook': f('Callable', PASS_GUARD, 'Caller-supplied next.acceptItem for the item.'),
        'next_handle_hook': f('Callable', PASS_HANDLE, 'Caller-supplied next.handleItem for the item.'),
    }
    n2052_outputs = {
        'passed': f('bool', PASS_RETURN_TRUE, 'Whether the item was forwarded to the next building.'),
        'item_id': f('Variant', PASS_GUARD, 'The item id forwarded, or null when nothing was passed.'),
        'handle_called': f('bool', PASS_HANDLE, 'Whether next.handleItem ran.'),
        'reason': f('String', PASS_RETURN_FALSE, 'Forward outcome: passed, null_item, no_next, wrong_team, next_rejects, no_handle.'),
    }

    entries = [
        ('N2050', 'SourceConveyorRuntimeState.source_conveyor_accept_item_state', 'source_conveyor_accept_item_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'acceptItem', n2050_inputs, n2050_outputs, [ACCEPT_SIG, ACCEPT_CAPACITY, ACCEPT_FACING, ACCEPT_FACING_NULL, ACCEPT_DIRECTION, ACCEPT_RETURN, ITEM_SPACE, CAPACITY_CONST]),
        ('N2051', 'SourceConveyorRuntimeState.source_conveyor_handle_item_state', 'source_conveyor_handle_item_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'handleItem', n2051_inputs, n2051_outputs, [HANDLE_SIG, HANDLE_CAPACITY, HANDLE_ROTATION, HANDLE_ANG, HANDLE_X, HANDLE_NO_SLEEP, HANDLE_ADD, HANDLE_STRAIGHT, HANDLE_ADD_ZERO, HANDLE_XS_ZERO, HANDLE_YS_ZERO, HANDLE_ADD_MID, HANDLE_YS_MID, ITEM_SPACE, CAPACITY_CONST]),
        ('N2052', 'SourceConveyorRuntimeState.source_conveyor_pass_state', 'source_conveyor_pass_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'pass', n2052_inputs, n2052_outputs, [PASS_SIG, PASS_GUARD, PASS_HANDLE, PASS_RETURN_TRUE, PASS_RETURN_FALSE]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed ConveyorBuild intake; one item per call.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed ConveyorBuild intake; the result reports the gate, the insertion and the forward.'))
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
