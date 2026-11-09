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
	var ticked: Dictionary = turret_build_state.source_tick_buildings_state(game, 1.0 / 60.0)
	proof["driver_ticked_one"] = int(ticked.get("ticked_count", -1)) == 1 and ticked.get("results_by_cell", {}).has(game.call("cell_key", turret_cell))
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["driver_frame_fresh_current"] = str(frame.get("current_liquid", "")) == str(liquid_names_by_id[int(module.get("current", -1))])
	proof["driver_frame_fresh_multiplier"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0)

	# --- the tick reads the ammo map off the block's registry
	# properties (ContinuousLiquidTurret.java:14 ammoTypes, captured
	# into properties["ammoTypes"] by N2104), not a hardcoded map:
	# the frame's ammo_types is the registry entry, so mutating the
	# entry shows up in the frame after the next tick, and removing
	# it restores the frame. ---
	var registry_ammo: Dictionary = blocks_by_id["sublimate"].properties.get("ammoTypes", {})
	var frame_ammo: Dictionary = frame.get("ammo_types", {})
	proof["frame_ammo_types_matches_registry"] = frame_ammo.size() == registry_ammo.size() and is_equal_approx(float(Dictionary(frame_ammo.get("ozone", {})).get("ammoMultiplier", -1.0)), float(Dictionary(registry_ammo.get("ozone", {})).get("ammoMultiplier", -2.0))) and is_equal_approx(float(Dictionary(frame_ammo.get("cyanogen", {})).get("ammoMultiplier", -1.0)), float(Dictionary(registry_ammo.get("cyanogen", {})).get("ammoMultiplier", -2.0)))
	registry_ammo["__n2105_probe__"] = {"ammoMultiplier": 9.0}
	turret_build_state.source_tick_buildings_state(game, 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["frame_ammo_types_tracks_registry"] = Dictionary(frame.get("ammo_types", {})).has("__n2105_probe__")
	registry_ammo.erase("__n2105_probe__")
	turret_build_state.source_tick_buildings_state(game, 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["frame_ammo_types_tracks_registry_restore"] = not Dictionary(frame.get("ammo_types", {})).has("__n2105_probe__")

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
	# --- water has no ammo type, so the filter does not consume it:
	# getConsumed falls back to ozone (the first ammo liquid with
	# amount left in content order), and LiquidModule.remove sets
	# current to the removed liquid (LiquidModule.java:110-112,
	# 125-127) — so after the first consuming tick current is ozone
	# again, not water. The multiplier lambda reads b.liquids
	# .current() (ContinuousLiquidTurret.java:46), so that first
	# tick pays 1.0 (current is still water when updateConsumption
	# runs) and the next three pay 1/1.2: the drop over four ticks
	# is 1/60 + 3 * 1/60 * 1/1.2. (Before N2106 the turret consumed
	# nothing, so current stayed water and the multiplier read 1.0;
	# the water-pays-1.0 case is still proven live by the fresh
	# module above, which has no ammo liquid to consume.) ---
	liquid_module_state.source_add_state(module, water_id, 5.0, [])
	var ozone_before_water: float = float(liquid_module_state.source_get_state(module, ozone_id).get("amount", -1.0))
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	frame = turret.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["live_loop_water_current_is_consumed"] = str(frame.get("current_liquid", "")) == "ozone"
	proof["live_loop_water_multiplier_follows_consumed"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(frame).get("multiplier", -1.0)), 1.0 / 1.2)
	proof["live_loop_water_untouched"] = is_equal_approx(float(liquid_module_state.source_get_state(module, water_id).get("amount", -1.0)), 5.0)
	proof["live_loop_water_ozone_drains"] = is_equal_approx(float(liquid_module_state.source_get_state(module, ozone_id).get("amount", -1.0)), ozone_before_water - (1.0 / 60.0 + 3.0 * (1.0 / 60.0) * (1.0 / 1.2)))

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
	ticked = turret_build_state.source_tick_buildings_state(game, 1.0 / 60.0)
	proof["driver_ticked_two"] = int(ticked.get("ticked_count", -1)) == 2
	var second_module: Dictionary = second.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(second_module, ozone_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var second_frame: Dictionary = second.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["second_live_loop_ozone_multiplier"] = str(second_frame.get("current_liquid", "")) == "ozone" and is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(second_frame).get("multiplier", -1.0)), 1.0 / 1.2)

	# --- N2106: the live loop binds a RuntimeConsumer for the turret
	# and the placed turret actually consumes its ammo liquid each
	# tick: ConsumeLiquidFilter.update (ConsumeLiquidFilter.java)
	# removes amount * edelta * multiplier from getConsumed each
	# tick, through BuildingComp.updateConsumption's second pass. ---
	var third_cell := Vector2i(40, 7)
	var third := Sprite2D.new()
	game.add_child(third)
	game.call("record_placed_block", third, blocks_by_id["sublimate"], third_cell)
	proof["third_frame_bound"] = third.has_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY)
	var third_frame: Dictionary = third.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["third_consumers_empty_before_tick"] = Array(third_frame.get("consumers", [])).is_empty()
	var third_module: Dictionary = third.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(third_module, ozone_id, 6.0, [])
	proof["third_ozone_added"] = is_equal_approx(float(liquid_module_state.source_get_state(third_module, ozone_id).get("amount", -1.0)), 6.0)
	# Four ticks: the first only flips activated (Java runs
	# super.updateTile() before the hysteresis lines), the next three
	# consume 1/60 * 1/1.2 each.
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	third_frame = third.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	var ozone_after_four: float = float(liquid_module_state.source_get_state(third_module, ozone_id).get("amount", -1.0))
	proof["third_consumers_bound"] = Array(third_frame.get("consumers", [])).size() == 2
	proof["third_activated"] = bool(third_frame.get("activated", false))
	proof["third_ozone_drops_three_ticks"] = is_equal_approx(ozone_after_four, 6.0 - 3.0 * (1.0 / 60.0) * (1.0 / 1.2))
	proof["third_multiplier_still_ozone"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(third_frame).get("multiplier", -1.0)), 1.0 / 1.2)
	# Ten more ticks, all consuming: the drop is 10 * 1/60 * 1/1.2.
	for iteration in range(10):
		game.call("simulate_factory", 1.0 / 60.0)
	var ozone_after_fourteen: float = float(liquid_module_state.source_get_state(third_module, ozone_id).get("amount", -1.0))
	proof["third_ozone_rate_ten_ticks"] = is_equal_approx(ozone_after_fourteen, ozone_after_four - 10.0 * (1.0 / 60.0) * (1.0 / 1.2))
	# Cyanogen pays 1/2: 6.0 added, current flips to cyanogen, all four
	# ticks consume; the ozone is untouched (only getConsumed drains).
	liquid_module_state.source_add_state(third_module, cyanogen_id, 6.0, [])
	proof["third_cyanogen_added"] = is_equal_approx(float(liquid_module_state.source_get_state(third_module, cyanogen_id).get("amount", -1.0)), 6.0)
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var cyanogen_after: float = float(liquid_module_state.source_get_state(third_module, cyanogen_id).get("amount", -1.0))
	var ozone_after_cyanogen: float = float(liquid_module_state.source_get_state(third_module, ozone_id).get("amount", -1.0))
	proof["third_cyanogen_drops_four_ticks"] = is_equal_approx(cyanogen_after, 6.0 - 4.0 * (1.0 / 60.0) * 0.5)
	proof["third_ozone_untouched_by_cyanogen"] = is_equal_approx(ozone_after_cyanogen, ozone_after_fourteen)
	third_frame = third.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["third_multiplier_cyanogen"] = is_equal_approx(float(consume_state.source_cost_multiplier_for_block_state(third_frame).get("multiplier", -1.0)), 0.5)
	# Water has no ammo type: getConsumed falls back to the first ammo
	# liquid with amount left in content order (ozone, Liquids.java),
	# so ozone keeps draining and the water stays put. The multiplier
	# lambda reads b.liquids.current() (ContinuousLiquidTurret
	# .java:46), so the first tick after the water arrives pays 1.0
	# (current is still water when updateConsumption runs) and the
	# next three pay 1/1.2: the drop over four ticks is
	# 1/60 + 3 * 1/60 * 1/1.2.
	liquid_module_state.source_add_state(third_module, water_id, 5.0, [])
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var ozone_after_water: float = float(liquid_module_state.source_get_state(third_module, ozone_id).get("amount", -1.0))
	var cyanogen_after_water: float = float(liquid_module_state.source_get_state(third_module, cyanogen_id).get("amount", -1.0))
	var water_after: float = float(liquid_module_state.source_get_state(third_module, water_id).get("amount", -1.0))
	proof["third_scan_branch_ozone_drains"] = is_equal_approx(ozone_after_water, ozone_after_cyanogen - (1.0 / 60.0 + 3.0 * (1.0 / 60.0) * (1.0 / 1.2)))
	proof["third_cyanogen_untouched_by_water"] = is_equal_approx(cyanogen_after_water, cyanogen_after)
	proof["third_water_untouched"] = is_equal_approx(water_after, 5.0)
	# Rebinding does not duplicate actors: another driver tick keeps two.
	turret_build_state.source_tick_buildings_state(game, 1.0 / 60.0)
	third_frame = third.get_meta(turret_build_state.SOURCE_CONTINUOUS_LIQUID_TURRET_BUILDING_META_KEY, {})
	proof["third_consumers_not_duplicated"] = Array(third_frame.get("consumers", [])).size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("ContinuousLiquidTurretLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
