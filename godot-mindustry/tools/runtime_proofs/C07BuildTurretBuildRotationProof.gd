extends Node

const build_turret_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BuildTurretBuild.buildRotation() (N2477):
	# BuildTurretBuild.buildRotation() (BuildTurret.java:107-110):
	#     return unit.rotation();
	# TRAP: this reads the UNIT's rotation (the
	# BuildTurretBuild field `unit`, BuildTurret.java:93,
	# initialised to 90f at :98-100), NOT the inherited
	# `rotation` field of BaseTurretBuild (BaseTurret.java:129-131,
	# `return rotation;` -- a different method, backup B):
	# updateTile (:121) assigns the field from the unit
	# every tick, so between ticks the two can differ. The
	# proof pins the trap with a unit at 45 degrees while
	# the inherited field sits at its 90-degree default --
	# the result must be 45, not 90. TRAP: no clamp, no
	# angle normalisation -- a negative angle or an angle
	# > 360 passes through whole (Java has no Math.min/max
	# or angle wrap here). The proof calls the pure
	# function with synthetic unit-rotation values (no live
	# tick, no game state). GDScript float is 64-bit vs
	# Java float 32-bit, but the value is returned as-is
	# on both sides, so == on the float result is exact
	# for these literals.

	# KEY TRAP: unit 45 degrees, inherited field at its
	# 90-degree default -- the result must be the UNIT's
	# 45, not the field's 90.
	var trap_result: Dictionary = build_turret_state.source_build_turret_build_rotation_state(45.0)
	proof["unit_45_field_90_returns_45"] = trap_result.get("build_rotation") == 45.0 and trap_result.size() == 1

	# A unit at 0 degrees returns 0.0.
	proof["unit_0_returns_0"] = build_turret_state.source_build_turret_build_rotation_state(0.0).get("build_rotation") == 0.0

	# A unit at the 90-degree init default returns 90.
	proof["unit_90_returns_90"] = build_turret_state.source_build_turret_build_rotation_state(90.0).get("build_rotation") == 90.0

	# TRAP: a negative angle passes through -- a port that
	# clamps at 0 or normalises to [0, 360) is wrong.
	proof["unit_negative_passes_through"] = build_turret_state.source_build_turret_build_rotation_state(-45.0).get("build_rotation") == -45.0

	# TRAP: an angle > 360 passes through -- a port that
	# wraps with fmod is wrong.
	proof["unit_above_360_passes_through"] = build_turret_state.source_build_turret_build_rotation_state(450.0).get("build_rotation") == 450.0

	# A fractional angle is returned exactly, with no
	# rounding (direct float pass-through).
	proof["unit_fractional_precision"] = build_turret_state.source_build_turret_build_rotation_state(33.75).get("build_rotation") == 33.75

	# The result has exactly one key.
	proof["returns_only_one_key"] = build_turret_state.source_build_turret_build_rotation_state(180.0).size() == 1

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = build_turret_state.source_build_turret_build_rotation_state(180.0).get("build_rotation") == build_turret_state.source_build_turret_build_rotation_state(180.0).get("build_rotation")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretBuildRotationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
