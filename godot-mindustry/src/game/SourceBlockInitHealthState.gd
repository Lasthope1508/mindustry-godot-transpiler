extends RefCounted
class_name SourceBlockInitHealthState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func health_scaled_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	var health_after: int = health_before
	var health_assigned: bool = health_before == -1 and scaled_health >= 0.0
	if health_assigned:
		health_after = int(size_value * size_value * scaled_health)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_HEALTH_SCALED_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "round_init_expr": "boolean round = false;", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "health_assign_expr": "health = round ? Mathf.round(size * size * scaledHealth, 5) : (int)(size * size * scaledHealth);", "int_cast_expr": "(int)(size * size * scaledHealth)", "health_before": health_before, "size": size_value, "scaled_health": scaled_health, "round": false, "health_after": health_after, "health_assigned": health_assigned}

static func generated_health_scaled_bridge_state(health_before: int, size_value: int, scaled_health: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "health_scaled"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [health_before, size_value, scaled_health], null, metadata)
	var canonical = health_scaled_state(health_before, size_value, scaled_health)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_HEALTH_SCALED_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func health_requirements_scaling_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	var health_assigned: bool = health_before == -1 and scaled_health_before < 0.0
	var scaling: float = 1.0
	for health_scaling in requirement_health_scalings:
		scaling += float(health_scaling)
	var scaled_health_after: float = 40.0 * scaling if health_assigned else scaled_health_before
	var health_after: int = health_before
	if health_assigned:
		health_after = int(float(size_value * size_value) * scaled_health_after / 5.0) * 5
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_HEALTH_REQUIREMENTS_SCALING_STATE, "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "health_comment": "//initialize default health based on size", "health_guard_expr": "if(health == -1){", "scaled_health_negative_guard_expr": "if(scaledHealth < 0){", "scaled_health_default_expr": "scaledHealth = 40;", "scaling_init_expr": "float scaling = 1f;", "requirements_loop_expr": "for(var stack : requirements){", "health_scaling_add_expr": "scaling += stack.item.healthScaling;", "item_health_scaling_field_expr": "public float healthScaling = 0f;", "scaled_health_multiply_expr": "scaledHealth *= scaling;", "round_true_expr": "round = true;", "mathf_round_expr": "Mathf.round(size * size * scaledHealth, 5)", "mathf_round_step_expr": "return (int)(value / step) * step;", "health_before": health_before, "size": size_value, "scaled_health_before": scaled_health_before, "requirement_health_scalings": requirement_health_scalings, "scaling": scaling, "scaled_health_after": scaled_health_after, "round": health_assigned, "health_after": health_after, "health_assigned": health_assigned}

static func generated_health_requirements_scaling_bridge_state(health_before: int, size_value: int, scaled_health_before: float, requirement_health_scalings: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "health_requirements_scaling"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [health_before, size_value, scaled_health_before, requirement_health_scalings], null, metadata)
	var canonical = health_requirements_scaling_state(health_before, size_value, scaled_health_before, requirement_health_scalings)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_HEALTH_REQUIREMENTS_SCALING_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
