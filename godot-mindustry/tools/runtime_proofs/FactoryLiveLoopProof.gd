extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
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
	proof["factory_smelter_is_generic_crafter"] = String(blocks_by_id["silicon-smelter"].implementation) == "GenericCrafter"
	proof["factory_press_is_generic_crafter"] = String(blocks_by_id["graphite-press"].implementation) == "GenericCrafter"

	# --- the two factories are placed live. ---
	var smelter_cell := Vector2i(30, 7)
	var press_cell := Vector2i(35, 7)
	var smelter := Sprite2D.new()
	game.add_child(smelter)
	game.call("record_placed_block", smelter, blocks_by_id["silicon-smelter"], smelter_cell)
	var press := Sprite2D.new()
	game.add_child(press)
	game.call("record_placed_block", press, blocks_by_id["graphite-press"], press_cell)
	proof["factory_smelter_placed_live_sprite"] = str(smelter.get_meta("source_block_id", "")) == "silicon-smelter"
	proof["factory_press_placed_live_sprite"] = str(press.get_meta("source_block_id", "")) == "graphite-press"

	# --- the factory frame is bound ON PLACEMENT: a silicon-smelter
	# placed live carries the frame meta the moment record_placed_block
	# returns, before any live-loop tick runs (Block.newBuilding(),
	# Block.java:1002). The frame is empty until the tick fills its
	# keys. ---
	proof["factory_frame_bound_on_placement"] = smelter.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	var smelter_frame: Dictionary = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_frame_empty_before_tick"] = smelter_frame.is_empty()
	proof["factory_press_frame_bound_on_placement"] = press.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- a non-factory block binds nothing, and the scenario drill
	# and duo carry no factory frame. ---
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_bind: Dictionary = factory_build_state.source_factory_bind_frame_state(drill_sprite, blocks_by_id["mechanical-drill"])
	proof["factory_non_factory_bind_false"] = drill_bind.get("applied", true) == false
	proof["factory_drill_has_no_factory_frame"] = not drill_sprite.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	var duo_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(19, 7))
	var duo_bind: Dictionary = factory_build_state.source_factory_bind_frame_state(duo_sprite, blocks_by_id["duo"])
	proof["factory_turret_bind_false"] = duo_bind.get("applied", true) == false
	proof["factory_duo_has_no_factory_frame"] = not duo_sprite.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- the tick wiring reads the live rules directly: a hand-built
	# frame cheats when its team cheats and does not otherwise. ---
	var wired_cheat: Dictionary = factory_build_state.source_factory_tick_frame_state({}, "GenericCrafter", 1, {"teams": {1: {"cheat": true}}})
	proof["factory_tick_frame_cheat_true"] = bool(wired_cheat.get("cheating", false)) == true and str(wired_cheat.get("block_implementation", "")) == "GenericCrafter" and int(wired_cheat.get("team_id", -1)) == 1
	var wired_plain: Dictionary = factory_build_state.source_factory_tick_frame_state({}, "GenericCrafter", 1, {"teams": {}})
	proof["factory_tick_frame_cheat_false"] = bool(wired_plain.get("cheating", true)) == false

	# --- the live-loop tick driver wires the placed factories: the
	# silicon-smelter and the graphite-press. The drill and the duo
	# are skipped (their own drivers). ---
	var ticked: Dictionary = factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["factory_driver_ticked_two"] = int(ticked.get("ticked_count", -1)) == 2 and ticked.get("results_by_cell", {}).has(game.call("cell_key", smelter_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", press_cell))
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var press_frame: Dictionary = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_driver_smelter_frame_wired"] = str(smelter_frame.get("block_implementation", "")) == "GenericCrafter" and int(smelter_frame.get("team_id", -1)) >= 0 and bool(smelter_frame.get("cheating", true)) == false
	proof["factory_driver_press_frame_wired"] = str(press_frame.get("block_implementation", "")) == "GenericCrafter" and int(press_frame.get("team_id", -1)) >= 0 and bool(press_frame.get("cheating", true)) == false

	# --- the live loop itself refreshes the keys every tick. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_not_cheating_default"] = bool(smelter_frame.get("cheating", true)) == false and bool(press_frame.get("cheating", true)) == false

	# --- the factory tick reads the live cheat flag for its own team
	# (TeamComp.cheating(), N2099): while the team cheats, the
	# smelter and the press frames carry cheating=true, so
	# updateConsumption counts everything as valid
	# (BuildingComp.java:1944-1945). ---
	var team_id: int = int(smelter_frame.get("team_id", -1))
	proof["factory_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_smelter_frame_sees_cheat"] = bool(smelter_frame.get("cheating", false)) == true
	proof["factory_live_loop_press_frame_sees_cheat"] = bool(press_frame.get("cheating", false)) == true

	# --- uncheating restores the false flag through the live loop. ---
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_uncheat_restores"] = bool(smelter_frame.get("cheating", true)) == false and bool(press_frame.get("cheating", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("FactoryLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
