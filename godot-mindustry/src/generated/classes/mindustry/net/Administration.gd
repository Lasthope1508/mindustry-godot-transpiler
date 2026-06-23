# Generated from Mindustry upstream.
# Source: mindustry/net/Administration.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.net"
const JAVA_KIND := "class"
const JAVA_NAME := "Administration"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "bannedIPs", "type": "Seq"}, {"modifiers": ["public"], "name": "whitelist", "type": "Seq"}, {"modifiers": ["public"], "name": "chatFilters", "type": "Seq"}, {"modifiers": ["public"], "name": "actionFilters", "type": "Seq"}, {"modifiers": ["public"], "name": "subnetBans", "type": "Seq"}, {"modifiers": ["public"], "name": "dosBlacklist", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "kickedIPs", "type": "ObjectMap"}, {"modifiers": ["public"], "name": "bannedNames", "type": "Seq"}, {"modifiers": ["private"], "name": "modified", "type": "boolean"}, {"modifiers": ["private"], "name": "loaded", "type": "boolean"}, {"modifiers": ["public"], "name": "playerInfo", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Administration", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public", "synchronized"], "name": "blacklistDos", "parameters": [{"name": "address", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "synchronized"], "name": "unBlacklistDos", "parameters": [{"name": "address", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "synchronized"], "name": "isDosBlacklisted", "parameters": [{"name": "address", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getKickTime", "parameters": [{"name": "uuid", "type": "String", "varargs": false}, {"name": "ip", "type": "String", "varargs": false}], "return_type": "long"}, {"modifiers": ["public"], "name": "handleKicked", "parameters": [{"name": "uuid", "type": "String", "varargs": false}, {"name": "ip", "type": "String", "varargs": false}, {"name": "duration", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getSubnetBans", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "removeSubnetBan", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addSubnetBan", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isSubnetBanned", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "addNameBan", "parameters": [{"name": "regex", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addChatFilter", "parameters": [{"name": "filter", "type": "ChatFilter", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "filterMessage", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "message", "type": "String", "varargs": false}], "return_type": "String"}, {"modifiers": ["public"], "name": "addActionFilter", "parameters": [{"name": "filter", "type": "ActionFilter", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "allowAction", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "type", "type": "ActionType", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowAction", "parameters": [{"name": "player", "type": "Player", "varargs": false}, {"name": "type", "type": "ActionType", "varargs": false}, {"name": "setter", "type": "Cons", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getPlayerLimit", "parameters": [], "return_type": "int"}, {"modifiers": ["public"], "name": "setPlayerLimit", "parameters": [{"name": "limit", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isStrict", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "allowsCustomClients", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "updatePlayerJoined", "parameters": [{"name": "id", "type": "String", "varargs": false}, {"name": "ip", "type": "String", "varargs": false}, {"name": "name", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "banPlayer", "parameters": [{"name": "uuid", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "banPlayerIP", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "banPlayerID", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unbanPlayerIP", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unbanPlayerID", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getAdmins", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getBanned", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getBannedIPs", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "adminPlayer", "parameters": [{"name": "id", "type": "String", "varargs": false}, {"name": "usid", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unAdminPlayer", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isWhitelistEnabled", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isWhitelisted", "parameters": [{"name": "id", "type": "String", "varargs": false}, {"name": "usid", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "whitelist", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "unwhitelist", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isIPBanned", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isIDBanned", "parameters": [{"name": "uuid", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isNameBanned", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isAdmin", "parameters": [{"name": "id", "type": "String", "varargs": false}, {"name": "usid", "type": "String", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "findByName", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "ObjectSet"}, {"modifiers": ["public"], "name": "searchNames", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "ObjectSet"}, {"modifiers": ["public"], "name": "findByIPs", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "Seq"}, {"modifiers": ["public"], "name": "getInfo", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "PlayerInfo"}, {"modifiers": ["public"], "name": "getInfoOptional", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "PlayerInfo"}, {"modifiers": ["public"], "name": "findByIP", "parameters": [{"name": "ip", "type": "String", "varargs": false}], "return_type": "PlayerInfo"}, {"modifiers": ["public"], "name": "getWhitelisted", "parameters": [], "return_type": "Seq"}, {"modifiers": ["private"], "name": "getCreateInfo", "parameters": [{"name": "id", "type": "String", "varargs": false}], "return_type": "PlayerInfo"}, {"modifiers": ["public"], "name": "save", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "forceSave", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "load", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_blacklistDos_0(_args: Array = []) -> Variant:
	return null

func java_method_unBlacklistDos_1(_args: Array = []) -> Variant:
	return null

func java_method_isDosBlacklisted_2(_args: Array = []) -> Variant:
	return null

func java_method_getKickTime_3(_args: Array = []) -> Variant:
	return null

func java_method_handleKicked_4(_args: Array = []) -> Variant:
	return null

func java_method_getSubnetBans_5(_args: Array = []) -> Variant:
	return null

func java_method_removeSubnetBan_6(_args: Array = []) -> Variant:
	return null

func java_method_addSubnetBan_7(_args: Array = []) -> Variant:
	return null

func java_method_isSubnetBanned_8(_args: Array = []) -> Variant:
	return null

func java_method_addNameBan_9(_args: Array = []) -> Variant:
	return null

func java_method_addChatFilter_10(_args: Array = []) -> Variant:
	return null

func java_method_filterMessage_11(_args: Array = []) -> Variant:
	return null

func java_method_addActionFilter_12(_args: Array = []) -> Variant:
	return null

func java_method_allowAction_13(_args: Array = []) -> Variant:
	return null

func java_method_allowAction_14(_args: Array = []) -> Variant:
	return null

func java_method_getPlayerLimit_15(_args: Array = []) -> Variant:
	return null

func java_method_setPlayerLimit_16(_args: Array = []) -> Variant:
	return null

func java_method_isStrict_17(_args: Array = []) -> Variant:
	return null

func java_method_allowsCustomClients_18(_args: Array = []) -> Variant:
	return null

func java_method_updatePlayerJoined_19(_args: Array = []) -> Variant:
	return null

func java_method_banPlayer_20(_args: Array = []) -> Variant:
	return null

func java_method_banPlayerIP_21(_args: Array = []) -> Variant:
	return null

func java_method_banPlayerID_22(_args: Array = []) -> Variant:
	return null

func java_method_unbanPlayerIP_23(_args: Array = []) -> Variant:
	return null

func java_method_unbanPlayerID_24(_args: Array = []) -> Variant:
	return null

func java_method_getAdmins_25(_args: Array = []) -> Variant:
	return null

func java_method_getBanned_26(_args: Array = []) -> Variant:
	return null

func java_method_getBannedIPs_27(_args: Array = []) -> Variant:
	return null

func java_method_adminPlayer_28(_args: Array = []) -> Variant:
	return null

func java_method_unAdminPlayer_29(_args: Array = []) -> Variant:
	return null

func java_method_isWhitelistEnabled_30(_args: Array = []) -> Variant:
	return null

func java_method_isWhitelisted_31(_args: Array = []) -> Variant:
	return null

func java_method_whitelist_32(_args: Array = []) -> Variant:
	return null

func java_method_unwhitelist_33(_args: Array = []) -> Variant:
	return null

func java_method_isIPBanned_34(_args: Array = []) -> Variant:
	return null

func java_method_isIDBanned_35(_args: Array = []) -> Variant:
	return null

func java_method_isNameBanned_36(_args: Array = []) -> Variant:
	return null

func java_method_isAdmin_37(_args: Array = []) -> Variant:
	return null

func java_method_findByName_38(_args: Array = []) -> Variant:
	return null

func java_method_searchNames_39(_args: Array = []) -> Variant:
	return null

func java_method_findByIPs_40(_args: Array = []) -> Variant:
	return null

func java_method_getInfo_41(_args: Array = []) -> Variant:
	return null

func java_method_getInfoOptional_42(_args: Array = []) -> Variant:
	return null

func java_method_findByIP_43(_args: Array = []) -> Variant:
	return null

func java_method_getWhitelisted_44(_args: Array = []) -> Variant:
	return null

func java_method_getCreateInfo_45(_args: Array = []) -> Variant:
	return null

func java_method_save_46(_args: Array = []) -> Variant:
	return null

func java_method_forceSave_47(_args: Array = []) -> Variant:
	return null

func java_method_load_48(_args: Array = []) -> Variant:
	return null
