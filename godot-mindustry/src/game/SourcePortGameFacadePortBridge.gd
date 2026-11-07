extends "res://src/game/SourcePortGameRootStatePortBridge.gd"

const source_input_handler_state := preload("res://src/game/SourceInputHandlerState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_footprint := preload("res://src/game/SourceBlockFootprint.gd")
const source_block_placement := preload("res://src/game/SourceBlockPlacement.gd")
const source_projector_boost_state := preload("res://src/game/SourceProjectorBoostState.gd")
const source_unit_building_command_state := preload("res://src/game/SourceUnitBuildingCommandState.gd")

func source_input_handler_get_mouse_x_state(mouse_x: float) -> Dictionary:
	return source_input_handler_state.get_mouse_x_state(mouse_x)

func source_input_handler_get_mouse_y_state(mouse_y: float) -> Dictionary:
	return source_input_handler_state.get_mouse_y_state(mouse_y)

func source_input_handler_pan_camera_state(position: Vector2, locked: bool, camera_position_before: Vector2) -> Dictionary:
	return source_input_handler_state.pan_camera_state(position, locked, camera_position_before)

func source_input_handler_selected_block_state(block_present: bool) -> Dictionary:
	return source_input_handler_state.selected_block_state(block_present)

func source_input_handler_is_placing_state(block_present: bool) -> Dictionary:
	return source_input_handler_state.is_placing_state(block_present)

func source_input_handler_is_breaking_state() -> Dictionary:
	return source_input_handler_state.is_breaking_state()

func source_input_handler_mouse_angle_state(x_value: float, y_value: float, mouse_world: Vector2) -> Dictionary:
	return source_input_handler_state.mouse_angle_state(x_value, y_value, mouse_world)

func place_selected_block_at_mouse() -> void:
	place_selected_block_at_world(get_global_mouse_position())

func place_selected_block_at_cell(x: int, y: int) -> bool:
	return place_selected_block_at_world(grid_to_world(Vector2i(x, y)))

func place_selected_block_at_world(world_pos: Vector2) -> bool:
	return source_block_placement.game_place_selected_block_at_world(self, world_pos)

func add_source_block(parent: Node, block_id: String, cell: Vector2i) -> void:
	source_block_placement.add_source_block(self, parent, block_id, cell)

func add_source_block_batch(parent: Node, block_id: String, cells: Array) -> Node:
	return source_block_placement.add_source_block_batch(self, parent, block_id, cells)

func occupied_cells(cell: Vector2i, block) -> Array[Vector2i]:
	return source_block_footprint.occupied_cells(cell, block_size(block))

func can_place_block_at_cell(block, cell: Vector2i) -> bool:
	var state := source_block_placement.game_can_place_state(self, block, cell)
	return bool(state.get("can_place", false))

func boost_mend_projector_at_cell(x: int, y: int) -> bool:
	var booster_items: Dictionary = get("mend_projector_booster_items")
	var optional_efficiency: Dictionary = get("mend_projector_optional_efficiency")
	return source_projector_boost_state.apply_projector_boost_at_cell(self, x, y, source_projector_boost_state.PROJECTOR_KIND_MEND, booster_items, optional_efficiency)

func boost_overdrive_projector_at_cell(x: int, y: int) -> bool:
	var booster_items: Dictionary = get("overdrive_projector_booster_items")
	var optional_efficiency: Dictionary = get("overdrive_projector_optional_efficiency")
	return source_projector_boost_state.apply_projector_boost_at_cell(self, x, y, source_projector_boost_state.PROJECTOR_KIND_OVERDRIVE, booster_items, optional_efficiency)

func source_unit_building_get_command_position_state(class_name_value: String, source_path: String, command_position: Variant) -> Dictionary:
	return source_unit_building_command_state.command_position_state(class_name_value, source_path, command_position)

func source_unit_building_on_command_state(class_name_value: String, source_path: String, target: Variant) -> Dictionary:
	return source_unit_building_command_state.on_command_state(class_name_value, source_path, target)

func generated_unit_building_get_command_position_bridge_state(class_name_value: String, source_path: String, command_position: Variant) -> Dictionary:
	return source_unit_building_command_state.generated_command_position_bridge_state(class_name_value, source_path, command_position)

func generated_unit_building_on_command_bridge_state(class_name_value: String, source_path: String, target: Variant) -> Dictionary:
	return source_unit_building_command_state.generated_on_command_bridge_state(class_name_value, source_path, target)

func generated_state_matches_generated_subset(result: Variant, canonical: Dictionary, ignored_keys: Array = []) -> bool:
	return source_generated_class_runtime.generated_state_matches_generated_subset_ignoring_source_owner(result, canonical, ignored_keys)

func generated_state_matches_generated_subset_or_nan(result: Variant, canonical: Dictionary, nan_key: String, identity_key: String, ignored_keys: Array = []) -> bool:
	return source_generated_class_runtime.generated_state_matches_generated_subset_or_nan_ignoring_source_owner(result, canonical, nan_key, identity_key, ignored_keys)
