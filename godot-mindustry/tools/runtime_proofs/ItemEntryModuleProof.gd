extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_item_entry_state := preload("res://src/game/SourceItemEntryState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var constructor := source_item_entry_state.constructor_state("copper", 6)
	var type := source_item_entry_state.type_state("copper", {"id": "duo-copper"})
	var text := source_item_entry_state.to_string_state("copper", 6)
	var game_constructor := game.source_item_entry_constructor_state("copper", 6)
	var game_type := game.source_item_entry_type_state("copper", {"id": "duo-copper"})
	var game_text := game.source_item_entry_to_string_state("copper", 6)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceItemEntryState",
		"constructor": constructor,
		"type": type,
		"to_string": text,
		"game_constructor": game_constructor,
		"game_type": game_type,
		"game_to_string": game_text,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = constructor.get("item_after", null) == "copper" and type.get("type", null) != null and text.get("to_string", "") == "ItemEntry{item=copper, amount=6}" and game_constructor == constructor and game_type == type and game_text == text and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("ITEM_ENTRY_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ItemEntryModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

