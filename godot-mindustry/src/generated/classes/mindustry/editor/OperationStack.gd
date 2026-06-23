# Generated from Mindustry upstream.
# Source: mindustry/editor/OperationStack.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "OperationStack"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "maxSize", "type": "int"}, {"modifiers": ["private"], "name": "stack", "type": "Seq"}, {"modifiers": ["private"], "name": "index", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "OperationStack", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "clear", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "action", "type": "DrawOperation", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "canUndo", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canRedo", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "undo", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "redo", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_clear_0(_args: Array = []) -> Variant:
	return null

func java_method_add_1(_args: Array = []) -> Variant:
	return null

func java_method_canUndo_2(_args: Array = []) -> Variant:
	return null

func java_method_canRedo_3(_args: Array = []) -> Variant:
	return null

func java_method_undo_4(_args: Array = []) -> Variant:
	return null

func java_method_redo_5(_args: Array = []) -> Variant:
	return null
