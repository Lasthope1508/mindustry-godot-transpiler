extends RefCounted
class_name SourceUnitTypeState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_text := preload("res://src/game/SourceUnitTypeSourceTextState.gd")

static func _generated_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/type/UnitType.gd", generated_method, generated_args, null)

static func create_controller_state(controller_get: Callable, unit: Variant) -> Dictionary:
	var missing: Array = []
	if not controller_get.is_valid():
		missing.append("controller_get")
	if not missing.is_empty():
		return {
			source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_CREATE_CONTROLLER_STATE,
			source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
			source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_METHOD,
			source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_CALL,
			source_text.SOURCE_UNIT_TYPE_UNIT_KEY: unit,
			source_text.SOURCE_UNIT_TYPE_DEFERRED_KEY: true,
			source_text.SOURCE_UNIT_TYPE_MISSING_DEPENDENCIES_KEY: missing,
		}
	return {
		source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_CREATE_CONTROLLER_STATE,
		source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
		source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_METHOD,
		source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_CALL,
		source_text.SOURCE_UNIT_TYPE_UNIT_KEY: unit,
		source_text.SOURCE_UNIT_TYPE_CONTROLLER_KEY: controller_get.call(unit),
		source_text.SOURCE_UNIT_TYPE_DEFERRED_KEY: false,
		source_text.SOURCE_UNIT_TYPE_MISSING_DEPENDENCIES_KEY: [],
	}

static func has_weapons_state(weapons: Array) -> Dictionary:
	return {
		source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_HAS_WEAPONS_STATE,
		source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
		source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_HAS_WEAPONS_METHOD,
		source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_HAS_WEAPONS_RETURN,
		source_text.SOURCE_UNIT_TYPE_WEAPONS_KEY: weapons,
		source_text.SOURCE_UNIT_TYPE_HAS_WEAPONS_KEY: not weapons.is_empty(),
	}

static func targetable_state(type_targetable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant, targeter: Variant) -> Dictionary:
	var payload_targetable := vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_TARGETABLE_STATE,
		source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
		source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_TARGETABLE_METHOD,
		source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_TARGETABLE_RETURN,
		source_text.SOURCE_UNIT_TYPE_TARGETABLE_KEY: type_targetable or payload_targetable,
		source_text.SOURCE_UNIT_TYPE_PAYLOAD_TARGETABLE_KEY: payload_targetable,
		source_text.SOURCE_UNIT_TYPE_UNIT_KEY: unit,
		source_text.SOURCE_UNIT_TYPE_TARGETER_KEY: targeter,
	}

static func killable_state(type_killable: bool, unit: Variant) -> Dictionary:
	return {
		source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_KILLABLE_STATE,
		source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
		source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_KILLABLE_METHOD,
		source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_KILLABLE_RETURN,
		source_text.SOURCE_UNIT_TYPE_KILLABLE_KEY: type_killable,
		source_text.SOURCE_UNIT_TYPE_UNIT_KEY: unit,
	}

static func hittable_state(type_hittable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant) -> Dictionary:
	var payload_hittable := vulnerable_with_payloads and unit_is_payloadc and unit_has_payload
	return {
		source_text.SOURCE_UNIT_TYPE_SOURCE_OWNER_KEY: source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_HITTABLE_STATE,
		source_text.SOURCE_UNIT_TYPE_SOURCE_KEY: source_text.SOURCE_UNIT_TYPE_SOURCE,
		source_text.SOURCE_UNIT_TYPE_METHOD_KEY: source_text.SOURCE_UNIT_TYPE_HITTABLE_METHOD,
		source_text.SOURCE_UNIT_TYPE_CALL_KEY: source_text.SOURCE_UNIT_TYPE_HITTABLE_RETURN,
		source_text.SOURCE_UNIT_TYPE_HITTABLE_KEY: type_hittable or payload_hittable,
		source_text.SOURCE_UNIT_TYPE_PAYLOAD_HITTABLE_KEY: payload_hittable,
		source_text.SOURCE_UNIT_TYPE_UNIT_KEY: unit,
	}

static func get_unit_stances_state(controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	var result_out: Array = out.duplicate(true)
	var returned_early := not controller_is_command_ai
	var branch := "none"
	if returned_early:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_GET_UNIT_STANCES_STATE,
			"source": source_text.SOURCE_UNIT_TYPE_SOURCE,
			"method": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_METHOD,
			"command_guard": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_COMMAND_GUARD,
			"controller_is_command_ai": controller_is_command_ai,
			"out": result_out,
			"returned_early": true,
			"branch": branch,
		}
	branch = "mine" if command_is_mine else "compatible"
	if command_is_mine:
		result_out.append("UnitStance.mineAuto")
		for ore_variant in present_ores:
			var ore: Dictionary = ore_variant if ore_variant is Dictionary else {}
			var ore_available := bool(ore.get("can_mine", false)) and ((mine_floor and bool(ore.get("has_ore", false))) or (mine_walls and bool(ore.get("has_wall_ore", false))))
			if ore_available and ore.get("item_stance", null) != null:
				result_out.append(ore.get("item_stance"))
	else:
		for stance_variant in stances:
			var stance: Dictionary = stance_variant if stance_variant is Dictionary else {}
			if bool(stance.get("compatible", false)):
				result_out.append(stance.get("stance"))
	result_out.append_array(extra_stances)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_GET_UNIT_STANCES_STATE,
		"source": source_text.SOURCE_UNIT_TYPE_SOURCE,
		"method": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_METHOD,
		"command_guard": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_COMMAND_GUARD,
		"mine_command_guard": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_MINE_COMMAND_GUARD,
		"mine_auto": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_MINE_AUTO,
		"extra_stances_call": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_EXTRA,
		"controller_is_command_ai": controller_is_command_ai,
		"command_is_mine": command_is_mine,
		"mine_floor": mine_floor,
		"mine_walls": mine_walls,
		"present_ores": present_ores,
		"stances": stances,
		"extra_stances": extra_stances,
		"out": result_out,
		"returned_early": returned_early,
		"branch": branch,
	}

static func allow_stance_state(stance: Variant, controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	var stopped: bool = stance == "UnitStance.stop"
	if stopped:
		return {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_ALLOW_STANCE_STATE,
			"source": source_text.SOURCE_UNIT_TYPE_SOURCE,
			"method": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_METHOD,
			"stop_guard": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_STOP_GUARD,
			"stance": stance,
			"stopped": true,
			"allowed": true,
		}
	var stances_state := get_unit_stances_state(controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)
	var allowed: bool = stances_state.get("out", []).has(stance)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_ALLOW_STANCE_STATE,
		"source": source_text.SOURCE_UNIT_TYPE_SOURCE,
		"method": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_METHOD,
		"stop_guard": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_STOP_GUARD,
		"return_expr": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_RETURN,
		"stance": stance,
		"stopped": false,
		"allowed": allowed,
		"stances_state": stances_state,
	}

static func allow_command_state(commands: Array, command: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_ALLOW_COMMAND_STATE,
		"source": source_text.SOURCE_UNIT_TYPE_SOURCE,
		"method": source_text.SOURCE_UNIT_TYPE_ALLOW_COMMAND_METHOD,
		"return_expr": source_text.SOURCE_UNIT_TYPE_ALLOW_COMMAND_RETURN,
		"commands": commands,
		"command": command,
		"allowed": commands.has(command),
	}

static func update_state(unit: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_UPDATE_STATE, "source": source_text.SOURCE_UNIT_TYPE_SOURCE, "method": source_text.SOURCE_UNIT_TYPE_UPDATE_METHOD, "no_op": true, "unit": unit, "body": source_text.SOURCE_UNIT_TYPE_NO_OP_BODY}

static func update_payload_state(unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_STATE, "source": source_text.SOURCE_UNIT_TYPE_SOURCE, "method": source_text.SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_METHOD, "no_op": true, "unit": unit, "unit_holder": unit_holder, "building_holder": building_holder, "body": source_text.SOURCE_UNIT_TYPE_NO_OP_BODY}

static func killed_state(unit: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_KILLED_STATE, "source": source_text.SOURCE_UNIT_TYPE_SOURCE, "method": source_text.SOURCE_UNIT_TYPE_KILLED_METHOD, "no_op": true, "unit": unit, "body": source_text.SOURCE_UNIT_TYPE_NO_OP_BODY}

static func landed_state(unit: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_TYPE_LANDED_STATE, "source": source_text.SOURCE_UNIT_TYPE_SOURCE, "method": source_text.SOURCE_UNIT_TYPE_LANDED_METHOD, "no_op": true, "unit": unit, "body": source_text.SOURCE_UNIT_TYPE_NO_OP_BODY}

static func source_unit_type_estimate_dps_state(cached_dps: float, weapons_dps_sum: float, has_kill_shooter_weapon: bool) -> Dictionary:
	# UnitType.estimateDps() (UnitType.java:1132-1144,
	# `public float estimateDps(){` /
	# `if(dpsEstimate < 0){` /
	# `dpsEstimate = weapons.sumf(Weapon::dps);` /
	# `if(weapons.contains(w -> w.bullet.killShooter)){` /
	# `dpsEstimate /= 15f;` /
	# `return dpsEstimate;`).
	# The cache check is `dpsEstimate < 0` (NOT `>= 0f`):
	# a cached value of 0.0 IS a hit (0 is not < 0), and a
	# negative cache (-1, the `dpsEstimate = -1,` init,
	# UnitType.java:104) recomputes. The suicide leg divides
	# the SAME field that was just summed (`dpsEstimate /=
	# 15f;`), so the divided value is what gets cached -- the
	# pure function returns the divided value through both
	# `estimate_dps` and `cached_dps` on the
	# "computed_suicide" branch. `cached_dps` is the runtime
	# cache (`dpsEstimate = -1,`, UnitType.java:104 -- -1
	# means "not computed yet"; the field doc says "a VERY
	# ROUGH estimate of unit DPS; initialized in init()").
	# `weapons_dps_sum` is the caller-summed
	# `weapons.sumf(Weapon::dps)` (UnitType.java:1136):
	# Weapon.dps() (Weapon.java:188-190, `(bullet.
	# estimateDPS() / reload) * shoot.shots * 60f`) is NOT
	# ported yet, so the sum arrives as a float param (the
	# N2529 precedent -- the spawn unit DPS was a param until
	# this slice). `has_kill_shooter_weapon` is the
	# caller-side `weapons.contains(w -> w.bullet.
	# killShooter)` guard (UnitType.java:1139): the caller
	# scans the weapons for a bullet with `killShooter`
	# (BulletType.java:105); the function cannot scan weapons
	# from a float param.
	# LIVE CONSEQUENCE: DORMANT live today.
	# estimateDps() is a read/estimate, not per-tick, and no
	# caller reads the new function today (the N2529 bullet
	# function still takes `spawn_unit_dps` /
	# `despawn_unit_dps` as float params; wiring N2529 ->
	# N2533 is a separate consumer slice; C11 HUD / stats
	# display reads `estimate_dps` in a later slice) -> live
	# behavior does NOT change. `estimateDps()` is also called
	# from `UnitType.init()` (UnitType.java:1129) -- that is a
	# content-init call site, not a per-tick driver, and this
	# slice does not wire init().
	# No gameplay change: one pure function + register +
	# test + proof only. NO driver tick call site.
	if cached_dps >= 0.0:
		return {"estimate_dps": cached_dps, "cached_dps": cached_dps, "branch": "cached"}
	var dps: float = weapons_dps_sum
	if has_kill_shooter_weapon:
		dps /= 15.0
		return {"estimate_dps": dps, "cached_dps": dps, "branch": "computed_suicide"}
	return {"estimate_dps": dps, "cached_dps": dps, "branch": "computed"}

static func generated_create_controller_bridge_state(controller_get: Callable, unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_GENERATED_METHOD, [controller_get, unit])
	var canonical := create_controller_state(controller_get, unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_CREATE_CONTROLLER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_has_weapons_bridge_state(weapons: Array) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_HAS_WEAPONS_GENERATED_METHOD, [weapons])
	var canonical := has_weapons_state(weapons)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_HAS_WEAPONS_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_targetable_bridge_state(type_targetable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant, targeter: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_TARGETABLE_GENERATED_METHOD, [type_targetable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit, targeter])
	var canonical := targetable_state(type_targetable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit, targeter)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_TARGETABLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_killable_bridge_state(type_killable: bool, unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_KILLABLE_GENERATED_METHOD, [type_killable, unit])
	var canonical := killable_state(type_killable, unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_KILLABLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_hittable_bridge_state(type_hittable: bool, vulnerable_with_payloads: bool, unit_is_payloadc: bool, unit_has_payload: bool, unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_HITTABLE_GENERATED_METHOD, [type_hittable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit])
	var canonical := hittable_state(type_hittable, vulnerable_with_payloads, unit_is_payloadc, unit_has_payload, unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_HITTABLE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_get_unit_stances_bridge_state(controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	var args := [controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out]
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_GENERATED_METHOD, args)
	var canonical := get_unit_stances_state(controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_GET_UNIT_STANCES_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_allow_stance_bridge_state(stance: Variant, controller_is_command_ai: bool, command_is_mine: bool, mine_floor: bool, mine_walls: bool, present_ores: Array, stances: Array, extra_stances: Array, out: Array) -> Dictionary:
	var args := [stance, controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out]
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_GENERATED_METHOD, args)
	var canonical := allow_stance_state(stance, controller_is_command_ai, command_is_mine, mine_floor, mine_walls, present_ores, stances, extra_stances, out)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_ALLOW_STANCE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_allow_command_bridge_state(commands: Array, command: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_ALLOW_COMMAND_GENERATED_METHOD, [commands, command])
	var canonical := allow_command_state(commands, command)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_ALLOW_COMMAND_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_update_bridge_state(unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_UPDATE_GENERATED_METHOD, [unit])
	var canonical := update_state(unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_update_payload_bridge_state(unit: Variant, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_GENERATED_METHOD, [unit, unit_holder, building_holder])
	var canonical := update_payload_state(unit, unit_holder, building_holder)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_UPDATE_PAYLOAD_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_killed_bridge_state(unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_KILLED_GENERATED_METHOD, [unit])
	var canonical := killed_state(unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_KILLED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}

static func generated_landed_bridge_state(unit: Variant) -> Dictionary:
	var result: Variant = _generated_call(source_text.SOURCE_UNIT_TYPE_LANDED_GENERATED_METHOD, [unit])
	var canonical := landed_state(unit)
	return {"generated_owner": source_text.SOURCE_UNIT_TYPE_LANDED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)}
