"""Register executable Tile changeBuild / changed / setBlock primitives."""
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
TILE = 'core/src/mindustry/world/Tile.java'
PROOF = '/root/TileChangeBuildSetBlockProof'
TESTS = ['test_executable_tile_change_build_set_block_registration', 'test_all_tile_change_build_input_evidence_is_exact', 'test_reference_graph_and_actual_tile_set_block']
DEFERRED = [
    'These are executable composition primitives, not automatic production placement or world-reload binding.',
    'Multiblock pass 0 uses a caller-bound setBlock(air) hook; full recursive proxy setBlock wiring belongs to production placement binding.',
    'Superclass noSleep, power onProximity hooks, turret unregister, controller pickup, world transitions and remaining Tile/Floor side effects stay open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

CHANGE_BUILD_METHOD = 'protected void changeBuild(Team team, Prov<Building> entityprov, int rotation){'
CHANGE_BUILD_INIT = 'build = entityprov.get().init(this, team, block.update && !state.isEditor(), rotation);'
CHANGED_METHOD = 'protected void changed(){'
SET_BLOCK_METHOD = 'public void setBlock(Block type, Team team, int rotation, Prov<Building> entityprov){'


def main():
    symbols = {}

    def f(typ, expr, rule, source=TILE, **extra):
        return backed(typ, source, expr, rule, **extra)

    definitions = [
        ('N2029', 'SourceBlockGeometry.source_apply_tile_change_build', 'source_apply_tile_change_build_input', TILE, 'changeBuild', {
            'self_tile': f('Dictionary', CHANGE_BUILD_METHOD, 'Actual mutation Tile by reference; old build is cleared and the new build is assigned on it.'),
            'old_build': f('Object', 'if(build != null){', 'Actual previous Building or null; removal and edge collection happen only when present.'),
            'old_block_size': f('int', 'int size = build.block.size;', 'Actual old Building block size for the canonical edge owner.'),
            'new_block_has_building': f('bool', 'if(block.hasBuilding()){', 'Actual new Block predicate; no Building is created when false.'),
            'new_block_update': f('bool', CHANGE_BUILD_INIT, 'Actual new Block.update flag; init_update is block.update && !state.isEditor().'),
            'team': f('Variant', CHANGE_BUILD_INIT, 'Actual Team passed to the new Building init.'),
            'rotation': f('int', CHANGE_BUILD_INIT, 'Actual normalized rotation passed to the new Building init.'),
            'editor_state': f('bool', CHANGE_BUILD_INIT, 'Actual state.isEditor(); init_update is false in the editor.'),
            'world_build': f('Callable', 'Building other = world.build(x + edge.x, y + edge.y);', 'Actual world Building lookup returning the original object or null; multiple edges may return the same entity.'),
            'remove_build': f('Callable', 'build.remove();', 'Actual old Building removal, called once before its Tile build is cleared.'),
            'update_proximity': f('Callable', 't.updateProximity();', 'Actual proximity update, called once per unique edge Building after removal.'),
            'entity_provider': f('Callable', CHANGE_BUILD_INIT, 'Actual entityprov.get(); returns the uninitialized new Building.'),
            'entity_init': f('Callable', CHANGE_BUILD_INIT, 'Actual Building.init(this, team, block.update && !state.isEditor(), rotation); returns the initialized Building.'),
        }, ['protected void changeBuild(Team team, Prov<Building> entityprov, int rotation){', 'if(build != null){', 'int size = build.block.size;', 'build.remove();', 'tileSet.clear();', 'for(Point2 edge : Edges.getEdges(size)){', 'Building other = world.build(x + edge.x, y + edge.y);', 'tileSet.add(other);', 'for(Building t : tileSet){', 't.updateProximity();', 'if(block.hasBuilding()){', 'build = entityprov.get().init(this, team, block.update && !state.isEditor(), rotation);']),
        ('N2030', 'SourceBlockGeometry.source_apply_tile_changed', 'source_apply_tile_changed_input', TILE, 'changed', {
            'self_tile': f('Dictionary', CHANGED_METHOD, 'Actual mutation Tile by reference; its build decides the proximity branch.'),
            'world_generating': f('bool', 'if(!world.isGenerating()){', 'Actual generation phase; proximity work and the change event are gated on it.'),
            'block_static': f('bool', 'if(block.isStatic()){', 'Actual new Block static predicate for the recache call.'),
            'world_build': f('Callable', 'Building tile = world.build(x + p.x, y + p.y);', 'Actual world Building lookup for the Geometry.d4 neighbours.'),
            'd4_offsets': f('Array', 'for(Point2 p : Geometry.d4){', 'Actual Geometry.d4 offsets in Arc order (1,0), (0,1), (-1,0), (0,-1); never a guessed neighbour set.'),
            'neighbor_changing': f('Callable', 'if(tile != null && !tile.tile.changing){', 'Actual neighbour tile changing flag; changing neighbours receive no proximity update.'),
            'update_proximity': f('Callable', 'build.updateProximity();', 'Actual own-Building proximity update when a build is present.'),
            'on_proximity_update': f('Callable', 'tile.onProximityUpdate();', 'Actual neighbour proximity update hook.'),
            'fire_changed': f('Callable', 'fireChanged();', 'Actual change event hook; suppressed while generating by the canonical event gate.'),
            'recache': f('Callable', 'recache();', 'Actual Tile recache hook for a static Block.'),
        }, ['protected void changed(){', 'if(!world.isGenerating()){', 'build.updateProximity();', 'for(Point2 p : Geometry.d4){', 'Building tile = world.build(x + p.x, y + p.y);', 'if(tile != null && !tile.tile.changing){', 'tile.onProximityUpdate();', 'fireChanged();', 'if(block.isStatic()){', 'recache();']),
        ('N2031', 'SourceBlockGeometry.source_apply_tile_set_block', 'source_apply_tile_set_block_input', TILE, 'setBlock', {
            'self_tile': f('Dictionary', SET_BLOCK_METHOD, 'Actual mutation Tile by reference; changing, block and build are mutated on it in source order.'),
            'type_value': f('Variant', 'this.block = type;', 'Actual new Block assigned to the mutation Tile.'),
            'team_value': f('Variant', 'if(type.forceTeam != null) team = type.forceTeam;', 'Actual requested Team, replaced by the new Block forceTeam when present.'),
            'rotation_value': f('int', 'changeBuild(team, entityprov, (byte)Mathf.mod(rotation, 4));', 'Actual requested rotation; normalized with posmod 4 before changeBuild.'),
            'type_static': f('bool', 'if(type.isStatic() || this.block.isStatic()){', 'Actual new Block static predicate for the opening recache guard.'),
            'previous_block_static': f('bool', 'if(type.isStatic() || this.block.isStatic()){', 'Actual previous Block static predicate for the opening recache guard.'),
            'force_team_present': f('bool', 'if(type.forceTeam != null) team = type.forceTeam;', 'Whether the new Block carries a forceTeam; the team is only replaced when present.'),
            'force_team_value': f('Variant', 'if(type.forceTeam != null) team = type.forceTeam;', 'Actual new Block forceTeam value.'),
            'world_generating': f('bool', 'if(!world.isGenerating()){', 'Actual generation phase used by the composed preChanged and changed primitives.'),
            'previous_build': f('Object', 'if(build != null){', 'Actual previous Building on the mutation Tile or null; retained through preChanged and removed by changeBuild.'),
            'previous_build_multiblock': f('bool', 'if(build.block.isMultiblock()){', 'Actual old Building block predicate for the preChanged footprint.'),
            'previous_block_size': f('int', 'int size = build.block.size;', 'Actual old Building block size.'),
            'size_offset': f('int', 'int offsetx = -(size - 1) / 2;', 'Actual old initialized footprint offset from the canonical Block geometry owner.'),
            'old_build_center': f('Vector2i', 'int cx = build.tileX(), cy = build.tileY();', 'Actual old Building center; a proxy mutation must not center its reset on the proxy.'),
            'world_tile_lookup': f('Callable', 'Tile other = world.tile(cx + dx + offsetx, cy + dy + offsety);', 'Actual nullable Tile lookup; each multiblock pass looks up fresh in source dx/dy order.'),
            'world_build': f('Callable', 'Building other = world.build(x + edge.x, y + edge.y);', 'Actual world Building lookup for the composed changeBuild and changed primitives.'),
            'air_block': f('Object', 'other.block = Blocks.air;', 'Canonical resolved Blocks.air object; no string content substitute is assigned.'),
            'on_removed': f('Callable', 'build.onRemoved();', 'Actual source domain hook once before removal from proximity and any old proxy reset.'),
            'remove_from_proximity': f('Callable', 'build.removeFromProximity();', 'Actual previous Building proximity removal. Caller can compose the registered executable reference owner.'),
            'remove_build': f('Callable', 'build.remove();', 'Actual old Building removal inside the composed changeBuild.'),
            'fire_pre_changed': f('Callable', 'firePreChanged();', 'Actual pre-change event hook; suppressed by generation.'),
            'fire_changed': f('Callable', 'fireChanged();', 'Actual change event hook; suppressed by generation.'),
            'new_block_has_building': f('bool', 'if(block.hasBuilding()){', 'Actual new Block predicate for the composed changeBuild.'),
            'new_block_update': f('bool', CHANGE_BUILD_INIT, 'Actual new Block.update flag for the composed changeBuild init.'),
            'editor_state': f('bool', CHANGE_BUILD_INIT, 'Actual state.isEditor() for the composed changeBuild init.'),
            'update_proximity': f('Callable', 't.updateProximity();', 'Actual proximity update used by the composed changeBuild and changed primitives.'),
            'on_proximity_update': f('Callable', 'tile.onProximityUpdate();', 'Actual neighbour proximity update hook used by the composed changed primitive.'),
            'entity_provider': f('Callable', CHANGE_BUILD_INIT, 'Actual entityprov.get(); returns the uninitialized new Building.'),
            'entity_init': f('Callable', CHANGE_BUILD_INIT, 'Actual Building.init(this, team, block.update && !state.isEditor(), rotation); returns the initialized Building.'),
            'build_team': f('Callable', 'build.team(team);', 'Actual new Building team assignment after changeBuild.'),
            'd4_offsets': f('Array', 'for(Point2 p : Geometry.d4){', 'Actual Geometry.d4 offsets in Arc order for the composed changed primitive.'),
            'neighbor_changing': f('Callable', 'if(tile != null && !tile.tile.changing){', 'Actual neighbour tile changing flag for the composed changed primitive.'),
            'recache': f('Callable', 'recache();', 'Actual Tile recache hook for the static guard and the composed changed primitive.'),
            'recache_wall': f('Callable', 'recacheWall();', 'Actual Tile wall recache hook for the static guard.'),
            'set_block_air': f('Callable', 'other.setBlock(Blocks.air);', 'Caller-bound setBlock(Blocks.air) for multiblock pass 0; full recursive proxy wiring belongs to production placement binding.'),
            'new_block_multiblock': f('bool', 'if(block.isMultiblock()){', 'Actual new Block multiblock predicate for the two-pass proxy assignment.'),
            'new_block_size': f('int', 'int offset = -(block.size - 1) / 2;', 'Actual new Block size for the two-pass footprint.'),
            'block_changed': f('Callable', 'block.blockChanged(this);', 'Actual new Block blockChanged hook after changing is reset.'),
        }, ['public void setBlock(Block type, Team team, int rotation, Prov<Building> entityprov){', 'changing = true;', 'if(type.isStatic() || this.block.isStatic()){', 'recache();', 'recacheWall();', 'if(type.forceTeam != null) team = type.forceTeam;', 'preChanged();', 'this.block = type;', 'changeBuild(team, entityprov, (byte)Mathf.mod(rotation, 4));', 'build.team(team);', 'if(block.isMultiblock()){', 'other.setBlock(Blocks.air);', 'other.build = entity;', 'other.block = block;', 'changed();', 'changing = false;', 'block.blockChanged(this);']),
    ]
    for sid, owner, name, source, method, fields, exprs in definitions:
        names = []
        for key, meta in fields.items():
            meta['used_by'] = [owner]
            symbol = name + '.' + key
            names.append(symbol)
            symbols[symbol] = dict(status='source-backed', godot_owner=owner, godot_symbol=symbol, java_source=meta['java_source'], java_method=method, java_expr=meta['java_expr'], rule=meta['rule'], tests=TESTS, runtime_proof=PROOF)
        source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=fields, runtime_proof=PROOF, rule='Void mutation; no fabricated result dictionary or competing persistent state. Inputs and hooks must be actual source context.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=name+'.'+k) for k, v in fields.items()], return_type='void', return_keys=[], tests=TESTS, runtime_proof=PROOF, rule='Source void mutation, verified against explicit GDScript -> void; input/owner/slice/proof checks remain mandatory. No result schema or fabricated wrapper.'))
        source_symbols.upsert_source_slice(GODOT, sid, dict(status='done', java_source=source, java_class='mindustry.world.Tile', java_method=method, godot_owner=owner, exact_exprs=exprs, source_symbols=names, tests=TESTS, runtime_proof=PROOF, deferred_exprs=DEFERRED))
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
