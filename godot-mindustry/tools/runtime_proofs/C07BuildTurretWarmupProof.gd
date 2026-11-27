extends Node

const build_turret_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BuildTurretBuild.warmup() (N2482):
	# BuildTurretBuild.warmup() (BuildTurret.java:254-255):
	#     return warmup;
	# on `public class BuildTurretBuild extends BaseTurretBuild
	# implements ControlBlock, RotBlock{` (BuildTurret.java:92).
	# The field `public float warmup;` (BuildTurret.java:96)
	# is lerped by updateTile every tick (`warmup =
	# Mathf.lerpDelta(warmup, unit.activelyBuilding() ?
	# efficiency : 0f, 0.1f);`, BuildTurret.java:136-137)
	# and read by draw() for the glow (`Drawf.additive(
	# glowRegion, heatColor, warmup, x, y, rotation - 90f,
	# Layer.turretHeat);`, BuildTurret.java:247) -- this
	# slice is ONLY the accessor: return the field whole, no
	# clamp, no floor. TRAP: a port clamping to [0, 1] is
	# wrong -- warmup follows efficiency, and efficiency > 1
	# passes through whole. TRAP: this is NOT
	# TurretBuild.warmup() (N2297, Turret.java:354-356,
	# `return shootWarmup;`) -- the parent-class method
	# reads a different field (`public float shootWarmup,
	# charge, warmupHold = 0f;`, Turret.java:1592), so the
	# two can differ. The proof drives the pure function
	# with the precomputed warmup field (no live tick, no
	# game state) and pins the cross-trap by driving the
	# parent method (N2297, source_turret_warmup_state)
	# with the same value in both directions.

	# KEY TRAP: warmup = 1.5 passes through whole -- no
	# clamp to [0, 1] even though the field is lerped
	# toward efficiency each tick.
	proof["warmup_one_point_five_passes_through"] = build_turret_state.source_build_turret_warmup_state(1.5).get("warmup") == 1.5

	# Warmup 0 stays 0.0.
	proof["warmup_zero_is_zero"] = build_turret_state.source_build_turret_warmup_state(0.0).get("warmup") == 0.0

	# A mid-range warmup passes through whole.
	proof["warmup_half_passes_through"] = build_turret_state.source_build_turret_warmup_state(0.5).get("warmup") == 0.5

	# A negative warmup passes through whole -- no floor.
	proof["warmup_negative_passes_through"] = build_turret_state.source_build_turret_warmup_state(-0.5).get("warmup") == -0.5

	# CROSS-TRAP, parent differs: TurretBuild.warmup()
	# (N2297) reads shootWarmup, so with shootWarmup =
	# 0.25 it returns 0.25 while this slice returns 1.5
	# for warmup = 1.5 -- the two fields are different.
	proof["parent_warmup_differs"] = turret_state.source_turret_warmup_state({}, 0.25).get("warmup") == 0.25 and build_turret_state.source_build_turret_warmup_state(1.5).get("warmup") == 1.5 and turret_state.source_turret_warmup_state({}, 0.25).get("warmup") != build_turret_state.source_build_turret_warmup_state(1.5).get("warmup")

	# When the two fields coincide numerically the methods
	# agree: both return 0.75, so the trap only shows when
	# the fields differ.
	proof["parent_warmup_matches_when_equal"] = turret_state.source_turret_warmup_state({}, 0.75).get("warmup") == 0.75 and build_turret_state.source_build_turret_warmup_state(0.75).get("warmup") == 0.75

	# The result has exactly one key.
	proof["returns_only_one_key"] = build_turret_state.source_build_turret_warmup_state(1.5).size() == 1

	# A second call with the same input gives the same output.
	proof["idempotent_second_call"] = build_turret_state.source_build_turret_warmup_state(1.5).get("warmup") == build_turret_state.source_build_turret_warmup_state(1.5).get("warmup")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretWarmupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
