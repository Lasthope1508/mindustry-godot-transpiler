extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret per-def ambientSoundVolume (N2235):
	# Blocks.java overrides the RepairTurret class default
	# `ambientSoundVolume = 1f;` (RepairTurret.java:67) per
	# def: repair-point 0.9f (Blocks.java:6393,
	# `ambientSoundVolume = 0.9f;`) and repair-turret 1.25f
	# (Blocks.java:6408, `ambientSoundVolume = 1.25f;`).
	# The loop multiplies that volume by ambientVolume()
	# (BuildingComp.java:2271, `control.sound.loop(block.
	# ambientSound, self(), block.ambientSoundVolume *
	# ambientVolume());`, gated by BuildingComp.java:2270),
	# where ambientVolume() is the folded efficiency
	# (BuildingComp.java:2015-2017). An unknown def falls
	# back to the 1.0 class default. The loop keeps its
	# two-arg signature and resolves the volume from the
	# frame's block_id; a frame with no block_id keeps the
	# old 1.0 behavior. There is no driver tick line: the
	# volume is a catalog read (the N2223 sense precedent).

	# Repair-point volume is 0.9.
	var volume_point: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_volume_state("repair-point")
	proof["volume_repair_point_0_9"] = absf(float(volume_point.get("ambient_sound_volume", -1.0)) - 0.9) < 0.001

	# Repair-turret volume is 1.25.
	var volume_turret: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_volume_state("repair-turret")
	proof["volume_repair_turret_1_25"] = absf(float(volume_turret.get("ambient_sound_volume", -1.0)) - 1.25) < 0.001

	# An unknown def falls back to the 1.0 class default.
	var volume_unknown: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_volume_state("repair-tower")
	proof["volume_unknown_fallback_1_0"] = absf(float(volume_unknown.get("ambient_sound_volume", -1.0)) - 1.0) < 0.001

	# Loop volume for repair-point at full efficiency is 0.9.
	var loop_point: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 1.0, "block_id": "repair-point"}, false)
	proof["loop_volume_repair_point"] = bool(loop_point.get("should_loop", false)) and absf(float(loop_point.get("volume", -1.0)) - 0.9) < 0.001

	# Loop volume for repair-turret at half efficiency is 0.625.
	var loop_turret: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 0.5, "block_id": "repair-turret"}, false)
	proof["loop_volume_repair_turret"] = bool(loop_turret.get("should_loop", false)) and absf(float(loop_turret.get("volume", -1.0)) - 0.625) < 0.001

	# A frame with no block_id keeps the 1.0 class default
	# (backward-compat with the N2222 loop).
	var loop_fallback: Dictionary = repair_turret_build_state.source_repair_turret_ambient_sound_loop_state({"has_target": true, "efficiency": 0.5}, false)
	proof["loop_volume_no_block_id_fallback"] = bool(loop_fallback.get("should_loop", false)) and absf(float(loop_fallback.get("volume", -1.0)) - 0.5) < 0.001

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTurretBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_turret_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_turret_ambient_sound_volume_state") and not driver_body.contains("source_repair_turret_ambient_sound_loop_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretAmbientSoundVolumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
