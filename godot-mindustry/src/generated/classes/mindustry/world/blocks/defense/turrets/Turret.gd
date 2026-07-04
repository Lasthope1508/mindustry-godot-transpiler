# Generated from Mindustry upstream.
# Source: mindustry/world/blocks/defense/turrets/Turret.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.world.blocks.defense.turrets"
const JAVA_KIND := "class"
const JAVA_NAME := "Turret"
const JAVA_EXTENDS := "ReloadTurret"
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "public", "static"], "name": "logicControlCooldown", "type": "float"}, {"modifiers": ["final", "public"], "name": "timerTarget", "type": "int"}, {"modifiers": ["public"], "name": "targetInterval", "type": "float"}, {"modifiers": ["public"], "name": "newTargetInterval", "type": "float"}, {"modifiers": ["public"], "name": "maxAmmo", "type": "int"}, {"modifiers": ["public"], "name": "ammoPerShot", "type": "int"}, {"modifiers": ["public"], "name": "consumeAmmoOnce", "type": "boolean"}, {"modifiers": ["public"], "name": "heatRequirement", "type": "float"}, {"modifiers": ["public"], "name": "maxHeatEfficiency", "type": "float"}, {"modifiers": ["public"], "name": "inaccuracy", "type": "float"}, {"modifiers": ["public"], "name": "velocityRnd", "type": "float"}, {"modifiers": ["public"], "name": "scaleLifetimeOffset", "type": "float"}, {"modifiers": ["public"], "name": "shootCone", "type": "float"}, {"modifiers": ["public"], "name": "shootX", "type": "float"}, {"modifiers": ["public"], "name": "shootY", "type": "float"}, {"modifiers": ["public"], "name": "xRand", "type": "float"}, {"modifiers": ["public"], "name": "drawMinRange", "type": "boolean"}, {"modifiers": ["public"], "name": "trackingRange", "type": "float"}, {"modifiers": ["public"], "name": "minRange", "type": "float"}, {"modifiers": ["public"], "name": "minWarmup", "type": "float"}, {"modifiers": ["public"], "name": "accurateDelay", "type": "boolean"}, {"modifiers": ["public"], "name": "moveWhileCharging", "type": "boolean"}, {"modifiers": ["public"], "name": "reloadWhileCharging", "type": "boolean"}, {"modifiers": ["public"], "name": "warmupMaintainTime", "type": "float"}, {"modifiers": ["public"], "name": "shoot", "type": "ShootPattern"}, {"modifiers": ["public"], "name": "targetAir", "type": "boolean"}, {"modifiers": ["public"], "name": "targetGround", "type": "boolean"}, {"modifiers": ["public"], "name": "targetBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "targetHealing", "type": "boolean"}, {"modifiers": ["public"], "name": "playerControllable", "type": "boolean"}, {"modifiers": ["public"], "name": "displayAmmoMultiplier", "type": "boolean"}, {"modifiers": ["public"], "name": "targetUnderBlocks", "type": "boolean"}, {"modifiers": ["public"], "name": "alwaysShooting", "type": "boolean"}, {"modifiers": ["public"], "name": "predictTarget", "type": "boolean"}, {"modifiers": ["public"], "name": "unitSort", "type": "Sortf"}, {"modifiers": ["public"], "name": "unitFilter", "type": "Boolf"}, {"modifiers": ["public"], "name": "buildingFilter", "type": "Boolf"}, {"modifiers": ["public"], "name": "heatColor", "type": "Color"}, {"modifiers": ["public"], "name": "shootEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "smokeEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "ammoUseEffect", "type": "Effect"}, {"modifiers": ["public"], "name": "shootSound", "type": "Sound"}, {"modifiers": ["public"], "name": "shootSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "chargeSound", "type": "Sound"}, {"modifiers": ["public"], "name": "loopSound", "type": "Sound"}, {"modifiers": ["public"], "name": "loopSoundVolume", "type": "float"}, {"modifiers": ["public"], "name": "soundPitchMin", "type": "float"}, {"modifiers": ["public"], "name": "soundPitchMax", "type": "float"}, {"modifiers": ["public"], "name": "ammoEjectBack", "type": "float"}, {"modifiers": ["public"], "name": "shootWarmupSpeed", "type": "float"}, {"modifiers": ["public"], "name": "linearWarmup", "type": "boolean"}, {"modifiers": ["public"], "name": "recoil", "type": "float"}, {"modifiers": ["public"], "name": "recoils", "type": "int"}, {"modifiers": ["public"], "name": "recoilTime", "type": "float"}, {"modifiers": ["public"], "name": "recoilPow", "type": "float"}, {"modifiers": ["public"], "name": "cooldownTime", "type": "float"}, {"modifiers": ["public"], "name": "elevation", "type": "float"}, {"modifiers": ["public"], "name": "shake", "type": "float"}, {"modifiers": ["public"], "name": "drawer", "type": "DrawBlock"}]
const JAVA_CONSTRUCTORS := [{"modifiers": ["public"], "name": "Turret", "parameters": [{"name": "name", "type": "String", "varargs": false}]}]
const JAVA_METHODS := [{"modifiers": ["public"], "name": "outputsItems", "parameters": [], "return_type": "boolean"}, {"modifiers": ["public"], "name": "setStats", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "setBars", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "init", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "load", "parameters": [], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlanRegion", "parameters": [{"name": "plan", "type": "BuildPlan", "varargs": false}, {"name": "list", "type": "Eachable", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "icons", "parameters": [], "return_type": "TextureRegion"}, {"modifiers": ["public"], "name": "getRegionsToOutline", "parameters": [{"name": "out", "type": "Seq", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "limitRange", "parameters": [{"name": "bullet", "type": "BulletType", "varargs": false}, {"name": "margin", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "drawPlace", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "valid", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public"], "name": "rotatedOutput", "parameters": [{"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}], "return_type": "boolean"}, {"modifiers": ["public"], "name": "placeEnded", "parameters": [{"name": "tile", "type": "Tile", "varargs": false}, {"name": "builder", "type": "Unit", "varargs": false}, {"name": "rotation", "type": "int", "varargs": false}, {"name": "config", "type": "Object", "varargs": false}], "return_type": ""}]
const JAVA_ENUM_CONSTANTS := []

func java_method_outputsItems_0(_args: Array = []) -> Variant:
	return {"source_owner": "PortGame.source_turret_outputs_items_state", "method": "public boolean outputsItems(){", "override_expr": "@Override", "return_expr": "return false;", "outputs_items": false}

func java_method_setStats_1(_args: Array = []) -> Variant:
	return null

func java_method_setBars_2(_args: Array = []) -> Variant:
	return null

func java_method_init_3(_args: Array = []) -> Variant:
	return null

func java_method_load_4(_args: Array = []) -> Variant:
	return null

func java_method_drawPlanRegion_5(_args: Array = []) -> Variant:
	return null

func java_method_icons_6(_args: Array = []) -> Variant:
	return null

func java_method_getRegionsToOutline_7(_args: Array = []) -> Variant:
	return null

func java_method_limitRange_8(_args: Array = []) -> Variant:
	return null

func java_method_drawPlace_9(_args: Array = []) -> Variant:
	return null

func java_method_rotatedOutput_10(_args: Array = []) -> Variant:
	return null

func java_method_placeEnded_11(_args: Array = []) -> Variant:
	return null
