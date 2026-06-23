# Generated from Mindustry upstream.
# Source: mindustry/audio/SoundControl.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.audio"
const JAVA_KIND := "class"
const JAVA_NAME := "SoundControl"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "finTime", "type": "float"}, {"modifiers": ["public"], "name": "foutTime", "type": "float"}, {"modifiers": ["public"], "name": "musicInterval", "type": "float"}, {"modifiers": ["public"], "name": "musicChance", "type": "float"}, {"modifiers": ["public"], "name": "musicWaveChance", "type": "float"}, {"modifiers": ["public"], "name": "ambientMusic", "type": "Seq"}, {"modifiers": ["public"], "name": "darkMusic", "type": "Seq"}, {"modifiers": ["public"], "name": "bossMusic", "type": "Seq"}, {"modifiers": ["public"], "name": "uiBus", "type": "AudioBus"}, {"modifiers": ["protected"], "name": "lastRandomPlayed", "type": "Music"}, {"modifiers": ["protected"], "name": "timer", "type": "Interval"}, {"modifiers": ["protected"], "name": "lastPlayed", "type": "long"}, {"modifiers": ["protected"], "name": "current", "type": "Music"}, {"modifiers": ["protected"], "name": "fade", "type": "float"}, {"modifiers": ["protected"], "name": "silenced", "type": "boolean"}, {"modifiers": ["protected"], "name": "keepSilent", "type": "boolean"}, {"modifiers": ["protected"], "name": "wasPlaying", "type": "boolean"}, {"modifiers": ["protected"], "name": "filter", "type": "AudioFilter"}, {"modifiers": ["protected"], "name": "sounds", "type": "ObjectMap"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SoundControl", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["protected"], "name": "setupFilters", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "reload", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "loop", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "volume", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "loop", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "pos", "type": "Position", "varargs": false}, {"name": "volume", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "loop", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "pos", "type": "Position", "varargs": false}, {"name": "volume", "type": "float", "varargs": false}, {"name": "pitch", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "stop", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "keepSilent", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "updateLoops", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "playMusic", "parameters": [{"name": "music", "type": "Music", "varargs": false}, {"name": "interrupt", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isPlaying", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "playRandom", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "alwaysPlayMusic", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "getBossMusic", "parameters": [], "return_type": "Seq"}, {"modifiers": ["protected"], "name": "getAmbientMusic", "parameters": [], "return_type": "Seq"}, {"modifiers": ["protected"], "name": "getDarkMusic", "parameters": [], "return_type": "Seq"}, {"modifiers": ["protected"], "name": "isDark", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "play", "parameters": [{"name": "music", "type": "Music", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "playOnce", "parameters": [{"name": "music", "type": "Music", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "shouldPlay", "parameters": [], "return_type": "boolean"}, {"modifiers": ["protected"], "name": "silence", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "findMusic", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "Music"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setupFilters_0(_args: Array = []) -> Variant:
	return null

func java_method_reload_1(_args: Array = []) -> Variant:
	return null

func java_method_loop_2(_args: Array = []) -> Variant:
	return null

func java_method_loop_3(_args: Array = []) -> Variant:
	return null

func java_method_loop_4(_args: Array = []) -> Variant:
	return null

func java_method_stop_5(_args: Array = []) -> Variant:
	return null

func java_method_update_6(_args: Array = []) -> Variant:
	return null

func java_method_keepSilent_7(_args: Array = []) -> Variant:
	return null

func java_method_updateLoops_8(_args: Array = []) -> Variant:
	return null

func java_method_playMusic_9(_args: Array = []) -> Variant:
	return null

func java_method_isPlaying_10(_args: Array = []) -> Variant:
	return null

func java_method_playRandom_11(_args: Array = []) -> Variant:
	return null

func java_method_alwaysPlayMusic_12(_args: Array = []) -> Variant:
	return null

func java_method_getBossMusic_13(_args: Array = []) -> Variant:
	return null

func java_method_getAmbientMusic_14(_args: Array = []) -> Variant:
	return null

func java_method_getDarkMusic_15(_args: Array = []) -> Variant:
	return null

func java_method_isDark_16(_args: Array = []) -> Variant:
	return null

func java_method_play_17(_args: Array = []) -> Variant:
	return null

func java_method_playOnce_18(_args: Array = []) -> Variant:
	return null

func java_method_shouldPlay_19(_args: Array = []) -> Variant:
	return null

func java_method_silence_20(_args: Array = []) -> Variant:
	return null

func java_method_findMusic_21(_args: Array = []) -> Variant:
	return null
