extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_tractor_beam_turret_build_update_tile_flow_state := preload("res://src/game/SourceTractorBeamTurretBuildUpdateTileFlowState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var activation_timer := 0.0
	var time_delta := 1.0
	var efficiency := 0.75
	var coolant_multiplier := 1.5
	var delta_value := 2.0
	var timer_target_ready := true
	var existing_target := {"id": 1, "team": "sharded"}
	var closest_enemy_result := {"id": 2, "team": "crux"}
	var team := "sharded"
	var x := 16.0
	var y := 24.0
	var range_value := 120.0
	var target_air := true
	var target_ground := false
	var coolant_present := true
	var coolant_amount := 3.0
	var current_liquid := "cryofluid"
	var liquid_amount := 2.0
	var liquid_heat_capacity := 0.6
	var chance_result := true
	var size := 2.0
	var source_tilesize := 8.0
	var range_x := 1.0
	var range_y := -2.0
	var any_before := true
	var activation_bridge := game.generated_tractor_beam_turret_build_update_tile_activation_bridge_state(activation_timer, time_delta)
	var eff_bridge := game.generated_tractor_beam_turret_build_update_tile_eff_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value)
	var retarget_bridge := game.generated_tractor_beam_turret_build_update_tile_retarget_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground)
	var coolant_guard_bridge := game.generated_tractor_beam_turret_build_update_tile_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid)
	var coolant_used_bridge := game.generated_tractor_beam_turret_build_update_tile_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)
	var coolant_remove_bridge := game.generated_tractor_beam_turret_build_update_tile_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity)
	var coolant_effect_bridge := game.generated_tractor_beam_turret_build_update_tile_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)
	var coolant_multiplier_bridge := game.generated_tractor_beam_turret_build_update_tile_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y)
	var any_reset_bridge := game.generated_tractor_beam_turret_build_update_tile_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before)
	var proof := {
		"module": "SourceTractorBeamTurretBuildUpdateTileFlowState",
		"activation_bridge_matches": activation_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_activation_bridge_state(activation_timer, time_delta) and bool(activation_bridge.get("matches", false)),
		"eff_bridge_matches": eff_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_eff_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value) and bool(eff_bridge.get("matches", false)),
		"retarget_bridge_matches": retarget_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_retarget_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground) and bool(retarget_bridge.get("matches", false)),
		"coolant_guard_bridge_matches": coolant_guard_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_guard_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid) and bool(coolant_guard_bridge.get("matches", false)),
		"coolant_used_bridge_matches": coolant_used_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_used_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity) and bool(coolant_used_bridge.get("matches", false)),
		"coolant_remove_bridge_matches": coolant_remove_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_remove_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity) and bool(coolant_remove_bridge.get("matches", false)),
		"coolant_effect_bridge_matches": coolant_effect_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_effect_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y) and bool(coolant_effect_bridge.get("matches", false)),
		"coolant_multiplier_bridge_matches": coolant_multiplier_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_coolant_multiplier_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y) and bool(coolant_multiplier_bridge.get("matches", false)),
		"any_reset_bridge_matches": any_reset_bridge == source_tractor_beam_turret_build_update_tile_flow_state.generated_any_reset_bridge_state(activation_timer, time_delta, efficiency, coolant_multiplier, delta_value, timer_target_ready, existing_target, closest_enemy_result, team, x, y, range_value, target_air, target_ground, coolant_present, coolant_amount, current_liquid, liquid_amount, liquid_heat_capacity, chance_result, size, source_tilesize, range_x, range_y, any_before) and bool(any_reset_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["module_matches"] = proof["activation_bridge_matches"] and proof["eff_bridge_matches"] and proof["retarget_bridge_matches"] and proof["coolant_guard_bridge_matches"] and proof["coolant_used_bridge_matches"] and proof["coolant_remove_bridge_matches"] and proof["coolant_effect_bridge_matches"] and proof["coolant_multiplier_bridge_matches"] and proof["any_reset_bridge_matches"]
	proof["matches"] = proof["module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "TRACTOR_BEAM_UPDATE_TILE_FLOW_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	print("TRACTOR_BEAM_UPDATE_TILE_FLOW_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TractorBeamUpdateTileFlowModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

