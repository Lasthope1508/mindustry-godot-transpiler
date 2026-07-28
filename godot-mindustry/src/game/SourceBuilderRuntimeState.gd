extends RefCounted
class_name SourceBuilderRuntimeState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func can_build_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	var type_build_speed_positive: bool = type_build_speed > 0
	var build_speed_multiplier_positive: bool = build_speed_multiplier > 0
	var can_build: bool = type_build_speed_positive and build_speed_multiplier_positive
	return {"source_owner": "PortGame.source_builder_can_build_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "public boolean canBuild(){", "return_expr": "return type.buildSpeed > 0 && buildSpeedMultiplier > 0;", "type_build_speed": type_build_speed, "build_speed_multiplier": build_speed_multiplier, "type_build_speed_positive": type_build_speed_positive, "build_speed_multiplier_positive": build_speed_multiplier_positive, "can_build": can_build}

static func update_state() -> Dictionary:
	return {"source_owner": "PortGame.source_builder_update_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "public void update(){", "update_build_logic_call": "updateBuildLogic();", "update_build_logic_called": true}

static func after_read_state(plans_null: bool) -> Dictionary:
	return {"source_owner": "PortGame.source_builder_after_read_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "public void afterRead(){", "comment": "//why would this happen?", "guard_expr": "if(plans == null){", "queue_constructor": "new Queue<>(1)", "plans_null": plans_null, "queue_reset": plans_null, "plans_capacity": 1 if plans_null else 0}

static func is_building_state(plans_size: int) -> Dictionary:
	var is_building := plans_size != 0
	return {"source_owner": "PortGame.source_builder_is_building_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "boolean isBuilding(){", "return_expr": "return plans.size != 0;", "plans_size": plans_size, "is_building": is_building}

static func clear_building_state() -> Dictionary:
	return {"source_owner": "PortGame.source_builder_clear_building_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "void clearBuilding(){", "plans_clear_call": "plans.clear();", "plans_clear_called": true}

static func add_build_tail_state(place: Variant) -> Dictionary:
	return {"source_owner": "PortGame.source_builder_add_build_tail_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "void addBuild(BuildPlan place){", "place": place, "tail": true, "add_build_call": {"call": "addBuild(place, true);", "place": place, "tail": true}, "add_build_called": true}

static func should_skip_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	var guard_returns_false: bool = state_rules_infinite_resources or team_rules_infinite_resources or plan_breaking or core_null or plan_is_rotation or plan_is_derelict_repair
	var stuck_missing_requirements: bool = plan_stuck and not core_items_has_plan_block_requirements
	var should_skip: bool = false if guard_returns_false else (stuck_missing_requirements or structs_contains_missing_requirement)
	return {"source_owner": "PortGame.source_builder_should_skip_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "boolean shouldSkip(BuildPlan plan, @Nullable Building core){", "guard_expr": "if(state.rules.infiniteResources || team.rules().infiniteResources || plan.breaking || core == null || plan.isRotation(team) || plan.isDerelictRepair()) return false;", "return_expr": "return (plan.stuck && !core.items.has(plan.block.requirements)) || (Structs.contains(plan.block.requirements, i -> !core.items.has(i.item, Math.min(i.amount, 15)) && Mathf.round(i.amount * state.rules.buildCostMultiplier) > 0));", "state_rules_infinite_resources": state_rules_infinite_resources, "team_rules_infinite_resources": team_rules_infinite_resources, "plan_breaking": plan_breaking, "core_null": core_null, "plan_is_rotation": plan_is_rotation, "plan_is_derelict_repair": plan_is_derelict_repair, "plan_stuck": plan_stuck, "core_items_has_plan_block_requirements": core_items_has_plan_block_requirements, "structs_contains_missing_requirement": structs_contains_missing_requirement, "guard_returns_false": guard_returns_false, "stuck_missing_requirements": stuck_missing_requirements, "should_skip": should_skip}

static func remove_build_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	var idx := -1
	for i in range(plans.size()):
		var plan: Dictionary = plans[i] if plans[i] is Dictionary else {}
		if bool(plan.get("breaking", false)) == breaking and int(plan.get("x", 0)) == x and int(plan.get("y", 0)) == y:
			idx = i
			break
	var plans_after := plans.duplicate(true)
	var remove_index_call: Variant = null
	if idx != -1:
		plans_after.remove_at(idx)
		remove_index_call = {"call": "plans.removeIndex(idx);", "idx": idx}
	return {"source_owner": "PortGame.source_builder_remove_build_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "void removeBuild(int x, int y, boolean breaking){", "index_expr": "int idx = plans.indexOf(req -> req.breaking == breaking && req.x == x && req.y == y);", "guard_expr": "if(idx != -1){", "remove_index_expr": "plans.removeIndex(idx);", "plans": plans, "x": x, "y": y, "breaking": breaking, "idx": idx, "removed": idx != -1, "remove_index_call": remove_index_call, "plans_after": plans_after}

static func add_build_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	var place_after: Dictionary = (place if place is Dictionary else {}).duplicate(true)
	var plans_after := plans.duplicate(true)
	var replace_index := -1
	var removed_replace := false
	var world_tile_call: Variant = null
	var progress_copied := false
	var add_last_call: Variant = null
	var add_first_call: Variant = null
	if can_build:
		for i in range(plans_after.size()):
			var plan: Dictionary = plans_after[i] if plans_after[i] is Dictionary else {}
			if int(plan.get("x", 0)) == int(place_after.get("x", 0)) and int(plan.get("y", 0)) == int(place_after.get("y", 0)):
				replace_index = i
				break
		if replace_index != -1:
			plans_after.remove_at(replace_index)
			removed_replace = true
		world_tile_call = {"call": "world.tile(place.x, place.y);", "x": int(place_after.get("x", 0)), "y": int(place_after.get("y", 0))}
		if world_tile_exists and tile_build_is_construct_build:
			place_after["progress"] = construct_progress
			progress_copied = true
		if tail:
			plans_after.append(place_after)
			add_last_call = {"call": "plans.addLast(place);", "place": place_after}
		else:
			plans_after.insert(0, place_after)
			add_first_call = {"call": "plans.addFirst(place);", "place": place_after}
	return {"source_owner": "PortGame.source_builder_add_build_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "void addBuild(BuildPlan place, boolean tail){", "add_last_expr": "plans.addLast(place);", "add_first_expr": "plans.addFirst(place);", "plans": plans, "place": place, "tail": tail, "can_build": can_build, "world_tile_exists": world_tile_exists, "tile_build_is_construct_build": tile_build_is_construct_build, "construct_progress": construct_progress, "returned_early": not can_build, "replace_index": replace_index, "removed_replace": removed_replace, "world_tile_call": world_tile_call, "progress_copied": progress_copied, "add_last_call": add_last_call, "add_first_call": add_first_call, "plans_after": plans_after, "place_after": place_after}

static func build_plan_state(plans_size: int, plans_first: Variant) -> Dictionary:
	var build_plan: Variant = null if plans_size == 0 else plans_first
	return {"source_owner": "PortGame.source_builder_build_plan_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "BuildPlan buildPlan(){", "return_expr": "return plans.size == 0 ? null : plans.first();", "plans_size": plans_size, "plans_first": plans_first, "build_plan": build_plan}

static func actively_building_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	var is_building := plans_size != 0
	var build_plan: Variant = null if plans_size == 0 else plans_first
	var final_place_dst := 3.4028234663852886e38 if state_rules_infinite_resources else type_build_range
	var outside_range_blocked := is_building and not state_is_editor and build_plan != null and not within_plan
	var actively_building := false if outside_range_blocked else is_building and update_building
	return {"source_owner": "PortGame.source_builder_actively_building_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "boolean activelyBuilding(){", "range_expr": "state.rules.infiniteResources ? Float.MAX_VALUE : type.buildRange", "plans_size": plans_size, "plans_first": plans_first, "is_building": is_building, "build_plan": build_plan, "state_is_editor": state_is_editor, "state_rules_infinite_resources": state_rules_infinite_resources, "type_build_range": type_build_range, "final_place_dst": final_place_dst, "within_plan": within_plan, "update_building": update_building, "outside_range_blocked": outside_range_blocked, "actively_building": actively_building}

static func build_step_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	var build_speed := 1.0 / entity_build_cost * type_build_speed * build_speed_multiplier * team_build_speed
	var deconstruct_called := current_breaking and allow_build_current
	var construct_called := (not current_breaking) and allow_build_current
	return {"source_owner": "PortGame.source_builder_build_step_state", "source": "core/src/mindustry/entities/comp/BuilderComp.java", "method": "void updateBuildLogic(){", "build_speed_formula": "1f / entity.buildCost * type.buildSpeed * buildSpeedMultiplier * state.rules.buildSpeed(team)", "construct_call_expr": "entity.construct(self(), core, bs, current.config);", "deconstruct_call_expr": "entity.deconstruct(self(), core, bs);", "entity_build_cost": entity_build_cost, "type_build_speed": type_build_speed, "build_speed_multiplier": build_speed_multiplier, "team_build_speed": team_build_speed, "current_breaking": current_breaking, "allow_build_current": allow_build_current, "build_speed": build_speed, "deconstruct_called": deconstruct_called, "construct_called": construct_called}

static func generated_builder_comp_can_build_bridge_state(type_build_speed: float, build_speed_multiplier: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_canBuild_0", [type_build_speed, build_speed_multiplier], null)
	var canonical = can_build_state(type_build_speed, build_speed_multiplier)
	return {"source_owner": "PortGame.source_builder_can_build_state", "generated_owner": "BuilderComp.java_method_canBuild_0", "result": result, "canonical": canonical, "matches": result.get("can_build", null) == canonical.get("can_build", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_builder_comp_update_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_update_1", [], null)
	var canonical = update_state()
	return {"source_owner": "PortGame.source_builder_update_state", "generated_owner": "BuilderComp.java_method_update_1", "result": result, "canonical": canonical, "matches": result.get("update_build_logic_call", null) == canonical.get("update_build_logic_call", null) and result.get("update_build_logic_called", null) == canonical.get("update_build_logic_called", null)}

static func generated_builder_comp_after_read_bridge_state(plans_null: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_afterRead_2", [plans_null], null)
	var canonical = after_read_state(plans_null)
	return {"source_owner": "PortGame.source_builder_after_read_state", "generated_owner": "BuilderComp.java_method_afterRead_2", "result": result, "canonical": canonical, "matches": result.get("queue_reset", null) == canonical.get("queue_reset", null) and result.get("plans_capacity", null) == canonical.get("plans_capacity", null)}

static func generated_builder_comp_is_building_bridge_state(plans_size: int) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_isBuilding_9", [plans_size], null)
	var canonical = is_building_state(plans_size)
	return {"source_owner": "PortGame.source_builder_is_building_state", "generated_owner": "BuilderComp.java_method_isBuilding_9", "result": result, "canonical": canonical, "matches": result.get("is_building", null) == canonical.get("is_building", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_builder_comp_clear_building_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_clearBuilding_10", [], null)
	var canonical = clear_building_state()
	return {"source_owner": "PortGame.source_builder_clear_building_state", "generated_owner": "BuilderComp.java_method_clearBuilding_10", "result": result, "canonical": canonical, "matches": result.get("plans_clear_call", null) == canonical.get("plans_clear_call", null) and result.get("plans_clear_called", null) == canonical.get("plans_clear_called", null)}

static func generated_builder_comp_add_build_tail_bridge_state(place: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_addBuild_11", [place], null)
	var canonical = add_build_tail_state(place)
	return {"source_owner": "PortGame.source_builder_add_build_tail_state", "generated_owner": "BuilderComp.java_method_addBuild_11", "result": result, "canonical": canonical, "matches": result.get("add_build_call", null) == canonical.get("add_build_call", null) and result.get("add_build_called", null) == canonical.get("add_build_called", null)}

static func generated_builder_comp_should_skip_bridge_state(state_rules_infinite_resources: bool, team_rules_infinite_resources: bool, plan_breaking: bool, core_null: bool, plan_is_rotation: bool, plan_is_derelict_repair: bool, plan_stuck: bool, core_items_has_plan_block_requirements: bool, structs_contains_missing_requirement: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_shouldSkip_7", [state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement], null)
	var canonical = should_skip_state(state_rules_infinite_resources, team_rules_infinite_resources, plan_breaking, core_null, plan_is_rotation, plan_is_derelict_repair, plan_stuck, core_items_has_plan_block_requirements, structs_contains_missing_requirement)
	return {"source_owner": "PortGame.source_builder_should_skip_state", "generated_owner": "BuilderComp.java_method_shouldSkip_7", "result": result, "canonical": canonical, "matches": result.get("should_skip", null) == canonical.get("should_skip", null) and result.get("guard_returns_false", null) == canonical.get("guard_returns_false", null)}

static func generated_builder_comp_remove_build_bridge_state(plans: Array, x: int, y: int, breaking: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_removeBuild_8", [plans, x, y, breaking], null)
	var canonical = remove_build_state(plans, x, y, breaking)
	return {"source_owner": "PortGame.source_builder_remove_build_state", "generated_owner": "BuilderComp.java_method_removeBuild_8", "result": result, "canonical": canonical, "matches": result.get("idx", null) == canonical.get("idx", null) and result.get("plans_after", null) == canonical.get("plans_after", null)}

static func generated_builder_comp_add_build_bridge_state(plans: Array, place: Variant, tail: bool, can_build: bool, world_tile_exists: bool, tile_build_is_construct_build: bool, construct_progress: float) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_addBuild_12", [plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress], null)
	var canonical = add_build_state(plans, place, tail, can_build, world_tile_exists, tile_build_is_construct_build, construct_progress)
	return {"source_owner": "PortGame.source_builder_add_build_state", "generated_owner": "BuilderComp.java_method_addBuild_12", "result": result, "canonical": canonical, "matches": result.get("plans_after", null) == canonical.get("plans_after", null) and result.get("place_after", null) == canonical.get("place_after", null) and result.get("returned_early", null) == canonical.get("returned_early", null)}

static func generated_builder_comp_build_plan_bridge_state(plans_size: int, plans_first: Variant) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_buildPlan_14", [plans_size, plans_first], null)
	var canonical = build_plan_state(plans_size, plans_first)
	return {"source_owner": "PortGame.source_builder_build_plan_state", "generated_owner": "BuilderComp.java_method_buildPlan_14", "result": result, "canonical": canonical, "matches": result.get("build_plan", null) == canonical.get("build_plan", null) and result.get("return_expr", null) == canonical.get("return_expr", null)}

static func generated_builder_comp_update_build_logic_bridge_state(entity_build_cost: float, type_build_speed: float, build_speed_multiplier: float, team_build_speed: float, current_breaking: bool, allow_build_current: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_updateBuildLogic_4", [entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current], null)
	var canonical = build_step_state(entity_build_cost, type_build_speed, build_speed_multiplier, team_build_speed, current_breaking, allow_build_current)
	return {"source_owner": "PortGame.source_builder_build_step_state", "generated_owner": "BuilderComp.java_method_updateBuildLogic_4", "result": result, "canonical": canonical, "matches": result.get("deconstruct_called", null) == canonical.get("deconstruct_called", null) and result.get("construct_called", null) == canonical.get("construct_called", null) and result.get("build_speed", null) == canonical.get("build_speed", null)}

static func generated_builder_comp_actively_building_bridge_state(plans_size: int, plans_first: Variant, state_is_editor: bool, state_rules_infinite_resources: bool, type_build_range: float, within_plan: bool, update_building: bool) -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuilderComp.gd", "java_method_activelyBuilding_13", [plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building], null)
	var canonical = actively_building_state(plans_size, plans_first, state_is_editor, state_rules_infinite_resources, type_build_range, within_plan, update_building)
	return {"source_owner": "PortGame.source_builder_actively_building_state", "generated_owner": "BuilderComp.java_method_activelyBuilding_13", "result": result, "canonical": canonical, "matches": result.get("actively_building", null) == canonical.get("actively_building", null) and result.get("outside_range_blocked", null) == canonical.get("outside_range_blocked", null)}
