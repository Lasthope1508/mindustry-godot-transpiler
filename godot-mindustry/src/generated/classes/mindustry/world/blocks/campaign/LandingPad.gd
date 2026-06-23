# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/campaign/LandingPad.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.campaign"
const JAVA_KIND := "class"
const JAVA_NAME := "LandingPad"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["static"], "name": "waiting", "type": "ObjectMap"}, {"modifiers": ["static"], "name": "lastUpdateId", "type": "long"}, {"modifiers": ["public"], "name": "podRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "arrivalDuration", "type": "float"}, {"modifiers": ["public"], "name": "cooldownTime", "type": "float"}, {"modifiers": ["public"], "name": "consumeLiquidAmount", "type": "float"}, {"modifiers": ["public"], "name": "consumeLiquid", "type": "Liquid"}, {"modifiers": ["public"], "name": "landEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "coolingEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "coolingEffectChance", "type": "float"}, {"modifiers": ["public"], "name": "liquidPad", "type": "float"}, {"modifiers": ["public"], "name": "bottomColor", "type": "Color"}, {"modifiers": ["public"], "name": "landSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "landSound", "type": "Sound"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "LandingPad", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public", "static"], "name": "landingPadLanded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
