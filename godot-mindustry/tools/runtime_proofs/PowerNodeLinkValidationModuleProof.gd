extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_power_node_state := preload("res://src/game/SourcePowerNodeState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

const GENERATED_CLASS := "res://src/generated/classes/mindustry/world/blocks/power/PowerNode.gd"

func _ready() -> void:
	var game = PortGameScript.new()
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var valid_link := {
		"tile_is_link": false,
		"link_present": true,
		"link_has_power": true,
		"link_connected_power": true,
		"same_team": true,
		"same_block_connection": false,
		"same_block_type": true,
		"source_overlaps": true,
		"link_is_power_node": true,
		"reverse_overlaps": false,
		"link_links_size": 1,
		"link_max_nodes": 3,
		"link_contains_tile": false,
	}
	var link_state: Dictionary = game.source_power_node_link_valid_state(valid_link, true)
	var guard_rejected := valid_link.duplicate(true)
	guard_rejected["same_team"] = false
	var max_nodes_rejected := valid_link.duplicate(true)
	max_nodes_rejected["link_links_size"] = 3
	max_nodes_rejected["link_max_nodes"] = 3
	var existing_link := max_nodes_rejected.duplicate(true)
	existing_link["link_contains_tile"] = true
	var guard_state: Dictionary = game.source_power_node_link_valid_state(guard_rejected, true)
	var max_state: Dictionary = game.source_power_node_link_valid_state(max_nodes_rejected, true)
	var existing_state: Dictionary = game.source_power_node_link_valid_state(existing_link, true)
	var unchecked_state: Dictionary = game.source_power_node_link_valid_state(max_nodes_rejected, false)
	var insulated_state: Dictionary = game.source_power_node_insulated_state(true)
	var clear_state: Dictionary = game.source_power_node_insulated_state(false)
	var generated_link = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_linkValid_20", [valid_link, true], null)
	var generated_guard = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_linkValid_20", [guard_rejected, true], null)
	var generated_max = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_linkValid_20", [max_nodes_rejected, true], null)
	var generated_existing = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_linkValid_20", [existing_link, true], null)
	var generated_unchecked = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_linkValid_20", [max_nodes_rejected, false], null)
	var generated_insulated = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_insulated_23", [true], null)
	var generated_clear = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_insulated_23", [false], null)
	var proof: Dictionary = {
		"module": "POWER_NODE_LINK_VALIDATION_MODULE_PROOF",
		"source_matches": [
			link_state == source_power_node_state.link_valid_state(valid_link, true),
			guard_state == source_power_node_state.link_valid_state(guard_rejected, true),
			max_state == source_power_node_state.link_valid_state(max_nodes_rejected, true),
			existing_state == source_power_node_state.link_valid_state(existing_link, true),
			unchecked_state == source_power_node_state.link_valid_state(max_nodes_rejected, false),
			insulated_state == source_power_node_state.insulated_state(true),
			clear_state == source_power_node_state.insulated_state(false),
			bool(link_state.get("link_valid", false)),
			not bool(guard_state.get("link_valid", true)),
			not bool(max_state.get("link_valid", true)),
			bool(existing_state.get("link_valid", false)),
			bool(unchecked_state.get("link_valid", false)),
			bool(insulated_state.get("insulated", false)),
			not bool(clear_state.get("insulated", true)),
		],
		"generated_matches": [
			generated_link == link_state,
			generated_guard == guard_state,
			generated_max == max_state,
			generated_existing == existing_state,
			generated_unchecked == unchecked_state,
			generated_insulated == insulated_state,
			generated_clear == clear_state,
		],
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = not proof["source_matches"].has(false) and not proof["generated_matches"].has(false) and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_NODE_LINK_VALIDATION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerNodeLinkValidationModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
