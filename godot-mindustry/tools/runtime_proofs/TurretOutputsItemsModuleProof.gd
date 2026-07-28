extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceTurretRuntimeState := preload("res://src/game/SourceTurretRuntimeState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var bridge := game.generated_turret_outputs_items_bridge_state()
	var module_bridge := SourceTurretRuntimeState.generated_outputs_items_bridge_state()
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "TURRET_OUTPUTS_ITEMS_MODULE_PROOF",
		"bridge": bridge,
		"module_bridge": module_bridge,
		"bridge_matches_module": bridge == module_bridge,
		"bridge_matches_canonical": bool(bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["bridge_matches_module"] and proof["bridge_matches_canonical"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_OUTPUTS_ITEMS_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/TurretOutputsItemsModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
