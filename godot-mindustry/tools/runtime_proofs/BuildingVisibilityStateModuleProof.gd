extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingVisibilityState := preload("res://src/game/SourceBuildingVisibilityState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var initial_bridge := game.generated_building_comp_in_fog_initial_gate_bridge_state(false, true)
	var discovery_bridge := game.generated_building_comp_in_fog_discovery_gate_bridge_state(2, -1, 10, 20, false)
	var visibility_bridge := game.generated_building_comp_in_fog_visibility_loop_bridge_state(2, -1, 10, 20, [{"x": 10, "y": 19}])
	var update_fog_bridge := game.generated_building_comp_update_fog_visibility_bridge_state(false, false, 1, 3, {"self": true}, {"tile": true})
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_VISIBILITY_STATE_MODULE_PROOF",
		"initial_bridge": initial_bridge,
		"discovery_bridge": discovery_bridge,
		"visibility_bridge": visibility_bridge,
		"update_fog_bridge": update_fog_bridge,
		"initial_bridge_matches": initial_bridge == SourceBuildingVisibilityState.generated_in_fog_initial_gate_bridge_state(false, true),
		"discovery_bridge_matches": discovery_bridge == SourceBuildingVisibilityState.generated_in_fog_discovery_gate_bridge_state(2, -1, 10, 20, false),
		"visibility_bridge_matches": visibility_bridge == SourceBuildingVisibilityState.generated_in_fog_visibility_loop_bridge_state(2, -1, 10, 20, [{"x": 10, "y": 19}]),
		"update_fog_bridge_matches": update_fog_bridge == SourceBuildingVisibilityState.generated_update_fog_visibility_bridge_state(false, false, 1, 3, {"self": true}, {"tile": true}),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["initial_bridge_matches"] and proof["discovery_bridge_matches"] and proof["visibility_bridge_matches"] and proof["update_fog_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_VISIBILITY_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingVisibilityStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
