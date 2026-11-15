extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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

	# --- Pure advance (N2238): LaunchPadBuild.updateTile()
	# (LaunchPad.java:143-161): the launchCounter += edelta()
	# advance (LaunchPad.java:146), the full-and-timed launch
	# gate (LaunchPad.java:146, items.total() >= itemCapacity),
	# the consume() call (LaunchPad.java:148, a no-op for items
	# on this def -- ConsumePower has no trigger override and
	# the Consume default trigger is empty, Consume.java:50),
	# the LaunchPayload stacks copy (LaunchPad.java:151,
	# items.each -- zero amounts skipped, ItemModule.java:
	# 100-106), the items.clear() (LaunchPad.java:157) and the
	# launchCounter = 0f reset (LaunchPad.java:159). The entity
	# creation/application (LaunchPad.java:150-155), the launch
	# sound and the launch effects (LaunchPad.java:149/156/158)
	# defer: the launch is reported as the pure result
	# launched_stacks (the N2234 spawned_unit precedent) plus
	# launched. source_delta is Time.delta in ticks (1.0 = one
	# tick); edelta() = efficiency * Time.delta * timeScale
	# (BuildingComp.java:1922-1929). item_capacity arrives as
	# the explicit param (the Separator precedent); both defs
	# carry itemCapacity 100 (Blocks.java:6793/6803).
	var full_step: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 0.0, "launch_time": 1200.0, "items": {}}, 1.0, 1.0, 100)
	var half_step: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 0.5, "launch_counter": 10.0, "launch_time": 1200.0, "items": {}}, 1.0, 1.0, 100)
	var scaled_step: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 0.0, "launch_time": 1200.0, "items": {}}, 1.0, 2.0, 100)
	var frozen_step: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 0.0, "launch_counter": 7.0, "launch_time": 1200.0, "items": {}}, 1.0, 1.0, 100)
	var stopped_step: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 7.0, "launch_time": 1200.0, "items": {}}, 1.0, 0.0, 100)
	proof["launch_counter_advances_with_edelta"] = is_equal_approx(float(full_step.get("launch_counter", -1.0)), 1.0) and bool(full_step.get("launched", true)) == false and is_equal_approx(float(half_step.get("launch_counter", -1.0)), 10.5) and is_equal_approx(float(scaled_step.get("launch_counter", -1.0)), 2.0) and is_equal_approx(float(frozen_step.get("launch_counter", -1.0)), 7.0) and is_equal_approx(float(stopped_step.get("launch_counter", -1.0)), 7.0)

	var boundary: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 1199.0, "launch_time": 1200.0, "items": {"copper": 60, "lead": 40}}, 1.0, 1.0, 100)
	var boundary_stacks: Dictionary = boundary.get("launched_stacks", {})
	var over_full: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 0.0, "launch_counter": 1200.0, "launch_time": 1200.0, "items": {"copper": 150}}, 1.0, 1.0, 100)
	var advanced_def: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 1799.0, "launch_time": 1800.0, "items": {"copper": 100}}, 1.0, 1.0, 100)
	proof["launch_fires_when_full_and_timed"] = bool(boundary.get("launched", false)) and is_equal_approx(float(boundary.get("launch_counter", -1.0)), 0.0) and Dictionary(boundary.get("items", {"x": 1})).is_empty() and int(boundary_stacks.get("copper", -1)) == 60 and int(boundary_stacks.get("lead", -1)) == 40 and bool(over_full.get("launched", false)) and is_equal_approx(float(over_full.get("launch_counter", -1.0)), 0.0) and int(Dictionary(over_full.get("launched_stacks", {})).get("copper", -1)) == 150 and bool(advanced_def.get("launched", false)) and is_equal_approx(float(advanced_def.get("launch_counter", -1.0)), 0.0)

	var zero_skip: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 1199.0, "launch_time": 1200.0, "items": {"copper": 100, "lead": 0}}, 1.0, 1.0, 100)
	var zero_stacks: Dictionary = zero_skip.get("launched_stacks", {})
	var after_launch: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 0.0, "launch_time": 1200.0, "items": {}}, 1.0, 1.0, 100)
	proof["launch_clears_items_and_resets"] = bool(zero_skip.get("launched", false)) and Dictionary(zero_skip.get("items", {"x": 1})).is_empty() and is_equal_approx(float(zero_skip.get("launch_counter", -1.0)), 0.0) and int(zero_stacks.get("copper", -1)) == 100 and not zero_stacks.has("lead") and bool(after_launch.get("launched", true)) == false and is_equal_approx(float(after_launch.get("launch_counter", -1.0)), 1.0) and Dictionary(after_launch.get("launched_stacks", {"x": 1})).is_empty()

	var not_full: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 1200.0, "launch_time": 1200.0, "items": {"copper": 99}}, 1.0, 1.0, 100)
	var empty_pad: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 5000.0, "launch_time": 1200.0, "items": {}}, 1.0, 1.0, 100)
	proof["no_launch_when_not_full"] = bool(not_full.get("launched", true)) == false and is_equal_approx(float(not_full.get("launch_counter", -1.0)), 1201.0) and int(Dictionary(not_full.get("items", {})).get("copper", -1)) == 99 and Dictionary(not_full.get("launched_stacks", {"x": 1})).is_empty() and bool(empty_pad.get("launched", true)) == false and is_equal_approx(float(empty_pad.get("launch_counter", -1.0)), 5001.0)

	var early: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 1.0, "launch_counter": 500.0, "launch_time": 1200.0, "items": {"copper": 100}}, 1.0, 1.0, 100)
	var just_below: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_advance_state({"efficiency": 0.5, "launch_counter": 1199.0, "launch_time": 1200.0, "items": {"copper": 100}}, 1.0, 1.0, 100)
	proof["no_launch_before_launch_time"] = bool(early.get("launched", true)) == false and is_equal_approx(float(early.get("launch_counter", -1.0)), 501.0) and int(Dictionary(early.get("items", {})).get("copper", -1)) == 100 and bool(just_below.get("launched", true)) == false and is_equal_approx(float(just_below.get("launch_counter", -1.0)), 1199.5) and int(Dictionary(just_below.get("items", {})).get("copper", -1)) == 100

	# --- Live tick: a launch-pad placed live; the tick driver
	# is called directly (as the N2172 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. One 1/60s tick is one source
	# tick: efficiency folds the power min 0.5, the counter
	# advances 0.5, launchTime stamps 1200.0 for the
	# launch-pad def, and nothing launches (the pad is empty).
	# A second tick advances the counter to 1.0. Then a full
	# pad at 1199.5 with full power launches live: the items
	# clear, the counter resets, and launched_stacks carries
	# the copper.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var catalog_ok: bool = int(blocks_by_id["launch-pad"].properties.get("itemCapacity", -1)) == 100

	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})

	# A freshly bound frame carries the updateTile state keys
	# with the Java build-field defaults (LaunchPad.java:84).
	var fresh_defaults: bool = launch_pad_frame.has("launch_counter") and is_equal_approx(float(launch_pad_frame["launch_counter"]), 0.0) and launch_pad_frame.has("items") and Dictionary(launch_pad_frame["items"]).is_empty()

	launch_pad_frame["power_status"] = 0.5
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var tick1_ok: bool = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 0.5) and is_equal_approx(float(launch_pad_frame.get("launch_time", -1.0)), 1200.0) and bool(launch_pad_frame.get("launched", true)) == false and Dictionary(launch_pad_frame.get("items", {"x": 1})).is_empty()

	launch_pad_frame["power_status"] = 0.5
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var tick2_ok: bool = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 1.0) and bool(launch_pad_frame.get("launched", true)) == false

	launch_pad_frame["items"] = {"copper": 100}
	launch_pad_frame["launch_counter"] = 1199.5
	launch_pad_frame["power_status"] = 1.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	var live_launch_ok: bool = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 1.0) and bool(launch_pad_frame.get("launched", false)) and Dictionary(launch_pad_frame.get("items", {"x": 1})).is_empty() and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 0.0) and int(Dictionary(launch_pad_frame.get("launched_stacks", {})).get("copper", -1)) == 100
	proof["live_tick_writes_advance_frame_keys"] = catalog_ok and fresh_defaults and tick1_ok and tick2_ok and live_launch_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
