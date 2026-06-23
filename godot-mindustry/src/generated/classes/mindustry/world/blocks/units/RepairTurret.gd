# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/units/RepairTurret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.units"
const JAVA_KIND := "class"
const JAVA_NAME := "RepairTurret"
const JAVA_EXTENDS := "Block"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["final", "static"], "name": "rand", "type": "Rand"}, {"modifiers": ["public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "timerEffect", "type": "int"}, {"modifiers": ["public"], "name": "repairRadius", "type": "float"}, {"modifiers": ["public"], "name": "repairSpeed", "type": "float"}, {"modifiers": ["public"], "name": "powerUse", "type": "float"}, {"modifiers": ["public"], "name": "length", "type": "float"}, {"modifiers": ["public"], "name": "beamWidth", "type": "float"}, {"modifiers": ["public"], "name": "pulseRadius", "type": "float"}, {"modifiers": ["public"], "name": "pulseStroke", "type": "float"}, {"modifiers": ["public"], "name": "acceptCoolant", "type": "boolean"}, {"modifiers": ["public"], "name": "coolantUse", "type": "float"}, {"modifiers": ["public"], "name": "coolEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "coolantMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "baseRegion", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laser", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserTop", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserTopEnd", "type": "TextureRegion"}, {"modifiers": ["public"], "name": "laserColor", "type": "Color"}, {"modifiers": ["public"], "name": "laserTopColor", "type": "Color"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "RepairTurret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public", "static"], "name": "drawBeam", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "rotation", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "id", "type": "int", "varargs": false}, {"name": "target", "type": "Sized", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "strength", "type": "float", "varargs": false}, {"name": "pulseStroke", "type": "float", "varargs": false}, {"name": "pulseRadius", "type": "float", "varargs": false}, {"name": "beamWidth", "type": "float", "varargs": false}, {"name": "lastEnd", "type": "Vec2", "varargs": false}, {"name": "offset", "type": "Vec2", "varargs": false}, {"name": "laserColor", "type": "Color", "varargs": false}, {"name": "laserTopColor", "type": "Color", "varargs": false}, {"name": "laser", "type": "TextureRegion", "varargs": false}, {"name": "laserEnd", "type": "TextureRegion", "varargs": false}, {"name": "laserTop", "type": "TextureRegion", "varargs": false}, {"name": "laserTopEnd", "type": "TextureRegion", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_setStats_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_2(_args: Array = []) -> Variant:
	return null

func java_method_icons_3(_args: Array = []) -> Variant:
	return null

func java_method_drawBeam_4(_args: Array = []) -> Variant:
	return null
