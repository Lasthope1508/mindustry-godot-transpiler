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

	# --- Turret drawrot() (N2532): `public float
	# drawrot(){` / `return rotation - 90;`
	# (Turret.java:359-362). It uses the `rotation` AIM
	# rotation field (`public float rotation = 90;`,
	# BaseTurret.java:114), NOT the Building quadrant
	# rotation (0-3). It overrides the BuildingComp base
	# (`return block.rotate && block.rotateDraw ? rotation
	# * 90 : 0f;`, BuildingComp.java:587-588), which uses
	# quadrants * 90; the Turret override ignores
	# block.rotate / block.rotateDraw. Java has NO
	# clamp/wrap guard in drawrot() (Turret.java:584 only
	# guards inside updateTile), so negative and >360
	# rotations pass through unchanged. The proof drives
	# the pure function on exact legs: 1 the BaseTurret
	# default rotation 90 -> 0; 2 rotation 0 -> -90; 3
	# rotation 180 -> 90; 4 rotation 270 -> 180; 5
	# rotation 45 -> -45; 6 rotation 360 -> 270 (no
	# wrap); 7 a negative rotation -90 -> -180 (no
	# clamp); 8 the result carries exactly the single
	# `drawrot` key and the value is a float.
	var result: Dictionary = turret_build_state.source_turret_drawrot_state(90.0)
	proof["drawrot_default"] = is_equal_approx(float(result.get("drawrot", 0.0)), 0.0)

	result = turret_build_state.source_turret_drawrot_state(0.0)
	proof["drawrot_zero"] = is_equal_approx(float(result.get("drawrot", 0.0)), -90.0)

	result = turret_build_state.source_turret_drawrot_state(180.0)
	proof["drawrot_half_turn"] = is_equal_approx(float(result.get("drawrot", 0.0)), 90.0)

	result = turret_build_state.source_turret_drawrot_state(270.0)
	proof["drawrot_three_quarter"] = is_equal_approx(float(result.get("drawrot", 0.0)), 180.0)

	result = turret_build_state.source_turret_drawrot_state(45.0)
	proof["drawrot_quarter"] = is_equal_approx(float(result.get("drawrot", 0.0)), -45.0)

	result = turret_build_state.source_turret_drawrot_state(360.0)
	proof["drawrot_full_turn"] = is_equal_approx(float(result.get("drawrot", 0.0)), 270.0)

	# Phase 7: a negative rotation passes through with
	# no clamp -- -90 -> -180.
	result = turret_build_state.source_turret_drawrot_state(-90.0)
	proof["drawrot_negative"] = is_equal_approx(float(result.get("drawrot", 0.0)), -180.0)

	# Phase 8: the result carries exactly the single
	# `drawrot` key, and the value is a float.
	result = turret_build_state.source_turret_drawrot_state(90.0)
	proof["drawrot_single_key"] = result.keys() == ["drawrot"] and result.get("drawrot") is float

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretDrawrotProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
