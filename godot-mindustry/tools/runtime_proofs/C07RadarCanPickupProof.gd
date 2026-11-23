extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Pure canPickup() accessor (N2318): RadarBuild.canPickup()
	# (Radar.java:75, `public boolean canPickup(){` with `return
	# false;`, Radar.java:76) overrides the base
	# BuildingComp.canPickup() (BuildingComp.java:1838, `public
	# boolean canPickup(){` with `return block.canPickup;`,
	# BuildingComp.java:1839) for Radar: a radar can never be
	# picked up, whatever the frame holds. The override takes
	# no state, so the proof calls the pure function
	# source_radar_can_pickup_state(frame) directly with
	# synthetic frames. There are no driver-tick keys: pickup
	# is a placement-time gate, not tick state.

	# Empty frame reads false -- the override is unconditional.
	var empty: Dictionary = radar_build_state.source_radar_can_pickup_state({})
	proof["can_pickup_empty_frame_false"] = bool(empty.get("can_pickup", true)) == false

	# A frame mid-discovery still reads false: progress does
	# not change pickup.
	var progress_frame: Dictionary = radar_build_state.source_radar_can_pickup_state({"progress": 1.0})
	proof["can_pickup_progress_frame_false"] = bool(progress_frame.get("can_pickup", true)) == false

	# An enabled, fully efficient frame still reads false:
	# enabled and efficiency do not change pickup.
	var enabled_frame: Dictionary = radar_build_state.source_radar_can_pickup_state({"enabled": true, "efficiency": 1.0})
	proof["can_pickup_enabled_frame_false"] = bool(enabled_frame.get("can_pickup", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarCanPickupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
