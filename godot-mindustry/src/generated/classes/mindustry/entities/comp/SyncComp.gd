# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/SyncComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "SyncComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Entityc"]
const JAVA_FIELDS := [{"modifiers": ["transient"], "name": "lastUpdated", "type": "long"}, {"modifiers": ["transient"], "name": "updateSpacing", "type": "long"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "snapSync", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "snapInterpolation", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "readSync", "parameters": [{"name": "read", "type": "Reads", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeSync", "parameters": [{"name": "write", "type": "Writes", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "readSyncManual", "parameters": [{"name": "buffer", "type": "FloatBuffer", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "writeSyncManual", "parameters": [{"name": "buffer", "type": "FloatBuffer", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "afterSync", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "interpolate", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "isSyncHidden", "parameters": [{"name": "player", "type": "Player", "varargs": false}], "return_type": "boolean"}, {"modifiers": [], "name": "handleSyncHidden", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "remove", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
