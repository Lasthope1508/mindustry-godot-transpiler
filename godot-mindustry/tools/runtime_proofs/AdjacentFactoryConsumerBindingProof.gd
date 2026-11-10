extends Node

const main_scene := preload("res://scenes/Main.tscn")
const adjacent_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")
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
	proof["adjacent_separator_is_separator"] = String(blocks_by_id["separator"].implementation) == "Separator"
	proof["adjacent_disassembler_is_separator"] = String(blocks_by_id["disassembler"].implementation) == "Separator"
	proof["adjacent_incinerator_is_incinerator"] = String(blocks_by_id["incinerator"].implementation) == "Incinerator"
	proof["adjacent_crusher_is_wall_crafter"] = String(blocks_by_id["cliff-crusher"].implementation) == "WallCrafter"
	proof["adjacent_large_crusher_is_wall_crafter"] = String(blocks_by_id["large-cliff-crusher"].implementation) == "WallCrafter"
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var slag_id: int = int(liquid_catalog["liquid_id_by_name"].get("slag", -1))
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))

	# --- the five adjacent-family blocks are placed live, and the
	# N2114 frame is bound ON PLACEMENT (Block.newBuilding(),
	# Block.java:1002). ---
	var separator_cell := Vector2i(30, 7)
	var disassembler_cell := Vector2i(35, 7)
	var incinerator_cell := Vector2i(40, 7)
	var crusher_cell := Vector2i(42, 7)
	var large_crusher_cell := Vector2i(45, 7)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	var disassembler := Sprite2D.new()
	game.add_child(disassembler)
	game.call("record_placed_block", disassembler, blocks_by_id["disassembler"], disassembler_cell)
	var incinerator := Sprite2D.new()
	game.add_child(incinerator)
	game.call("record_placed_block", incinerator, blocks_by_id["incinerator"], incinerator_cell)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	var large_crusher := Sprite2D.new()
	game.add_child(large_crusher)
	game.call("record_placed_block", large_crusher, blocks_by_id["large-cliff-crusher"], large_crusher_cell)
	proof["adjacent_separator_frame_bound_on_placement"] = separator.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	proof["adjacent_disassembler_frame_bound_on_placement"] = disassembler.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	proof["adjacent_incinerator_frame_bound_on_placement"] = incinerator.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	proof["adjacent_crusher_frame_bound_on_placement"] = crusher.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	proof["adjacent_large_crusher_frame_bound_on_placement"] = large_crusher.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)

	# --- the binding itself: one RuntimeConsumer actor per consume
	# row (the drill model, N2097/N2100). The separator consumes
	# slag 4/60 per tick (Blocks.java:1244); the disassembler scrap
	# 1 plus slag 0.12 (Blocks.java:1263-1264); the large-cliff-
	# crusher hydrogen 1/60 (Blocks.java:3028) — its graphite booster
	# is an assigned consumeItem(...).boost() row (Blocks.java:3030),
	# captured as boosterItem, not a consumeItem row, so it binds no
	# item actor. The incinerator and the cliff-crusher consume power
	# only (Blocks.java:1328, 3004) and bind none. ---
	var separator_frame: Dictionary = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var separator_module: Dictionary = separator.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(separator_module, slag_id, 10.0, [])
	var separator_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(separator_frame, blocks_by_id["separator"], catalog, separator_module)
	proof["adjacent_separator_bind_one_actor"] = bool(separator_bind.get("bound", false)) == true and Array(separator_bind.get("consumers", [])).size() == 1 and Array(separator_bind.get("rows", [])).size() == 1 and int(Array(separator_bind.get("rows", []))[0].get("liquid", -1)) == slag_id
	var separator_rebind: Dictionary = adjacent_build_state.source_bind_consumer_state(separator_frame, blocks_by_id["separator"], catalog, separator_module)
	proof["adjacent_separator_rebind_no_duplicate"] = bool(separator_rebind.get("bound", true)) == false and Array(separator_frame.get("consumers", [])).size() == 1
	var disassembler_frame: Dictionary = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	disassembler_frame["items"] = {"scrap": 5}
	var disassembler_module: Dictionary = disassembler.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(disassembler_module, slag_id, 10.0, [])
	var disassembler_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(disassembler_frame, blocks_by_id["disassembler"], catalog, disassembler_module)
	proof["adjacent_disassembler_bind_two_actors"] = bool(disassembler_bind.get("bound", false)) == true and Array(disassembler_bind.get("consumers", [])).size() == 2 and Array(disassembler_bind.get("rows", [])).size() == 2 and str(Array(disassembler_bind.get("rows", []))[0].get("item", "")) == "scrap" and int(Array(disassembler_bind.get("rows", []))[1].get("liquid", -1)) == slag_id
	var incinerator_frame: Dictionary = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var incinerator_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(incinerator_frame, blocks_by_id["incinerator"], catalog, {})
	proof["adjacent_incinerator_bind_none"] = bool(incinerator_bind.get("bound", true)) == false and Array(incinerator_bind.get("consumers", [])).is_empty() and Array(incinerator_bind.get("rows", [])).is_empty()
	var crusher_frame: Dictionary = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var crusher_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(crusher_frame, blocks_by_id["cliff-crusher"], catalog, {})
	proof["adjacent_crusher_bind_none"] = bool(crusher_bind.get("bound", true)) == false and Array(crusher_bind.get("consumers", [])).is_empty() and Array(crusher_bind.get("rows", [])).is_empty()
	var large_crusher_frame: Dictionary = large_crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var large_crusher_module: Dictionary = large_crusher.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(large_crusher_module, hydrogen_id, 10.0, [])
	var large_crusher_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(large_crusher_frame, blocks_by_id["large-cliff-crusher"], catalog, large_crusher_module)
	proof["adjacent_large_crusher_bind_one_actor"] = bool(large_crusher_bind.get("bound", false)) == true and Array(large_crusher_bind.get("consumers", [])).size() == 1 and Array(large_crusher_bind.get("rows", [])).size() == 1 and int(Array(large_crusher_bind.get("rows", []))[0].get("liquid", -1)) == hydrogen_id
	var bare_frame: Dictionary = {}
	var null_bind: Dictionary = adjacent_build_state.source_bind_consumer_state(bare_frame, null, catalog, {})
	proof["adjacent_null_block_bind_none"] = bool(null_bind.get("bound", true)) == false and Array(null_bind.get("consumers", [])).is_empty() and Array(null_bind.get("rows", [])).is_empty()

	# --- the live-loop tick driver ticks all five, and the bound
	# actors run through updateConsumption every tick: the separator
	# drains its slag at the live rate (ConsumeLiquid.update,
	# ConsumeLiquid.java:38-40: amount * edelta * multiplier, 4/60
	# per tick at efficiency 1.0), the disassembler its slag at 0.12
	# per tick while its scrap stays put — ConsumeItems has no update
	# body (Consume.java:52), so items leave only at craft() via
	# trigger (a later slice) — and the large-cliff-crusher its
	# hydrogen at 1/60 per tick. ---
	var ticked: Dictionary = adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["adjacent_driver_ticked_five"] = int(ticked.get("ticked_count", -1)) == 5 and ticked.get("results_by_cell", {}).has(game.call("cell_key", separator_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", disassembler_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", incinerator_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", crusher_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", large_crusher_cell))
	for iteration in range(3):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	disassembler_frame = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	incinerator_frame = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	crusher_frame = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	large_crusher_frame = large_crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_separator_consumers_still_one"] = Array(separator_frame.get("consumers", [])).size() == 1
	proof["adjacent_disassembler_consumers_still_two"] = Array(disassembler_frame.get("consumers", [])).size() == 2
	proof["adjacent_large_crusher_consumers_still_one"] = Array(large_crusher_frame.get("consumers", [])).size() == 1
	proof["adjacent_separator_efficiency_one"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0)
	proof["adjacent_disassembler_efficiency_one"] = is_equal_approx(float(disassembler_frame.get("efficiency", -1.0)), 1.0)
	proof["adjacent_large_crusher_efficiency_one"] = is_equal_approx(float(large_crusher_frame.get("efficiency", -1.0)), 1.0)
	proof["adjacent_power_only_efficiency_one"] = is_equal_approx(float(incinerator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 1.0)
	proof["adjacent_separator_slag_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_module, slag_id).get("amount", -1.0)), 10.0 - 4.0 * (4.0 / 60.0))
	proof["adjacent_disassembler_slag_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(disassembler_module, slag_id).get("amount", -1.0)), 10.0 - 4.0 * 0.12)
	proof["adjacent_disassembler_scrap_unchanged"] = Dictionary(disassembler_frame.get("items", {})).get("scrap", -1) == 5
	proof["adjacent_large_crusher_hydrogen_drops_four_ticks"] = is_equal_approx(float(liquid_module_state.source_get_state(large_crusher_module, hydrogen_id).get("amount", -1.0)), 10.0 - 4.0 * (1.0 / 60.0))

	# --- the item actor gates efficiency: with the disassembler's
	# scrap gone the first pass reads 0, so efficiency is 0 and the
	# building should not consume power; restoring it restores 1.0.
	# (The actor holds the frame's item module by reference, so the
	# proof empties the same dict in place.) ---
	var disassembler_items: Dictionary = disassembler_frame.get("items", {})
	disassembler_items["scrap"] = 0
	game.call("simulate_factory", 1.0 / 60.0)
	disassembler_frame = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_disassembler_no_scrap_efficiency_zero"] = is_equal_approx(float(disassembler_frame.get("efficiency", -1.0)), 0.0)
	proof["adjacent_disassembler_no_scrap_no_power"] = bool(disassembler_frame.get("should_consume_power", true)) == false
	disassembler_items["scrap"] = 5
	game.call("simulate_factory", 1.0 / 60.0)
	disassembler_frame = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_disassembler_scrap_restored_efficiency_one"] = is_equal_approx(float(disassembler_frame.get("efficiency", -1.0)), 1.0)

	# --- while the team cheats, the live loop skips consumption
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945):
	# the separator's slag stays put at full efficiency; uncheating
	# resumes the drain. ---
	var team_id: int = int(separator_frame.get("team_id", -1))
	proof["adjacent_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	var slag_before_cheat: float = float(liquid_module_state.source_get_state(separator_module, slag_id).get("amount", -1.0))
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	disassembler_frame = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	large_crusher_frame = large_crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_cheating_frames_true"] = bool(separator_frame.get("cheating", false)) == true and bool(disassembler_frame.get("cheating", false)) == true and bool(large_crusher_frame.get("cheating", false)) == true
	proof["adjacent_cheating_slag_unchanged"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_module, slag_id).get("amount", -1.0)), slag_before_cheat)
	proof["adjacent_cheating_efficiency_one"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(disassembler_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(large_crusher_frame.get("efficiency", -1.0)), 1.0)
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	disassembler_frame = disassembler.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	large_crusher_frame = large_crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_uncheat_restores"] = bool(separator_frame.get("cheating", true)) == false and bool(disassembler_frame.get("cheating", true)) == false and bool(large_crusher_frame.get("cheating", true)) == false
	proof["adjacent_uncheat_slag_drops"] = is_equal_approx(float(liquid_module_state.source_get_state(separator_module, slag_id).get("amount", -1.0)), slag_before_cheat - 4.0 * (4.0 / 60.0))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("AdjacentFactoryConsumerBindingProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
