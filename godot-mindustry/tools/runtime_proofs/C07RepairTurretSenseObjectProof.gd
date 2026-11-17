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

	# --- RepairTurret senseObject() (N2234):
	# BuildingComp.senseObject() (BuildingComp.java:2128-2136,
	# `public Object senseObject(LAccess sensor){`) switches
	# on the LAccess sensor: `case type -> block;`
	# (BuildingComp.java:2130), `case firstItem -> items ==
	# null ? null : items.first();` (BuildingComp.java:2131),
	# `case config -> block.configSenseable() ? config() :
	# null;` (BuildingComp.java:2132), `case payloadType ->
	# getPayload() instanceof UnitPayload p1 ? p1.unit.type :
	# getPayload() instanceof BuildPayload p2 ? p2.block() :
	# null;` (BuildingComp.java:2133), `default ->
	# noSensed;` (BuildingComp.java:2134). For a repair
	# turret the three middle legs are all null: firstItem
	# because `hasItems` is false by default (Block.java:45)
	# and RepairTurret never sets it, so BuildingComp.java:145
	# never creates the items module; config because
	# RepairTurret registers no `config()` call, so
	# `configurations` (Block.java:402) stays empty and
	# configSenseable() (Block.java:809-813) is false;
	# payloadType because the base `getPayload()` returns null
	# (BuildingComp.java:984-986) and RepairTurret does not
	# override it. The `type` leg returns the block itself,
	# whose port identity is its id string. An unhandled
	# sensor returns the `noSensed` sentinel
	# (Senseable.java:6), which the logic converts to a
	# numeric `sense()` fallback (LExecutor.java:697-698).
	# There is no driver tick line: senseObject is a logic
	# read, not a tick write (the N2223 sense precedent).

	# Type senses the block itself: repair-point id.
	var type_point: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("type", "repair-point")
	proof["sense_object_type_repair_point"] = bool(type_point.get("handled", false)) and String(type_point.get("sense_object", "")) == "repair-point" and not bool(type_point.get("is_no_sensed", true))

	# Type senses the block itself: repair-turret id.
	var type_turret: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("type", "repair-turret")
	proof["sense_object_type_repair_turret"] = bool(type_turret.get("handled", false)) and String(type_turret.get("sense_object", "")) == "repair-turret" and not bool(type_turret.get("is_no_sensed", true))

	# First item is null: no items module (hasItems false).
	var first_item: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("firstItem", "repair-point")
	proof["sense_object_first_item_null"] = bool(first_item.get("handled", false)) and first_item.get("sense_object", "non-null") == null and not bool(first_item.get("is_no_sensed", true))

	# Config is null: no configurations registered.
	var config: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("config", "repair-point")
	proof["sense_object_config_null"] = bool(config.get("handled", false)) and config.get("sense_object", "non-null") == null and not bool(config.get("is_no_sensed", true))

	# Payload type is null: base getPayload() returns null.
	var payload_type: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("payloadType", "repair-turret")
	proof["sense_object_payload_type_null"] = bool(payload_type.get("handled", false)) and payload_type.get("sense_object", "non-null") == null and not bool(payload_type.get("is_no_sensed", true))

	# An unhandled sensor returns the noSensed sentinel.
	var unknown: Dictionary = repair_turret_build_state.source_repair_turret_sense_object_state("totalItems", "repair-point")
	proof["sense_object_unknown_is_no_sensed"] = not bool(unknown.get("handled", true)) and unknown.get("sense_object", "non-null") == null and bool(unknown.get("is_no_sensed", false))

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTurretBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_turret_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_turret_sense_object_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretSenseObjectProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
