extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_lifecycle_state := preload("res://src/game/SourceBuildingLifecycleState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_lifecycle_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_building_lifecycle_state.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY: Callable(game, source_building_lifecycle_state.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_FALLBACK),
	}
	var override_callbacks := source_building_lifecycle_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_lifecycle_state.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY, Callable()) == Callable(self, "proof_chance_delta_threshold")
	var suppression_wrapper := game.source_building_check_suppression_state(true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red")
	var suppression_module := source_building_lifecycle_state.game_check_suppression_state(game, true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red")
	var override_suppression := source_building_lifecycle_state.game_check_suppression_state(self, true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red")
	var primitive_override_suppression := source_building_lifecycle_state.check_suppression_state(true, 3.0, 10.0, 0.5, 8.0, 9.0, 2, 8.0, "red", Callable(self, "proof_chance_delta_threshold"))
	var heal_suppressed_wrapper := game.source_building_is_heal_suppressed_state(true, 3.0, 10.0)
	var heal_suppressed_module := source_building_lifecycle_state.is_heal_suppressed_state(true, 3.0, 10.0)
	var killed_initial_bridge := game.generated_building_comp_killed_initial_side_effects_bridge_state("tile-1")
	var killed_removal_bridge := game.generated_building_comp_killed_removal_side_effects_bridge_state("tile-1", true)
	var check_allow_update_bridge := game.generated_building_comp_check_allow_update_bridge_state(true, false)
	var update_tile_bridge := game.generated_building_comp_update_tile_gate_bridge_state(true, false)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLifecycleState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"check_suppression_matches": suppression_wrapper == suppression_module,
		"override_check_suppression_matches": override_suppression == primitive_override_suppression,
		"heal_suppressed_matches": heal_suppressed_wrapper == heal_suppressed_module,
		"killed_initial_bridge_matches": killed_initial_bridge == source_building_lifecycle_state.generated_killed_initial_side_effects_bridge_state("tile-1"),
		"killed_removal_bridge_matches": killed_removal_bridge == source_building_lifecycle_state.generated_killed_removal_side_effects_bridge_state("tile-1", true),
		"check_allow_update_bridge_matches": check_allow_update_bridge == source_building_lifecycle_state.generated_check_allow_update_bridge_state(true, false),
		"update_tile_gate_bridge_matches": update_tile_bridge == source_building_lifecycle_state.generated_update_tile_gate_bridge_state(true, false),
		"module_matches": suppression_wrapper == suppression_module and heal_suppressed_wrapper == heal_suppressed_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_check_suppression_matches"] and proof["killed_initial_bridge_matches"] and proof["killed_removal_bridge_matches"] and proof["check_allow_update_bridge_matches"] and proof["update_tile_gate_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BUILDING_LIFECYCLE_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BuildingLifecycleStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return chance * source_delta

func _building_lifecycle_method_names() -> Dictionary:
	return {
		source_building_lifecycle_state.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY: "proof_chance_delta_threshold",
	}
