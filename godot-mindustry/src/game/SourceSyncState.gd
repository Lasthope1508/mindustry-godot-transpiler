extends RefCounted
class_name SourceSyncState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func _noop_state(source_owner: String, method: String) -> Dictionary:
	return {
		"source_owner": source_owner,
		"method": method,
		"empty_body": method,
		"no_op": true,
	}

static func snap_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_SYNC_STATE, "method": "void snapSync(){}", "empty_body": "void snapSync(){}", "no_op": true}

static func snap_interpolation_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_INTERPOLATION_STATE, "method": "void snapInterpolation(){}", "empty_body": "void snapInterpolation(){}", "no_op": true}

static func read_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_STATE, "method": "void readSync(Reads read){}", "empty_body": "void readSync(Reads read){}", "no_op": true}

static func write_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_STATE, "method": "void writeSync(Writes write){}", "empty_body": "void writeSync(Writes write){}", "no_op": true}

static func read_sync_manual_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_MANUAL_STATE, "method": "void readSyncManual(FloatBuffer buffer){}", "empty_body": "void readSyncManual(FloatBuffer buffer){}", "no_op": true}

static func write_sync_manual_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_MANUAL_STATE, "method": "void writeSyncManual(FloatBuffer buffer){}", "empty_body": "void writeSyncManual(FloatBuffer buffer){}", "no_op": true}

static func after_sync_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_AFTER_SYNC_STATE, "method": "void afterSync(){}", "empty_body": "void afterSync(){}", "no_op": true}

static func interpolate_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_INTERPOLATE_STATE, "method": "void interpolate(){}", "empty_body": "void interpolate(){}", "no_op": true}

static func is_sync_hidden_state(player: Variant = null) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_IS_SYNC_HIDDEN_STATE,
		"method": "boolean isSyncHidden(Player player){",
		"player": player,
		"return_expr": "return false;",
		"is_sync_hidden": false,
	}

static func handle_sync_hidden_state() -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_HANDLE_SYNC_HIDDEN_STATE,
		"method": "void handleSyncHidden(){",
		"empty_body": "void handleSyncHidden(){\n\n}",
		"no_op": true,
	}

static func update_interpolate_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	var interpolate_called: bool = (net_client and not is_local) or is_remote
	var interpolate_result: Variant = null
	if interpolate_called:
		interpolate_result = interpolate_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_UPDATE_INTERPOLATE_STATE,
		"method": "public void update(){",
		"condition": "if((Vars.net.client() && !isLocal()) || isRemote()){",
		"interpolate_call": "interpolate();",
		"net_client": net_client,
		"is_local": is_local,
		"is_remote": is_remote,
		"interpolate_called": interpolate_called,
		"interpolate": interpolate_result,
	}

static func remove_client_removed_entity_state(net_client: bool, entity_id: int) -> Dictionary:
	var add_removed_entity_call: Variant = null
	if net_client:
		add_removed_entity_call = {"call": "Vars.netClient.addRemovedEntity(id());", "entity_id": entity_id}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_STATE,
		"method": "public void remove(){",
		"condition": "if(Vars.net.client()){",
		"add_removed_entity_call": add_removed_entity_call,
		"id_call": "id()",
		"net_client": net_client,
		"entity_id": entity_id,
	}

static func generated_snap_sync_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_snapSync_0", [], null)
	var canonical = snap_sync_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_SYNC_STATE,
		"generated_owner": "sync_comp.java_method_snapSync_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_snap_interpolation_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_snapInterpolation_1", [], null)
	var canonical = snap_interpolation_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_SNAP_INTERPOLATION_STATE,
		"generated_owner": "sync_comp.java_method_snapInterpolation_1",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_read_sync_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_readSync_2", [], null)
	var canonical = read_sync_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_STATE,
		"generated_owner": "sync_comp.java_method_readSync_2",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_write_sync_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_writeSync_3", [], null)
	var canonical = write_sync_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_STATE,
		"generated_owner": "sync_comp.java_method_writeSync_3",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_read_sync_manual_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_readSyncManual_4", [], null)
	var canonical = read_sync_manual_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_READ_SYNC_MANUAL_STATE,
		"generated_owner": "sync_comp.java_method_readSyncManual_4",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_write_sync_manual_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_writeSyncManual_5", [], null)
	var canonical = write_sync_manual_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_WRITE_SYNC_MANUAL_STATE,
		"generated_owner": "sync_comp.java_method_writeSyncManual_5",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_after_sync_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_afterSync_6", [], null)
	var canonical = after_sync_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_AFTER_SYNC_STATE,
		"generated_owner": "sync_comp.java_method_afterSync_6",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_interpolate_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_interpolate_7", [], null)
	var canonical = interpolate_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_INTERPOLATE_STATE,
		"generated_owner": "sync_comp.java_method_interpolate_7",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_is_sync_hidden_bridge_state(player: Variant = null) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_isSyncHidden_8", [player], null)
	var canonical = is_sync_hidden_state(player)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_IS_SYNC_HIDDEN_STATE,
		"generated_owner": "sync_comp.java_method_isSyncHidden_8",
		"result": result,
		"canonical": canonical,
		"matches": result.get("is_sync_hidden", null) == canonical.get("is_sync_hidden", null) and result.get("return_expr", null) == canonical.get("return_expr", null),
	}

static func generated_handle_sync_hidden_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_handleSyncHidden_9", [], null)
	var canonical = handle_sync_hidden_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_HANDLE_SYNC_HIDDEN_STATE,
		"generated_owner": "sync_comp.java_method_handleSyncHidden_9",
		"result": result,
		"canonical": canonical,
		"matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("no_op", null) == canonical.get("no_op", null),
	}

static func generated_update_interpolate_bridge_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_update_10", [net_client, is_local, is_remote], null)
	var canonical = update_interpolate_state(net_client, is_local, is_remote)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_UPDATE_INTERPOLATE_STATE,
		"generated_owner": "sync_comp.java_method_update_10",
		"result": result,
		"canonical": canonical,
		"matches": result.get("interpolate_called", null) == canonical.get("interpolate_called", null) and result.get("condition", null) == canonical.get("condition", null),
	}

static func generated_remove_client_removed_entity_bridge_state(net_client: bool, entity_id: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/SyncComp.gd", "java_method_remove_11", [net_client, entity_id], null)
	var canonical = remove_client_removed_entity_state(net_client, entity_id)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SYNC_REMOVE_CLIENT_REMOVED_ENTITY_STATE,
		"generated_owner": "sync_comp.java_method_remove_11",
		"result": result,
		"canonical": canonical,
		"matches": result.get("add_removed_entity_call", null) == canonical.get("add_removed_entity_call", null) and result.get("condition", null) == canonical.get("condition", null),
	}
