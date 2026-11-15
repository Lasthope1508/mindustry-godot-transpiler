extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shield_wall_build_state := preload("res://src/game/SourceShieldWallBuildState.gd")
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

	# --- Live tick: the shield wall is a ShieldWall build with a
	# power consumer (shielded-wall, consumePower 3f / 60f = 0.05,
	# Blocks.java:1905), placed live; the tick driver is called
	# directly (as the N2175 proof does), not simulate_factory, so
	# the graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142. The
	# broken() coupling (N2202, ShieldWall.java:91-92, `return
	# breakTimer > 0 || !canConsume();`) runs through the pure
	# function source_shield_wall_broken_state(frame) over the
	# frame keys `break_timer` (float) and `potential_efficiency`
	# (float, stamped by the N2175 machinery via
	# apply_update_consumption_state): an absent break_timer key
	# means "no break in progress" (0.0), never "broken"; an
	# absent potential_efficiency key means "no machinery run
	# yet" (1.0), never "no power" -- the N2175 null-folds-to-1.0
	# precedent and the N2201 absent-preserves-behavior
	# precedent. The driver stamps frame["broken"] after the
	# consumption machinery, so the flag reads the fresh
	# potential_efficiency.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["shield_wall_has_power_consumer"] = bool(blocks_by_id["shielded-wall"].properties.has("consumePower")) and is_equal_approx(float(blocks_by_id["shielded-wall"].properties.get("consumePower", -1.0)), 0.05)

	var shield_wall_cell := Vector2i(28, 21)
	var shield_wall := Sprite2D.new()
	game.add_child(shield_wall)
	game.call("record_placed_block", shield_wall, blocks_by_id["shielded-wall"], shield_wall_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	shield_wall_build_state.source_shield_wall_bind_frame_state(shield_wall, blocks_by_id["shielded-wall"])
	var shield_wall_frame: Dictionary = shield_wall.get_meta(shield_wall_build_state.SOURCE_SHIELD_WALL_BUILDING_META_KEY, {})

	# Whole when powered: no break timer at half power -- the
	# machinery stamps potential_efficiency 0.5, so canConsume()
	# is true and broken() is false (ShieldWall.java:92 with
	# BuildingComp.java:1917-1919, `return potentialEfficiency >
	# 0;`).
	shield_wall_frame["power_status"] = 0.5
	shield_wall_frame["enabled"] = true
	shield_wall_build_state.source_shield_wall_tick_buildings_state(game, 1.0 / 60.0)
	shield_wall_frame = shield_wall.get_meta(shield_wall_build_state.SOURCE_SHIELD_WALL_BUILDING_META_KEY, {})
	proof["not_broken_when_powered"] = bool(shield_wall_frame.get("broken", true)) == false

	# Broken on break timer: break_timer=300 at half power --
	# the first disjunct (`breakTimer > 0`, ShieldWall.java:92)
	# breaks the wall even though power is fine; the tick-frame
	# function does not touch break_timer, so the proof-stamped
	# observation survives the driver call (the N2201
	# plans_count mechanics).
	shield_wall_frame["break_timer"] = 300.0
	shield_wall_frame["power_status"] = 0.5
	shield_wall_build_state.source_shield_wall_tick_buildings_state(game, 1.0 / 60.0)
	shield_wall_frame = shield_wall.get_meta(shield_wall_build_state.SOURCE_SHIELD_WALL_BUILDING_META_KEY, {})
	proof["broken_when_break_timer_positive"] = bool(shield_wall_frame.get("broken", false)) == true

	# Broken on no power: no break timer at zero power -- the
	# machinery stamps potential_efficiency 0.0, so canConsume()
	# is false and broken() is true (the power coupling: no
	# power = broken, no shield regen, ShieldWall.java:80).
	shield_wall_frame.erase("break_timer")
	shield_wall_frame["power_status"] = 0.0
	shield_wall_build_state.source_shield_wall_tick_buildings_state(game, 1.0 / 60.0)
	shield_wall_frame = shield_wall.get_meta(shield_wall_build_state.SOURCE_SHIELD_WALL_BUILDING_META_KEY, {})
	proof["broken_when_no_power"] = bool(shield_wall_frame.get("broken", false)) == true

	# Absent potential_efficiency folds to one: NO
	# potential_efficiency key and NO break_timer key -- the
	# pure function defaults to 1.0, so the wall is whole.
	# This pins the RED absent-default decision: absent means
	# "no machinery run yet", not "no power".
	var absent_potential: Dictionary = shield_wall_build_state.source_shield_wall_broken_state({})
	proof["broken_absent_potential_efficiency_folds_one"] = bool(absent_potential.get("broken", true)) == false

	# Absent break_timer defaults to zero: potential_efficiency
	# 1.0 with NO break_timer key -- the pure function defaults
	# the timer to 0.0, so the wall is whole. This pins the
	# second RED absent-default decision: absent means "no
	# break in progress", and the future updateTile-advance
	# slice owns live stamping of break_timer.
	var absent_timer: Dictionary = shield_wall_build_state.source_shield_wall_broken_state({"potential_efficiency": 1.0})
	proof["broken_absent_break_timer_defaults_zero"] = bool(absent_timer.get("broken", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShieldWallBrokenProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
