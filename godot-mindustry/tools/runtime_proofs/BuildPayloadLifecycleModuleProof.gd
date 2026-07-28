extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBuildPayloadLifecycleState := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tile := "tile"
	var build_block := "block"
	var build_team := "team"
	var rotation_value := 90
	var unit_holder_present := true
	var build_block_update_in_units := true
	var unit_payload_update := false
	var build_block_always_update_in_units := false
	var unit_holder := "unit"
	var building_holder := "building"
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var place_default_bridge := game.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)
	var place_bridge := game.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)
	var update_bridge := game.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var destroyed_bridge := game.generated_build_payload_destroyed_bridge_state()
	var remove_bridge := game.generated_build_payload_remove_bridge_state()
	var module_place_default_bridge := SourceBuildPayloadLifecycleState.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)
	var module_place_bridge := SourceBuildPayloadLifecycleState.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)
	var module_update_bridge := SourceBuildPayloadLifecycleState.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var module_destroyed_bridge := SourceBuildPayloadLifecycleState.generated_build_payload_destroyed_bridge_state()
	var module_remove_bridge := SourceBuildPayloadLifecycleState.generated_build_payload_remove_bridge_state()
	var proof := {
		"module": "BUILD_PAYLOAD_LIFECYCLE_MODULE_PROOF",
		"place_default_bridge": place_default_bridge,
		"place_bridge": place_bridge,
		"update_bridge": update_bridge,
		"destroyed_bridge": destroyed_bridge,
		"remove_bridge": remove_bridge,
		"place_default_bridge_matches": place_default_bridge == module_place_default_bridge,
		"place_bridge_matches": place_bridge == module_place_bridge,
		"update_bridge_matches": update_bridge == module_update_bridge,
		"destroyed_bridge_matches": destroyed_bridge == module_destroyed_bridge,
		"remove_bridge_matches": remove_bridge == module_remove_bridge,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(place_default_bridge.get("matches", false)) and bool(place_bridge.get("matches", false)) and bool(update_bridge.get("matches", false)) and bool(destroyed_bridge.get("matches", false)) and bool(remove_bridge.get("matches", false)) and proof["place_default_bridge_matches"] and proof["place_bridge_matches"] and proof["update_bridge_matches"] and proof["destroyed_bridge_matches"] and proof["remove_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("BUILD_PAYLOAD_LIFECYCLE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildPayloadLifecycleModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
