extends RefCounted
class_name SourceBuilderDrawState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_entity_comp_source_text_state := preload("res://src/game/SourceEntityCompSourceTextState.gd")
const source_builder_draw_source_text_state := preload("res://src/game/SourceBuilderDrawSourceTextState.gd")

const SOURCE_BUILDER_COMP_GENERATED_CLASS := source_entity_comp_source_text_state.SOURCE_BUILDER_COMP_GENERATED_CLASS
const SOURCE_BUILDER_DRAW_PLAN_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_METHOD
const SOURCE_BUILDER_DRAW_PLAN_JAVA_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_JAVA_METHOD
const SOURCE_BUILDER_DRAW_PLAN_GENERATED_OWNER := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_GENERATED_OWNER
const SOURCE_BUILDER_DRAW_PLAN_ANIM_SCALE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_ANIM_SCALE_EXPR
const SOURCE_BUILDER_DRAW_PLAN_BREAKING_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_BREAKING_GUARD_EXPR
const SOURCE_BUILDER_DRAW_PLAN_DRAW_BREAKING_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_DRAW_BREAKING_EXPR
const SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_CALL_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_CALL_EXPR
const SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_EXPR
const SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_VALID_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_VALID_EXPR
const SOURCE_BUILDER_DRAW_PLAN_TOP_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_METHOD
const SOURCE_BUILDER_DRAW_PLAN_TOP_JAVA_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_JAVA_METHOD
const SOURCE_BUILDER_DRAW_PLAN_TOP_GENERATED_OWNER := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_GENERATED_OWNER
const SOURCE_BUILDER_DRAW_PLAN_TOP_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_GUARD_EXPR
const SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_RESET_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_RESET_EXPR
const SOURCE_BUILDER_DRAW_PLAN_TOP_MIXCOL_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_MIXCOL_EXPR
const SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_ALPHA_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_ALPHA_EXPR
const SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_PLAN_CONFIG_TOP_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_PLAN_CONFIG_TOP_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_METHOD
const SOURCE_BUILDER_DRAW_BUILDING_JAVA_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_JAVA_METHOD
const SOURCE_BUILDER_DRAW_BUILDING_GENERATED_OWNER := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_GENERATED_OWNER
const SOURCE_BUILDER_DRAW_BUILDING_TODO_COMMENT := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_TODO_COMMENT
const SOURCE_BUILDER_DRAW_BUILDING_ACTIVE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_ACTIVE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_INACTIVE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_INACTIVE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_Z_FLYING_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_Z_FLYING_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_PLAN_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_PLAN_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_TILE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_TILE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_CORE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_CORE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_RANGE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_RANGE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_REMOTE_COMMENT := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_REMOTE_COMMENT
const SOURCE_BUILDER_DRAW_BUILDING_REMOTE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_REMOTE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_Z_PLANS_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_Z_PLANS_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_TOP_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_TOP_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_FOCUS_LEN_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_FOCUS_LEN_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_PX_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_PX_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_PY_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_PY_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_DRAW_BEAM_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_DRAW_BEAM_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_METHOD
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_JAVA_METHOD := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_JAVA_METHOD
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_GENERATED_OWNER := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_GENERATED_OWNER
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_ACTIVE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_ACTIVE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_INACTIVE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_INACTIVE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_FLYING_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_FLYING_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_PLAN_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_PLAN_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_TILE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_TILE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_RANGE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_RANGE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_SIZE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_SIZE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_XY_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_XY_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_STROKE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_STROKE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_BUILD_BEAM_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_BUILD_BEAM_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_ALPHA_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_ALPHA_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_GUARD_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_GUARD_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_SQUARE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_SQUARE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_BUILD_BEAM_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_BUILD_BEAM_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_FOCUS_SQUARE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_FOCUS_SQUARE_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_RESET_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_RESET_EXPR
const SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_RESTORE_EXPR := source_builder_draw_source_text_state.SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_RESTORE_EXPR

static func _builder_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDER_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func draw_plan_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	var plan_anim_scale: float = 1.0
	var draw_plan_valid: bool = build_valid_place or control_input_plan_matches
	var draw_breaking_call: Variant = null
	var draw_plan_call: Variant = null
	if plan_breaking:
		draw_breaking_call = {"call": SOURCE_BUILDER_DRAW_PLAN_DRAW_BREAKING_EXPR, "plan": plan}
	else:
		draw_plan_call = {"call": SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_CALL_EXPR, "plan": plan, "all_plans": all_plans, "valid": draw_plan_valid, "alpha": alpha}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_PLAN_STATE, "method": SOURCE_BUILDER_DRAW_PLAN_METHOD, "anim_scale_expr": SOURCE_BUILDER_DRAW_PLAN_ANIM_SCALE_EXPR, "breaking_guard_expr": SOURCE_BUILDER_DRAW_PLAN_BREAKING_GUARD_EXPR, "draw_breaking_expr": SOURCE_BUILDER_DRAW_PLAN_DRAW_BREAKING_EXPR, "draw_plan_expr": SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_EXPR, "draw_plan_valid_expr": SOURCE_BUILDER_DRAW_PLAN_DRAW_PLAN_VALID_EXPR, "plan": plan, "all_plans": all_plans, "plan_breaking": plan_breaking, "alpha": alpha, "build_valid_place": build_valid_place, "control_input_plan_matches": control_input_plan_matches, "plan_anim_scale": plan_anim_scale, "draw_plan_valid": draw_plan_valid, "draw_breaking_call": draw_breaking_call, "draw_plan_call": draw_plan_call}

static func draw_plan_top_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	var draw_top: bool = not plan_breaking
	var mixcol_alpha: float = 0.24 + mathf_absin_time_global_6_0_28
	var draw_reset_called: bool = draw_top
	var draw_alpha_call: Variant = null
	var draw_plan_config_top_call: Variant = null
	if draw_top:
		draw_alpha_call = {"call": SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_ALPHA_EXPR, "alpha": alpha}
		draw_plan_config_top_call = {"call": SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_PLAN_CONFIG_TOP_EXPR, "plan": plan, "plans": plans}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_PLAN_TOP_STATE, "method": SOURCE_BUILDER_DRAW_PLAN_TOP_METHOD, "guard_expr": SOURCE_BUILDER_DRAW_PLAN_TOP_GUARD_EXPR, "draw_reset_expr": SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_RESET_EXPR, "mixcol_expr": SOURCE_BUILDER_DRAW_PLAN_TOP_MIXCOL_EXPR, "draw_alpha_expr": SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_ALPHA_EXPR, "draw_plan_config_top_expr": SOURCE_BUILDER_DRAW_PLAN_TOP_DRAW_PLAN_CONFIG_TOP_EXPR, "plan": plan, "plans": plans, "plan_breaking": plan_breaking, "alpha": alpha, "mathf_absin_time_global_6_0_28": mathf_absin_time_global_6_0_28, "draw_top": draw_top, "mixcol_alpha": mixcol_alpha, "draw_reset_called": draw_reset_called, "draw_alpha_call": draw_alpha_call, "draw_plan_config_top_call": draw_plan_config_top_call}

static func draw_building_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	var inactive_without_last_active: bool = not active and last_active == null
	var plan: Variant = build_plan if active else last_active
	var outside_range_blocked: bool = not tile_exists or not within_plan
	var remote_plan_draw: bool = false
	var z_flying_unit_call: Variant = null
	var z_plans_call: Variant = null
	var draw_plan_call: Variant = null
	var draw_plan_top_call: Variant = null
	var z_restore_call: Variant = null
	var focus_len: float = type_build_beam_offset + mathf_absin_time_3_0_6
	var px: float = x + angles_trnsx_rotation_focus_len
	var py: float = y + angles_trnsy_rotation_focus_len
	var draw_building_beam_call: Variant = null
	if not inactive_without_last_active:
		z_flying_unit_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_Z_FLYING_EXPR, "layer": "Layer.flyingUnit"}
		if not outside_range_blocked:
			remote_plan_draw = core_exists and active and not is_local and not tile_block_is_construct_block and not state_is_paused
			if remote_plan_draw:
				z_plans_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_Z_PLANS_EXPR, "layer": "Layer.plans - 1f"}
				draw_plan_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_EXPR, "plan": plan, "alpha": 0.5}
				draw_plan_top_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_TOP_EXPR, "plan": plan, "alpha": 0.5}
				z_restore_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_Z_FLYING_EXPR, "layer": "Layer.flyingUnit"}
			if type_draw_build_beam:
				draw_building_beam_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_DRAW_BEAM_EXPR, "px": px, "py": py}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_BUILDING_STATE, "method": SOURCE_BUILDER_DRAW_BUILDING_METHOD, "todo_comment": SOURCE_BUILDER_DRAW_BUILDING_TODO_COMMENT, "active_expr": SOURCE_BUILDER_DRAW_BUILDING_ACTIVE_EXPR, "inactive_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_INACTIVE_GUARD_EXPR, "z_flying_expr": SOURCE_BUILDER_DRAW_BUILDING_Z_FLYING_EXPR, "plan_expr": SOURCE_BUILDER_DRAW_BUILDING_PLAN_EXPR, "tile_expr": SOURCE_BUILDER_DRAW_BUILDING_TILE_EXPR, "core_expr": SOURCE_BUILDER_DRAW_BUILDING_CORE_EXPR, "range_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_RANGE_GUARD_EXPR, "remote_comment": SOURCE_BUILDER_DRAW_BUILDING_REMOTE_COMMENT, "remote_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_REMOTE_GUARD_EXPR, "z_plans_expr": SOURCE_BUILDER_DRAW_BUILDING_Z_PLANS_EXPR, "draw_plan_expr": SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_EXPR, "draw_plan_top_expr": SOURCE_BUILDER_DRAW_BUILDING_DRAW_PLAN_TOP_EXPR, "beam_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_GUARD_EXPR, "focus_len_expr": SOURCE_BUILDER_DRAW_BUILDING_FOCUS_LEN_EXPR, "px_expr": SOURCE_BUILDER_DRAW_BUILDING_PX_EXPR, "py_expr": SOURCE_BUILDER_DRAW_BUILDING_PY_EXPR, "draw_beam_expr": SOURCE_BUILDER_DRAW_BUILDING_DRAW_BEAM_EXPR, "active": active, "last_active": last_active, "build_plan": build_plan, "plan": plan, "tile_exists": tile_exists, "core_exists": core_exists, "within_plan": within_plan, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "is_local": is_local, "tile_block_is_construct_block": tile_block_is_construct_block, "state_is_paused": state_is_paused, "type_draw_build_beam": type_draw_build_beam, "type_build_beam_offset": type_build_beam_offset, "mathf_absin_time_3_0_6": mathf_absin_time_3_0_6, "x": x, "y": y, "rotation": rotation_value, "angles_trnsx_rotation_focus_len": angles_trnsx_rotation_focus_len, "angles_trnsy_rotation_focus_len": angles_trnsy_rotation_focus_len, "inactive_without_last_active": inactive_without_last_active, "z_flying_unit_call": z_flying_unit_call, "outside_range_blocked": outside_range_blocked, "remote_plan_draw": remote_plan_draw, "z_plans_call": z_plans_call, "draw_plan_call": draw_plan_call, "draw_plan_top_call": draw_plan_top_call, "z_restore_call": z_restore_call, "focus_len": focus_len, "px": px, "py": py, "draw_building_beam_call": draw_building_beam_call}

static func draw_building_beam_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	var inactive_without_last_active: bool = not active and last_active == null
	var plan: Variant = build_plan if active else last_active
	var outside_range_blocked: bool = not tile_exists or not within_plan
	var size: int = tile_block_size if plan_breaking and active else last_size if plan_breaking else plan_block_size
	var tx: float = plan_drawx
	var ty: float = plan_drawy
	var stroke_color: String = "Pal.remove" if plan_breaking else "Pal.accent"
	var z_flying_unit_call: Variant = null
	var stroke_call: Variant = null
	var z_build_beam_call: Variant = null
	var draw_alpha_call: Variant = null
	var fill_last_active_square_call: Variant = null
	var build_beam_call: Variant = null
	var focus_square_radius: float = 1.8 + mathf_absin_time_2_2_1_1
	var focus_square_rotation: float = rotation_value + 45.0
	var focus_square_call: Variant = null
	var draw_reset_call: Variant = null
	var z_restore_call: Variant = null
	if not inactive_without_last_active:
		z_flying_unit_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_FLYING_EXPR, "layer": "Layer.flyingUnit"}
		if not outside_range_blocked:
			stroke_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_STROKE_EXPR, "width": 1.0, "color": stroke_color}
			z_build_beam_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_BUILD_BEAM_EXPR, "layer": "Layer.buildBeam"}
			draw_alpha_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_ALPHA_EXPR, "alpha": build_alpha}
			if not active and not tile_build_is_construct_build:
				fill_last_active_square_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_SQUARE_EXPR, "x": plan_drawx, "y": plan_drawy, "radius": float(size) * source_tilesize / 2.0}
			build_beam_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_BUILD_BEAM_EXPR, "px": px, "py": py, "tx": tx, "ty": ty, "radius": source_tilesize * float(size) / 2.0}
			focus_square_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_FOCUS_SQUARE_EXPR, "x": px, "y": py, "radius": focus_square_radius, "rotation": focus_square_rotation}
			draw_reset_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_RESET_EXPR}
			z_restore_call = {"call": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_RESTORE_EXPR, "layer": "Layer.flyingUnit"}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_BUILDING_BEAM_STATE, "method": SOURCE_BUILDER_DRAW_BUILDING_BEAM_METHOD, "active_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_ACTIVE_EXPR, "inactive_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_INACTIVE_GUARD_EXPR, "z_flying_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_FLYING_EXPR, "plan_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_PLAN_EXPR, "tile_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_TILE_EXPR, "range_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_RANGE_GUARD_EXPR, "size_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_SIZE_EXPR, "draw_xy_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_XY_EXPR, "stroke_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_STROKE_EXPR, "z_build_beam_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_BUILD_BEAM_EXPR, "alpha_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_ALPHA_EXPR, "fill_last_active_guard_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_GUARD_EXPR, "fill_last_active_square_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_FILL_LAST_ACTIVE_SQUARE_EXPR, "build_beam_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_BUILD_BEAM_EXPR, "focus_square_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_FOCUS_SQUARE_EXPR, "draw_reset_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_DRAW_RESET_EXPR, "z_restore_expr": SOURCE_BUILDER_DRAW_BUILDING_BEAM_Z_RESTORE_EXPR, "px": px, "py": py, "active": active, "last_active": last_active, "build_plan": build_plan, "plan": plan, "tile_exists": tile_exists, "within_plan": within_plan, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "plan_breaking": plan_breaking, "tile_block_size": tile_block_size, "last_size": last_size, "plan_block_size": plan_block_size, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "build_alpha": build_alpha, "tile_build_is_construct_build": tile_build_is_construct_build, "source_tilesize": source_tilesize, "mathf_absin_time_2_2_1_1": mathf_absin_time_2_2_1_1, "rotation": rotation_value, "inactive_without_last_active": inactive_without_last_active, "outside_range_blocked": outside_range_blocked, "size": size, "tx": tx, "ty": ty, "stroke_color": stroke_color, "z_flying_unit_call": z_flying_unit_call, "stroke_call": stroke_call, "z_build_beam_call": z_build_beam_call, "draw_alpha_call": draw_alpha_call, "fill_last_active_square_call": fill_last_active_square_call, "build_beam_call": build_beam_call, "focus_square_radius": focus_square_radius, "focus_square_rotation": focus_square_rotation, "focus_square_call": focus_square_call, "draw_reset_call": draw_reset_call, "z_restore_call": z_restore_call}

static func generated_builder_comp_draw_plan_top_bridge_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	var result = _builder_comp_call(SOURCE_BUILDER_DRAW_PLAN_TOP_JAVA_METHOD, [plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28])
	var canonical = draw_plan_top_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_PLAN_TOP_STATE, "generated_owner": SOURCE_BUILDER_DRAW_PLAN_TOP_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("draw_top", null) == canonical.get("draw_top", null) and result.get("draw_plan_config_top_call", null) == canonical.get("draw_plan_config_top_call", null)}

static func generated_builder_comp_draw_plan_bridge_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	var result = _builder_comp_call(SOURCE_BUILDER_DRAW_PLAN_JAVA_METHOD, [plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches])
	var canonical = draw_plan_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_PLAN_STATE, "generated_owner": SOURCE_BUILDER_DRAW_PLAN_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("draw_breaking_call", null) == canonical.get("draw_breaking_call", null) and result.get("draw_plan_call", null) == canonical.get("draw_plan_call", null)}

static func generated_builder_comp_draw_building_bridge_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	var result = _builder_comp_call(SOURCE_BUILDER_DRAW_BUILDING_JAVA_METHOD, [active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len])
	var canonical = draw_building_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_BUILDING_STATE, "generated_owner": SOURCE_BUILDER_DRAW_BUILDING_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("remote_plan_draw", null) == canonical.get("remote_plan_draw", null) and result.get("draw_building_beam_call", null) == canonical.get("draw_building_beam_call", null)}

static func generated_builder_comp_draw_building_beam_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	var result = _builder_comp_call(SOURCE_BUILDER_DRAW_BUILDING_BEAM_JAVA_METHOD, [px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value])
	var canonical = draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_BUILDING_BEAM_STATE, "generated_owner": SOURCE_BUILDER_DRAW_BUILDING_BEAM_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("outside_range_blocked", null) == canonical.get("outside_range_blocked", null) and result.get("build_beam_call", null) == canonical.get("build_beam_call", null) and result.get("focus_square_call", null) == canonical.get("focus_square_call", null)}

static func generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool) -> Dictionary:
	var result = _builder_comp_call(SOURCE_BUILDER_DRAW_BUILDING_BEAM_JAVA_METHOD, [px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build])
	var canonical = draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_world_defaults.TILESIZE, 0.0, 0.0)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDER_DRAW_BUILDING_BEAM_STATE, "generated_owner": SOURCE_BUILDER_DRAW_BUILDING_BEAM_GENERATED_OWNER, "defaulted_arg": "source_tilesize", "source_tilesize": source_world_defaults.TILESIZE, "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("outside_range_blocked", null) == canonical.get("outside_range_blocked", null) and result.get("build_beam_call", null) == canonical.get("build_beam_call", null) and result.get("focus_square_call", null) == canonical.get("focus_square_call", null)}
