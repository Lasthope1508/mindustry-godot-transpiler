# Generated from Mindustry upstream.
# Source: mindustry/audio/SoundLoop.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.audio"
const JAVA_KIND := "class"
const JAVA_NAME := "SoundLoop"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "fadeSpeed", "type": "float"}, {"modifiers": ["final", "private"], "name": "sound", "type": "Sound"}, {"modifiers": ["private"], "name": "id", "type": "int"}, {"modifiers": ["private"], "name": "volume", "type": "float"}, {"modifiers": ["private"], "name": "baseVolume", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SoundLoop", "parameters": [{"name": "sound", "type": "Sound", "varargs": false}, {"name": "baseVolume", "type": "float", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "play", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "play", "type": "boolean", "varargs": false}, {"name": "volumeScl", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "stop", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
