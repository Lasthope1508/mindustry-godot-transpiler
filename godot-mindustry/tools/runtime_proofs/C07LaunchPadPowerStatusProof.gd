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

	# --- Pure power row (N2172): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = launch_pad_build_state.source_launch_pad_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = launch_pad_build_state.source_launch_pad_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = launch_pad_build_state.source_launch_pad_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the launch pad is a LaunchPad build with a
	# power consumer (consumePower 4f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The launch-pad tick models no
	# other consumers, so with a power consumer the first pass
	# holds only the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["launch_pad_has_power_consumer"] = bool(blocks_by_id["launch-pad"].properties.has("consumePower")) and is_equal_approx(float(blocks_by_id["launch-pad"].properties.get("consumePower", -1.0)), 4.0)

	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5.
	launch_pad_frame["power_status"] = 0.5
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	launch_pad_frame["power_status"] = 0.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
