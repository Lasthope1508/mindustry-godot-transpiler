extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildingSetPropState := preload("res://src/game/SourceBuildingSetPropState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var health_bridge := game.generated_building_comp_set_prop_health_bridge_state("health", 10.0, 20.0, -5.0, false, "self")
	var team_double_bridge := game.generated_building_comp_set_prop_team_double_bridge_state("team", 7, 9.0)
	var total_power_bridge := game.generated_building_comp_set_prop_total_power_bridge_state("totalPower", 0.25, true, true, true, 2.0, 1.5)
	var team_object_bridge := game.generated_building_comp_set_prop_team_object_bridge_state("team", 7, true, 9)
	var item_content_bridge := game.generated_building_comp_set_prop_item_content_bridge_state("item", true, "copper", 2, 5.0, 3)
	var liquid_content_bridge := game.generated_building_comp_set_prop_liquid_content_bridge_state("liquid", true, "water", 0.25, 0.5, 1.0, true, true, 0.25, true)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "BUILDING_SET_PROP_STATE_MODULE_PROOF",
		"health_bridge_matches": health_bridge == SourceBuildingSetPropState.generated_health_bridge_state("health", 10.0, 20.0, -5.0, false, "self"),
		"team_double_bridge_matches": team_double_bridge == SourceBuildingSetPropState.generated_team_double_bridge_state("team", 7, 9.0),
		"total_power_bridge_matches": total_power_bridge == SourceBuildingSetPropState.generated_total_power_bridge_state("totalPower", 0.25, true, true, true, 2.0, 1.5),
		"team_object_bridge_matches": team_object_bridge == SourceBuildingSetPropState.generated_team_object_bridge_state("team", 7, true, 9),
		"item_content_bridge_matches": item_content_bridge == SourceBuildingSetPropState.generated_item_content_bridge_state("item", true, "copper", 2, 5.0, 3),
		"liquid_content_bridge_matches": liquid_content_bridge == SourceBuildingSetPropState.generated_liquid_content_bridge_state("liquid", true, "water", 0.25, 0.5, 1.0, true, true, 0.25, true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"health_bridge": health_bridge,
		"team_double_bridge": team_double_bridge,
		"total_power_bridge": total_power_bridge,
		"team_object_bridge": team_object_bridge,
		"item_content_bridge": item_content_bridge,
		"liquid_content_bridge": liquid_content_bridge,
	}
	proof["matches"] = proof["health_bridge_matches"] and proof["team_double_bridge_matches"] and proof["total_power_bridge_matches"] and proof["team_object_bridge_matches"] and proof["item_content_bridge_matches"] and proof["liquid_content_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_SET_PROP_STATE_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/BuildingSetPropStateModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
