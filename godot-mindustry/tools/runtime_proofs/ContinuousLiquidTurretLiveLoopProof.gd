extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")
const consume_state := preload("res://src/game/SourceConsumeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var turret_impl: String = String(blocks_by_id["sublimate"].implementation)
	proof["turret_is_continuous_liquid_turret"] = turret_impl == "ContinuousLiquidTurret"

	# Content liquid names indexed by liquid id (Java resolves a liquid
	# by id through content.liquid(id); LiquidModule.java:24 seeds the
	# module's current with content.liquid(0), the first liquid).
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(String(liquid.id))
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog["liquid_id_by_name"]
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var cyanogen_id: int = int(liquid_id_by_name.get("cyanogen", -1))
	var water_id: int = int(liquid_id_by_name.get("water", -1))

	# --- the turret frame is bound ON PLACEMENT: the sprite carries
	# the frame meta the moment record_placed_block returns, before
	# any live-loop tick runs (Block.newBuilding(), Block.java:1002).
	# The frame is empty until the tick fills its keys. ---
	var turret_cell := Vector2i(30, 7)
	var turret := Sprite2D.new()
	game.add_child(turret)
	game.call("record_placed_block", turret, blocks_by_id["sublimate"], turret_cell)
	proof["turret_placed_live_sprite"] = turret != null and str(turret.get_meta("source_block_id", "")) == "sublimate"
	var turret_tile: Dictionary = game.call("source_world_tile", turret_cell.x, turret_cell.y)
	proof["turret_tile_build_is_sprite"] = turret_tile.get("build") == turret and turret_tile.get("block") == blocks_by_id["sublimate"]
	proof["turret_module_attached"] = turret.has_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY)
	proof["frame_bound_on_placement"] = turret.has_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY)
	var frame: Dictionary = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["frame_empty_before_tick"] = frame.is_empty()
	var module: Dictionary = turret.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	# --- a non-turret block binds nothing, and the scenario drill
	# carries no turret frame. ---
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_bind: Dictionary = turret_build_state.source_bind_frame_state(drill_sprite, blocks_by_id["mechanical-drill"])
	proof["non_turret_bind_false"] = drill_bind.get("applied", true) == false
	proof["drill_has_no_turret_frame"] = not drill_sprite.has_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY)

	# --- the live-loop tick driver wires the one placed turret: a
	# fresh module's current is the first liquid (water,
	# Liquids.java:7; LiquidModule.java:24), which has no ammo type,
	# so the turret pays the 1.0 default. ---
	var ticked: Dictionary = turret_build_state.source_tick_buildings_state(game)
	proof["driver_ticked_one"] = int(ticked.get("ticked_count", -1)) == 1 and ticked.get("results_by_cell", {}).has(game.call("cell_key", turret_cell))
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["driver_frame_fresh_current"] = str(frame.get("current_liquid", "")) == str(liquid_names_by_id[int(module.get("current", -1))])
	proof["driver_frame_fresh_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0)

	# --- the live loop itself refreshes the keys every tick:
	# simulate_factory runs the turret tick with the drill, pump and
	# conduits, and the fresh turret still pays 1.0. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_fresh_multiplier"] = str(frame.get("current_liquid", "")) == "water" and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0)

	# --- ozone reaches the turret through the live loop: the tick
	# refreshes the frame and the multiplier is actually paid, 1/1.2. ---
	liquid_module_state.source_add_state(module, ozone_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_ozone"] = str(frame.get("current_liquid", "")) == "ozone"
	proof["live_loop_ozone_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0 / 1.2)

	# --- cyanogen pays 1 / 2, water (no ammo type) pays 1.0. ---
	liquid_module_state.source_add_state(module, cyanogen_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_cyanogen"] = str(frame.get("current_liquid", "")) == "cyanogen"
	proof["live_loop_cyanogen_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 0.5)
	liquid_module_state.source_add_state(module, water_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_water"] = str(frame.get("current_liquid", "")) == "water"
	proof["live_loop_water_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0)

	# --- the keys refresh, they do not go stale: ozone again pays
	# 1 / 1.2 after water, through the live loop alone. ---
	liquid_module_state.source_add_state(module, ozone_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_refresh_ozone"] = str(frame.get("current_liquid", "")) == "ozone" and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0 / 1.2)

	# --- a second sublimate ticks too: the driver counts both. ---
	var second_cell := Vector2i(35, 7)
	var second := Sprite2D.new()
	game.add_child(second)
	game.call("record_placed_block", second, blocks_by_id["sublimate"], second_cell)
	proof["second_turret_placed"] = str(second.get_meta("source_block_id", "")) == "sublimate"
	proof["second_frame_bound_on_placement"] = second.has_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY)
	ticked = turret_build_state.source_tick_buildings_state(game)
	proof["driver_ticked_two"] = int(ticked.get("ticked_count", -1)) == 2
	var second_module: Dictionary = second.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(second_module, ozone_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var second_frame: Dictionary = second.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["second_live_loop_ozone_multiplier"] = str(second_frame.get("current_liquid", "")) == "ozone" and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(second_frame).get("multiplier", -1.0)), 1.0 / 1.2)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ContinuousLiquidTurretLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
