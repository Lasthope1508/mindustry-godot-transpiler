# Generated from Mindustry upstream.
# Source: mindustry/ui/dialogs/PlanetDialog.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.dialogs"
const JAVA_KIND := "class"
const JAVA_NAME := "PlanetDialog"
const JAVA_EXTENDS := "BaseDialog"
const JAVA_IMPLEMENTS := ["PlanetInterfaceRenderer"]
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "debugSelect", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "debugSectorAttackEdit", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "debugShowNumbers", "type": "boolean"}, {"modifiers": ["public", "static"], "name": "sectorShowDuration", "type": "float"}, {"modifiers": ["final", "public"], "name": "buffer", "type": "FrameBuffer"}, {"modifiers": ["final", "public"], "name": "loadouts", "type": "LaunchLoadoutDialog"}, {"modifiers": ["final", "public"], "name": "planets", "type": "PlanetRenderer"}, {"modifiers": ["public"], "name": "state", "type": "PlanetParams"}, {"modifiers": ["public"], "name": "zoom", "type": "float"}, {"modifiers": ["public"], "name": "selected", "type": "Sector"}, {"modifiers": ["public"], "name": "hovered", "type": "Sector"}, {"modifiers": ["public"], "name": "launchSector", "type": "Sector"}, {"modifiers": ["public"], "name": "launchCandidates", "type": "Seq"}, {"modifiers": ["public"], "name": "mode", "type": "Mode"}, {"modifiers": ["public"], "name": "launching", "type": "boolean"}, {"modifiers": ["public"], "name": "listener", "type": "Cons"}, {"modifiers": ["public"], "name": "newPresets", "type": "Seq"}, {"modifiers": ["public"], "name": "presetShow", "type": "float"}, {"modifiers": ["public"], "name": "showed", "type": "boolean"}, {"modifiers": ["public"], "name": "sectorsShown", "type": "boolean"}, {"modifiers": ["public"], "name": "searchText", "type": "String"}, {"modifiers": ["public"], "name": "sectorTop", "type": "Table"}, {"modifiers": ["public"], "name": "notifs", "type": "Table"}, {"modifiers": ["public"], "name": "expandTable", "type": "Table"}, {"modifiers": ["public"], "name": "hoverLabel", "type": "Label"}, {"modifiers": ["private"], "name": "planetTextures", "type": "Texture"}, {"modifiers": ["private"], "name": "mainView", "type": "Element"}, {"modifiers": ["private"], "name": "selectDialog", "type": "SectorSelectDialog"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "PlanetDialog", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "show", "parameters": [], "return_type": "Dialog"}, {"modifiers": [], "name": "rebuildButtons", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addBack", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "addTech", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showOverview", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showPlanetLaunch", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "launchCandidates", "type": "Seq", "varargs": false}, {"name": "listener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showSelect", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "listener", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "lookAt", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "alpha", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "clampZoom", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "canSelect", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "findLauncher", "parameters": [{"name": "to", "type": "Sector", "varargs": false}], "return_type": "Sector"}, {"modifiers": [], "name": "showing", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "renderSectors", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderOverProjections", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "renderProjections", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "selectable", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "setup", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "rebuildExpand", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "rebuildList", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getHoverPlanet", "parameters": [{"name": "mouseX", "type": "float", "varargs": false}, {"name": "mouseY", "type": "float", "varargs": false}], "return_type": "Planet"}, {"modifiers": ["public"], "name": "viewPlanet", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}, {"name": "pan", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "act", "parameters": [{"name": "delta", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "displayItems", "parameters": [{"name": "c", "type": "Table", "varargs": false}, {"name": "stats", "type": "ObjectMap", "varargs": false}, {"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "displayItems", "parameters": [{"name": "c", "type": "Table", "varargs": false}, {"name": "stats", "type": "ObjectMap", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "builder", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "showStats", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "abandonSectorConfirm", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "listener", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "addSurvivedInfo", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}, {"name": "table", "type": "Table", "varargs": false}, {"name": "wrap", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "selectSector", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "updateSelected", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "hasNoCandidate", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "isLocked", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "canPlaySector", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "playSelected", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_show_0(_args: Array = []) -> Variant:
	return null

func java_method_rebuildButtons_1(_args: Array = []) -> Variant:
	return null

func java_method_addBack_2(_args: Array = []) -> Variant:
	return null

func java_method_addTech_3(_args: Array = []) -> Variant:
	return null

func java_method_showOverview_4(_args: Array = []) -> Variant:
	return null

func java_method_showPlanetLaunch_5(_args: Array = []) -> Variant:
	return null

func java_method_showSelect_6(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_7(_args: Array = []) -> Variant:
	return null

func java_method_lookAt_8(_args: Array = []) -> Variant:
	return null

func java_method_clampZoom_9(_args: Array = []) -> Variant:
	return null

func java_method_canSelect_10(_args: Array = []) -> Variant:
	return null

func java_method_findLauncher_11(_args: Array = []) -> Variant:
	return null

func java_method_showing_12(_args: Array = []) -> Variant:
	return null

func java_method_renderSectors_13(_args: Array = []) -> Variant:
	return null

func java_method_renderOverProjections_14(_args: Array = []) -> Variant:
	return null

func java_method_renderProjections_15(_args: Array = []) -> Variant:
	return null

func java_method_selectable_16(_args: Array = []) -> Variant:
	return null

func java_method_setup_17(_args: Array = []) -> Variant:
	return null

func java_method_rebuildExpand_18(_args: Array = []) -> Variant:
	return null

func java_method_rebuildList_19(_args: Array = []) -> Variant:
	return null

func java_method_getHoverPlanet_20(_args: Array = []) -> Variant:
	return null

func java_method_viewPlanet_21(_args: Array = []) -> Variant:
	return null

func java_method_draw_22(_args: Array = []) -> Variant:
	return null

func java_method_act_23(_args: Array = []) -> Variant:
	return null

func java_method_displayItems_24(_args: Array = []) -> Variant:
	return null

func java_method_displayItems_25(_args: Array = []) -> Variant:
	return null

func java_method_showStats_26(_args: Array = []) -> Variant:
	return null

func java_method_abandonSectorConfirm_27(_args: Array = []) -> Variant:
	return null

func java_method_addSurvivedInfo_28(_args: Array = []) -> Variant:
	return null

func java_method_selectSector_29(_args: Array = []) -> Variant:
	return null

func java_method_updateSelected_30(_args: Array = []) -> Variant:
	return null

func java_method_hasNoCandidate_31(_args: Array = []) -> Variant:
	return null

func java_method_isLocked_32(_args: Array = []) -> Variant:
	return null

func java_method_canPlaySector_33(_args: Array = []) -> Variant:
	return null

func java_method_playSelected_34(_args: Array = []) -> Variant:
	return null
