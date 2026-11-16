extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# --- Pure gate (N2205): LaunchPadBuild overrides
	# shouldConsume (LaunchPad.java:92, `public boolean
	# shouldConsume(){` with `return launchCounter <
	# launchTime;`, LaunchPad.java:94) over the launch
	# counter (LaunchPad.java:84, `public float
	# launchCounter;`), which the updateTile advance alone
	# writes (LaunchPad.java:146, `if((launchCounter +=
	# edelta()) >= launchTime && items.total() >=
	# itemCapacity){`). The per-def launchTime is 1200f for
	# launch-pad (Blocks.java:6794, `launchTime = 60f *
	# 20;`) and 1800f for advanced-launch-pad
	# (Blocks.java:6804, `launchTime = 60f * 30;`),
	# overriding the class default `public float launchTime
	# = 1f;` (LaunchPad.java:32), so the gate threshold the
	# counter runs against is per-def, not a single
	# hardcoded constant. An absent `launch_counter` key
	# means "no observation yet" and preserves the N2172
	# behavior (should_consume = enabled) -- the N2191
	# precedent -- never "fully launched".
	var below: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 10.0, "enabled": true}, 1200.0)
	var advanced_below: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1500.0, "enabled": true}, 1800.0)
	proof["gate_passes_below_launch_time"] = bool(below.get("should_consume", false)) == true and bool(advanced_below.get("should_consume", false)) == true

	var at_launch_time: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 1200.0, "enabled": true}, 1200.0)
	proof["gate_blocks_at_launch_time"] = bool(at_launch_time.get("should_consume", true)) == false

	# Gate blocks when disabled: counter 10.0 but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable (the N2191
	# proof pattern).
	var disabled_gate: Dictionary = launch_pad_build_state.source_launch_pad_should_consume_state({"launch_counter": 10.0, "enabled": false}, 1200.0)
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# --- Live tick: the launch pad is a LaunchPad build
	# with a static power consumer (launch-pad,
	# consumePower 4f, Blocks.java:6797), placed live; the tick
	# driver is called directly (as the N2172/N2191/N2193 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The driver calls the gate BEFORE
	# the consumption setup (the Java order, updateConsumption
	# :2274 reads shouldConsume() at :1960), reading the
	# launch_counter the previous tick's advance stamped; the
	# advance itself runs AFTER apply_update_consumption_state and
	# cannot change the counter the gate just read on a 1/60s
	# tick in a way the efficiency keys observe -- the gate value
	# is what the consumption machinery folds. The driver selects
	# the per-def launchTime by block id (launch-pad 1200.0).
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

	# Absent key preserves the power fold: NO launch_counter key
	# at half power -- the gate preserves the N2172 behavior
	# (should_consume = enabled), so efficiency folds the power
	# min 0.5. This pins the RED absent-default decision: null
	# means "no observation yet", not "fully launched".
	launch_pad_frame.erase("launch_counter")
	launch_pad_frame["power_status"] = 0.5
	launch_pad_frame["enabled"] = true
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when fully charged: launch_counter=1200.0 (at
	# launchTime, not < launchTime) at full power -- the gate overrides
	# the power fold, efficiency 0 (BuildingComp.java:1960 +
	# 1992-1993, `if(!update){` / `efficiency =
	# optionalEfficiency = 0f;`), even though the power row
	# alone would fold 1.0.
	launch_pad_frame["launch_counter"] = 1200.0
	launch_pad_frame["power_status"] = 1.0
	launch_pad_frame["enabled"] = true
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["gate_blocks_when_fully_charged"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes below launchTime at half power: launch_counter=10.0
	# -- the power fold applies, efficiency 0.5.
	launch_pad_frame["launch_counter"] = 10.0
	launch_pad_frame["power_status"] = 0.5
	launch_pad_frame["enabled"] = true
	launch_pad_build_state.source_launch_pad_tick_buildings_state(game, 1.0 / 60.0)
	launch_pad_frame = launch_pad.get_meta(launch_pad_build_state.SOURCE_LAUNCH_PAD_BUILDING_META_KEY, {})
	proof["gate_passes_below_launch_time_live"] = is_equal_approx(float(launch_pad_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
