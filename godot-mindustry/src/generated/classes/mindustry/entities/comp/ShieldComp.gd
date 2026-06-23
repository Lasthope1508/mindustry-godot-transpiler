# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/ShieldComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "ShieldComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Healthc", "Posc"]
const JAVA_FIELDS := [{"modifiers": [], "name": "health", "type": "float"}, {"modifiers": [], "name": "hitTime", "type": "float"}, {"modifiers": [], "name": "x", "type": "float"}, {"modifiers": [], "name": "y", "type": "float"}, {"modifiers": [], "name": "healthMultiplier", "type": "float"}, {"modifiers": [], "name": "armorOverride", "type": "float"}, {"modifiers": [], "name": "dead", "type": "boolean"}, {"modifiers": [], "name": "team", "type": "Team"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "shield", "type": "float"}, {"modifiers": ["transient"], "name": "armor", "type": "float"}, {"modifiers": ["transient"], "name": "shieldAlpha", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "damage", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "damagePierce", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "withEffect", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "damageArmorMult", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "armorMult", "type": "float", "varargs": false}, {"name": "withEffect", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["protected"], "name": "rawDamage", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []
