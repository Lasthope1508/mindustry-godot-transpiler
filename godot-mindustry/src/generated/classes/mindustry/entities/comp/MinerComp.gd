# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/MinerComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "MinerComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Itemsc", "Posc", "Teamc", "Rotc", "Drawc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "hitSize", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": ["transient"], "name": "mineTimer", "type": "float"}, {"modifiers": [], "name": "mineTile", "type": "Tile"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "canMine", "parameters": [{"name": "item", "type": "Item", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "offloadImmediately", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "mining", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "getMineResult", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "Item"}, {"modifiers": ["public"], "name": "validMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "checkDst", "type": "boolean", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "validMine", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "canMine", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
