extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_power_generator_state := preload("res://src/game/SourcePowerGeneratorState.gd")
const source_power_generator_generated_state := preload("res://src/game/SourcePowerGeneratorGeneratedState.gd")
const source_thermal_generator_state := preload("res://src/game/SourceThermalGeneratorState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game: PortGame = PortGameScript.new()
	game.load_content_registry()
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var power_production := 4.5
	var production_efficiency := 0.75
	var thermal_sum := 1.5
	var attribute_env := 0.5
	var generate_time := 12.0
	var revision := 1
	var read_production_efficiency_value := 0.5
	var read_generate_time_value := 7.0
	var solar_multiplier := 1.25
	var light_env := 0.8
	var lighting := true
	var ambient_light_alpha := 0.2
	var warmup_value := 0.7
	var explosion_min_warmup := 0.6
	var should_explode_value := true
	var source_x := 48.0
	var source_y := 64.0
	var explosion_radius := 3
	var explosion_damage := 90
	var source_tilesize := 8
	var explode_effect_value := "blast"
	var explode_sound_value := "explosion"
	var effect_chance := 0.08
	var chance_delta_result := true
	var range_x := 4.0
	var range_y := 5.0
	var generate_effect_name := "smoke"
	var output_liquid_present := true
	var output_liquid_liquid := "water"
	var output_liquid_amount := 0.25
	var delta_value := 0.5
	var liquid_capacity := 10.0
	var current_liquid_amount := 2.0
	var display_efficiency_scale := 60.0
	var light_clip_size := 12.0
	var size := 2.0
	var super_total_progress := 7.0
	var sum_attribute := 0.9
	var linked_attribute_sum := 1.1
	var min_efficiency := 0.01
	var source_time := 11.0
	var display_efficiency := true
	var floating := false
	var rotation_value := 0
	var valid := true
	var super_after_picked_up_state := {"picked_up": true}
	var super_on_proximity_added_state := {"proximity": true}
	var super_set_stats_state := {"stats": true}
	var super_load_state := {"loaded": true}
	var drawer_load_state := {"loaded": true}
	var drawer_icons_state: Array = ["generator-base", "generator-top"]
	var has_power := true
	var outputs_power := true
	var super_set_bars_state := {"bars": true}
	var time_scale := 1.25
	var plan_state := {"id": "plan"}
	var list_state := [{"id": "plan"}]
	var drawer_draw_plan_state := {"drawn": true}
	var explosion_puddle_liquid_value: Variant = "slag"
	var explosion_puddles := 2
	var explosion_puddle_range := 16.0
	var explosion_puddle_amount := 24.0
	var random_angle_units := [0.0, 0.25]
	var random_range_units := [0.5, 1.0]
	var tmp_v1_state: Dictionary = source_power_generator_state.create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units)
	var tmp_v1_vectors: Array = tmp_v1_state.get("tmp_v1_vectors", [])
	var tile_world_state: Dictionary = source_power_generator_state.create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors)
	var tile_world_calls: Array = tile_world_state.get("tile_world_calls", [])
	var explosion_shake := 2.0
	var explosion_shake_duration := 6.0
	var create_explosion_state: Dictionary = game.source_power_generator_create_explosion_gate_state(should_explode_value)
	var source_matches: Array[bool] = [
		game.source_power_generator_icons_state(drawer_icons_state) == source_power_generator_state.icons_state(drawer_icons_state),
		game.source_power_generator_outputs_items_state() == source_power_generator_state.outputs_items_state(),
		game.source_power_generator_set_stats_state(power_production, super_set_stats_state) == source_power_generator_state.set_stats_state(power_production, super_set_stats_state),
		game.source_power_generator_set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency) == source_power_generator_state.set_bars_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency),
		game.source_power_generator_load_state(super_load_state, drawer_load_state) == source_power_generator_state.load_state(super_load_state, drawer_load_state),
		game.source_power_generator_draw_plan_region_state(plan_state, list_state, drawer_draw_plan_state) == source_power_generator_state.draw_plan_region_state(plan_state, list_state, drawer_draw_plan_state),
		game.source_power_generator_get_power_production_state(true, power_production, production_efficiency) == source_power_generator_state.get_power_production_state(true, power_production, production_efficiency),
		game.source_power_generator_displayed_power_production_state(power_production) == source_power_generator_state.displayed_power_production_state(power_production),
		game.source_power_generator_build_serialization_state(production_efficiency, generate_time, revision, read_production_efficiency_value, read_generate_time_value) == source_power_generator_state.build_serialization_state(production_efficiency, generate_time, revision, read_production_efficiency_value, read_generate_time_value),
		game.source_solar_generator_update_tile_state(true, solar_multiplier, light_env, lighting, ambient_light_alpha) == source_power_generator_state.solar_update_tile_state(true, solar_multiplier, light_env, lighting, ambient_light_alpha),
		game.source_power_generator_warmup_state(true, production_efficiency) == source_power_generator_state.warmup_state(true, production_efficiency),
		game.source_power_generator_should_explode_state(warmup_value, explosion_min_warmup) == source_power_generator_state.should_explode_state(warmup_value, explosion_min_warmup),
		game.source_power_generator_ambient_volume_state(production_efficiency) == source_power_generator_state.ambient_volume_state(production_efficiency),
		create_explosion_state == source_power_generator_state.create_explosion_gate_state(should_explode_value),
		game.source_power_generator_create_explosion_damage_state(should_explode_value, source_x, source_y, explosion_radius, explosion_damage, source_tilesize) == source_power_generator_state.create_explosion_damage_state(should_explode_value, source_x, source_y, explosion_radius, explosion_damage, source_tilesize),
		game.source_power_generator_create_explosion_effect_sound_state(should_explode_value, source_x, source_y, explode_effect_value, explode_sound_value) == source_power_generator_state.create_explosion_effect_sound_state(should_explode_value, source_x, source_y, explode_effect_value, explode_sound_value),
		game.source_power_generator_create_explosion_puddle_loop_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles) == source_power_generator_state.create_explosion_puddle_loop_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles),
		game.source_power_generator_create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units) == source_power_generator_state.create_explosion_puddle_vector_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_range, random_angle_units, random_range_units),
		game.source_power_generator_create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors) == source_power_generator_state.create_explosion_puddle_tile_world_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, source_x, source_y, source_tilesize, tmp_v1_vectors),
		game.source_power_generator_create_explosion_puddle_deposit_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_amount, tile_world_calls) == source_power_generator_state.create_explosion_puddle_deposit_state(should_explode_value, explosion_puddle_liquid_value, explosion_puddles, explosion_puddle_amount, tile_world_calls),
		game.source_power_generator_create_explosion_shake_state(should_explode_value, source_x, source_y, explosion_shake, explosion_shake_duration) == source_power_generator_state.create_explosion_shake_state(should_explode_value, source_x, source_y, explosion_shake, explosion_shake_duration),
		game.source_power_generator_on_destroyed_reactor_explosion_state(true, create_explosion_state) == source_power_generator_state.on_destroyed_reactor_explosion_state(true, create_explosion_state),
		game.source_thermal_generator_update_tile_state(thermal_sum, attribute_env) == source_thermal_generator_state.update_tile_state(thermal_sum, attribute_env),
		game.source_thermal_generator_update_tile_effect_state(source_x, source_y, production_efficiency, effect_chance, chance_delta_result, range_x, range_y, generate_effect_name) == source_thermal_generator_state.update_tile_effect_state(source_x, source_y, production_efficiency, effect_chance, chance_delta_result, range_x, range_y, generate_effect_name),
		game.source_thermal_generator_update_tile_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, production_efficiency, delta_value, liquid_capacity, current_liquid_amount) == source_thermal_generator_state.update_tile_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, production_efficiency, delta_value, liquid_capacity, current_liquid_amount),
		game.source_thermal_generator_displayed_power_production_state(power_production, display_efficiency_scale) == source_thermal_generator_state.displayed_power_production_state(power_production, display_efficiency_scale),
		game.source_thermal_generator_init_state(output_liquid_present, light_clip_size, size) == source_thermal_generator_state.init_state(output_liquid_present, light_clip_size, size),
		game.source_thermal_generator_total_progress_state(true, thermal_sum, super_total_progress) == source_thermal_generator_state.total_progress_state(true, thermal_sum, super_total_progress),
		game.source_thermal_generator_after_picked_up_state(thermal_sum, super_after_picked_up_state) == source_thermal_generator_state.after_picked_up_state(thermal_sum, super_after_picked_up_state),
		game.source_thermal_generator_on_proximity_added_state(sum_attribute, super_on_proximity_added_state) == source_thermal_generator_state.on_proximity_added_state(sum_attribute, super_on_proximity_added_state),
		game.source_thermal_generator_can_place_on_state(linked_attribute_sum, min_efficiency) == source_thermal_generator_state.can_place_on_state(linked_attribute_sum, min_efficiency),
		game.source_thermal_generator_draw_light_state(source_x, source_y, source_time, production_efficiency, size) == source_thermal_generator_state.draw_light_state(source_x, source_y, source_time, production_efficiency, size),
		game.source_thermal_generator_set_stats_state(power_production, display_efficiency_scale, display_efficiency, size, floating, super_set_stats_state) == source_thermal_generator_state.set_stats_state(power_production, display_efficiency_scale, display_efficiency, size, floating, super_set_stats_state),
		game.source_thermal_generator_set_stats_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, size) == source_thermal_generator_state.set_stats_output_liquid_state(output_liquid_present, output_liquid_liquid, output_liquid_amount, size),
		game.source_thermal_generator_draw_place_state(int(source_x), int(source_y), rotation_value, valid, display_efficiency, sum_attribute, display_efficiency_scale) == source_thermal_generator_state.draw_place_state(int(source_x), int(source_y), rotation_value, valid, display_efficiency, sum_attribute, display_efficiency_scale),
	]
	var generated_bridge: Dictionary = game.generated_power_generator_displayed_power_production_bridge_state(power_production)
	var generated_canonical: Dictionary = source_power_generator_generated_state.generated_displayed_power_production_bridge_state(power_production)
	var generated_icons_bridge: Dictionary = source_power_generator_generated_state.generated_icons_bridge_state(drawer_icons_state)
	var generated_set_bars_bridge: Dictionary = source_power_generator_generated_state.generated_set_bars_bridge_state(has_power, outputs_power, super_set_bars_state, power_production, time_scale, production_efficiency)
	var generated_canonical_matches: Array[bool] = [
		generated_bridge == generated_canonical,
		bool(generated_bridge.get("matches", false)),
		bool(generated_icons_bridge.get("matches", false)),
		bool(generated_set_bars_bridge.get("matches", false)),
	]
	var proof: Dictionary = {
		"module": "POWER_GENERATOR_MODULE_PROOF",
		"source_matches": source_matches,
		"generated_canonical_matches": generated_canonical_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["module_matches"] = not source_matches.has(false) and not generated_canonical_matches.has(false)
	proof["matches"] = bool(proof["module_matches"]) and bool(proof["one_headquarter_per_ssot"]) and bool(proof["registry_valid"])
	var proof_label := get_node_or_null("ProofCanvas/ProofLabel") as Label
	if proof_label != null:
		proof_label.text = "POWER_GENERATOR_MODULE_PROOF matches=%s registry_valid=%s" % [str(proof["matches"]), str(proof["registry_valid"])]
	print("POWER_GENERATOR_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("PowerGeneratorModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

