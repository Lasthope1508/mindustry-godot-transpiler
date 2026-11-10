extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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
	proof["factory_smelter_is_generic_crafter"] = String(blocks_by_id["silicon-smelter"].implementation) == "GenericCrafter"
	proof["factory_mixer_is_generic_crafter"] = String(blocks_by_id["cryofluid-mixer"].implementation) == "GenericCrafter"
	proof["factory_heater_is_heat_producer"] = String(blocks_by_id["electric-heater"].implementation) == "HeatProducer"
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))

	# --- the three factories are placed live, and the N2110 frame is
	# bound ON PLACEMENT (Block.newBuilding(), Block.java:1002). ---
	var smelter_cell := Vector2i(30, 7)
	var mixer_cell := Vector2i(35, 7)
	var heater_cell := Vector2i(40, 7)
	var smelter := Sprite2D.new()
	game.add_child(smelter)
	game.call("record_placed_block", smelter, blocks_by_id["silicon-smelter"], smelter_cell)
	var mixer := Sprite2D.new()
	game.add_child(mixer)
	game.call("record_placed_block", mixer, blocks_by_id["cryofluid-mixer"], mixer_cell)
	var heater := Sprite2D.new()
	game.add_child(heater)
	game.call("record_placed_block", heater, blocks_by_id["electric-heater"], heater_cell)
	proof["factory_smelter_frame_bound_on_placement"] = smelter.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	proof["factory_mixer_frame_bound_on_placement"] = mixer.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	proof["factory_heater_frame_bound_on_placement"] = heater.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- the binding itself: one RuntimeConsumer actor per consume
	# row (the drill model, N2097/N2100). The smelter consumes coal
	# 1 + sand 2 (Blocks.java:1081, consumeItems with coal 1, sand
	# 2); the mixer consumes titanium 1 + water 0.2; the heater has
	# no item or liquid rows and binds nothing. ---
	var smelter_frame: Dictionary = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_frame["items"] = {"coal": 5, "sand": 5}
	var smelter_bind: Dictionary = factory_build_state.source_bind_consumer_state(smelter_frame, blocks_by_id["silicon-smelter"], catalog, {})
	proof["factory_smelter_bind_two_actors"] = bool(smelter_bind.get("bound", false)) == true and Array(smelter_bind.get("consumers", [])).size() == 2 and Array(smelter_bind.get("rows", [])).size() == 2 and str(Array(smelter_bind.get("rows", []))[0].get("item", "")) == "coal" and str(Array(smelter_bind.get("rows", []))[1].get("item", "")) == "sand"
	var smelter_rebind: Dictionary = factory_build_state.source_bind_consumer_state(smelter_frame, blocks_by_id["silicon-smelter"], catalog, {})
	proof["factory_smelter_rebind_no_duplicate"] = bool(smelter_rebind.get("bound", true)) == false and Array(smelter_frame.get("consumers", [])).size() == 2
	var mixer_frame: Dictionary = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["items"] = {"titanium": 5}
	var mixer_module: Dictionary = mixer.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(mixer_module, water_id, 10.0, [])
	var mixer_bind: Dictionary = factory_build_state.source_bind_consumer_state(mixer_frame, blocks_by_id["cryofluid-mixer"], catalog, mixer_module)
	proof["factory_mixer_bind_two_actors"] = bool(mixer_bind.get("bound", false)) == true and Array(mixer_bind.get("consumers", [])).size() == 2 and Array(mixer_bind.get("rows", [])).size() == 2 and str(Array(mixer_bind.get("rows", []))[0].get("item", "")) == "titanium" and int(Array(mixer_bind.get("rows", []))[1].get("liquid", -1)) == water_id
	var heater_frame: Dictionary = heater.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var heater_bind: Dictionary = factory_build_state.source_bind_consumer_state(heater_frame, blocks_by_id["electric-heater"], catalog, {})
	proof["factory_heater_bind_none"] = bool(heater_bind.get("bound", true)) == false and Array(heater_bind.get("consumers", [])).is_empty() and Array(heater_bind.get("rows", [])).is_empty()
	var bare_frame: Dictionary = {}
	var null_bind: Dictionary = factory_build_state.source_bind_consumer_state(bare_frame, null, catalog, {})
	proof["factory_null_block_bind_none"] = bool(null_bind.get("bound", true)) == false and Array(null_bind.get("consumers", [])).is_empty() and Array(null_bind.get("rows", [])).is_empty()

	# --- the live-loop tick driver ticks all three, and the bound
	# actors run through updateConsumption every tick: the mixer
	# drains its water at the live rate (ConsumeLiquid.update,
	# ConsumeLiquid.java:38-40: amount * edelta * multiplier, 0.2
	# per tick at efficiency 1.0), while the item stacks stay put —
	# ConsumeItems has no update body (Consume.java:52), so items
	# leave only at craft() via trigger (a later slice). ---
	var ticked: Dictionary = factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["factory_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", smelter_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", mixer_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", heater_cell))
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	heater_frame = heater.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_smelter_consumers_still_two"] = Array(smelter_frame.get("consumers", [])).size() == 2
	proof["factory_mixer_consumers_still_two"] = Array(mixer_frame.get("consumers", [])).size() == 2
	proof["factory_smelter_efficiency_one"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 1.0)
	proof["factory_smelter_items_unchanged"] = Dictionary(smelter_frame.get("items", {})).get("coal", -1) == 5 and Dictionary(smelter_frame.get("items", {})).get("sand", -1) == 5
	proof["factory_mixer_water_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0)), 10.0 - 4.0 * 0.2)
	proof["factory_mixer_titanium_unchanged"] = Dictionary(mixer_frame.get("items", {})).get("titanium", -1) == 5
	proof["factory_mixer_efficiency_one"] = is_equal_approx(float(mixer_frame.get("efficiency", -1.0)), 1.0)
	proof["factory_heater_consumers_zero"] = Array(heater_frame.get("consumers", [])).is_empty()
	proof["factory_heater_efficiency_one"] = is_equal_approx(float(heater_frame.get("efficiency", -1.0)), 1.0)

	# --- the item actors gate efficiency: with the smelter's items
	# gone the first pass reads 0, so efficiency is 0 and the
	# building should not consume power; restoring them restores 1.0.
	# (The actors hold the frame's item module by reference, so the
	# proof empties the same dict in place.) ---
	var smelter_items: Dictionary = smelter_frame.get("items", {})
	smelter_items["coal"] = 0
	smelter_items["sand"] = 0
	game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_smelter_no_items_efficiency_zero"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 0.0)
	proof["factory_smelter_no_items_no_power"] = bool(smelter_frame.get("should_consume_power", true)) == false
	smelter_items["coal"] = 5
	smelter_items["sand"] = 5
	game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_smelter_items_restored_efficiency_one"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 1.0)

	# --- while the team cheats, the live loop skips consumption
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945):
	# the mixer's water stays put at full efficiency; uncheating
	# resumes the drain. ---
	var team_id: int = int(smelter_frame.get("team_id", -1))
	proof["factory_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	var water_before_cheat: float = float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0))
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_cheating_frames_true"] = bool(smelter_frame.get("cheating", false)) == true and bool(mixer_frame.get("cheating", false)) == true
	proof["factory_cheating_water_unchanged"] = is_equal_approx(float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0)), water_before_cheat)
	proof["factory_cheating_efficiency_one"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(mixer_frame.get("efficiency", -1.0)), 1.0)
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_uncheat_restores"] = bool(smelter_frame.get("cheating", true)) == false and bool(mixer_frame.get("cheating", true)) == false
	proof["factory_uncheat_water_drops"] = is_equal_approx(float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0)), water_before_cheat - 4.0 * 0.2)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("FactoryConsumerBindingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
