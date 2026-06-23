# Generated from Mindustry upstream.
# Source: mindustry/logic/LCanvas.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.logic"
const JAVA_KIND := "class"
const JAVA_NAME := "LCanvas"
const JAVA_EXTENDS := "Table"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "tmpOccupiers1", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "tmpOccupiers2", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "tmpBits1", "type": "Bits"}, {"modifiers": ["final", "private", "static"], "name": "tmpBits2", "type": "Bits"}, {"modifiers": ["final", "private", "static"], "name": "invalidJump", "type": "int"}, {"modifiers": ["static"], "name": "canvas", "type": "LCanvas"}, {"modifiers": ["final", "private", "static"], "name": "dynamicJumpHeights", "type": "boolean"}, {"modifiers": ["public"], "name": "statements", "type": "DragLayout"}, {"modifiers": ["public"], "name": "pane", "type": "ScrollPane"}, {"modifiers": [], "name": "dragging", "type": "StatementElem"}, {"modifiers": [], "name": "hovered", "type": "StatementElem"}, {"modifiers": [], "name": "targetWidth", "type": "float"}, {"modifiers": [], "name": "privileged", "type": "boolean"}, {"modifiers": [], "name": "tooltips", "type": "Seq"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LCanvas", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "useRows", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "tooltip", "parameters": [{"name": "cell", "type": "Cell", "varargs": false}, {"name": "key", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tooltip", "parameters": [{"name": "cell", "type": "Cell", "varargs": false}, {"name": "key", "type": "Enum", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rebuild", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [{"name": "statement", "type": "LStatement", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addAt", "parameters": [{"name": "at", "type": "int", "varargs": false}, {"name": "statement", "type": "LStatement", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "save", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "load", "parameters": [{"name": "asm", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearStatements", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "checkHovered", "parameters": [], "return_type": "StatementElem"}, {"modifiers": ["public"], "name": "act", "parameters": [{"name": "delta", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_useRows_0(_args: Array = []) -> Variant:
	return null

func java_method_tooltip_1(_args: Array = []) -> Variant:
	return null

func java_method_tooltip_2(_args: Array = []) -> Variant:
	return null

func java_method_rebuild_3(_args: Array = []) -> Variant:
	return null

func java_method_add_4(_args: Array = []) -> Variant:
	return null

func java_method_addAt_5(_args: Array = []) -> Variant:
	return null

func java_method_save_6(_args: Array = []) -> Variant:
	return null

func java_method_load_7(_args: Array = []) -> Variant:
	return null

func java_method_clearStatements_8(_args: Array = []) -> Variant:
	return null

func java_method_checkHovered_9(_args: Array = []) -> Variant:
	return null

func java_method_act_10(_args: Array = []) -> Variant:
	return null
