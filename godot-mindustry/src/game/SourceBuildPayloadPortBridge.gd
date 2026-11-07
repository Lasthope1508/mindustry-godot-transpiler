extends "res://src/game/SourceUnitPayloadPortBridge.gd"

const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_build_payload_draw_state_script := preload("res://src/game/SourceBuildPayloadDrawState.gd")
const source_build_payload_lifecycle_state := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")

func source_build_payload_block_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.block_state(build_block)

func generated_build_payload_block_bridge_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_block_bridge_state(build_block)

func source_build_payload_constructor_block_team_state(block: Variant, team: Variant) -> Dictionary:
	return source_build_payload_state.constructor_block_team_state(block, team)

func generated_build_payload_constructor_block_team_bridge_state(block: Variant, team: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_constructor_block_team_bridge_state(block, team)

func source_build_payload_constructor_build_state(build: Variant) -> Dictionary:
	return source_build_payload_state.constructor_build_state(build)

func generated_build_payload_constructor_build_bridge_state(build: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_constructor_build_bridge_state(build)

func source_build_payload_content_equals_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	return source_build_payload_state.content_equals_state(other_is_build_payload, other_block, build_block)

func generated_build_payload_content_equals_bridge_state(other_is_build_payload: bool, other_block: Variant, build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_content_equals_bridge_state(other_is_build_payload, other_block, build_block)

func source_build_payload_content_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.content_state(build_block)

func generated_build_payload_content_bridge_state(build_block: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_content_bridge_state(build_block)

func source_build_payload_build_time_state(build_time: float) -> Dictionary:
	return source_build_payload_state.build_time_state(build_time)

func generated_build_payload_build_time_bridge_state(build_time: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_build_time_bridge_state(build_time)

func source_build_payload_requirements_state(requirements: Variant) -> Dictionary:
	return source_build_payload_state.requirements_state(requirements)

func generated_build_payload_requirements_bridge_state(requirements: Variant) -> Dictionary:
	return source_build_payload_state.generated_build_payload_requirements_bridge_state(requirements)

func source_build_payload_x_state(build_x: float) -> Dictionary:
	return source_build_payload_state.x_state(build_x)

func generated_build_payload_x_bridge_state(build_x: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_x_bridge_state(build_x)

func source_build_payload_y_state(build_y: float) -> Dictionary:
	return source_build_payload_state.y_state(build_y)

func generated_build_payload_y_bridge_state(build_y: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_y_bridge_state(build_y)

func source_build_payload_size_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	return source_build_payload_state.size_state(build_block_size, source_tilesize)

func generated_build_payload_size_bridge_state(build_block_size: float, source_tilesize: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_size_bridge_state(build_block_size, source_tilesize)

func generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_size_source_tilesize_default_bridge_state(build_block_size)

func source_build_payload_write_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	return source_build_payload_state.write_state(payload_block, build_block_id, build_version)

func generated_build_payload_write_bridge_state(payload_block: int, build_block_id: int, build_version: int) -> Dictionary:
	return source_build_payload_state.generated_build_payload_write_bridge_state(payload_block, build_block_id, build_version)

func source_build_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_build_payload_state.set_state(x, y, rotation_value)

func generated_build_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_build_payload_state.generated_build_payload_set_bridge_state(x, y, rotation_value)

func source_build_payload_place_default_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.place_default_state(tile, build_block, build_team)

func generated_build_payload_place_default_bridge_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)

func source_build_payload_place_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	return source_build_payload_lifecycle_state.place_state(tile, build_block, build_team, rotation_value)

func generated_build_payload_place_bridge_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)

func source_build_payload_update_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func generated_build_payload_update_bridge_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)

func source_build_payload_destroyed_state() -> Dictionary:
	return source_build_payload_lifecycle_state.destroyed_state()

func generated_build_payload_destroyed_bridge_state() -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_destroyed_bridge_state()

func source_build_payload_remove_state() -> Dictionary:
	return source_build_payload_lifecycle_state.remove_state()

func generated_build_payload_remove_bridge_state() -> Dictionary:
	return source_build_payload_lifecycle_state.generated_build_payload_remove_bridge_state()

func source_build_payload_draw_shadow_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	return source_build_payload_draw_state_script.draw_shadow_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func generated_build_payload_draw_shadow_bridge_state(build_x: float, build_y: float, build_block_size: float, source_tilesize: float, alpha: float) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_draw_shadow_bridge_state(build_x, build_y, build_block_size, source_tilesize, alpha)

func source_build_payload_draw_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	return source_build_payload_draw_state_script.draw_state(prev_z, layer_flying_unit_low, transform_z)

func generated_build_payload_draw_bridge_state(prev_z: float, layer_flying_unit_low: float, transform_z: float) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_draw_bridge_state(prev_z, layer_flying_unit_low, transform_z)

func source_build_payload_icon_state(full_icon: Variant) -> Dictionary:
	return source_build_payload_draw_state_script.icon_state(full_icon)

func generated_build_payload_icon_bridge_state(full_icon: Variant) -> Dictionary:
	return source_build_payload_draw_state_script.generated_build_payload_icon_bridge_state(full_icon)
