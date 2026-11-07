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
	var block_result := game.source_power_node_overlaps_state(true, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_EXPR)
	var tile_result := game.source_power_node_overlaps_state(false, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_EXPR)
	var building_result := game.source_power_node_overlaps_state(true, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BUILDING_EXPR)
	var tile_range_result := game.source_power_node_overlaps_state(true, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_TILE_RANGE_EXPR)
	var nullable_result := game.source_power_node_overlaps_nullable_state(false, false, false)
	var generated_block = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_overlaps_10", [true], null)
	var generated_tile = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_overlaps_11", [false], null)
	var generated_building = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_overlaps_12", [true], null)
	var generated_tile_range = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_overlaps_13", [true], null)
	var generated_nullable = source_generated_class_runtime.call_java_method(GENERATED_CLASS, "java_method_overlaps_14", [false, false, false], null)
	var proof: Dictionary = {
		"module": "POWER_NODE_OVERLAP_MODULE_PROOF",
		"source_matches": [
			block_result == source_power_node_state.overlaps_state(true, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_METHOD, source_power_node_state.SOURCE_POWER_NODE_OVERLAPS_BLOCK_EXPR),
			not bool(tile_result.get("overlaps", true)),
			bool(building_result.get("overlaps", false)),
			bool(tile_range_result.get("overlaps", false)),
			bool(nullable_result.get("overlaps", false)),
		],
		"generated_matches": [
			generated_block == block_result,
			generated_tile == tile_result,
			generated_building == building_result,
			generated_tile_range == tile_range_result,
			generated_nullable == nullable_result,
		],
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = not proof["source_matches"].has(false) and not proof["generated_matches"].has(false) and proof["registry_valid"] and proof["one_headquarter_per_ssot"]
	print("POWER_NODE_OVERLAP_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerNodeOverlapModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
