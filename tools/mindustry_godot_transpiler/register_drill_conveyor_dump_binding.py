"""Register drill->conveyor dump wiring binding (N2059-N2061).

N2059 binds Edges.getFacingEdge (the multiblock facing-edge clamp the
conveyor intake needs); N2060/N2061 bind the conveyor accept/handle
hooks for a real neighbor cell. The drill dump step that composes them
with the dump composition is the next batch (N2062).
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
TILE = 'core/src/mindustry/world/Tile.java'
EDGES = 'core/src/mindustry/world/Edges.java'
BLOCK = 'core/src/mindustry/world/Block.java'
PROOF = '/root/DrillConveyorDumpProof'
TESTS = ['test_drill_conveyor_dump_binding_registration', 'test_all_drill_conveyor_dump_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_drill_conveyor_dump']
DEFERRED = [
    'The drill dump step composing the facing edge, the accept/handle hooks and the dump composition is the next batch (N2062); the live loop still dumps straight to the core.',
    'The drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

EDGE_SINGLE = 'if(!block.isMultiblock()) return world.tile(tilex, tiley);'
EDGE_SIZE = 'int size = block.size;'
EDGE_X = 'tilex + Mathf.clamp(other.x - tilex, -(size - 1) / 2, (size / 2))'
EDGE_Y = 'tiley + Mathf.clamp(other.y - tiley, -(size - 1) / 2, (size / 2))'
EDGE_MULTIBLOCK = 'return size > 1;'
TILE_RELATIVE_NORTH = 'if(x == cx && y == cy - 1) return 1;'
TILE_RELATIVE_EAST = 'if(x == cx - 1 && y == cy) return 0;'
ACCEPT_DIRECTION = 'int direction = Math.abs(facing.relativeTo(tile.x, tile.y) - rotation);'
ACCEPT_RETURN = 'return (((direction == 0) && minitem >= itemSpace) || ((direction % 2 == 1) && minitem > 0.7f)) && !(source.block.rotate && next == source);'
ACCEPT_CAPACITY = 'if(len >= capacity) return false;'
HANDLE_SIG = 'public void handleItem(Building source, Item item){'
HANDLE_ANG = 'int ang = ((facing.relativeTo(tile.x, tile.y) - r));'
HANDLE_ITEMS = 'items.add(item, 1);'
HANDLE_ADD0 = 'add(0);'
SCAN_MINITEM = 'minitem = 1f;'
SCAN_MID_COND = 'if(ys[i] > 0.5 && i > 0) mid = i - 1;'
ADD_IDS = 'ids[i] = ids[i - 1];'
ADD_XS = 'xs[i] = xs[i - 1];'
ADD_YS = 'ys[i] = ys[i - 1];'
ADD_LEN = 'len++;'
ITEMSPACE = 'private static final float itemSpace = 0.4f;'
CAPACITY = 'private static final int capacity = 3;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=CONV, **extra):
        return backed(typ, source, expr, rule, **extra)

    n2059_inputs = {
        'block_size': f('int', EDGE_SIZE, 'Size of the source block; size 1 is not a multiblock.', source=EDGES),
        'tile_x': f('int', EDGE_SINGLE, 'X cell of the source block tile.', source=EDGES),
        'tile_y': f('int', EDGE_SINGLE, 'Y cell of the source block tile.', source=EDGES),
        'other_x': f('int', EDGE_X, 'X cell of the neighbor tile.', source=EDGES),
        'other_y': f('int', EDGE_Y, 'Y cell of the neighbor tile.', source=EDGES),
    }
    n2059_outputs = {
        'edge_x': f('int', EDGE_X, 'X cell of the facing edge tile.', source=EDGES),
        'edge_y': f('int', EDGE_Y, 'Y cell of the facing edge tile.', source=EDGES),
        'is_multiblock': f('bool', EDGE_MULTIBLOCK, 'Whether the source block is a multiblock (size > 1).', source=BLOCK),
        'reason': f('String', EDGE_SINGLE, 'Edge outcome: tile, facing_edge.', source=EDGES),
    }
    queue_inputs = {
        'queue_ids': f('Array', ADD_IDS, 'Item ids on the belt in queue order.'),
        'queue_xs': f('Array', ADD_XS, 'Item x offsets on the belt in queue order.'),
        'queue_ys': f('Array', ADD_YS, 'Item y positions on the belt in queue order.'),
        'queue_len': f('int', ADD_LEN, 'Current item count on the belt.'),
        'capacity': f('int', CAPACITY, 'Maximum item count on the belt.'),
        'item_space': f('float', ITEMSPACE, 'Spacing between items on the belt.'),
        'source_cell': f('Vector2i', TILE_RELATIVE_NORTH, 'Cell of the facing edge handing the item to the belt.', source=TILE),
        'conveyor_cell': f('Vector2i', TILE_RELATIVE_EAST, 'Cell of the belt receiving the item.', source=TILE),
        'conveyor_rotation': f('int', ACCEPT_DIRECTION, 'Rotation of the belt receiving the item.'),
    }
    n2060_inputs = dict(queue_inputs)
    n2060_inputs.update({
        'source_block_rotate': f('bool', ACCEPT_RETURN, 'Whether the source block rotates; a rotating source feeding its own next belt is refused.'),
        'next_is_source': f('bool', ACCEPT_RETURN, 'Whether the belt ahead is the source itself.'),
    })
    n2060_outputs = {
        'accepted': f('bool', ACCEPT_CAPACITY, 'Whether the belt accepts the item from this cell.'),
        'direction': f('int', ACCEPT_DIRECTION, 'Absolute facing difference between the source direction and the belt rotation.'),
        'facing_direction': f('int', ACCEPT_DIRECTION, 'Direction from the source cell to the belt cell.'),
        'minitem': f('float', SCAN_MINITEM, 'Smallest y among items on the belt.'),
        'reason': f('String', ACCEPT_CAPACITY, 'Accept outcome: accepted, at_capacity, no_facing, wrong_direction, rotate_loop.'),
    }
    n2061_inputs = dict(queue_inputs)
    n2061_inputs.update({
        'item_id': f('String', HANDLE_SIG, 'Item to insert on the belt.'),
        'item_count_before': f('int', HANDLE_ITEMS, 'Items-module count of the item on the belt before the insertion.'),
    })
    n2061_outputs = {
        'ids_after': f('Array', ADD_IDS, 'Item ids after the insertion.'),
        'xs_after': f('Array', ADD_XS, 'Item x offsets after the insertion.'),
        'ys_after': f('Array', ADD_YS, 'Item y positions after the insertion.'),
        'len_before': f('int', ADD_LEN, 'Item count before the insertion.'),
        'len_after': f('int', ADD_LEN, 'Item count after the insertion.'),
        'index': f('int', HANDLE_ADD0, 'Queue index the item was inserted at.'),
        'x': f('float', HANDLE_ANG, 'Item x offset on the belt.'),
        'y': f('float', HANDLE_ADD0, 'Item y position on the belt.'),
        'item_count_after': f('int', HANDLE_ITEMS, 'Items-module count of the item on the belt after the insertion.'),
        'no_sleep_called': f('bool', HANDLE_SIG, 'Whether noSleep ran on intake.'),
        'reason': f('String', ACCEPT_CAPACITY, 'Handle outcome: accepted, at_capacity.'),
    }

    entries = [
        ('N2059', 'SourceBlockGeometry.source_block_facing_edge_state', 'source_block_facing_edge_state', EDGES, 'mindustry.world.Edges', 'getFacingEdge', n2059_inputs, n2059_outputs, [EDGE_SINGLE, EDGE_SIZE, EDGE_X, EDGE_Y, EDGE_MULTIBLOCK]),
        ('N2060', 'SourceConveyorRuntimeState.source_conveyor_accept_for_cell_state', 'source_conveyor_accept_for_cell_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'acceptItem', n2060_inputs, n2060_outputs, [TILE_RELATIVE_NORTH, TILE_RELATIVE_EAST, ACCEPT_DIRECTION, ACCEPT_RETURN, ACCEPT_CAPACITY, SCAN_MINITEM]),
        ('N2061', 'SourceConveyorRuntimeState.source_conveyor_handle_for_cell_state', 'source_conveyor_handle_for_cell_state', CONV, 'mindustry.world.blocks.distribution.Conveyor.ConveyorBuild', 'handleItem', n2061_inputs, n2061_outputs, [TILE_RELATIVE_NORTH, TILE_RELATIVE_EAST, HANDLE_SIG, HANDLE_ANG, HANDLE_ITEMS, HANDLE_ADD0, SCAN_MID_COND, ADD_IDS, ADD_XS, ADD_YS, ADD_LEN]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed drill->conveyor dump wiring.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed drill->conveyor dump wiring; the result reports the facing edge or the belt intake.'))
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
