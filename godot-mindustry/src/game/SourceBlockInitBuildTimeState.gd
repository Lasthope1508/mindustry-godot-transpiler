extends RefCounted
class_name SourceBlockInitBuildTimeState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func requirements_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	var requirements_length: int = requirement_stacks.size()
	var build_time_assigned: bool = requirement_stacks.size() > 0 and build_time_before < 0.0
	var build_time_after: float = 0.0 if build_time_assigned else build_time_before
	if build_time_assigned:
		for stack in requirement_stacks:
			if stack is Dictionary:
				build_time_after += float(stack.get("amount", 0)) * float(stack.get("cost", 1.0))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_REQUIREMENTS_STATE, "source": "core/src/mindustry/world/Block.java", "item_source": "core/src/mindustry/type/Item.java", "item_stack_source": "core/src/mindustry/type/ItemStack.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(requirements.length > 0 && buildTime < 0){", "build_time_zero_expr": "buildTime = 0f;", "requirements_loop_expr": "for(ItemStack stack : requirements){", "build_time_add_expr": "buildTime += stack.amount * stack.item.cost;", "item_cost_field_expr": "public float cost = 1f;", "itemstack_amount_field_expr": "public int amount = 0;", "build_time_before": build_time_before, "requirement_stacks": requirement_stacks, "requirements_length": requirements_length, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}

static func generated_requirements_bridge_state(build_time_before: float, requirement_stacks: Array) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "build_time_requirements"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [build_time_before, requirement_stacks], null, metadata)
	var canonical = requirements_state(build_time_before, requirement_stacks)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_REQUIREMENTS_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func default_state(build_time_before: float) -> Dictionary:
	var build_time_assigned: bool = build_time_before < 0.0
	var build_time_after: float = 20.0 if build_time_assigned else build_time_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_DEFAULT_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_time_guard_expr": "if(buildTime < 0){", "build_time_default_expr": "buildTime = 20f;", "build_time_before": build_time_before, "build_time_assigned": build_time_assigned, "build_time_after": build_time_after}

static func generated_default_bridge_state(build_time_before: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "build_time_default"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [build_time_before], null, metadata)
	var canonical = default_state(build_time_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_DEFAULT_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func multiplier_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	var build_time_after: float = build_time_before * build_cost_multiplier
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_MULTIPLIER_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "build_cost_multiplier_field_expr": "public float buildCostMultiplier = 1f;", "build_time_multiplier_expr": "buildTime *= buildCostMultiplier;", "build_time_before": build_time_before, "build_cost_multiplier": build_cost_multiplier, "build_time_after": build_time_after}

static func generated_multiplier_bridge_state(build_time_before: float, build_cost_multiplier: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "build_time_multiplier"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [build_time_before, build_cost_multiplier], null, metadata)
	var canonical = multiplier_state(build_time_before, build_cost_multiplier)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILD_TIME_MULTIPLIER_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
