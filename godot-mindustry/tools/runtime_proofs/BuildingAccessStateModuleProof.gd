extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_access_state := preload("res://src/game/SourceBuildingAccessState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var tile_x_wrapper := game.source_building_tile_x_state(11)
	var tile_y_wrapper := game.source_building_tile_y_state(23)
	var pos_wrapper := game.source_building_pos_state(1123)
	var floor_wrapper: Variant = game.source_building_floor_state("sand")
	var interactable_wrapper := game.source_building_interactable_state(true)
	var tile_x_module := source_building_access_state.tile_x_state(11)
	var tile_y_module := source_building_access_state.tile_y_state(23)
	var pos_module := source_building_access_state.pos_state(1123)
	var floor_module: Variant = source_building_access_state.floor_state("sand")
	var interactable_module := source_building_access_state.interactable_state(true)
	var allow_update_module := source_building_access_state.allow_update_state(false, true, false, false, true, true, 5, 5, 0, 0, 10, 10)
	var allow_update_denied_module := source_building_access_state.allow_update_state(false, true, false, false, true, true, 20, 20, 0, 0, 10, 10)
	var in_map_area_module := source_building_access_state.in_map_area_state(true, 0.0, 0.0, 10.0, 10.0, 159.0, 159.0, 16.0)
	var in_map_area_denied_module := source_building_access_state.in_map_area_state(true, 0.0, 0.0, 10.0, 10.0, 161.0, 161.0, 16.0)
	var status_logic_disable_module := source_building_access_state.status_state(false, true, 1.0, true, 0.0)
	var status_no_output_module := source_building_access_state.status_state(true, false, 1.0, true, 0.0)
	var status_no_input_module := source_building_access_state.status_state(true, true, 0.0, true, 0.0)
	var status_active_module := source_building_access_state.status_state(true, true, 1.0, true, 0.0)
	var status_tick_no_input_module := source_building_access_state.status_state(true, true, 0.25, true, 45.0)
	var sleep_module := source_building_access_state.sleep_state(59.0, 1.0, false, 3)
	var sleep_already_module := source_building_access_state.sleep_state(80.0, 1.0, true, 4)
	var no_sleep_module := source_building_access_state.no_sleep_state(true, 4)
	var no_sleep_awake_module := source_building_access_state.no_sleep_state(false, 4)
	var can_withdraw_module := source_building_access_state.can_withdraw_state()
	var can_unload_module := source_building_access_state.can_unload_state(true)
	var can_resupply_module := source_building_access_state.can_resupply_state(true)
	var payload_check_module := source_building_access_state.payload_check_state(true, 1, 3)
	var payload_check_disabled_module := source_building_access_state.payload_check_state(false, 1, 3)
	var allow_deposit_module := source_building_access_state.allow_deposit_state(false, false)
	var allow_deposit_denied_module := source_building_access_state.allow_deposit_state(false, true)
	var should_consume_module := source_building_access_state.should_consume_state(true)
	var should_not_consume_module := source_building_access_state.should_consume_state(false)
	var production_valid_module := source_building_access_state.production_valid_state()
	var consume_trigger_valid_module := source_building_access_state.consume_trigger_valid_state()
	var generated_tile_x_wrapper := game.generated_building_comp_tile_x_bridge_state(11)
	var generated_tile_y_wrapper := game.generated_building_comp_tile_y_bridge_state(23)
	var generated_pos_wrapper := game.generated_building_comp_pos_bridge_state(1123)
	var generated_floor_wrapper := game.generated_building_comp_floor_bridge_state("sand")
	var generated_interactable_wrapper := game.generated_building_comp_interactable_bridge_state(true)
	var generated_tile_x_module := source_building_access_state.generated_tile_x_bridge_state(11)
	var generated_tile_y_module := source_building_access_state.generated_tile_y_bridge_state(23)
	var generated_pos_module := source_building_access_state.generated_pos_bridge_state(1123)
	var generated_floor_module := source_building_access_state.generated_floor_bridge_state("sand")
	var generated_interactable_module := source_building_access_state.generated_interactable_bridge_state(true)
	var generated_allow_update_wrapper := game.generated_building_comp_allow_update_bridge_state(false, true, false, false, true, true, 5, 5, 0, 0, 10, 10)
	var generated_in_map_area_wrapper := game.generated_building_comp_in_map_area_bridge_state(true, 0.0, 0.0, 10.0, 10.0, 159.0, 159.0, 16.0)
	var generated_allow_update_module := source_building_access_state.generated_allow_update_bridge_state(false, true, false, false, true, true, 5, 5, 0, 0, 10, 10)
	var generated_in_map_area_module := source_building_access_state.generated_in_map_area_bridge_state(true, 0.0, 0.0, 10.0, 10.0, 159.0, 159.0, 16.0)
	var generated_status_wrapper := game.generated_building_comp_status_bridge_state(true, true, 1.0, true, 0.0)
	var generated_status_module := source_building_access_state.generated_status_bridge_state(true, true, 1.0, true, 0.0)
	var generated_sleep_wrapper := game.generated_building_comp_sleep_bridge_state(59.0, 1.0, false, 3)
	var generated_sleep_module := source_building_access_state.generated_sleep_bridge_state(59.0, 1.0, false, 3)
	var generated_no_sleep_wrapper := game.generated_building_comp_no_sleep_bridge_state(true, 4)
	var generated_no_sleep_module := source_building_access_state.generated_no_sleep_bridge_state(true, 4)
	var generated_can_withdraw_wrapper := game.generated_building_comp_can_withdraw_bridge_state()
	var generated_can_unload_wrapper := game.generated_building_comp_can_unload_bridge_state(true)
	var generated_can_resupply_wrapper := game.generated_building_comp_can_resupply_bridge_state(true)
	var generated_payload_check_wrapper := game.generated_building_comp_payload_check_bridge_state(true, 1, 3)
	var generated_allow_deposit_wrapper := game.generated_building_comp_allow_deposit_bridge_state(false, false)
	var generated_can_withdraw_module := source_building_access_state.generated_can_withdraw_bridge_state()
	var generated_can_unload_module := source_building_access_state.generated_can_unload_bridge_state(true)
	var generated_can_resupply_module := source_building_access_state.generated_can_resupply_bridge_state(true)
	var generated_payload_check_module := source_building_access_state.generated_payload_check_bridge_state(true, 1, 3)
	var generated_allow_deposit_module := source_building_access_state.generated_allow_deposit_bridge_state(false, false)
	var generated_should_consume_wrapper := game.generated_building_comp_should_consume_bridge_state(true)
	var generated_production_valid_wrapper := game.generated_building_comp_production_valid_bridge_state()
	var generated_consume_trigger_valid_wrapper := game.generated_building_comp_consume_trigger_valid_bridge_state()
	var generated_should_consume_module := source_building_access_state.generated_should_consume_bridge_state(true)
	var generated_production_valid_module := source_building_access_state.generated_production_valid_bridge_state()
	var generated_consume_trigger_valid_module := source_building_access_state.generated_consume_trigger_valid_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingAccessState",
		"tile_x_matches": tile_x_wrapper == tile_x_module,
		"tile_y_matches": tile_y_wrapper == tile_y_module,
		"pos_matches": pos_wrapper == pos_module,
		"floor_matches": floor_wrapper == floor_module,
		"interactable_matches": interactable_wrapper == interactable_module,
		"allow_update_matches": allow_update_module and not allow_update_denied_module,
		"in_map_area_matches": in_map_area_module and not in_map_area_denied_module,
		"status_branch_matches": status_logic_disable_module == "logicDisable" and status_no_output_module == "noOutput" and status_no_input_module == "noInput" and status_active_module == "active" and status_tick_no_input_module == "noInput",
		"sleep_matches": bool(sleep_module.get("remove_called", false)) and sleep_module.get("sleeping_entities_after", -1) == 4 and not bool(sleep_already_module.get("remove_called", true)),
		"no_sleep_matches": bool(no_sleep_module.get("add_called", false)) and no_sleep_module.get("sleeping_entities_after", -1) == 3 and not bool(no_sleep_awake_module.get("add_called", true)),
		"payload_access_matches": can_withdraw_module and can_unload_module and can_resupply_module and payload_check_module and not payload_check_disabled_module and allow_deposit_module and not allow_deposit_denied_module,
		"consumption_predicates_matches": should_consume_module and not should_not_consume_module and production_valid_module and not consume_trigger_valid_module,
		"generated_tile_x_matches": generated_tile_x_wrapper == generated_tile_x_module and bool(generated_tile_x_wrapper.get("matches", false)),
		"generated_tile_y_matches": generated_tile_y_wrapper == generated_tile_y_module and bool(generated_tile_y_wrapper.get("matches", false)),
		"generated_pos_matches": generated_pos_wrapper == generated_pos_module and bool(generated_pos_wrapper.get("matches", false)),
		"generated_floor_matches": generated_floor_wrapper == generated_floor_module and bool(generated_floor_wrapper.get("matches", false)),
		"generated_interactable_matches": generated_interactable_wrapper == generated_interactable_module and bool(generated_interactable_wrapper.get("matches", false)),
		"generated_allow_update_matches": generated_allow_update_wrapper == generated_allow_update_module and bool(generated_allow_update_wrapper.get("matches", false)),
		"generated_in_map_area_matches": generated_in_map_area_wrapper == generated_in_map_area_module and bool(generated_in_map_area_wrapper.get("matches", false)),
		"generated_status_matches": generated_status_wrapper == generated_status_module and bool(generated_status_wrapper.get("matches", false)),
		"generated_sleep_matches": generated_sleep_wrapper == generated_sleep_module and bool(generated_sleep_wrapper.get("matches", false)),
		"generated_no_sleep_matches": generated_no_sleep_wrapper == generated_no_sleep_module and bool(generated_no_sleep_wrapper.get("matches", false)),
		"generated_payload_access_matches": generated_can_withdraw_wrapper == generated_can_withdraw_module and generated_can_unload_wrapper == generated_can_unload_module and generated_can_resupply_wrapper == generated_can_resupply_module and generated_payload_check_wrapper == generated_payload_check_module and generated_allow_deposit_wrapper == generated_allow_deposit_module and bool(generated_can_withdraw_wrapper.get("matches", false)) and bool(generated_can_unload_wrapper.get("matches", false)) and bool(generated_can_resupply_wrapper.get("matches", false)) and bool(generated_payload_check_wrapper.get("matches", false)) and bool(generated_allow_deposit_wrapper.get("matches", false)),
		"generated_consumption_predicates_matches": generated_should_consume_wrapper == generated_should_consume_module and generated_production_valid_wrapper == generated_production_valid_module and generated_consume_trigger_valid_wrapper == generated_consume_trigger_valid_module and bool(generated_should_consume_wrapper.get("matches", false)) and bool(generated_production_valid_wrapper.get("matches", false)) and bool(generated_consume_trigger_valid_wrapper.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["tile_x_matches"] and proof["tile_y_matches"] and proof["pos_matches"] and proof["floor_matches"] and proof["interactable_matches"] and proof["allow_update_matches"] and proof["in_map_area_matches"] and proof["status_branch_matches"] and proof["sleep_matches"] and proof["no_sleep_matches"] and proof["payload_access_matches"] and proof["consumption_predicates_matches"] and proof["generated_tile_x_matches"] and proof["generated_tile_y_matches"] and proof["generated_pos_matches"] and proof["generated_floor_matches"] and proof["generated_interactable_matches"] and proof["generated_allow_update_matches"] and proof["generated_in_map_area_matches"] and proof["generated_status_matches"] and proof["generated_sleep_matches"] and proof["generated_no_sleep_matches"] and proof["generated_payload_access_matches"] and proof["generated_consumption_predicates_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_ACCESS_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingAccessStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
