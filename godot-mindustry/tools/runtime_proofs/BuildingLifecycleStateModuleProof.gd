extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_lifecycle_state := preload("res://src/game/SourceBuildingLifecycleState.gd")
const source_building_lifecycle_team_state := preload("res://src/game/SourceBuildingLifecycleTeamState.gd")
const source_building_lifecycle_pickup_state := preload("res://src/game/SourceBuildingLifecyclePickupState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

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
	var heal_suppressed_bridge := game.generated_building_comp_is_heal_suppressed_bridge_state(true, 3.0, 10.0)
	var heal_suppression_default_bridge := game.generated_building_comp_apply_heal_suppression_bridge_state(5.0, 10.0, 2.0, "Pal.sapBullet", false)
	var heal_suppression_color_bridge := game.generated_building_comp_apply_heal_suppression_bridge_state(12.0, 10.0, 2.0, "red", true)
	var heal_suppression_default := game.source_building_heal_suppression_state(5.0, 10.0, 2.0)
	var heal_suppression_color := game.source_building_heal_suppression_state(12.0, 10.0, 2.0, "red")
	var recently_healed_state := game.generated_building_comp_recently_healed_bridge_state(10.0)
	var was_recently_healed_state := game.generated_building_comp_was_recently_healed_bridge_state(8.0, 3.0, 10.0)
	var was_recently_damaged_state := game.generated_building_comp_was_recently_damaged_bridge_state(8.0, 3.0, 10.0)
	var killed_initial_bridge := game.generated_building_comp_killed_initial_side_effects_bridge_state("tile-1")
	var killed_removal_bridge := game.generated_building_comp_killed_removal_side_effects_bridge_state("tile-1", true)
	var check_allow_update_bridge := game.generated_building_comp_check_allow_update_bridge_state(true, false)
	var update_tile_bridge := game.generated_building_comp_update_tile_gate_bridge_state(true, false)
	var update_payload_bridge := game.generated_building_comp_update_payload_bridge_state("unit-holder", "building-holder")
	var update_tile_noop_bridge := game.generated_building_comp_update_tile_noop_bridge_state()
	var empty_item_taken_bridge := game.generated_building_comp_empty_lifecycle_callbacks_bridge_state("java_method_itemTaken_68", ["copper"])
	var empty_dropped_bridge := game.generated_building_comp_empty_lifecycle_callbacks_bridge_state("java_method_dropped_70", [])
	var empty_handle_string_bridge := game.generated_building_comp_empty_lifecycle_callbacks_bridge_state("java_method_handleString_71", ["logic-value"])
	var empty_created_bridge := game.generated_building_comp_empty_lifecycle_callbacks_bridge_state("java_method_created_72", [])
	var empty_stack_offset_bridge := game.generated_building_comp_empty_lifecycle_callbacks_bridge_state("java_method_getStackOffset_81", ["copper", {"x": 3.0, "y": 4.0}])
	var init_bridge := game.generated_building_comp_init_bridge_state(false, true, true, "tile-1", "blue", 2, 16.0, 24.0)
	var create_bridge := game.generated_building_comp_create_bridge_state("block-1", "blue", 120.0, 4, true, false, true)
	var add_bridge := game.generated_building_comp_add_bridge_state(true)
	var write_hook_bridge := game.generated_building_comp_write_hook_bridge_state("write-stream")
	var read_hook_bridge := game.generated_building_comp_read_hook_bridge_state("read-stream", 3)
	var write_all_bridge := game.generated_building_comp_write_all_bridge_state()
	var read_all_bridge := game.generated_building_comp_read_all_bridge_state()
	var write_sync_bridge := game.generated_building_comp_write_sync_bridge_state()
	var read_sync_bridge := game.generated_building_comp_read_sync_bridge_state()
	var remove_from_proximity_bridge := game.generated_building_comp_remove_from_proximity_bridge_state(4, 2)
	var update_proximity_bridge := game.generated_building_comp_update_proximity_bridge_state(4, 3, false, true)
	var on_nearby_build_added_bridge := game.generated_building_comp_on_nearby_build_added_bridge_state({"other": true})
	var change_team_delegate_bridge := game.generated_building_comp_change_team_delegate_bridge_state("red")
	var change_team_initial_wrapper := game.source_building_change_team_initial_state("blue", "red", null, true)
	var change_team_initial_facade := source_building_lifecycle_state.change_team_initial_state("blue", "red", null, true)
	var change_team_initial_module := source_building_lifecycle_team_state.change_team_initial_state("blue", "red", null, true)
	var change_team_links_wrapper := game.source_building_change_team_power_links_state(2, "red", "old-graph")
	var change_team_links_facade := source_building_lifecycle_state.change_team_power_links_state(2, "red", "old-graph")
	var change_team_links_module := source_building_lifecycle_team_state.change_team_power_links_state(2, "red", "old-graph")
	var change_team_generated_links_wrapper := game.generated_building_comp_change_team_power_links_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var change_team_generated_links_facade := source_building_lifecycle_state.generated_change_team_power_links_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var change_team_generated_links_module := source_building_lifecycle_team_state.generated_change_team_power_links_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var change_team_generated_final_wrapper := game.generated_building_comp_change_team_final_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var change_team_generated_final_facade := source_building_lifecycle_state.generated_change_team_final_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var change_team_generated_final_module := source_building_lifecycle_team_state.generated_change_team_final_bridge_state("blue", "red", null, true, true, true, "old-graph", 2)
	var pickup_can_wrapper := game.source_building_can_pickup_state(true)
	var pickup_can_facade := source_building_lifecycle_state.can_pickup_state(true)
	var pickup_can_module := source_building_lifecycle_pickup_state.can_pickup_state(true)
	var pickup_picked_wrapper := game.source_building_picked_up_state("previous")
	var pickup_picked_facade := source_building_lifecycle_state.picked_up_state("previous")
	var pickup_picked_module := source_building_lifecycle_pickup_state.picked_up_state("previous")
	var pickup_after_wrapper := game.source_building_after_picked_up_state(true, true, false, 0.75)
	var pickup_after_facade := source_building_lifecycle_state.after_picked_up_state(true, true, false, 0.75)
	var pickup_after_module := source_building_lifecycle_pickup_state.after_picked_up_state(true, true, false, 0.75)
	var pickup_can_bridge := game.generated_building_comp_can_pickup_bridge_state(true)
	var pickup_picked_bridge := game.generated_building_comp_picked_up_bridge_state("previous")
	var pickup_after_bridge := game.generated_building_comp_after_picked_up_bridge_state(true, true, false, 0.75)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingLifecycleState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"check_suppression_matches": suppression_wrapper == suppression_module,
		"override_check_suppression_matches": override_suppression == primitive_override_suppression,
		"heal_suppressed_matches": heal_suppressed_wrapper == heal_suppressed_module,
		"heal_suppressed_bridge_matches": bool(heal_suppressed_bridge.get("matches", false)),
		"heal_suppression_default_matches": bool(heal_suppression_default_bridge.get("matches", false)) and heal_suppression_default == heal_suppression_default_bridge.get("canonical", {}),
		"heal_suppression_color_matches": bool(heal_suppression_color_bridge.get("matches", false)) and heal_suppression_color == heal_suppression_color_bridge.get("canonical", {}),
		"recently_healed_matches": bool(recently_healed_state.get("matches", false)),
		"was_recently_healed_matches": bool(was_recently_healed_state.get("matches", false)),
		"was_recently_damaged_matches": bool(was_recently_damaged_state.get("matches", false)),
		"killed_initial_bridge_matches": killed_initial_bridge == source_building_lifecycle_state.generated_killed_initial_side_effects_bridge_state("tile-1"),
		"killed_removal_bridge_matches": killed_removal_bridge == source_building_lifecycle_state.generated_killed_removal_side_effects_bridge_state("tile-1", true),
		"check_allow_update_bridge_matches": check_allow_update_bridge == source_building_lifecycle_state.generated_check_allow_update_bridge_state(true, false),
		"update_tile_gate_bridge_matches": update_tile_bridge == source_building_lifecycle_state.generated_update_tile_gate_bridge_state(true, false),
		"update_payload_bridge_matches": bool(update_payload_bridge.get("matches", false)),
		"update_tile_noop_bridge_matches": bool(update_tile_noop_bridge.get("matches", false)),
		"empty_item_taken_bridge_matches": bool(empty_item_taken_bridge.get("matches", false)),
		"empty_dropped_bridge_matches": bool(empty_dropped_bridge.get("matches", false)),
		"empty_handle_string_bridge_matches": bool(empty_handle_string_bridge.get("matches", false)),
		"empty_created_bridge_matches": bool(empty_created_bridge.get("matches", false)),
		"empty_stack_offset_bridge_matches": bool(empty_stack_offset_bridge.get("matches", false)),
		"init_bridge_matches": bool(init_bridge.get("matches", false)),
		"create_bridge_matches": bool(create_bridge.get("matches", false)),
		"add_bridge_matches": bool(add_bridge.get("matches", false)),
		"write_hook_bridge_matches": bool(write_hook_bridge.get("matches", false)) and bool(write_hook_bridge.get("canonical", {}).get("no_op", false)),
		"read_hook_bridge_matches": bool(read_hook_bridge.get("matches", false)) and bool(read_hook_bridge.get("canonical", {}).get("no_op", false)),
		"write_all_bridge_matches": bool(write_all_bridge.get("matches", false)),
		"read_all_bridge_matches": bool(read_all_bridge.get("matches", false)),
		"write_sync_bridge_matches": bool(write_sync_bridge.get("matches", false)),
		"read_sync_bridge_matches": bool(read_sync_bridge.get("matches", false)),
		"remove_from_proximity_bridge_matches": remove_from_proximity_bridge == source_building_lifecycle_state.generated_remove_from_proximity_bridge_state(4, 2),
		"update_proximity_bridge_matches": update_proximity_bridge == source_building_lifecycle_state.generated_update_proximity_bridge_state(4, 3, false, true),
		"on_nearby_build_added_bridge_matches": on_nearby_build_added_bridge == source_building_lifecycle_state.generated_on_nearby_build_added_bridge_state({"other": true}),
		"change_team_delegate_bridge_matches": change_team_delegate_bridge == source_building_lifecycle_state.generated_change_team_delegate_bridge_state("red"),
		"change_team_initial_matches": change_team_initial_wrapper == change_team_initial_facade and change_team_initial_wrapper == change_team_initial_module,
		"change_team_power_links_matches": change_team_links_wrapper == change_team_links_facade and change_team_links_wrapper == change_team_links_module,
		"change_team_generated_links_matches": change_team_generated_links_wrapper == change_team_generated_links_facade and change_team_generated_links_wrapper == change_team_generated_links_module,
		"change_team_generated_final_matches": change_team_generated_final_wrapper == change_team_generated_final_facade and change_team_generated_final_wrapper == change_team_generated_final_module,
		"pickup_can_pickup_matches": pickup_can_wrapper == pickup_can_facade and pickup_can_wrapper == pickup_can_module,
		"pickup_picked_up_matches": pickup_picked_wrapper == pickup_picked_facade and pickup_picked_wrapper == pickup_picked_module,
		"pickup_after_picked_up_matches": pickup_after_wrapper == pickup_after_facade and pickup_after_wrapper == pickup_after_module,
		"pickup_can_bridge_matches": pickup_can_bridge == source_building_lifecycle_pickup_state.generated_can_pickup_bridge_state(true),
		"pickup_picked_bridge_matches": pickup_picked_bridge == source_building_lifecycle_pickup_state.generated_picked_up_bridge_state("previous"),
		"pickup_after_bridge_matches": pickup_after_bridge == source_building_lifecycle_pickup_state.generated_after_picked_up_bridge_state(true, true, false, 0.75),
		"team_module_matches": change_team_initial_wrapper == change_team_initial_module and change_team_links_wrapper == change_team_links_module and change_team_generated_links_wrapper == change_team_generated_links_module and change_team_generated_final_wrapper == change_team_generated_final_module,
		"module_matches": suppression_wrapper == suppression_module and heal_suppressed_wrapper == heal_suppressed_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["team_module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_check_suppression_matches"] and proof["heal_suppressed_bridge_matches"] and proof["heal_suppression_default_matches"] and proof["heal_suppression_color_matches"] and proof["recently_healed_matches"] and proof["was_recently_healed_matches"] and proof["killed_initial_bridge_matches"] and proof["killed_removal_bridge_matches"] and proof["check_allow_update_bridge_matches"] and proof["update_tile_gate_bridge_matches"] and proof["update_payload_bridge_matches"] and proof["update_tile_noop_bridge_matches"] and proof["empty_item_taken_bridge_matches"] and proof["empty_dropped_bridge_matches"] and proof["empty_handle_string_bridge_matches"] and proof["empty_created_bridge_matches"] and proof["empty_stack_offset_bridge_matches"] and proof["init_bridge_matches"] and proof["create_bridge_matches"] and proof["add_bridge_matches"] and proof["write_hook_bridge_matches"] and proof["read_hook_bridge_matches"] and proof["write_all_bridge_matches"] and proof["read_all_bridge_matches"] and proof["write_sync_bridge_matches"] and proof["read_sync_bridge_matches"] and proof["remove_from_proximity_bridge_matches"] and proof["update_proximity_bridge_matches"] and proof["on_nearby_build_added_bridge_matches"] and proof["change_team_delegate_bridge_matches"] and proof["change_team_initial_matches"] and proof["change_team_power_links_matches"] and proof["change_team_generated_links_matches"] and proof["change_team_generated_final_matches"] and proof["pickup_can_pickup_matches"] and proof["pickup_picked_up_matches"] and proof["pickup_after_picked_up_matches"] and proof["pickup_can_bridge_matches"] and proof["pickup_picked_bridge_matches"] and proof["pickup_after_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_LIFECYCLE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingLifecycleStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_chance_delta_threshold(chance: float, source_delta: float) -> float:
	return chance * source_delta

func _building_lifecycle_method_names() -> Dictionary:
	return {
		source_building_lifecycle_state.SOURCE_BUILDING_LIFECYCLE_CHANCE_DELTA_THRESHOLD_KEY: "proof_chance_delta_threshold",
	}
