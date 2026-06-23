# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/WaterMoveComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "WaterMoveComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc", "Velc", "Hitboxc", "Unitc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "rotation", "type": "float"}, {"modifiers": [], "name": "speedMultiplier", "type": "float"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": ["private", "transient"], "name": "tleft", "type": "Trail"}, {"modifiers": ["private", "transient"], "name": "tright", "type": "Trail"}, {"modifiers": ["private", "transient"], "name": "trailColor", "type": "Color"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "add", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "solidity", "parameters": [], "return_type": "SolidPred"}, {"modifiers": ["public"], "name": "onSolid", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "floorSpeedMultiplier", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "onLiquid", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []
