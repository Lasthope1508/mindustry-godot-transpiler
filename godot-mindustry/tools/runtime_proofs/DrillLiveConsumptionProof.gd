extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid := preload("res://src/game/SourceConsumeLiquidState.gd")
const consume := preload("res://src/game/SourceConsumeState.gd")
const placed := preload("res://src/game/SourcePlacedBlockState.gd")
const storage := preload("res://src/game/SourceLiquidModuleState.gd")
const live := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func tick(game: Node) -> void:
	game.call("_process", 1.0 / 60.0)

func _ready() -> void:
	var amounts := storage.source_initial_state([0])
	storage.source_reset_state(amounts, 0, 0.15)
	var descriptor := {"liquid": 0, "amount": 0.05, "optional": true, "booster": true, "ignored": false}
	var adapter = liquid.source_runtime_consumer_state(descriptor, amounts, [], func(_build): return {"multiplier": 2.0})["consumer"]
	adapter.source_delta = 1.0
	adapter.time_scale = 2.0
	var self_state := {"efficiency": 1.0, "efficiency_scale": 1.0}
	var adapter_efficiency: float = adapter.efficiency(self_state)
	adapter.update(self_state)
	var adapter_matches: bool = is_equal_approx(adapter_efficiency, 0.75) and amounts["liquids"][0] == 0.0 and is_same(adapter.definition, descriptor) and consume.source_cost_multiplier_state(self_state)["multiplier"] == 1.0
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)
	# Drain the liquid network before the measured steps: setup runs
	# the live loop on real (headless) frame deltas, so the pump may
	# already have flooded the conduits and their 1s flow timers may
	# be about to fire mid-proof, pushing water into the drill and
	# breaking the exact liquid assertions below. Resetting each
	# conduit's water to 0 and its flow timer to 0 (and the pump's
	# water to 0) makes the measured ticks see an empty network, as
	# the consumption steps assume; the pump refills conduit 1 at
	# 7/60 per tick but its timer cannot fire within the ~10 ticks
	# this proof runs, so nothing reaches the drill.
	var conduit_state = preload("res://src/game/SourceConduitRuntimeState.gd")
	var scenario_defaults = preload("res://src/game/SourcePlayableScenarioDefaults.gd")
	for conduit_cell in scenario_defaults.conduit_cells():
		var conduit_sprite: Variant = game.call("block_sprite_at_cell", conduit_cell)
		if conduit_sprite == null:
			continue
		var conduit_liquids: Variant = conduit_sprite.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if conduit_liquids != null:
			storage.source_reset_state(conduit_liquids, 0, 0.0)
		var conduit_frame: Dictionary = conduit_sprite.get_meta(conduit_state.SOURCE_CONDUIT_BUILDING_META_KEY, {})
		conduit_frame["flow_timer"] = 0.0
		conduit_sprite.set_meta(conduit_state.SOURCE_CONDUIT_BUILDING_META_KEY, conduit_frame)
	var pump_sprite: Variant = game.call("block_sprite_at_cell", scenario_defaults.PUMP_POS)
	if pump_sprite != null:
		var pump_liquids: Variant = pump_sprite.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY, null)
		if pump_liquids != null:
			storage.source_reset_state(pump_liquids, 0, 0.0)
	var cell: Vector2i = game.get("drill_pos")
	var first: Sprite2D = game.call("block_sprite_at_cell", cell)
	var catalog = game.get("content_catalog")
	var block = catalog.get_many("block").filter(func(value): return value.id == "mechanical-drill")[0]
	var second := Sprite2D.new()
	game.add_child(second)
	var second_cell := Vector2i(28, 20)
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	for occupied in game.call("occupied_cells", second_cell, block):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", second, block, second_cell)
	var unique: Array = placed.source_unique_buildings_state(game)["buildings"]
	var unique_matches: bool = unique.count(first) == 1 and unique.count(second) == 1
	var second_origin_values: Dictionary = game.get("placed_block_origins")
	unique_matches = unique_matches and second_origin_values.values().count(second_cell) == 4
	var first_liquids: Dictionary = first.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
	var second_liquids: Dictionary = second.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)
	storage.source_reset_state(first_liquids, 0, 0.125)
	storage.source_reset_state(second_liquids, 0, 0.2)
	second.set_meta(placed.SOURCE_BLOCK_TIME_SCALE_META_KEY, 2.0)
	second.set_meta(placed.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY, 100.0)
	tick(game)
	var first_frame: Dictionary = first.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)
	var second_frame: Dictionary = second.get_meta(live.SOURCE_DRILL_BUILDING_META_KEY)
	var consumption_matches: bool = is_equal_approx(first_liquids["liquids"][0], 0.075) and is_equal_approx(second_liquids["liquids"][0], 0.1)
	var time_scale_matches: bool = is_equal_approx(second.get_meta(placed.SOURCE_BLOCK_TIME_SCALE_DURATION_META_KEY), 99.0)
	var adapter_identity = second_frame["consumers"][0]
	tick(game)
	consumption_matches = consumption_matches and is_equal_approx(first_liquids["liquids"][0], 0.025) and is_equal_approx(second_liquids["liquids"][0], 0.0)
	second_frame["enabled"] = false
	storage.source_reset_state(second_liquids, 0, 1.0)
	var second_progress: float = second_frame["item_progress"]
	tick(game)
	var disabled_matches: bool = second_liquids["liquids"][0] == 1.0 and second_frame["item_progress"] == second_progress and second_frame["efficiency"] == 0.0
	var partial_matches: bool = is_equal_approx(first_frame["optional_efficiency"], 0.5) and first_liquids["liquids"][0] == 0.0
	var before_dry_progress: float = game.get("item_progress")
	tick(game)
	var dry_matches: bool = first_frame["efficiency"] == 1.0 and first_frame["optional_efficiency"] == 0.0 and first_frame["speed"] == 1.0 and game.get("item_progress") > before_dry_progress
	var reused_matches: bool = is_same(adapter_identity, second_frame["consumers"][0]) and is_same(first_liquids, first.get_meta(placed.SOURCE_BUILDING_LIQUIDS_META_KEY)) and not is_same(first_liquids, second_liquids)
	storage.source_reset_state(first_liquids, 0, 1.0)
	game.set("drill_items", {game.get("drill_output_item_id"): block.properties["itemCapacity"]})
	tick(game)
	var full_matches: bool = first_liquids["liquids"][0] == 1.0 and first_frame["efficiency"] == 0.0
	game.set("drill_items", {})
	for occupied in game.call("occupied_cells", cell, block):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("air"), false)
	tick(game)
	var no_ore_matches: bool = first_liquids["liquids"][0] == 1.0 and first_frame["efficiency"] == 0.0 and first_frame["dominant_item"] == null
	for occupied in game.call("occupied_cells", cell, block):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	# The autonomous drive is proven through the same _process entry
	# with the controlled 1/60s delta every other step uses: real
	# frames carry uncontrolled deltas, so the pump/conduit network
	# can refill the drill faster than it drains and the check
	# becomes a race on wall-clock frame time.
	tick(game)
	tick(game)
	var autonomous_matches: bool = first_liquids["liquids"][0] < 1.0
	var state := registry.canonical_headquarter_registry_state()
	var proof := {"adapter_matches": adapter_matches, "unique_traversal_matches": unique_matches, "time_scale_matches": time_scale_matches, "two_building_consumption_matches": consumption_matches, "partial_optional_matches": partial_matches, "dry_base_drilling_matches": dry_matches, "disabled_matches": disabled_matches, "full_output_matches": full_matches, "no_ore_matches": no_ore_matches, "identity_matches": reused_matches, "autonomous_process_matches": autonomous_matches, "registry_valid": state.get("errors", []).is_empty(), "one_headquarter_per_ssot": state.get("one_headquarter_per_ssot", false)}
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillLiveConsumptionProof", proof)
	game.queue_free()
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
