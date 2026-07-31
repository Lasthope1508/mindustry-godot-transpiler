extends Node

const source_item_entry_state := preload("res://src/game/SourceItemEntryState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var constructor := source_item_entry_state.constructor_state("copper", 6)
	var type := source_item_entry_state.type_state("copper", {"id": "duo-copper"})
	var text := source_item_entry_state.to_string_state("copper", 6)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceItemEntryState",
		"constructor": constructor,
		"type": type,
		"to_string": text,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = constructor.get("item_after", null) == "copper" and type.get("type", null) != null and text.get("to_string", "") == "ItemEntry{item=copper, amount=6}" and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("ITEM_ENTRY_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/ItemEntryModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
