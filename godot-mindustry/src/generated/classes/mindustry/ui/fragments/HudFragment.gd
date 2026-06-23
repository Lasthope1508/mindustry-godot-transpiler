# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/HudFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "HudFragment"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "dsize", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "pauseHeight", "type": "float"}, {"modifiers": ["public"], "name": "blockfrag", "type": "PlacementFragment"}, {"modifiers": ["public"], "name": "coreItems", "type": "CoreItemsDisplay"}, {"modifiers": ["public"], "name": "shown", "type": "boolean"}, {"modifiers": ["private"], "name": "flip", "type": "ImageButton"}, {"modifiers": ["private"], "name": "hudText", "type": "String"}, {"modifiers": ["private"], "name": "showHudText", "type": "boolean"}, {"modifiers": ["private"], "name": "lastUnlockTable", "type": "Table"}, {"modifiers": ["private"], "name": "lastUnlockLayout", "type": "Table"}, {"modifiers": ["private"], "name": "lastToast", "type": "long"}, {"modifiers": ["private"], "name": "pauseDisableDur", "type": "float"}, {"modifiers": ["private"], "name": "blocksOut", "type": "Seq"}, {"modifiers": ["private"], "name": "hudLabel", "type": "Table"}, {"modifiers": ["private"], "name": "coreAttackTime", "type": "float"}, {"modifiers": ["private", "static"], "name": "favoriteBlocks", "type": "ObjectSet"}, {"modifiers": ["private", "static"], "name": "lastFavorited", "type": "String"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["private"], "name": "addBlockSelection", "parameters": [{"name": "cont", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "loadFavorites", "parameters": [], "return_type": ""}, {"modifiers": ["private", "static"], "name": "saveFavorites", "parameters": [], "return_type": ""}, {"modifiers": ["private", "static"], "name": "isFavorite", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private", "static"], "name": "toggleFavorite", "parameters": [{"name": "block", "type": "Block", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "rebuildBlockSelection", "parameters": [{"name": "blockSelection", "type": "Table", "varargs": false}, {"name": "searchText", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "setPlayerTeamEditor", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "setHudText", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toggleHudText", "parameters": [{"name": "shown", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "scheduleToast", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hasToast", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "showToast", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showToast", "parameters": [{"name": "icon", "type": "Drawable", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showToast", "parameters": [{"name": "icon", "type": "Drawable", "varargs": false}, {"name": "size", "type": "float", "varargs": false}, {"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showPauseDisabled", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showUnlock", "parameters": [{"name": "content", "type": "UnlockableContent", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "toggleMenus", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "makeStatusTable", "parameters": [], "return_type": "Table"}, {"modifiers": ["private"], "name": "addInfoTable", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "canSkipWave", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_addBlockSelection_0(_args: Array = []) -> Variant:
	return null

func java_method_loadFavorites_1(_args: Array = []) -> Variant:
	return null

func java_method_saveFavorites_2(_args: Array = []) -> Variant:
	return null

func java_method_isFavorite_3(_args: Array = []) -> Variant:
	return null

func java_method_toggleFavorite_4(_args: Array = []) -> Variant:
	return null

func java_method_rebuildBlockSelection_5(_args: Array = []) -> Variant:
	return null

func java_method_build_6(_args: Array = []) -> Variant:
	return null

func java_method_setPlayerTeamEditor_7(_args: Array = []) -> Variant:
	return null

func java_method_setHudText_8(_args: Array = []) -> Variant:
	return null

func java_method_toggleHudText_9(_args: Array = []) -> Variant:
	return null

func java_method_scheduleToast_10(_args: Array = []) -> Variant:
	return null

func java_method_hasToast_11(_args: Array = []) -> Variant:
	return null

func java_method_showToast_12(_args: Array = []) -> Variant:
	return null

func java_method_showToast_13(_args: Array = []) -> Variant:
	return null

func java_method_showToast_14(_args: Array = []) -> Variant:
	return null

func java_method_showPauseDisabled_15(_args: Array = []) -> Variant:
	return null

func java_method_showUnlock_16(_args: Array = []) -> Variant:
	return null

func java_method_toggleMenus_17(_args: Array = []) -> Variant:
	return null

func java_method_makeStatusTable_18(_args: Array = []) -> Variant:
	return null

func java_method_addInfoTable_19(_args: Array = []) -> Variant:
	return null

func java_method_canSkipWave_20(_args: Array = []) -> Variant:
	return null
