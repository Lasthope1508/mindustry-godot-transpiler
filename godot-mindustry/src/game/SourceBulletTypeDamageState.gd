extends RefCounted
class_name SourceBulletTypeDamageState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")

const SOURCE_BULLET_SHIELD_DAMAGE_MULTIPLIER_DEFAULT := source_bullet_defaults.SHIELD_DAMAGE_MULTIPLIER_DEFAULT
const SOURCE_BULLET_DAMAGE_MULTIPLIER_DEFAULT := source_bullet_defaults.DAMAGE_MULTIPLIER_DEFAULT
const SOURCE_BULLET_OWNER_UNIT_DAMAGE_MULTIPLIER_DEFAULT := source_bullet_defaults.OWNER_UNIT_DAMAGE_MULTIPLIER_DEFAULT
const SOURCE_BULLET_RULES_UNIT_DAMAGE_DEFAULT := source_bullet_defaults.RULES_UNIT_DAMAGE_DEFAULT
const SOURCE_BULLET_RULES_BLOCK_DAMAGE_DEFAULT := source_bullet_defaults.RULES_BLOCK_DAMAGE_DEFAULT

static func damage_multiplier_state(bullet_state: Dictionary, bullet_owner_state: Dictionary, rules_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var update_owner_state: Dictionary = bullet_owner_state.duplicate(true)
	var update_rules_state: Dictionary = rules_state.duplicate(true)
	var owner_is_unit := bool(update_owner_state.get("isUnit", false))
	var owner_unit_damage_multiplier := float(update_owner_state.get("unitDamageMultiplier", SOURCE_BULLET_OWNER_UNIT_DAMAGE_MULTIPLIER_DEFAULT))
	var owner_is_building := bool(update_owner_state.get("isBuilding", false))
	var rules_unit_damage := float(update_rules_state.get("unitDamage", SOURCE_BULLET_RULES_UNIT_DAMAGE_DEFAULT))
	var rules_block_damage := float(update_rules_state.get("blockDamage", SOURCE_BULLET_RULES_BLOCK_DAMAGE_DEFAULT))
	var damage_multiplier := SOURCE_BULLET_DAMAGE_MULTIPLIER_DEFAULT
	var branch := "fallback"
	if owner_is_unit:
		damage_multiplier = owner_unit_damage_multiplier * rules_unit_damage
		branch = "unit"
	elif owner_is_building:
		damage_multiplier = rules_block_damage
		branch = "building"
	return {
		"bullet": update_bullet_state,
		"owner": update_owner_state,
		"rules": update_rules_state,
		"team": update_bullet_state.get("team", null),
		"ownerIsUnit": owner_is_unit,
		"ownerUnitDamageMultiplier": owner_unit_damage_multiplier,
		"ownerIsBuilding": owner_is_building,
		"rulesUnitDamage": rules_unit_damage,
		"rulesBlockDamage": rules_block_damage,
		"damageMultiplier": damage_multiplier,
		"branch": branch,
		"unitBranchSource": "if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team)",
		"buildingBranchSource": "if(b.owner instanceof Building) return state.rules.blockDamage(b.team)",
		"fallbackSource": "return 1f",
	}

static func building_damage_state(bullet_state: Dictionary) -> Dictionary:
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var damage := float(update_bullet_state.get("damage", 0.0))
	var building_damage_multiplier := float(update_bullet_state.get("buildingDamageMultiplier", source_bullet_defaults.BUILDING_DAMAGE_MULTIPLIER_DEFAULT))
	var building_damage := damage * building_damage_multiplier
	return {
		"bullet": update_bullet_state,
		"damage": damage,
		"buildingDamageMultiplier": building_damage_multiplier,
		"buildingDamage": building_damage,
		"buildingDamageReturnSource": "return b.damage() * b.buildingDamageMultiplier",
	}

static func shield_damage_state(bullet_type_state: Dictionary, bullet_state: Dictionary) -> Dictionary:
	var update_type_state: Dictionary = bullet_type_state.duplicate(true)
	var update_bullet_state: Dictionary = bullet_state.duplicate(true)
	var damage := float(update_bullet_state.get("damage", 0.0))
	var shield_damage_multiplier := float(update_type_state.get("shieldDamageMultiplier", SOURCE_BULLET_SHIELD_DAMAGE_MULTIPLIER_DEFAULT))
	var shield_damage := damage * shield_damage_multiplier
	return {
		"bulletType": update_type_state,
		"bullet": update_bullet_state,
		"damage": damage,
		"shieldDamageMultiplier": shield_damage_multiplier,
		"shieldDamage": shield_damage,
		"shieldDamageReturnSource": "return b.damage() * shieldDamageMultiplier",
	}

static func source_bullet_type_estimate_dps_state(damage: float, splash_damage: float, pierce: bool, pierce_cap: int, cached_dps: float, has_spawn_unit: bool, spawn_unit_dps: float, has_despawn_unit: bool, despawn_unit_dps: float, has_frag_bullet: bool, frag_bullet_dps: float, frag_bullets: int, spawn_bullets_dps_sum: float) -> Dictionary:
	# BulletType.estimateDPS() (BulletType.java:414-435,
	# `public float estimateDPS(){` /
	# `if(cachedDps >= 0f) return cachedDps;` /
	# `if(spawnUnit != null){` /
	# `return spawnUnit.estimateDps();` /
	# `if(despawnUnit != null){` /
	# `return despawnUnit.estimateDps();` /
	# `float sum = (damage + splashDamage*0.75f) * (pierce ? pierceCap == -1 ? 2 : Mathf.clamp(pierceCap, 1, 2) : 1f);` /
	# `if(fragBullet != null && fragBullet != this){` /
	# `sum += fragBullet.estimateDPS() * fragBullets / 2f;` /
	# `for(var other : spawnBullets){` /
	# `sum += other.estimateDPS();` /
	# `return cachedDps = sum;`).
	# The legs run in exact Java order: the cache hit
	# returns `cached_dps` first; the spawnUnit /
	# despawnUnit legs return the unit DPS WITHOUT writing
	# the cache (Java returns before the `cachedDps = sum`
	# line); only the computed leg writes the cache, and
	# the pure function returns the new cache value through
	# the `cached_dps` key (it never mutates state
	# outside). `damage` is the BulletType field
	# (`public float damage = 1f;`, BulletType.java:41 --
	# the class default). `splash_damage` is the field
	# (`public float splashDamage = 0f;`,
	# BulletType.java:109). `pierce` is the field
	# (`public boolean pierce;`, BulletType.java:53 --
	# false by default). `pierce_cap` is the field
	# (`public int pierceCap = -1;`, BulletType.java:57).
	# `cached_dps` is the runtime cache
	# (`protected float cachedDps = -1;`,
	# BulletType.java:377 -- -1 means "not computed yet").
	# `has_spawn_unit` / `spawn_unit_dps` and
	# `has_despawn_unit` / `despawn_unit_dps` are bool +
	# float param pairs: UnitType.estimateDps()
	# (UnitType.java:1132-1144) is NOT ported yet, so the
	# unit DPS arrives as a param (the N2528 precedent).
	# The frag guard (`fragBullet != this`,
	# BulletType.java:425) arrives as the
	# `has_frag_bullet` bool param: the caller passes false
	# when the frag bullet is the bullet itself
	# (self-frag), the function cannot tell identity from
	# a float param. `frag_bullets` is the field
	# (`public int fragBullets = 9;`, BulletType.java:212).
	# `spawn_bullets_dps_sum` is the caller-summed
	# `estimateDPS()` of every `spawnBullets` entry
	# (`for(var other : spawnBullets){ sum +=
	# other.estimateDPS(); }`, BulletType.java:429-431).
	# Java doc: "this can be very inaccurate" -- the
	# function keeps the exact Java formula including
	# that inaccuracy (the N2128 +/-2 deg precedent: never
	# "fix" Java to make a proof prettier).
	# LIVE CONSEQUENCE: DORMANT live today.
	# estimateDPS() is a read/estimate, not per-tick, and
	# no caller reads the new function today (the N2528
	# turret function still takes `peek_ammo_dps` as a
	# param; wiring N2528 -> N2529 is a separate consumer
	# slice; C11 HUD / stats display reads `estimate_dps`
	# in a later slice) -> live behavior does NOT change.
	# When the wiring consumer lands, this function is
	# the canonical owner of BulletType estimateDPS().
	# No gameplay change: one pure function + register +
	# test + proof only. NO driver tick call site.
	if cached_dps >= 0.0:
		return {"estimate_dps": cached_dps, "cached_dps": cached_dps, "branch": "cached"}
	if has_spawn_unit:
		return {"estimate_dps": spawn_unit_dps, "cached_dps": cached_dps, "branch": "spawn_unit"}
	if has_despawn_unit:
		return {"estimate_dps": despawn_unit_dps, "cached_dps": cached_dps, "branch": "despawn_unit"}
	var pierce_multiplier: float = 1.0
	if pierce:
		pierce_multiplier = 2.0 if pierce_cap == -1 else float(clampi(pierce_cap, 1, 2))
	var sum: float = (damage + splash_damage * 0.75) * pierce_multiplier
	if has_frag_bullet:
		sum += frag_bullet_dps * float(frag_bullets) / 2.0
	sum += spawn_bullets_dps_sum
	return {"estimate_dps": sum, "cached_dps": sum, "branch": "computed"}
