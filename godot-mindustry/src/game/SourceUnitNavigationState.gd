class_name SourceUnitNavigationState

const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")

const SOURCE_UNIT_IS_PATH_IMPASSABLE_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_IS_PATH_IMPASSABLE_METHOD
const SOURCE_UNIT_IS_PATH_IMPASSABLE_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_IS_PATH_IMPASSABLE_RETURN
const SOURCE_UNIT_CAN_LAND_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_CAN_LAND_METHOD
const SOURCE_UNIT_CAN_LAND_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_CAN_LAND_RETURN
const SOURCE_UNIT_PREF_ROTATION_METHOD := source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_METHOD
const SOURCE_UNIT_PREF_ROTATION_BUILDING_BRANCH := source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_BUILDING_BRANCH
const SOURCE_UNIT_PREF_ROTATION_MINE_BRANCH := source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_MINE_BRANCH
const SOURCE_UNIT_PREF_ROTATION_OMNI_BRANCH := source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_OMNI_BRANCH
const SOURCE_UNIT_PREF_ROTATION_RETURN := source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_RETURN

static func is_path_impassable_state(type_flying: bool, tile_x: int, tile_y: int, tile_in_bounds: bool, path_cost: int) -> Dictionary:
	return {
		"method": SOURCE_UNIT_IS_PATH_IMPASSABLE_METHOD,
		"return": SOURCE_UNIT_IS_PATH_IMPASSABLE_RETURN,
		"type_flying": type_flying,
		"tile_x": tile_x,
		"tile_y": tile_y,
		"tile_in_bounds": tile_in_bounds,
		"path_cost": path_cost,
		"impassable": not type_flying and tile_in_bounds and path_cost == -1,
	}

static func can_land_state(unit_x: float, unit_y: float, physic_size: float, on_solid_result: bool, nearby_grounded_units_count: int) -> Dictionary:
	return {
		"method": SOURCE_UNIT_CAN_LAND_METHOD,
		"return": SOURCE_UNIT_CAN_LAND_RETURN,
		"on_solid": on_solid_result,
		"unit_x": unit_x,
		"unit_y": unit_y,
		"physic_size": physic_size,
		"nearby_grounded_units_count": nearby_grounded_units_count,
		"can_land": not on_solid_result and nearby_grounded_units_count == 0,
	}

static func pref_rotation_state(actively_building: bool, rotate_to_building: bool, build_plan_angle: float, mine_tile_exists: bool, mine_tile_angle: float, moving: bool, omni_movement: bool, velocity_angle: float, current_rotation: float) -> Dictionary:
	var selected_angle := current_rotation
	var branch := "rotation"
	if actively_building and rotate_to_building:
		selected_angle = build_plan_angle
		branch = "build_plan"
	elif mine_tile_exists:
		selected_angle = mine_tile_angle
		branch = "mine_tile"
	elif moving and omni_movement:
		selected_angle = velocity_angle
		branch = "velocity"
	return {
		"method": SOURCE_UNIT_PREF_ROTATION_METHOD,
		"building_branch": SOURCE_UNIT_PREF_ROTATION_BUILDING_BRANCH,
		"mine_branch": SOURCE_UNIT_PREF_ROTATION_MINE_BRANCH,
		"omni_branch": SOURCE_UNIT_PREF_ROTATION_OMNI_BRANCH,
		"return": SOURCE_UNIT_PREF_ROTATION_RETURN,
		"branch": branch,
		"rotation": selected_angle,
	}
