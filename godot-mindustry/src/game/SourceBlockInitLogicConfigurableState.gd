extends RefCounted
class_name SourceBlockInitLogicConfigurableState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func logic_configurable_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LOGIC_CONFIGURABLE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void init(){", "super_init_expr": "super.init();", "logic_configurable_field_expr": "public boolean logicConfigurable = false;", "logic_configurable_guard_expr": "if(!logicConfigurable){", "configurations_each_expr": "configurations.each((key, val) -> {", "unlockable_assignable_expr": "if(UnlockableContent.class.isAssignableFrom(key)){", "logic_configurable_assignment_expr": "logicConfigurable = true;", "logic_configurable_before": logic_configurable_before, "config_key_assignable_to_unlockable_content": config_key_assignable_to_unlockable_content, "logic_configurable_after": logic_configurable_before or config_key_assignable_to_unlockable_content}

static func generated_block_init_logic_configurable_bridge_state(logic_configurable_before: bool, config_key_assignable_to_unlockable_content: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [logic_configurable_before, config_key_assignable_to_unlockable_content], null, {"mindustry_init_bridge_mode": "logic_configurable"})
	var canonical = logic_configurable_state(logic_configurable_before, config_key_assignable_to_unlockable_content)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_LOGIC_CONFIGURABLE_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
