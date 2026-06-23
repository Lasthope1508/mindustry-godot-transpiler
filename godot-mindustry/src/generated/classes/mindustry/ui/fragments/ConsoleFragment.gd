# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/ConsoleFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "ConsoleFragment"
const JAVA_EXTENDS := "Table"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "messagesShown", "type": "int"}, {"modifiers": ["private"], "name": "messages", "type": "Seq"}, {"modifiers": ["private"], "name": "open", "type": "boolean"}, {"modifiers": ["private"], "name": "shown", "type": "boolean"}, {"modifiers": ["private"], "name": "chatfield", "type": "TextField"}, {"modifiers": ["private"], "name": "fieldlabel", "type": "Label"}, {"modifiers": ["private"], "name": "font", "type": "Font"}, {"modifiers": ["private"], "name": "layout", "type": "GlyphLayout"}, {"modifiers": ["private"], "name": "offsetx", "type": "float"}, {"modifiers": ["private"], "name": "offsety", "type": "float"}, {"modifiers": ["private"], "name": "fontoffsetx", "type": "float"}, {"modifiers": ["private"], "name": "chatspace", "type": "float"}, {"modifiers": ["private"], "name": "shadowColor", "type": "Color"}, {"modifiers": ["private"], "name": "textspacing", "type": "float"}, {"modifiers": ["private"], "name": "history", "type": "Seq"}, {"modifiers": ["private"], "name": "historyPos", "type": "int"}, {"modifiers": ["private"], "name": "scrollPos", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "ConsoleFragment", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearMessages", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "rect", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "w", "type": "float", "varargs": false}, {"name": "h", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "sendMessage", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "injectConsoleVariables", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "toggleMobile", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "toggle", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hide", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateChat", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "clearChatInput", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "open", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shown", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "addMessage", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_build_0(_args: Array = []) -> Variant:
	return null

func java_method_clearMessages_1(_args: Array = []) -> Variant:
	return null

func java_method_setup_2(_args: Array = []) -> Variant:
	return null

func java_method_rect_3(_args: Array = []) -> Variant:
	return null

func java_method_draw_4(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_5(_args: Array = []) -> Variant:
	return null

func java_method_injectConsoleVariables_6(_args: Array = []) -> Variant:
	return null

func java_method_toggleMobile_7(_args: Array = []) -> Variant:
	return null

func java_method_toggle_8(_args: Array = []) -> Variant:
	return null

func java_method_hide_9(_args: Array = []) -> Variant:
	return null

func java_method_updateChat_10(_args: Array = []) -> Variant:
	return null

func java_method_clearChatInput_11(_args: Array = []) -> Variant:
	return null

func java_method_open_12(_args: Array = []) -> Variant:
	return null

func java_method_shown_13(_args: Array = []) -> Variant:
	return null

func java_method_addMessage_14(_args: Array = []) -> Variant:
	return null
