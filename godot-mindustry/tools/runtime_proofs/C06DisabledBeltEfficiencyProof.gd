extends Node

const main_scene := preload("res://scenes/Main.tscn")
const conveyor_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")


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

	# --- A disabled belt reads efficiency 0 in Java: a conveyor
	# carries no consumers, so updateConsumption
	# (BuildingComp.java:1943-1948) sets efficiency to 1 when enabled
	# and to 0 when disabled, and the belt moves by `float moved =
	# speed * edelta();` (Conveyor.java:266) with edelta() =
	# efficiency * delta() (BuildingComp.java:1927-1929). The advance
	# step takes the belt's own efficiency (trailing param, default
	# 1.0), so efficiency 0 moves 0: the belt is frozen. ---
	var disabled: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0, 0.0)
	proof["disabled_belt_ys_frozen"] = disabled.get("ys_after") == [0.0, 0.5]
	proof["disabled_belt_xs_frozen"] = disabled.get("xs_after") == [0.2, -0.3]

	# --- A disabled belt never reaches the exit: with moved 0 the
	# front item stays at 0.98, so pass_ready is false. (An item
	# ALREADY at ys >= 1.0 would still report pass_ready true -- the
	# pass check reads the stored position, not moved -- but that
	# state cannot arise for a disabled belt in Java because
	# updateTile is never called for it, Conveyor.java:52
	# noUpdateDisabled = false; the live-loop enabled gate is the
	# deferred follow-up.) ---
	var disabled_ready: Dictionary = conveyor_state.source_conveyor_advance_state(["lead"], [0.0], [0.98], 1, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0, 0.0)
	proof["disabled_belt_no_pass_ready"] = disabled_ready.get("ys_after") == [0.98] and disabled_ready.get("pass_ready") == false

	# --- An enabled belt (efficiency 1.0, explicit) advances by
	# speed * delta * time_scale, same numbers as ConveyorAdvanceProof. ---
	var enabled: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0, 1.0)
	proof["enabled_belt_advances"] = enabled.get("ys_after") == [0.03, 0.53] and enabled.get("pass_ready") == false

	# --- Half efficiency moves items half as far. ---
	var half: Dictionary = conveyor_state.source_conveyor_advance_state(["lead", "copper"], [0.2, -0.3], [0.0, 0.5], 2, 0.03, 1.0, 1.0, false, 1.0, 0, 0.0, 0.5)
	proof["half_efficiency_half_moved"] = is_equal_approx(float(half.get("ys_after")[0]), 0.015) and is_equal_approx(float(half.get("ys_after")[1]), 0.515) and is_equal_approx(float(half.get("xs_after")[0]), 0.17) and is_equal_approx(float(half.get("xs_after")[1]), -0.27)

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06DisabledBeltEfficiencyProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
