extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var bridge := game.generated_turret_outputs_items_bridge_state()
	var module_bridge := source_turret_runtime_state.generated_outputs_items_bridge_state()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_OUTPUTS_ITEMS_MODULE_PROOF",
		"bridge": bridge,
		"module_bridge": module_bridge,
		"bridge_matches_module": bridge == module_bridge,
		"bridge_matches_canonical": bool(bridge.get("matches", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["bridge_matches_module"] and proof["bridge_matches_canonical"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_OUTPUTS_ITEMS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretOutputsItemsModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
