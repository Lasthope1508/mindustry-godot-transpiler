# Generated from Mindustry upstream.
# Source: desktop/src/mindustry/desktop/DesktopLauncher.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.desktop"
const JAVA_KIND := "class"
const JAVA_NAME := "DesktopLauncher"
const JAVA_EXTENDS := "ClientLauncher"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "discordID", "type": "long"}, {"modifiers": ["final", "public"], "name": "args", "type": "String"}, {"modifiers": [], "name": "useDiscord", "type": "boolean"}, {"modifiers": [], "name": "loadError", "type": "boolean"}, {"modifiers": [], "name": "steamError", "type": "Throwable"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "DesktopLauncher", "parameters": [{"name": "args", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "main", "parameters": [{"name": "arg", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "checkJavaVersion", "parameters": [], "return_type": ""}, {"modifiers": ["static"], "name": "check32Bit", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "logSteamError", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "initSteam", "parameters": [{"name": "args", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["static"], "name": "handleCrash", "parameters": [{"name": "e", "type": "Throwable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showFileChooser", "parameters": [{"name": "params", "type": "FileChooserParams", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getWorkshopContent", "parameters": [{"name": "type", "type": "Class", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "viewListing", "parameters": [{"name": "pub", "type": "Publishable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "viewListingID", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getNet", "parameters": [], "return_type": "NetProvider"}, {"modifiers": ["public"], "name": "openWorkshop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "publish", "parameters": [{"name": "pub", "type": "Publishable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "inviteFriends", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateLobby", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateRPC", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getUUID", "parameters": [], "return_type": "String"}, {"modifiers": ["private", "static"], "name": "message", "parameters": [{"name": "message", "type": "String", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_main_0(_args: Array = []) -> Variant:
	return null

func java_method_checkJavaVersion_1(_args: Array = []) -> Variant:
	return null

func java_method_check32Bit_2(_args: Array = []) -> Variant:
	return null

func java_method_logSteamError_3(_args: Array = []) -> Variant:
	return null

func java_method_initSteam_4(_args: Array = []) -> Variant:
	return null

func java_method_handleCrash_5(_args: Array = []) -> Variant:
	return null

func java_method_showFileChooser_6(_args: Array = []) -> Variant:
	return null

func java_method_getWorkshopContent_7(_args: Array = []) -> Variant:
	return null

func java_method_viewListing_8(_args: Array = []) -> Variant:
	return null

func java_method_viewListingID_9(_args: Array = []) -> Variant:
	return null

func java_method_getNet_10(_args: Array = []) -> Variant:
	return null

func java_method_openWorkshop_11(_args: Array = []) -> Variant:
	return null

func java_method_publish_12(_args: Array = []) -> Variant:
	return null

func java_method_inviteFriends_13(_args: Array = []) -> Variant:
	return null

func java_method_updateLobby_14(_args: Array = []) -> Variant:
	return null

func java_method_updateRPC_15(_args: Array = []) -> Variant:
	return null

func java_method_getUUID_16(_args: Array = []) -> Variant:
	return null

func java_method_message_17(_args: Array = []) -> Variant:
	return null
