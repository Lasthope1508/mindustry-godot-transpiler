# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/HealthComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "HealthComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Entityc", "Posc"]
const JAVA_FIELDS := [{"modifiers": ["final", "static"], "name": "hitDuration", "type": "float"}, {"modifiers": [], "name": "health", "type": "float"}, {"modifiers": ["transient"], "name": "hitTime", "type": "float"}, {"modifiers": ["transient"], "name": "maxHealth", "type": "float"}, {"modifiers": ["transient"], "name": "dead", "type": "boolean"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": [], "name": "isValid", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "healthf", "parameters": [], "return_type": "float"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "killed", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "kill", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "heal", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "damaged", "parameters": [], "return_type": "boolean"}, {"modifiers": [], "name": "damagePierce", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "withEffect", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damagePierce", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damageArmorMult", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "armorMult", "type": "float", "varargs": false}, {"name": "withEffect", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damageArmorMult", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "armorMult", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damage", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damage", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "withEffect", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damageContinuous", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damageContinuousPierce", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "damageContinuousArmorMult", "parameters": [{"name": "amount", "type": "float", "varargs": false}, {"name": "armorMult", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "clampHealth", "parameters": [], "return_type": ""}, {"modifiers": [], "name": "heal", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": [], "name": "healFract", "parameters": [{"name": "amount", "type": "float", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_isValid_0(_args: Array = []) -> Variant:
	return null

func java_method_healthf_1(_args: Array = []) -> Variant:
	return null

func java_method_update_2(_args: Array = []) -> Variant:
	return null

func java_method_killed_3(_args: Array = []) -> Variant:
	return null

func java_method_kill_4(_args: Array = []) -> Variant:
	return null

func java_method_heal_5(_args: Array = []) -> Variant:
	return null

func java_method_damaged_6(_args: Array = []) -> Variant:
	return null

func java_method_damagePierce_7(_args: Array = []) -> Variant:
	return null

func java_method_damagePierce_8(_args: Array = []) -> Variant:
	return null

func java_method_damageArmorMult_9(_args: Array = []) -> Variant:
	return null

func java_method_damageArmorMult_10(_args: Array = []) -> Variant:
	return null

func java_method_damage_11(_args: Array = []) -> Variant:
	return null

func java_method_damage_12(_args: Array = []) -> Variant:
	return null

func java_method_damageContinuous_13(_args: Array = []) -> Variant:
	return null

func java_method_damageContinuousPierce_14(_args: Array = []) -> Variant:
	return null

func java_method_damageContinuousArmorMult_15(_args: Array = []) -> Variant:
	return null

func java_method_clampHealth_16(_args: Array = []) -> Variant:
	return null

func java_method_heal_17(_args: Array = []) -> Variant:
	return null

func java_method_healFract_18(_args: Array = []) -> Variant:
	return null
