# Generated from Mindustry upstream.
# Source: ios/src/mindustry/ios/IOSLauncher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ios"
const JAVA_KIND := "class"
const JAVA_NAME := "IOSLauncher"
const JAVA_EXTENDS := "IOSApplication"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "forced", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "createApplication", "parameters": [], "return_type": "IOSApplication"}, {"modifiers": ["public"], "name": "getSupportedInterfaceOrientations", "parameters": [{"name": "application", "type": "UIApplication", "varargs": false}, {"name": "window", "type": "UIWindow", "varargs": false}], "return_type": "UIInterfaceOrientationMask"}, {"modifiers": ["public"], "name": "openURL", "parameters": [{"name": "app", "type": "UIApplication", "varargs": false}, {"name": "url", "type": "NSURL", "varargs": false}, {"name": "options", "type": "UIApplicationOpenURLOptions", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "didFinishLaunching", "parameters": [{"name": "application", "type": "UIApplication", "varargs": false}, {"name": "options", "type": "UIApplicationLaunchOptions", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "openURL", "parameters": [{"name": "url", "type": "NSURL", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "main", "parameters": [{"name": "argv", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_createApplication_0(_args: Array = []) -> Variant:
	return null

func java_method_getSupportedInterfaceOrientations_1(_args: Array = []) -> Variant:
	return null

func java_method_openURL_2(_args: Array = []) -> Variant:
	return null

func java_method_didFinishLaunching_3(_args: Array = []) -> Variant:
	return null

func java_method_openURL_4(_args: Array = []) -> Variant:
	return null

func java_method_main_5(_args: Array = []) -> Variant:
	return null
