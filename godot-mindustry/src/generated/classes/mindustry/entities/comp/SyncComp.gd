# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/SyncComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "SyncComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Entityc"]
const JAVA_FIELDS := [{"modifiers": ["transient"], "name": "lastUpdated", "type": "long"}, {"modifiers": ["transient"], "name": "updateSpacing", "type": "long"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "snapSync", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "snapInterpolation", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "readSync", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeSync", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "readSyncManual", "parameters": [{"name": "buffer", "type": "FloatBuffer", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeSyncManual", "parameters": [{"name": "buffer", "type": "FloatBuffer", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "interpolate", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "isSyncHidden", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "handleSyncHidden", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_snapSync_0(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_snap_sync_state", "method": "void snapSync(){}", "empty_body": "void snapSync(){}", "no_op": true}

func java_method_snapInterpolation_1(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_snap_interpolation_state", "method": "void snapInterpolation(){}", "empty_body": "void snapInterpolation(){}", "no_op": true}

func java_method_readSync_2(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_read_sync_state", "method": "void readSync(Reads read){}", "empty_body": "void readSync(Reads read){}", "no_op": true}

func java_method_writeSync_3(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_write_sync_state", "method": "void writeSync(Writes write){}", "empty_body": "void writeSync(Writes write){}", "no_op": true}

func java_method_readSyncManual_4(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_read_sync_manual_state", "method": "void readSyncManual(FloatBuffer buffer){}", "empty_body": "void readSyncManual(FloatBuffer buffer){}", "no_op": true}

func java_method_writeSyncManual_5(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_write_sync_manual_state", "method": "void writeSyncManual(FloatBuffer buffer){}", "empty_body": "void writeSyncManual(FloatBuffer buffer){}", "no_op": true}

func java_method_afterSync_6(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_after_sync_state", "method": "void afterSync(){}", "empty_body": "void afterSync(){}", "no_op": true}

func java_method_interpolate_7(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_interpolate_state", "method": "void interpolate(){}", "empty_body": "void interpolate(){}", "no_op": true}

func java_method_isSyncHidden_8(_args: Array = []) -> Variant:
	var player: Variant = _args[0] if _args.size() > 0 else null
	return {"source_owner": "PortGame.source_sync_is_sync_hidden_state", "method": "boolean isSyncHidden(Player player){", "player": player, "return_expr": "return false;", "is_sync_hidden": false}

func java_method_handleSyncHidden_9(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_sync_handle_sync_hidden_state", "method": "void handleSyncHidden(){", "empty_body": "void handleSyncHidden(){\n\n}", "no_op": true}

func java_method_update_10(_args: Array = []) -> Variant:
	var net_client: bool = bool(_args[0] if _args.size() > 0 else false)
	var is_local: bool = bool(_args[1] if _args.size() > 1 else false)
	var is_remote: bool = bool(_args[2] if _args.size() > 2 else false)
	var interpolate_called: bool = (net_client and not is_local) or is_remote
	var interpolate_result: Variant = null
	if interpolate_called:
		interpolate_result = java_method_interpolate_7([])
	return {"source_owner": "PortGame.source_sync_update_interpolate_state", "method": "public void update(){", "condition": "if((Vars.net.client() && !isLocal()) || isRemote()){", "interpolate_call": "interpolate();", "net_client": net_client, "is_local": is_local, "is_remote": is_remote, "interpolate_called": interpolate_called, "interpolate": interpolate_result}

func java_method_remove_11(_args: Array = []) -> Variant:
	return null
