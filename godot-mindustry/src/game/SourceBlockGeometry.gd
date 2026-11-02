class_name SourceBlockGeometry
extends RefCounted

const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func block_world_size(block_size: int, tile_size: int) -> float:
	return float(max(source_block_defaults.SIZE_DEFAULT, block_size)) * float(tile_size)


static func block_base_position(grid_world: Vector2, block_size: int, tile_size: int) -> Vector2:
	var safe_block_size: int = max(source_block_defaults.SIZE_DEFAULT, block_size)
	var offset := float(safe_block_size - 1) * float(tile_size) * 0.5
	return grid_world + Vector2(offset, offset)


static func block_sprite_scale(texture_size: Vector2, block_size: int, tile_size: int) -> Vector2:
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	var world_size := block_world_size(block_size, tile_size)
	return Vector2(world_size / texture_size.x, world_size / texture_size.y)


static func building_hit_size(block_size_value: int, source_tilesize: float) -> float:
	return float(block_size_value) * source_tilesize

static func generated_building_hit_size_bridge_state(block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_hitSize_202", [block_size_value, source_tilesize], null)
	var canonical = building_hit_size(block_size_value, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HIT_SIZE,
		"generated_owner": "building_comp.java_method_hitSize_202",
		"result": result,
		"canonical": canonical,
	}


static func building_hitbox_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var hitbox_size: float = building_hit_size(block_size_value, source_tilesize)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HITBOX_STATE, "method": "public void hitbox(Rect out){", "set_centered_expr": "out.setCentered(x, y, block.size * tilesize, block.size * tilesize);", "hitbox_size_expr": "block.size * tilesize", "world_x": world_x, "world_y": world_y, "block_size_value": block_size_value, "source_tilesize": source_tilesize, "hitbox_size": hitbox_size, "set_centered": {"x": world_x, "y": world_y, "width": hitbox_size, "height": hitbox_size}}

static func generated_building_hitbox_bridge_state(world_x: float, world_y: float, block_size_value: int, source_tilesize: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_hitbox_219", [world_x, world_y, block_size_value, source_tilesize], null)
	var canonical = building_hitbox_state(world_x, world_y, block_size_value, source_tilesize)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_HITBOX_STATE,
		"generated_owner": "building_comp.java_method_hitbox_219",
		"result": result,
		"canonical": canonical,
	}


static func block_unit_tile_hit_size(block_size: float, tile_size: float) -> float:
	return float(block_size) * tile_size * source_block_defaults.BLOCK_UNIT_TILE_HIT_SIZE_SCALE_DEFAULT

static func tile_floor_assignment_state(type_value: Variant, previous_floor: Variant, build_present: bool) -> Dictionary:
	var same_floor: bool = type_value == previous_floor
	return {"same_floor": same_floor, "floor": previous_floor if same_floor else type_value, "build_proximity_updated": not same_floor and build_present}

# Execute the existing pre-change plan on actual Tile references. The old Building
# stays on the mutation Tile until changeBuild; all other old footprint cells reset.
static func source_apply_tile_pre_changed(self_tile: Dictionary, build: Object, block_is_multiblock: bool, block_size: int, size_offset: int, old_build_center: Vector2i, world_tile_lookup: Callable, air_block: Object, world_generating: bool, on_removed: Callable, remove_from_proximity: Callable, fire_pre_changed: Callable, fire_changed: Callable) -> void:
	if tile_fire_change_state(world_generating, fire_pre_changed)["event_fired"]:
		fire_pre_changed.call(self_tile)
	if build == null:
		return
	on_removed.call(build)
	remove_from_proximity.call(build)
	if not block_is_multiblock:
		return
	var reset_proxy := func(other: Variant) -> void:
		var plan := tile_pre_changed_state(world_generating, build != null, block_is_multiblock, [other], self_tile, fire_pre_changed, fire_changed)
		for index in range(plan["multiblock_reset_tiles"].size()):
			var reset: Dictionary = plan["multiblock_reset_tiles"][index]
			var tile: Dictionary = reset["tile"]
			var pre_call: Variant = plan["multiblock_pre_change_calls"][index]["event_call"]
			if pre_call != null:
				pre_call.call(tile)
			tile["build"] = reset["build"]
			tile["block"] = air_block
			var changed_call: Variant = plan["multiblock_changed_calls"][index]["event_call"]
			if changed_call != null:
				changed_call.call(tile)
	# Stream lookup and assignment in source dx/dy order; events may change a later Tile.
	tile_get_linked_tiles_state(block_is_multiblock, block_size, size_offset, old_build_center.x, old_build_center.y, world_tile_lookup, self_tile, reset_proxy)
