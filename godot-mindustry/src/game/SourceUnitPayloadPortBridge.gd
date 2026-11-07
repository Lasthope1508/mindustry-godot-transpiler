extends "res://src/game/SourceUnitPayloadDumpPortBridge.gd"

const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_unit_payload_content_state_script := preload("res://src/game/SourceUnitPayloadContentState.gd")
const source_unit_payload_requirements_state_script := preload("res://src/game/SourceUnitPayloadRequirementsState.gd")
const source_unit_payload_io_state := preload("res://src/game/SourceUnitPayloadIoState.gd")
const source_unit_payload_draw_state := preload("res://src/game/SourceUnitPayloadDrawState.gd")

func source_unit_payload_constructor_state(unit: Variant) -> Dictionary:
	return source_unit_payload_basic_state.constructor_state(unit)

func generated_unit_payload_constructor_bridge_state(unit: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_constructor_bridge_state(unit)

func source_unit_payload_show_overlay_texture_region_state(icon: Variant) -> Dictionary:
	return source_unit_payload_basic_state.show_overlay_texture_region_state(icon)

func generated_unit_payload_show_overlay_texture_region_bridge_state(icon: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_show_overlay_texture_region_bridge_state(icon)

func source_unit_payload_show_overlay_drawable_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return source_unit_payload_basic_state.show_overlay_drawable_state(icon_null, headless, region)

func generated_unit_payload_show_overlay_drawable_bridge_state(icon_null: bool, headless: bool, region: Variant) -> Dictionary:
	return source_unit_payload_basic_state.generated_show_overlay_drawable_bridge_state(icon_null, headless, region)

func source_unit_payload_content_equals_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.content_equals_state(other_is_unit_payload, other_unit_type, unit_type)

func generated_unit_payload_content_equals_bridge_state(other_is_unit_payload: bool, other_unit_type: Variant, unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_content_equals_bridge_state(other_is_unit_payload, other_unit_type, unit_type)

func source_unit_payload_update_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.update_state(unit_type, unit, unit_holder, building_holder)

func generated_unit_payload_update_bridge_state(unit_type: Variant, unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_update_bridge_state(unit_type, unit, unit_holder, building_holder)

func source_unit_payload_content_state(unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.content_state(unit_type)

func generated_unit_payload_content_bridge_state(unit_type: Variant) -> Dictionary:
	return source_unit_payload_content_state_script.generated_content_bridge_state(unit_type)

func source_unit_payload_requirements_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	return source_unit_payload_requirements_state_script.requirements_state(unit_type, total_requirements)

func generated_unit_payload_requirements_bridge_state(unit_type: Variant, total_requirements: Variant) -> Dictionary:
	return source_unit_payload_requirements_state_script.generated_requirements_bridge_state(unit_type, total_requirements)

func source_unit_payload_build_time_state(unit_type: Variant, build_time: float) -> Dictionary:
	return source_unit_payload_requirements_state_script.build_time_state(unit_type, build_time)

func generated_unit_payload_build_time_bridge_state(unit_type: Variant, build_time: float) -> Dictionary:
	return source_unit_payload_requirements_state_script.generated_build_time_bridge_state(unit_type, build_time)

func source_unit_payload_write_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	return source_unit_payload_io_state.write_state(payload_unit, unit_class_id)

func generated_unit_payload_write_bridge_state(payload_unit: int, unit_class_id: int) -> Dictionary:
	return source_unit_payload_io_state.generated_write_bridge_state(payload_unit, unit_class_id)

func source_unit_payload_set_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_unit_payload_io_state.set_state(x, y, rotation_value)

func generated_unit_payload_set_bridge_state(x: float, y: float, rotation_value: float) -> Dictionary:
	return source_unit_payload_io_state.generated_set_bridge_state(x, y, rotation_value)

func source_unit_payload_x_state(unit_x: float) -> Dictionary:
	return source_unit_payload_io_state.x_state(unit_x)

func generated_unit_payload_x_bridge_state(unit_x: float) -> Dictionary:
	return source_unit_payload_io_state.generated_x_bridge_state(unit_x)

func source_unit_payload_y_state(unit_y: float) -> Dictionary:
	return source_unit_payload_io_state.y_state(unit_y)

func generated_unit_payload_y_bridge_state(unit_y: float) -> Dictionary:
	return source_unit_payload_io_state.generated_y_bridge_state(unit_y)

func source_unit_payload_rotation_state(unit_rotation: float) -> Dictionary:
	return source_unit_payload_io_state.rotation_state(unit_rotation)

func generated_unit_payload_rotation_bridge_state(unit_rotation: float) -> Dictionary:
	return source_unit_payload_io_state.generated_rotation_bridge_state(unit_rotation)

func source_unit_payload_size_state(unit_hit_size: float) -> Dictionary:
	return source_unit_payload_io_state.size_state(unit_hit_size)

func generated_unit_payload_size_bridge_state(unit_hit_size: float) -> Dictionary:
	return source_unit_payload_io_state.generated_size_bridge_state(unit_hit_size)

func source_unit_payload_draw_shadow_type_null_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.draw_shadow_type_null_state(unit_type_null, alpha, unit_id)

func generated_unit_payload_draw_shadow_type_null_bridge_state(unit_type_null: bool, alpha: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_shadow_type_null_bridge_state(unit_type_null, alpha, unit_id)

func source_unit_payload_draw_type_null_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_draw_state.draw_type_null_state(unit_type_null)

func generated_unit_payload_draw_type_null_bridge_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_draw_state.generated_type_null_bridge_state(unit_type_null)

func source_unit_payload_draw_elevation_setup_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.draw_elevation_setup_state(unit_type_null, unit_elevation, unit_id)

func generated_unit_payload_draw_elevation_setup_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_elevation_setup_bridge_state(unit_type_null, unit_elevation, unit_id)

func source_unit_payload_draw_overlay_warning_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	return source_unit_payload_draw_state.draw_overlay_warning_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)

func generated_unit_payload_draw_overlay_warning_bridge_state(unit_type_null: bool, unit_elevation: float, unit_id: Variant, overlay_time: float, overlay_region: Variant, unit_x: float, unit_y: float, time_delta: float, draw_z_before: float, interp_exp5_out_overlay_time: float) -> Dictionary:
	return source_unit_payload_draw_state.generated_overlay_warning_bridge_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)

func source_unit_payload_icon_state(unit_type_full_icon: Variant) -> Dictionary:
	return source_unit_payload_draw_state.icon_state(unit_type_full_icon)

func generated_unit_payload_icon_bridge_state(unit_type_full_icon: Variant) -> Dictionary:
	return source_unit_payload_draw_state.generated_icon_bridge_state(unit_type_full_icon)
