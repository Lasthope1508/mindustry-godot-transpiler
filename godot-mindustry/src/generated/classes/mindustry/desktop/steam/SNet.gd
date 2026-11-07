# Generated from Mindustry upstream.
# Source: desktop/src/mindustry/desktop/steam/SNet.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.desktop.steam"
const JAVA_KIND := "class"
const JAVA_NAME := "SNet"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["SteamNetworkingCallback", "SteamMatchmakingCallback", "SteamFriendsCallback", "NetProvider"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "snet", "type": "SteamNetworking"}, {"modifiers": ["final", "public"], "name": "smat", "type": "SteamMatchmaking"}, {"modifiers": ["final", "public"], "name": "friends", "type": "SteamFriends"}, {"modifiers": ["final"], "name": "provider", "type": "NetProvider"}, {"modifiers": ["final"], "name": "serializer", "type": "PacketSerializer"}, {"modifiers": ["final"], "name": "writeBuffer", "type": "ByteBuffer"}, {"modifiers": ["final"], "name": "readBuffer", "type": "ByteBuffer"}, {"modifiers": ["final"], "name": "readCopyBuffer", "type": "ByteBuffer"}, {"modifiers": ["final"], "name": "connections", "type": "CopyOnWriteArrayList"}, {"modifiers": ["final"], "name": "steamConnections", "type": "IntMap"}, {"modifiers": [], "name": "currentLobby", "type": "SteamID"}, {"modifiers": [], "name": "currentServer", "type": "SteamID"}, {"modifiers": [], "name": "lobbyCallback", "type": "Cons"}, {"modifiers": [], "name": "lobbyDoneCallback", "type": "Runnable"}, {"modifiers": [], "name": "joinCallback", "type": "Runnable"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SNet", "parameters": [{"name": "provider", "type": "NetProvider", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "isSteamClient", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "connectClient", "parameters": [{"name": "ip", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}, {"name": "success", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "sendClient", "parameters": [{"name": "object", "type": "Object", "varargs": false}, {"name": "reliable", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "disconnectClient", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "discoverServers", "parameters": [{"name": "callback", "type": "Cons", "varargs": false}, {"name": "done", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "pingHost", "parameters": [{"name": "address", "type": "String", "varargs": false}, {"name": "port", "type": "int", "varargs": false}, {"name": "valid", "type": "Cons", "varargs": false}, {"name": "failed", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hostServer", "parameters": [{"name": "port", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateLobby", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updateWave", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "updateBans", "parameters": [{"name": "changed", "type": "String", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "closeServer", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getConnections", "parameters": [], "return_type": "Iterable"}, {"modifiers": [], "name": "disconnectSteamUser", "parameters": [{"name": "steamid", "type": "SteamID", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onLobbyInvite", "parameters": [{"name": "steamIDUser", "type": "SteamID", "varargs": false}, {"name": "steamIDLobby", "type": "SteamID", "varargs": false}, {"name": "gameID", "type": "long", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onLobbyEnter", "parameters": [{"name": "steamIDLobby", "type": "SteamID", "varargs": false}, {"name": "chatPermissions", "type": "int", "varargs": false}, {"name": "blocked", "type": "boolean", "varargs": false}, {"name": "response", "type": "ChatRoomEnterResponse", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onLobbyChatUpdate", "parameters": [{"name": "lobby", "type": "SteamID", "varargs": false}, {"name": "who", "type": "SteamID", "varargs": false}, {"name": "changer", "type": "SteamID", "varargs": false}, {"name": "change", "type": "ChatMemberStateChange", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onLobbyMatchList", "parameters": [{"name": "matches", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onLobbyCreated", "parameters": [{"name": "result", "type": "SteamResult", "varargs": false}, {"name": "steamID", "type": "SteamID", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showFriendInvites", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onP2PSessionConnectFail", "parameters": [{"name": "steamIDRemote", "type": "SteamID", "varargs": false}, {"name": "sessionError", "type": "P2PSessionError", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onP2PSessionRequest", "parameters": [{"name": "steamIDRemote", "type": "SteamID", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onGameLobbyJoinRequested", "parameters": [{"name": "lobby", "type": "SteamID", "varargs": false}, {"name": "steamIDFriend", "type": "SteamID", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isSteamClient_0(_args: Array = []) -> Variant:
	return null

func java_method_connectClient_1(_args: Array = []) -> Variant:
	return null

func java_method_sendClient_2(_args: Array = []) -> Variant:
	return null

func java_method_disconnectClient_3(_args: Array = []) -> Variant:
	return null

func java_method_discoverServers_4(_args: Array = []) -> Variant:
	return null

func java_method_pingHost_5(_args: Array = []) -> Variant:
	return null

func java_method_hostServer_6(_args: Array = []) -> Variant:
	return null

func java_method_updateLobby_7(_args: Array = []) -> Variant:
	return null

func java_method_updateWave_8(_args: Array = []) -> Variant:
	return null

func java_method_updateBans_9(_args: Array = []) -> Variant:
	return null

func java_method_closeServer_10(_args: Array = []) -> Variant:
	return null

func java_method_getConnections_11(_args: Array = []) -> Variant:
	return null

func java_method_disconnectSteamUser_12(_args: Array = []) -> Variant:
	return null

func java_method_onLobbyInvite_13(_args: Array = []) -> Variant:
	return null

func java_method_onLobbyEnter_14(_args: Array = []) -> Variant:
	return null

func java_method_onLobbyChatUpdate_15(_args: Array = []) -> Variant:
	return null

func java_method_onLobbyMatchList_16(_args: Array = []) -> Variant:
	return null

func java_method_onLobbyCreated_17(_args: Array = []) -> Variant:
	return null

func java_method_showFriendInvites_18(_args: Array = []) -> Variant:
	return null

func java_method_onP2PSessionConnectFail_19(_args: Array = []) -> Variant:
	return null

func java_method_onP2PSessionRequest_20(_args: Array = []) -> Variant:
	return null

func java_method_onGameLobbyJoinRequested_21(_args: Array = []) -> Variant:
	return null
