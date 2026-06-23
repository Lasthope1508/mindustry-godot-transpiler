# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/PlayerComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "PlayerComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["UnitController", "Entityc", "Syncc", "Timerc", "Drawc"]
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "deathDelay", "type": "float"}, {"modifiers": ["final", "static"], "name": "pingDuration", "type": "float"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "unit", "type": "Unit"}, {"modifiers": ["transient"], "name": "con", "type": "NetConnection"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "typing", "type": "boolean"}, {"modifiers": [], "name": "shooting", "type": "boolean"}, {"modifiers": [], "name": "boosting", "type": "boolean"}, {"modifiers": [], "name": "selectedBlock", "type": "Block"}, {"modifiers": [], "name": "selectedRotation", "type": "int"}, {"modifiers": [], "name": "mouseX", "type": "float"}, {"modifiers": [], "name": "mouseY", "type": "float"}, {"modifiers": [], "name": "lastCommand", "type": "UnitCommand"}, {"modifiers": [], "name": "admin", "type": "boolean"}, {"modifiers": [], "name": "name", "type": "String"}, {"modifiers": [], "name": "color", "type": "Color"}, {"modifiers": ["transient"], "name": "locale", "type": "String"}, {"modifiers": ["transient"], "name": "deathTimer", "type": "float"}, {"modifiers": ["transient"], "name": "lastText", "type": "String"}, {"modifiers": ["transient"], "name": "textFadeTime", "type": "float"}, {"modifiers": ["transient"], "name": "itemDepositRate", "type": "Ratekeeper"}, {"modifiers": ["transient"], "name": "pingX", "type": "float"}, {"modifiers": ["transient"], "name": "pingY", "type": "float"}, {"modifiers": ["transient"], "name": "pingTime", "type": "float"}, {"modifiers": ["transient"], "name": "pingText", "type": "String"}, {"modifiers": ["private", "transient"], "name": "lastReadUnit", "type": "Unit"}, {"modifiers": ["private", "transient"], "name": "wrongReadUnits", "type": "int"}, {"modifiers": ["transient"], "name": "justSwitchFrom", "type": "Unit"}, {"modifiers": ["transient"], "name": "justSwitchTo", "type": "Unit"}, {"modifiers": ["transient"], "name": "lastPreviewPlanGroup", "type": "int"}, {"modifiers": ["transient"], "name": "lastPreviewPlanGroupServer", "type": "int"}, {"modifiers": ["transient"], "name": "lastPreviewPlanTimestamp", "type": "long"}, {"modifiers": ["transient"], "name": "receivingNewPlanGroup", "type": "boolean"}, {"modifiers": ["transient"], "name": "previewPlansCurrent", "type": "Seq"}, {"modifiers": ["transient"], "name": "previewPlansAssembling", "type": "Seq"}, {"modifiers": ["transient"], "name": "previewPlanTree", "type": "QuadTree"}, {"modifiers": ["transient"], "name": "planEachable", "type": "QueryEachable"}, {"modifiers": ["transient"], "name": "previewPlansDirty", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "getPreviewPlans", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "handlePreviewPlans", "parameters": [{"name": "groupId", "type": "int", "varargs": false}, {"name": "plans", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isBuilder", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "closestCore", "parameters": [], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "core", "parameters": [], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "bestCore", "parameters": [], "return_type": "CoreBuild"}, {"modifiers": ["public"], "name": "icon", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "displayAmmo", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isValidController", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isLogicControllable", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "clipSize", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "checkSpawn", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "team", "parameters": [{"name": "team", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "clearUnit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unit", "parameters": [], "return_type": "Unit"}, {"modifiers": ["public"], "name": "unit", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "dead", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "ip", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "uuid", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "usid", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "kick", "parameters": [{"name": "reason", "type": "KickReason", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "kick", "parameters": [{"name": "reason", "type": "KickReason", "varargs": false}, {"name": "duration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "kick", "parameters": [{"name": "reason", "type": "String", "varargs": false}, {"name": "duration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isPinging", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "drawPing", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "drawName", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "coloredName", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "plainName", "parameters": [], "return_type": "String"}, {"modifiers": [], "name": "sendMessage", "parameters": [{"name": "text", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "sendMessage", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "from", "type": "Player", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "sendMessage", "parameters": [{"name": "text", "type": "String", "varargs": false}, {"name": "from", "type": "Player", "varargs": false}, {"name": "unformatted", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "sendUnformatted", "parameters": [{"name": "unformatted", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "sendUnformatted", "parameters": [{"name": "from", "type": "Player", "varargs": false}, {"name": "unformatted", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "getInfo", "parameters": [], "return_type": "PlayerInfo"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_getPreviewPlans_0(_args: Array = []) -> Variant:
	return null

func java_method_handlePreviewPlans_1(_args: Array = []) -> Variant:
	return null

func java_method_isBuilder_2(_args: Array = []) -> Variant:
	return null

func java_method_closestCore_3(_args: Array = []) -> Variant:
	return null

func java_method_core_4(_args: Array = []) -> Variant:
	return null

func java_method_bestCore_5(_args: Array = []) -> Variant:
	return null

func java_method_icon_6(_args: Array = []) -> Variant:
	return null

func java_method_displayAmmo_7(_args: Array = []) -> Variant:
	return null

func java_method_reset_8(_args: Array = []) -> Variant:
	return null

func java_method_isValidController_9(_args: Array = []) -> Variant:
	return null

func java_method_isLogicControllable_10(_args: Array = []) -> Variant:
	return null

func java_method_clipSize_11(_args: Array = []) -> Variant:
	return null

func java_method_afterSync_12(_args: Array = []) -> Variant:
	return null

func java_method_update_13(_args: Array = []) -> Variant:
	return null

func java_method_checkSpawn_14(_args: Array = []) -> Variant:
	return null

func java_method_remove_15(_args: Array = []) -> Variant:
	return null

func java_method_team_16(_args: Array = []) -> Variant:
	return null

func java_method_clearUnit_17(_args: Array = []) -> Variant:
	return null

func java_method_unit_18(_args: Array = []) -> Variant:
	return null

func java_method_unit_19(_args: Array = []) -> Variant:
	return null

func java_method_dead_20(_args: Array = []) -> Variant:
	return null

func java_method_ip_21(_args: Array = []) -> Variant:
	return null

func java_method_uuid_22(_args: Array = []) -> Variant:
	return null

func java_method_usid_23(_args: Array = []) -> Variant:
	return null

func java_method_kick_24(_args: Array = []) -> Variant:
	return null

func java_method_kick_25(_args: Array = []) -> Variant:
	return null

func java_method_kick_26(_args: Array = []) -> Variant:
	return null

func java_method_kick_27(_args: Array = []) -> Variant:
	return null

func java_method_draw_28(_args: Array = []) -> Variant:
	return null

func java_method_isPinging_29(_args: Array = []) -> Variant:
	return null

func java_method_drawPing_30(_args: Array = []) -> Variant:
	return null

func java_method_drawName_31(_args: Array = []) -> Variant:
	return null

func java_method_coloredName_32(_args: Array = []) -> Variant:
	return null

func java_method_plainName_33(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_34(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_35(_args: Array = []) -> Variant:
	return null

func java_method_sendMessage_36(_args: Array = []) -> Variant:
	return null

func java_method_sendUnformatted_37(_args: Array = []) -> Variant:
	return null

func java_method_sendUnformatted_38(_args: Array = []) -> Variant:
	return null

func java_method_getInfo_39(_args: Array = []) -> Variant:
	return null
