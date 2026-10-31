# Generated from Mindustry upstream.
# Source: mindustry/world/modules/LiquidModule.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.modules"
const JAVA_KIND := "class"
const JAVA_NAME := "LiquidModule"
const JAVA_EXTENDS := "BlockModule"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "windowSize", "type": "int"}, {"modifiers": ["final", "private", "static"], "name": "flowTimer", "type": "Interval"}, {"modifiers": ["final", "private", "static"], "name": "pollScl", "type": "float"}, {"modifiers": ["private", "static"], "name": "cacheFlow", "type": "WindowedMean"}, {"modifiers": ["private", "static"], "name": "cacheSums", "type": "float"}, {"modifiers": ["private", "static"], "name": "displayFlow", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "cacheBits", "type": "Bits"}, {"modifiers": ["private"], "name": "liquids", "type": "float"}, {"modifiers": ["private"], "name": "current", "type": "Liquid"}, {"modifiers": ["private"], "name": "flow", "type": "WindowedMean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "updateFlow", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "stopFlow", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getFlowRate", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "hasFlowLiquid", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "current", "parameters": [], "return_type": "Liquid"}, {"modifiers": ["public"], "name": "reset", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "set", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "currentAmount", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "get", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "handleFlow", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [{"name": "liquid", "type": "Liquid", "varargs": false}, {"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "each", "parameters": [{"name": "cons", "type": "LiquidConsumer", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sum", "parameters": [{"name": "calc", "type": "LiquidCalculator", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "checkArrayCapacity", "parameters": [{"name": "size", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "write", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "read", "parameters": [{"name": "read", "type": "Reads", "varargs": false}, {"name": "legacy", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
const source_liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")

func java_method_updateFlow_0(_args: Array = []) -> Variant:
	return null

func java_method_stopFlow_1(_args: Array = []) -> Variant:
	return null

func java_method_getFlowRate_2(_args: Array = []) -> Variant:
	return null

func java_method_hasFlowLiquid_3(_args: Array = []) -> Variant:
	return null

func java_method_current_4(_args: Array = []) -> Variant:
	return null

func java_method_reset_5(_args: Array = []) -> Variant:
	return null

func java_method_set_6(_args: Array = []) -> Variant:
	return null

func java_method_currentAmount_7(_args: Array = []) -> Variant:
	return null

func java_method_get_8(_args: Array = []) -> Variant:
	var self_state: Dictionary = _args[0]
	var liquid_id: int = int(_args[1])
	return source_liquid_module_state.source_get_state(self_state, liquid_id)

func java_method_clear_9(_args: Array = []) -> Variant:
	return null

func java_method_add_10(_args: Array = []) -> Variant:
	var self_state: Dictionary = _args[0]
	var liquid_id: int = int(_args[1])
	var amount: float = float(_args[2])
	var cache_sums: Array = _args[3]
	return source_liquid_module_state.source_add_state(self_state, liquid_id, amount, cache_sums)

func java_method_handleFlow_11(_args: Array = []) -> Variant:
	return null

func java_method_remove_12(_args: Array = []) -> Variant:
	var self_state: Dictionary = _args[0]
	var liquid_id: int = int(_args[1])
	var amount: float = float(_args[2])
	var cache_sums: Array = _args[3]
	return source_liquid_module_state.source_remove_state(self_state, liquid_id, amount, cache_sums)

func java_method_each_13(_args: Array = []) -> Variant:
	return null

func java_method_sum_14(_args: Array = []) -> Variant:
	return null

func java_method_checkArrayCapacity_15(_args: Array = []) -> Variant:
	return null

func java_method_write_16(_args: Array = []) -> Variant:
	return null

func java_method_read_17(_args: Array = []) -> Variant:
	return null
