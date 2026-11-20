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

	# --- Turret logic-processor sense dispatch hook (N2507):
	# SenseI.run() (LExecutor.java:681-718,
	# `public static class SenseI implements LInstruction{`,
	# :668) dispatches the logic `sense` op: null target +
	# `dead` writes num 1 first
	# (`if(target == null && sense == LAccess.dead){` /
	# `to.setnum(1);`, LExecutor.java:685-687); otherwise
	# senseObject() is tried and its object is written when
	# handled (`Object objOut = se.senseObject(la);` /
	# `to.setobj(objOut);`, LExecutor.java:695, :701-703),
	# including a null object for `config` / `payloadType`
	# (N2506: duo is not configSenseable, base getPayload()
	# returns null -- null is NOT the sentinel, so it never
	# falls back to numeric sense); on the `noSensed`
	# sentinel (`Object noSensed = new Object();`,
	# Senseable.java:6) the numeric sense(la) value is
	# written instead (`if(objOut == Senseable.noSensed){` /
	# `to.setnum(se.sense(la));`, LExecutor.java:697-699).
	# The dispatch composes the N2506 senseObject outputs
	# with the N2283/N2284 numeric sense chain (passed in
	# as the synthetic `sense_value` here, the
	# N2212/N2220 per-def-param precedent). There is no
	# driver tick line: the dispatch is a logic read, not a
	# tick write (the N2206/N2208/N2223/N2283/N2284/N2506
	# precedent).

	# Null target + dead writes num 1, checked first: the
	# senseObject outcome would have handled "type", but the
	# dead leg wins.
	var null_dead: Dictionary = turret_build_state.source_logic_sense_dispatch_state("dead", true, true, "duo", 0.0)
	proof["dispatch_null_target_dead_num_one"] = bool(null_dead.get("handled", false)) and String(null_dead.get("output_kind", "")) == "num" and float(null_dead.get("output_value", 0.0)) == 1.0 and not bool(null_dead.get("is_no_sensed", true))

	# Type senses the block itself: duo id as an object.
	var type_so: Dictionary = turret_build_state.source_turret_sense_object_state("type", "duo", "copper")
	var type_dispatch: Dictionary = turret_build_state.source_logic_sense_dispatch_state("type", false, bool(type_so.get("handled", false)), type_so.get("sense_object"), 0.0)
	proof["dispatch_type_duo_obj"] = bool(type_dispatch.get("handled", false)) and String(type_dispatch.get("output_kind", "")) == "obj" and String(type_dispatch.get("output_value", "")) == "duo" and not bool(type_dispatch.get("is_no_sensed", true))

	# First item is copper: the observed first item as an object.
	var first_item_so: Dictionary = turret_build_state.source_turret_sense_object_state("firstItem", "duo", "copper")
	var first_item_dispatch: Dictionary = turret_build_state.source_logic_sense_dispatch_state("firstItem", false, bool(first_item_so.get("handled", false)), first_item_so.get("sense_object"), 0.0)
	proof["dispatch_first_item_copper_obj"] = bool(first_item_dispatch.get("handled", false)) and String(first_item_dispatch.get("output_kind", "")) == "obj" and String(first_item_dispatch.get("output_value", "")) == "copper" and not bool(first_item_dispatch.get("is_no_sensed", true))

	# Config is null: duo is not configSenseable -- the null
	# object is written, never a numeric fallback.
	var config_so: Dictionary = turret_build_state.source_turret_sense_object_state("config", "duo", "copper")
	var config_dispatch: Dictionary = turret_build_state.source_logic_sense_dispatch_state("config", false, bool(config_so.get("handled", false)), config_so.get("sense_object"), 0.0)
	proof["dispatch_config_null_obj"] = bool(config_dispatch.get("handled", false)) and String(config_dispatch.get("output_kind", "")) == "obj" and config_dispatch.get("output_value", "non-null") == null and not bool(config_dispatch.get("is_no_sensed", true))

	# Payload type is null: base getPayload() returns null --
	# the null object is written, never a numeric fallback.
	var payload_so: Dictionary = turret_build_state.source_turret_sense_object_state("payloadType", "duo", "copper")
	var payload_dispatch: Dictionary = turret_build_state.source_logic_sense_dispatch_state("payloadType", false, bool(payload_so.get("handled", false)), payload_so.get("sense_object"), 0.0)
	proof["dispatch_payload_type_null_obj"] = bool(payload_dispatch.get("handled", false)) and String(payload_dispatch.get("output_kind", "")) == "obj" and payload_dispatch.get("output_value", "non-null") == null and not bool(payload_dispatch.get("is_no_sensed", true))

	# An unhandled sensor falls back to the numeric sense
	# value: "totalItems" is noSensed for senseObject, so the
	# dispatch writes num with the passed-in sense value (5.0
	# synthetic, standing in for the N2283/N2284 sense(la)).
	var unknown_so: Dictionary = turret_build_state.source_turret_sense_object_state("totalItems", "duo", "copper")
	var unknown_dispatch: Dictionary = turret_build_state.source_logic_sense_dispatch_state("totalItems", false, bool(unknown_so.get("handled", true)), unknown_so.get("sense_object"), 5.0)
	proof["dispatch_unknown_falls_back_to_sense"] = bool(unknown_dispatch.get("handled", false)) and String(unknown_dispatch.get("output_kind", "")) == "num" and float(unknown_dispatch.get("output_value", 0.0)) == 5.0 and bool(unknown_dispatch.get("is_no_sensed", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretLogicSenseDispatchProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
