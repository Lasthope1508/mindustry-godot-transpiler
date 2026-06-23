# Generated from Mindustry upstream.
# Source: mindustry/ctype/UnlockableContent.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ctype"
const JAVA_KIND := "class"
const JAVA_NAME := "UnlockableContent"
const JAVA_EXTENDS := "MappableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "stats", "type": "Stats"}, {"modifiers": ["public"], "name": "localizedName", "type": "String"}, {"modifiers": ["public"], "name": "description", "type": "String"}, {"modifiers": ["public"], "name": "details", "type": "String"}, {"modifiers": ["public"], "name": "credit", "type": "String"}, {"modifiers": ["public"], "name": "alwaysUnlocked", "type": "boolean"}, {"modifiers": ["public"], "name": "inlineDescription", "type": "boolean"}, {"modifiers": ["public"], "name": "hideDetails", "type": "boolean"}, {"modifiers": ["public"], "name": "hideDatabase", "type": "boolean"}, {"modifiers": ["public"], "name": "generateIcons", "type": "boolean"}, {"modifiers": ["public"], "name": "selectionSize", "type": "float"}, {"modifiers": ["public"], "name": "uiIcon", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "fullIcon", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "fullOverride", "type": "String"}, {"modifiers": ["public"], "name": "allDatabaseTabs", "type": "boolean"}, {"modifiers": ["public"], "name": "shownPlanets", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "databaseTabs", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "databaseCategory", "type": "String"}, {"modifiers": ["public"], "name": "databaseTag", "type": "String"}, {"modifiers": ["public"], "name": "techNode", "type": "TechNode"}, {"modifiers": ["public"], "name": "techNodes", "type": "Seq"}, {"modifiers": ["protected"], "name": "unlocked", "type": "boolean"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "UnlockableContent", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "postInit", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loadIcon", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "afterPatch", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isBanned", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isOnPlanet", "parameters": [{"name": "planet", "type": "Planet", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getLogicId", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "displayDescription", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "checkStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "displayExtra", "parameters": [{"name": "table", "type": "Table", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "makeOutline", "parameters": [{"name": "page", "type": "PageType", "varargs": false}, {"name": "packer", "type": "MultiPacker", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "makeNew", "type": "boolean", "varargs": false}, {"name": "outlineColor", "type": "Color", "varargs": false}, {"name": "outlineRadius", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "makeOutline", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "outlineColor", "type": "Color", "varargs": false}, {"name": "outlineRadius", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "makeOutline", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}, {"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "name", "type": "String", "varargs": false}, {"name": "outlineColor", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "researchRequirements", "parameters": [], "return_type": "ItemStack"}, {"modifiers": ["public"], "name": "emoji", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "emojiChar", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "hasEmoji", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getDependencies", "parameters": [{"name": "cons", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onUnlock", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "showUnlock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "logicVisible", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unlock", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "quietUnlock", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unlockedNowHost", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unlockedHost", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unlockedNow", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unlocked", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "clearUnlock", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "locked", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_postInit_0(_args: Array = []) -> Variant:
	return null

func java_method_loadIcon_1(_args: Array = []) -> Variant:
	return null

func java_method_afterPatch_2(_args: Array = []) -> Variant:
	return null

func java_method_isBanned_3(_args: Array = []) -> Variant:
	return null

func java_method_isOnPlanet_4(_args: Array = []) -> Variant:
	return null

func java_method_getLogicId_5(_args: Array = []) -> Variant:
	return null

func java_method_displayDescription_6(_args: Array = []) -> Variant:
	return null

func java_method_checkStats_7(_args: Array = []) -> Variant:
	return null

func java_method_setStats_8(_args: Array = []) -> Variant:
	return null

func java_method_displayExtra_9(_args: Array = []) -> Variant:
	return null

func java_method_createIcons_10(_args: Array = []) -> Variant:
	return null

func java_method_makeOutline_11(_args: Array = []) -> Variant:
	return null

func java_method_makeOutline_12(_args: Array = []) -> Variant:
	return null

func java_method_makeOutline_13(_args: Array = []) -> Variant:
	return null

func java_method_researchRequirements_14(_args: Array = []) -> Variant:
	return null

func java_method_emoji_15(_args: Array = []) -> Variant:
	return null

func java_method_emojiChar_16(_args: Array = []) -> Variant:
	return null

func java_method_hasEmoji_17(_args: Array = []) -> Variant:
	return null

func java_method_getDependencies_18(_args: Array = []) -> Variant:
	return null

func java_method_onUnlock_19(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_20(_args: Array = []) -> Variant:
	return null

func java_method_showUnlock_21(_args: Array = []) -> Variant:
	return null

func java_method_logicVisible_22(_args: Array = []) -> Variant:
	return null

func java_method_unlock_23(_args: Array = []) -> Variant:
	return null

func java_method_quietUnlock_24(_args: Array = []) -> Variant:
	return null

func java_method_unlockedNowHost_25(_args: Array = []) -> Variant:
	return null

func java_method_unlockedHost_26(_args: Array = []) -> Variant:
	return null

func java_method_unlockedNow_27(_args: Array = []) -> Variant:
	return null

func java_method_unlocked_28(_args: Array = []) -> Variant:
	return null

func java_method_clearUnlock_29(_args: Array = []) -> Variant:
	return null

func java_method_locked_30(_args: Array = []) -> Variant:
	return null
