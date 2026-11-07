# Generated from Mindustry upstream.
# Source: android/src/mindustry/android/AndroidLauncher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.android"
const JAVA_KIND := "class"
const JAVA_NAME := "AndroidLauncher"
const JAVA_EXTENDS := "AndroidApplication"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "PERMISSION_REQUEST_CODE", "type": "int"}, {"modifiers": [], "name": "doubleScaleTablets", "type": "boolean"}, {"modifiers": [], "name": "chooser", "type": "FileChooserDialog"}, {"modifiers": [], "name": "permCallback", "type": "Runnable"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "onCreate", "parameters": [{"name": "savedInstanceState", "type": "Bundle", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onRequestPermissionsResult", "parameters": [{"name": "requestCode", "type": "int", "varargs": false}, {"name": "permissions", "type": "String", "varargs": false}, {"name": "grantResults", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "checkFiles", "parameters": [{"name": "intent", "type": "Intent", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "isTablet", "parameters": [{"name": "context", "type": "Context", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_onCreate_0(_args: Array = []) -> Variant:
	return null

func java_method_onRequestPermissionsResult_1(_args: Array = []) -> Variant:
	return null

func java_method_checkFiles_2(_args: Array = []) -> Variant:
	return null

func java_method_isTablet_3(_args: Array = []) -> Variant:
	return null
