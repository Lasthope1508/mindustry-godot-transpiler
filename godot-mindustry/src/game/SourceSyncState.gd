extends RefCounted
class_name SourceSyncState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_entity_comp_source_text_state := preload("res://src/game/SourceEntityCompSourceTextState.gd")
const source_sync_source_text_state := preload("res://src/game/SourceSyncSourceTextState.gd")
const SOURCE_SYNC_COMP_GENERATED_CLASS := source_entity_comp_source_text_state.SOURCE_SYNC_COMP_GENERATED_CLASS
const SOURCE_SYNC_SNAP_SYNC_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_SNAP_SYNC_JAVA_METHOD
const SOURCE_SYNC_SNAP_SYNC_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_SNAP_SYNC_GENERATED_OWNER
const SOURCE_SYNC_SNAP_INTERPOLATION_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_SNAP_INTERPOLATION_JAVA_METHOD
const SOURCE_SYNC_SNAP_INTERPOLATION_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_SNAP_INTERPOLATION_GENERATED_OWNER
const SOURCE_SYNC_READ_SYNC_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_JAVA_METHOD
const SOURCE_SYNC_READ_SYNC_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_GENERATED_OWNER
const SOURCE_SYNC_WRITE_SYNC_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_JAVA_METHOD
const SOURCE_SYNC_WRITE_SYNC_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_GENERATED_OWNER
const SOURCE_SYNC_READ_SYNC_MANUAL_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_MANUAL_JAVA_METHOD
const SOURCE_SYNC_READ_SYNC_MANUAL_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_MANUAL_GENERATED_OWNER
const SOURCE_SYNC_WRITE_SYNC_MANUAL_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_MANUAL_JAVA_METHOD
const SOURCE_SYNC_WRITE_SYNC_MANUAL_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_MANUAL_GENERATED_OWNER
const SOURCE_SYNC_AFTER_SYNC_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_AFTER_SYNC_JAVA_METHOD
const SOURCE_SYNC_AFTER_SYNC_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_AFTER_SYNC_GENERATED_OWNER
const SOURCE_SYNC_INTERPOLATE_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_JAVA_METHOD
const SOURCE_SYNC_INTERPOLATE_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_GENERATED_OWNER
const SOURCE_SYNC_IS_SYNC_HIDDEN_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_IS_SYNC_HIDDEN_JAVA_METHOD
const SOURCE_SYNC_IS_SYNC_HIDDEN_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_IS_SYNC_HIDDEN_GENERATED_OWNER
const SOURCE_SYNC_HANDLE_SYNC_HIDDEN_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_HANDLE_SYNC_HIDDEN_JAVA_METHOD
const SOURCE_SYNC_HANDLE_SYNC_HIDDEN_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_HANDLE_SYNC_HIDDEN_GENERATED_OWNER
const SOURCE_SYNC_UPDATE_INTERPOLATE_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_UPDATE_INTERPOLATE_JAVA_METHOD
const SOURCE_SYNC_UPDATE_INTERPOLATE_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_UPDATE_INTERPOLATE_GENERATED_OWNER
const SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_JAVA_METHOD := source_sync_source_text_state.SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_JAVA_METHOD
const SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_GENERATED_OWNER := source_sync_source_text_state.SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_GENERATED_OWNER
const SOURCE_SYNC_SNAP_SYNC_METHOD := source_sync_source_text_state.SOURCE_SYNC_SNAP_SYNC_METHOD
const SOURCE_SYNC_SNAP_INTERPOLATION_METHOD := source_sync_source_text_state.SOURCE_SYNC_SNAP_INTERPOLATION_METHOD
const SOURCE_SYNC_READ_SYNC_METHOD := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_METHOD
const SOURCE_SYNC_WRITE_SYNC_METHOD := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_METHOD
const SOURCE_SYNC_READ_SYNC_MANUAL_METHOD := source_sync_source_text_state.SOURCE_SYNC_READ_SYNC_MANUAL_METHOD
const SOURCE_SYNC_WRITE_SYNC_MANUAL_METHOD := source_sync_source_text_state.SOURCE_SYNC_WRITE_SYNC_MANUAL_METHOD
const SOURCE_SYNC_AFTER_SYNC_METHOD := source_sync_source_text_state.SOURCE_SYNC_AFTER_SYNC_METHOD
const SOURCE_SYNC_INTERPOLATE_METHOD := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_METHOD
const SOURCE_SYNC_IS_SYNC_HIDDEN_METHOD := source_sync_source_text_state.SOURCE_SYNC_IS_SYNC_HIDDEN_METHOD
const SOURCE_SYNC_HANDLE_SYNC_HIDDEN_METHOD := source_sync_source_text_state.SOURCE_SYNC_HANDLE_SYNC_HIDDEN_METHOD
const SOURCE_SYNC_UPDATE_METHOD := source_sync_source_text_state.SOURCE_SYNC_UPDATE_METHOD
const SOURCE_SYNC_REMOVE_METHOD := source_sync_source_text_state.SOURCE_SYNC_REMOVE_METHOD
const SOURCE_SYNC_UPDATE_CONDITION := source_sync_source_text_state.SOURCE_SYNC_UPDATE_CONDITION
const SOURCE_SYNC_UPDATE_INTERPOLATE_CALL := source_sync_source_text_state.SOURCE_SYNC_UPDATE_INTERPOLATE_CALL
const SOURCE_SYNC_REMOVE_CONDITION := source_sync_source_text_state.SOURCE_SYNC_REMOVE_CONDITION
const SOURCE_SYNC_REMOVE_CALL := source_sync_source_text_state.SOURCE_SYNC_REMOVE_CALL
const SOURCE_SYNC_ID_CALL := source_sync_source_text_state.SOURCE_SYNC_ID_CALL
const SOURCE_SYNC_EMPTY_BODY_KEY := source_sync_source_text_state.SOURCE_SYNC_EMPTY_BODY_KEY
const SOURCE_SYNC_NO_OP_KEY := source_sync_source_text_state.SOURCE_SYNC_NO_OP_KEY
const SOURCE_SYNC_CALL_KEY := source_sync_source_text_state.SOURCE_SYNC_CALL_KEY
const SOURCE_SYNC_METHOD_KEY := source_sync_source_text_state.SOURCE_SYNC_METHOD_KEY
const SOURCE_SYNC_SOURCE_OWNER_KEY := source_sync_source_text_state.SOURCE_SYNC_SOURCE_OWNER_KEY
const SOURCE_SYNC_PLAYER_KEY := source_sync_source_text_state.SOURCE_SYNC_PLAYER_KEY
const SOURCE_SYNC_RETURN_EXPR_KEY := source_sync_source_text_state.SOURCE_SYNC_RETURN_EXPR_KEY
const SOURCE_SYNC_IS_SYNC_HIDDEN_KEY := source_sync_source_text_state.SOURCE_SYNC_IS_SYNC_HIDDEN_KEY
const SOURCE_SYNC_CONDITION_KEY := source_sync_source_text_state.SOURCE_SYNC_CONDITION_KEY
const SOURCE_SYNC_INTERPOLATE_CALL_KEY := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_CALL_KEY
const SOURCE_SYNC_NET_CLIENT_KEY := source_sync_source_text_state.SOURCE_SYNC_NET_CLIENT_KEY
const SOURCE_SYNC_IS_LOCAL_KEY := source_sync_source_text_state.SOURCE_SYNC_IS_LOCAL_KEY
const SOURCE_SYNC_IS_REMOTE_KEY := source_sync_source_text_state.SOURCE_SYNC_IS_REMOTE_KEY
const SOURCE_SYNC_INTERPOLATE_CALLED_KEY := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_CALLED_KEY
const SOURCE_SYNC_INTERPOLATE_KEY := source_sync_source_text_state.SOURCE_SYNC_INTERPOLATE_KEY
const SOURCE_SYNC_ADD_REMOVED_ENTITY_CALL_KEY := source_sync_source_text_state.SOURCE_SYNC_ADD_REMOVED_ENTITY_CALL_KEY
const SOURCE_SYNC_ID_CALL_KEY := source_sync_source_text_state.SOURCE_SYNC_ID_CALL_KEY
const SOURCE_SYNC_ENTITY_ID_KEY := source_sync_source_text_state.SOURCE_SYNC_ENTITY_ID_KEY
const SOURCE_SYNC_RESULT_KEY := source_sync_source_text_state.SOURCE_SYNC_RESULT_KEY
const SOURCE_SYNC_CANONICAL_KEY := source_sync_source_text_state.SOURCE_SYNC_CANONICAL_KEY
const SOURCE_SYNC_GENERATED_OWNER_KEY := source_sync_source_text_state.SOURCE_SYNC_GENERATED_OWNER_KEY
const SOURCE_SYNC_MATCHES_KEY := source_sync_source_text_state.SOURCE_SYNC_MATCHES_KEY

static func _sync_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_SYNC_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func _noop_state(source_owner: String, method: String) -> Dictionary:
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_owner,
		SOURCE_SYNC_METHOD_KEY: method,
		SOURCE_SYNC_EMPTY_BODY_KEY: method,
		SOURCE_SYNC_NO_OP_KEY: true,
	}

static func snap_sync_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_SYNC_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_SNAP_SYNC_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_SNAP_SYNC_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func snap_interpolation_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_INTERPOLATION_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_SNAP_INTERPOLATION_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_SNAP_INTERPOLATION_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func read_sync_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_READ_SYNC_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_READ_SYNC_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func write_sync_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_WRITE_SYNC_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_WRITE_SYNC_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func read_sync_manual_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_MANUAL_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_READ_SYNC_MANUAL_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_READ_SYNC_MANUAL_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func write_sync_manual_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_MANUAL_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_WRITE_SYNC_MANUAL_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_WRITE_SYNC_MANUAL_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func after_sync_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_AFTER_SYNC_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_AFTER_SYNC_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_AFTER_SYNC_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func interpolate_state() -> Dictionary:
	return {SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_INTERPOLATE_STATE, SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_INTERPOLATE_METHOD, SOURCE_SYNC_EMPTY_BODY_KEY: SOURCE_SYNC_INTERPOLATE_METHOD, SOURCE_SYNC_NO_OP_KEY: true}

static func is_sync_hidden_state(player: Variant = null) -> Dictionary:
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_IS_SYNC_HIDDEN_STATE,
		SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_IS_SYNC_HIDDEN_METHOD,
		SOURCE_SYNC_PLAYER_KEY: player,
		SOURCE_SYNC_RETURN_EXPR_KEY: "return false;",
		SOURCE_SYNC_IS_SYNC_HIDDEN_KEY: false,
	}

static func handle_sync_hidden_state() -> Dictionary:
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_HANDLE_SYNC_HIDDEN_STATE,
		SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_HANDLE_SYNC_HIDDEN_METHOD,
		SOURCE_SYNC_EMPTY_BODY_KEY: "void handleSyncHidden(){\n\n}",
		SOURCE_SYNC_NO_OP_KEY: true,
	}

static func update_interpolate_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	var interpolate_called: bool = (net_client and not is_local) or is_remote
	var interpolate_result: Variant = null
	if interpolate_called:
		interpolate_result = interpolate_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_UPDATE_INTERPOLATE_STATE,
		SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_UPDATE_METHOD,
		SOURCE_SYNC_CONDITION_KEY: SOURCE_SYNC_UPDATE_CONDITION,
		SOURCE_SYNC_INTERPOLATE_CALL_KEY: SOURCE_SYNC_UPDATE_INTERPOLATE_CALL,
		SOURCE_SYNC_NET_CLIENT_KEY: net_client,
		SOURCE_SYNC_IS_LOCAL_KEY: is_local,
		SOURCE_SYNC_IS_REMOTE_KEY: is_remote,
		SOURCE_SYNC_INTERPOLATE_CALLED_KEY: interpolate_called,
		SOURCE_SYNC_INTERPOLATE_KEY: interpolate_result,
	}

static func remove_client_removed_entity_state(net_client: bool, entity_id: int) -> Dictionary:
	var add_removed_entity_call: Variant = null
	if net_client:
		add_removed_entity_call = {SOURCE_SYNC_CALL_KEY: SOURCE_SYNC_REMOVE_CALL, SOURCE_SYNC_ENTITY_ID_KEY: entity_id}
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_STATE,
		SOURCE_SYNC_METHOD_KEY: SOURCE_SYNC_REMOVE_METHOD,
		SOURCE_SYNC_CONDITION_KEY: SOURCE_SYNC_REMOVE_CONDITION,
		SOURCE_SYNC_ADD_REMOVED_ENTITY_CALL_KEY: add_removed_entity_call,
		SOURCE_SYNC_ID_CALL_KEY: SOURCE_SYNC_ID_CALL,
		SOURCE_SYNC_NET_CLIENT_KEY: net_client,
		SOURCE_SYNC_ENTITY_ID_KEY: entity_id,
	}

static func generated_snap_sync_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_SNAP_SYNC_JAVA_METHOD, [])
	var canonical = snap_sync_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_SYNC_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_SNAP_SYNC_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_snap_interpolation_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_SNAP_INTERPOLATION_JAVA_METHOD, [])
	var canonical = snap_interpolation_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_INTERPOLATION_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_SNAP_INTERPOLATION_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_read_sync_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_READ_SYNC_JAVA_METHOD, [])
	var canonical = read_sync_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_READ_SYNC_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_write_sync_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_WRITE_SYNC_JAVA_METHOD, [])
	var canonical = write_sync_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_WRITE_SYNC_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_read_sync_manual_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_READ_SYNC_MANUAL_JAVA_METHOD, [])
	var canonical = read_sync_manual_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_MANUAL_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_READ_SYNC_MANUAL_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_write_sync_manual_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_WRITE_SYNC_MANUAL_JAVA_METHOD, [])
	var canonical = write_sync_manual_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_MANUAL_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_WRITE_SYNC_MANUAL_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_after_sync_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_AFTER_SYNC_JAVA_METHOD, [])
	var canonical = after_sync_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_AFTER_SYNC_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_AFTER_SYNC_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_interpolate_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_INTERPOLATE_JAVA_METHOD, [])
	var canonical = interpolate_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_INTERPOLATE_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_INTERPOLATE_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_is_sync_hidden_bridge_state(player: Variant = null) -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_IS_SYNC_HIDDEN_JAVA_METHOD, [player])
	var canonical = is_sync_hidden_state(player)
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_IS_SYNC_HIDDEN_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_IS_SYNC_HIDDEN_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_IS_SYNC_HIDDEN_KEY, null) == canonical.get(SOURCE_SYNC_IS_SYNC_HIDDEN_KEY, null) and result.get(SOURCE_SYNC_RETURN_EXPR_KEY, null) == canonical.get(SOURCE_SYNC_RETURN_EXPR_KEY, null),
	}

static func generated_handle_sync_hidden_bridge_state() -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_HANDLE_SYNC_HIDDEN_JAVA_METHOD, [])
	var canonical = handle_sync_hidden_state()
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_HANDLE_SYNC_HIDDEN_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_HANDLE_SYNC_HIDDEN_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) == canonical.get(SOURCE_SYNC_EMPTY_BODY_KEY, null) and result.get(SOURCE_SYNC_NO_OP_KEY, null) == canonical.get(SOURCE_SYNC_NO_OP_KEY, null),
	}

static func generated_update_interpolate_bridge_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_UPDATE_INTERPOLATE_JAVA_METHOD, [net_client, is_local, is_remote])
	var canonical = update_interpolate_state(net_client, is_local, is_remote)
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_UPDATE_INTERPOLATE_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_UPDATE_INTERPOLATE_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_INTERPOLATE_CALLED_KEY, null) == canonical.get(SOURCE_SYNC_INTERPOLATE_CALLED_KEY, null) and result.get(SOURCE_SYNC_CONDITION_KEY, null) == canonical.get(SOURCE_SYNC_CONDITION_KEY, null),
	}

static func generated_remove_client_removed_entity_bridge_state(net_client: bool, entity_id: int) -> Dictionary:
	var result = _sync_comp_call(SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_JAVA_METHOD, [net_client, entity_id])
	var canonical = remove_client_removed_entity_state(net_client, entity_id)
	return {
		SOURCE_SYNC_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_STATE,
		SOURCE_SYNC_GENERATED_OWNER_KEY: SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_GENERATED_OWNER,
		SOURCE_SYNC_RESULT_KEY: result,
		SOURCE_SYNC_CANONICAL_KEY: canonical,
		SOURCE_SYNC_MATCHES_KEY: result.get(SOURCE_SYNC_ADD_REMOVED_ENTITY_CALL_KEY, null) == canonical.get(SOURCE_SYNC_ADD_REMOVED_ENTITY_CALL_KEY, null) and result.get(SOURCE_SYNC_CONDITION_KEY, null) == canonical.get(SOURCE_SYNC_CONDITION_KEY, null),
	}
