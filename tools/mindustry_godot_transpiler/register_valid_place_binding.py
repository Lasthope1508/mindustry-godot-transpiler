"""Register Build.validPlace binding (N2041-N2043)."""
import copy
import json
from pathlib import Path

from mindustry_port import source_ssot, source_symbols
from register_liquid_consumer_hydration import backed

GODOT = Path(__file__).resolve().parents[2] / 'godot-mindustry'
BUILD = 'core/src/mindustry/world/Build.java'
BLOCK = 'core/src/mindustry/world/Block.java'
TILE = 'core/src/mindustry/world/Tile.java'
TEAMS = 'core/src/mindustry/game/Teams.java'
RULES = 'core/src/mindustry/game/Rules.java'
FLOOR = 'core/src/mindustry/world/blocks/environment/Floor.java'
DRILL = 'core/src/mindustry/world/blocks/production/Drill.java'
VARS = 'core/src/mindustry/Vars.java'
PROOF = '/root/ValidPlaceProof'
TESTS = ['test_valid_place_binding_registration', 'test_all_valid_place_binding_input_evidence_is_exact', 'test_reference_graph_and_actual_valid_place']
DEFERRED = [
    'Block/Floor fields the content catalog does not export (rotate, solid, floating, requiresWater, placeableLiquid, ignoreBuildDarkness, alwaysReplace, privileged, replaceable, quickRotate, group, isFloor, isOverlay, environmentBuildable, isPlaceable, isVisible, drownTime, liquidDrop) arrive as caller-supplied block_flags/floor_flags lookup dictionaries keyed by block id; the binding applies the Java field defaults when a flag is absent.',
    'Fog discovery (fogControl.isDiscovered) and world darkness (World.getDarkness) have no runtime equivalent; they arrive as caller-supplied hooks, defaulting to undiscovered/false and 0 (no darkness data) when absent.',
    'Enemy overlap for placeRangeCheck needs the unit indexer (indexer.findEnemyTile); it arrives as a caller-supplied hook, defaulting to no overlap when absent. Unit overlap (Units.anyEntities) likewise arrives as a hook, defaulting to no overlap: the runtime has no unit system yet.',
    'ConstructBuild replacement (a build under construction of the same type) has no runtime equivalent; the footprint check evaluates it as false because no build is under construction.',
    'Superclass noSleep group membership (entity group add/remove), power/turret live hooks, controller pickup and world transitions stay open in C01.',
    'C02 inventory/offload/dump/transport and C03-C12 remain open. Existing uncommitted owner extraction dependencies still need C12 adoption.',
]

VALID_PLACE_7 = 'public static boolean validPlace(Block type, Team team, int x, int y, int rotation, boolean checkVisible, boolean checkCoreRadius){'
VALID_PLACE_IGNORE = 'public static boolean validPlaceIgnoreUnits(Block type, Team team, int x, int y, int rotation, boolean checkVisible, boolean checkCoreRadius){'
UNIT_OVERLAP = 'public static boolean checkNoUnitOverlap(Block type, int x, int y){'
TYPE_NULL = 'if(type == null || (!state.rules.editor && (checkVisible && (!type.environmentBuildable() || (!type.isPlaceable() && !(state.rules.waves && team == state.rules.waveTeam && type.isVisible())))))){'
CORE_PROTECTION = 'if(state.teams.anyEnemyCoresWithinBuildRadius(team, x * tilesize + type.offset, y * tilesize + type.offset)){'
TILE_NULL = 'if(tile == null) return false;'
CAN_PLACE_ON = 'if(!type.canPlaceOn(tile, team, rotation)){'
CAN_PLACE_ON_DEFAULT = 'public boolean canPlaceOn(Tile tile, Team team, int rotation){'
FLOOR_CHECK = 'if(type.isFloor()){'
DARKNESS = 'if(!type.ignoreBuildDarkness && world.getDarkness(x, y) >= 3){'
SHALLOWS = 'if(!type.requiresWater && !contactsShallows(tile.x, tile.y, type) && !type.placeableLiquid){'
FOOTPRINT_LOOP = 'for(int dx = 0; dx < type.size; dx++){'
CELL_NULL = 'check == null || //nothing there'
CELL_DARKNESS = '(type.size == 2 && world.getDarkness(wx, wy) >= 3) ||'
CELL_FOG = '(state.rules.staticFog && state.rules.fog && !fogControl.isDiscovered(team, wx, wy)) ||'
CELL_DEEP = '(check.floor().isDeep() && !type.floating && !type.requiresWater && !type.placeableLiquid) || //deep water'
CELL_DERELICT = '(!state.rules.derelictRepair && check.team() == Team.derelict && check.build != null) ||'
CELL_SAME = '(type == check.block() && check.build != null && rotation == check.build.rotation && type.rotate && !((type == check.block && team != Team.derelict && check.team() == Team.derelict))) || //same block, same rotation'
CELL_INTERACTABLE = '!check.interactable(team) || //cannot interact'
CELL_SOLID_FLOOR = '!check.floor().placeableOn && !type.ignoreBuildDarkness || //solid floor'
CELL_PAYLOAD = '(!checkVisible && checkCoreRadius && !check.block().alwaysReplace) || //replacing a block that should be replaced (e.g. payload placement)'
CELL_REPLACE = '!(((type.canReplace(check.block()) || (check.build != null && check.build.canBeReplaced(type)) || (type == check.block && team != Team.derelict && check.team() == Team.derelict)) || //can replace type OR can replace derelict block of same type'
CELL_BOUNDS = 'type.bounds(tile.x, tile.y, Tmp.r1).grow(0.01f).contains(check.block.bounds(check.centerX(), check.centerY(), Tmp.r2))) || //no replacement'
CELL_WATER = '(type.requiresWater && check.floor().liquidDrop != Liquids.water) //requires water but none found'
CAN_REPLACE = 'public boolean canReplace(Block other){'
CAN_INTERACT = 'public boolean canInteract(Team team, Team other){'
PLACE_RANGE = 'if(state.rules.placeRangeCheck && checkCoreRadius && !state.isEditor() && getEnemyOverlap(type, team, x, y) != null){'


def main():
    symbols = {}
    by_slice = {}

    def f(typ, expr, rule, source=BUILD, **extra):
        return backed(typ, source, expr, rule, **extra)

    # N2041: one footprint cell of validPlaceIgnoreUnits.
    n2041_inputs = {
        'game': f('Object', FOOTPRINT_LOOP, 'Actual game world containing the Tile store and placement index.'),
        'block': f('Object', FOOTPRINT_LOOP, 'Actual Block the placement is checked for; its size sets the footprint.'),
        'block_flags': f('Dictionary', CAN_REPLACE, 'Caller-supplied Block fields the catalog does not export, keyed by block id; Java field defaults apply when a flag is absent.', source=BLOCK),
        'floor_flags': f('Dictionary', CELL_DEEP, 'Caller-supplied Floor fields the catalog does not export, keyed by floor block id; Java field defaults apply when a flag is absent.'),
        'check_cell': f('Vector2i', CELL_NULL, 'Actual footprint cell being checked.'),
        'origin_cell': f('Vector2i', CELL_BOUNDS, 'Actual placement cell the new Block bounds are built from.'),
        'team_id': f('int', CELL_INTERACTABLE, 'Actual Team id placing the block; Tile.interactable and derelict checks compare against it.'),
        'rotation': f('int', CELL_SAME, 'Actual placement rotation; the same-block check compares it with the existing Building rotation.'),
        'check_visible': f('bool', CELL_PAYLOAD, 'Whether the placement comes from a visible (non-payload) path; payload placement may not replace non-alwaysReplace blocks.'),
        'check_core_radius': f('bool', CELL_PAYLOAD, 'Whether core-radius rules apply; payload placement with core radius may not replace non-alwaysReplace blocks.'),
        'rules_state': f('Dictionary', CELL_DERELICT, 'Caller-supplied Rules fields the check reads (derelictRepair, staticFog, fog); Rules.java defaults apply when a field is absent.'),
        'darkness_hook': f('Callable', CELL_DARKNESS, 'Caller-supplied World.getDarkness equivalent; defaults to 0 (no darkness data) when absent.'),
        'fog_discovered_hook': f('Callable', CELL_FOG, 'Caller-supplied fogControl.isDiscovered equivalent; only called when staticFog and fog are both true.'),
    }
    n2041_outputs = {
        'cell': f('Vector2i', CELL_NULL, 'Actual footprint cell that was checked.'),
        'valid': f('bool', CELL_NULL, 'Whether the footprint cell passes every check in the Java loop body.'),
        'reason': f('String', CELL_NULL, 'Which check failed, or empty when the cell is valid.'),
    }
    # N2042: validPlaceIgnoreUnits (pre-checks + footprint loop + place range).
    n2042_inputs = {
        'game': f('Object', VALID_PLACE_IGNORE, 'Actual game world containing the Tile store, placement index and content catalog.'),
        'block': f('Object', VALID_PLACE_IGNORE, 'Actual Block the placement is checked for.'),
        'block_flags': f('Dictionary', CAN_REPLACE, 'Caller-supplied Block fields the catalog does not export, keyed by block id; Java field defaults apply when a flag is absent.', source=BLOCK),
        'floor_flags': f('Dictionary', CELL_DEEP, 'Caller-supplied Floor fields the catalog does not export, keyed by floor block id; Java field defaults apply when a flag is absent.'),
        'team_id': f('int', VALID_PLACE_IGNORE, 'Actual Team id placing the block.'),
        'x': f('int', VALID_PLACE_IGNORE, 'Actual placement cell x.'),
        'y': f('int', VALID_PLACE_IGNORE, 'Actual placement cell y.'),
        'rotation': f('int', VALID_PLACE_IGNORE, 'Actual placement rotation.'),
        'check_visible': f('bool', VALID_PLACE_7, 'Whether the placement comes from a visible path; the visibility gate and payload replacement depend on it.'),
        'check_core_radius': f('bool', VALID_PLACE_7, 'Whether core-radius rules apply.'),
        'rules_state': f('Dictionary', TYPE_NULL, 'Caller-supplied Rules fields the check reads (editor, waves, waveTeam, derelictRepair, polygonCoreProtection, staticFog, fog, placeRangeCheck); Rules.java defaults apply when a field is absent.'),
        'cores_state': f('Dictionary', CORE_PROTECTION, 'Caller-supplied core registry (cores with cell, team and protectCores, plus build radius and tilesize) for the core-protection check.'),
        'can_place_on_hook': f('Callable', CAN_PLACE_ON, 'Caller-supplied Block.canPlaceOn equivalent; the Block default returns true when absent.'),
        'darkness_hook': f('Callable', DARKNESS, 'Caller-supplied World.getDarkness equivalent; defaults to 0 (no darkness data) when absent.'),
        'fog_discovered_hook': f('Callable', CELL_FOG, 'Caller-supplied fogControl.isDiscovered equivalent; only called when staticFog and fog are both true.'),
        'enemy_overlap_hook': f('Callable', PLACE_RANGE, 'Caller-supplied getEnemyOverlap equivalent; only called when placeRangeCheck is true, defaulting to no overlap when absent.'),
    }
    n2042_outputs = {
        'valid': f('bool', VALID_PLACE_IGNORE, 'Whether the placement passes validPlaceIgnoreUnits.'),
        'reason': f('String', VALID_PLACE_IGNORE, 'Which check failed, or empty when the placement is valid.'),
        'cell': f('Variant', FOOTPRINT_LOOP, 'The footprint cell that failed, or null when no cell failed.'),
    }
    # N2043: PortGame entry point (7-arg validPlace = ignoreUnits + unit overlap).
    n2043_inputs = {
        'block': f('Object', VALID_PLACE_7, 'Actual Block the placement is checked for.'),
        'block_flags': f('Dictionary', CAN_REPLACE, 'Caller-supplied Block fields the catalog does not export, keyed by block id.', source=BLOCK),
        'floor_flags': f('Dictionary', CELL_DEEP, 'Caller-supplied Floor fields the catalog does not export, keyed by floor block id.'),
        'team_id': f('int', VALID_PLACE_7, 'Actual Team id placing the block.'),
        'x': f('int', VALID_PLACE_7, 'Actual placement cell x.'),
        'y': f('int', VALID_PLACE_7, 'Actual placement cell y.'),
        'rotation': f('int', VALID_PLACE_7, 'Actual placement rotation.'),
        'check_visible': f('bool', VALID_PLACE_7, 'Whether the placement comes from a visible path; the 5-arg entry defaults it to true.'),
        'check_core_radius': f('bool', VALID_PLACE_7, 'Whether core-radius rules apply; the 6-arg entry defaults it to true.'),
        'rules_state': f('Dictionary', TYPE_NULL, 'Caller-supplied Rules fields the check reads.'),
        'cores_state': f('Dictionary', CORE_PROTECTION, 'Caller-supplied core registry for the core-protection check.'),
        'can_place_on_hook': f('Callable', CAN_PLACE_ON, 'Caller-supplied Block.canPlaceOn equivalent.'),
        'darkness_hook': f('Callable', DARKNESS, 'Caller-supplied World.getDarkness equivalent.'),
        'fog_discovered_hook': f('Callable', CELL_FOG, 'Caller-supplied fogControl.isDiscovered equivalent.'),
        'enemy_overlap_hook': f('Callable', PLACE_RANGE, 'Caller-supplied getEnemyOverlap equivalent.'),
        'unit_overlap_hook': f('Callable', UNIT_OVERLAP, 'Caller-supplied Units.anyEntities equivalent; defaults to no overlap when absent because the runtime has no unit system yet.'),
    }
    n2043_outputs = copy.deepcopy(n2042_outputs)

    entries = [
        ('N2041', 'SourceBlockGeometry.source_valid_place_footprint_cell_state', 'source_valid_place_footprint_cell_state', BUILD, 'mindustry.world.Build', 'validPlaceIgnoreUnits', n2041_inputs, n2041_outputs, [FOOTPRINT_LOOP, CELL_NULL, CELL_DARKNESS, CELL_FOG, CELL_DEEP, CELL_DERELICT, CELL_SAME, CELL_INTERACTABLE, CELL_SOLID_FLOOR, CELL_PAYLOAD, CELL_REPLACE, CELL_BOUNDS, CELL_WATER]),
        ('N2042', 'SourceBlockGeometry.source_valid_place_ignore_units_state', 'source_valid_place_ignore_units_state', BUILD, 'mindustry.world.Build', 'validPlaceIgnoreUnits', n2042_inputs, n2042_outputs, [VALID_PLACE_IGNORE, TYPE_NULL, CORE_PROTECTION, TILE_NULL, CAN_PLACE_ON, FLOOR_CHECK, DARKNESS, SHALLOWS, FOOTPRINT_LOOP, PLACE_RANGE]),
        ('N2043', 'PortGame.source_valid_place_state', 'source_valid_place_state', BUILD, 'mindustry.world.Build', 'validPlace', n2043_inputs, n2043_outputs, [VALID_PLACE_7, UNIT_OVERLAP]),
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
            source_symbols.upsert_source_state_schema(GODOT, name, dict(status='active', owner=owner, source_slice=sid, keys=keys, runtime_proof=PROOF, rule='Source-backed validPlace inputs; hooks and flag dictionaries must be actual source context.'))
        source_symbols.upsert_source_api_contract(GODOT, owner, dict(status='active', source_slice=sid, java_source=source, source_method=method, params=[dict(name=k, type=v['type'], schema=prefix + '_input.' + k) for k, v in inputs.items()], return_keys=list(outputs), tests=TESTS, runtime_proof=PROOF, rule='Source-backed validPlace; the result dictionary reports which check failed, with no fabricated runtime state.'))
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
