# Generated from Mindustry upstream.
# Source: mindustry/ui/fragments/BlockInventoryFragment.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ui.fragments"
const JAVA_KIND := "class"
const JAVA_NAME := "BlockInventoryFragment"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "holdWithdraw", "type": "float"}, {"modifiers": ["final", "private", "static"], "name": "holdShrink", "type": "float"}, {"modifiers": [], "name": "table", "type": "Table"}, {"modifiers": [], "name": "build", "type": "Building"}, {"modifiers": [], "name": "holdTime", "type": "float"}, {"modifiers": [], "name": "emptyTime", "type": "float"}, {"modifiers": [], "name": "holding", "type": "boolean"}, {"modifiers": [], "name": "held", "type": "boolean"}, {"modifiers": [], "name": "shrinkHoldTimes", "type": "float"}, {"modifiers": [], "name": "lastItem", "type": "Item"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "build", "parameters": [{"name": "parent", "type": "Group", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "showFor", "parameters": [{"name": "t", "type": "Building", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "hide", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "takeItem", "parameters": [{"name": "requested", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "rebuild", "parameters": [{"name": "actions", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "round", "parameters": [{"name": "f", "type": "float", "varargs": false}], "return_type": "String"}, {"modifiers": ["private"], "name": "updateTablePosition", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "itemImage", "parameters": [{"name": "region", "type": "TextureRegion", "varargs": false}, {"name": "text", "type": "Prov", "varargs": false}], "return_type": "Element"}]
const JAVA_ENUM_CONSTANTS := []
