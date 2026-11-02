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
