extends Node

const build_turret_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- BuildTurretBuild.canControl() (N2480):
	# BuildTurretBuild.canControl() (BuildTurret.java:103-105):
	#     return true;
	# on `public class BuildTurretBuild extends BaseTurretBuild
	# implements ControlBlock, RotBlock{` (BuildTurret.java:92).
	# The build tower is ALWAYS controllable -- ControlBlock
	# with no gate -- so the method returns the constant true
	# and reads NO state: no unit, no player, no logic, no
	# block field. TRAP: this is NOT TurretBuild.canControl()
	# (Turret.java:376-378, N2297, `return playerControllable;`
	# -- the block-level field `public boolean
	# playerControllable = true;`, Turret.java:97, which a def
	# can set false): a block with playerControllable = false
	# still returns true here and false in N2297. TRAP: this
	# is NOT TurretBuild.controlled() (Turret.java:441-443,
	# N2324/N2523, `return unit.isPlayer();`) -- canControl is
	# about the block being controllable, controlled is about
	# who holds it now. The proof calls the pure function
	# with no inputs (no live tick, no game state) and pins
	# the cross-trap by driving the parent method
	# (N2297, source_turret_can_control_state) with the same
	# playerControllable value in both directions.

	# The method returns the constant true, with no inputs.
	proof["can_control_is_true"] = build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	# KEY TRAP: a block with playerControllable = false still
	# returns true here -- the method never reads the field.
	# (The local models the N2297 input; the zero-arg call
	# cannot consult it.)
	var player_controllable_false := false
	proof["player_controllable_false_still_true"] = player_controllable_false == false and build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	# With playerControllable = true the result is true too
	# -- the value of the field never matters here.
	var player_controllable_true := true
	proof["player_controllable_true_still_true"] = player_controllable_true == true and build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	# CROSS-TRAP, parent differs: TurretBuild.canControl()
	# (N2297) returns the field, so with playerControllable =
	# false it returns false while this slice returns true.
	proof["parent_can_control_differs_when_false"] = turret_state.source_turret_can_control_state({}, false).get("can_control") == false and build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	# With playerControllable = true the parent agrees: both
	# return true, so the trap only shows in the false case.
	proof["parent_can_control_matches_when_true"] = turret_state.source_turret_can_control_state({}, true).get("can_control") == true and build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	# The result has exactly one key.
	proof["returns_only_one_key"] = build_turret_state.source_build_turret_can_control_state().size() == 1

	# A second call with no input gives the same output.
	proof["idempotent_second_call"] = build_turret_state.source_build_turret_can_control_state().get("can_control") == build_turret_state.source_build_turret_can_control_state().get("can_control")

	# Repeated calls stay constant -- the constant never drifts.
	proof["constant_across_repeated_calls"] = build_turret_state.source_build_turret_can_control_state().get("can_control") == true and build_turret_state.source_build_turret_can_control_state().get("can_control") == true and build_turret_state.source_build_turret_can_control_state().get("can_control") == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretCanControlProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
