extends RefCounted
class_name SourceBlockInitClipState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_defaults := preload("res://src/game/SourceBlockDefaults.gd")

static func clip_size_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	var size_tilesize: float = float(size_value) * source_tilesize
	var clip_size_after: float = max(clip_size_before, size_tilesize)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CLIP_SIZE_STATE, "source": "core/src/mindustry/world/Block.java", "vars_source": "core/src/mindustry/Vars.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "tilesize_comment": "/** size of tiles in units */", "tilesize_field_expr": "public static final int tilesize = 8;", "clip_size_before": clip_size_before, "size": size_value, "source_tilesize": source_tilesize, "size_tilesize": size_tilesize, "clip_size_after": clip_size_after}

static func generated_clip_size_bridge_state(clip_size_before: float, size_value: int, source_tilesize: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "clip_size"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [clip_size_before, size_value, source_tilesize], null, metadata)
	var canonical = clip_size_state(clip_size_before, size_value, source_tilesize)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_CLIP_SIZE_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func light_clip_size_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	var light_clip_size_after: float = max(light_clip_size_before, clip_size)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIGHT_CLIP_SIZE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "clip_size_expr": "clipSize = Math.max(clipSize, size * tilesize);", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, clipSize);", "light_clip_size_before": light_clip_size_before, "clip_size": clip_size, "light_clip_size_after": light_clip_size_after}

static func generated_light_clip_size_bridge_state(light_clip_size_before: float, clip_size: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "light_clip_size"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [light_clip_size_before, clip_size], null, metadata)
	var canonical = light_clip_size_state(light_clip_size_before, clip_size)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIGHT_CLIP_SIZE_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func liquid_light_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	var liquid_light_gate: bool = has_liquids and draw_liquid_light
	var liquid_light_clip_size: float = float(size_value) * source_block_defaults.INIT_LIQUID_LIGHT_RADIUS_SCALE * source_block_defaults.INIT_LIGHT_CLIP_DIAMETER_SCALE
	var emit_light_after: bool = true if liquid_light_gate else emit_light_before
	var light_clip_size_after: float = max(light_clip_size_before, liquid_light_clip_size) if liquid_light_gate else light_clip_size_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIQUID_LIGHT_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_light_guard_expr": "if(hasLiquids && drawLiquidLight){", "emit_light_assign_expr": "emitLight = true;", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, size * 30f * 2f);", "has_liquids": has_liquids, "draw_liquid_light": draw_liquid_light, "emit_light_before": emit_light_before, "light_clip_size_before": light_clip_size_before, "size": size_value, "liquid_light_gate": liquid_light_gate, "liquid_light_clip_size": liquid_light_clip_size, "emit_light_after": emit_light_after, "light_clip_size_after": light_clip_size_after}

static func generated_liquid_light_bridge_state(has_liquids: bool, draw_liquid_light: bool, emit_light_before: bool, light_clip_size_before: float, size_value: int) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "liquid_light"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value], null, metadata)
	var canonical = liquid_light_state(has_liquids, draw_liquid_light, emit_light_before, light_clip_size_before, size_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIQUID_LIGHT_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func liquid_capacity_default_state(liquid_capacity_before: float) -> Dictionary:
	var liquid_capacity_assigned: bool = liquid_capacity_before < 0.0
	var consume_amount: float = source_block_defaults.INIT_LIQUID_CONSUME_AMOUNT_DEFAULT
	var liquid_capacity_after: float = float(int(source_block_defaults.INIT_LIQUID_CAPACITY_SCALE * consume_amount + source_block_defaults.INIT_LIQUID_CAPACITY_ROUND_BIAS) - source_block_defaults.INIT_LIQUID_CAPACITY_ROUND_OFFSET) if liquid_capacity_assigned else liquid_capacity_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIQUID_CAPACITY_DEFAULT_STATE, "source": "core/src/mindustry/world/Block.java", "arc_mathf_source": "arc-core/src/arc/math/Mathf.java", "method": "public void init(){", "super_init_expr": "super.init();", "liquid_capacity_comment": "//some blocks don't have hasLiquids, but have liquid consumers/liquid capacity", "liquid_capacity_guard_expr": "if(liquidCapacity < 0){", "consume_amount_default_expr": "float consumeAmount = 1f;", "consume_builder_loop_expr": "for(var cons : consumeBuilder){", "liquid_capacity_assign_expr": "liquidCapacity = Mathf.round(10f * consumeAmount);", "mathf_round_expr": "return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;", "liquid_capacity_before": liquid_capacity_before, "consume_amount": consume_amount, "liquid_capacity_assigned": liquid_capacity_assigned, "liquid_capacity_after": liquid_capacity_after}

static func generated_liquid_capacity_default_bridge_state(liquid_capacity_before: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "liquid_capacity_default"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [liquid_capacity_before], null, metadata)
	var canonical = liquid_capacity_default_state(liquid_capacity_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LIQUID_CAPACITY_DEFAULT_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func emit_light_radius_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	var light_radius_clip_size: float = light_radius * source_block_defaults.INIT_LIGHT_CLIP_DIAMETER_SCALE
	var light_clip_size_after: float = max(light_clip_size_before, light_radius_clip_size) if emit_light else light_clip_size_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_EMIT_LIGHT_RADIUS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "emit_light_guard_expr": "if(emitLight){", "light_clip_size_expr": "lightClipSize = Math.max(lightClipSize, lightRadius * 2f);", "emit_light": emit_light, "light_clip_size_before": light_clip_size_before, "light_radius": light_radius, "light_radius_clip_size": light_radius_clip_size, "light_clip_size_after": light_clip_size_after}

static func generated_emit_light_radius_bridge_state(emit_light: bool, light_clip_size_before: float, light_radius: float) -> Dictionary:
	var metadata := {"mindustry_init_bridge_mode": "emit_light_radius"}
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [emit_light, light_clip_size_before, light_radius], null, metadata)
	var canonical = emit_light_radius_state(emit_light, light_clip_size_before, light_radius)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_EMIT_LIGHT_RADIUS_STATE,
		"generated_owner": "block.java_method_init_123",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
