extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- ReloadTurretBuild.baseReloadSpeed() (N2476):
	# ReloadTurretBuild.baseReloadSpeed() (ReloadTurret.java:45-47):
	#     return efficiency;
	# TRAP: efficiency is returned WHOLE -- no clamp, no
	# floor: 0 stays 0.0, > 1 passes through, and a negative
	# value passes through (Java has no Math.min/max here;
	# the cap in updateReload is on reloadCounter, not on
	# this factor). TRAP: do NOT confuse with
	# ammoReloadMultiplier() (ReloadTurret.java:41-43,
	# returns the constant 1f) or
	# TurretBuild.ammoReloadMultiplier() (N746, a ternary on
	# peekAmmo) -- baseReloadSpeed never looks at ammo. The
	# proof calls the pure function with synthetic
	# efficiency values (no live tick, no game state).
	# GDScript float is 64-bit vs Java float 32-bit, but the
	# value is returned as-is on both sides, so == on the
	# float result is exact for these literals.

	# Full efficiency is 1.0.
	var one_result: Dictionary = turret_state.source_reload_turret_base_reload_speed_state(1.0)
	proof["efficiency_1_returns_1"] = one_result.get("base_reload_speed") == 1.0 and one_result.size() == 1

	# TRAP: 0 stays 0.0 -- not a default of 1, not floored.
	proof["efficiency_0_returns_0"] = turret_state.source_reload_turret_base_reload_speed_state(0.0).get("base_reload_speed") == 0.0

	# TRAP: > 1 passes through -- a port that clamps to
	# [0, 1] is wrong.
	proof["efficiency_above_1_passes_through"] = turret_state.source_reload_turret_base_reload_speed_state(1.5).get("base_reload_speed") == 1.5

	# TRAP: a negative efficiency passes through -- a port
	# that clamps at 0 is wrong (Java has no Math.max here).
	proof["efficiency_negative_passes_through"] = turret_state.source_reload_turret_base_reload_speed_state(-0.5).get("base_reload_speed") == -0.5

	# Half efficiency is 0.5.
	proof["efficiency_half_returns_half"] = turret_state.source_reload_turret_base_reload_speed_state(0.5).get("base_reload_speed") == 0.5

	# A fractional efficiency is returned exactly, with no
	# rounding (direct float pass-through).
	proof["efficiency_fractional_precision"] = turret_state.source_reload_turret_base_reload_speed_state(0.333).get("base_reload_speed") == 0.333

	# The result has exactly one key.
	proof["returns_only_one_key"] = turret_state.source_reload_turret_base_reload_speed_state(0.75).size() == 1

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = turret_state.source_reload_turret_base_reload_speed_state(0.75).get("base_reload_speed") == turret_state.source_reload_turret_base_reload_speed_state(0.75).get("base_reload_speed")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ReloadTurretBaseReloadSpeedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
