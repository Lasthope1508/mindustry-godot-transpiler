extends RefCounted
class_name SourceBuildingSerializationState

const source_text := preload("res://src/game/SourceBuildingSerializationSourceTextState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS

static func write_hook_noop_state(write_value: Variant = null) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SERIALIZATION_HOOK_STATE, "source": source_text.SOURCE, "method": source_text.WRITE_HOOK_METHOD, "write": write_value, "no_op": true}

static func read_hook_noop_state(read_value: Variant = null, revision: int = 0) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SERIALIZATION_HOOK_STATE, "source": source_text.SOURCE, "method": source_text.READ_HOOK_METHOD, "read": read_value, "revision": revision, "no_op": true}

static func write_all_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_WRITE_ALL_STATE, "source": source_text.SOURCE, "method": source_text.WRITE_ALL_METHOD, "base_call": source_text.WRITE_ALL_BASE_CALL, "body_call": source_text.WRITE_ALL_BODY_CALL}

static func read_all_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_READ_ALL_STATE, "source": source_text.SOURCE, "method": source_text.READ_ALL_METHOD, "base_call": source_text.READ_ALL_BASE_CALL, "body_call": source_text.READ_ALL_BODY_CALL}

static func write_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_WRITE_SYNC_STATE, "source": source_text.SOURCE, "method": source_text.WRITE_SYNC_METHOD, "delegates_to": source_text.WRITE_SYNC_CALL}

static func read_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_READ_SYNC_STATE, "source": source_text.SOURCE, "method": source_text.READ_SYNC_METHOD, "delegates_to": source_text.READ_SYNC_CALL}

static func version_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_VERSION_STATE, "source": source_text.SOURCE, "method": source_text.VERSION_METHOD, "return_expr": source_text.VERSION_RETURN_EXPR, "version": source_text.VERSION_VALUE}

static func generated_write_all_bridge_state() -> Dictionary:
	return _bridge(source_text.WRITE_ALL_JAVA_METHOD, source_text.WRITE_ALL_GENERATED_OWNER, write_all_state())

static func generated_write_hook_bridge_state(write_value: Variant = null) -> Dictionary:
	return _bridge_with_args(source_text.WRITE_HOOK_JAVA_METHOD, source_text.WRITE_HOOK_GENERATED_OWNER, [write_value], write_hook_noop_state(write_value))

static func generated_read_hook_bridge_state(read_value: Variant = null, revision: int = 0) -> Dictionary:
	return _bridge_with_args(source_text.READ_HOOK_JAVA_METHOD, source_text.READ_HOOK_GENERATED_OWNER, [read_value, revision], read_hook_noop_state(read_value, revision))

static func generated_read_all_bridge_state() -> Dictionary:
	return _bridge(source_text.READ_ALL_JAVA_METHOD, source_text.READ_ALL_GENERATED_OWNER, read_all_state())

static func generated_write_sync_bridge_state() -> Dictionary:
	return _bridge(source_text.WRITE_SYNC_JAVA_METHOD, source_text.WRITE_SYNC_GENERATED_OWNER, write_sync_state())

static func generated_read_sync_bridge_state() -> Dictionary:
	return _bridge(source_text.READ_SYNC_JAVA_METHOD, source_text.READ_SYNC_GENERATED_OWNER, read_sync_state())

static func generated_version_bridge_state() -> Dictionary:
	return _bridge(source_text.VERSION_JAVA_METHOD, source_text.VERSION_GENERATED_OWNER, version_state())

static func _bridge(method_name: String, generated_owner: String, canonical: Dictionary) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(GENERATED_CLASS, method_name, [], null)
	return {"source_owner": canonical.get("source_owner", ""), "generated_owner": generated_owner, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}

static func _bridge_with_args(method_name: String, generated_owner: String, args: Array, canonical: Dictionary) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(GENERATED_CLASS, method_name, args, null)
	return {"source_owner": canonical.get("source_owner", ""), "generated_owner": generated_owner, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)}
