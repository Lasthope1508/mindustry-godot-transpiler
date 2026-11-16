extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Pure battery read (N2218): getBatteryStored
	# (PowerGraph.java:118-128, `public float getBatteryStored(){`
	# with `float totalAccumulator = 0f;` and `totalAccumulator +=
	# battery.power.status * battery.block.consPower.capacity;`
	# and `return totalAccumulator;`) sums the enabled batteries'
	# stored power, recorded each update as lastPowerStored
	# (PowerGraph.java:236, `lastPowerStored =
	# getBatteryStored();`). The canLaunch battery half-gate
	# (Accelerator.java:239-240, `power.graph.getBatteryStored()
	# >= powerBufferRequirement-0.00001f`) needs the stored total
	# at the 1,000,000f requirement (Blocks.java:6826), and the
	# powerBufferRequirement bar (Accelerator.java:105-109,
	# `() -> b.power.graph.getBatteryStored() /
	# powerBufferRequirement`) shows the stored total over the
	# requirement. A frame with no stamp reads 0.0 before the
	# first graph update -- the same null-fold shape as the N2183
	# power row. The launch itself drains the battery
	# (Accelerator.java:270, `power.graph.useBatteries(
	# powerBufferRequirement);`) -- the launch waits for its own
	# slice, so this read never drains stored power.
	var requirement: float = accelerator_build_state.SOURCE_ACCELERATOR_POWER_BUFFER_REQUIREMENT

	# Half full: 500,000 stored of the 1,000,000 requirement.
	var half: Dictionary = accelerator_build_state.source_accelerator_battery_state({"battery_stored": 500000.0}, requirement)
	proof["battery_half"] = is_equal_approx(float(half.get("battery_stored", -1.0)), 500000.0) and is_equal_approx(float(half.get("battery_fraction", -1.0)), 0.5) and bool(half.get("can_launch_battery", true)) == false

	# Full: the stored total meets the requirement, so the gate passes.
	var full: Dictionary = accelerator_build_state.source_accelerator_battery_state({"battery_stored": 1000000.0}, requirement)
	proof["battery_full"] = is_equal_approx(float(full.get("battery_stored", -1.0)), 1000000.0) and is_equal_approx(float(full.get("battery_fraction", -1.0)), 1.0) and bool(full.get("can_launch_battery", false))

	# Epsilon: 1,000,000 - 0.00001 is exactly the gate, so the
	# stored total at the epsilon passes (Accelerator.java:240).
	var epsilon: Dictionary = accelerator_build_state.source_accelerator_battery_state({"battery_stored": 999999.99999}, requirement)
	proof["battery_gate_epsilon"] = bool(epsilon.get("can_launch_battery", false))

	# Just below the epsilon: the gate stays closed.
	var below: Dictionary = accelerator_build_state.source_accelerator_battery_state({"battery_stored": 999999.9}, requirement)
	proof["battery_gate_below"] = bool(below.get("can_launch_battery", true)) == false

	# Absent stamp: 0.0 before the first graph update, so the
	# gate is false and the fraction is 0.0.
	var absent: Dictionary = accelerator_build_state.source_accelerator_battery_state({}, requirement)
	proof["battery_absent_defaults_zero"] = is_equal_approx(float(absent.get("battery_stored", -1.0)), 0.0) and is_equal_approx(float(absent.get("battery_fraction", -1.0)), 0.0) and bool(absent.get("can_launch_battery", true)) == false

	# --- Live tick: the accelerator is an Accelerator build
	# with a static power consumer (interplanetary-accelerator,
	# consumePower 10f, Blocks.java:6829), placed live; the tick
	# driver is called directly (as the N2183 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped battery_stored -- the write-back itself is
	# covered by the state test plus the battery binding tests,
	# not by a live graph-update key. The driver stamps the
	# gate and the fraction from the pre-stamped frame value.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp battery_stored on it).
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})

	# Full battery pre-stamped on the frame (the graph update
	# writes frame["battery_stored"] each tick, the N2142
	# write-back pattern extended): the driver stamps the gate
	# and the fraction from it. Full power too, so the
	# efficiency fold does not gate the tick.
	accelerator_frame["power_status"] = 1.0
	accelerator_frame["battery_stored"] = 1000000.0
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	proof["battery_live_tick_stamps_gate"] = bool(accelerator_frame.get("can_launch_battery", false)) and is_equal_approx(float(accelerator_frame.get("battery_fraction", -1.0)), 1.0) and is_equal_approx(float(accelerator_frame.get("battery_stored", -1.0)), 1000000.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorBatteryProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
