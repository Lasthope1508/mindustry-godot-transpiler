"""Register drill dump step binding (N2062-N2064).

N2062/N2063 bind the drill dump step through the dump composition with
the N2060/N2061 conveyor hooks (specific item, then the dump(null) any
branch); N2064 binds the proximity ring in Java angle order
(Edges.getEdges), which the dump step takes as its proximity list.
"""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
CONV = 'core/src/mindustry/world/blocks/distribution/Conveyor.java'
BUILD = 'core/src/mindustry/entities/comp/BuildingComp.java'
EDGES = 'core/src/mindustry/world/Edges.java'
TILE = 'core/src/mindustry/world/Tile.java'
PROOF = '/root/DrillDumpStepProof'
TESTS = ['test_drill_dump_step_binding_registration', 'test_all_drill_dump_step_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_drill_dump_step']
DEFERRED = [
    'The dump step operates on caller-supplied conveyor queues keyed by cell; no runtime queue storage exists yet, so the live loop still dumps straight to the core.',
    'The drill runtime bridge global item and the one-inventory-owner cleanup stay open in C02.',
    'C02 two-Drill gate and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

DUMP_SIG = 'public boolean dump(Item todump){'
DUMP_NULL = 'return dump(null);'
DUMP_GUARD = 'if(!block.hasItems || items.total() == 0 || proximity.size == 0 || (todump != null && !items.has(todump))) return false;'
DUMP_CDUMP = 'int dump = this.cdump;'
DUMP_OTHER = 'Building other = proximity.get((i + dump) % proximity.size);'
DUMP_ACCEPT = 'if(other.acceptItem(self(), todump) && canDump(other, todump)){'
DUMP_HANDLE = 'other.handleItem(self(), todump);'
DUMP_REMOVE = 'items.remove(todump, 1);'
DUMP_INCREMENT = 'incrementDump(proximity.size);'
DUMP_ANY_ACCEPT = 'if(other.acceptItem(self(), item) && canDump(other, item)){'
DUMP_ANY_HANDLE = 'other.handleItem(self(), item);'
DUMP_ANY_REMOVE = 'items.remove(item, 1);'
EDGE_SINGLE = 'if(!block.isMultiblock()) return world.tile(tilex, tiley);'
EDGE_X = 'tilex + Mathf.clamp(other.x - tilex, -(size - 1) / 2, (size / 2))'
ACCEPT_DIRECTION = 'int direction = Math.abs(facing.relativeTo(tile.x, tile.y) - rotation);'
ACCEPT_RETURN = 'return (((direction == 0) && minitem >= itemSpace) || ((direction % 2 == 1) && minitem > 0.7f)) && !(source.block.rotate && next == source);'
ITEMSPACE = 'private static final float itemSpace = 0.4f;'
CAPACITY = 'private static final int capacity = 3;'
EDGES_BOT = 'int bot = -(int)(i / 2f) - 1;'
EDGES_TOP = 'int top = (int)(i / 2f + 0.5f) + 1;'
EDGES_BOTTOM = 'edges[i][idx++] = new Point2(bot + 1 + j, bot);'
EDGES_TOP_PT = 'edges[i][idx++] = new Point2(bot + 1 + j, top);'
EDGES_LEFT = 'edges[i][idx++] = new Point2(bot, bot + j + 1);'
EDGES_RIGHT = 'edges[i][idx++] = new Point2(top, bot + j + 1);'
EDGES_SORT = 'Arrays.sort(edges[i], (e1, e2) -> Float.compare(Mathf.angle(e1.x, e1.y), Mathf.angle(e2.x, e2.y)));'
EDGES_GET = 'return edges[size - 1];'
TILE_RELATIVE_NORTH = 'if(x == cx && y == cy - 1) return 1;'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BUILD, **extra):
        return backed(typ, source, expr, rule, **extra)

    step_inputs = {
        'items': f('Dictionary', DUMP_GUARD, 'The dumping building inventory by item id.'),
        'proximity_cells': f('Array', DUMP_OTHER, 'Neighbor cells in dump order.'),
        'cdump': f('int', DUMP_CDUMP, 'Dump cursor before the step.'),
        'has_items': f('bool', DUMP_GUARD, 'Whether the dumping building has an items module.'),
        'queues_by_cell': f('Dictionary', DUMP_OTHER, 'Conveyor queues keyed by neighbor cell; cells without a queue fail closed.'),
        'capacity': f('int', CAPACITY, 'Maximum item count on a belt.', source=CONV),
        'item_space': f('float', ITEMSPACE, 'Spacing between items on a belt.', source=CONV),
        'conveyor_rotation_by_cell': f('Dictionary', ACCEPT_DIRECTION, 'Belt rotations keyed by neighbor cell.', source=CONV),
        'source_block_rotate': f('bool', ACCEPT_RETURN, 'Whether the source block rotates; a rotating source feeding its own next belt is refused.', source=CONV),
        'next_is_source': f('bool', ACCEPT_RETURN, 'Whether the belt ahead is the source itself.', source=CONV),
        'drill_cell': f('Vector2i', TILE_RELATIVE_NORTH, 'Cell of the dumping drill.', source=TILE),
        'drill_size': f('int', EDGE_X, 'Size of the dumping drill; the facing edge is clamped from it.', source=EDGES),
    }
    step_outputs = {
        'dumped': f('bool', DUMP_HANDLE, 'Whether the item reached a neighbor belt.'),
        'item_id': f('String', DUMP_SIG, 'Item dumped, or null when nothing was dumped.'),
        'receiver_index': f('int', DUMP_OTHER, 'Index of the receiving neighbor in the proximity list, or -1.'),
        'receiver_cell': f('Variant', DUMP_OTHER, 'Cell of the receiving neighbor belt, or null.'),
        'cdump_before': f('int', DUMP_CDUMP, 'Dump cursor before the step.'),
        'cdump_after': f('int', DUMP_INCREMENT, 'Dump cursor after the step.'),
        'items_after': f('Dictionary', DUMP_REMOVE, 'The dumping building inventory after the step.'),
        'queues_after': f('Dictionary', DUMP_HANDLE, 'Conveyor queues keyed by neighbor cell after the step.'),
        'removed': f('int', DUMP_REMOVE, 'Units removed from the dumping building inventory.'),
        'destination': f('String', DUMP_HANDLE, 'Where the item went: conveyor, none.'),
        'reason': f('String', DUMP_GUARD, 'Dump outcome: dumped, no_receiver, no_items_block, empty_items, no_proximity, item_not_held.'),
    }
    n2062_inputs = dict(step_inputs)
    n2062_inputs['todump'] = f('String', DUMP_SIG, 'Item to dump to the first accepting neighbor.')
    # Keep the Java method order: todump sits after proximity_cells in the
    # dump signature; rebuild the dict in that order for readability.
    n2062_inputs = {
        'items': step_inputs['items'],
        'proximity_cells': step_inputs['proximity_cells'],
        'todump': n2062_inputs['todump'],
        'cdump': step_inputs['cdump'],
        'has_items': step_inputs['has_items'],
        'queues_by_cell': step_inputs['queues_by_cell'],
        'capacity': step_inputs['capacity'],
        'item_space': step_inputs['item_space'],
        'conveyor_rotation_by_cell': step_inputs['conveyor_rotation_by_cell'],
        'source_block_rotate': step_inputs['source_block_rotate'],
        'next_is_source': step_inputs['next_is_source'],
        'drill_cell': step_inputs['drill_cell'],
        'drill_size': step_inputs['drill_size'],
    }
    n2062_outputs = dict(step_outputs)
    n2063_inputs = {
        'items': step_inputs['items'],
        'proximity_cells': step_inputs['proximity_cells'],
        'cdump': step_inputs['cdump'],
        'has_items': step_inputs['has_items'],
        'content_item_ids': f('Array', DUMP_NULL, 'Item ids in content order; the any branch tries them per neighbor.'),
        'queues_by_cell': step_inputs['queues_by_cell'],
        'capacity': step_inputs['capacity'],
        'item_space': step_inputs['item_space'],
        'conveyor_rotation_by_cell': step_inputs['conveyor_rotation_by_cell'],
        'source_block_rotate': step_inputs['source_block_rotate'],
        'next_is_source': step_inputs['next_is_source'],
        'drill_cell': step_inputs['drill_cell'],
        'drill_size': step_inputs['drill_size'],
    }
    n2063_outputs = dict(step_outputs)
    n2063_outputs['dumped'] = f('bool', DUMP_ANY_HANDLE, 'Whether an item reached a neighbor belt.')
    n2063_outputs['items_after'] = f('Dictionary', DUMP_ANY_REMOVE, 'The dumping building inventory after the step.')
    n2063_outputs['queues_after'] = f('Dictionary', DUMP_ANY_HANDLE, 'Conveyor queues keyed by neighbor cell after the step.')
    n2063_outputs['removed'] = f('int', DUMP_ANY_REMOVE, 'Units removed from the dumping building inventory.')
    n2063_outputs['destination'] = f('String', DUMP_ANY_HANDLE, 'Where the item went: conveyor, none.')
    n2064_inputs = {
        'block_size': f('int', EDGES_GET, 'Size of the block whose proximity ring is returned.', source=EDGES),
        'tile_x': f('int', EDGES_BOT, 'X cell of the block tile.', source=EDGES),
        'tile_y': f('int', EDGES_BOT, 'Y cell of the block tile.', source=EDGES),
    }
    n2064_outputs = {
        'cells': f('Array', EDGES_SORT, 'Ring cells around the block in Java angle order.', source=EDGES),
        'count': f('int', EDGES_GET, 'Number of ring cells (size * 4).', source=EDGES),
        'reason': f('String', EDGES_GET, 'Ring outcome: ring, invalid_size.', source=EDGES),
    }

    entries = [
        ('N2062', 'SourceBuildingItemDumpState.source_drill_dump_step_state', 'source_drill_dump_step_state', BUILD, 'mindustry.entities.comp.BuildingComp', 'dump', n2062_inputs, n2062_outputs, [DUMP_SIG, DUMP_GUARD, DUMP_CDUMP, DUMP_OTHER, DUMP_ACCEPT, DUMP_HANDLE, DUMP_REMOVE, DUMP_INCREMENT]),
        ('N2063', 'SourceBuildingItemDumpState.source_drill_dump_any_step_state', 'source_drill_dump_any_step_state', BUILD, 'mindustry.entities.comp.BuildingComp', 'dump', n2063_inputs, n2063_outputs, [DUMP_NULL, DUMP_GUARD, DUMP_CDUMP, DUMP_OTHER, DUMP_ANY_ACCEPT, DUMP_ANY_HANDLE, DUMP_ANY_REMOVE, DUMP_INCREMENT]),
        ('N2064', 'SourceBlockGeometry.source_block_proximity_cells_state', 'source_block_proximity_cells_state', EDGES, 'mindustry.world.Edges', 'getEdges', n2064_inputs, n2064_outputs, [EDGES_BOT, EDGES_TOP, EDGES_BOTTOM, EDGES_TOP_PT, EDGES_LEFT, EDGES_RIGHT, EDGES_SORT, EDGES_GET]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed drill dump step and proximity ring.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed drill dump step; the result reports the receiving belt and the updated queues.'))
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
