extends RefCounted
class_name SourceBlockProducerBuildUpdateState

const source_block_producer_state := preload("res://src/game/SourceBlockProducerState.gd")
const source_factory_defaults := preload("res://src/game/SourceFactoryDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_FACTORY_HEAT_LERP_PROGRESS := source_factory_defaults.HEAT_LERP_PROGRESS
const SOURCE_PAYLOAD_BLOCK_SOURCE := "core/src/mindustry/world/blocks/payloads/PayloadBlock.java"
const SOURCE_ARC_MATHF_SOURCE := "arc-core/src/arc/math/Mathf.java"
const SOURCE_BUILDING_COMP_SOURCE := "core/src/mindustry/entities/comp/BuildingComp.java"
const SOURCE_BUILDING_DELTA_METHOD := "public float delta(){"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD := "public void updateTile(){"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_SUPER_CALL := "super.updateTile();"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_RECIPE_ASSIGNMENT := "var recipe = recipe();"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PRODUCE_EXPR := "boolean produce = recipe != null && efficiency > 0 && payload == null;"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_IF_PRODUCE_EXPR := "if(produce){"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_EXPR := "progress += buildSpeed * edelta();"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_COMPLETION_GUARD_EXPR := "if(progress >= recipe.buildTime){"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_CONSUME_EXPR := "consume();"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAYLOAD_EXPR := "payload = new BuildPayload(recipe, team);"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PLACE_EFFECT_EXPR := "payload.block().placeEffect.at(x, y, payload.size() / tilesize);"
const SOURCE_BLOCK_PRODUCER_BUILD_PAY_VECTOR_FIELD := "public Vec2 payVector = new Vec2();"
const SOURCE_BLOCK_PRODUCER_BUILD_PROGRESS_TIME_HEAT_FIELD := "public float progress, time, heat;"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAY_VECTOR_SET_ZERO_EXPR := "payVector.setZero();"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_MODULO_EXPR := "progress %= 1f;"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_HEAT_EXPR := "heat = Mathf.lerpDelta(heat, Mathf.num(produce), 0.15f);"
const SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_TIME_EXPR := "time += heat * delta();"

static func source_arc_mathf_num(value: bool) -> int:
	return 1 if value else 0

static func source_mathf_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return source_math_state.source_lerp_delta(from_value, to_value, progress, source_delta)

static func produce_gate_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	var produce: bool = not recipe_null and efficiency > 0.0 and payload_null
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PRODUCE_GATE_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "super_call": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_SUPER_CALL, "recipe_assignment": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_RECIPE_ASSIGNMENT, "produce_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PRODUCE_EXPR, "recipe_null": recipe_null, "efficiency": efficiency, "payload_null": payload_null, "produce": produce}

static func progress_accumulation_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	var progress_delta: float = build_speed * edelta if produce else 0.0
	var progress_after: float = progress_before + progress_delta
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_ACCUMULATION_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "if_produce_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_IF_PRODUCE_EXPR, "progress_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_EXPR, "produce": produce, "progress_before": progress_before, "build_speed": build_speed, "edelta": edelta, "progress_delta": progress_delta, "progress_after": progress_after}

static func completion_guard_state(progress: float, recipe_build_time: float) -> Dictionary:
	var completion_guard: bool = progress >= recipe_build_time
	var consume_called: bool = completion_guard
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_COMPLETION_GUARD_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "completion_guard_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_COMPLETION_GUARD_EXPR, "consume_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_CONSUME_EXPR, "progress": progress, "recipe_build_time": recipe_build_time, "completion_guard": completion_guard, "consume_called": consume_called}

static func payload_creation_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	var payload_after: Variant = null
	if completion_guard:
		payload_after = {"recipe": recipe, "team": team}
	var place_effect_called: bool = completion_guard
	var effect_radius: Variant = null
	if completion_guard:
		effect_radius = payload_size / tilesize
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAYLOAD_CREATION_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "payload_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAYLOAD_EXPR, "place_effect_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PLACE_EFFECT_EXPR, "completion_guard": completion_guard, "recipe": recipe, "team": team, "x": x, "y": y, "payload_size": payload_size, "tilesize": tilesize, "payload_after": payload_after, "place_effect_called": place_effect_called, "effect_radius": effect_radius}

static func pay_vector_progress_reset_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	var pay_vector_after: Dictionary = {"x": pay_vector_x, "y": pay_vector_y}
	var progress_after: float = progress_before
	if completion_guard:
		pay_vector_after = {"x": 0.0, "y": 0.0}
		progress_after = fmod(progress_before, 1.0)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAY_VECTOR_PROGRESS_RESET_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "parent_source": SOURCE_PAYLOAD_BLOCK_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "completion_guard_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_COMPLETION_GUARD_EXPR, "pay_vector_field": SOURCE_BLOCK_PRODUCER_BUILD_PAY_VECTOR_FIELD, "progress_field": SOURCE_BLOCK_PRODUCER_BUILD_PROGRESS_TIME_HEAT_FIELD, "pay_vector_set_zero_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAY_VECTOR_SET_ZERO_EXPR, "progress_modulo_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_MODULO_EXPR, "completion_guard": completion_guard, "pay_vector_x": pay_vector_x, "pay_vector_y": pay_vector_y, "progress_before": progress_before, "pay_vector_after": pay_vector_after, "progress_after": progress_after}

static func heat_time_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	var produce_num: float = float(source_arc_mathf_num(produce))
	var heat_after: float = source_mathf_lerp_delta(heat_before, produce_num, SOURCE_FACTORY_HEAT_LERP_PROGRESS, time_delta)
	var time_after: float = time_before + heat_after * time_delta
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_HEAT_TIME_STATE, "source": source_block_producer_state.SOURCE_BLOCK_PRODUCER_SOURCE, "arc_source": SOURCE_ARC_MATHF_SOURCE, "building_source": SOURCE_BUILDING_COMP_SOURCE, "inner_class": source_block_producer_state.SOURCE_BLOCK_PRODUCER_BUILD_CLASS_EXPR, "override_expr": "@Override", "method": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_METHOD, "field_expr": SOURCE_BLOCK_PRODUCER_BUILD_PROGRESS_TIME_HEAT_FIELD, "heat_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_HEAT_EXPR, "time_expr": SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_TIME_EXPR, "mathf_num_method": source_math_state.SOURCE_ARC_MATHF_NUM_METHOD, "mathf_lerp_delta_method": source_math_defaults.LERP_DELTA_METHOD, "building_delta_method": SOURCE_BUILDING_DELTA_METHOD, "produce": produce, "produce_num": produce_num, "heat_before": heat_before, "time_before": time_before, "time_delta": time_delta, "heat_after": heat_after, "time_after": time_after}

static func generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null: bool, efficiency: float, payload_null: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_5", [recipe_null, efficiency, payload_null], null)
	var canonical = produce_gate_state(recipe_null, efficiency, payload_null)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PRODUCE_GATE_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.produceGate", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce: bool, progress_before: float, build_speed: float, edelta: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_progress_accumulation_5", [produce, progress_before, build_speed, edelta], null)
	var canonical = progress_accumulation_state(produce, progress_before, build_speed, edelta)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PROGRESS_ACCUMULATION_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.progressAccumulation", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_update_tile_completion_guard_bridge_state(progress: float, recipe_build_time: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_completion_guard_5", [progress, recipe_build_time], null)
	var canonical = completion_guard_state(progress, recipe_build_time)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_COMPLETION_GUARD_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.completionGuard", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_update_tile_payload_creation_bridge_state(completion_guard: bool, recipe: Variant, team: Variant, x: float, y: float, payload_size: float, tilesize: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_payload_creation_5", [completion_guard, recipe, team, x, y, payload_size, tilesize], null)
	var canonical = payload_creation_state(completion_guard, recipe, team, x, y, payload_size, tilesize)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAYLOAD_CREATION_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.payloadCreation", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(completion_guard: bool, pay_vector_x: float, pay_vector_y: float, progress_before: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_pay_vector_progress_reset_5", [completion_guard, pay_vector_x, pay_vector_y, progress_before], null)
	var canonical = pay_vector_progress_reset_state(completion_guard, pay_vector_x, pay_vector_y, progress_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_PAY_VECTOR_PROGRESS_RESET_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.payVectorProgressReset", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_producer_build_update_tile_heat_time_bridge_state(produce: bool, heat_before: float, time_before: float, time_delta: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/payloads/BlockProducer.gd", "java_inner_class_BlockProducerBuild_method_updateTile_heat_time_5", [produce, heat_before, time_before, time_delta], null)
	var canonical = heat_time_state(produce, heat_before, time_before, time_delta)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PRODUCER_BUILD_UPDATE_TILE_HEAT_TIME_STATE, "generated_owner": "block_producer.BlockProducerBuild.updateTile.heatTime", "result": result, "canonical": canonical, "matches": matches}
