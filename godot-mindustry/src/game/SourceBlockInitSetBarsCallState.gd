extends RefCounted
class_name SourceBlockInitSetBarsCallState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func set_bars_call_state() -> Dictionary:
	var set_bars_call: Dictionary = {"call": "setBars();", "method": "public void setBars(){"}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SET_BARS_CALL_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "set_bars_expr": "setBars();", "set_bars_method_expr": "public void setBars(){", "health_bar_expr": "addBar(\"health\", entity -> new Bar(\"stat.health\", Pal.health, entity::healthf).blink(Color.white));", "set_bars_call": set_bars_call, "set_bars_called": true}

static func generated_block_init_set_bars_call_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [], null, {"mindustry_init_bridge_mode": "set_bars_call"})
	var canonical = set_bars_call_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_SET_BARS_CALL_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
