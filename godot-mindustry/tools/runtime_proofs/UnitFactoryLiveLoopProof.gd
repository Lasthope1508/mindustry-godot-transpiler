extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceUnitFactoryBuildState.gd")
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
	proof["factory_ground_is_unit_factory"] = String(blocks_by_id["ground-factory"].implementation) == "UnitFactory"
	proof["factory_reconstructor_is_reconstructor"] = String(blocks_by_id["additive-reconstructor"].implementation) == "Reconstructor"
	proof["factory_assembler_is_unit_assembler"] = String(blocks_by_id["tank-assembler"].implementation) == "UnitAssembler"

	# --- the factory frame is bound ON PLACEMENT: three factories
	# placed live carry the frame meta the moment record_placed_block
	# returns, before any live-loop tick runs (Block.newBuilding(),
	# Block.java:1002). The frame is empty until the tick fills its
	# keys. ---
	var ground_cell := Vector2i(30, 7)
	var recon_cell := Vector2i(35, 7)
	var assembler_cell := Vector2i(40, 7)
	var ground := Sprite2D.new()
	game.add_child(ground)
	game.call("record_placed_block", ground, blocks_by_id["ground-factory"], ground_cell)
	var recon := Sprite2D.new()
	game.add_child(recon)
	game.call("record_placed_block", recon, blocks_by_id["additive-reconstructor"], recon_cell)
	var assembler := Sprite2D.new()
	game.add_child(assembler)
	game.call("record_placed_block", assembler, blocks_by_id["tank-assembler"], assembler_cell)
	proof["factory_ground_placed_live_sprite"] = str(ground.get_meta("source_block_id", "")) == "ground-factory"
	proof["factory_reconstructor_placed_live_sprite"] = str(recon.get_meta("source_block_id", "")) == "additive-reconstructor"
	proof["factory_assembler_placed_live_sprite"] = str(assembler.get_meta("source_block_id", "")) == "tank-assembler"
	proof["factory_frame_bound_on_placement"] = ground.has_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)
	var ground_frame: Dictionary = ground.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["factory_frame_empty_before_tick"] = ground_frame.is_empty()

	# --- a non-factory block binds nothing, and the scenario drill
	# and duo carry no factory frame. ---
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_bind: Dictionary = factory_build_state.source_unit_factory_bind_frame_state(drill_sprite, blocks_by_id["mechanical-drill"])
	proof["factory_non_factory_bind_false"] = drill_bind.get("applied", true) == false
	proof["factory_drill_has_no_factory_frame"] = not drill_sprite.has_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)
	var duo_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(19, 7))
	var duo_bind: Dictionary = factory_build_state.source_unit_factory_bind_frame_state(duo_sprite, blocks_by_id["duo"])
	proof["factory_turret_bind_false"] = duo_bind.get("applied", true) == false
	proof["factory_duo_has_no_factory_frame"] = not duo_sprite.has_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY)

	# --- the tick wiring reads the live rules directly: a hand-built
	# frame cheats when its team cheats and does not otherwise. ---
	var wired_cheat: Dictionary = factory_build_state.source_unit_factory_tick_frame_state({}, "UnitFactory", 1, {"teams": {1: {"cheat": true}}})
	proof["factory_tick_frame_cheat_true"] = bool(wired_cheat.get("cheating", false)) == true and str(wired_cheat.get("block_implementation", "")) == "UnitFactory" and int(wired_cheat.get("team_id", -1)) == 1
	var wired_plain: Dictionary = factory_build_state.source_unit_factory_tick_frame_state({}, "Reconstructor", 1, {"teams": {}})
	proof["factory_tick_frame_cheat_false"] = bool(wired_plain.get("cheating", true)) == false and str(wired_plain.get("block_implementation", "")) == "Reconstructor"

	# --- the live-loop tick driver wires the placed factories: the
	# ground factory, the reconstructor and the assembler. ---
	var ticked: Dictionary = factory_build_state.source_unit_factory_tick_buildings_state(game, 1.0 / 60.0)
	proof["factory_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", ground_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", recon_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", assembler_cell))
	ground_frame = ground.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	var recon_frame: Dictionary = recon.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	var assembler_frame: Dictionary = assembler.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["factory_driver_ground_frame_wired"] = str(ground_frame.get("block_implementation", "")) == "UnitFactory" and int(ground_frame.get("team_id", -1)) >= 0 and bool(ground_frame.get("cheating", true)) == false
	proof["factory_driver_reconstructor_frame_wired"] = str(recon_frame.get("block_implementation", "")) == "Reconstructor" and int(recon_frame.get("team_id", -1)) >= 0 and bool(recon_frame.get("cheating", true)) == false
	proof["factory_driver_assembler_frame_wired"] = str(assembler_frame.get("block_implementation", "")) == "UnitAssembler" and int(assembler_frame.get("team_id", -1)) >= 0 and bool(assembler_frame.get("cheating", true)) == false

	# --- the live loop itself refreshes the keys every tick. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	ground_frame = ground.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	recon_frame = recon.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_not_cheating_default"] = bool(ground_frame.get("cheating", true)) == false and bool(recon_frame.get("cheating", true)) == false and bool(assembler_frame.get("cheating", true)) == false

	# --- the factory tick reads the live cheat flag for its own team
	# (TeamComp.cheating(), N2099): while the team cheats, all three
	# factory frames carry cheating=true. ---
	var team_id: int = int(ground_frame.get("team_id", -1))
	proof["factory_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	ground_frame = ground.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	recon_frame = recon.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_ground_frame_sees_cheat"] = bool(ground_frame.get("cheating", false)) == true
	proof["factory_live_loop_reconstructor_frame_sees_cheat"] = bool(recon_frame.get("cheating", false)) == true
	proof["factory_live_loop_assembler_frame_sees_cheat"] = bool(assembler_frame.get("cheating", false)) == true

	# --- updateConsumption reads the wired flag: while the team
	# cheats, the factory takes the early return
	# (BuildingComp.updateConsumption(), BuildingComp.java:1944-1945)
	# and skips consumption at full efficiency; without cheating the
	# same call runs the machinery (no actors bound yet, N2106
	# pattern) and does not skip. ---
	var cheating_consumption: Dictionary = factory_build_state.source_unit_factory_update_consumption_state(ground_frame, true, true, true, true, 1.0)
	proof["factory_consumption_cheating_skips"] = bool(cheating_consumption.get("skipped_consumption", false)) == true and float(cheating_consumption.get("efficiency", -1.0)) == 1.0 and float(cheating_consumption.get("potential_efficiency", -1.0)) == 1.0 and bool(cheating_consumption.get("should_consume_power", false)) == true
	var cheating_disabled: Dictionary = factory_build_state.source_unit_factory_update_consumption_state(ground_frame, true, false, true, true, 1.0)
	proof["factory_consumption_cheating_disabled_zero"] = bool(cheating_disabled.get("skipped_consumption", false)) == true and float(cheating_disabled.get("potential_efficiency", -1.0)) == 0.0 and float(cheating_disabled.get("efficiency", -1.0)) == 0.0
	var plain_frame: Dictionary = {"cheating": false}
	var plain_consumption: Dictionary = factory_build_state.source_unit_factory_update_consumption_state(plain_frame, true, true, true, true, 1.0)
	proof["factory_consumption_plain_runs_machinery"] = bool(plain_consumption.get("skipped_consumption", true)) == false and float(plain_consumption.get("efficiency", -1.0)) == 1.0 and bool(plain_consumption.get("should_consume_power", false)) == true
	var plain_idle: Dictionary = factory_build_state.source_unit_factory_update_consumption_state(plain_frame, true, true, true, false, 1.0)
	proof["factory_consumption_plain_no_consume_zero"] = bool(plain_idle.get("skipped_consumption", true)) == false and float(plain_idle.get("efficiency", -1.0)) == 0.0 and float(plain_idle.get("potential_efficiency", -1.0)) == 1.0

	# --- uncheating restores the false flag through the live loop. ---
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	ground_frame = ground.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	recon_frame = recon.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	assembler_frame = assembler.get_meta(factory_build_state.SOURCE_UNIT_FACTORY_BUILDING_META_KEY, {})
	proof["factory_live_loop_uncheat_restores"] = bool(ground_frame.get("cheating", true)) == false and bool(recon_frame.get("cheating", true)) == false and bool(assembler_frame.get("cheating", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("UnitFactoryLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
