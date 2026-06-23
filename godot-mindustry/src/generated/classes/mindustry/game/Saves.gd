# Generated from Mindustry upstream.
# Source: mindustry/game/Saves.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.game"
const JAVA_KIND := "class"
const JAVA_NAME := "Saves"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "dateFormat", "type": "DateFormat"}, {"modifiers": [], "name": "saves", "type": "Seq"}, {"modifiers": [], "name": "current", "type": "SaveSlot"}, {"modifiers": ["private"], "name": "lastSectorSave", "type": "SaveSlot"}, {"modifiers": ["private"], "name": "saving", "type": "boolean"}, {"modifiers": ["private"], "name": "time", "type": "float"}, {"modifiers": [], "name": "totalPlaytime", "type": "long"}, {"modifiers": ["private"], "name": "lastTimestamp", "type": "long"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Saves", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "clearOldMegabaseSectors", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getLastSector", "parameters": [], "return_type": "SaveSlot"}, {"modifiers": ["public"], "name": "getCurrent", "parameters": [], "return_type": "SaveSlot"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "getTotalPlaytime", "parameters": [], "return_type": "long"}, {"modifiers": ["public"], "name": "resetSave", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isSaving", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getSectorFile", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": "Fi"}, {"modifiers": ["public"], "name": "saveSector", "parameters": [{"name": "sector", "type": "Sector", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "addSave", "parameters": [{"name": "name", "type": "String", "varargs": false}], "return_type": "SaveSlot"}, {"modifiers": ["public"], "name": "importSave", "parameters": [{"name": "file", "type": "Fi", "varargs": false}], "return_type": "SaveSlot"}, {"modifiers": ["public"], "name": "getNextSlotFile", "parameters": [], "return_type": "Fi"}, {"modifiers": ["public"], "name": "getSaveSlots", "parameters": [], "return_type": "Seq"}, {"modifiers": ["public"], "name": "deleteAll", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
