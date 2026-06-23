# Generated from Mindustry upstream.
# Source: mindustry/ui/Menus.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui"
const JAVA_KIND := "class"
const JAVA_NAME := "Menus"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "menuListeners", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "textInputListeners", "type": "Seq"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "registerMenu", "parameters": [{"name": "listener", "type": "MenuListener", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "registerTextInput", "parameters": [{"name": "listener", "type": "TextInputListener", "varargs": false}], "return_type": "int"}, {"modifiers": ["public", "static"], "name": "menu", "parameters": [{"name": "menuId", "type": "int", "varargs": false}, {"name": "title", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}, {"name": "options", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "followUpMenu", "parameters": [{"name": "menuId", "type": "int", "varargs": false}, {"name": "title", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}, {"name": "options", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "hideFollowUpMenu", "parameters": [{"name": "menuId", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "menuChoose", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "menuId", "type": "int", "varargs": false}, {"name": "option", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "textInput", "parameters": [{"name": "textInputId", "type": "int", "varargs": false}, {"name": "title", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}, {"name": "textLength", "type": "int", "varargs": false}, {"name": "def", "type": "String", "varargs": false}, {"name": "numeric", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "textInput", "parameters": [{"name": "textInputId", "type": "int", "varargs": false}, {"name": "title", "type": "String", "varargs": false}, {"name": "message", "type": "String", "varargs": false}, {"name": "textLength", "type": "int", "varargs": false}, {"name": "def", "type": "String", "varargs": false}, {"name": "numeric", "type": "boolean", "varargs": false}, {"name": "allowEmpty", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "textInputResult", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "textInputId", "type": "int", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setHudText", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "hideHudText", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setHudTextReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "announce", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoMessage", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoPopup", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}, {"name": "top", "type": "int", "varargs": false}, {"name": "left", "type": "int", "varargs": false}, {"name": "bottom", "type": "int", "varargs": false}, {"name": "right", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoPopupReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}, {"name": "top", "type": "int", "varargs": false}, {"name": "left", "type": "int", "varargs": false}, {"name": "bottom", "type": "int", "varargs": false}, {"name": "right", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoPopup", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}, {"name": "top", "type": "int", "varargs": false}, {"name": "left", "type": "int", "varargs": false}, {"name": "bottom", "type": "int", "varargs": false}, {"name": "right", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoPopupReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "align", "type": "int", "varargs": false}, {"name": "top", "type": "int", "varargs": false}, {"name": "left", "type": "int", "varargs": false}, {"name": "bottom", "type": "int", "varargs": false}, {"name": "right", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "label", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}, {"name": "flags", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "labelReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}, {"name": "flags", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "label", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "labelReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "label", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "labelReliable", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "worldx", "type": "float", "varargs": false}, {"name": "worldy", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "infoToast", "parameters": [{"name": "message", "type": "String", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "warningToast", "parameters": [{"name": "unicode", "type": "int", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "openURI", "parameters": [{"name": "uri", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "copyToClipboard", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "removeWorldLabel", "parameters": [{"name": "id", "type": "int", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_registerMenu_0(_args: Array = []) -> Variant:
	return null

func java_method_registerTextInput_1(_args: Array = []) -> Variant:
	return null

func java_method_menu_2(_args: Array = []) -> Variant:
	return null

func java_method_followUpMenu_3(_args: Array = []) -> Variant:
	return null

func java_method_hideFollowUpMenu_4(_args: Array = []) -> Variant:
	return null

func java_method_menuChoose_5(_args: Array = []) -> Variant:
	return null

func java_method_textInput_6(_args: Array = []) -> Variant:
	return null

func java_method_textInput_7(_args: Array = []) -> Variant:
	return null

func java_method_textInputResult_8(_args: Array = []) -> Variant:
	return null

func java_method_setHudText_9(_args: Array = []) -> Variant:
	return null

func java_method_hideHudText_10(_args: Array = []) -> Variant:
	return null

func java_method_setHudTextReliable_11(_args: Array = []) -> Variant:
	return null

func java_method_announce_12(_args: Array = []) -> Variant:
	return null

func java_method_infoMessage_13(_args: Array = []) -> Variant:
	return null

func java_method_infoPopup_14(_args: Array = []) -> Variant:
	return null

func java_method_infoPopupReliable_15(_args: Array = []) -> Variant:
	return null

func java_method_infoPopup_16(_args: Array = []) -> Variant:
	return null

func java_method_infoPopupReliable_17(_args: Array = []) -> Variant:
	return null

func java_method_label_18(_args: Array = []) -> Variant:
	return null

func java_method_labelReliable_19(_args: Array = []) -> Variant:
	return null

func java_method_label_20(_args: Array = []) -> Variant:
	return null

func java_method_labelReliable_21(_args: Array = []) -> Variant:
	return null

func java_method_label_22(_args: Array = []) -> Variant:
	return null

func java_method_labelReliable_23(_args: Array = []) -> Variant:
	return null

func java_method_infoToast_24(_args: Array = []) -> Variant:
	return null

func java_method_warningToast_25(_args: Array = []) -> Variant:
	return null

func java_method_openURI_26(_args: Array = []) -> Variant:
	return null

func java_method_copyToClipboard_27(_args: Array = []) -> Variant:
	return null

func java_method_removeWorldLabel_28(_args: Array = []) -> Variant:
	return null
