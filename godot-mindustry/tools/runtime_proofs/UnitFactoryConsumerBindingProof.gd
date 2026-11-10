extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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
	proof["unit_factory_is_unit_factory"] = String(blocks_by_id["ground-factory"].implementation) == "UnitFactory"
	proof["unit_reconstructor_is_reconstructor"] = String(blocks_by_id["additive-reconstructor"].implementation) == "Reconstructor"
	proof["unit_assembler_is_unit_assembler"] = String(blocks_by_id["tank-assembler"].implementation) == "UnitAssembler"
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))

	# --- the three factories are placed live, and the N2109 frame is
	# bound ON PLACEMENT (Block.newBuilding(), Block.java:1002). ---
	var factory_cell := Vector2i(30, 7)
	var reconstructor_cell := Vector2i(35, 7)
	var assembler_cell := Vector2i(40, 7)
	var factory := Sprite2D.new()
	game.add_child(factory)
	game.call("record_placed_block", factory, blocks_by_id["ground-factory"], factory_cell)
	var reconstructor := Sprite2D.new()
	game.add_child(reconstructor)
	game.call("record_placed_block", reconstructor, blocks_by_id["additive-reconstructor"], reconstructor_cell)
	var assembler := Sprite2D.new()
	game.add_child(assembler)
	game.call("record_placed_block", assembler, blocks_by_id["tank-assembler"], assembler_cell)
	proof["unit_factory_frame_bound_on_placement"] = factory.has_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)
	proof["unit_reconstructor_frame_bound_on_placement"] = reconstructor.has_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)
	proof["unit_assembler_frame_bound_on_placement"] = assembler.has_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)

	# --- the current plan's requirements (UnitFactory.java:207-218,
	# UnitPlan holds the unit, the build time and the ItemStack[]
	# requirements; the registry captures the block's plans as
	# unitPlans). The ground-factory's dagger plan is silicon 10 +
	# lead 10 over 900 ticks (Blocks.java); no plan, or an index
	# outside the plans, has no requirements (UnitFactory.java:84,
	# ItemStack.empty). ---
	var dagger_plan: Dictionary = unit_factory_build_state.source_unit_factory_plan_requirements_state(blocks_by_id["ground-factory"], 0)
	proof["unit_factory_plan_dagger"] = String(dagger_plan.get("unit", "")) == "dagger" and is_equal_approx(float(dagger_plan.get("time", -1.0)), 900.0) and Array(dagger_plan.get("items", [])).size() == 2 and str(Array(dagger_plan.get("items", []))[0].get("item", "")) == "silicon" and int(Array(dagger_plan.get("items", []))[0].get("amount", -1)) == 10 and str(Array(dagger_plan.get("items", []))[1].get("item", "")) == "lead" and int(Array(dagger_plan.get("items", []))[1].get("amount", -1)) == 10
	var null_plan: Dictionary = unit_factory_build_state.source_unit_factory_plan_requirements_state(null, 0)
	proof["unit_factory_plan_null_block_none"] = not null_plan.has("unit")
	var minus_one_plan: Dictionary = unit_factory_build_state.source_unit_factory_plan_requirements_state(blocks_by_id["ground-factory"], -1)
	proof["unit_factory_plan_minus_one_none"] = not minus_one_plan.has("unit")
	var past_end_plan: Dictionary = unit_factory_build_state.source_unit_factory_plan_requirements_state(blocks_by_id["ground-factory"], 99)
	proof["unit_factory_plan_out_of_range_none"] = not past_end_plan.has("unit")

	# --- the binding itself: one RuntimeConsumer actor per consume
	# row (the drill model, N2097/N2100) plus one per requirement
	# of the frame's current plan (the ConsumeItemDynamic,
	# UnitFactory.java:84). The ground-factory binds its dagger
	# plan (silicon 10 + lead 10) and nothing without a plan; the
	# additive-reconstructor consumes silicon 40 + graphite 40
	# (Blocks.java:6307); the tank-assembler consumes cyanogen 0.15
	# per tick (Blocks.java:6537). ---
	var factory_frame: Dictionary = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	factory_frame["current_plan"] = 0
	factory_frame["items"] = {"silicon": 10, "lead": 10}
	var factory_bind: Dictionary = unit_factory_build_state.source_bind_consumer_state(factory_frame, blocks_by_id["ground-factory"], catalog, {})
	proof["unit_factory_bind_two_plan_actors"] = bool(factory_bind.get("bound", false)) == true and Array(factory_bind.get("consumers", [])).size() == 2 and Array(factory_bind.get("rows", [])).size() == 2 and str(Array(factory_bind.get("rows", []))[0].get("item", "")) == "silicon" and str(Array(factory_bind.get("rows", []))[1].get("item", "")) == "lead"
	var factory_rebind: Dictionary = unit_factory_build_state.source_bind_consumer_state(factory_frame, blocks_by_id["ground-factory"], catalog, {})
	proof["unit_factory_rebind_no_duplicate"] = bool(factory_rebind.get("bound", true)) == false and Array(factory_frame.get("consumers", [])).size() == 2
	var no_plan_frame: Dictionary = {}
	var no_plan_bind: Dictionary = unit_factory_build_state.source_bind_consumer_state(no_plan_frame, blocks_by_id["ground-factory"], catalog, {})
	proof["unit_factory_no_plan_bind_none"] = bool(no_plan_bind.get("bound", true)) == false and Array(no_plan_bind.get("consumers", [])).is_empty() and Array(no_plan_bind.get("rows", [])).is_empty()
	var reconstructor_frame: Dictionary = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	reconstructor_frame["items"] = {"silicon": 40, "graphite": 40}
	var reconstructor_bind: Dictionary = unit_factory_build_state.source_bind_consumer_state(reconstructor_frame, blocks_by_id["additive-reconstructor"], catalog, {})
	proof["unit_reconstructor_bind_two_actors"] = bool(reconstructor_bind.get("bound", false)) == true and Array(reconstructor_bind.get("consumers", [])).size() == 2 and Array(reconstructor_bind.get("rows", [])).size() == 2 and str(Array(reconstructor_bind.get("rows", []))[0].get("item", "")) == "silicon" and str(Array(reconstructor_bind.get("rows", []))[1].get("item", "")) == "graphite"
	var reconstructor_rebind: Dictionary = unit_factory_build_state.source_bind_consumer_state(reconstructor_frame, blocks_by_id["additive-reconstructor"], catalog, {})
	proof["unit_reconstructor_rebind_no_duplicate"] = bool(reconstructor_rebind.get("bound", true)) == false and Array(reconstructor_frame.get("consumers", [])).size() == 2
	var assembler_frame: Dictionary = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	var assembler_module: Dictionary = assembler.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(assembler_module, cyanogen_id, 10.0, [])
	var assembler_bind: Dictionary = unit_factory_build_state.source_bind_consumer_state(assembler_frame, blocks_by_id["tank-assembler"], catalog, assembler_module)
	proof["unit_assembler_bind_one_actor"] = bool(assembler_bind.get("bound", false)) == true and Array(assembler_bind.get("consumers", [])).size() == 1 and Array(assembler_bind.get("rows", [])).size() == 1 and int(Array(assembler_bind.get("rows", []))[0].get("liquid", -1)) == cyanogen_id
	var assembler_rebind: Dictionary = unit_factory_build_state.source_bind_consumer_state(assembler_frame, blocks_by_id["tank-assembler"], catalog, assembler_module)
	proof["unit_assembler_rebind_no_duplicate"] = bool(assembler_rebind.get("bound", true)) == false and Array(assembler_frame.get("consumers", [])).size() == 1
	var bare_frame: Dictionary = {}
	var null_bind: Dictionary = unit_factory_build_state.source_bind_consumer_state(bare_frame, null, catalog, {})
	proof["unit_null_block_bind_none"] = bool(null_bind.get("bound", true)) == false and Array(null_bind.get("consumers", [])).is_empty() and Array(null_bind.get("rows", [])).is_empty()

	# --- reinitialize (Block.reinitializeConsumers(),
	# Block.java:1481-1497, the N2116 pattern): a changed plan
	# rebinds from the new plan's requirements while the held items
	# stay; a replaced block drops the old actors, clears the item
	# and liquid stores for the fresh Building, and rebinds from
	# the new block's rows; the same block and plan takes the normal
	# once-only bind path. ---
	var plan_frame: Dictionary = {"current_plan": 0, "items": {"silicon": 10, "lead": 10}}
	unit_factory_build_state.source_bind_consumer_state(plan_frame, blocks_by_id["ground-factory"], catalog, {})
	plan_frame["current_plan"] = 1
	var plan_reinit: Dictionary = unit_factory_build_state.source_unit_factory_reinitialize_consumers_state(plan_frame, blocks_by_id["ground-factory"], catalog, {})
	proof["unit_plan_change_reinitializes"] = bool(plan_reinit.get("reinitialized", false)) == true and bool(plan_reinit.get("bound", false)) == true and Array(plan_reinit.get("consumers", [])).size() == 2 and Array(plan_reinit.get("rows", [])).size() == 2 and str(Array(plan_reinit.get("rows", []))[0].get("item", "")) == "silicon" and int(Array(plan_reinit.get("rows", []))[0].get("amount", -1)) == 8 and str(Array(plan_reinit.get("rows", []))[1].get("item", "")) == "coal" and Dictionary(plan_frame.get("items", {})).get("silicon", -1) == 10 and Dictionary(plan_frame.get("items", {})).get("lead", -1) == 10
	var swap_frame: Dictionary = {"current_plan": 0, "items": {"silicon": 10, "lead": 10}}
	unit_factory_build_state.source_bind_consumer_state(swap_frame, blocks_by_id["ground-factory"], catalog, {})
	var swap_reinit: Dictionary = unit_factory_build_state.source_unit_factory_reinitialize_consumers_state(swap_frame, blocks_by_id["additive-reconstructor"], catalog, {})
	proof["unit_block_change_reinitializes"] = bool(swap_reinit.get("reinitialized", false)) == true and bool(swap_reinit.get("bound", false)) == true and Array(swap_reinit.get("consumers", [])).size() == 2 and str(Array(swap_reinit.get("rows", []))[0].get("item", "")) == "silicon" and int(Array(swap_reinit.get("rows", []))[0].get("amount", -1)) == 40 and str(Array(swap_reinit.get("rows", []))[1].get("item", "")) == "graphite" and Dictionary(swap_frame.get("items", {})).is_empty()
	var same_reinit: Dictionary = unit_factory_build_state.source_unit_factory_reinitialize_consumers_state(reconstructor_frame, blocks_by_id["additive-reconstructor"], catalog, {})
	proof["unit_reinitialize_same_block_noop"] = bool(same_reinit.get("reinitialized", true)) == false and bool(same_reinit.get("bound", true)) == false and Array(same_reinit.get("consumers", [])).size() == 2

	# --- the live-loop tick driver ticks all three, and the bound
	# actors run through updateConsumption every tick: the assembler
	# drains its cyanogen at the live rate (ConsumeLiquid.update,
	# ConsumeLiquid.java:38-40: amount * edelta * multiplier, 0.15
	# per tick at efficiency 1.0), while the item stacks stay put —
	# ConsumeItems has no update body (Consume.java:52), so items
	# leave only at unit completion via trigger (a later slice). ---
	var ticked: Dictionary = unit_factory_build_state.source_unit_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["unit_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", factory_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", reconstructor_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", assembler_cell))
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	factory_frame = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_factory_consumers_still_two"] = Array(factory_frame.get("consumers", [])).size() == 2
	proof["unit_reconstructor_consumers_still_two"] = Array(reconstructor_frame.get("consumers", [])).size() == 2
	proof["unit_assembler_consumers_still_one"] = Array(assembler_frame.get("consumers", [])).size() == 1
	proof["unit_factory_efficiency_one"] = is_equal_approx(float(factory_frame.get("efficiency", -1.0)), 1.0)
	proof["unit_reconstructor_efficiency_one"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0)
	proof["unit_assembler_efficiency_one"] = is_equal_approx(float(assembler_frame.get("efficiency", -1.0)), 1.0)
	proof["unit_factory_plan_items_unchanged"] = Dictionary(factory_frame.get("items", {})).get("silicon", -1) == 10 and Dictionary(factory_frame.get("items", {})).get("lead", -1) == 10
	proof["unit_reconstructor_items_unchanged"] = Dictionary(reconstructor_frame.get("items", {})).get("silicon", -1) == 40 and Dictionary(reconstructor_frame.get("items", {})).get("graphite", -1) == 40
	proof["unit_assembler_cyanogen_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(assembler_module, cyanogen_id).get("amount", -1.0)), 10.0 - 4.0 * 0.15)

	# --- the item actors gate efficiency: with the reconstructor's
	# items gone the first pass reads 0, so efficiency is 0 and the
	# building should not consume power; restoring them restores 1.0.
	# (The actors hold the frame's item module by reference, so the
	# proof empties the same dict in place.) ---
	var reconstructor_items: Dictionary = reconstructor_frame.get("items", {})
	reconstructor_items["silicon"] = 0
	reconstructor_items["graphite"] = 0
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_reconstructor_no_items_efficiency_zero"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 0.0)
	proof["unit_reconstructor_no_items_no_power"] = bool(reconstructor_frame.get("should_consume_power", true)) == false
	reconstructor_items["silicon"] = 40
	reconstructor_items["graphite"] = 40
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_reconstructor_items_restored_efficiency_one"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0)

	# --- the cost multiplier is Rules.unitCost for this family
	# (UnitFactory.java:109, Reconstructor.java:149,
	# UnitAssembler.java:175): with the team's unitCostMultiplier
	# at 2.0 the reconstructor's stacks cost amount * unitCost, so
	# 40 held against 80 required reads efficiency 0; restoring
	# 1.0 restores 1.0. ---
	var team_id: int = int(reconstructor_frame.get("team_id", -1))
	proof["unit_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"unitCostMultiplier": 2.0}
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_cost_multiplier_two_efficiency_zero"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 0.0)
	teams[team_id] = {"unitCostMultiplier": 1.0}
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_cost_multiplier_one_efficiency_one"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0)

	# --- while the team cheats, the live loop skips consumption
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945):
	# the assembler's cyanogen stays put at full efficiency;
	# uncheating resumes the drain. ---
	teams[team_id] = {"cheat": true}
	var cyanogen_before_cheat: float = float(liquid_module_state.source_get_state(assembler_module, cyanogen_id).get("amount", -1.0))
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	factory_frame = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_cheating_frames_true"] = bool(factory_frame.get("cheating", false)) == true and bool(reconstructor_frame.get("cheating", false)) == true and bool(assembler_frame.get("cheating", false)) == true
	proof["unit_cheating_cyanogen_unchanged"] = is_equal_approx(float(liquid_module_state.source_get_state(assembler_module, cyanogen_id).get("amount", -1.0)), cyanogen_before_cheat)
	proof["unit_cheating_efficiency_one"] = is_equal_approx(float(factory_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(assembler_frame.get("efficiency", -1.0)), 1.0)
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	factory_frame = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["unit_uncheat_restores"] = bool(factory_frame.get("cheating", true)) == false and bool(assembler_frame.get("cheating", true)) == false
	proof["unit_uncheat_cyanogen_drops"] = is_equal_approx(float(liquid_module_state.source_get_state(assembler_module, cyanogen_id).get("amount", -1.0)), cyanogen_before_cheat - 4.0 * 0.15)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("UnitFactoryConsumerBindingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
