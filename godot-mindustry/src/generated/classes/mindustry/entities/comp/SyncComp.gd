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
	return null

func java_method_afterSync_6(_args: Array = []) -> Variant:
	return null

func java_method_interpolate_7(_args: Array = []) -> Variant:
	return null

func java_method_isSyncHidden_8(_args: Array = []) -> Variant:
	return null

func java_method_handleSyncHidden_9(_args: Array = []) -> Variant:
	return null

func java_method_update_10(_args: Array = []) -> Variant:
	return null

func java_method_remove_11(_args: Array = []) -> Variant:
	return null
