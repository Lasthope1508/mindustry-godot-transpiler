# Generated from Mindustry upstream.
# Source: mindustry/core/Logic.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.core"
const JAVA_KIND := "class"
const JAVA_NAME := "Logic"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["ApplicationListener"]
const JAVA_FIELDS := []
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Logic", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["private"], "name": "checkCampaignStats", "parameters": [], "return_type": "boolean"}, {"modifiers": ["private"], "name": "checkOverlappingPlans", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "play", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "reset", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "skipWave", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "runWave", "parameters": [], "return_type": ""}, {"modifiers": ["private"], "name": "checkGameState", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "updateWeather", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "sectorCapture", "parameters": [], "return_type": ""}, {"modifiers": ["public", "static"], "name": "updateGameOver", "parameters": [{"name": "winner", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "gameOver", "parameters": [{"name": "winner", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "researched", "parameters": [{"name": "content", "type": "Content", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "dispose", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "updateEntities", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "isWaitingWave", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
