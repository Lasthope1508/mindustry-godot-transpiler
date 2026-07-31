extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_init_health_state := preload("res://src/game/SourceBlockInitHealthState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var health_scaled_bridge := game.generated_block_init_health_scaled_bridge_state(-1, 3, 2.0)
	var health_requirements_bridge := game.generated_block_init_health_requirements_scaling_bridge_state(-1, 3, -1.0, [0.25, 0.75])
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_INIT_HEALTH_MODULE_PROOF",
		"health_scaled_bridge": health_scaled_bridge,
		"health_requirements_bridge": health_requirements_bridge,
		"health_scaled_bridge_matches": health_scaled_bridge == source_block_init_health_state.generated_health_scaled_bridge_state(-1, 3, 2.0),
		"health_requirements_bridge_matches": health_requirements_bridge == source_block_init_health_state.generated_health_requirements_scaling_bridge_state(-1, 3, -1.0, [0.25, 0.75]),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(health_scaled_bridge.get("matches", false)) and bool(health_requirements_bridge.get("matches", false)) and proof["health_scaled_bridge_matches"] and proof["health_requirements_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_INIT_HEALTH_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockInitHealthModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
		proof_file.flush()
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
