extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingTetherState := preload("res://src/game/SourceBuildingTetherState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var update_bridge := game.generated_building_tether_comp_update_bridge_state(true, false, "blue", "blue", 42)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_TETHER_STATE_MODULE_PROOF",
		"update_bridge": update_bridge,
		"update_bridge_matches": update_bridge == SourceBuildingTetherState.generated_building_tether_update_bridge_state(true, false, "blue", "blue", 42),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["update_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_TETHER_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingTetherStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
