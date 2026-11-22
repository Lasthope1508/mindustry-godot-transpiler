extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- Turret fogRadius() (N2531): `public float
	# fogRadius(){` / `return (range + (hasAmmo() ?
	# peekAmmo().rangeChange : 0f)) / tilesize *
	# fogRadiusMultiplier;` (Turret.java:420-422). It uses
	# the `range` FIELD plus the peeked ammo rangeChange
	# when hasAmmo() is true; it does NOT call range()
	# (Turret.java:343-347). `tilesize` is `public static
	# final int tilesize = 8;` (Vars.java:135) and
	# `fogRadiusMultiplier` is the block field `public
	# float fogRadiusMultiplier = 1f;`
	# (BaseTurret.java:24), with the one per-def override
	# `fogRadiusMultiplier = 0.4f;` (Blocks.java:5627,
	# scathe). The proof drives the pure function on exact
	# legs: 1 has ammo, range 180 + rangeChange 40 ->
	# (180+40)/8*1 = 27.5; 2 no ammo, same range and
	# rangeChange -> 180/8*1 = 22.5; 3 the BaseTurret
	# default range 80, no ammo, multiplier 1 ->
	# 80/8*1 = 10.0; 4 the scathe multiplier 0.4f, range
	# 240 -> 240/8*0.4 = 12.0; 5 the result carries exactly
	# the single `fog_radius` key; 6 the result value is a
	# float; 7 rangeChange is ignored when hasAmmo is
	# false (range 80, rc 100 -> 80/8*1 = 10.0); 8 the
	# function is param-driven and deterministic (same
	# params, same result, no hidden state).
	var result: Dictionary = turret_build_state.source_turret_fog_radius_state(180.0, true, 40.0, 8, 1.0)
	proof["fog_radius_ammo"] = is_equal_approx(float(result.get("fog_radius", 0.0)), 27.5)

	result = turret_build_state.source_turret_fog_radius_state(180.0, false, 40.0, 8, 1.0)
	proof["fog_radius_no_ammo"] = is_equal_approx(float(result.get("fog_radius", 0.0)), 22.5)

	# Phase 3: the BaseTurret.java:21 field default
	# (`public float range = 80f;`), no ammo, multiplier
	# 1 -> 80/8*1 = 10.0.
	result = turret_build_state.source_turret_fog_radius_state(80.0, false, 0.0, 8, 1.0)
	proof["fog_radius_default"] = is_equal_approx(float(result.get("fog_radius", 0.0)), 10.0)

	# Phase 4: scathe overrides fogRadiusMultiplier to
	# 0.4f (Blocks.java:5627) -> 240/8*0.4 = 12.0.
	result = turret_build_state.source_turret_fog_radius_state(240.0, false, 0.0, 8, 0.4)
	proof["fog_radius_scathe_multiplier"] = is_equal_approx(float(result.get("fog_radius", 0.0)), 12.0)

	# Phase 5: the result carries exactly the single
	# `fog_radius` key.
	result = turret_build_state.source_turret_fog_radius_state(80.0, false, 0.0, 8, 1.0)
	proof["fog_radius_single_key"] = result.keys() == ["fog_radius"]

	# Phase 6: the result value is a float.
	proof["fog_radius_float_type"] = result.get("fog_radius") is float

	# Phase 7: rangeChange is ignored when hasAmmo is
	# false -- range 80, rc 100 -> 80/8*1 = 10.0.
	result = turret_build_state.source_turret_fog_radius_state(80.0, false, 100.0, 8, 1.0)
	proof["fog_radius_range_change_ignored"] = is_equal_approx(float(result.get("fog_radius", 0.0)), 10.0)

	# Phase 8: param-driven and deterministic -- the same
	# params twice give the same result (no hidden state,
	# no catalog guess inside the function).
	var first: Dictionary = turret_build_state.source_turret_fog_radius_state(180.0, true, 40.0, 8, 1.0)
	var second: Dictionary = turret_build_state.source_turret_fog_radius_state(180.0, true, 40.0, 8, 1.0)
	proof["fog_radius_param_driven"] = first == second and is_equal_approx(float(first.get("fog_radius", 0.0)), 27.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretFogRadiusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
