# Generated from Mindustry upstream.
# Source: mindustry/ai/types/BuilderAI.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.ai.types"
const JAVA_KIND := "class"
const JAVA_NAME := "BuilderAI"
const JAVA_EXTENDS := "AIController"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["public", "static"], "name": "buildRadius", "type": "float"}, {"modifiers": ["public", "static"], "name": "retreatDst", "type": "float"}, {"modifiers": ["public", "static"], "name": "retreatDelay", "type": "float"}, {"modifiers": ["public", "static"], "name": "defaultRebuildPeriod", "type": "float"}, {"modifiers": ["public"], "name": "assistFollowing", "type": "Unit"}, {"modifiers": ["public"], "name": "following", "type": "Unit"}, {"modifiers": ["public"], "name": "enemy", "type": "Teamc"}, {"modifiers": ["public"], "name": "lastPlan", "type": "BlockPlan"}, {"modifiers": ["public"], "name": "fleeRange", "type": "float"}, {"modifiers": ["public"], "name": "rebuildPeriod", "type": "float"}, {"modifiers": ["public"], "name": "alwaysFlee", "type": "boolean"}, {"modifiers": ["public"], "name": "onlyAssist", "type": "boolean"}, {"modifiers": [], "name": "found", "type": "boolean"}, {"modifiers": [], "name": "retreatTimer", "type": "float"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "BuilderAI", "parameters": [{"name": "alwaysFlee", "type": "boolean", "varargs": false}, {"name": "fleeRange", "type": "float", "varargs": false}]}, {"modifiers": ["public"], "name": "BuilderAI", "parameters": []}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "updateMovement", "parameters": [], "return_type": ""}, {"modifiers": ["protected"], "name": "nearEnemy", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "fallback", "parameters": [], "return_type": "AIController"}, {"modifiers": ["public"], "name": "useFallback", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldFire", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "shouldShoot", "parameters": [], "return_type": "boolean"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_init_0(_args: Array = []) -> Variant:
	return null

func java_method_updateMovement_1(_args: Array = []) -> Variant:
	return null

func java_method_nearEnemy_2(_args: Array = []) -> Variant:
	return null

func java_method_fallback_3(_args: Array = []) -> Variant:
	return null

func java_method_useFallback_4(_args: Array = []) -> Variant:
	return null

func java_method_shouldFire_5(_args: Array = []) -> Variant:
	return null

func java_method_shouldShoot_6(_args: Array = []) -> Variant:
	return null
