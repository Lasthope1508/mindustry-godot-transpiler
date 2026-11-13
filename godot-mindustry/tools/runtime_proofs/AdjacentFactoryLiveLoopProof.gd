extends Node

# No vanilla block uses SingleBlockProducer (Blocks.java defines
# none -- it is a base class for mod blocks), so the
# SingleBlockProducer shouldConsume() branch is exercised through
# a stand-in block object carrying the same implementation and
# properties shape the registry would capture.
class FakeSingleBlockProducerBlock extends RefCounted:
	var implementation: String = "SingleBlockProducer"
	var properties: Dictionary = {"result": "router", "itemCapacity": 10}

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

	# --- the three adjacent families are placed live. ---
	var separator_cell := Vector2i(30, 7)
	var incinerator_cell := Vector2i(35, 7)
	var crusher_cell := Vector2i(40, 7)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	var incinerator := Sprite2D.new()
	game.add_child(incinerator)
	game.call("record_placed_block", incinerator, blocks_by_id["incinerator"], incinerator_cell)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	# The scene needs power since N2146: the adjacent tick driver
	# reads the live power.status (ConsumePower.efficiency,
	# ConsumePower.java:39, `return build.power.status;`), and
	# the live loop's graph update stamps 0.0 when no producer
	# feeds the graph (PowerGraph.java:203, coverage 0), so an
	# unpowered adjacent factory ticks at efficiency 0 no matter
	# what shouldConsume says. A thorium reactor (powerProduction
	# 15.0, no fuel in the port's producer model) covers the
	# whole graph, so the efficiency keys below are isolated
	# from power.
	var reactor_cell := Vector2i(25, 7)
	var reactor := Sprite2D.new()
	game.add_child(reactor)
	game.call("record_placed_block", reactor, blocks_by_id["thorium-reactor"], reactor_cell)
	# N2115 binds the separator's slag actor, so the live loop runs
	# it through updateConsumption every tick: the separator needs
	# slag held for its live-loop efficiency to read 1.0
	# (ConsumeLiquid.efficiency, ConsumeLiquid.java:38-40 — with no
	# slag the first pass reads 0). The incinerator and the crusher
	# bind no actors and need nothing.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var slag_id: int = int(liquid_catalog["liquid_id_by_name"].get("slag", -1))
	var separator_module: Dictionary = separator.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(separator_module, slag_id, 10.0, [])
	proof["adjacent_separator_placed_live_sprite"] = str(separator.get_meta("source_block_id", "")) == "separator"
	proof["adjacent_incinerator_placed_live_sprite"] = str(incinerator.get_meta("source_block_id", "")) == "incinerator"
	proof["adjacent_crusher_placed_live_sprite"] = str(crusher.get_meta("source_block_id", "")) == "cliff-crusher"

	# --- the adjacent frame is bound ON PLACEMENT: a separator
	# placed live carries the frame meta the moment
	# record_placed_block returns, before any live-loop tick runs
	# (Block.newBuilding(), Block.java:1002). The frame is empty
	# until the tick fills its keys. ---
	proof["adjacent_frame_bound_on_placement"] = separator.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	var separator_frame: Dictionary = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_frame_empty_before_tick"] = separator_frame.is_empty()
	proof["adjacent_incinerator_frame_bound_on_placement"] = incinerator.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	proof["adjacent_crusher_frame_bound_on_placement"] = crusher.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)

	# --- a non-adjacent block binds nothing, and the scenario drill
	# and duo carry no adjacent frame. ---
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_bind: Dictionary = adjacent_build_state.source_adjacent_factory_bind_frame_state(drill_sprite, blocks_by_id["mechanical-drill"])
	proof["adjacent_non_adjacent_bind_false"] = drill_bind.get("applied", true) == false
	proof["adjacent_drill_has_no_adjacent_frame"] = not drill_sprite.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)
	var duo_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(19, 7))
	var duo_bind: Dictionary = adjacent_build_state.source_adjacent_factory_bind_frame_state(duo_sprite, blocks_by_id["duo"])
	proof["adjacent_turret_bind_false"] = duo_bind.get("applied", true) == false
	proof["adjacent_duo_has_no_adjacent_frame"] = not duo_sprite.has_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY)

	# --- the tick wiring reads the live rules directly: a hand-built
	# frame cheats when its team cheats and does not otherwise. ---
	var wired_cheat: Dictionary = adjacent_build_state.source_adjacent_factory_tick_frame_state({}, "Separator", 1, {"teams": {1: {"cheat": true}}})
	proof["adjacent_tick_frame_cheat_true"] = bool(wired_cheat.get("cheating", false)) == true and str(wired_cheat.get("block_implementation", "")) == "Separator" and int(wired_cheat.get("team_id", -1)) == 1
	var wired_plain: Dictionary = adjacent_build_state.source_adjacent_factory_tick_frame_state({}, "Incinerator", 1, {"teams": {}})
	proof["adjacent_tick_frame_cheat_false"] = bool(wired_plain.get("cheating", true)) == false

	# --- the live-loop tick driver wires the placed adjacent
	# builds: the separator, the incinerator and the cliff-crusher.
	# The drill and the duo are skipped (their own drivers). ---
	var ticked: Dictionary = adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["adjacent_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", separator_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", incinerator_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", crusher_cell))
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var incinerator_frame: Dictionary = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var crusher_frame: Dictionary = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_driver_separator_frame_wired"] = str(separator_frame.get("block_implementation", "")) == "Separator" and int(separator_frame.get("team_id", -1)) >= 0 and bool(separator_frame.get("cheating", true)) == false
	proof["adjacent_driver_incinerator_frame_wired"] = str(incinerator_frame.get("block_implementation", "")) == "Incinerator" and int(incinerator_frame.get("team_id", -1)) >= 0 and bool(incinerator_frame.get("cheating", true)) == false
	proof["adjacent_driver_crusher_frame_wired"] = str(crusher_frame.get("block_implementation", "")) == "WallCrafter" and int(crusher_frame.get("team_id", -1)) >= 0 and bool(crusher_frame.get("cheating", true)) == false

	# --- the live loop itself refreshes the keys every tick, and a
	# placed adjacent factory with room ticks at efficiency 1. The
	# efficiency here folds the live power.status (N2146), and the
	# graph's coverage ratio carries float64 noise (produced /
	# needed lands a hair under 1.0 even when the reactor covers
	# the graph), so the exact == the proof used before N2146 is
	# brittle now; is_equal_approx matches the binding proof's
	# idiom for the same live efficiency. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	incinerator_frame = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	crusher_frame = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_live_loop_not_cheating_default"] = bool(separator_frame.get("cheating", true)) == false and bool(incinerator_frame.get("cheating", true)) == false and bool(crusher_frame.get("cheating", true)) == false
	proof["adjacent_live_loop_efficiency_one"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(incinerator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 1.0)

	# --- each family's own shouldConsume() body, read live by the
	# driver: Separator counts held items minus the consumeItem
	# inputs against itemCapacity (Separator.java:92-100), the
	# disassembler subtracts its scrap input, WallCrafter blocks
	# when the held output stack fills itemCapacity
	# (WallCrafter.java:226-227), Incinerator takes the Building
	# default (enabled, BuildingComp.java:755-756), and
	# SingleBlockProducer needs a recipe (BlockProducer.java:102-103). ---
	var separator_room: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {}}, blocks_by_id["separator"])
	proof["adjacent_separator_room_consumes"] = bool(separator_room.get("should_consume", false)) == true and bool(separator_room.get("buffer_full", true)) == false
	var separator_full: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {"sand": 10}}, blocks_by_id["separator"])
	proof["adjacent_separator_full_blocks"] = bool(separator_full.get("should_consume", true)) == false and bool(separator_full.get("buffer_full", false)) == true
	var disassembler_inputs: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {"scrap": 10}}, blocks_by_id["disassembler"])
	proof["adjacent_disassembler_inputs_subtracted"] = bool(disassembler_inputs.get("should_consume", false)) == true and bool(disassembler_inputs.get("buffer_full", true)) == false
	var disassembler_full: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {"scrap": 10, "sand": 25}}, blocks_by_id["disassembler"])
	proof["adjacent_disassembler_overflow_blocks"] = bool(disassembler_full.get("should_consume", true)) == false and bool(disassembler_full.get("buffer_full", false)) == true
	var crusher_room: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {"sand": 9}}, blocks_by_id["cliff-crusher"])
	proof["adjacent_crusher_room_consumes"] = bool(crusher_room.get("should_consume", false)) == true and bool(crusher_room.get("output_blocked", true)) == false
	var crusher_full: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {"sand": 10}}, blocks_by_id["cliff-crusher"])
	proof["adjacent_crusher_full_blocks"] = bool(crusher_full.get("should_consume", true)) == false and bool(crusher_full.get("output_blocked", false)) == true
	var crusher_disabled: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": false, "items": {}}, blocks_by_id["cliff-crusher"])
	proof["adjacent_crusher_no_enabled_check"] = bool(crusher_disabled.get("should_consume", false)) == true
	var incinerator_on: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {}}, blocks_by_id["incinerator"])
	proof["adjacent_incinerator_enabled_consumes"] = bool(incinerator_on.get("should_consume", false)) == true
	var incinerator_off: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": false, "items": {}}, blocks_by_id["incinerator"])
	proof["adjacent_incinerator_disabled_blocks"] = bool(incinerator_off.get("should_consume", true)) == false
	var producer_block := FakeSingleBlockProducerBlock.new()
	var producer_on: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {}}, producer_block)
	proof["adjacent_producer_recipe_consumes"] = bool(producer_on.get("should_consume", false)) == true
	producer_block.properties["result"] = ""
	var producer_no_recipe: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {}}, producer_block)
	proof["adjacent_producer_no_recipe_blocks"] = bool(producer_no_recipe.get("should_consume", true)) == false
	var null_block: Dictionary = adjacent_build_state.source_adjacent_factory_should_consume_state({"enabled": true, "items": {}}, null)
	proof["adjacent_null_block_enabled_consumes"] = bool(null_block.get("should_consume", false)) == true

	# --- live, a buffer-full separator ticks at efficiency 0, and
	# room restores 1.0. ---
	separator_frame["items"] = {"sand": 10}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_live_loop_full_separator_zero"] = float(separator_frame.get("efficiency", -1.0)) == 0.0
	separator_frame["items"] = {}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_live_loop_room_separator_restores"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0)

	# --- the adjacent tick reads the live cheat flag for its own
	# team (TeamComp.cheating(), N2099): while the team cheats, the
	# separator, incinerator and crusher frames carry cheating=true,
	# so updateConsumption counts everything as valid
	# (BuildingComp.java:1944-1945). ---
	var team_id: int = int(separator_frame.get("team_id", -1))
	proof["adjacent_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	incinerator_frame = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	crusher_frame = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_live_loop_separator_frame_sees_cheat"] = bool(separator_frame.get("cheating", false)) == true
	proof["adjacent_live_loop_incinerator_frame_sees_cheat"] = bool(incinerator_frame.get("cheating", false)) == true
	proof["adjacent_live_loop_crusher_frame_sees_cheat"] = bool(crusher_frame.get("cheating", false)) == true

	# --- updateConsumption reads the wired flag: while the team
	# cheats, the adjacent factory takes the early return
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945)
	# and skips consumption at full efficiency; without cheating the
	# same call runs the machinery (no actors bound yet, N2112
	# pattern) and does not skip. ---
	var cheating_consumption: Dictionary = adjacent_build_state.source_adjacent_factory_update_consumption_state(separator_frame, true, true, true, true, 1.0)
	proof["adjacent_consumption_cheating_skips"] = bool(cheating_consumption.get("skipped_consumption", false)) == true and float(cheating_consumption.get("efficiency", -1.0)) == 1.0 and float(cheating_consumption.get("potential_efficiency", -1.0)) == 1.0 and bool(cheating_consumption.get("should_consume_power", false)) == true
	var cheating_disabled: Dictionary = adjacent_build_state.source_adjacent_factory_update_consumption_state(separator_frame, true, false, true, true, 1.0)
	proof["adjacent_consumption_cheating_disabled_zero"] = bool(cheating_disabled.get("skipped_consumption", false)) == true and float(cheating_disabled.get("potential_efficiency", -1.0)) == 0.0 and float(cheating_disabled.get("efficiency", -1.0)) == 0.0
	var plain_frame: Dictionary = {"cheating": false}
	var plain_consumption: Dictionary = adjacent_build_state.source_adjacent_factory_update_consumption_state(plain_frame, true, true, true, true, 1.0)
	proof["adjacent_consumption_plain_runs_machinery"] = bool(plain_consumption.get("skipped_consumption", true)) == false and float(plain_consumption.get("efficiency", -1.0)) == 1.0 and bool(plain_consumption.get("should_consume_power", false)) == true
	var plain_idle: Dictionary = adjacent_build_state.source_adjacent_factory_update_consumption_state(plain_frame, true, true, true, false, 1.0)
	proof["adjacent_consumption_plain_no_consume_zero"] = bool(plain_idle.get("skipped_consumption", true)) == false and float(plain_idle.get("efficiency", -1.0)) == 0.0 and float(plain_idle.get("potential_efficiency", -1.0)) == 1.0
	var no_consumers: Dictionary = adjacent_build_state.source_adjacent_factory_update_consumption_state(plain_frame, false, true, true, true, 1.0)
	proof["adjacent_consumption_plain_no_consumers_skips"] = bool(no_consumers.get("skipped_consumption", false)) == true and float(no_consumers.get("efficiency", -1.0)) == 1.0

	# --- uncheating restores the false flag through the live loop. ---
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	incinerator_frame = incinerator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	crusher_frame = crusher.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["adjacent_live_loop_uncheat_restores"] = bool(separator_frame.get("cheating", true)) == false and bool(incinerator_frame.get("cheating", true)) == false and bool(crusher_frame.get("cheating", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("AdjacentFactoryLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
