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

	# --- Turret estimateDps() (N2528): `public float estimateDps(){` /
	# `if(!hasAmmo()) return 0f;` /
	# `return shoot.shots / reload * 60f * (peekAmmo() == null ? 0f : peekAmmo().estimateDPS()) * potentialEfficiency * timeScale;`
	# (Turret.java:329-333). `shots` is the ShootPattern field
	# (`public int shots = 1;`, ShootPattern.java:9 -- salvo 2,
	# ripple 4, smite 2, malign 4 per-def, Blocks.java); `reload`
	# is the per-def reload time (`public float reload = 10f;`,
	# ReloadTurret.java:10 -- duo 20f, foreshadow 200f,
	# Blocks.java); `60f` is SourceTimeDefaults.TICK_RATE;
	# `potentialEfficiency` is the frame-stamped efficiency fold
	# (default 1.0); `timeScale` is the BuildingComp transient
	# field (default 1f). `has_ammo` is a bool param (hasAmmo()
	# mutates the ammo stack, Turret.java:703, so it cannot be
	# a pure read); `peek_ammo_dps` is a float param -- the DPS
	# value itself comes from BulletType.estimateDPS()
	# (BulletType.java:414, the N2529 follow-up), not computed
	# here. The proof drives the pure function on exact legs:
	# 1 no ammo -> 0.0; 2 ammo but no peek ammo -> 0.0; 3 shots
	# 2 / reload 10 / dps 30 / potEff 1.0 / timeScale 1.0 ->
	# 360.0; 4 potentialEfficiency 0.5 -> 180.0 (half); 5
	# timeScale 2.0 -> 720.0 (double); 6 shots 4 / reload 200
	# (foreshadow) / dps 30 -> 36.0; 7 shots 1 / reload 20
	# (duo) / dps 30 -> 90.0; 8 peek dps 0.0 with ammo -> 0.0.
	var frame: Dictionary = {}

	# Phase 1: no ammo -> 0.0 (the hasAmmo() leg fires first,
	# even with a peek dps of 30.0).
	frame = {"potential_efficiency": 1.0}
	var estimate: Dictionary = turret_build_state.source_turret_estimate_dps_state(frame, false, true, 30.0, 2, 10.0, 1.0)
	proof["estimate_dps_zero_no_ammo"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 0.0)

	# Phase 2: ammo but no peek ammo -> 0.0 (the
	# `peekAmmo() == null ? 0f` leg).
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, false, 30.0, 2, 10.0, 1.0)
	proof["estimate_dps_zero_no_peek_ammo"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 0.0)

	# Phase 3: shots 2 / reload 10 / dps 30 / potEff 1.0 /
	# timeScale 1.0 -> 2 / 10 * 60 * 30 = 360.0.
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 30.0, 2, 10.0, 1.0)
	proof["estimate_dps_shots_two_reload_ten"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 360.0)

	# Phase 4: potentialEfficiency 0.5 -> half of phase 3:
	# 360.0 * 0.5 = 180.0.
	frame = {"potential_efficiency": 0.5}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 30.0, 2, 10.0, 1.0)
	proof["estimate_dps_half_potential_efficiency"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 180.0)

	# Phase 5: timeScale 2.0 -> double of phase 3:
	# 360.0 * 2.0 = 720.0.
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 30.0, 2, 10.0, 2.0)
	proof["estimate_dps_double_time_scale"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 720.0)

	# Phase 6: shots 4 / reload 200 (foreshadow) / dps 30 ->
	# 4 / 200 * 60 * 30 = 36.0.
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 30.0, 4, 200.0, 1.0)
	proof["estimate_dps_shots_four_reload_large"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 36.0)

	# Phase 7: shots 1 / reload 20 (duo) / dps 30 ->
	# 1 / 20 * 60 * 30 = 90.0.
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 30.0, 1, 20.0, 1.0)
	proof["estimate_dps_duo_default"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 90.0)

	# Phase 8: peek dps 0.0 with ammo -> 0.0 (the formula
	# multiplies through zero).
	frame = {"potential_efficiency": 1.0}
	estimate = turret_build_state.source_turret_estimate_dps_state(frame, true, true, 0.0, 2, 10.0, 1.0)
	proof["estimate_dps_zero_peek_dps"] = is_equal_approx(float(estimate.get("estimate_dps", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretEstimateDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
