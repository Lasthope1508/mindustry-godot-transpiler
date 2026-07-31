extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_set_bars_call_state := preload("res://src/game/SourceBlockInitSetBarsCallState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var bridge := game.generated_block_init_set_bars_call_bridge_state()
	var proof := {
		"module": "BLOCK_INIT_SET_BARS_CALL_MODULE_PROOF",
		"bridge": bridge,
		"bridge_matches": bridge == source_block_init_set_bars_call_state.generated_block_init_set_bars_call_bridge_state(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(bridge.get("matches", false)) and proof["bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_SET_BARS_CALL_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitSetBarsCallModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
