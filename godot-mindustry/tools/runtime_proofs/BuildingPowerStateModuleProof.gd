extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_power_state := preload("res://src/game/SourceBuildingPowerState.gd")
const generated_building_comp_script := preload("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var block: Dictionary = {"properties": {
		"hasPower": true,
		"outputsPower": true,
		"consumesPower": false,
		"powerBuffered": true,
		"powerUsage": 0.0,
		"powerCapacity": 10.0,
	}}
	var role_bridge: Dictionary = game.power_graph_role_for_block(block)
	var role_module: Dictionary = source_building_power_state.block_power_role_state(block)
	var removed_bridge: Dictionary = game.source_building_on_proximity_removed_state(true)
	var added_bridge: Dictionary = game.source_building_on_proximity_added_state(true)
	var update_bridge: Dictionary = game.source_building_update_power_graph_state([true, false, true])
	var removed_graph_bridge: Dictionary = game.source_building_power_graph_removed_state(true, [true, true, false], [true, false, true])
	var generated_building_comp := generated_building_comp_script.new()
	var generated_removed: Dictionary = generated_building_comp.java_method_onProximityRemoved_113([true])
	var generated_added: Dictionary = generated_building_comp.java_method_onProximityAdded_114([true])
	var generated_update: Dictionary = generated_building_comp.java_method_onProximityUpdate_115([])
	var generated_graph_update: Dictionary = generated_building_comp.java_method_updatePowerGraph_116([[true, false, true]])
	var generated_graph_removed: Dictionary = generated_building_comp.java_method_powerGraphRemoved_117([true, [true, true, false], [true, false, true]])
	var generated_conducts: Dictionary = generated_building_comp.java_method_conductsTo_118([true])
	var generated_connections: Dictionary = generated_building_comp.java_method_getPowerConnections_119([
		true, 4,
		[true, true, false], [true, true, true], [true, false, true],
		true, false, false,
		[true, true, false], [false, true, false], [false, false, true],
		[true, true, false], [true, false, true], [false, false, true],
		[true, true], [true, true], [true, false], [true, true],
	])
	var proximity_bridge: Dictionary = game.source_building_get_power_connections_proximity_guard_state([true, true, false], [true, false, true], [true, true, true])
	var compatibility_bridge: Dictionary = game.source_building_get_power_connections_power_compatibility_guard_state(true, false, false, [true, false, true], [false, true, false], [false, false, true])
	var conducts_bridge: Dictionary = game.source_building_get_power_connections_conducts_link_guard_state([true, true, false], [true, false, true], [false, false, true])
	var automatic_bridge: Dictionary = game.source_building_get_power_connections_automatic_add_state([0, 2], 1)
	var manual_bridge: Dictionary = game.source_building_get_power_connections_manual_links_loop_state([true, true, false], [true, true, true], [true, false, true], [true, true, true], 2)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof: Dictionary = {
		"module": "BUILDING_POWER_STATE_MODULE_PROOF",
		"role_bridge_matches": role_bridge == role_module,
		"removed_bridge_matches": removed_bridge == source_building_power_state.on_proximity_removed_state(true),
		"added_bridge_matches": added_bridge == source_building_power_state.on_proximity_added_state(true),
		"update_bridge_matches": update_bridge == source_building_power_state.update_power_graph_state([true, false, true]),
		"removed_graph_bridge_matches": removed_graph_bridge == source_building_power_state.power_graph_removed_state(true, [true, true, false], [true, false, true]),
		"generated_proximity_power_matches": generated_removed.get("power_graph_removed_called", false) and generated_added.get("update_power_graph_called", false) and generated_update.get("no_sleep_called", false) and generated_graph_update.get("add_graph_call_count", -1) == 2 and generated_graph_removed.get("linked_remove_count", -1) == 1 and generated_conducts.get("conducts_to", true) == false and generated_connections.get("returned_out", false) and generated_connections.get("phases", {}).get("proximity_guard", {}).get("proximity_guard_pass_count", -1) == 1 and generated_connections.get("phases", {}).get("compatibility_guard", {}).get("power_compatibility_pass_count", -1) == 2 and generated_connections.get("phases", {}).get("conducts_link_guard", {}).get("conducts_link_guard_pass_count", -1) == 1 and generated_connections.get("phases", {}).get("automatic_add", {}).get("added_count", -1) == 0 and generated_connections.get("phases", {}).get("manual_links", {}).get("manual_link_added_count", -1) == 1 and generated_removed.get("source_owner", "") == "port_game.source_building_on_proximity_removed_state" and generated_graph_removed.get("source_owner", "") == "port_game.source_building_power_graph_removed_state" and generated_conducts.get("source_owner", "") == "port_game.source_building_conducts_to_state" and generated_connections.get("source_owner", "") == "port_game.source_building_get_power_connections_state",
		"generated_removed": generated_removed,
		"generated_added": generated_added,
		"generated_update": generated_update,
		"generated_graph_update": generated_graph_update,
		"generated_graph_removed": generated_graph_removed,
		"proximity_bridge_matches": proximity_bridge == source_building_power_state.get_power_connections_proximity_guard_state([true, true, false], [true, false, true], [true, true, true]),
		"compatibility_bridge_matches": compatibility_bridge == source_building_power_state.get_power_connections_power_compatibility_guard_state(true, false, false, [true, false, true], [false, true, false], [false, false, true]),
		"conducts_bridge_matches": conducts_bridge == source_building_power_state.get_power_connections_conducts_link_guard_state([true, true, false], [true, false, true], [false, false, true]),
		"automatic_bridge_matches": automatic_bridge == source_building_power_state.get_power_connections_automatic_add_state([0, 2], 1),
		"manual_bridge_matches": manual_bridge == source_building_power_state.get_power_connections_manual_links_loop_state([true, true, false], [true, true, true], [true, false, true], [true, true, true], 2),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["role_bridge_matches"] and proof["removed_bridge_matches"] and proof["added_bridge_matches"] and proof["update_bridge_matches"] and proof["removed_graph_bridge_matches"] and proof["generated_proximity_power_matches"] and proof["proximity_bridge_matches"] and proof["compatibility_bridge_matches"] and proof["conducts_bridge_matches"] and proof["automatic_bridge_matches"] and proof["manual_bridge_matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("BUILDING_POWER_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingPowerStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

