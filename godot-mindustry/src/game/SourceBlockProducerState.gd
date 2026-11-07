extends RefCounted
class_name SourceBlockProducerState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_producer_source_text_state := preload("res://src/game/SourceBlockProducerSourceTextState.gd")

const SOURCE_BLOCK_PRODUCER_GENERATED_CLASS := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_GENERATED_CLASS
const SOURCE_BLOCK_PRODUCER_SOURCE := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SOURCE
const SOURCE_BLOCK_PRODUCER_CLASS_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_CLASS_EXPR
const SOURCE_BLOCK_PRODUCER_ICONS_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_ICONS_METHOD
const SOURCE_BLOCK_PRODUCER_ICONS_RETURN_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_ICONS_RETURN_EXPR
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_METHOD
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_ROTATION_OFFSET_DEGREES := source_math_defaults.QUARTER_CIRCLE_DEGREES
const SOURCE_BLOCK_PRODUCER_SET_BARS_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_METHOD
const SOURCE_BLOCK_PRODUCER_SET_BARS_SUPER_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_SUPER_EXPR
const SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR
const SOURCE_BLOCK_PRODUCER_SET_BARS_PROGRESS_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_PROGRESS_EXPR
const SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_METHOD
const SOURCE_BLOCK_PRODUCER_ICONS_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_ICONS_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_ICONS_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_ICONS_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_SET_BARS_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_SET_BARS_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_SET_BARS_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_RETURN_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_RETURN_EXPR
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_NULL_GUARD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_NULL_GUARD
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_REQUIREMENT_LOOP := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_REQUIREMENT_LOOP
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_MATCH_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_MATCH_EXPR
const SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_FINAL_RETURN := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_FINAL_RETURN
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_RETURN_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_RETURN_EXPR
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_JAVA_METHOD := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_JAVA_METHOD
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_GENERATED_OWNER := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_GENERATED_OWNER
const SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_RETURN_EXPR := source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_RETURN_EXPR

static func _block_producer_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_PRODUCER_GENERATED_CLASS, generated_method, generated_args, null)

static func icons_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	var icons: Array = [region, out_region, top_region]
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_ICONS_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_ICONS_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_ICONS_RETURN_EXPR, "region": region, "out_region": out_region, "top_region": top_region, "icons": icons}

static func draw_plan_region_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	var out_region_rotation: float = plan_rotation * SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_ROTATION_OFFSET_DEGREES
	var draw_calls: Array = [{"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR, "region": region, "x": plan_drawx, "y": plan_drawy}, {"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR, "region": out_region, "x": plan_drawx, "y": plan_drawy, "rotation": out_region_rotation}, {"call": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR, "region": top_region, "x": plan_drawx, "y": plan_drawy}]
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_METHOD, "draw_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_REGION_EXPR, "draw_out_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_OUT_REGION_EXPR, "draw_top_region_expr": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_TOP_REGION_EXPR, "region": region, "out_region": out_region, "top_region": top_region, "plan_drawx": plan_drawx, "plan_drawy": plan_drawy, "plan_rotation": plan_rotation, "out_region_rotation": out_region_rotation, "draw_calls": draw_calls}

static func set_bars_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	var progress_bar_fraction: float = 0.0 if recipe_null else entity_progress / recipe_build_time
	var progress_bar_call: Dictionary = {"call": SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR, "name": "progress", "bar_text": "bar.progress", "color": "Pal.ammo", "fraction": progress_bar_fraction}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_SET_BARS_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "class_expr": SOURCE_BLOCK_PRODUCER_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_SET_BARS_METHOD, "super_set_bars_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_SUPER_EXPR, "add_bar_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_ADD_BAR_EXPR, "bar_text": "bar.progress", "bar_color": "Pal.ammo", "bar_progress_expr": SOURCE_BLOCK_PRODUCER_SET_BARS_PROGRESS_EXPR, "recipe_null": recipe_null, "entity_progress": entity_progress, "recipe_build_time": recipe_build_time, "super_set_bars_called": true, "progress_bar_added": true, "progress_bar_fraction": progress_bar_fraction, "progress_bar_call": progress_bar_call}

static func build_accept_item_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	var accept_item: bool = item_count < maximum_accepted
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_RETURN_EXPR, "source_building": source_building, "item": item, "item_count": item_count, "maximum_accepted": maximum_accepted, "accept_item": accept_item}

static func build_get_maximum_accepted_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	var maximum_accepted: int = 0
	var matched_requirement: Variant = null
	if not recipe_null:
		for stack in requirements:
			if stack is Dictionary:
				var stack_item: Variant = stack.get("item", null)
				if stack_item == item:
					var stack_amount: int = int(stack.get("amount", 0))
					maximum_accepted = stack_amount * 2
					matched_requirement = stack
					break
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_METHOD, "null_guard": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_NULL_GUARD, "requirement_loop": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_REQUIREMENT_LOOP, "match_expr": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_MATCH_EXPR, "final_return": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_FINAL_RETURN, "item": item, "recipe_null": recipe_null, "requirements": requirements, "matched_requirement": matched_requirement, "maximum_accepted": maximum_accepted}

static func build_accept_payload_state(source_building: Variant, payload: Variant) -> Dictionary:
	var accept_payload: bool = false
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_RETURN_EXPR, "source_building": source_building, "payload": payload, "accept_payload": accept_payload}

static func build_should_consume_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	var should_consume: bool = super_should_consume and not recipe_null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_STATE, "source": SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_METHOD, "return_expr": SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_RETURN_EXPR, "super_should_consume": super_should_consume, "recipe_null": recipe_null, "should_consume": should_consume}

static func generated_block_producer_icons_bridge_state(region: Variant, out_region: Variant, top_region: Variant) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_ICONS_JAVA_METHOD, [region, out_region, top_region])
	var canonical = icons_state(region, out_region, top_region)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_ICONS_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_ICONS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_draw_plan_region_bridge_state(region: Variant, out_region: Variant, top_region: Variant, plan_drawx: float, plan_drawy: float, plan_rotation: float) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_JAVA_METHOD, [region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation])
	var canonical = draw_plan_region_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_DRAW_PLAN_REGION_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_set_bars_bridge_state(recipe_null: bool, entity_progress: float, recipe_build_time: float) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_SET_BARS_JAVA_METHOD, [recipe_null, entity_progress, recipe_build_time])
	var canonical = set_bars_state(recipe_null, entity_progress, recipe_build_time)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_SET_BARS_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_SET_BARS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_accept_item_bridge_state(source_building: Variant, item: Variant, item_count: int, maximum_accepted: int) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_JAVA_METHOD, [source_building, item, item_count, maximum_accepted])
	var canonical = build_accept_item_state(source_building, item, item_count, maximum_accepted)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_ITEM_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_get_maximum_accepted_bridge_state(item: Variant, recipe_null: bool, requirements: Array) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_JAVA_METHOD, [item, recipe_null, requirements])
	var canonical = build_get_maximum_accepted_state(item, recipe_null, requirements)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_BUILD_GET_MAXIMUM_ACCEPTED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_accept_payload_bridge_state(source_building: Variant, payload: Variant) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_JAVA_METHOD, [source_building, payload])
	var canonical = build_accept_payload_state(source_building, payload)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_BUILD_ACCEPT_PAYLOAD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_should_consume_bridge_state(super_should_consume: bool, recipe_null: bool) -> Dictionary:
	var result = _block_producer_call(SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_JAVA_METHOD, [super_should_consume, recipe_null])
	var canonical = build_should_consume_state(super_should_consume, recipe_null)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_STATE, "generated_owner": SOURCE_BLOCK_PRODUCER_BUILD_SHOULD_CONSUME_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
