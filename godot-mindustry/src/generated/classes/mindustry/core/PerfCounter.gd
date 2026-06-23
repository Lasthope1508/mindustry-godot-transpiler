# Generated from Mindustry upstream.
# Source: mindustry/core/PerfCounter.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "enum"
const JAVA_NAME := "PerfCounter"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "all", "type": "PerfCounter"}, {"modifiers": ["final", "static"], "name": "meanWindow", "type": "int"}, {"modifiers": ["final", "static"], "name": "refreshTimeMillis", "type": "int"}, {"modifiers": ["private"], "name": "valueRefreshTime", "type": "long"}, {"modifiers": ["private"], "name": "refreshValue", "type": "float"}, {"modifiers": ["private"], "name": "beginTime", "type": "long"}, {"modifiers": ["private"], "name": "began", "type": "boolean"}, {"modifiers": ["private"], "name": "mean", "type": "WindowedMean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "begin", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "end", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "valueMs", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "rawValueMs", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "rawValueNs", "parameters": [], "return_type": "long"}]
const JAVA_ENUM_CONSTANTS := ["frame", "update", "entityUpdate", "buildingUpdate", "unitUpdate", "ui", "render"]

func java_method_begin_0(_args: Array = []) -> Variant:
	return null

func java_method_end_1(_args: Array = []) -> Variant:
	return null

func java_method_valueMs_2(_args: Array = []) -> Variant:
	return null

func java_method_rawValueMs_3(_args: Array = []) -> Variant:
	return null

func java_method_rawValueNs_4(_args: Array = []) -> Variant:
	return null
