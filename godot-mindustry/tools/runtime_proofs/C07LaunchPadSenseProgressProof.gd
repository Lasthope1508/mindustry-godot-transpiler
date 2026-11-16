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

	# --- Pure sense (N2206): LaunchPadBuild overrides sense
	# (LaunchPad.java:98, `public double sense(LAccess sensor){`
	# with `if(sensor == LAccess.progress) return
	# Mathf.clamp(launchCounter / launchTime);`,
	# LaunchPad.java:99) over the launch counter
	# (LaunchPad.java:84, `public float launchCounter;`),
	# which the updateTile advance alone writes
	# (LaunchPad.java:146, `if((launchCounter += edelta())
	# >= launchTime && items.total() >= itemCapacity){`).
	# Non-progress sensors fall through to super.sense
	# (LaunchPad.java:100, `return super.sense(sensor);`),
	# and the BuildingComp super switch has NO progress case
	# (BuildingComp.java:2093, `public double sense(LAccess
	# sensor){` + 2123, `default -> Float.NaN; //gets converted
	# to null in logic`), so a logic read of `progress` on a
	# launch pad currently returns NaN/null while Java returns
	# the clamped fraction. Sense is a logic read, not a tick
	# write: NO driver tick line belongs here (the N2203
	# damage() precedent), so the proof calls the pure function
	# source_launch_pad_sense_state(frame, sensor, launch_time)
	# directly with synthetic frames. The per-def launchTime is
	# 1200f for launch-pad (Blocks.java:6794, `launchTime = 60f
	# * 20;`) and 1800f for advanced-launch-pad
	# (Blocks.java:6804, `launchTime = 60f * 30;`), overriding
	# the class default `public float launchTime = 1f;`
	# (LaunchPad.java:32). An absent `launch_counter` key reads
	# 0.0 -- the Java init default (`public float
	# launchCounter;` defaults to 0.0f), so a freshly built pad
	# senses 0.0, NOT NaN.

	# Counter below launchTime senses the fraction:
	# launch_counter=600.0 with launch_time=1200.0 senses 0.5.
	var below: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({"launch_counter": 600.0}, "progress", 1200.0)
	proof["sense_progress_below_launch_time"] = bool(below.get("handled", false)) == true and is_equal_approx(float(below.get("sense_value", -1.0)), 0.5) and bool(below.get("sense_value_is_nan", true)) == false

	# Counter at launchTime senses 1.0: launch_counter=1200.0
	# with launch_time=1200.0 -- a full pad waiting for items.
	var at_launch_time: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({"launch_counter": 1200.0}, "progress", 1200.0)
	proof["sense_progress_at_launch_time"] = bool(at_launch_time.get("handled", false)) == true and is_equal_approx(float(at_launch_time.get("sense_value", -1.0)), 1.0) and bool(at_launch_time.get("sense_value_is_nan", true)) == false

	# Counter above launchTime clamps to 1.0:
	# launch_counter=1500.0 with launch_time=1200.0 -- the
	# clamp (Mathf.clamp one-arg, [0, 1]) floors the fraction.
	var above: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({"launch_counter": 1500.0}, "progress", 1200.0)
	proof["sense_progress_above_launch_time"] = bool(above.get("handled", false)) == true and is_equal_approx(float(above.get("sense_value", -1.0)), 1.0) and bool(above.get("sense_value_is_nan", true)) == false

	# Absent launch_counter senses 0.0 (Java init): an empty
	# frame -- the counter defaults to 0.0f at Java init, so
	# clamp(0 / launchTime) = 0.0, NOT NaN. This pins the RED
	# absent-default decision.
	var absent: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({}, "progress", 1200.0)
	proof["sense_progress_absent_counter_zero"] = bool(absent.get("handled", false)) == true and is_equal_approx(float(absent.get("sense_value", -1.0)), 0.0) and bool(absent.get("sense_value_is_nan", true)) == false

	# Non-progress sensor falls through to super.sense:
	# sensor "health" -- handled false, sense_value null,
	# sense_value_is_nan true (the generic laccess wire for
	# "not handled", LaunchPad.java:100, `return
	# super.sense(sensor);`).
	var fall_through: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({"launch_counter": 600.0}, "health", 1200.0)
	proof["sense_fall_through_non_progress"] = bool(fall_through.get("handled", true)) == false and fall_through.get("sense_value", -1.0) == null and bool(fall_through.get("sense_value_is_nan", false)) == true

	# Advanced pad senses its own per-def fraction:
	# launch_counter=900.0 with launch_time=1800.0 senses 0.5
	# (advanced-launch-pad, Blocks.java:6804, `launchTime =
	# 60f * 30;`).
	var advanced: Dictionary = launch_pad_build_state.source_launch_pad_sense_state({"launch_counter": 900.0}, "progress", 1800.0)
	proof["sense_progress_advanced_pad"] = bool(advanced.get("handled", false)) == true and is_equal_approx(float(advanced.get("sense_value", -1.0)), 0.5) and bool(advanced.get("sense_value_is_nan", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadSenseProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
