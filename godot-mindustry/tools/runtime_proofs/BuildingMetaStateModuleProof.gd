extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingMetaState := preload("res://src/game/SourceBuildingMetaState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var cursor_state := SourceBuildingMetaState.cursor_state(true, true)
	var health_changed_state := SourceBuildingMetaState.health_changed_state(true, {"health": 10})
	var to_string_state := SourceBuildingMetaState.to_string_state(5, 7, 9, "block")
	var to_string_bridge := game.generated_building_comp_to_string_bridge_state(5, 7, 9, "block")
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_META_STATE_MODULE_PROOF",
		"cursor_state": cursor_state,
		"health_changed_state": health_changed_state,
		"to_string_state": to_string_state,
		"to_string_bridge": to_string_bridge,
		"to_string_bridge_matches": to_string_bridge == SourceBuildingMetaState.generated_to_string_bridge_state(5, 7, 9, "block"),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["to_string_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_META_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingMetaStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
