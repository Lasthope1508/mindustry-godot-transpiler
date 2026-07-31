# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/power/PowerGraph.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.power"
const JAVA_KIND := "class"
const JAVA_NAME := "PowerGraph"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "queue", "type": "Queue"}, {"modifiers": ["final", "private", "static"], "name": "outArray1", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "outArray2", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "closedSet", "type": "IntSet"}, {"modifiers": ["final", "public"], "name": "producers", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "consumers", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "batteries", "type": "Seq"}, {"modifiers": ["final", "public"], "name": "all", "type": "Seq"}, {"modifiers": ["final", "private"], "name": "entity", "type": "PowerGraphUpdater"}, {"modifiers": ["final", "private"], "name": "powerBalance", "type": "WindowedMean"}, {"modifiers": ["private"], "name": "lastPowerProduced", "type": "float"}, {"modifiers": ["private"], "name": "lastPowerNeeded", "type": "float"}, {"modifiers": ["private"], "name": "lastPowerStored", "type": "float"}, {"modifiers": ["private"], "name": "lastScaledPowerIn", "type": "float"}, {"modifiers": ["private"], "name": "lastScaledPowerOut", "type": "float"}, {"modifiers": ["private"], "name": "lastCapacity", "type": "float"}, {"modifiers": ["private"], "name": "energyDelta", "type": "float"}, {"modifiers": ["final", "private"], "name": "graphID", "type": "int"}, {"modifiers": ["private", "static"], "name": "lastGraphID", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PowerGraph", "parameters": []}, {"modifiers": ["public"], "name": "PowerGraph", "parameters": [{"name": "noEntity", "type": "boolean", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getID", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "getLastScaledPowerIn", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastScaledPowerOut", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerBalance", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "hasPowerBalanceSamples", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getLastPowerNeeded", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastPowerProduced", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getLastPowerStored", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "transferPower", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getSatisfaction", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerProduced", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getPowerNeeded", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getBatteryStored", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getBatteryCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "getTotalBatteryCapacity", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "useBatteries", "parameters": [{"name": "needed", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "chargeBatteries", "parameters": [{"name": "excess", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "distributePower", "parameters": [{"name": "needed", "type": "float", "varargs": false}, {"name": "produced", "type": "float", "varargs": false}, {"name": "charged", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "addGraph", "parameters": [{"name": "graph", "type": "PowerGraph", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAdd", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reflow", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "removeList", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "tile", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getId", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getID_0(_args: Array = []) -> Variant:
	return null

func java_method_getLastScaledPowerIn_1(_args: Array = []) -> Variant:
	return null

func java_method_getLastScaledPowerOut_2(_args: Array = []) -> Variant:
	return null

func java_method_getLastCapacity_3(_args: Array = []) -> Variant:
	return null

func java_method_getPowerBalance_4(_args: Array = []) -> Variant:
	return null

func java_method_hasPowerBalanceSamples_5(_args: Array = []) -> Variant:
	return null

func java_method_getLastPowerNeeded_6(_args: Array = []) -> Variant:
	return null

func java_method_getLastPowerProduced_7(_args: Array = []) -> Variant:
	return null

func java_method_getLastPowerStored_8(_args: Array = []) -> Variant:
	return null

func java_method_transferPower_9(_args: Array = []) -> Variant:
	return null

func java_method_getSatisfaction_10(_args: Array = []) -> Variant:
	return null

func java_method_getPowerProduced_11(_args: Array = []) -> Variant:
	return null

func java_method_getPowerNeeded_12(_args: Array = []) -> Variant:
	return null

func java_method_getBatteryStored_13(_args: Array = []) -> Variant:
	return null

func java_method_getBatteryCapacity_14(_args: Array = []) -> Variant:
	return null

func java_method_getTotalBatteryCapacity_15(_args: Array = []) -> Variant:
	return null

func java_method_useBatteries_16(_args: Array = []) -> Variant:
	return null

func java_method_chargeBatteries_17(_args: Array = []) -> Variant:
	return null

func java_method_distributePower_18(_args: Array = []) -> Variant:
	return null

func java_method_update_19(_args: Array = []) -> Variant:
	return null

func java_method_addGraph_20(_args: Array = []) -> Variant:
	return null

func java_method_add_21(_args: Array = []) -> Variant:
	return null

func java_method_checkAdd_22(_args: Array = []) -> Variant:
	return null

func java_method_clear_23(_args: Array = []) -> Variant:
	return null

func java_method_reflow_24(_args: Array = []) -> Variant:
	return null

func java_method_removeList_25(_args: Array = []) -> Variant:
	return null

func java_method_remove_26(_args: Array = []) -> Variant:
	return null

func java_method_getId_27(_args: Array = []) -> Variant:
	var graph_id: int = int(_args[0] if _args.size() > 0 else 0)
	return {"source_owner": "port_game.source_power_graph_get_id_state", "source": "core/src/mindustry/world/blocks/power/PowerGraph.java", "method": "public int getId(){", "return_graph_id": "return graphID;", "graph_id": graph_id}

func java_method_toString_28(_args: Array = []) -> Variant:
	return null
