extends RefCounted
class_name SourceTurretOutputsItemsState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS
const SOURCE_TURRET_OUTPUTS_ITEMS_METHOD := source_turret_source_text_state.SOURCE_TURRET_OUTPUTS_ITEMS_METHOD
const SOURCE_TURRET_OUTPUTS_ITEMS_OVERRIDE := source_turret_source_text_state.SOURCE_TURRET_OUTPUTS_ITEMS_OVERRIDE
const SOURCE_TURRET_OUTPUTS_ITEMS_RETURN := source_turret_source_text_state.SOURCE_TURRET_OUTPUTS_ITEMS_RETURN
const SOURCE_TURRET_OUTPUTS_ITEMS_JAVA_METHOD := source_turret_source_text_state.SOURCE_TURRET_OUTPUTS_ITEMS_JAVA_METHOD
const SOURCE_TURRET_OUTPUTS_ITEMS_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_OUTPUTS_ITEMS_GENERATED_OWNER

static func _turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func outputs_items_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_OUTPUTS_ITEMS_STATE,
		"method": SOURCE_TURRET_OUTPUTS_ITEMS_METHOD,
		"override_expr": SOURCE_TURRET_OUTPUTS_ITEMS_OVERRIDE,
		"return_expr": SOURCE_TURRET_OUTPUTS_ITEMS_RETURN,
		"outputs_items": false,
	}

static func generated_outputs_items_bridge_state() -> Dictionary:
	var result = _turret_call(SOURCE_TURRET_OUTPUTS_ITEMS_JAVA_METHOD, [])
	var canonical = outputs_items_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_OUTPUTS_ITEMS_STATE,
		"generated_owner": SOURCE_TURRET_OUTPUTS_ITEMS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": result.get("outputs_items", null) == canonical.get("outputs_items", null),
	}
