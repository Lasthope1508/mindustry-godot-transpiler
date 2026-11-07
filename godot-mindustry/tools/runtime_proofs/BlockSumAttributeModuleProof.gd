extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_attribute_state := preload("res://src/game/SourceBlockAttributeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var deep_flags := [false, true, false]
	var values := [1.25, 8.0, 2.75]
	var wrapper := game.generated_block_sum_attribute_bridge_state(true, true, false, false, deep_flags, values)
	var module := source_block_attribute_state.generated_block_sum_attribute_bridge_state(true, true, false, false, deep_flags, values)
	var null_attr := game.generated_block_sum_attribute_bridge_state(false, true, false, false, deep_flags, values)
	var null_tile := game.generated_block_sum_attribute_bridge_state(true, false, false, false, deep_flags, values)
	var floating := game.generated_block_sum_attribute_bridge_state(true, true, true, false, deep_flags, values)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_SUM_ATTRIBUTE_MODULE_PROOF",
		"wrapper_matches_module": wrapper == module,
		"generated_matches": bool(wrapper.get("matches", false)),
		"deep_floor_is_excluded": is_equal_approx(float(wrapper.get("result", {}).get("sum", -1.0)), 4.0),
		"null_attr_is_zero": is_equal_approx(float(null_attr.get("result", {}).get("sum", -1.0)), 0.0),
		"null_tile_is_zero": is_equal_approx(float(null_tile.get("result", {}).get("sum", -1.0)), 0.0),
		"floating_includes_deep": is_equal_approx(float(floating.get("result", {}).get("sum", -1.0)), 12.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches_module"] and proof["generated_matches"] and proof["deep_floor_is_excluded"] and proof["null_attr_is_zero"] and proof["null_tile_is_zero"] and proof["floating_includes_deep"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockSumAttributeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
