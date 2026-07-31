extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_check_content_array_capacity_state := preload("res://src/game/SourceBlockCheckContentArrayCapacityState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var item_filter := [true, false, true]
	var liquid_filter := [false, true]
	var bridge := game.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, 5, 4)
	var proof := {
		"module": "BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_MODULE_PROOF",
		"bridge": bridge,
		"bridge_matches": bridge == source_block_check_content_array_capacity_state.generated_block_check_content_array_capacity_bridge_state(item_filter, liquid_filter, 5, 4),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(bridge.get("matches", false)) and proof["bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_CHECK_CONTENT_ARRAY_CAPACITY_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockCheckContentArrayCapacityModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
