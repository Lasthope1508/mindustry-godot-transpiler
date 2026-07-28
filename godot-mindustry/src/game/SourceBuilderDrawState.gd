extends RefCounted
class_name SourceBuilderDrawState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceWorldDefaults := preload("res://src/game/SourceWorldDefaults.gd")

static func draw_plan_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	var plan_anim_scale: float = 1.0
	var draw_plan_valid: bool = build_valid_place or control_input_plan_matches
	var draw_breaking_call: Variant = null
	var draw_plan_call: Variant = null
	if plan_breaking:
		draw_breaking_call = {"call": "control.input.drawBreaking(plan);", "plan": plan}
	else:
		draw_plan_call = {"call": "plan.block.drawPlan(plan, control.input.allPlans(), Build.validPlace(...) || control.input.planMatches(plan), alpha);", "plan": plan, "all_plans": all_plans, "valid": draw_plan_valid, "alpha": alpha}
	return {"source_owner": "PortGame.source_builder_draw_plan_state", "method": "void drawPlan(BuildPlan plan, float alpha){", "anim_scale_expr": "plan.animScale = 1f;", "breaking_guard_expr": "if(plan.breaking){", "draw_breaking_expr": "control.input.drawBreaking(plan);", "draw_plan_expr": "plan.block.drawPlan(plan, control.input.allPlans(), Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan), alpha);", "draw_plan_valid_expr": "Build.validPlace(plan.block, team, plan.x, plan.y, plan.rotation) || control.input.planMatches(plan)", "plan": plan, "all_plans": all_plans, "plan_breaking": plan_breaking, "alpha": alpha, "build_valid_place": build_valid_place, "control_input_plan_matches": control_input_plan_matches, "plan_anim_scale": plan_anim_scale, "draw_plan_valid": draw_plan_valid, "draw_breaking_call": draw_breaking_call, "draw_plan_call": draw_plan_call}

static func draw_plan_top_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	var draw_top: bool = not plan_breaking
	var mixcol_alpha: float = 0.24 + mathf_absin_time_global_6_0_28
	var draw_reset_called: bool = draw_top
	var draw_alpha_call: Variant = null
	var draw_plan_config_top_call: Variant = null
	if draw_top:
		draw_alpha_call = {"call": "Draw.alpha(alpha);", "alpha": alpha}
		draw_plan_config_top_call = {"call": "plan.block.drawPlanConfigTop(plan, plans);", "plan": plan, "plans": plans}
	return {"source_owner": "PortGame.source_builder_draw_plan_top_state", "method": "void drawPlanTop(BuildPlan plan, float alpha){", "guard_expr": "if(!plan.breaking){", "draw_reset_expr": "Draw.reset();", "mixcol_expr": "Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));", "draw_alpha_expr": "Draw.alpha(alpha);", "draw_plan_config_top_expr": "plan.block.drawPlanConfigTop(plan, plans);", "plan": plan, "plans": plans, "plan_breaking": plan_breaking, "alpha": alpha, "mathf_absin_time_global_6_0_28": mathf_absin_time_global_6_0_28, "draw_top": draw_top, "mixcol_alpha": mixcol_alpha, "draw_reset_called": draw_reset_called, "draw_alpha_call": draw_alpha_call, "draw_plan_config_top_call": draw_plan_config_top_call}

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
		z_flying_unit_call = {"call": "Draw.z(Layer.flyingUnit);", "layer": "Layer.flyingUnit"}
		if not outside_range_blocked:
			remote_plan_draw = core_exists and active and not is_local and not tile_block_is_construct_block and not state_is_paused
			if remote_plan_draw:
				z_plans_call = {"call": "Draw.z(Layer.plans - 1f);", "layer": "Layer.plans - 1f"}
				draw_plan_call = {"call": "drawPlan(plan, 0.5f);", "plan": plan, "alpha": 0.5}
				draw_plan_top_call = {"call": "drawPlanTop(plan, 0.5f);", "plan": plan, "alpha": 0.5}
				z_restore_call = {"call": "Draw.z(Layer.flyingUnit);", "layer": "Layer.flyingUnit"}
			if type_draw_build_beam:
				draw_building_beam_call = {"call": "drawBuildingBeam(px, py);", "px": px, "py": py}
	return {"source_owner": "PortGame.source_builder_draw_building_state", "method": "public void drawBuilding(){", "todo_comment": "//TODO make this more generic so it works with builder \"weapons\"", "active_expr": "boolean active = activelyBuilding();", "inactive_guard_expr": "if(!active && lastActive == null) return;", "z_flying_expr": "Draw.z(Layer.flyingUnit);", "plan_expr": "BuildPlan plan = active ? buildPlan() : lastActive;", "tile_expr": "Tile tile = plan.tile();", "core_expr": "var core = team.core();", "range_guard_expr": "if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){", "remote_comment": "//draw remote plans.", "remote_guard_expr": "if(core != null && active && !isLocal() && !(tile.block() instanceof ConstructBlock) && !state.isPaused()){" , "z_plans_expr": "Draw.z(Layer.plans - 1f);", "draw_plan_expr": "drawPlan(plan, 0.5f);", "draw_plan_top_expr": "drawPlanTop(plan, 0.5f);", "beam_guard_expr": "if(type.drawBuildBeam){", "focus_len_expr": "float focusLen = type.buildBeamOffset + Mathf.absin(Time.time, 3f, 0.6f);", "px_expr": "float px = x + Angles.trnsx(rotation, focusLen);", "py_expr": "float py = y + Angles.trnsy(rotation, focusLen);", "draw_beam_expr": "drawBuildingBeam(px, py);", "active": active, "last_active": last_active, "build_plan": build_plan, "plan": plan, "tile_exists": tile_exists, "core_exists": core_exists, "within_plan": within_plan, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "is_local": is_local, "tile_block_is_construct_block": tile_block_is_construct_block, "state_is_paused": state_is_paused, "type_draw_build_beam": type_draw_build_beam, "type_build_beam_offset": type_build_beam_offset, "mathf_absin_time_3_0_6": mathf_absin_time_3_0_6, "x": x, "y": y, "rotation": rotation_value, "angles_trnsx_rotation_focus_len": angles_trnsx_rotation_focus_len, "angles_trnsy_rotation_focus_len": angles_trnsy_rotation_focus_len, "inactive_without_last_active": inactive_without_last_active, "z_flying_unit_call": z_flying_unit_call, "outside_range_blocked": outside_range_blocked, "remote_plan_draw": remote_plan_draw, "z_plans_call": z_plans_call, "draw_plan_call": draw_plan_call, "draw_plan_top_call": draw_plan_top_call, "z_restore_call": z_restore_call, "focus_len": focus_len, "px": px, "py": py, "draw_building_beam_call": draw_building_beam_call}

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
		z_flying_unit_call = {"call": "Draw.z(Layer.flyingUnit);", "layer": "Layer.flyingUnit"}
		if not outside_range_blocked:
			stroke_call = {"call": "Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);", "width": 1.0, "color": stroke_color}
			z_build_beam_call = {"call": "Draw.z(Layer.buildBeam);", "layer": "Layer.buildBeam"}
			draw_alpha_call = {"call": "Draw.alpha(buildAlpha);", "alpha": build_alpha}
			if not active and not tile_build_is_construct_build:
				fill_last_active_square_call = {"call": "Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);", "x": plan_drawx, "y": plan_drawy, "radius": float(size) * source_tilesize / 2.0}
			build_beam_call = {"call": "Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);", "px": px, "py": py, "tx": tx, "ty": ty, "radius": source_tilesize * float(size) / 2.0}
			focus_square_call = {"call": "Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);", "x": px, "y": py, "radius": focus_square_radius, "rotation": focus_square_rotation}
			draw_reset_call = {"call": "Draw.reset();"}
			z_restore_call = {"call": "Draw.z(Layer.flyingUnit);", "layer": "Layer.flyingUnit"}
	return {"source_owner": "PortGame.source_builder_draw_building_beam_state", "method": "public void drawBuildingBeam(float px, float py){", "active_expr": "boolean active = activelyBuilding();", "inactive_guard_expr": "if(!active && lastActive == null) return;", "z_flying_expr": "Draw.z(Layer.flyingUnit);", "plan_expr": "BuildPlan plan = active ? buildPlan() : lastActive;", "tile_expr": "Tile tile = world.tile(plan.x, plan.y);", "range_guard_expr": "if(tile == null || !within(plan, state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange)){", "size_expr": "int size = plan.breaking ? active ? tile.block().size : lastSize : plan.block.size;", "draw_xy_expr": "float tx = plan.drawx(), ty = plan.drawy();", "stroke_expr": "Lines.stroke(1f, plan.breaking ? Pal.remove : Pal.accent);", "z_build_beam_expr": "Draw.z(Layer.buildBeam);", "alpha_expr": "Draw.alpha(buildAlpha);", "fill_last_active_guard_expr": "if(!active && !(tile.build instanceof ConstructBuild)){", "fill_last_active_square_expr": "Fill.square(plan.drawx(), plan.drawy(), size * tilesize/2f);", "build_beam_expr": "Drawf.buildBeam(px, py, tx, ty, Vars.tilesize * size / 2f);", "focus_square_expr": "Fill.square(px, py, 1.8f + Mathf.absin(Time.time, 2.2f, 1.1f), rotation + 45);", "draw_reset_expr": "Draw.reset();", "z_restore_expr": "Draw.z(Layer.flyingUnit);", "px": px, "py": py, "active": active, "last_active": last_active, "build_plan": build_plan, "plan": plan, "tile_exists": tile_exists, "within_plan": within_plan, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "plan_breaking": plan_breaking, "tile_block_size": tile_block_size, "last_size": last_size, "plan_block_size": plan_block_size, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "build_alpha": build_alpha, "tile_build_is_construct_build": tile_build_is_construct_build, "source_tilesize": source_tilesize, "mathf_absin_time_2_2_1_1": mathf_absin_time_2_2_1_1, "rotation": rotation_value, "inactive_without_last_active": inactive_without_last_active, "outside_range_blocked": outside_range_blocked, "size": size, "tx": tx, "ty": ty, "stroke_color": stroke_color, "z_flying_unit_call": z_flying_unit_call, "stroke_call": stroke_call, "z_build_beam_call": z_build_beam_call, "draw_alpha_call": draw_alpha_call, "fill_last_active_square_call": fill_last_active_square_call, "build_beam_call": build_beam_call, "focus_square_radius": focus_square_radius, "focus_square_rotation": focus_square_rotation, "focus_square_call": focus_square_call, "draw_reset_call": draw_reset_call, "z_restore_call": z_restore_call}

static func generated_builder_comp_draw_plan_top_bridge_state(plan: Variant, plans: Array, plan_breaking: bool, alpha: float, mathf_absin_time_global_6_0_28: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_drawPlanTop_6", [plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28], null)
	var canonical = draw_plan_top_state(plan, plans, plan_breaking, alpha, mathf_absin_time_global_6_0_28)
	return {"source_owner": "PortGame.source_builder_draw_plan_top_state", "generated_owner": "BuilderComp.java_method_drawPlanTop_6", "result": result, "canonical": canonical, "matches": result.get("draw_top", null) == canonical.get("draw_top", null) and result.get("draw_plan_config_top_call", null) == canonical.get("draw_plan_config_top_call", null)}

static func generated_builder_comp_draw_plan_bridge_state(plan: Variant, all_plans: Array, plan_breaking: bool, alpha: float, build_valid_place: bool, control_input_plan_matches: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_drawPlan_5", [plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches], null)
	var canonical = draw_plan_state(plan, all_plans, plan_breaking, alpha, build_valid_place, control_input_plan_matches)
	return {"source_owner": "PortGame.source_builder_draw_plan_state", "generated_owner": "BuilderComp.java_method_drawPlan_5", "result": result, "canonical": canonical, "matches": result.get("draw_breaking_call", null) == canonical.get("draw_breaking_call", null) and result.get("draw_plan_call", null) == canonical.get("draw_plan_call", null)}

static func generated_builder_comp_draw_building_bridge_state(active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, core_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, is_local: bool, tile_block_is_construct_block: bool, state_is_paused: bool, type_draw_build_beam: bool, type_build_beam_offset: float, mathf_absin_time_3_0_6: float, x: float, y: float, rotation_value: float, angles_trnsx_rotation_focus_len: float, angles_trnsy_rotation_focus_len: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_drawBuilding_15", [active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len], null)
	var canonical = draw_building_state(active, last_active, build_plan, tile_exists, core_exists, within_plan, state_rules_infinite_resources, type_build_range, is_local, tile_block_is_construct_block, state_is_paused, type_draw_build_beam, type_build_beam_offset, mathf_absin_time_3_0_6, x, y, rotation_value, angles_trnsx_rotation_focus_len, angles_trnsy_rotation_focus_len)
	return {"source_owner": "PortGame.source_builder_draw_building_state", "generated_owner": "BuilderComp.java_method_drawBuilding_15", "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("remote_plan_draw", null) == canonical.get("remote_plan_draw", null) and result.get("draw_building_beam_call", null) == canonical.get("draw_building_beam_call", null)}

static func generated_builder_comp_draw_building_beam_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool, source_tilesize: float, mathf_absin_time_2_2_1_1: float, rotation_value: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_drawBuildingBeam_16", [px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value], null)
	var canonical = draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, source_tilesize, mathf_absin_time_2_2_1_1, rotation_value)
	return {"source_owner": "PortGame.source_builder_draw_building_beam_state", "generated_owner": "BuilderComp.java_method_drawBuildingBeam_16", "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("outside_range_blocked", null) == canonical.get("outside_range_blocked", null) and result.get("build_beam_call", null) == canonical.get("build_beam_call", null) and result.get("focus_square_call", null) == canonical.get("focus_square_call", null)}

static func generated_builder_comp_draw_building_beam_source_tilesize_default_bridge_state(px: float, py: float, active: bool, last_active: Variant, build_plan: Variant, tile_exists: bool, within_plan: bool, state_rules_infinite_resources: bool, type_build_range: float, plan_breaking: bool, tile_block_size: int, last_size: int, plan_block_size: int, plan_drawx: float, plan_drawy: float, build_alpha: float, tile_build_is_construct_build: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_drawBuildingBeam_16", [px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build], null)
	var canonical = draw_building_beam_state(px, py, active, last_active, build_plan, tile_exists, within_plan, state_rules_infinite_resources, type_build_range, plan_breaking, tile_block_size, last_size, plan_block_size, plan_drawx, plan_drawy, build_alpha, tile_build_is_construct_build, SourceWorldDefaults.TILESIZE, 0.0, 0.0)
	return {"source_owner": "PortGame.source_builder_draw_building_beam_state", "generated_owner": "BuilderComp.java_method_drawBuildingBeam_16", "defaulted_arg": "source_tilesize", "source_tilesize": SourceWorldDefaults.TILESIZE, "result": result, "canonical": canonical, "matches": result.get("inactive_without_last_active", null) == canonical.get("inactive_without_last_active", null) and result.get("outside_range_blocked", null) == canonical.get("outside_range_blocked", null) and result.get("build_beam_call", null) == canonical.get("build_beam_call", null) and result.get("focus_square_call", null) == canonical.get("focus_square_call", null)}
