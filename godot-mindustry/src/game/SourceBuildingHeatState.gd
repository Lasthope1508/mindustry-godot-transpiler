extends RefCounted
class_name SourceBuildingHeatState

const source_building_heat_source_text_state := preload("res://src/game/SourceBuildingHeatSourceTextState.gd")
const source_building_navigation_state := preload("res://src/game/SourceBuildingNavigationState.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func _building_present(build: Variant) -> bool:
	return build != null and (not build is Dictionary or bool(build.get("present", true)))

static func _build_value(build: Variant, key: String, fallback: Variant = null) -> Variant:
	return build.get(key, fallback) if build is Dictionary else fallback

static func calculate_heat_default_state(side_heat: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	var result := calculate_heat_state(side_heat, [], proximity, team_id, self_x, self_y, block_size, tilesize, self_id, false, update_heat_callback)
	result["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CALCULATE_HEAT_DEFAULT_STATE
	result["method"] = source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_DEFAULT_METHOD
	return result

static func calculate_heat_state(side_heat: Array, came_from: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, came_from_present: bool, update_heat_callback: Variant = null) -> Dictionary:
	for index in range(side_heat.size()):
		side_heat[index] = 0.0
	var side_heat_after: Array = side_heat
	var came_from_after: Array = came_from
	if came_from_present:
		came_from.clear()
	var heat := 0.0
	var contact_traces: Array = []
	var update_heat_calls: Array = []
	for build in proximity:
		if not _building_present(build):
			continue
		var build_team_id := int(_build_value(build, "team_id", team_id))
		var is_heat_block := bool(_build_value(build, "is_heat_block", false))
		if build_team_id != team_id or not is_heat_block:
			continue
		var is_conductor := bool(_build_value(build, "is_heat_conductor", false))
		var split_heat := is_conductor and bool(_build_value(build, "split_heat", false))
		var build_x := float(_build_value(build, "x", 0.0))
		var build_y := float(_build_value(build, "y", 0.0))
		var relative := source_building_navigation_state.relative_to_building_state(self_x, self_y, build_x, build_y)
		var rotates := bool(_build_value(build, "block_rotate", false))
		var rotation := int(_build_value(build, "rotation", 0))
		var rotation_allowed := (not rotates) or ((not split_heat and int(source_math_state.source_mod_float(float(relative + 2), 4.0)) == rotation) or (split_heat and relative != rotation))
		if not rotation_allowed:
			continue
		var building_id := int(_build_value(build, "id", 0))
		var build_came_from: Array = _build_value(build, "came_from", []) if _build_value(build, "came_from", []) is Array else []
		var already_traversed := came_from.has(building_id)
		var cycle := is_conductor and build_came_from.has(self_id)
		var add := 0.0
		var contact_points := 0
		var diff := 0.0
		var heat_value := float(_build_value(build, "heat", 0.0))
		var build_size := int(_build_value(build, "block_size", 1))
		if not cycle:
			diff = min(abs(build_x - self_x), abs(build_y - self_y)) / tilesize
			contact_points = mini(int(float(block_size) / 2.0 + float(build_size) / 2.0 - diff), mini(build_size, block_size))
			add = heat_value / float(build_size) * float(contact_points)
			if split_heat:
				add /= 3.0
			var side_index := int(source_math_state.source_mod_float(float(relative), 4.0))
			side_heat_after[side_index] = float(side_heat_after[side_index]) + add
			heat += add
		if came_from_present:
			if not already_traversed and not came_from_after.has(building_id):
				came_from_after.append(building_id)
			for ancestor in build_came_from:
				if not came_from_after.has(ancestor):
					came_from_after.append(ancestor)
		if is_conductor:
			update_heat_calls.append(building_id)
			if update_heat_callback is Callable:
				update_heat_callback.call()
		contact_traces.append({"build_id": building_id, "relative": relative, "split": split_heat, "cycle": cycle, "diff": diff, "contact_points": contact_points, "add": add})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CALCULATE_HEAT_STATE, "source": source_building_heat_source_text_state.SOURCE_BUILDING_COMP_SOURCE, "method": source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_METHOD, "side_heat": side_heat_after, "came_from": came_from_after, "heat": heat, "contact_traces": contact_traces, "update_heat_calls": update_heat_calls}

static func generated_calculate_heat_default_bridge_state(side_heat: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_building_heat_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS, source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_DEFAULT_JAVA_METHOD, [side_heat.duplicate(true), proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback])
	var canonical := calculate_heat_default_state(side_heat.duplicate(true), proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback)
	var matches := source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, ["source_owner", "method"])
	return {"generated_owner": source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_DEFAULT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_calculate_heat_bridge_state(side_heat: Array, came_from: Array, proximity: Array, team_id: int, self_x: float, self_y: float, block_size: int, tilesize: float, self_id: int, update_heat_callback: Variant = null) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_building_heat_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS, source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_JAVA_METHOD, [side_heat.duplicate(true), came_from.duplicate(true), proximity, team_id, self_x, self_y, block_size, tilesize, self_id, update_heat_callback])
	var canonical := calculate_heat_state(side_heat.duplicate(true), came_from.duplicate(true), proximity, team_id, self_x, self_y, block_size, tilesize, self_id, true, update_heat_callback)
	var matches := source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, ["source_owner", "method"])
	return {"generated_owner": source_building_heat_source_text_state.SOURCE_BUILDING_HEAT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
