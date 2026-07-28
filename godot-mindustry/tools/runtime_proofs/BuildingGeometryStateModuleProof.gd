extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBlockGeometry := preload("res://src/game/SourceBlockGeometry.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var hitbox_bridge := game.generated_building_comp_hitbox_bridge_state(10.0, 20.0, 2, 8.0)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_GEOMETRY_STATE_MODULE_PROOF",
		"hitbox_bridge": hitbox_bridge,
		"hitbox_bridge_matches": hitbox_bridge == SourceBlockGeometry.generated_building_hitbox_bridge_state(10.0, 20.0, 2, 8.0),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["hitbox_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_GEOMETRY_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingGeometryStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
