# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/storage/CoreBlock.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.storage"
const JAVA_KIND := "class"
const JAVA_NAME := "CoreBlock"
const JAVA_EXTENDS := "StorageBlock"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "cloudScaling", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "cfinScl", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "cfinOffset", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "calphaFinOffset", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "cloudAlpha", "type": "float"}, {"modifiers": ["final", "public", "static"], "name": "cloudAlphas", "type": "float"}, {"modifiers": ["private", "static"], "name": "nextItems", "type": "ItemModule"}, {"modifiers": ["final", "public", "static"], "name": "thrusterSizes", "type": "float"}, {"modifiers": ["public"], "name": "thruster1", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "thruster2", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "thrusterLength", "type": "float"}, {"modifiers": ["public"], "name": "thrusterOffset", "type": "float"}, {"modifiers": ["public"], "name": "isFirstTier", "type": "boolean"}, {"modifiers": ["public"], "name": "allowSpawn", "type": "boolean"}, {"modifiers": ["public"], "name": "requiresCoreZone", "type": "boolean"}, {"modifiers": ["public"], "name": "incinerateNonBuildable", "type": "boolean"}, {"modifiers": ["public"], "name": "unitType", "type": "UnitType"}, {"modifiers": ["public"], "name": "landDuration", "type": "float"}, {"modifiers": ["public"], "name": "landMusic", "type": "Music"}, {"modifiers": ["public"], "name": "launchSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "landSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "launchSound", "type": "Sound"}, {"modifiers": ["public"], "name": "landSound", "type": "Sound"}, {"modifiers": ["public"], "name": "launchEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "landZoomInterp", "type": "Interp"}, {"modifiers": ["public"], "name": "landZoomFrom", "type": "float"}, {"modifiers": ["public"], "name": "landZoomTo", "type": "float"}, {"modifiers": ["public"], "name": "captureInvicibility", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "CoreBlock", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "playerSpawn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "player", "type": "Player", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "canBreak", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canReplace", "parameters": [{"name": "other", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canPlaceOn", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "placeBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "beforePlaceBegan", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "previous", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_playerSpawn_0(_args: Array = []) -> Variant:
	return null

func java_method_setStats_1(_args: Array = []) -> Variant:
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null

func java_method_init_3(_args: Array = []) -> Variant:
	return null

func java_method_postInit_4(_args: Array = []) -> Variant:
	return null

func java_method_canBreak_5(_args: Array = []) -> Variant:
	return null

func java_method_canReplace_6(_args: Array = []) -> Variant:
	return null

func java_method_canPlaceOn_7(_args: Array = []) -> Variant:
	return null

func java_method_placeBegan_8(_args: Array = []) -> Variant:
	return null

func java_method_beforePlaceBegan_9(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_10(_args: Array = []) -> Variant:
	return null
