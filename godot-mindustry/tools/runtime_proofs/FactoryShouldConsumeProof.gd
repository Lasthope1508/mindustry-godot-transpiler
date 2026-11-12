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
	proof["factory_electrolyzer_is_generic_crafter"] = String(blocks_by_id["electrolyzer"].implementation) == "GenericCrafter"
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog["liquid_id_by_name"]
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))

	# --- the registry captures the outputs shouldConsume reads: the
	# smelter's singular outputItem (silicon 1, itemCapacity 10,
	# liquidCapacity 10.0, the Block.init default), the mixer's
	# singular outputLiquid (cryofluid 0.2, its own liquidCapacity
	# 36f, Blocks.java:1180), and the electrolyzer's
	# LiquidStack.with pair (ozone + hydrogen, liquidCapacity 50f,
	# Blocks.java:1365). ---
	var smelter_properties: Dictionary = blocks_by_id["silicon-smelter"].properties
	var mixer_properties: Dictionary = blocks_by_id["cryofluid-mixer"].properties
	var electrolyzer_properties: Dictionary = blocks_by_id["electrolyzer"].properties
	proof["factory_smelter_registry_outputs"] = Array(smelter_properties.get("outputItems", [])).size() == 1 and str(Array(smelter_properties.get("outputItems", []))[0].get("item", "")) == "silicon" and int(Array(smelter_properties.get("outputItems", []))[0].get("amount", -1)) == 1 and int(smelter_properties.get("itemCapacity", -1)) == 10 and is_equal_approx(float(smelter_properties.get("liquidCapacity", -1.0)), 10.0)
	proof["factory_mixer_registry_outputs"] = Array(mixer_properties.get("outputLiquids", [])).size() == 1 and str(Array(mixer_properties.get("outputLiquids", []))[0].get("liquid", "")) == "cryofluid" and is_equal_approx(float(Array(mixer_properties.get("outputLiquids", []))[0].get("amount", -1.0)), 0.2) and is_equal_approx(float(mixer_properties.get("liquidCapacity", -1.0)), 36.0)
	var electrolyzer_outputs: Array = electrolyzer_properties.get("outputLiquids", [])
	proof["factory_electrolyzer_registry_outputs"] = electrolyzer_outputs.size() == 2 and str(electrolyzer_outputs[0].get("liquid", "")) == "ozone" and str(electrolyzer_outputs[1].get("liquid", "")) == "hydrogen" and is_equal_approx(float(electrolyzer_properties.get("liquidCapacity", -1.0)), 50.0)

	# --- the three factories are placed live, and the N2110 frame is
	# bound ON PLACEMENT (Block.newBuilding(), Block.java:1002). ---
	var smelter_cell := Vector2i(30, 7)
	var mixer_cell := Vector2i(35, 7)
	var electrolyzer_cell := Vector2i(40, 7)
	var smelter := Sprite2D.new()
	game.add_child(smelter)
	game.call("record_placed_block", smelter, blocks_by_id["silicon-smelter"], smelter_cell)
	var mixer := Sprite2D.new()
	game.add_child(mixer)
	game.call("record_placed_block", mixer, blocks_by_id["cryofluid-mixer"], mixer_cell)
	var electrolyzer := Sprite2D.new()
	game.add_child(electrolyzer)
	game.call("record_placed_block", electrolyzer, blocks_by_id["electrolyzer"], electrolyzer_cell)
	# The scene needs power since N2145: the factory tick driver
	# reads the live power.status (ConsumePower.efficiency,
	# ConsumePower.java:39, `return build.power.status;`), and
	# the live loop's graph update stamps 0.0 when no producer
	# feeds the graph (PowerGraph.java:203, coverage 0), so an
	# unpowered factory ticks at efficiency 0 no matter what
	# shouldConsume says. The campaign slice already carries 19
	# other consumers, so one RTG (4.5) cannot cover the 2.5 the
	# three factories need plus the scene's own draw; a thorium
	# reactor (powerProduction 15.0, no fuel in the port's
	# producer model) covers the whole graph, so the shouldConsume
	# gating below is isolated from power.
	var reactor_cell := Vector2i(45, 7)
	var reactor := Sprite2D.new()
	game.add_child(reactor)
	game.call("record_placed_block", reactor, blocks_by_id["thorium-reactor"], reactor_cell)
	proof["factory_smelter_frame_bound_on_placement"] = smelter.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	proof["factory_mixer_frame_bound_on_placement"] = mixer.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	proof["factory_electrolyzer_frame_bound_on_placement"] = electrolyzer.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- shouldConsume directly: the smelter's output item blocks
	# when the held silicon plus one output would exceed
	# itemCapacity (GenericCrafter.java:205), and a disabled build
	# never consumes (`return enabled;`, GenericCrafter.java:230);
	# a null block has no outputs, so nothing blocks it. ---
	var smelter_frame: Dictionary = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_frame["items"] = {"coal": 5, "sand": 5, "silicon": 9}
	var room: Dictionary = factory_build_state.source_factory_should_consume_state(smelter_frame, blocks_by_id["silicon-smelter"], {}, liquid_id_by_name)
	proof["factory_smelter_room_for_output"] = bool(room.get("should_consume", false)) == true and bool(room.get("item_blocked", true)) == false
	smelter_frame["items"] = {"coal": 5, "sand": 5, "silicon": 10}
	var full: Dictionary = factory_build_state.source_factory_should_consume_state(smelter_frame, blocks_by_id["silicon-smelter"], {}, liquid_id_by_name)
	proof["factory_smelter_output_full_blocks"] = bool(full.get("should_consume", true)) == false and bool(full.get("item_blocked", false)) == true
	smelter_frame["items"] = {"coal": 5, "sand": 5, "silicon": 0}
	smelter_frame["enabled"] = false
	var disabled: Dictionary = factory_build_state.source_factory_should_consume_state(smelter_frame, blocks_by_id["silicon-smelter"], {}, liquid_id_by_name)
	proof["factory_smelter_disabled_blocks"] = bool(disabled.get("should_consume", true)) == false
	smelter_frame["enabled"] = true
	var null_block: Dictionary = factory_build_state.source_factory_should_consume_state(smelter_frame, null, {}, liquid_id_by_name)
	proof["factory_null_block_consumes"] = bool(null_block.get("should_consume", false)) == true

	# --- shouldConsume directly: the mixer's output liquid blocks
	# only when it is full (GenericCrafter.java:216, liquidCapacity
	# - 0.001f); with dumpExtraLiquid (the default true) a single
	# full liquid still leaves room unless every output liquid is
	# full (`if(allFull){`, GenericCrafter.java:226), while
	# ignoreLiquidFullness skips the liquid check entirely
	# (GenericCrafter.java:212). ---
	var mixer_frame: Dictionary = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["items"] = {"titanium": 5}
	var mixer_empty: Dictionary = factory_build_state.source_factory_should_consume_state(mixer_frame, blocks_by_id["cryofluid-mixer"], {cryofluid_id: 0.0}, liquid_id_by_name)
	proof["factory_mixer_liquid_room"] = bool(mixer_empty.get("should_consume", false)) == true and bool(mixer_empty.get("all_liquids_full", true)) == false
	var mixer_partial: Dictionary = factory_build_state.source_factory_should_consume_state(mixer_frame, blocks_by_id["cryofluid-mixer"], {cryofluid_id: 35.0}, liquid_id_by_name)
	proof["factory_mixer_liquid_room_partial"] = bool(mixer_partial.get("should_consume", false)) == true and bool(mixer_partial.get("all_liquids_full", true)) == false
	var mixer_full: Dictionary = factory_build_state.source_factory_should_consume_state(mixer_frame, blocks_by_id["cryofluid-mixer"], {cryofluid_id: 36.0}, liquid_id_by_name)
	proof["factory_mixer_all_liquids_full_blocks"] = bool(mixer_full.get("should_consume", true)) == false and bool(mixer_full.get("all_liquids_full", false)) == true and bool(mixer_full.get("liquid_blocked", false)) == true
	mixer_properties["ignoreLiquidFullness"] = true
	var mixer_ignored: Dictionary = factory_build_state.source_factory_should_consume_state(mixer_frame, blocks_by_id["cryofluid-mixer"], {cryofluid_id: 36.0}, liquid_id_by_name)
	proof["factory_mixer_ignore_fullness_consumes"] = bool(mixer_ignored.get("should_consume", false)) == true and bool(mixer_ignored.get("all_liquids_full", true)) == false
	mixer_properties.erase("ignoreLiquidFullness")

	# --- the electrolyzer's two output liquids separate the two
	# blocking branches: with dumpExtraLiquid (default true) one
	# full liquid still consumes; with it false, that one full
	# liquid blocks at once (`if(!dumpExtraLiquid){`,
	# GenericCrafter.java:217); both full blocks either way. ---
	var electrolyzer_frame: Dictionary = electrolyzer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var electrolyzer_one_full: Dictionary = factory_build_state.source_factory_should_consume_state(electrolyzer_frame, blocks_by_id["electrolyzer"], {ozone_id: 50.0, hydrogen_id: 0.0}, liquid_id_by_name)
	proof["factory_electrolyzer_one_liquid_full_still_consumes"] = bool(electrolyzer_one_full.get("should_consume", false)) == true and bool(electrolyzer_one_full.get("all_liquids_full", true)) == false
	electrolyzer_properties["dumpExtraLiquid"] = false
	var electrolyzer_dump_false: Dictionary = factory_build_state.source_factory_should_consume_state(electrolyzer_frame, blocks_by_id["electrolyzer"], {ozone_id: 50.0, hydrogen_id: 0.0}, liquid_id_by_name)
	proof["factory_electrolyzer_one_liquid_full_dump_false_blocks"] = bool(electrolyzer_dump_false.get("should_consume", true)) == false and bool(electrolyzer_dump_false.get("liquid_blocked", false)) == true and bool(electrolyzer_dump_false.get("all_liquids_full", true)) == false
	var electrolyzer_both_full: Dictionary = factory_build_state.source_factory_should_consume_state(electrolyzer_frame, blocks_by_id["electrolyzer"], {ozone_id: 50.0, hydrogen_id: 50.0}, liquid_id_by_name)
	proof["factory_electrolyzer_all_liquids_full_blocks"] = bool(electrolyzer_both_full.get("should_consume", true)) == false and bool(electrolyzer_both_full.get("all_liquids_full", false)) == true
	electrolyzer_properties.erase("dumpExtraLiquid")

	# --- the live-loop tick driver gates efficiency on
	# shouldConsume: a smelter holding a full silicon output ticks
	# at efficiency 0, and room restores 1.0; a mixer with a full
	# cryofluid output ticks at 0 with its water untouched, and
	# room restores the drain (0.2 per tick, ConsumeLiquid.update,
	# ConsumeLiquid.java:38-40). ---
	var mixer_module: Dictionary = mixer.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(mixer_module, water_id, 10.0, [])
	liquid_module_state.source_add_state(mixer_module, cryofluid_id, 36.0, [])
	# The disabled check above left the smelter's silicon at 0; put
	# the full output back so the live tick sees it blocked.
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	smelter_frame["items"] = {"coal": 5, "sand": 5, "silicon": 10}
	var ticked: Dictionary = factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["factory_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", smelter_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", mixer_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", electrolyzer_cell))
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_smelter_output_full_efficiency_zero"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 0.0)
	proof["factory_mixer_liquid_full_efficiency_zero"] = is_equal_approx(float(mixer_frame.get("efficiency", -1.0)), 0.0)
	var water_while_blocked: float = float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0))
	game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_mixer_blocked_water_unchanged"] = is_equal_approx(float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0)), water_while_blocked)
	# The reactor covers the graph (15.0 produced vs ~8.5 needed
	# across the scene's 22 consumers), so the live loop stamps
	# power_status 1.0 on the factories -- the restore below is a
	# shouldConsume effect, not a power one (N2145).
	proof["factory_reactor_powers_scene"] = is_equal_approx(float(smelter_frame.get("power_status", -1.0)), 1.0) and is_equal_approx(float(mixer_frame.get("power_status", -1.0)), 1.0)
	var smelter_items: Dictionary = smelter_frame.get("items", {})
	smelter_items["silicon"] = 5
	var mixer_liquids: Array = mixer_module["liquids"]
	mixer_liquids[cryofluid_id] = 0.0
	game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_smelter_room_restores_efficiency_one"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 1.0)
	proof["factory_mixer_room_restores_efficiency_one"] = is_equal_approx(float(mixer_frame.get("efficiency", -1.0)), 1.0)
	var water_after_restore: float = float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0))
	game.call("simulate_factory", 1.0 / 60.0)
	proof["factory_mixer_water_drops_when_consuming"] = is_equal_approx(float(liquid_module_state.source_get_state(mixer_module, water_id).get("amount", -1.0)), water_after_restore - 0.2)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("FactoryShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
