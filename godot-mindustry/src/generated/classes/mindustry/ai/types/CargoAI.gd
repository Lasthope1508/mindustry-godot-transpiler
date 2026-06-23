# Generated from Mindustry upstream.
# Source: mindustry/ai/types/CargoAI.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai.types"
const JAVA_KIND := "class"
const JAVA_NAME := "CargoAI"
const JAVA_EXTENDS := "AIController"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "orderedItems", "type": "Seq"}, {"modifiers": ["static"], "name": "targets", "type": "Seq"}, {"modifiers": ["public", "static"], "name": "emptyWaitTime", "type": "float"}, {"modifiers": ["public", "static"], "name": "dropSpacing", "type": "float"}, {"modifiers": ["public", "static"], "name": "transferRange", "type": "float"}, {"modifiers": ["public", "static"], "name": "moveRange", "type": "float"}, {"modifiers": ["public", "static"], "name": "moveSmoothing", "type": "float"}, {"modifiers": ["public"], "name": "unloadTarget", "type": "UnitCargoUnloadPointBuild"}, {"modifiers": ["public"], "name": "itemTarget", "type": "Item"}, {"modifiers": ["public"], "name": "noDestTimer", "type": "float"}, {"modifiers": ["public"], "name": "targetIndex", "type": "int"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "updateMovement", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "findDropTarget", "parameters": [{"name": "item", "type": "Item", "varargs": false}, {"name": "offset", "type": "int", "varargs": false}, {"name": "ignore", "type": "UnitCargoUnloadPointBuild", "varargs": false}], "return_type": "int"}, {"modifiers": ["public"], "name": "findAnyTarget", "parameters": [{"name": "build", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "sortTargets", "parameters": [{"name": "targets", "type": "Seq", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
