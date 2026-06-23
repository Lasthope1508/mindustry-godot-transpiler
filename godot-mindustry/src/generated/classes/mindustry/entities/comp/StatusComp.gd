# Generated from Mindustry upstream.
# Source: mindustry/entities/comp/StatusComp.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities.comp"
const JAVA_KIND := "class"
const JAVA_NAME := "StatusComp"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := ["Posc"]
const JAVA_FIELDS := [{"modifiers": ["private"], "name": "statuses", "type": "Seq"}, {"modifiers": ["private", "transient"], "name": "applied", "type": "Bits"}, {"modifiers": ["transient"], "name": "speedMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "damageMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "healthMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "reloadMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "buildSpeedMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "dragMultiplier", "type": "float"}, {"modifiers": ["transient"], "name": "armorOverride", "type": "float"}, {"modifiers": ["transient"], "name": "disarmed", "type": "boolean"}, {"modifiers": [], "name": "type", "type": "UnitType"}, {"modifiers": [], "name": "maxHealth", "type": "float"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public"], "name": "apply", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "apply", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "getDuration", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": "float"}, {"modifiers": ["public"], "name": "clearStatuses", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "unapply", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isBoss", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "isImmune", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "statusColor", "parameters": [], "return_type": "Color"}, {"modifiers": ["public"], "name": "applyDynamicStatus", "parameters": [], "return_type": "StatusEntry"}, {"modifiers": ["public"], "name": "statusSpeed", "parameters": [{"name": "speed", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusDamageMultiplier", "parameters": [{"name": "damageMultiplier", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusReloadMultiplier", "parameters": [{"name": "reloadMultiplier", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusMaxHealth", "parameters": [{"name": "health", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusBuildSpeed", "parameters": [{"name": "buildSpeed", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusDrag", "parameters": [{"name": "drag", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "statusArmor", "parameters": [{"name": "armor", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["abstract", "public"], "name": "isGrounded", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "statusBits", "parameters": [], "return_type": "Bits"}, {"modifiers": ["public"], "name": "draw", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "hasEffect", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_apply_0(_args: Array = []) -> Variant:
	return null

func java_method_apply_1(_args: Array = []) -> Variant:
	return null

func java_method_getDuration_2(_args: Array = []) -> Variant:
	return null

func java_method_clearStatuses_3(_args: Array = []) -> Variant:
	return null

func java_method_unapply_4(_args: Array = []) -> Variant:
	return null

func java_method_isBoss_5(_args: Array = []) -> Variant:
	return null

func java_method_isImmune_6(_args: Array = []) -> Variant:
	return null

func java_method_statusColor_7(_args: Array = []) -> Variant:
	return null

func java_method_applyDynamicStatus_8(_args: Array = []) -> Variant:
	return null

func java_method_statusSpeed_9(_args: Array = []) -> Variant:
	return null

func java_method_statusDamageMultiplier_10(_args: Array = []) -> Variant:
	return null

func java_method_statusReloadMultiplier_11(_args: Array = []) -> Variant:
	return null

func java_method_statusMaxHealth_12(_args: Array = []) -> Variant:
	return null

func java_method_statusBuildSpeed_13(_args: Array = []) -> Variant:
	return null

func java_method_statusDrag_14(_args: Array = []) -> Variant:
	return null

func java_method_statusArmor_15(_args: Array = []) -> Variant:
	return null

func java_method_isGrounded_16(_args: Array = []) -> Variant:
	return null

func java_method_update_17(_args: Array = []) -> Variant:
	return null

func java_method_statusBits_18(_args: Array = []) -> Variant:
	return null

func java_method_draw_19(_args: Array = []) -> Variant:
	return null

func java_method_hasEffect_20(_args: Array = []) -> Variant:
	return null
