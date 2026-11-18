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

	# --- TurretBuild.estimateDps() (N2261):
	# TurretBuild overrides estimateDps (Turret.java:329-332,
	# `public float estimateDps(){` / `if(!hasAmmo())
	# return 0f;` / `return shoot.shots / reload * 60f *
	# (peekAmmo() == null ? 0f : peekAmmo().estimateDPS())
	# * potentialEfficiency * timeScale;`) over the
	# ShootPattern def shots (ShootPattern.java:9, `public
	# int shots = 1;`), the ReloadTurret def reload
	# (ReloadTurret.java:10, `public float reload = 10f;`),
	# the BuildingComp potentialEfficiency
	# (BuildingComp.java:89, `transient float
	# potentialEfficiency;`) and timeScale
	# (BuildingComp.java:1922-1923, `public float
	# delta(){` / `return Time.delta * timeScale;`), and
	# the peeked bullet's estimateDPS
	# (BulletType.java:414, `public float
	# estimateDPS(){`). hasAmmo() (Turret.java:698-712)
	# has a side effect (it swaps the ammo queue when the
	# first entry is short) so the pure function takes
	# has_ammo as an explicit bool; peekAmmo()
	# (Turret.java:693, `public @Nullable BulletType
	# peekAmmo(){`) is likewise not ported here -- the
	# caller passes the peeked bullet's DPS explicitly
	# (0.0 when peekAmmo() is null, the Java ternary
	# leg). The accessor is what the RTS AI reads
	# (RtsAI.java:336, `dps[0] += t.estimateDps();`);
	# the AI itself waits for its own slice. There is no
	# driver tick line: estimateDps() is a read accessor
	# the RTS AI calls, not a per-tick write (the
	# N2244/N2249 precedent). reload = 0 keeps the Java
	# float-division behavior (Infinity for a nonzero
	# numerator) -- no invented guard.

	# No ammo returns 0.0 (the Java early return).
	var no_ammo: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, false, 1, 10.0, 10.0, 1.0, 1.0)
	proof["estimate_dps_no_ammo"] = is_equal_approx(float(no_ammo.get("estimate_dps", -1.0)), 0.0)

	# A null peek (DPS 0.0) returns 0.0 (the Java
	# ternary leg).
	var peek_null: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 1, 10.0, 0.0, 1.0, 1.0)
	proof["estimate_dps_peek_null"] = is_equal_approx(float(peek_null.get("estimate_dps", -1.0)), 0.0)

	# Standard case: 1 / 10.0 * 60.0 * 10.0 * 1.0 * 1.0
	# = 60.0.
	var standard: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 1, 10.0, 10.0, 1.0, 1.0)
	proof["estimate_dps_standard"] = is_equal_approx(float(standard.get("estimate_dps", -1.0)), 60.0)

	# Shots 2 doubles it: 2 / 10.0 * 60.0 * 10.0 * 1.0
	# * 1.0 = 120.0.
	var shots_double: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 2, 10.0, 10.0, 1.0, 1.0)
	proof["estimate_dps_shots_double"] = is_equal_approx(float(shots_double.get("estimate_dps", -1.0)), 120.0)

	# Efficiency 0.5 halves it: 1 / 10.0 * 60.0 * 10.0
	# * 0.5 * 1.0 = 30.0.
	var efficiency_half: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 1, 10.0, 10.0, 0.5, 1.0)
	proof["estimate_dps_efficiency_half"] = is_equal_approx(float(efficiency_half.get("estimate_dps", -1.0)), 30.0)

	# TimeScale 2 doubles it: 1 / 10.0 * 60.0 * 10.0 *
	# 1.0 * 2.0 = 120.0.
	var time_scale_double: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 1, 10.0, 10.0, 1.0, 2.0)
	proof["estimate_dps_time_scale_double"] = is_equal_approx(float(time_scale_double.get("estimate_dps", -1.0)), 120.0)

	# reload = 0 keeps the Java float-division behavior:
	# 1 / 0.0 * 60.0 * 10.0 * 1.0 * 1.0 = Infinity.
	var reload_zero: Dictionary = turret_build_state.source_turret_estimate_dps_state({}, true, 1, 0.0, 10.0, 1.0, 1.0)
	proof["estimate_dps_reload_zero_infinity"] = is_inf(float(reload_zero.get("estimate_dps", 0.0)))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretEstimateDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
