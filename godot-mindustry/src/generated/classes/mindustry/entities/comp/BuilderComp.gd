# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/BuilderComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "BuilderComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Statusc", "Teamc", "Rotc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "buildSpeedMultiplier", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "plans", "type": "Queue"}, {"modifiers": [], "name": "updateBuilding", "type": "boolean"}, {"modifiers": ["private", "transient"], "name": "buildCounter", "type": "float"}, {"modifiers": ["private", "transient"], "name": "lastActive", "type": "BuildPlan"}, {"modifiers": ["private", "transient"], "name": "lastSize", "type": "int"}, {"modifiers": ["transient"], "name": "buildAlpha", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "canBuild", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterRead", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "validatePlans", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateBuildLogic", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "drawPlan", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "drawPlanTop", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "shouldSkip", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "core", "type": "Building", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "removeBuild", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "breaking", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "isBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "clearBuilding", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addBuild", "parameters": [{"name": "place", "type": "BuildPlan", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "addBuild", "parameters": [{"name": "place", "type": "BuildPlan", "varargs": false}, {"name": "tail", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "activelyBuilding", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "buildPlan", "parameters": [], "return_type": "BuildPlan"}, {"modifiers": ["public"], "name": "drawBuilding", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawBuildingBeam", "parameters": [{"name": "px", "type": "float", "varargs": false}, {"name": "py", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_canBuild_0(_args: Array = []) -> Variant:
	var type_build_speed: float = float(_args[0] if _args.size() > 0 else 0.0)
	var build_speed_multiplier: float = float(_args[1] if _args.size() > 1 else 0.0)
	var type_build_speed_positive: bool = type_build_speed > 0
	var build_speed_multiplier_positive: bool = build_speed_multiplier > 0
	var can_build: bool = type_build_speed_positive and build_speed_multiplier_positive
	return {"source_owner": "PortGame.source_builder_can_build_state", "method": "public boolean canBuild(){", "return_expr": "return type.buildSpeed > 0 && buildSpeedMultiplier > 0;", "type_build_speed": type_build_speed, "build_speed_multiplier": build_speed_multiplier, "type_build_speed_positive": type_build_speed_positive, "build_speed_multiplier_positive": build_speed_multiplier_positive, "can_build": can_build}

func java_method_update_1(_args: Array = []) -> Variant:
	var update_build_logic_call: String = "updateBuildLogic();"
	var update_build_logic_called: bool = true
	return {"source_owner": "PortGame.source_builder_update_state", "method": "public void update(){", "update_build_logic_call": update_build_logic_call, "update_build_logic_called": update_build_logic_called}

func java_method_afterRead_2(_args: Array = []) -> Variant:
	var plans_null: bool = bool(_args[0] if _args.size() > 0 else false)
	var queue_reset: bool = plans_null
	var plans_capacity: int = 1 if queue_reset else 0
	return {"source_owner": "PortGame.source_builder_after_read_state", "method": "public void afterRead(){", "comment": "//why would this happen?", "guard_expr": "if(plans == null){", "queue_constructor": "new Queue<>(1)", "plans_null": plans_null, "queue_reset": queue_reset, "plans_capacity": plans_capacity}

func java_method_validatePlans_3(_args: Array = []) -> Variant:
	return null

func java_method_updateBuildLogic_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlan_5(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanTop_6(_args: Array = []) -> Variant:
	var plan: Variant = _args[0] if _args.size() > 0 else null
	var plans: Array = _args[1] if _args.size() > 1 and _args[1] is Array else []
	var plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)
	var alpha: float = float(_args[3] if _args.size() > 3 else 0.0)
	var mathf_absin_time_global_6_0_28: float = float(_args[4] if _args.size() > 4 else 0.0)
	var draw_top: bool = not plan_breaking
	var mixcol_alpha: float = 0.24 + mathf_absin_time_global_6_0_28
	var draw_reset_called: bool = draw_top
	var draw_alpha_call: Variant = null
	var draw_plan_config_top_call: Variant = null
	if draw_top:
		draw_alpha_call = {"call": "Draw.alpha(alpha);", "alpha": alpha}
		draw_plan_config_top_call = {"call": "plan.block.drawPlanConfigTop(plan, plans);", "plan": plan, "plans": plans}
	return {"source_owner": "PortGame.source_builder_draw_plan_top_state", "method": "void drawPlanTop(BuildPlan plan, float alpha){", "guard_expr": "if(!plan.breaking){", "draw_reset_expr": "Draw.reset();", "mixcol_expr": "Draw.mixcol(Color.white, 0.24f + Mathf.absin(Time.globalTime, 6f, 0.28f));", "draw_alpha_expr": "Draw.alpha(alpha);", "draw_plan_config_top_expr": "plan.block.drawPlanConfigTop(plan, plans);", "plan": plan, "plans": plans, "plan_breaking": plan_breaking, "alpha": alpha, "mathf_absin_time_global_6_0_28": mathf_absin_time_global_6_0_28, "draw_top": draw_top, "mixcol_alpha": mixcol_alpha, "draw_reset_called": draw_reset_called, "draw_alpha_call": draw_alpha_call, "draw_plan_config_top_call": draw_plan_config_top_call}

func java_method_shouldSkip_7(_args: Array = []) -> Variant:
	var state_rules_infinite_resources: bool = bool(_args[0] if _args.size() > 0 else false)
	var team_rules_infinite_resources: bool = bool(_args[1] if _args.size() > 1 else false)
	var plan_breaking: bool = bool(_args[2] if _args.size() > 2 else false)
	var core_null: bool = bool(_args[3] if _args.size() > 3 else false)
	var plan_is_rotation: bool = bool(_args[4] if _args.size() > 4 else false)
	var plan_is_derelict_repair: bool = bool(_args[5] if _args.size() > 5 else false)
	var plan_stuck: bool = bool(_args[6] if _args.size() > 6 else false)
	var core_items_has_plan_block_requirements: bool = bool(_args[7] if _args.size() > 7 else true)
	var structs_contains_missing_requirement: bool = bool(_args[8] if _args.size() > 8 else false)
	var guard_returns_false: bool = state_rules_infinite_resources or team_rules_infinite_resources or plan_breaking or core_null or plan_is_rotation or plan_is_derelict_repair
	var stuck_missing_requirements: bool = plan_stuck and not core_items_has_plan_block_requirements
	var should_skip: bool = false if guard_returns_false else (stuck_missing_requirements or structs_contains_missing_requirement)
	return {"source_owner": "PortGame.source_builder_should_skip_state", "method": "boolean shouldSkip(BuildPlan plan, @Nullable Building core){", "comment": "/** @return whether this plan should be skipped, in favor of the next one. */", "guard_expr": "if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;", "return_expr": "return (plan.stuck && !core.items.has(plan.block.requirements)) || (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));", "state_rules_infinite_resources": state_rules_infinite_resources, "team_rules_infinite_resources": team_rules_infinite_resources, "plan_breaking": plan_breaking, "core_null": core_null, "plan_is_rotation": plan_is_rotation, "plan_is_derelict_repair": plan_is_derelict_repair, "plan_stuck": plan_stuck, "core_items_has_plan_block_requirements": core_items_has_plan_block_requirements, "structs_contains_missing_requirement": structs_contains_missing_requirement, "guard_returns_false": guard_returns_false, "stuck_missing_requirements": stuck_missing_requirements, "should_skip": should_skip}

func java_method_removeBuild_8(_args: Array = []) -> Variant:
	var plans: Array = _args[0] if _args.size() > 0 and _args[0] is Array else []
	var x: int = int(_args[1] if _args.size() > 1 else 0)
	var y: int = int(_args[2] if _args.size() > 2 else 0)
	var breaking: bool = bool(_args[3] if _args.size() > 3 else false)
	var idx: int = -1
	for i in range(plans.size()):
		var plan: Dictionary = plans[i] if plans[i] is Dictionary else {}
		if bool(plan.get("breaking", false)) == breaking and int(plan.get("x", 0)) == x and int(plan.get("y", 0)) == y:
			idx = i
			break
	var plans_after: Array = plans.duplicate(true)
	var remove_index_call: Variant = null
	if idx != -1:
		plans_after.remove_at(idx)
		remove_index_call = {"call": "plans.removeIndex(idx);", "idx": idx}
	return {"source_owner": "PortGame.source_builder_remove_build_state", "method": "void removeBuild(int x, int y, boolean breaking){", "comment": "//remove matching plan", "index_expr": "int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);", "guard_expr": "if(idx != -1){", "remove_index_expr": "plans.removeIndex(idx);", "plans": plans, "x": x, "y": y, "breaking": breaking, "idx": idx, "removed": idx != -1, "remove_index_call": remove_index_call, "plans_after": plans_after}

func java_method_isBuilding_9(_args: Array = []) -> Variant:
	var plans_size: int = int(_args[0] if _args.size() > 0 else 0)
	var is_building: bool = plans_size != 0
	return {"source_owner": "PortGame.source_builder_is_building_state", "method": "boolean isBuilding(){", "return_expr": "return plans.size != 0;", "plans_size": plans_size, "is_building": is_building}

func java_method_clearBuilding_10(_args: Array = []) -> Variant:
	var plans_clear_call: String = "plans.clear();"
	var plans_clear_called: bool = true
	return {"source_owner": "PortGame.source_builder_clear_building_state", "method": "void clearBuilding(){", "plans_clear_call": plans_clear_call, "plans_clear_called": plans_clear_called}

func java_method_addBuild_11(_args: Array = []) -> Variant:
	var place: Variant = _args[0] if _args.size() > 0 else null
	var tail: bool = true
	var add_build_call: Dictionary = {"call": "addBuild(place, true);", "place": place, "tail": tail}
	return {"source_owner": "PortGame.source_builder_add_build_tail_state", "method": "void addBuild(BuildPlan place){", "place": place, "tail": tail, "add_build_call": add_build_call, "add_build_called": true}

func java_method_addBuild_12(_args: Array = []) -> Variant:
	return null

func java_method_activelyBuilding_13(_args: Array = []) -> Variant:
	var plans_size: int = int(_args[0] if _args.size() > 0 else 0)
	var plans_first: Variant = _args[1] if _args.size() > 1 else null
	var state_is_editor: bool = bool(_args[2] if _args.size() > 2 else false)
	var state_rules_infinite_resources: bool = bool(_args[3] if _args.size() > 3 else false)
	var type_build_range: float = float(_args[4] if _args.size() > 4 else 0.0)
	var within_plan: bool = bool(_args[5] if _args.size() > 5 else false)
	var update_building: bool = bool(_args[6] if _args.size() > 6 else false)
	var is_building: bool = plans_size != 0
	var build_plan: Variant = null if plans_size == 0 else plans_first
	var final_place_dst: float = 3.4028234663852886e38 if state_rules_infinite_resources else type_build_range
	var outside_range_blocked: bool = is_building and not state_is_editor and build_plan != null and not within_plan
	var actively_building: bool = false if outside_range_blocked else is_building and update_building
	return {"source_owner": "PortGame.source_builder_actively_building_state", "method": "boolean activelyBuilding(){", "comment": "//not actively building when not near the build plan", "guard_expr": "if(isBuilding()){", "plan_assignment": "var plan = buildPlan();", "range_expr": "state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange", "return_false_expr": "return false;", "return_expr": "return isBuilding() && updateBuilding;", "plans_size": plans_size, "plans_first": plans_first, "is_building": is_building, "build_plan": build_plan, "state_is_editor": state_is_editor, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "final_place_dst": final_place_dst, "within_plan": within_plan, "update_building": update_building, "outside_range_blocked": outside_range_blocked, "actively_building": actively_building}

func java_method_buildPlan_14(_args: Array = []) -> Variant:
	var plans_size: int = int(_args[0]) if _args.size() > 0 else 0
	var plans_first: Variant = _args[1] if _args.size() > 1 else null
	var build_plan: Variant = null if plans_size == 0 else plans_first
	return {"source_owner": "PortGame.source_builder_build_plan_state", "method": "BuildPlan buildPlan(){", "return_expr": "return plans.size == 0 ? null : plans.first();", "plans_size": plans_size, "plans_first": plans_first, "build_plan": build_plan}

func java_method_drawBuilding_15(_args: Array = []) -> Variant:
	return null

func java_method_drawBuildingBeam_16(_args: Array = []) -> Variant:
	return null
