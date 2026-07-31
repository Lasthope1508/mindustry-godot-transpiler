extends RefCounted
class_name SourceBlockInitBufferedPowerState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func buffered_power_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	var buffered_power_disabled: bool = (not outputs_power) and has_cons_power and cons_power_buffered_before
	var cons_power_buffered_after: bool = false if buffered_power_disabled else cons_power_buffered_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUFFERED_POWER_STATE, "source": "core/src/mindustry/world/Block.java", "consume_power_source": "core/src/mindustry/world/consumers/ConsumePower.java", "method": "public void init(){", "super_init_expr": "super.init();", "outputs_power_field_expr": "public boolean outputsPower = false;", "cons_power_field_expr": "public @Nullable ConsumePower consPower;", "consume_power_buffered_field_expr": "public boolean buffered;", "buffered_power_guard_expr": "if(!outputsPower && consPower != null && consPower.buffered){", "buffered_power_warn_expr": "Log.warn(\"Consumer using buffered power: @. Disabling buffered power.\", name);", "buffered_power_disable_expr": "consPower.buffered = false;", "outputs_power": outputs_power, "has_cons_power": has_cons_power, "cons_power_buffered_before": cons_power_buffered_before, "buffered_power_disabled": buffered_power_disabled, "cons_power_buffered_after": cons_power_buffered_after}

static func generated_block_init_buffered_power_bridge_state(outputs_power: bool, has_cons_power: bool, cons_power_buffered_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [outputs_power, has_cons_power, cons_power_buffered_before], null, {"mindustry_init_bridge_mode": "buffered_power"})
	var canonical = buffered_power_state(outputs_power, has_cons_power, cons_power_buffered_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUFFERED_POWER_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
