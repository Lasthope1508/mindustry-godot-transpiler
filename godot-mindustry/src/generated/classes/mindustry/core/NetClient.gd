# Generated from Mindustry upstream.
# Source: mindustry/core/NetClient.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "NetClient"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["ApplicationListener"]
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "entitySnapshotTimeout", "type": "long"}, {"modifiers": ["final", "private", "static"], "name": "dataTimeout", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "playerSyncTime", "type": "Timekeeper"}, {"modifiers": ["final", "private", "static"], "name": "planSyncTime", "type": "Timekeeper"}, {"modifiers": ["final", "private", "static"], "name": "pingTime", "type": "Timekeeper"}, {"modifiers": ["final", "private", "static"], "name": "dataReads", "type": "Reads"}, {"modifiers": ["final", "private", "static"], "name": "tmpJsonMap", "type": "JsonValue"}, {"modifiers": ["private"], "name": "ping", "type": "long"}, {"modifiers": ["private"], "name": "connecting", "type": "boolean"}, {"modifiers": ["private"], "name": "quiet", "type": "boolean"}, {"modifiers": ["private"], "name": "quietReset", "type": "boolean"}, {"modifiers": ["private"], "name": "timeoutTime", "type": "float"}, {"modifiers": ["private"], "name": "lastSnapshotTimestamp", "type": "long"}, {"modifiers": ["private"], "name": "lastSent", "type": "int"}, {"modifiers": ["private"], "name": "removed", "type": "IntSet"}, {"modifiers": ["private"], "name": "byteStream", "type": "ReusableByteInStream"}, {"modifiers": ["private"], "name": "dataStream", "type": "DataInputStream"}, {"modifiers": ["private"], "name": "dataStreamReads", "type": "Reads"}, {"modifiers": ["private"], "name": "customPacketHandlers", "type": "ObjectMap"}, {"modifiers": ["private"], "name": "customBinaryPacketHandlers", "type": "ObjectMap"}, {"modifiers": ["final", "private", "static"], "name": "plansOut", "type": "ClientBuildPlans"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "NetClient", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "addPacketHandler", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "handler", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getPacketHandlers", "parameters": [{"name": "type", "type": "String", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "addBinaryPacketHandler", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "handler", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getBinaryPacketHandlers", "parameters": [{"name": "type", "type": "String", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public", "static"], "name": "clientBinaryPacketReliable", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "contents", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clientBinaryPacketUnreliable", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "contents", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clientPacketReliable", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "contents", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clientPacketUnreliable", "parameters": [{"name": "type", "type": "String", "varargs": false}, {"name": "contents", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "playMusic", "parameters": [{"name": "musicName", "type": "String", "varargs": false}, {"name": "interrupt", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "sound", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "volume", "type": "float", "varargs": false}, {"name": "pitch", "type": "float", "varargs": false}, {"name": "pan", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "soundAt", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "volume", "type": "float", "varargs": false}, {"name": "pitch", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "effect", "parameters": [{"name": "effect", "type": "Effect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "effect", "parameters": [{"name": "effect", "type": "Effect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}, {"name": "data", "type": "Object", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "effectReliable", "parameters": [{"name": "effect", "type": "Effect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "color", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "sendMessage", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "unformatted", "type": "String", "varargs": false}, {"name": "playersender", "type": "Player", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "sendMessage", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "sendChatMessage", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "connect", "parameters": [{"name": "ip", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "ping", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "time", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "pingResponse", "parameters": [{"name": "time", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "traceInfo", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "info", "type": "TraceInfo", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "kick", "parameters": [{"name": "reason", "type": "KickReason", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setRules", "parameters": [{"name": "rules", "type": "Rules", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setRule", "parameters": [{"name": "rule", "type": "String", "varargs": false}, {"name": "jsonData", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setObjectives", "parameters": [{"name": "executor", "type": "MapObjectives", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "clearObjectives", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "completeObjective", "parameters": [{"name": "index", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "worldDataBegin", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setPosition", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setCameraPosition", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "playerDisconnect", "parameters": [{"name": "playerid", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "readSyncEntity", "parameters": [{"name": "input", "type": "DataInputStream", "varargs": false}, {"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "entitySnapshot", "parameters": [{"name": "amount", "type": "short", "varargs": false}, {"name": "data", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "hiddenSnapshot", "parameters": [{"name": "ids", "type": "IntSeq", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "blockSnapshot", "parameters": [{"name": "amount", "type": "short", "varargs": false}, {"name": "data", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "stateSnapshot", "parameters": [{"name": "waveTime", "type": "float", "varargs": false}, {"name": "wave", "type": "int", "varargs": false}, {"name": "enemies", "type": "int", "varargs": false}, {"name": "paused", "type": "boolean", "varargs": false}, {"name": "gameOver", "type": "boolean", "varargs": false}, {"name": "timeData", "type": "int", "varargs": false}, {"name": "tps", "type": "byte", "varargs": false}, {"name": "rand0", "type": "long", "varargs": false}, {"name": "rand1", "type": "long", "varargs": false}, {"name": "coreData", "type": "byte", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "resetTimeout", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isConnecting", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPing", "parameters": [], "return_type": "int"}, {"modifiers": ["private"], "name": "finishConnecting", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "beginConnecting", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "disconnectQuietly", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "disconnectNoReset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setQuiet", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clearRemovedEntity", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addRemovedEntity", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isEntityUsed", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "sync", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "getUsid", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addPacketHandler_0(_args: Array = []) -> Variant:
	return null

func java_method_getPacketHandlers_1(_args: Array = []) -> Variant:
	return null

func java_method_addBinaryPacketHandler_2(_args: Array = []) -> Variant:
	return null

func java_method_getBinaryPacketHandlers_3(_args: Array = []) -> Variant:
	return null

func java_method_clientBinaryPacketReliable_4(_args: Array = []) -> Variant:
	return null

func java_method_clientBinaryPacketUnreliable_5(_args: Array = []) -> Variant:
	return null

func java_method_clientPacketReliable_6(_args: Array = []) -> Variant:
	return null

func java_method_clientPacketUnreliable_7(_args: Array = []) -> Variant:
	return null

func java_method_playMusic_8(_args: Array = []) -> Variant:
	return null

func java_method_sound_9(_args: Array = []) -> Variant:
	return null

func java_method_soundAt_10(_args: Array = []) -> Variant:
	return null

func java_method_effect_11(_args: Array = []) -> Variant:
	return null

func java_method_effect_12(_args: Array = []) -> Variant:
	return null

func java_method_effectReliable_13(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_14(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_15(_args: Array = []) -> Variant:
	return null

func java_method_sendChatMessage_16(_args: Array = []) -> Variant:
	return null

func java_method_connect_17(_args: Array = []) -> Variant:
	return null

func java_method_ping_18(_args: Array = []) -> Variant:
	return null

func java_method_pingResponse_19(_args: Array = []) -> Variant:
	return null

func java_method_traceInfo_20(_args: Array = []) -> Variant:
	return null

func java_method_kick_21(_args: Array = []) -> Variant:
	return null

func java_method_kick_22(_args: Array = []) -> Variant:
	return null

func java_method_setRules_23(_args: Array = []) -> Variant:
	return null

func java_method_setRule_24(_args: Array = []) -> Variant:
	return null

func java_method_setObjectives_25(_args: Array = []) -> Variant:
	return null

func java_method_clearObjectives_26(_args: Array = []) -> Variant:
	return null

func java_method_completeObjective_27(_args: Array = []) -> Variant:
	return null

func java_method_worldDataBegin_28(_args: Array = []) -> Variant:
	return null

func java_method_setPosition_29(_args: Array = []) -> Variant:
	return null

func java_method_setCameraPosition_30(_args: Array = []) -> Variant:
	return null

func java_method_playerDisconnect_31(_args: Array = []) -> Variant:
	return null

func java_method_readSyncEntity_32(_args: Array = []) -> Variant:
	return null

func java_method_entitySnapshot_33(_args: Array = []) -> Variant:
	return null

func java_method_hiddenSnapshot_34(_args: Array = []) -> Variant:
	return null

func java_method_blockSnapshot_35(_args: Array = []) -> Variant:
	return null

func java_method_stateSnapshot_36(_args: Array = []) -> Variant:
	return null

func java_method_update_37(_args: Array = []) -> Variant:
	return null

func java_method_resetTimeout_38(_args: Array = []) -> Variant:
	return null

func java_method_isConnecting_39(_args: Array = []) -> Variant:
	return null

func java_method_getPing_40(_args: Array = []) -> Variant:
	return null

func java_method_finishConnecting_41(_args: Array = []) -> Variant:
	return null

func java_method_reset_42(_args: Array = []) -> Variant:
	return null

func java_method_beginConnecting_43(_args: Array = []) -> Variant:
	return null

func java_method_disconnectQuietly_44(_args: Array = []) -> Variant:
	return null

func java_method_disconnectNoReset_45(_args: Array = []) -> Variant:
	return null

func java_method_setQuiet_46(_args: Array = []) -> Variant:
	return null

func java_method_clearRemovedEntity_47(_args: Array = []) -> Variant:
	return null

func java_method_addRemovedEntity_48(_args: Array = []) -> Variant:
	return null

func java_method_isEntityUsed_49(_args: Array = []) -> Variant:
	return null

func java_method_sync_50(_args: Array = []) -> Variant:
	return null

func java_method_getUsid_51(_args: Array = []) -> Variant:
	return null
