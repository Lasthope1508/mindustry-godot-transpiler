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

	# --- Turret logic-processor sense non-Senseable size/bufferSize legs (N2509):
	# SenseI.run() (LExecutor.java:681-718,
	# `public static class SenseI implements LInstruction{`,
	# :668) takes the else-branch when the target is NOT a
	# Senseable (`if(target instanceof Senseable se){`,
	# :691): a size / bufferSize sensor
	# (`if(sense == LAccess.size || sense == LAccess.bufferSize){`,
	# :706) on a CharSequence target writes seq.length() with
	# to.setnum and returns early (`if(target instanceof
	# CharSequence seq){` / `to.setnum(seq.length());` /
	# `return;`, :707-709), on a Seq<?> target writes seq.size
	# with to.setnum and returns early (`}else if(target
	# instanceof Seq<?> seq){` / `to.setnum(seq.size);` /
	# `return;`, :710-712), and any other sensor or target falls
	# through to to.setobj(null) (`to.setobj(null);`, :716).
	# The sensor spellings are the LAccess enum names: `size,`
	# (LAccess.java:45) and `bufferSize,` (:43). The length /
	# size are passed in as params (the N2212/N2220
	# per-def-param precedent); the pure function does not read
	# the frame. There is no driver tick line: the legs are
	# logic reads, not tick writes (the
	# N2206/N2208/N2223/N2283/N2284/N2506/N2507/N2508 precedent).

	# size on a 5-char string: "hello" reads 5.0 as num.
	var size_string_result: Dictionary = turret_build_state.source_logic_sense_size_state("size", "string", 5.0, 0.0)
	proof["size_string_num"] = bool(size_string_result.get("handled", false)) and String(size_string_result.get("output_kind", "")) == "num" and float(size_string_result.get("output_value", 0.0)) == 5.0 and not bool(size_string_result.get("is_null", true))

	# bufferSize on a 3-element sequence reads 3.0 as num.
	var buffer_seq_result: Dictionary = turret_build_state.source_logic_sense_size_state("bufferSize", "seq", 0.0, 3.0)
	proof["buffer_size_seq_num"] = bool(buffer_seq_result.get("handled", false)) and String(buffer_seq_result.get("output_kind", "")) == "num" and float(buffer_seq_result.get("output_value", 0.0)) == 3.0 and not bool(buffer_seq_result.get("is_null", true))

	# size on a 7-element sequence reads 7.0 as num: the size
	# guard covers both sensors on both target kinds.
	var size_seq_result: Dictionary = turret_build_state.source_logic_sense_size_state("size", "seq", 0.0, 7.0)
	proof["size_seq_num"] = bool(size_seq_result.get("handled", false)) and String(size_seq_result.get("output_kind", "")) == "num" and float(size_seq_result.get("output_value", 0.0)) == 7.0 and not bool(size_seq_result.get("is_null", true))

	# bufferSize on an 11-char string reads 11.0 as num.
	var buffer_string_result: Dictionary = turret_build_state.source_logic_sense_size_state("bufferSize", "string", 11.0, 0.0)
	proof["buffer_size_string_num"] = bool(buffer_string_result.get("handled", false)) and String(buffer_string_result.get("output_kind", "")) == "num" and float(buffer_string_result.get("output_value", 0.0)) == 11.0 and not bool(buffer_string_result.get("is_null", true))

	# size on a number target is neither CharSequence nor Seq:
	# both instanceof arms miss and the branch falls through
	# to to.setobj(null).
	var other_target_result: Dictionary = turret_build_state.source_logic_sense_size_state("size", "number", 5.0, 3.0)
	proof["size_other_target_null"] = bool(other_target_result.get("handled", false)) and String(other_target_result.get("output_kind", "")) == "obj" and other_target_result.get("output_value", 0.0) == null and bool(other_target_result.get("is_null", false))

	# A non-size sensor skips the whole size block even for a
	# string target: health on "hello" falls through to
	# to.setobj(null).
	var other_sensor_result: Dictionary = turret_build_state.source_logic_sense_size_state("health", "string", 5.0, 0.0)
	proof["other_sensor_string_null"] = bool(other_sensor_result.get("handled", false)) and String(other_sensor_result.get("output_kind", "")) == "obj" and other_sensor_result.get("output_value", 0.0) == null and bool(other_sensor_result.get("is_null", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicSenseSizeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
