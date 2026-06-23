# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/environment/SteamVent.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.environment"
const JAVA_KIND := "class"
const JAVA_NAME := "SteamVent"
const JAVA_EXTENDS := "Floor"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "offsets", "type": "Point2"}, {"modifiers": ["public"], "name": "parent", "type": "Block"}, {"modifiers": ["public"], "name": "effect", "type": "Effect"}, {"modifiers": ["public"], "name": "effectColor", "type": "Color"}, {"modifiers": ["public"], "name": "effectSpacing", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "SteamVent", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "drawMain", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "updateRender", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldIndex", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isCenterVent", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "renderUpdate", "parameters": [{"name": "state", "type": "UpdateRenderState", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "checkAdjacent", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
