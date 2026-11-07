extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_block_producer_state := preload("res://src/game/SourceBlockProducerState.gd")
const source_block_producer_build_update_state := preload("res://src/game/SourceBlockProducerBuildUpdateState.gd")
const source_block_producer_move_out_payload_state := preload("res://src/game/SourceBlockProducerMoveOutPayloadState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var region := "region"
	var out_region := "out-region"
	var top_region := "top-region"
	var plan_drawx := 16.0
	var plan_drawy := 24.0
	var plan_rotation := 1.0
	var recipe_null := false
	var entity_progress := 9.0
	var recipe_build_time := 12.0
	var source_building := "source-building"
	var item := "copper"
	var item_count := 4
	var maximum_accepted := 10
	var requirements := [
		{"item": "lead", "amount": 4},
		{"item": "copper", "amount": 5},
	]
	var payload := "payload"
	var super_should_consume := true
	var efficiency := 1.0
	var payload_null := true
	var produce := true
	var progress_before := 1.0
	var build_speed := 2.0
	var edelta := 0.5
	var progress := 5.0
	var payload_recipe := "recipe"
	var team := "team"
	var x := 2.0
	var y := 4.0
	var payload_size := 16.0
	var tilesize := 8.0
	var pay_vector_x := 3.0
	var pay_vector_y := 4.0
	var pay_rotation_before := 0.0
	var rotdeg_value := 0.0
	var size_value := 2.0
	var payload_rotate_speed := 0.0
	var payload_speed := 100.0
	var time_delta := 1.0
	var front_present := false
	var front_solid := false
	var front_outputs_payload := false
	var front_accepts_payload := false
	var move_payload_result := false
	var heat_before := 0.0
	var time_before := 2.0
	var draw_plan_region_rotation_offset_degrees := source_math_defaults.QUARTER_CIRCLE_DEGREES
	var icons_bridge := game.generated_block_producer_icons_bridge_state(region, out_region, top_region)
	var draw_plan_region_bridge := game.generated_block_producer_draw_plan_region_bridge_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation)
	var set_bars_bridge := game.generated_block_producer_set_bars_bridge_state(recipe_null, entity_progress, recipe_build_time)
	var accept_item_bridge := game.generated_block_producer_build_accept_item_bridge_state(source_building, item, item_count, maximum_accepted)
	var maximum_accepted_bridge := game.generated_block_producer_build_get_maximum_accepted_bridge_state(item, recipe_null, requirements)
	var accept_payload_bridge := game.generated_block_producer_build_accept_payload_bridge_state(source_building, payload)
	var should_consume_bridge := game.generated_block_producer_build_should_consume_bridge_state(super_should_consume, recipe_null)
	var produce_gate_bridge := game.generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null, efficiency, payload_null)
	var progress_accumulation_bridge := game.generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce, progress_before, build_speed, edelta)
	var completion_guard_bridge := game.generated_block_producer_build_update_tile_completion_guard_bridge_state(progress, recipe_build_time)
	var payload_creation_bridge := game.generated_block_producer_build_update_tile_payload_creation_bridge_state(true, payload_recipe, team, x, y, payload_size, tilesize)
	var pay_vector_reset_bridge := game.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(true, pay_vector_x, pay_vector_y, progress_before)
	var heat_time_bridge := game.generated_block_producer_build_update_tile_heat_time_bridge_state(produce, heat_before, time_before, time_delta)
	var move_out_payload_bridge := game.generated_block_producer_build_update_tile_move_out_payload_bridge_state(true, 0.0, 0.0, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result)
	var proof := {
		"module": "BLOCK_PRODUCER_MODULE_PROOF",
		"draw_plan_region_rotation_offset_degrees": draw_plan_region_rotation_offset_degrees,
		"icons_bridge_matches": icons_bridge == source_block_producer_state.generated_block_producer_icons_bridge_state(region, out_region, top_region),
		"draw_plan_region_bridge_matches": draw_plan_region_bridge == source_block_producer_state.generated_block_producer_draw_plan_region_bridge_state(region, out_region, top_region, plan_drawx, plan_drawy, plan_rotation),
		"set_bars_bridge_matches": set_bars_bridge == source_block_producer_state.generated_block_producer_set_bars_bridge_state(recipe_null, entity_progress, recipe_build_time),
		"accept_item_bridge_matches": accept_item_bridge == source_block_producer_state.generated_block_producer_build_accept_item_bridge_state(source_building, item, item_count, maximum_accepted),
		"maximum_accepted_bridge_matches": maximum_accepted_bridge == source_block_producer_state.generated_block_producer_build_get_maximum_accepted_bridge_state(item, recipe_null, requirements),
		"accept_payload_bridge_matches": accept_payload_bridge == source_block_producer_state.generated_block_producer_build_accept_payload_bridge_state(source_building, payload),
		"should_consume_bridge_matches": should_consume_bridge == source_block_producer_state.generated_block_producer_build_should_consume_bridge_state(super_should_consume, recipe_null),
		"produce_gate_bridge_matches": produce_gate_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_produce_gate_bridge_state(recipe_null, efficiency, payload_null),
		"progress_accumulation_bridge_matches": progress_accumulation_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_progress_accumulation_bridge_state(produce, progress_before, build_speed, edelta),
		"completion_guard_bridge_matches": completion_guard_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_completion_guard_bridge_state(progress, recipe_build_time),
		"payload_creation_bridge_matches": payload_creation_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_payload_creation_bridge_state(true, payload_recipe, team, x, y, payload_size, tilesize),
		"pay_vector_reset_bridge_matches": pay_vector_reset_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_pay_vector_progress_reset_bridge_state(true, pay_vector_x, pay_vector_y, progress_before),
		"heat_time_bridge_matches": heat_time_bridge == source_block_producer_build_update_state.generated_block_producer_build_update_tile_heat_time_bridge_state(produce, heat_before, time_before, time_delta),
		"move_out_payload_bridge_matches": move_out_payload_bridge == source_block_producer_move_out_payload_state.generated_block_producer_build_update_tile_move_out_payload_bridge_state(true, 0.0, 0.0, pay_rotation_before, rotdeg_value, size_value, tilesize, payload_rotate_speed, payload_speed, time_delta, front_present, front_solid, front_outputs_payload, front_accepts_payload, move_payload_result),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(icons_bridge.get("matches", false)) and bool(draw_plan_region_bridge.get("matches", false)) and bool(set_bars_bridge.get("matches", false)) and bool(accept_item_bridge.get("matches", false)) and bool(maximum_accepted_bridge.get("matches", false)) and bool(accept_payload_bridge.get("matches", false)) and bool(should_consume_bridge.get("matches", false)) and bool(produce_gate_bridge.get("matches", false)) and bool(progress_accumulation_bridge.get("matches", false)) and bool(completion_guard_bridge.get("matches", false)) and bool(payload_creation_bridge.get("matches", false)) and bool(pay_vector_reset_bridge.get("matches", false)) and bool(heat_time_bridge.get("matches", false)) and bool(move_out_payload_bridge.get("matches", false)) and proof["icons_bridge_matches"] and proof["draw_plan_region_bridge_matches"] and proof["set_bars_bridge_matches"] and proof["accept_item_bridge_matches"] and proof["maximum_accepted_bridge_matches"] and proof["accept_payload_bridge_matches"] and proof["should_consume_bridge_matches"] and proof["produce_gate_bridge_matches"] and proof["progress_accumulation_bridge_matches"] and proof["completion_guard_bridge_matches"] and proof["payload_creation_bridge_matches"] and proof["pay_vector_reset_bridge_matches"] and proof["heat_time_bridge_matches"] and proof["move_out_payload_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_PRODUCER_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockProducerModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

