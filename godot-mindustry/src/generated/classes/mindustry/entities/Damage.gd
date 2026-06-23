# Generated from Mindustry upstream.
# Source: mindustry/entities/Damage.java
# Do not edit by hand.
extends RefCounted

const JAVA_PACKAGE := "mindustry.entities"
const JAVA_KIND := "class"
const JAVA_NAME := "Damage"
const JAVA_EXTENDS := ""
const JAVA_IMPLEMENTS := []
const JAVA_FIELDS := [{"modifiers": ["final", "private", "static"], "name": "bulletDamageEvent", "type": "UnitDamageEvent"}, {"modifiers": ["final", "private", "static"], "name": "rect", "type": "Rect"}, {"modifiers": ["final", "private", "static"], "name": "hitrect", "type": "Rect"}, {"modifiers": ["final", "private", "static"], "name": "vec", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "seg1", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "seg2", "type": "Vec2"}, {"modifiers": ["final", "private", "static"], "name": "collidedBlocks", "type": "IntSet"}, {"modifiers": ["final", "private", "static"], "name": "damages", "type": "IntFloatMap"}, {"modifiers": ["final", "private", "static"], "name": "collided", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "collidePool", "type": "Pool"}, {"modifiers": ["final", "private", "static"], "name": "builds", "type": "Seq"}, {"modifiers": ["final", "private", "static"], "name": "distances", "type": "FloatSeq"}, {"modifiers": ["private", "static"], "name": "furthest", "type": "Tile"}, {"modifiers": ["private", "static"], "name": "maxDst", "type": "float"}, {"modifiers": ["private", "static"], "name": "tmpBuilding", "type": "Building"}, {"modifiers": ["private", "static"], "name": "tmpUnit", "type": "Unit"}]
const JAVA_CONSTRUCTORS := []
const JAVA_METHODS := [{"modifiers": ["public", "static"], "name": "applySuppression", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "reload", "type": "float", "varargs": false}, {"name": "maxDelay", "type": "float", "varargs": false}, {"name": "applyParticleChance", "type": "float", "varargs": false}, {"name": "source", "type": "Position", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "applySuppression", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "reload", "type": "float", "varargs": false}, {"name": "maxDelay", "type": "float", "varargs": false}, {"name": "applyParticleChance", "type": "float", "varargs": false}, {"name": "source", "type": "Position", "varargs": false}, {"name": "effectColor", "type": "Color", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}, {"name": "explosionFx", "type": "Effect", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}, {"name": "explosionFx", "type": "Effect", "varargs": false}, {"name": "baseShake", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}, {"name": "fire", "type": "boolean", "varargs": false}, {"name": "ignoreTeam", "type": "Team", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}, {"name": "fire", "type": "boolean", "varargs": false}, {"name": "ignoreTeam", "type": "Team", "varargs": false}, {"name": "explosionFx", "type": "Effect", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "dynamicExplosion", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "flammability", "type": "float", "varargs": false}, {"name": "explosiveness", "type": "float", "varargs": false}, {"name": "power", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "boolean", "varargs": false}, {"name": "fire", "type": "boolean", "varargs": false}, {"name": "ignoreTeam", "type": "Team", "varargs": false}, {"name": "explosionFx", "type": "Effect", "varargs": false}, {"name": "baseShake", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "createIncend", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "range", "type": "float", "varargs": false}, {"name": "amount", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "findAbsorber", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x1", "type": "float", "varargs": false}, {"name": "y1", "type": "float", "varargs": false}, {"name": "x2", "type": "float", "varargs": false}, {"name": "y2", "type": "float", "varargs": false}], "return_type": "Building"}, {"modifiers": ["public", "static"], "name": "findLength", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "laser", "type": "boolean", "varargs": false}, {"name": "pierceCap", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "findLaserLength", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "findPierceLength", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "pierceCap", "type": "int", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "findPierceLength", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "pierceCap", "type": "int", "varargs": false}, {"name": "laser", "type": "boolean", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "collideLaser", "parameters": [{"name": "b", "type": "Bullet", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "large", "type": "boolean", "varargs": false}, {"name": "laser", "type": "boolean", "varargs": false}, {"name": "pierceCap", "type": "int", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "collideLine", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "collideLine", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "large", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "collideLine", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "large", "type": "boolean", "varargs": false}, {"name": "laser", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "collideLine", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}, {"name": "large", "type": "boolean", "varargs": false}, {"name": "laser", "type": "boolean", "varargs": false}, {"name": "pierceCap", "type": "int", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "collidePoint", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "team", "type": "Team", "varargs": false}, {"name": "effect", "type": "Effect", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "linecast", "parameters": [{"name": "hitter", "type": "Bullet", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "angle", "type": "float", "varargs": false}, {"name": "length", "type": "float", "varargs": false}], "return_type": "Healthc"}, {"modifiers": ["public", "static"], "name": "damageUnits", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "size", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "predicate", "type": "Boolf", "varargs": false}, {"name": "acceptor", "type": "Cons", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "status", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "effect", "type": "StatusEffect", "varargs": false}, {"name": "duration", "type": "float", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "complete", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "complete", "type": "boolean", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "complete", "type": "boolean", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}, {"name": "scaled", "type": "boolean", "varargs": false}, {"name": "source", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "damage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "complete", "type": "boolean", "varargs": false}, {"name": "air", "type": "boolean", "varargs": false}, {"name": "ground", "type": "boolean", "varargs": false}, {"name": "scaled", "type": "boolean", "varargs": false}, {"name": "source", "type": "Bullet", "varargs": false}, {"name": "armorMult", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tileDamage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "int", "varargs": false}, {"name": "y", "type": "int", "varargs": false}, {"name": "baseRadius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["public", "static"], "name": "tileDamage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "tx", "type": "int", "varargs": false}, {"name": "ty", "type": "int", "varargs": false}, {"name": "baseRadius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}, {"name": "source", "type": "Bullet", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "completeDamage", "parameters": [{"name": "team", "type": "Team", "varargs": false}, {"name": "x", "type": "float", "varargs": false}, {"name": "y", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": ""}, {"modifiers": ["private", "static"], "name": "calculateDamage", "parameters": [{"name": "dist", "type": "float", "varargs": false}, {"name": "radius", "type": "float", "varargs": false}, {"name": "damage", "type": "float", "varargs": false}], "return_type": "float"}, {"modifiers": ["public", "static"], "name": "applyArmor", "parameters": [{"name": "damage", "type": "float", "varargs": false}, {"name": "armor", "type": "float", "varargs": false}], "return_type": "float"}]
const JAVA_ENUM_CONSTANTS := []

func java_method_applySuppression_0(_args: Array = []) -> Variant:
	return null

func java_method_applySuppression_1(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_2(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_3(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_4(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_5(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_6(_args: Array = []) -> Variant:
	return null

func java_method_dynamicExplosion_7(_args: Array = []) -> Variant:
	return null

func java_method_createIncend_8(_args: Array = []) -> Variant:
	return null

func java_method_findAbsorber_9(_args: Array = []) -> Variant:
	return null

func java_method_findLength_10(_args: Array = []) -> Variant:
	return null

func java_method_findLaserLength_11(_args: Array = []) -> Variant:
	return null

func java_method_findPierceLength_12(_args: Array = []) -> Variant:
	return null

func java_method_findPierceLength_13(_args: Array = []) -> Variant:
	return null

func java_method_collideLaser_14(_args: Array = []) -> Variant:
	return null

func java_method_collideLine_15(_args: Array = []) -> Variant:
	return null

func java_method_collideLine_16(_args: Array = []) -> Variant:
	return null

func java_method_collideLine_17(_args: Array = []) -> Variant:
	return null

func java_method_collideLine_18(_args: Array = []) -> Variant:
	return null

func java_method_collidePoint_19(_args: Array = []) -> Variant:
	return null

func java_method_linecast_20(_args: Array = []) -> Variant:
	return null

func java_method_damageUnits_21(_args: Array = []) -> Variant:
	return null

func java_method_damage_22(_args: Array = []) -> Variant:
	return null

func java_method_damage_23(_args: Array = []) -> Variant:
	return null

func java_method_damage_24(_args: Array = []) -> Variant:
	return null

func java_method_status_25(_args: Array = []) -> Variant:
	return null

func java_method_damage_26(_args: Array = []) -> Variant:
	return null

func java_method_damage_27(_args: Array = []) -> Variant:
	return null

func java_method_damage_28(_args: Array = []) -> Variant:
	return null

func java_method_damage_29(_args: Array = []) -> Variant:
	return null

func java_method_tileDamage_30(_args: Array = []) -> Variant:
	return null

func java_method_tileDamage_31(_args: Array = []) -> Variant:
	return null

func java_method_completeDamage_32(_args: Array = []) -> Variant:
	return null

func java_method_calculateDamage_33(_args: Array = []) -> Variant:
	return null

func java_method_applyArmor_34(_args: Array = []) -> Variant:
	return null
