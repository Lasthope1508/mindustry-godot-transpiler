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

	# --- Pure gate (N2186): LaunchPadBuild.shouldConsume()
	# (LaunchPad.java:92, `public boolean shouldConsume(){`
	# with `return launchCounter < launchTime;`,
	# LaunchPad.java:94) -- the pad consumes only while its
	# launchCounter (LaunchPad.java:84, `public float
	# launchCounter;`, default 0f) is below launchTime
	# (launch-pad `launchTime = 60f * 20;`,
	# Blocks.java:6794). The override has NO enabled check --
	# enabled is handled separately by updateConsumption
	# (BuildingComp.java:1954-1957, the disabled early
	# return) and by the driver gate, the WallCrafter
	# precedent -- so the pure function reads only the
	# counter and the threshold.
	var open_gate: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 0.0, "launch_time": 1200.0})
	proof["gate_open_below_launch_time"] = bool(open_gate.get("should_consume", false)) and is_equal_approx(float(open_gate.get("launch_counter", -1.0)), 0.0)

	var closed_gate: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1200.0, "launch_time": 1200.0})
	proof["gate_closed_at_launch_time"] = bool(closed_gate.get("should_consume", true)) == false and is_equal_approx(float(closed_gate.get("launch_counter", -1.0)), 1200.0)

	var over_gate: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1500.0, "launch_time": 1200.0})
	proof["gate_closed_above_launch_time"] = bool(over_gate.get("should_consume", true)) == false and is_equal_approx(float(over_gate.get("launch_counter", -1.0)), 1500.0)

	# --- Live tick: the launch pad is a LaunchPad build with a
	# power consumer (consumePower 4f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172 proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The driver
	# stamps the per-def launchTime from the block id (the
	# catalog carries no launchTime): launch-pad 60f * 20 =
	# 1200.0. The counter advances by edelta each tick (the
	# counter half of LaunchPad.java:146); the launch fire
	# itself (consume() + LaunchPayload + Fx.launchPod +
	# items.clear + `launchCounter = 0f;`,
	# LaunchPad.java:147-159) waits for its own slice, so a
	# full pad never launches and its counter freezes at
	# launchTime with the gate closed.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var launch_pad_cell := Vector2i(28, 21)
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["launch-pad"], launch_pad_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["launch-pad"])
	var launch_pad_frame: Dictionary = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})

	# Full power: the counter advances by edelta (efficiency 1.0
	# times Time.delta = 1.0 tick per 1/60s tick), and the driver stamps launchTime
	# 1200.0 for the launch-pad def.
	launch_pad_frame["power_status"] = 1.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["counter_advances_by_edelta"] = is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 1.0) and is_equal_approx(float(launch_pad_frame.get("launch_time", -1.0)), 1200.0)

	# Gate open, half power: the old N2172 behavior is kept --
	# efficiency folds the power min 0.5.
	launch_pad_frame["launch_counter"] = 0.0
	launch_pad_frame["power_status"] = 0.5
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["efficiency_kept_when_gate_open"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5)

	# Gate closed, full power: efficiency folds to 0 through the
	# shared machinery (BuildingComp.java:1960/:1992-1994), and
	# the counter freezes at launchTime because edelta() is 0.
	# This proves the folded efficiency is 0; it carries no
	# launch/payload claim -- the launch fire
	# (LaunchPad.java:147-159) waits for its own slice.
	launch_pad_frame["launch_counter"] = 1200.0
	launch_pad_frame["power_status"] = 1.0
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_closed"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(launch_pad_frame.get("launch_counter", -1.0)), 1200.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
