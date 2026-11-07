extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_build_payload_lifecycle_state := preload("res://src/game/SourceBuildPayloadLifecycleState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

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
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var place_default_bridge := game.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)
	var place_bridge := game.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)
	var update_bridge := game.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var destroyed_bridge := game.generated_build_payload_destroyed_bridge_state()
	var remove_bridge := game.generated_build_payload_remove_bridge_state()
	var module_place_default_bridge := source_build_payload_lifecycle_state.generated_build_payload_place_default_bridge_state(tile, build_block, build_team)
	var module_place_bridge := source_build_payload_lifecycle_state.generated_build_payload_place_bridge_state(tile, build_block, build_team, rotation_value)
	var module_update_bridge := source_build_payload_lifecycle_state.generated_build_payload_update_bridge_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var module_destroyed_bridge := source_build_payload_lifecycle_state.generated_build_payload_destroyed_bridge_state()
	var module_remove_bridge := source_build_payload_lifecycle_state.generated_build_payload_remove_bridge_state()
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
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(place_default_bridge.get("matches", false)) and bool(place_bridge.get("matches", false)) and bool(update_bridge.get("matches", false)) and bool(destroyed_bridge.get("matches", false)) and bool(remove_bridge.get("matches", false)) and proof["place_default_bridge_matches"] and proof["place_bridge_matches"] and proof["update_bridge_matches"] and proof["destroyed_bridge_matches"] and proof["remove_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILD_PAYLOAD_LIFECYCLE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildPayloadLifecycleModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

