extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_build_selection_runtime_state := preload("res://src/game/SourceBuildSelectionRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_selected_build_state := preload("res://src/game/SourceSelectedBuildState.gd")
const source_projector_defaults := preload("res://src/game/SourceProjectorDefaults.gd")
const source_mend_projector_state := preload("res://src/game/SourceMendProjectorState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class FakeBlock:
	extends RefCounted
	var id := ""
	var texture_present := true

	func _init(block_id: String, has_texture_value := true) -> void:
		id = block_id
		texture_present = has_texture_value

	func has_texture() -> bool:
		return texture_present

class FakeCatalog:
	extends RefCounted
	var by_id: Dictionary = {}
	var blocks: Array = []

	func get_by_id(block_id: String):
		return by_id.get(block_id, null)

	func get_many(kind: String) -> Array:
		return blocks if kind == "block" else []

class FakeGame:
	extends RefCounted
	var content_catalog = null
	var build_palette: Array = []
	var selected_build_index := 0

func _ready() -> void:
	var conveyor := FakeBlock.new(source_playable_scenario_defaults.BLOCK_CONVEYOR)
	var router := FakeBlock.new(source_playable_scenario_defaults.BLOCK_ROUTER)
	var duo_untextured := FakeBlock.new(source_playable_scenario_defaults.BLOCK_DUO, false)
	var extra := FakeBlock.new("proof-extra-block")
	var catalog := FakeCatalog.new()
	catalog.by_id[conveyor.id] = conveyor
	catalog.by_id[router.id] = router
	catalog.by_id[duo_untextured.id] = duo_untextured
	catalog.blocks = [extra, conveyor, duo_untextured]
	var fake_game := FakeGame.new()
	fake_game.content_catalog = catalog

	source_build_selection_runtime_state.build_block_palette(fake_game)
	var palette_ids: Array[String] = []
	for block in fake_game.build_palette:
		palette_ids.append(str(block.id))
	var palette_matches := palette_ids == [source_playable_scenario_defaults.BLOCK_CONVEYOR, source_playable_scenario_defaults.BLOCK_ROUTER, "proof-extra-block"]
	var block_from_id: Variant = source_build_selection_runtime_state.block_by_id(fake_game, source_playable_scenario_defaults.BLOCK_CONVEYOR)
	var block_by_id_matches := block_from_id != null and str(block_from_id.id) == source_playable_scenario_defaults.BLOCK_CONVEYOR
	var target_filter := source_build_selection_runtime_state.selected_build_overdrive_target_filter_state_for_block_id(fake_game, source_playable_scenario_defaults.BLOCK_ROUTER, 4.0, 0.0)
	var target_filter_matches := target_filter == {"real_range": 0.0, "distance": 4.0, "can_overdrive": false, "in_range": false, "eligible": false}
	var selected_block: Variant = source_build_selection_runtime_state.selected_build_for_game(fake_game)
	var selected_build_for_game_matches: bool = selected_block == source_selected_build_state.selected_build(fake_game.build_palette, fake_game.selected_build_index)
	var selected_health_matches := source_build_selection_runtime_state.selected_build_health(fake_game) == source_selected_build_state.health(selected_block)
	var selected_scaled_health_matches := source_build_selection_runtime_state.selected_build_scaled_health(fake_game) == source_selected_build_state.scaled_health(selected_block)
	var selected_heal_percent_matches := source_build_selection_runtime_state.selected_build_heal_percent(fake_game) == source_selected_build_state.heal_percent(selected_block)
	var selected_phase_boost_matches := source_build_selection_runtime_state.selected_build_phase_boost(fake_game) == source_selected_build_state.phase_boost(selected_block)
	var selected_phase_range_boost_matches := source_build_selection_runtime_state.selected_build_phase_range_boost(fake_game) == source_selected_build_state.phase_range_boost(selected_block)
	var selected_can_overdrive_matches := source_build_selection_runtime_state.selected_build_can_overdrive(fake_game) == source_selected_build_state.can_overdrive(selected_block)
	var selected_has_power_matches := source_build_selection_runtime_state.selected_build_has_power(fake_game) == source_selected_build_state.has_power(selected_block)
	var selected_consumes_power_matches := source_build_selection_runtime_state.selected_build_consumes_power(fake_game) == source_selected_build_state.consumes_power(selected_block)
	var selected_outputs_power_matches := source_build_selection_runtime_state.selected_build_outputs_power(fake_game) == source_selected_build_state.outputs_power(selected_block)
	var selected_power_usage_matches := source_build_selection_runtime_state.selected_build_power_usage(fake_game) == source_selected_build_state.power_usage(selected_block)
	var selected_power_capacity_matches := source_build_selection_runtime_state.selected_build_power_capacity(fake_game) == source_selected_build_state.power_capacity(selected_block)
	var selected_power_buffered_matches := source_build_selection_runtime_state.selected_build_power_buffered(fake_game) == source_selected_build_state.power_buffered(selected_block)
	var selected_power_production_matches := source_build_selection_runtime_state.selected_build_power_production(fake_game) == source_selected_build_state.power_production(selected_block)
	var selected_item_duration_matches := source_build_selection_runtime_state.selected_build_item_duration(fake_game) == source_selected_build_state.item_duration(selected_block)
	var selected_max_nodes_matches := source_build_selection_runtime_state.selected_build_max_nodes(fake_game) == source_selected_build_state.max_nodes(selected_block)
	var selected_laser_range_matches := source_build_selection_runtime_state.selected_build_laser_range(fake_game) == source_selected_build_state.laser_range(selected_block)
	var selected_overdrive_real_boost_matches := source_build_selection_runtime_state.selected_build_overdrive_real_boost(fake_game) == source_selected_build_state.overdrive_real_boost(selected_block)
	var selected_overdrive_phase_real_boost_matches := source_build_selection_runtime_state.selected_build_overdrive_phase_real_boost(fake_game) == source_selected_build_state.overdrive_phase_real_boost(selected_block)
	var selected_overdrive_boost_bar_fraction_matches := source_build_selection_runtime_state.selected_build_overdrive_boost_bar_fraction(fake_game) == source_selected_build_state.overdrive_boost_bar_fraction(selected_block)
	var selected_overdrive_phase_boost_bar_fraction_matches := source_build_selection_runtime_state.selected_build_overdrive_phase_boost_bar_fraction(fake_game) == source_selected_build_state.overdrive_phase_boost_bar_fraction(selected_block)
	var selected_overdrive_place_state_matches := source_build_selection_runtime_state.selected_build_overdrive_place_state(fake_game) == source_selected_build_state.overdrive_place_state(selected_block)
	var selected_overdrive_phase_select_state_matches := source_build_selection_runtime_state.selected_build_overdrive_phase_select_state(fake_game) == source_selected_build_state.overdrive_phase_select_state(selected_block)
	var selected_overdrive_light_state_matches := source_build_selection_runtime_state.selected_build_overdrive_light_state_for_smooth_efficiency(fake_game, 0.25) == source_selected_build_state.overdrive_light_state_for_smooth_efficiency(selected_block, 0.25)
	var selected_overdrive_draw_state_matches := source_build_selection_runtime_state.selected_build_overdrive_draw_state_for_inputs(fake_game, 0.5, 0.25, 12.0, 8.0) == source_selected_build_state.overdrive_draw_state_for_inputs(selected_block, 0.5, 0.25, 8.0, 12.0)
	var selected_booster_item_matches := source_build_selection_runtime_state.selected_build_booster_item(fake_game) == source_selected_build_state.booster_item(selected_block)
	var selected_booster_use_time_matches := source_build_selection_runtime_state.selected_build_booster_use_time(fake_game) == source_selected_build_state.booster_use_time(selected_block)
	var selected_place_state_matches := source_build_selection_runtime_state.selected_build_place_state(fake_game) == source_selected_build_state.place_state(selected_block)
	var mend_projector: Variant = catalog.get_by_id(source_projector_defaults.MEND_PROJECTOR_BLOCK_ID)
	var selected_repair_amount_matches: bool = source_build_selection_runtime_state.selected_build_repair_amount(fake_game, catalog) == source_mend_projector_state.repair_amount(mend_projector, selected_block)

	source_build_selection_runtime_state.select_build_slot_action(fake_game, "build.slot.2")
	var select_slot_action_matches := fake_game.selected_build_index == 1
	source_build_selection_runtime_state.select_build_slot_action(fake_game, "build.slot.previous")
	var select_previous_action_matches := fake_game.selected_build_index == 0
	source_build_selection_runtime_state.select_build_slot_action(fake_game, "build.slot.next")
	var select_next_action_matches := fake_game.selected_build_index == 1
	fake_game.selected_build_index = 0
	source_build_selection_runtime_state.select_next_build_slot(fake_game)
	var next_matches := fake_game.selected_build_index == 1
	source_build_selection_runtime_state.select_previous_build_slot(fake_game)
	var previous_matches := fake_game.selected_build_index == 0
	var select_by_id_matches := source_build_selection_runtime_state.select_build_block_by_id(fake_game, "proof-extra-block") and fake_game.selected_build_index == 2
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildSelectionRuntimeState",
		"palette_matches": palette_matches,
		"block_by_id_matches": block_by_id_matches,
		"target_filter_matches": target_filter_matches,
		"selected_build_for_game_matches": selected_build_for_game_matches,
		"selected_build_stats_matches": selected_health_matches and selected_scaled_health_matches and selected_heal_percent_matches and selected_phase_boost_matches and selected_phase_range_boost_matches and selected_can_overdrive_matches and selected_has_power_matches and selected_consumes_power_matches and selected_outputs_power_matches and selected_power_usage_matches and selected_power_capacity_matches and selected_power_buffered_matches and selected_power_production_matches,
		"selected_build_extended_stats_matches": selected_item_duration_matches and selected_max_nodes_matches and selected_laser_range_matches and selected_overdrive_real_boost_matches and selected_overdrive_phase_real_boost_matches and selected_overdrive_boost_bar_fraction_matches and selected_overdrive_phase_boost_bar_fraction_matches and selected_overdrive_place_state_matches and selected_overdrive_phase_select_state_matches and selected_overdrive_light_state_matches and selected_overdrive_draw_state_matches and selected_booster_item_matches and selected_booster_use_time_matches and selected_place_state_matches and selected_repair_amount_matches,
		"select_slot_action_matches": select_slot_action_matches,
		"select_previous_action_matches": select_previous_action_matches,
		"select_next_action_matches": select_next_action_matches,
		"next_matches": next_matches,
		"previous_matches": previous_matches,
		"select_by_id_matches": select_by_id_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["palette_matches"] and proof["block_by_id_matches"] and proof["target_filter_matches"] and proof["selected_build_for_game_matches"] and proof["selected_build_stats_matches"] and proof["selected_build_extended_stats_matches"] and proof["select_slot_action_matches"] and proof["select_previous_action_matches"] and proof["select_next_action_matches"] and proof["next_matches"] and proof["previous_matches"] and proof["select_by_id_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILD_SELECTION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildSelectionModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

