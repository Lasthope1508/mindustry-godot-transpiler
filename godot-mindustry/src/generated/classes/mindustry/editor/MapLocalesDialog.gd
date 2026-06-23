# Generated from Mindustry upstream.
# Source: mindustry/editor/MapLocalesDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.editor"
const JAVA_KIND := "class"
const JAVA_NAME := "MapLocalesDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "cardWidth", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "filterStyle", "type": "TextButtonStyle"}, {"modifiers": ["final", "private", "static"], "name": "contentIcons", "type": "ContentType"}, {"modifiers": ["private"], "name": "locales", "type": "MapLocales"}, {"modifiers": ["private"], "name": "lastSaved", "type": "MapLocales"}, {"modifiers": ["private"], "name": "saved", "type": "boolean"}, {"modifiers": ["private"], "name": "langs", "type": "Table"}, {"modifiers": ["private"], "name": "main", "type": "Table"}, {"modifiers": ["private"], "name": "propView", "type": "Table"}, {"modifiers": ["private"], "name": "selectedLocale", "type": "String"}, {"modifiers": ["private"], "name": "applytoall", "type": "boolean"}, {"modifiers": ["private"], "name": "collapsed", "type": "boolean"}, {"modifiers": ["private"], "name": "searchString", "type": "String"}, {"modifiers": ["private"], "name": "searchByValue", "type": "boolean"}, {"modifiers": ["private"], "name": "showCorrect", "type": "boolean"}, {"modifiers": ["private"], "name": "showMissing", "type": "boolean"}, {"modifiers": ["private"], "name": "showSame", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "MapLocalesDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "show", "parameters": [{"name": "locales", "type": "MapLocales", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "buildTables", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "buildLocalesTable", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "buildMain", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "updateCard", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "propKey", "type": "String", "varargs": false}, {"name": "propValue", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "updateCard", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "propKey", "type": "String", "varargs": false}, {"name": "propValue", "type": "String", "varargs": false}, {"name": "locale", "type": "String", "varargs": false}, {"name": "viewCard", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "getPropertyStatus", "parameters": [{"name": "propKey", "type": "String", "varargs": false}, {"name": "propValue", "type": "String", "varargs": false}, {"name": "locale", "type": "String", "varargs": false}, {"name": "forView", "type": "boolean", "varargs": false}], "return_type": "PropertyStatus"}, {"modifiers": ["private"], "name": "addLocaleDialog", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "propEditDialog", "parameters": [{"name": "card", "type": "Table", "varargs": false}, {"name": "key", "type": "String", "varargs": false}, {"name": "value", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "localeEditDialog", "parameters": [{"name": "locale", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "editDialog", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "viewPropertyDialog", "parameters": [{"name": "key", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "buildPropView", "parameters": [{"name": "key", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "filterDialog", "parameters": [{"name": "hidden", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "addIconDialog", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "iconsTable", "parameters": [{"name": "table", "type": "Table", "varargs": false}, {"name": "search", "type": "String", "varargs": false}, {"name": "dialog", "type": "Dialog", "varargs": false}, {"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "writeBundles", "parameters": [], "return_type": "String"}, {"modifiers": ["private"], "name": "writeLocale", "parameters": [{"name": "key", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "readBundles", "parameters": [{"name": "data", "type": "String", "varargs": false}], "return_type": "MapLocales"}, {"modifiers": ["private"], "name": "readLocale", "parameters": [{"name": "data", "type": "String", "varargs": false}], "return_type": "StringMap"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_show_0(_args: Array = []) -> Variant:
	return null

func java_method_setup_1(_args: Array = []) -> Variant:
	return null

func java_method_buildTables_2(_args: Array = []) -> Variant:
	return null

func java_method_buildLocalesTable_3(_args: Array = []) -> Variant:
	return null

func java_method_buildMain_4(_args: Array = []) -> Variant:
	return null

func java_method_updateCard_5(_args: Array = []) -> Variant:
	return null

func java_method_updateCard_6(_args: Array = []) -> Variant:
	return null

func java_method_getPropertyStatus_7(_args: Array = []) -> Variant:
	return null

func java_method_addLocaleDialog_8(_args: Array = []) -> Variant:
	return null

func java_method_propEditDialog_9(_args: Array = []) -> Variant:
	return null

func java_method_localeEditDialog_10(_args: Array = []) -> Variant:
	return null

func java_method_editDialog_11(_args: Array = []) -> Variant:
	return null

func java_method_viewPropertyDialog_12(_args: Array = []) -> Variant:
	return null

func java_method_buildPropView_13(_args: Array = []) -> Variant:
	return null

func java_method_filterDialog_14(_args: Array = []) -> Variant:
	return null

func java_method_addIconDialog_15(_args: Array = []) -> Variant:
	return null

func java_method_iconsTable_16(_args: Array = []) -> Variant:
	return null

func java_method_writeBundles_17(_args: Array = []) -> Variant:
	return null

func java_method_writeLocale_18(_args: Array = []) -> Variant:
	return null

func java_method_readBundles_19(_args: Array = []) -> Variant:
	return null

func java_method_readLocale_20(_args: Array = []) -> Variant:
	return null
