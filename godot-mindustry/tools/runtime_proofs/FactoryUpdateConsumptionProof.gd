extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- the two factories are placed live, and the N2110 frame is
	# bound ON PLACEMENT (Block.newBuilding(), Block.java:1002). ---
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
	proof["factory_frame_bound_on_placement"] = smelter.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)
	var smelter_frame: Dictionary = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["factory_frame_empty_before_tick"] = smelter_frame.is_empty()
	proof["factory_press_frame_bound_on_placement"] = press.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- the live-loop tick driver wires the placed factories. ---
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

	# --- while the team cheats, the live loop flips both frames to
	# cheating=true (TeamComp.cheating(), N2099). ---
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

	# --- updateConsumption reads the wired flag: while the team
	# cheats, the factory takes the early return
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945)
	# and skips consumption at full efficiency; without cheating the
	# same call runs the machinery (no actors bound yet, N2106
	# pattern) and does not skip. ---
	var cheating_consumption: Dictionary = factory_build_state.source_factory_update_consumption_state(smelter_frame, true, true, true, true, 1.0)
	proof["factory_consumption_cheating_skips"] = bool(cheating_consumption.get("skipped_consumption", false)) == true and float(cheating_consumption.get("efficiency", -1.0)) == 1.0 and float(cheating_consumption.get("potential_efficiency", -1.0)) == 1.0 and bool(cheating_consumption.get("should_consume_power", false)) == true
	var cheating_disabled: Dictionary = factory_build_state.source_factory_update_consumption_state(smelter_frame, true, false, true, true, 1.0)
	proof["factory_consumption_cheating_disabled_zero"] = bool(cheating_disabled.get("skipped_consumption", false)) == true and float(cheating_disabled.get("potential_efficiency", -1.0)) == 0.0 and float(cheating_disabled.get("efficiency", -1.0)) == 0.0
	var press_cheating: Dictionary = factory_build_state.source_factory_update_consumption_state(press_frame, true, true, true, true, 1.0)
	proof["factory_consumption_press_cheating_skips"] = bool(press_cheating.get("skipped_consumption", false)) == true and float(press_cheating.get("efficiency", -1.0)) == 1.0
	var plain_frame: Dictionary = {"cheating": false}
	var plain_consumption: Dictionary = factory_build_state.source_factory_update_consumption_state(plain_frame, true, true, true, true, 1.0)
	proof["factory_consumption_plain_runs_machinery"] = bool(plain_consumption.get("skipped_consumption", true)) == false and float(plain_consumption.get("efficiency", -1.0)) == 1.0 and bool(plain_consumption.get("should_consume_power", false)) == true
	var plain_idle: Dictionary = factory_build_state.source_factory_update_consumption_state(plain_frame, true, true, true, false, 1.0)
	proof["factory_consumption_plain_no_consume_zero"] = bool(plain_idle.get("skipped_consumption", true)) == false and float(plain_idle.get("efficiency", -1.0)) == 0.0 and float(plain_idle.get("potential_efficiency", -1.0)) == 1.0
	var no_consumers: Dictionary = factory_build_state.source_factory_update_consumption_state(plain_frame, false, true, true, true, 1.0)
	proof["factory_consumption_plain_no_consumers_skips"] = bool(no_consumers.get("skipped_consumption", false)) == true and float(no_consumers.get("efficiency", -1.0)) == 1.0

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
	proof_state.write_proof("FactoryUpdateConsumptionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
