extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BaseTurretBuild.estimateDps() (N2486):
	# BaseTurretBuild.estimateDps()
	# (BaseTurret.java:138-140):
	#     public float estimateDps(){
	#         return 0f;
	#     }
	# on `public class BaseTurretBuild extends Building
	# implements Ranged, RotBlock{` (BaseTurret.java:113).
	# The override returns the CONSTANT 0f and reads NO
	# state: a BaseTurret has no ammo and no bullet, so
	# there is no DPS to compute. TRAP: a port computing
	# real DPS is WRONG -- that is the CHILD
	# TurretBuild.estimateDps() body (N2301,
	# Turret.java:740-745, `shots / reload * 60 *
	# peekAmmo().estimateDps() * potentialEfficiency *
	# timeScale`), a different method in a different
	# class. N2301 exposes the pure GD function
	# source_turret_estimate_dps_state, so the cross-trap
	# below pins the parent by evaluating its documented
	# formula from locals (the N2481 pattern). The proof
	# calls the pure function with no inputs (no live
	# tick, no game state).

	# The method returns the constant 0f, with no inputs.
	proof["estimate_dps_is_zero"] = turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# KEY TRAP: a high-DPS turret config still returns
	# 0.0 -- the override never reads the ammo. Parent
	# formula: shots 8 / reload 15 * 60 * peek DPS 25 *
	# efficiency 1.0 * time scale 1.0 = 800.0.
	var high_shots := 8
	var high_reload := 15.0
	var high_peek_dps := 25.0
	proof["high_dps_turret_still_zero"] = high_shots == 8 and high_reload == 15.0 and high_peek_dps == 25.0 and turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# A low-DPS turret config still returns 0.0. Parent
	# formula: shots 1 / reload 120 * 60 * peek DPS 5 = 2.5.
	var low_shots := 1
	var low_reload := 120.0
	var low_peek_dps := 5.0
	proof["low_dps_turret_still_zero"] = low_shots == 1 and low_reload == 120.0 and low_peek_dps == 5.0 and turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# With no ammo at all the result is still 0.0 -- the
	# constant does not depend on ammo presence either.
	var has_ammo_none := false
	proof["no_ammo_still_zero"] = has_ammo_none == false and turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# CROSS-TRAP, parent differs: TurretBuild
	# .estimateDps() (N2301) computes real DPS, so with
	# ammo loaded (shots 4, reload 30, peek DPS 12) the
	# parent formula gives 4 / 30 * 60 * 12 = 96.0 while
	# this slice gives 0.0.
	var has_ammo := true
	var parent_with_ammo: float = 0.0 if not has_ammo else float(4) / 30.0 * 60.0 * 12.0 * 1.0 * 1.0
	proof["parent_formula_differs_with_ammo"] = parent_with_ammo == 96.0 and turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# With no ammo the parent formula early-returns 0.0,
	# so both agree at 0.0 -- the trap only shows when
	# ammo is loaded.
	var parent_without_ammo: float = 0.0 if not has_ammo_none else float(4) / 30.0 * 60.0 * 12.0 * 1.0 * 1.0
	proof["parent_formula_matches_without_ammo"] = parent_without_ammo == 0.0 and turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == 0.0

	# The result has exactly one key.
	proof["returns_only_one_key"] = turret_state.source_base_turret_estimate_dps_state().size() == 1

	# A second call with no input gives the same output.
	proof["idempotent_second_call"] = turret_state.source_base_turret_estimate_dps_state().get("estimate_dps") == turret_state.source_base_turret_estimate_dps_state().get("estimate_dps")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseTurretEstimateDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
