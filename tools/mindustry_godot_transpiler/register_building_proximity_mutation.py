"""Register executable Building proximity and Tile pre-change primitives."""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILDING = 'core/src/mindustry/entities/comp/BuildingComp.java'
TILE = 'core/src/mindustry/world/Tile.java'
PROOF = '/root/BuildingProximityMutationProof'
TESTS = ['test_executable_lifecycle_registration', 'test_all_lifecycle_input_evidence_is_exact', 'test_reference_graph_and_actual_tile_pre_change']
DEFERRED = [
    'These are executable reference-mutation primitives, not automatic complete Main placement/removal integration.',
    'World lookup, actual persistent proximity arrays, actual Team references and domain hooks must be provided by their lifecycle owners; no empty-array/team/default hook is synthesized.',
    'BuildingComp.noSleep must bind actual sleep/group membership and count; power/turret hooks must bind their actual domain cleanup. Callback probes do not prove those integrations.',
    'Tile.changeBuild, full two-pass setBlock overlap, entity group removal/init, controller pickup/world transitions and actual event bus remain open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]


def main():
    symbols = {}

    def f(typ, expr, rule, source=BUILDING, **extra):
        return backed(typ, source, expr, rule, **extra)

    def common():
        return {
            'building': f('Object', 'other.proximity.remove(self(), true);', 'Actual Building identity; all arrays retain original object references.'),
            'block_size': f('int', 'Point2[] nearby = Edges.getEdges(block.size);', 'Actual initialized positive Block size; existing canonical edge owner supplies offsets.'),
            'tile_x': f('int', 'Building other = world.build(tile.x + point.x, tile.y + point.y);', 'Actual Building origin x, not an arbitrary clicked proxy coordinate.'),
            'tile_y': f('int', 'Building other = world.build(tile.x + point.x, tile.y + point.y);', 'Actual Building origin y.'),
            'world_build': f('Callable', 'Building other = world.build(tile.x + point.x, tile.y + point.y);', 'Actual world Building lookup returning original object or null; multiple edges may return the same entity.'),
            'proximity_for': f('Callable', 'transient Seq<Building> proximity = new Seq<>(true, 6, Building.class);', 'Returns the actual persistent mutable Array for the supplied Building; a copy would violate this contract.'),
        }

    definitions = [
        ('N2026', 'SourceBuildingLifecycleProximityState.source_apply_remove_from_proximity', 'source_apply_remove_from_proximity_input', BUILDING, 'removeFromProximity', {
            **common(),
            'on_proximity_removed': f('Callable', 'onProximityRemoved();', 'Call the actual domain hook once before collecting adjacent Building identities; power removal belongs to that hook.'),
            'on_proximity_update': f('Callable', 'other.onProximityUpdate();', 'Call once per unique adjacent entity after unlink, including other teams. Own proximity clears only after those hooks.'),
        }, ['onProximityRemoved();', 'other.proximity.remove(self(), true);', 'other.onProximityUpdate();', 'proximity.clear();']),
        ('N2027', 'SourceBuildingLifecycleProximityState.source_apply_update_proximity', 'source_apply_update_proximity_input', BUILDING, 'updateProximity', {
            **common(),
            'team_for': f('Callable', 'if(other == null || other.team != team) continue;', 'Returns actual Team object; filter by reference identity, never infer from sprite or accept missing teams.'),
            'on_proximity_added': f('Callable', 'onProximityAdded();', 'Actual hook after complete graph construction; no power implementation is synthesized.'),
            'on_proximity_update': f('Callable', 'onProximityUpdate();', 'Self hook then one hook per unique same-team neighbor; actual noSleep/domain integration remains caller owned.'),
            'recache': f('Callable', 'if(!headless && block.drawCached) recache();', 'Actual recache hook after proximity hooks when source guard is true.'),
            'headless': f('bool', 'if(!headless && block.drawCached) recache();', 'Explicit actual headless context; never fabricated by primitive.'),
            'draw_cached': f('bool', 'if(!headless && block.drawCached) recache();', 'Actual initialized Block.drawCached flag.'),
        }, ['proximity.clear();', 'if(other == null || other.team != team) continue;', 'other.proximity.addUnique(self());', 'proximity.add(tile);', 'onProximityAdded();', 'onProximityUpdate();']),
        ('N2028', 'SourceBlockGeometry.source_apply_tile_pre_changed', 'source_apply_tile_pre_changed_input', TILE, 'preChanged', {
            'self_tile': f('Dictionary', 'if(other != this){', 'Actual canonical mutation Tile by reference; excluded from old-footprint resets until changeBuild.', TILE),
            'build': f('Object', 'if(build != null){', 'Actual previous Building or null; proxy mutation must retain old Building identity.', TILE),
            'block_is_multiblock': f('bool', 'if(build.block.isMultiblock()){', 'Actual old Building block predicate, not the new block or clicked proxy geometry.', TILE),
            'block_size': f('int', 'int size = build.block.size;', 'Actual old Building size.', TILE),
            'size_offset': f('int', 'int offsetx = -(size - 1) / 2;', 'Actual old initialized footprint offset, supplied from canonical Block geometry owner.', TILE),
            'old_build_center': f('Vector2i', 'int cx = build.tileX(), cy = build.tileY();', 'Actual old Building center; a proxy mutation must not center its reset on the proxy.', TILE),
            'world_tile_lookup': f('Callable', 'Tile other = world.tile(cx + dx + offsetx, cy + dy + offsety);', 'Actual nullable Tile lookup; existing linked footprint owner preserves bounds and source dx/dy order.', TILE),
            'air_block': f('Object', 'other.block = Blocks.air;', 'Canonical resolved Blocks.air object; no string content substitute is assigned.', TILE),
            'world_generating': f('bool', 'if(!world.isGenerating()){', 'Actual generation phase used by the existing canonical event plan; hooks and field reset still occur.', TILE),
            'on_removed': f('Callable', 'build.onRemoved();', 'Actual source domain hook once before removal from proximity and any old proxy reset.', TILE),
            'remove_from_proximity': f('Callable', 'build.removeFromProximity();', 'Actual previous Building proximity removal. Caller can compose the registered executable reference owner.', TILE),
            'fire_pre_changed': f('Callable', 'other.firePreChanged();', 'Actual event hook before each proxy assignment; self pre-event comes before Building hooks. Suppressed by generation.', TILE),
            'fire_changed': f('Callable', 'other.fireChanged();', 'Actual event hook after each proxy assignment; no synthetic queue or event bus.', TILE),
        }, ['firePreChanged();', 'build.onRemoved();', 'build.removeFromProximity();', 'int cx = build.tileX(), cy = build.tileY();', 'if(other != this){', 'other.build = null;', 'other.block = Blocks.air;']),
    ]
    for sid, owner, name, source, method, fields, exprs in definitions:
        names = []
        for key, meta in fields.items():
            meta['used_by'] = [owner]
            symbol = name + '.' + key
            names.append(symbol)
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=fields, runtime_proof=PROOF, rule='Void mutation; no fabricated result dictionary or competing persistent state. Inputs and hooks must be actual source context.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=name+'.'+k) for k,v in fields.items()], return_type='void', return_keys=[], tests=TESTS, runtime_proof=PROOF, rule='Source void mutation, verified against explicit GDScript -> void; input/owner/slice/proof checks remain mandatory. No result schema or fabricated wrapper.'))
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class='mindustry.world.Tile' if source == TILE else 'mindustry.entities.comp.BuildingComp', java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))
    # Void contracts preserve the source API shape and keep all input linkage gates.
    source_symbols.upsert_source_symbols(GODOT, symbols)
    source_symbols.write_source_symbol_audit_report(GODOT)
    manifest = json.loads((GODOT / 'src/generated/source_ssot_modules.json').read_text(encoding='utf-8'))
    modules = manifest['modules']
    new_owners = {definition[1] for definition in definitions}
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
