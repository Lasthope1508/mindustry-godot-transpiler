extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockMetadataState := preload("res://src/game/SourceBlockMetadataState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var content_type_bridge := game.generated_block_get_content_type_bridge_state()
	var logic_visible_bridge := game.generated_block_logic_visible_bridge_state("shown")
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_METADATA_MODULE_PROOF",
		"content_type_bridge": content_type_bridge,
		"logic_visible_bridge": logic_visible_bridge,
		"content_type_bridge_matches": content_type_bridge == SourceBlockMetadataState.generated_content_type_bridge_state(),
		"logic_visible_bridge_matches": logic_visible_bridge == SourceBlockMetadataState.generated_logic_visible_bridge_state("shown"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(content_type_bridge.get("matches", false)) and bool(logic_visible_bridge.get("matches", false)) and proof["content_type_bridge_matches"] and proof["logic_visible_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_METADATA_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BlockMetadataModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
