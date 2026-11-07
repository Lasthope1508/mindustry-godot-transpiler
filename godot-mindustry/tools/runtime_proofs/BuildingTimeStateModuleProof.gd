extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_time_state := preload("res://src/game/SourceBuildingTimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var apply_boost_bridge := game.generated_building_comp_apply_boost_bridge_state(1.0, 0.0, 1.25, 60.0, true)
	var apply_slowdown_bridge := game.generated_building_comp_apply_slowdown_bridge_state(1.25, 60.0, 0.75, 30.0)
	var write_base_bridge := game.generated_building_comp_write_base_timescale_bridge_state(1.0, 0.0)
	var read_base_bridge := game.generated_building_comp_read_base_timescale_bridge_state(4, 1.0, 0.5)
	var module_bitmask_bridge := game.generated_building_comp_module_bitmask_bridge_state(true, true, false, 1.0, true)
	var update_timescale_bridge := game.generated_building_comp_update_timescale_decay_bridge_state(1.0, 0.0, 1.0)
	var update_ambient_bridge := game.generated_building_comp_update_ambient_sound_gate_bridge_state(false, "sound", null, true, 2.0, 3.0)
	var time_scale_bridge := game.generated_building_comp_time_scale_bridge_state(1.25)
	var warmup_bridge := game.generated_building_comp_warmup_bridge_state()
	var total_progress_bridge := game.generated_building_comp_total_progress_bridge_state(42.5)
	var progress_bridge := game.generated_building_comp_progress_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_TIME_STATE_MODULE_PROOF",
		"apply_boost_bridge": apply_boost_bridge,
		"apply_slowdown_bridge": apply_slowdown_bridge,
		"write_base_bridge": write_base_bridge,
		"read_base_bridge": read_base_bridge,
		"module_bitmask_bridge": module_bitmask_bridge,
		"update_timescale_bridge": update_timescale_bridge,
		"update_ambient_bridge": update_ambient_bridge,
		"time_scale_bridge": time_scale_bridge,
		"warmup_bridge": warmup_bridge,
		"total_progress_bridge": total_progress_bridge,
		"progress_bridge": progress_bridge,
		"write_base_bridge_matches": write_base_bridge == source_building_time_state.generated_write_base_timescale_bridge_state(1.0, 0.0),
		"read_base_bridge_matches": read_base_bridge == source_building_time_state.generated_read_base_timescale_bridge_state(4, 1.0, 0.5),
		"module_bitmask_bridge_matches": module_bitmask_bridge == source_building_time_state.generated_module_bitmask_bridge_state(true, true, false, 1.0, true),
		"update_timescale_bridge_matches": update_timescale_bridge == source_building_time_state.generated_update_timescale_decay_bridge_state(1.0, 0.0, 1.0),
		"update_ambient_bridge_matches": update_ambient_bridge == source_building_time_state.generated_update_ambient_sound_gate_bridge_state(false, "sound", null, true, 2.0, 3.0),
		"time_scale_bridge_matches": time_scale_bridge == source_building_time_state.generated_time_scale_bridge_state(1.25) and bool(time_scale_bridge.get("matches", false)),
		"warmup_bridge_matches": warmup_bridge == source_building_time_state.generated_warmup_bridge_state() and bool(warmup_bridge.get("matches", false)),
		"total_progress_bridge_matches": total_progress_bridge == source_building_time_state.generated_total_progress_bridge_state(42.5) and bool(total_progress_bridge.get("matches", false)),
		"progress_bridge_matches": progress_bridge == source_building_time_state.generated_progress_bridge_state() and bool(progress_bridge.get("matches", false)),
		"apply_boost_matches": bool(apply_boost_bridge.get("matches", false)) and apply_boost_bridge.get("canonical", {}) == source_building_time_state.apply_boost_state(1.0, 0.0, 1.25, 60.0, true, 0.001),
		"apply_slowdown_matches": bool(apply_slowdown_bridge.get("matches", false)) and apply_slowdown_bridge.get("canonical", {}) == source_building_time_state.apply_slowdown_state(1.25, 60.0, 0.75, 30.0, 0.001),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["apply_boost_matches"] and proof["apply_slowdown_matches"] and proof["write_base_bridge_matches"] and proof["read_base_bridge_matches"] and proof["module_bitmask_bridge_matches"] and proof["update_timescale_bridge_matches"] and proof["update_ambient_bridge_matches"] and proof["time_scale_bridge_matches"] and proof["warmup_bridge_matches"] and proof["total_progress_bridge_matches"] and proof["progress_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_TIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingTimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
