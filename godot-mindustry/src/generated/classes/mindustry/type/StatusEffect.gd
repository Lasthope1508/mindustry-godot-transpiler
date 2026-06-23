# Generated from Mindustry upstream.
# Source: mindustry/type/StatusEffect.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.type"
const JAVA_KIND := "class"
const JAVA_NAME := "StatusEffect"
const JAVA_EXTENDS := "UnlockableContent"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public"], "name": "damageMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "healthMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "speedMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "reloadMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "buildSpeedMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "dragMultiplier", "type": "float"}, {"modifiers": ["public"], "name": "transitionDamage", "type": "float"}, {"modifiers": ["public"], "name": "disarm", "type": "boolean"}, {"modifiers": ["public"], "name": "damage", "type": "float"}, {"modifiers": ["public"], "name": "intervalDamageTime", "type": "float"}, {"modifiers": ["public"], "name": "intervalDamage", "type": "float"}, {"modifiers": ["public"], "name": "intervalDamagePierce", "type": "boolean"}, {"modifiers": ["public"], "name": "effectChance", "type": "float"}, {"modifiers": ["public"], "name": "parentizeEffect", "type": "boolean"}, {"modifiers": ["public"], "name": "permanent", "type": "boolean"}, {"modifiers": ["public"], "name": "reactive", "type": "boolean"}, {"modifiers": ["public"], "name": "dynamic", "type": "boolean"}, {"modifiers": ["public"], "name": "show", "type": "boolean"}, {"modifiers": ["public"], "name": "color", "type": "Color"}, {"modifiers": ["public"], "name": "effect", "type": "Effect"}, {"modifiers": ["public"], "name": "applyEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "applyExtend", "type": "boolean"}, {"modifiers": ["public"], "name": "applyColor", "type": "Color"}, {"modifiers": ["public"], "name": "parentizeApplyEffect", "type": "boolean"}, {"modifiers": ["public"], "name": "affinities", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "opposites", "type": "ObjectSet"}, {"modifiers": ["public"], "name": "outline", "type": "boolean"}, {"modifiers": ["protected"], "name": "transitions", "type": "ObjectMap"}, {"modifiers": ["protected"], "name": "initblock", "type": "Runnable"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "StatusEffect", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [{"name": "run", "type": "Runnable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "isHidden", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "showUnlock", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "update", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "entry", "type": "StatusEntry", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "onRemoved", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "trans", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}, {"name": "handler", "type": "TransitionHandler", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "affinity", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}, {"name": "handler", "type": "TransitionHandler", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "opposite", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": true}], "return_type": ""}, {"modifiers": ["protected"], "name": "handleOpposite", "parameters": [{"name": "other", "type": "StatusEffect", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "draw", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "reactsWith", "parameters": [{"name": "effect", "type": "StatusEffect", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "applyTransition", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "to", "type": "StatusEffect", "varargs": false}, {"name": "entry", "type": "StatusEntry", "varargs": false}, {"name": "time", "type": "float", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "applied", "parameters": [{"name": "unit", "type": "Unit", "varargs": false}, {"name": "time", "type": "float", "varargs": false}, {"name": "extend", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "createIcons", "parameters": [{"name": "packer", "type": "MultiPacker", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "toString", "parameters": [], "return_type": "String"}, {"modifiers": ["public"], "name": "getContentType", "parameters": [], "return_type": "ContentType"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_init_1(_args: Array = []) -> Variant:
	return null

func java_method_isHidden_2(_args: Array = []) -> Variant:
	return null

func java_method_setStats_3(_args: Array = []) -> Variant:
	return null

func java_method_showUnlock_4(_args: Array = []) -> Variant:
	return null

func java_method_update_5(_args: Array = []) -> Variant:
	return null

func java_method_onRemoved_6(_args: Array = []) -> Variant:
	return null

func java_method_trans_7(_args: Array = []) -> Variant:
	return null

func java_method_affinity_8(_args: Array = []) -> Variant:
	return null

func java_method_opposite_9(_args: Array = []) -> Variant:
	return null

func java_method_handleOpposite_10(_args: Array = []) -> Variant:
	return null

func java_method_draw_11(_args: Array = []) -> Variant:
	return null

func java_method_draw_12(_args: Array = []) -> Variant:
	return null

func java_method_reactsWith_13(_args: Array = []) -> Variant:
	return null

func java_method_applyTransition_14(_args: Array = []) -> Variant:
	return null

func java_method_applied_15(_args: Array = []) -> Variant:
	return null

func java_method_createIcons_16(_args: Array = []) -> Variant:
	return null

func java_method_toString_17(_args: Array = []) -> Variant:
	return null

func java_method_getContentType_18(_args: Array = []) -> Variant:
	return null
