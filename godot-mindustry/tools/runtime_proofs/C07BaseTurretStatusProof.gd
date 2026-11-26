extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BaseTurretBuild.status() (N2475):
	# BaseTurretBuild.status() (BaseTurret.java:143-145):
	#     return (activationTimer <= 0)? super.status() : BlockStatus.inactive;
	# TRAP: the boundary is `<= 0` -- timer 0 returns the
	# base status, NOT inactive. TRAP: super.status() is
	# BuildingComp.status() (N1888) and arrives as the
	# precomputed base_status input. TRAP: `inactive` is
	# NOT `inactiveUnitFactory`. The proof calls the pure
	# function with synthetic (timer, base) pairs (no live
	# tick, no game state). GDScript float is 64-bit vs
	# Java float 32-bit, but the comparison is exact on
	# these values, so == on the String result is exact.

	# A positive timer forces "inactive" whatever the base.
	var positive_result: Dictionary = turret_state.source_base_turret_build_status_state(30.0, "active")
	proof["timer_positive_inactive"] = positive_result.get("status") == "inactive" and positive_result.size() == 1

	# TRAP: timer 0 returns the base status (the `<= 0`
	# boundary -- a port using `< 0` is wrong).
	proof["timer_zero_returns_base"] = turret_state.source_base_turret_build_status_state(0.0, "active").get("status") == "active"

	# A negative timer also passes the base through
	# (Java has no clamp here).
	proof["timer_negative_returns_base"] = turret_state.source_base_turret_build_status_state(-1.0, "noOutput").get("status") == "noOutput"

	# A positive timer overrides logicDisable too.
	proof["timer_positive_overrides_logic_disable"] = turret_state.source_base_turret_build_status_state(5.0, "logicDisable").get("status") == "inactive"

	# Timer 0 passes "noInput" through unchanged.
	proof["timer_zero_passes_no_input"] = turret_state.source_base_turret_build_status_state(0.0, "noInput").get("status") == "noInput"

	# TRAP: even a tiny positive timer (0.001) is already
	# inactive -- there is no epsilon.
	proof["tiny_positive_inactive"] = turret_state.source_base_turret_build_status_state(0.001, "active").get("status") == "inactive"

	# TRAP: "inactiveUnitFactory" is a DIFFERENT enum
	# value -- a positive timer overrides it to "inactive".
	proof["timer_positive_overrides_inactive_unit_factory"] = turret_state.source_base_turret_build_status_state(2.0, "inactiveUnitFactory").get("status") == "inactive"

	# A repeated call with the same inputs is identical.
	var first: Dictionary = turret_state.source_base_turret_build_status_state(30.0, "active")
	var second: Dictionary = turret_state.source_base_turret_build_status_state(30.0, "active")
	proof["idempotent_second_call"] = first == second and first.get("status") == "inactive"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseTurretStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
