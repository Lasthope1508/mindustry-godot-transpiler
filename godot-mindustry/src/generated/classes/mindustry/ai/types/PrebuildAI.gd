# Generated from Mindustry upstream.
# Source: mindustry/ai/types/PrebuildAI.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai.types"
const JAVA_KIND := "class"
const JAVA_NAME := "PrebuildAI"
const JAVA_EXTENDS := "AIController"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "priorities", "type": "float"}, {"modifiers": ["static"], "name": "tmpCopy", "type": "Seq"}, {"modifiers": [], "name": "lastPlan", "type": "BlockPlan"}, {"modifiers": [], "name": "collectBlock", "type": "Block"}, {"modifiers": [], "name": "collectingItems", "type": "boolean"}, {"modifiers": [], "name": "mining", "type": "boolean"}, {"modifiers": [], "name": "lastTargetItem", "type": "Item"}, {"modifiers": [], "name": "ore", "type": "Tile"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "sortPlans", "parameters": [{"name": "plans", "type": "Queue", "varargs": false}], "return_type": ""}, {"modifiers": ["private"], "name": "canBuild", "parameters": [{"name": "core", "type": "CoreBuild", "varargs": false}, {"name": "block", "type": "Block", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["private"], "name": "findNextPlan", "parameters": [], "return_type": "BlockPlan"}, {"modifiers": ["public"], "name": "updateMovement", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "doMining", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
