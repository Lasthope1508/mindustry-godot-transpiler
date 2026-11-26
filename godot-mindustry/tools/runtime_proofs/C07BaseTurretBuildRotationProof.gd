extends Node

const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BaseTurretBuild.buildRotation() (N2479):
	# BaseTurretBuild.buildRotation() (BaseTurret.java:129-131):
	#     return rotation;
	# TRAP: this reads the INHERITED `rotation` FIELD (the
	# BaseTurretBuild field `rotation`, BaseTurret.java:114,
	# initialised to 90f), NOT the unit's rotation -- the
	# OPPOSITE of N2477 BuildTurretBuild.buildRotation()
	# (BuildTurret.java:107-110, `return unit.rotation();`):
	# the function takes only the field value, so a unit
	# sitting at 77 degrees is irrelevant here. The proof
	# pins the cross-trap with field 33 (unit 77) -- the
	# result must be 33, not 77 (N2477 returns 77 for the
	# same pair). TRAP: no clamp, no angle normalisation --
	# a negative angle or an angle > 360 passes through
	# whole (Java has no Math.min/max or angle wrap here).
	# The proof calls the pure function with synthetic
	# field-rotation values (no live tick, no game state).
	# GDScript float is 64-bit vs Java float 32-bit, but
	# the value is returned as-is on both sides, so == on
	# the float result is exact for these literals.

	# KEY TRAP: field 33 degrees, unit at 77 degrees -- the
	# result must be the FIELD's 33, not the unit's 77.
	var trap_result: Dictionary = turret_state.source_base_turret_build_rotation_state(33.0)
	proof["field_33_unit_77_returns_33"] = trap_result.get("build_rotation") == 33.0 and trap_result.size() == 1

	# A field at the 90-degree default returns 90.
	proof["field_90_default_returns_90"] = turret_state.source_base_turret_build_rotation_state(90.0).get("build_rotation") == 90.0

	# A field at 0 degrees returns 0.0.
	proof["field_0_returns_0"] = turret_state.source_base_turret_build_rotation_state(0.0).get("build_rotation") == 0.0

	# TRAP: a negative angle passes through -- a port that
	# clamps at 0 or normalises to [0, 360) is wrong.
	proof["field_negative_passes_through"] = turret_state.source_base_turret_build_rotation_state(-45.0).get("build_rotation") == -45.0

	# TRAP: an angle > 360 passes through -- a port that
	# wraps with fmod is wrong.
	proof["field_above_360_passes_through"] = turret_state.source_base_turret_build_rotation_state(450.0).get("build_rotation") == 450.0

	# A fractional angle is returned exactly, with no
	# rounding (direct float pass-through).
	proof["field_fractional_precision"] = turret_state.source_base_turret_build_rotation_state(33.75).get("build_rotation") == 33.75

	# The result has exactly one key.
	proof["returns_only_one_key"] = turret_state.source_base_turret_build_rotation_state(180.0).size() == 1

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = turret_state.source_base_turret_build_rotation_state(180.0).get("build_rotation") == turret_state.source_base_turret_build_rotation_state(180.0).get("build_rotation")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BaseTurretBuildRotationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
