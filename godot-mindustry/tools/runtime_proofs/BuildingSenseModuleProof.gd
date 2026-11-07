extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game: PortGame = PortGameScript.new()
	var world_x: float = 32.0
	var world_y: float = 48.0
	var source_tilesize: float = 8.0
	var health: float = 70.0
	var max_health: float = 100.0
	var efficiency: float = 0.75
	var time_scale: float = 1.25
	var ranged_range: float = 64.0
	var has_range: bool = true
	var rotation_value: float = 90.0
	var total_items: float = 12.0
	var total_liquids: float = 4.0
	var total_power: float = 0.5
	var block_value: Dictionary = {"block": "router"}
	var first_item_value: Dictionary = {"item": "copper"}
	var config_value: Dictionary = {"config": "enabled"}
	var single_payload_content: Dictionary = {"unit": "dagger"}
	var position: Dictionary = game.source_building_sense_position_state(world_x, world_y, source_tilesize)
	var health_process: Dictionary = game.source_building_sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)
	var totals: Dictionary = game.source_building_sense_totals_state(total_items, total_liquids, total_power)
	var capacity_power_net: Dictionary = game.source_building_sense_capacity_power_net_state(true, 50.0, true, 80.0, true, 500.0, true, 1.5, 0.75, 120.0, 1000.0)
	var enabled_controlled: Dictionary = game.source_building_sense_enabled_controlled_state(true, true, true, 3.0)
	var payload_size: Dictionary = game.source_building_sense_payload_size_state(true, 2.0, true, 3.0)
	var object_state: Dictionary = game.source_building_sense_object_state("payloadType", block_value, true, first_item_value, true, config_value, "unit", single_payload_content)
	var content_state: Dictionary = game.source_building_sense_content_state("item", true, 6.0, false, 0.0, false, 0.0)
	var camera_default: Dictionary = game.source_building_sense_camera_default_state(true, 1.0, 2.0, 3.0, 4.0)
	var generated_position: Dictionary = game.generated_building_comp_sense_position_bridge_state(world_x, world_y, source_tilesize)
	var generated_health_process: Dictionary = game.generated_building_comp_sense_health_process_bridge_state(world_x, world_y, health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value)
	var generated_totals: Dictionary = game.generated_building_comp_sense_totals_bridge_state(world_x, world_y, total_items, total_liquids, total_power, source_tilesize)
	var generated_capacity_power_net: Dictionary = game.generated_building_comp_sense_capacity_power_net_bridge_state(world_x, world_y, true, 50.0, true, 80.0, true, 500.0, true, 1.5, 0.75, 120.0, 1000.0, source_tilesize)
	var generated_enabled_controlled: Dictionary = game.generated_building_comp_sense_enabled_controlled_bridge_state(world_x, world_y, true, true, true, 3.0, source_tilesize)
	var generated_payload_size: Dictionary = game.generated_building_comp_sense_payload_size_bridge_state(world_x, world_y, true, 2.0, true, 3.0, source_tilesize)
	var generated_object: Dictionary = game.generated_building_comp_sense_object_bridge_state("payloadType", block_value, true, first_item_value, true, config_value, "unit", single_payload_content)
	var generated_content: Dictionary = game.generated_building_comp_sense_content_bridge_state("item", true, 6.0, false, 0.0, false, 0.0)
	var generated_camera_default: Dictionary = game.generated_building_comp_sense_camera_default_bridge_state(world_x, world_y, true, 1.0, 2.0, 3.0, 4.0, source_tilesize)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var source_matches: Array[bool] = [
		position == source_building_sense_state.sense_position_state(world_x, world_y, source_tilesize),
		health_process == source_building_sense_state.sense_health_process_state(health, max_health, efficiency, time_scale, ranged_range, source_tilesize, has_range, rotation_value),
		totals == source_building_sense_state.sense_totals_state(total_items, total_liquids, total_power),
		capacity_power_net == source_building_sense_state.sense_capacity_power_net_state(true, 50.0, true, 80.0, true, 500.0, true, 1.5, 0.75, 120.0, 1000.0, source_time_defaults.TICK_RATE),
		enabled_controlled == source_building_sense_state.sense_enabled_controlled_state(true, true, true, 3.0),
		payload_size == source_building_sense_state.sense_payload_size_state(true, 2.0, true, 3.0),
		object_state == source_building_sense_state.sense_object_state("payloadType", block_value, true, first_item_value, true, config_value, "unit", single_payload_content),
		content_state == source_building_sense_state.sense_content_state("item", true, 6.0, false, 0.0, false, 0.0),
		camera_default == source_building_sense_state.sense_camera_default_state(true, 1.0, 2.0, 3.0, 4.0),
	]
	var generated_canonical_matches: Array[bool] = [
		generated_position.get("canonical") == position,
		generated_health_process.get("canonical") == health_process,
		generated_totals.get("canonical") == totals,
		generated_capacity_power_net.get("canonical") == capacity_power_net,
		generated_enabled_controlled.get("canonical") == enabled_controlled,
		generated_payload_size.get("canonical") == payload_size,
		generated_object.get("canonical") == object_state,
		generated_content.get("canonical") == content_state,
		generated_camera_default.get("canonical") == camera_default,
	]
	var proof: Dictionary = {
		"module": "BUILDING_SENSE_MODULE_PROOF",
		"source_matches": source_matches,
		"generated_canonical_matches": generated_canonical_matches,
		"position": position,
		"health_process": health_process,
		"totals": totals,
		"capacity_power_net": capacity_power_net,
		"enabled_controlled": enabled_controlled,
		"payload_size": payload_size,
		"object_state": object_state,
		"content_state": content_state,
		"camera_default": camera_default,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	var proof_matches: bool = not source_matches.has(false) and not generated_canonical_matches.has(false) and bool(proof["one_headquarter_per_ssot"]) and bool(proof["registry_valid"])
	proof["matches"] = proof_matches
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "BUILDING_SENSE_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	print("BUILDING_SENSE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingSenseModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

