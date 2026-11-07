extends RefCounted
class_name SourceBuildingPlanState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_text := preload("res://src/game/SourceBuildingPlanSourceTextState.gd")

const GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS

static func _call(method_name: String, args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(GENERATED_CLASS, method_name, args, null)

static func add_plan_default_state(check_previous: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	var result := add_plan_state(check_previous, false, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)
	result["default_delegate"] = source_text.ADD_PLAN_DEFAULT_DELEGATE
	return result

static func add_plan_state(check_previous: bool, ignore_conditions: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	var updated_plans := plans.duplicate(true)
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ADD_PLAN_STATE,
		"method": source_text.ADD_PLAN_METHOD,
		"plans": updated_plans,
		"added": false,
		"removed_previous": false,
		"path": "eligibility",
	}
	if not ignore_conditions and (not rebuildable or (is_default_team and is_campaign and not block_visible)):
		return result
	var to_add: Variant = block_value
	var override_config: Variant = null
	if is_construct_build:
		if construct_current_synthetic and construct_was_constructing:
			to_add = construct_current
			override_config = construct_last_config
		else:
			result["path"] = "construct_interrupted"
			return result
	if check_previous:
		for index in range(updated_plans.size()):
			var plan: Variant = updated_plans[index]
			if plan is Dictionary and int(plan.get("x", -2147483648)) == tile_x and int(plan.get("y", -2147483648)) == tile_y:
				updated_plans.remove_at(index)
				result["removed_previous"] = true
				break
	var plan_config: Variant = current_config if override_config == null else override_config
	var new_plan: Dictionary = {"x": tile_x, "y": tile_y, "rotation": rotation, "block": to_add, "config": plan_config}
	updated_plans.push_front(new_plan)
	result.merge({"plans": updated_plans, "added": true, "path": "added", "plan": new_plan, "to_add": to_add, "override_config": override_config})
	return result

static func generated_add_plan_default_bridge_state(check_previous: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	var args := [check_previous, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans]
	var canonical := add_plan_default_state(check_previous, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)
	var result: Variant = _call(source_text.ADD_PLAN_DEFAULT_JAVA_METHOD, args)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ADD_PLAN_STATE, "generated_owner": source_text.ADD_PLAN_DEFAULT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}

static func generated_add_plan_bridge_state(check_previous: bool, ignore_conditions: bool, rebuildable: bool, is_default_team: bool, is_campaign: bool, block_visible: bool, is_construct_build: bool, construct_current_synthetic: bool, construct_was_constructing: bool, construct_current: Variant, construct_last_config: Variant, block_value: Variant, current_config: Variant, tile_x: int, tile_y: int, rotation: int, plans: Array) -> Dictionary:
	var args := [check_previous, ignore_conditions, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans]
	var canonical := add_plan_state(check_previous, ignore_conditions, rebuildable, is_default_team, is_campaign, block_visible, is_construct_build, construct_current_synthetic, construct_was_constructing, construct_current, construct_last_config, block_value, current_config, tile_x, tile_y, rotation, plans)
	var result: Variant = _call(source_text.ADD_PLAN_JAVA_METHOD, args)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ADD_PLAN_STATE, "generated_owner": source_text.ADD_PLAN_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": result == canonical}
