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

	# --- Pure updateTile advance (N2207): LaunchPadBuild.updateTile
	# (LaunchPad.java:143, `public void updateTile(){`) advances
	# the launch counter by edelta() every tick
	# (LaunchPad.java:146, `if((launchCounter += edelta())
	# >= launchTime && items.total() >= itemCapacity){`) over
	# the launch counter (LaunchPad.java:84, `public float
	# launchCounter;`), and launches only when the counter
	# reaches launchTime AND the pad holds a full itemCapacity
	# of items, resetting the counter on launch
	# (`launchCounter = 0f;`, LaunchPad.java:160). edelta() is
	# efficiency * delta (BuildingComp.java:1927-1928, `public
	# float edelta(){` with `return efficiency * delta();`, and
	# `public float delta(){` with `return Time.delta *
	# timeScale;`, BuildingComp.java:1922-1923 -- timeScale is 1
	# by default and the port passes the raw tick seconds, the
	# N2190 driver convention). There is NO clamp at launchTime:
	# the counter keeps growing past it while the pad waits for
	# items (the N2192 no-clamp precedent). The launch side
	# effects -- consume(), the launch sound, the LaunchPayload
	# entity spawn, Fx.launchPod, items.clear() and Effect.shake
	# (LaunchPad.java:148-158) -- wait for their own slice; the
	# proof calls the pure function
	# source_launch_pad_update_tile_state(frame, delta,
	# launch_time, item_capacity) directly with synthetic
	# frames and checks the `launched` flag it returns. The
	# per-def launchTime is 1200f for launch-pad
	# (Blocks.java:6794, `launchTime = 60f * 20;`) and 1800f
	# for advanced-launch-pad (Blocks.java:6804, `launchTime =
	# 60f * 30;`), overriding the class default `public float
	# launchTime = 1f;` (LaunchPad.java:32); itemCapacity is
	# 100 for both defs (Blocks.java:6793, 6803,
	# `itemCapacity = 100;`). An absent `launch_counter` key
	# starts at 0.0 -- the Java init default (`public float
	# launchCounter;` defaults to 0.0f) -- and an absent
	# `items_total` key reads 0.0, because a fresh ItemModule
	# totals 0 (`protected int total;`, ItemModule.java:25).

	# Counter advances by efficiency * delta: launch_counter
	# 600.0 with efficiency 1.0, delta 1.0, launch_time 1200.0
	# and no items advances to 601.0 without launching.
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"launch_counter": 600.0, "efficiency": 1.0, "items_total": 0.0}, 1.0, 1200.0, 100.0)
	proof["update_tile_advances_counter_by_edelta"] = is_equal_approx(float(advanced.get("launch_counter", -1.0)), 601.0) and bool(advanced.get("launched", true)) == false

	# No efficiency means no advance: launch_counter 600.0
	# with efficiency 0.0 stays 600.0 -- a pad with no power
	# never launches, its counter frozen.
	var frozen: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"launch_counter": 600.0, "efficiency": 0.0, "items_total": 0.0}, 1.0, 1200.0, 100.0)
	proof["update_tile_no_advance_without_efficiency"] = is_equal_approx(float(frozen.get("launch_counter", -1.0)), 600.0) and bool(frozen.get("launched", true)) == false

	# Launch fires when full: launch_counter 1199.0 with
	# efficiency 1.0, delta 1.0 reaches 1200.0 and items_total
	# 100.0 meets itemCapacity 100.0 -- launched true and the
	# counter resets to 0.0.
	var launched: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"launch_counter": 1199.0, "efficiency": 1.0, "items_total": 100.0}, 1.0, 1200.0, 100.0)
	proof["update_tile_launches_when_full"] = bool(launched.get("launched", false)) == true and is_equal_approx(float(launched.get("launch_counter", -1.0)), 0.0)

	# Full counter without enough items stays full: counter
	# 1199.0 advances to 1200.0 but items_total 50.0 is below
	# itemCapacity -- launched false and the counter is NOT
	# reset and NOT clamped, it stays 1200.0 waiting for items.
	var waiting: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"launch_counter": 1199.0, "efficiency": 1.0, "items_total": 50.0}, 1.0, 1200.0, 100.0)
	proof["update_tile_no_launch_without_items"] = bool(waiting.get("launched", true)) == false and is_equal_approx(float(waiting.get("launch_counter", -1.0)), 1200.0)

	# Absent launch_counter starts at zero (Java init): an
	# empty counter with efficiency 1.0, delta 1.0 advances
	# from 0.0 to 1.0 without launching. This pins the RED
	# absent-default decision.
	var absent: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"efficiency": 1.0, "items_total": 0.0}, 1.0, 1200.0, 100.0)
	proof["update_tile_absent_counter_starts_zero"] = is_equal_approx(float(absent.get("launch_counter", -1.0)), 1.0) and bool(absent.get("launched", true)) == false

	# Advanced pad launches on its own per-def time:
	# launch_counter 1799.0 with efficiency 1.0, delta 1.0
	# reaches 1800.0 and items_total 100.0 meets itemCapacity
	# -- launched true and the counter resets to 0.0
	# (advanced-launch-pad, Blocks.java:6804, `launchTime =
	# 60f * 30;`).
	var advanced_pad: Dictionary = launch_pad_build_state.source_launch_pad_update_tile_state({"launch_counter": 1799.0, "efficiency": 1.0, "items_total": 100.0}, 1.0, 1800.0, 100.0)
	proof["update_tile_advanced_pad_launches"] = bool(advanced_pad.get("launched", false)) == true and is_equal_approx(float(advanced_pad.get("launch_counter", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
