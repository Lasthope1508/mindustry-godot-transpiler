extends RefCounted
class_name SourceBulletTypeDamageState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_bullet_runtime := preload("res://src/game/SourceBulletRuntime.gd")

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
	var runtime_state := source_bullet_runtime.damage_multiplier_state(bullet_state, bullet_owner_state, rules_state)
	runtime_state["bullet"] = update_bullet_state
	runtime_state["owner"] = update_owner_state
	runtime_state["rules"] = update_rules_state
	runtime_state["team"] = update_bullet_state.get("team", null)
	runtime_state["ownerIsUnit"] = owner_is_unit
	runtime_state["ownerUnitDamageMultiplier"] = owner_unit_damage_multiplier
	runtime_state["ownerIsBuilding"] = owner_is_building
	runtime_state["rulesUnitDamage"] = rules_unit_damage
	runtime_state["rulesBlockDamage"] = rules_block_damage
	runtime_state["damageMultiplier"] = damage_multiplier
	runtime_state["branch"] = branch
	var source_trace := {
		"unitBranchSource": "if(b.owner instanceof Unit u) return u.damageMultiplier() * state.rules.unitDamage(b.team)",
		"buildingBranchSource": "if(b.owner instanceof Building) return state.rules.blockDamage(b.team)",
		"fallbackSource": "return 1f",
	}
	runtime_state["unitBranchSource"] = source_trace.get("unitBranchSource", "")
	runtime_state["buildingBranchSource"] = source_trace.get("buildingBranchSource", "")
	runtime_state["fallbackSource"] = source_trace.get("fallbackSource", "")
	return runtime_state

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
