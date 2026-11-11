extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const mindustry_time := preload("res://src/runtime/Time.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Team.activateUnitFactories() is pure over the rules and the
	# live tick (Team.java:127-129, Rules.java:315-317): the global
	# delay (Rules.java:93, default 0f) plus the team's own
	# (Rules.java:351, default 0f), against state.tick (time * 60).
	# The proof process starts at time 0, so the default delay is
	# already passed; a 600-tick delay blocks until the clock is
	# advanced ten seconds, then passes exactly at tick 600.
	var activate_default: Dictionary = unit_factory_build_state.source_unit_factory_activate_state({}, 1)
	proof["should_consume_activate_default_true"] = bool(activate_default.get("activate_unit_factories", false)) == true and is_equal_approx(float(activate_default.get("unit_activation_delay", -1.0)), 0.0) and is_equal_approx(float(activate_default.get("tick", -1.0)), 0.0)
	var activate_delayed: Dictionary = unit_factory_build_state.source_unit_factory_activate_state({"unitFactoryActivationDelay": 600.0}, 1)
	proof["should_consume_activate_delay_blocks"] = bool(activate_delayed.get("activate_unit_factories", true)) == false and is_equal_approx(float(activate_delayed.get("unit_activation_delay", -1.0)), 600.0)
	var activate_team: Dictionary = unit_factory_build_state.source_unit_factory_activate_state({"unitFactoryActivationDelay": 100.0, "teams": {1: {"unitFactoryActivationDelay": 500.0}}}, 1)
	proof["should_consume_activate_delay_team"] = bool(activate_team.get("activate_unit_factories", true)) == false and is_equal_approx(float(activate_team.get("unit_activation_delay", -1.0)), 600.0)
	mindustry_time.update(10.0)
	var activate_passed: Dictionary = unit_factory_build_state.source_unit_factory_activate_state({"unitFactoryActivationDelay": 600.0}, 1)
	proof["should_consume_activate_delay_passed"] = bool(activate_passed.get("activate_unit_factories", false)) == true and is_equal_approx(float(activate_passed.get("tick", -1.0)), 600.0)

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
	var reconstructor_block = blocks_by_id["additive-reconstructor"]
	var factory_block = blocks_by_id["ground-factory"]
	var assembler_block = blocks_by_id["tank-assembler"]

	# --- ReconstructorBuild.hasUpgrade() (Reconstructor.java:388-391):
	# the held unit upgrades when the block's upgrade map holds a
	# pair for it, the upgrade target is unlocked for this team (or
	# the team is AI-controlled), and the held unit is not banned.
	# The additive-reconstructor upgrades dagger to mace
	# (Blocks.java:6311-6319); fortress has no pair there.
	var upgrade_dagger: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "dagger", {}, 1)
	proof["should_consume_upgrade_dagger_to_mace"] = bool(upgrade_dagger.get("has_upgrade", false)) == true and str(upgrade_dagger.get("upgrade_unit", "")) == "mace" and bool(upgrade_dagger.get("unlocked", false)) == true and bool(upgrade_dagger.get("is_ai", true)) == false and bool(upgrade_dagger.get("banned", true)) == false
	var upgrade_fortress: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "fortress", {}, 1)
	proof["should_consume_upgrade_no_pair"] = bool(upgrade_fortress.get("has_upgrade", true)) == false and str(upgrade_fortress.get("upgrade_unit", "x")) == ""
	var upgrade_banned: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "dagger", {"bannedUnits": ["dagger"]}, 1)
	proof["should_consume_upgrade_banned"] = bool(upgrade_banned.get("has_upgrade", true)) == false and bool(upgrade_banned.get("banned", false)) == true
	var upgrade_whitelist: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "dagger", {"unitWhitelist": true, "bannedUnits": []}, 1)
	proof["should_consume_upgrade_whitelist"] = bool(upgrade_whitelist.get("has_upgrade", true)) == false and bool(upgrade_whitelist.get("banned", false)) == true
	var upgrade_locked: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "dagger", {"sector": {"id": "x"}, "researched": []}, 1)
	proof["should_consume_upgrade_campaign_locked"] = bool(upgrade_locked.get("has_upgrade", true)) == false and bool(upgrade_locked.get("unlocked", true)) == false and bool(upgrade_locked.get("is_ai", true)) == false
	var upgrade_researched: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(reconstructor_block, "dagger", {"sector": {"id": "x"}, "researched": ["mace"]}, 1)
	proof["should_consume_upgrade_campaign_researched"] = bool(upgrade_researched.get("has_upgrade", false)) == true and bool(upgrade_researched.get("unlocked", false)) == true
	var upgrade_null: Dictionary = unit_factory_build_state.source_unit_factory_has_upgrade_state(null, "dagger", {}, 1)
	proof["should_consume_upgrade_null_block"] = bool(upgrade_null.get("has_upgrade", true)) == false and str(upgrade_null.get("upgrade_unit", "x")) == ""

	# --- UnitAssemblerBuild.plan() (UnitAssembler.java:386-389):
	# the current tier's plan, clamped to the last plan. The
	# tank-assembler builds vanquish (60f * 50f) at tier 0 and
	# conquer (60f * 60f * 3f) at tier 1 (Blocks.java:6521-6531);
	# the vanilla plans carry no itemReq/liquidReq.
	var plan_zero: Dictionary = unit_factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 0)
	proof["should_consume_assembler_plan_tier_zero"] = str(plan_zero.get("unit", "")) == "vanquish" and is_equal_approx(float(plan_zero.get("time", -1.0)), 3000.0) and Array(plan_zero.get("requirements", [])).size() == 2 and str(Array(plan_zero.get("requirements", []))[0].get("item", "")) == "stell" and int(Array(plan_zero.get("requirements", []))[0].get("amount", -1)) == 4 and str(Array(plan_zero.get("requirements", []))[1].get("item", "")) == "tungsten-wall-large" and int(Array(plan_zero.get("requirements", []))[1].get("amount", -1)) == 10 and Array(plan_zero.get("item_req", ["x"])).is_empty() and Array(plan_zero.get("liquid_req", ["x"])).is_empty()
	var plan_one: Dictionary = unit_factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 1)
	proof["should_consume_assembler_plan_tier_one"] = str(plan_one.get("unit", "")) == "conquer" and is_equal_approx(float(plan_one.get("time", -1.0)), 10800.0)
	var plan_clamped: Dictionary = unit_factory_build_state.source_unit_factory_assembler_plan_state(assembler_block, 99)
	proof["should_consume_assembler_plan_clamped"] = str(plan_clamped.get("unit", "")) == "conquer"
	var plan_null: Dictionary = unit_factory_build_state.source_unit_factory_assembler_plan_state(null, 0)
	proof["should_consume_assembler_plan_null_block"] = not plan_null.has("unit")

	# --- ConsumeItemDynamic.efficiency for the assembler's consItem
	# (ConsumeItemDynamic.java:57-59, UnitAssembler.java:159): the
	# plan's itemReq at the unitCost multiplier. Vanilla plans carry
	# no itemReq, so the check is over ItemStack.empty and the
	# efficiency is 1.0; a plan with itemReq gates on the held
	# stacks.
	var eff_empty: Dictionary = unit_factory_build_state.source_unit_factory_assembler_cons_item_efficiency_state({"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {}}, {"item_req": []})
	proof["should_consume_cons_item_empty_req_one"] = is_equal_approx(float(eff_empty.get("item_efficiency", -1.0)), 1.0)
	var eff_held: Dictionary = unit_factory_build_state.source_unit_factory_assembler_cons_item_efficiency_state({"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {}, "items": {"silicon": 10}}, {"item_req": [{"item": "silicon", "amount": 10}]})
	proof["should_consume_cons_item_held_one"] = is_equal_approx(float(eff_held.get("item_efficiency", -1.0)), 1.0)
	var eff_short: Dictionary = unit_factory_build_state.source_unit_factory_assembler_cons_item_efficiency_state({"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {}, "items": {"silicon": 9}}, {"item_req": [{"item": "silicon", "amount": 10}]})
	proof["should_consume_cons_item_short_zero"] = is_equal_approx(float(eff_short.get("item_efficiency", -1.0)), 0.0)
	var eff_cost: Dictionary = unit_factory_build_state.source_unit_factory_assembler_cons_item_efficiency_state({"block_implementation": "UnitAssembler", "team_id": 1, "rules_state": {"unitCostMultiplier": 2.0}, "items": {"silicon": 10}}, {"item_req": [{"item": "silicon", "amount": 10}]})
	proof["should_consume_cons_item_unit_cost_zero"] = is_equal_approx(float(eff_cost.get("item_efficiency", -1.0)), 0.0)

	# --- the dispatcher itself, direct calls with no game (the
	# default rules activate from tick 0, so only the per-class
	# terms decide here).
	var factory_no_plan: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitFactory", "current_plan": -1}, factory_block, null)
	proof["should_consume_factory_no_plan_false"] = bool(factory_no_plan.get("should_consume", true)) == false and int(factory_no_plan.get("current_plan", 0)) == -1
	var factory_plan: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitFactory", "current_plan": 0}, factory_block, null)
	proof["should_consume_factory_plan_true"] = bool(factory_plan.get("should_consume", false)) == true
	var factory_payload: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitFactory", "current_plan": 0, "payload": {"unit": "dagger"}}, factory_block, null)
	proof["should_consume_factory_payload_false"] = bool(factory_payload.get("should_consume", true)) == false and bool(factory_payload.get("has_payload", false)) == true
	var factory_disabled: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitFactory", "current_plan": 0, "enabled": false}, factory_block, null)
	proof["should_consume_factory_disabled_false"] = bool(factory_disabled.get("should_consume", true)) == false and bool(factory_disabled.get("enabled", true)) == false
	var recon_no_payload: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "Reconstructor"}, reconstructor_block, null)
	proof["should_consume_reconstructor_no_payload_false"] = bool(recon_no_payload.get("should_consume", true)) == false and bool(recon_no_payload.get("constructing", true)) == false
	var recon_payload: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "Reconstructor", "payload": {"unit": "dagger"}}, reconstructor_block, null)
	proof["should_consume_reconstructor_payload_true"] = bool(recon_payload.get("should_consume", false)) == true and bool(recon_payload.get("constructing", false)) == true and bool(recon_payload.get("has_upgrade", false)) == true and str(recon_payload.get("upgrade_unit", "")) == "mace"
	var recon_bad_payload: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "Reconstructor", "payload": {"unit": "fortress"}}, reconstructor_block, null)
	proof["should_consume_reconstructor_bad_payload_false"] = bool(recon_bad_payload.get("should_consume", true)) == false
	var assembler_default: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitAssembler", "current_tier": 0}, assembler_block, null)
	proof["should_consume_assembler_default_true"] = bool(assembler_default.get("should_consume", false)) == true and str(assembler_default.get("plan_unit", "")) == "vanquish" and is_equal_approx(float(assembler_default.get("item_efficiency", -1.0)), 1.0)
	var assembler_occupied: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitAssembler", "current_tier": 0, "was_occupied": true}, assembler_block, null)
	proof["should_consume_assembler_occupied_false"] = bool(assembler_occupied.get("should_consume", true)) == false and bool(assembler_occupied.get("was_occupied", false)) == true
	var assembler_no_create: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitAssembler", "current_tier": 0, "can_create": false}, assembler_block, null)
	proof["should_consume_assembler_no_create_false"] = bool(assembler_no_create.get("should_consume", true)) == false and bool(assembler_no_create.get("can_create", true)) == false
	var assembler_no_payload_eff: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({"block_implementation": "UnitAssembler", "current_tier": 0, "payload_efficiency": 0.0}, assembler_block, null)
	proof["should_consume_assembler_no_payload_eff_false"] = bool(assembler_no_payload_eff.get("should_consume", true)) == false and is_equal_approx(float(assembler_no_payload_eff.get("payload_efficiency", -1.0)), 0.0)
	var null_block: Dictionary = unit_factory_build_state.source_unit_factory_should_consume_state({}, null, null)
	proof["should_consume_null_block_false"] = bool(null_block.get("should_consume", true)) == false

	# --- the live loop: the three factories are placed live and the
	# dispatcher gates their efficiency through simulate_factory.
	# The ground factory runs its dagger plan (silicon 10 + lead
	# 10); the reconstructor holds a dagger payload (constructing);
	# the assembler holds cyanogen for its liquid row.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var cyanogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("cyanogen", -1))
	var factory_cell := Vector2i(30, 7)
	var reconstructor_cell := Vector2i(35, 7)
	var assembler_cell := Vector2i(40, 7)
	var factory := Sprite2D.new()
	game.add_child(factory)
	game.call("record_placed_block", factory, factory_block, factory_cell)
	var reconstructor := Sprite2D.new()
	game.add_child(reconstructor)
	game.call("record_placed_block", reconstructor, reconstructor_block, reconstructor_cell)
	var assembler := Sprite2D.new()
	game.add_child(assembler)
	game.call("record_placed_block", assembler, assembler_block, assembler_cell)
	var factory_frame: Dictionary = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	factory_frame["current_plan"] = 0
	factory_frame["items"] = {"silicon": 10, "lead": 10}
	var reconstructor_frame: Dictionary = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	reconstructor_frame["items"] = {"silicon": 40, "graphite": 40}
	reconstructor_frame["payload"] = {"unit": "dagger"}
	var assembler_frame: Dictionary = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	var assembler_module: Dictionary = assembler.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(assembler_module, cyanogen_id, 10.0, [])
	var ticked: Dictionary = unit_factory_build_state.source_unit_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["should_consume_live_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	factory_frame = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_factory_efficiency_one"] = is_equal_approx(float(factory_frame.get("efficiency", -1.0)), 1.0)
	proof["should_consume_live_reconstructor_efficiency_one"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0)
	proof["should_consume_live_assembler_efficiency_one"] = is_equal_approx(float(assembler_frame.get("efficiency", -1.0)), 1.0)

	# --- dropping the reconstructor's payload stops its consumption
	# (constructing goes false); restoring it resumes. Dropping the
	# factory's plan stops it the same way, and occupying the
	# assembler's spawn stops it until the spawn clears.
	reconstructor_frame["payload"] = null
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_reconstructor_no_payload_zero"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 0.0)
	reconstructor_frame["payload"] = {"unit": "dagger"}
	game.call("simulate_factory", 1.0 / 60.0)
	reconstructor_frame = reconstructor.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_reconstructor_payload_restored_one"] = is_equal_approx(float(reconstructor_frame.get("efficiency", -1.0)), 1.0)
	factory_frame["current_plan"] = -1
	game.call("simulate_factory", 1.0 / 60.0)
	factory_frame = factory.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_factory_no_plan_zero"] = is_equal_approx(float(factory_frame.get("efficiency", -1.0)), 0.0)
	assembler_frame["was_occupied"] = true
	game.call("simulate_factory", 1.0 / 60.0)
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_assembler_occupied_zero"] = is_equal_approx(float(assembler_frame.get("efficiency", -1.0)), 0.0)
	assembler_frame["was_occupied"] = false
	game.call("simulate_factory", 1.0 / 60.0)
	assembler_frame = assembler.get_meta(unit_factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["should_consume_live_assembler_unoccupied_one"] = is_equal_approx(float(assembler_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06UnitFactoryShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
