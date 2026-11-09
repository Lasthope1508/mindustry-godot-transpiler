extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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
	proof["turret_duo_is_item_turret"] = String(blocks_by_id["duo"].implementation) == "ItemTurret"
	proof["turret_lancer_is_power_turret"] = String(blocks_by_id["lancer"].implementation) == "PowerTurret"

	# --- the bootstrap duo and lancer are placed live. ---
	var duo_cell := Vector2i(19, 7)
	var lancer_cell := Vector2i(25, 7)
	var duo: Variant = game.call("block_sprite_at_cell", duo_cell)
	var lancer: Variant = game.call("block_sprite_at_cell", lancer_cell)
	proof["turret_duo_placed_live_sprite"] = duo != null and str(duo.get_meta("source_block_id", "")) == "duo"
	proof["turret_lancer_placed_live_sprite"] = lancer != null and str(lancer.get_meta("source_block_id", "")) == "lancer"

	# --- the turret frame is bound ON PLACEMENT: a second duo placed
	# live carries the frame meta the moment record_placed_block
	# returns, before any live-loop tick runs (Block.newBuilding(),
	# Block.java:1002). The frame is empty until the tick fills its
	# keys. ---
	var second_cell := Vector2i(30, 7)
	var second := Sprite2D.new()
	game.add_child(second)
	game.call("record_placed_block", second, blocks_by_id["duo"], second_cell)
	proof["turret_second_placed_live_sprite"] = str(second.get_meta("source_block_id", "")) == "duo"
	proof["turret_frame_bound_on_placement"] = second.has_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY)
	var second_frame: Dictionary = second.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["turret_frame_empty_before_tick"] = second_frame.is_empty()

	# --- a non-turret block binds nothing, and the scenario drill
	# carries no turret frame. ---
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var drill_bind: Dictionary = turret_build_state.source_turret_bind_frame_state(drill_sprite, blocks_by_id["mechanical-drill"])
	proof["turret_non_turret_bind_false"] = drill_bind.get("applied", true) == false
	proof["turret_drill_has_no_turret_frame"] = not drill_sprite.has_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY)

	# --- a ContinuousLiquidTurret binds nothing here: it has its own
	# frame and driver (N2103). ---
	var sublimate := Sprite2D.new()
	game.add_child(sublimate)
	game.call("record_placed_block", sublimate, blocks_by_id["sublimate"], Vector2i(35, 7))
	var sublimate_bind: Dictionary = turret_build_state.source_turret_bind_frame_state(sublimate, blocks_by_id["sublimate"])
	proof["turret_continuous_liquid_bind_false"] = sublimate_bind.get("applied", true) == false
	proof["turret_sublimate_has_no_turret_frame"] = not sublimate.has_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY)

	# --- the tick wiring reads the live rules directly: a hand-built
	# frame cheats when its team cheats and does not otherwise. ---
	var wired_cheat: Dictionary = turret_build_state.source_turret_tick_frame_state({}, "ItemTurret", 1, {"teams": {1: {"cheat": true}}})
	proof["turret_tick_frame_cheat_true"] = bool(wired_cheat.get("cheating", false)) == true and str(wired_cheat.get("block_implementation", "")) == "ItemTurret" and int(wired_cheat.get("team_id", -1)) == 1
	var wired_plain: Dictionary = turret_build_state.source_turret_tick_frame_state({}, "ItemTurret", 1, {"teams": {}})
	proof["turret_tick_frame_cheat_false"] = bool(wired_plain.get("cheating", true)) == false

	# --- the live-loop tick driver wires the placed turrets: the
	# bootstrap duo and lancer plus the second duo. The sublimate is
	# skipped (its own driver, N2103). ---
	var ticked: Dictionary = turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	proof["turret_driver_ticked_three"] = int(ticked.get("ticked_count", -1)) == 3 and ticked.get("results_by_cell", {}).has(game.call("cell_key", duo_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", lancer_cell)) and ticked.get("results_by_cell", {}).has(game.call("cell_key", second_cell))
	var duo_frame: Dictionary = duo.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var lancer_frame: Dictionary = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["turret_driver_duo_frame_wired"] = str(duo_frame.get("block_implementation", "")) == "ItemTurret" and int(duo_frame.get("team_id", -1)) >= 0 and bool(duo_frame.get("cheating", true)) == false
	proof["turret_driver_lancer_frame_wired"] = str(lancer_frame.get("block_implementation", "")) == "PowerTurret" and int(lancer_frame.get("team_id", -1)) >= 0 and bool(lancer_frame.get("cheating", true)) == false

	# --- the live loop itself refreshes the keys every tick. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	duo_frame = duo.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["turret_live_loop_not_cheating_default"] = bool(duo_frame.get("cheating", true)) == false and bool(lancer_frame.get("cheating", true)) == false

	# --- the turret tick reads the live cheat flag for its own team
	# (TeamComp.cheating(), N2099): while the team cheats, the duo,
	# the lancer and the second duo frames carry cheating=true. ---
	var team_id: int = int(duo_frame.get("team_id", -1))
	proof["turret_team_known"] = team_id >= 0
	var game_rules: Dictionary = game.get("rules_state")
	var teams: Dictionary = game_rules.get("teams", {})
	teams[team_id] = {"cheat": true}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	duo_frame = duo.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	second_frame = second.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["turret_live_loop_duo_frame_sees_cheat"] = bool(duo_frame.get("cheating", false)) == true
	proof["turret_live_loop_lancer_frame_sees_cheat"] = bool(lancer_frame.get("cheating", false)) == true
	proof["turret_live_loop_second_frame_sees_cheat"] = bool(second_frame.get("cheating", false)) == true

	# --- useAmmo reads the wired flag: while the team cheats, the
	# duo fires without spending ammo (TurretBuild.useAmmo(),
	# Turret.java:682 `if(cheating()) return peekAmmo();`); without
	# cheating the same shot spends one copper (ammoPerShot 1). ---
	var duo_properties: Dictionary = blocks_by_id["duo"].properties
	var stacks: Array = [{"item": "copper", "amount": 5}]
	var cheating_use: Dictionary = turret_build_state.source_turret_use_ammo_state(duo_frame, duo_properties, stacks, 5)
	proof["turret_use_ammo_cheating_returns_peek"] = int(Dictionary(cheating_use.get("returned_ammo", {})).get("damage", -1)) == 9 and str(Dictionary(cheating_use.get("returned_ammo", {})).get("item", "")) == "copper"
	proof["turret_use_ammo_cheating_keeps_stacks"] = int(Dictionary(Array(cheating_use.get("stacks_after", []))[0]).get("amount", -1)) == 5 and int(cheating_use.get("total_ammo_after", -1)) == 5 and bool(cheating_use.get("used", true)) == false
	var plain_frame: Dictionary = {"cheating": false}
	var plain_use: Dictionary = turret_build_state.source_turret_use_ammo_state(plain_frame, duo_properties, stacks, 5)
	proof["turret_use_ammo_plain_spends_one"] = int(Dictionary(plain_use.get("returned_ammo", {})).get("damage", -1)) == 9 and bool(plain_use.get("used", false)) == true and int(Dictionary(Array(plain_use.get("stacks_after", []))[0]).get("amount", -1)) == 4 and int(plain_use.get("total_ammo_after", -1)) == 4
	proof["turret_use_ammo_plain_leaves_input_stacks"] = int(Dictionary(stacks[0]).get("amount", -1)) == 5
	# --- a cheating turret with no ammo peeks nothing. ---
	var empty_use: Dictionary = turret_build_state.source_turret_use_ammo_state(duo_frame, duo_properties, [], 0)
	proof["turret_use_ammo_cheating_empty_peeks_nothing"] = Dictionary(empty_use.get("returned_ammo", {"x": 1})).is_empty() and bool(empty_use.get("used", true)) == false

	# --- uncheating restores the false flag through the live loop. ---
	teams[team_id] = {"cheat": false}
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	duo_frame = duo.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["turret_live_loop_uncheat_restores"] = bool(duo_frame.get("cheating", true)) == false and bool(lancer_frame.get("cheating", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TurretLiveLoopProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
