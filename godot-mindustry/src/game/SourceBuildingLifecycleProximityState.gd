extends RefCounted
class_name SourceBuildingLifecycleProximityState

const source_block_plan_geometry_state := preload("res://src/game/SourceBlockPlanGeometryState.gd")

# Providers return actual Building references and their persistent proximity arrays.
# Domain hooks (including power/noSleep) run through the caller's real lifecycle.
static func source_apply_remove_from_proximity(building: Object, block_size: int, tile_x: int, tile_y: int, world_build: Callable, proximity_for: Callable, on_proximity_removed: Callable, on_proximity_update: Callable) -> void:
	on_proximity_removed.call(building)
	var nearby: Array = []
	for point in source_block_plan_geometry_state.edge_points_state(block_size):
		var other: Variant = world_build.call(tile_x + point.x, tile_y + point.y)
		if other != null and not nearby.has(other):
			nearby.append(other)
	for other in nearby:
		var other_proximity: Array = proximity_for.call(other)
		other_proximity.erase(building)
		on_proximity_update.call(other)
	var proximity: Array = proximity_for.call(building)
	proximity.clear()

static func source_apply_update_proximity(building: Object, block_size: int, tile_x: int, tile_y: int, world_build: Callable, proximity_for: Callable, team_for: Callable, on_proximity_added: Callable, on_proximity_update: Callable, recache: Callable, headless: bool, draw_cached: bool) -> void:
	var nearby: Array = []
	var proximity: Array = proximity_for.call(building)
	proximity.clear()
	var team: Object = team_for.call(building)
	for point in source_block_plan_geometry_state.edge_points_state(block_size):
		var other: Variant = world_build.call(tile_x + point.x, tile_y + point.y)
		if other == null or not is_same(team_for.call(other), team):
			continue
		var other_proximity: Array = proximity_for.call(other)
		if not other_proximity.has(building):
			other_proximity.append(building)
		if not nearby.has(other):
			nearby.append(other)
	for other in nearby:
		proximity.append(other)
	on_proximity_added.call(building)
	on_proximity_update.call(building)
	for other in nearby:
		on_proximity_update.call(other)
	if not headless and draw_cached:
		recache.call(building)

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_building_lifecycle_source_text_state := preload("res://src/game/SourceBuildingLifecycleSourceTextState.gd")
const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_GENERATED_OWNER
const SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_JAVA_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_JAVA_METHOD
const SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_GENERATED_OWNER := source_building_lifecycle_source_text_state.SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_GENERATED_OWNER
const SOURCE_BUILDING_UPDATE_PROXIMITY_METHOD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_METHOD
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_CLEAR := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_CLEAR
const SOURCE_BUILDING_UPDATE_PROXIMITY_PROXIMITY_CLEAR := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_PROXIMITY_CLEAR
const SOURCE_BUILDING_UPDATE_PROXIMITY_EDGES := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_EDGES
const SOURCE_BUILDING_UPDATE_PROXIMITY_WORLD_BUILD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_WORLD_BUILD
const SOURCE_BUILDING_UPDATE_PROXIMITY_TEAM_GUARD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_TEAM_GUARD
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_UNIQUE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_UNIQUE
const SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_ADD := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_TMP_ADD
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_SELF := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_ADD_SELF
const SOURCE_BUILDING_UPDATE_PROXIMITY_ADDED := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_ADDED
const SOURCE_BUILDING_UPDATE_PROXIMITY_UPDATE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_UPDATE
const SOURCE_BUILDING_UPDATE_PROXIMITY_OTHER_UPDATE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_OTHER_UPDATE
const SOURCE_BUILDING_UPDATE_PROXIMITY_RECACHE := source_building_lifecycle_source_text_state.SOURCE_BUILDING_UPDATE_PROXIMITY_RECACHE

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func generated_remove_from_proximity_bridge_state(nearby_count: int, removable_count: int) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_JAVA_METHOD, [nearby_count, removable_count])
	var canonical = remove_from_proximity_state(nearby_count, removable_count)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_REMOVE_FROM_PROXIMITY_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_REMOVE_FROM_PROXIMITY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_update_proximity_bridge_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_JAVA_METHOD, [nearby_count, same_team_count, headless, draw_cached])
	var canonical = update_proximity_state(nearby_count, same_team_count, headless, draw_cached)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_UPDATE_PROXIMITY_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_UPDATE_PROXIMITY_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_on_nearby_build_added_bridge_state(other_state: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_JAVA_METHOD, [other_state])
	var canonical = on_nearby_build_added_state(other_state)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ON_NEARBY_BUILD_ADDED_STATE,
		"generated_owner": SOURCE_BUILDING_LIFECYCLE_ON_NEARBY_BUILD_ADDED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func remove_from_proximity_state(nearby_count: int, removable_count: int) -> Dictionary:
	return {
		"method": "public void removeFromProximity(){",
		"on_proximity_removed_call": "onProximityRemoved();",
		"tmp_tiles_clear_call": "tmpTiles.clear();",
		"edges_get_call": "Point2[] nearby = Edges.getEdges(block.size);",
		"world_build_call": "Building other = world.build(tile.x + point.x, tile.y + point.y);",
		"tmp_tiles_add_call": "tmpTiles.add(other);",
		"remove_self_call": "other.proximity.remove(self(), true);",
		"other_update_call": "other.onProximityUpdate();",
		"proximity_clear_call": "proximity.clear();",
		"on_proximity_removed": true,
		"tmp_tiles_cleared": true,
		"nearby_count": nearby_count,
		"queued_removals": clampi(removable_count, 0, nearby_count),
		"proximity_updates": clampi(removable_count, 0, nearby_count),
		"proximity_cleared": true,
	}

static func update_proximity_state(nearby_count: int, same_team_count: int, headless: bool, draw_cached: bool) -> Dictionary:
	return {
		"tmp_tiles_cleared": true,
		"proximity_cleared": true,
		"nearby_count": nearby_count,
		"same_team_count": clampi(same_team_count, 0, nearby_count),
		"add_unique_calls": clampi(same_team_count, 0, nearby_count),
		"on_proximity_added": true,
		"self_proximity_update": true,
		"other_proximity_updates": clampi(same_team_count, 0, nearby_count),
		"recache": (not headless) and draw_cached,
	}

static func on_nearby_build_added_state(other_state: Variant) -> Dictionary:
	return {
		"method": "public void onNearbyBuildAdded(Building other){}",
		"no_op": true,
		"other_state": other_state,
	}
