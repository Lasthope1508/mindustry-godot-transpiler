# Generated from Mindustry upstream.
# Source: desktop/src/mindustry/desktop/steam/SStats.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.desktop.steam"
const JAVA_KIND := "class"
const JAVA_NAME := "SStats"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["SteamUserStatsCallback"]
const JAVA_FIELDS := [{"modifiers": ["final", "public"], "name": "stats", "type": "SteamUserStats"}, {"modifiers": ["private"], "name": "updated", "type": "boolean"}, {"modifiers": ["private"], "name": "statSavePeriod", "type": "int"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SStats", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "onUpdate", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "onUserStatsReceived", "parameters": [{"name": "gameID", "type": "long", "varargs": false}, {"name": "steamID", "type": "SteamID", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onUserStatsStored", "parameters": [{"name": "gameID", "type": "long", "varargs": false}, {"name": "result", "type": "SteamResult", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_onUpdate_0(_args: Array = []) -> Variant:
	return null

func java_method_onUserStatsReceived_1(_args: Array = []) -> Variant:
	return null

func java_method_onUserStatsStored_2(_args: Array = []) -> Variant:
	return null
