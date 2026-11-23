extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Write/read/version persistence (N2286): DrillBuild persists
	# exactly TWO fields, its drill progress and its warmup
	# (`public void write(Writes write){` / `super.write(write);` /
	# `write.f(progress);` / `write.f(warmup);`, Drill.java:384-387),
	# restores them only for saves at revision >= 1 (`public void read(Reads read,
	# byte revision){` / `super.read(read, revision);` / `if(revision >= 1){` /
	# `progress = read.f();` / `warmup = read.f();`, Drill.java:389-394),
	# and reports save version 1 (`public byte version(){` / `return 1;`,
	# Drill.java:380-382). The fields are the DrillBuild float fields
	# (`public float progress;` / `public float warmup;`, Drill.java:238-239),
	# already tracked frame keys advanced by updateTile (N2294).
	# super.write/read are empty BuildingComp bodies -- only the marker is recorded.
	# DrillBuild has NO readSync override. Java write.f is a 32-bit float while GDScript
	# float is 64-bit -- the pure functions add NO rounding epsilon; the proof
	# round-trips float32-safe values exactly and checks the inexact value 0.1
	# with is_equal_approx. The proof calls the pure functions with synthetic
	# frames (no live tick, no save file: the persisted values are two floats).

	# Write with an empty frame (the Java field defaults, Drill.java:238-239):
	# 0.0 / 0.0 in -> 0.0 / 0.0 out.
	var written_defaults: Dictionary = burst_drill_build_state.source_drill_write_state({})
	proof["write_defaults_zero"] = is_equal_approx(float(written_defaults.get("progress", -1.0)), 0.0) and is_equal_approx(float(written_defaults.get("warmup", -1.0)), 0.0)

	# Write 12.5 / 0.75 round-trips through read: write the values, read the
	# stored values back at revision 1 -> 12.5 / 0.75.
	var written: Dictionary = burst_drill_build_state.source_drill_write_state({"progress": 12.5, "warmup": 0.75})
	var read_back: Dictionary = burst_drill_build_state.source_drill_read_state({}, float(written.get("progress", -1.0)), float(written.get("warmup", -1.0)), 1)
	proof["write_round_trips"] = is_equal_approx(float(read_back.get("progress", -1.0)), 12.5) and is_equal_approx(float(read_back.get("warmup", -1.0)), 0.75)

	# Write returns ONLY the two persisted values: nothing else survives save/load.
	proof["write_returns_only_two_keys"] = written.size() == 2

	# Read returns ONLY the two persisted values as well.
	proof["read_returns_only_two_keys"] = read_back.size() == 2

	# Read at revision 0 keeps the frame's current values and ignores the stored
	# ones: frame 3.0 / 0.25 with stored 12.5 / 0.75 at revision 0 -> 3.0 / 0.25.
	var read_old: Dictionary = burst_drill_build_state.source_drill_read_state({"progress": 3.0, "warmup": 0.25}, 12.5, 0.75, 0)
	proof["read_ignores_old_revision"] = is_equal_approx(float(read_old.get("progress", -1.0)), 3.0) and is_equal_approx(float(read_old.get("warmup", -1.0)), 0.25)

	# Read at revision 1 applies the stored values: frame 3.0 / 0.25 with stored
	# 12.5 / 0.75 at revision 1 -> 12.5 / 0.75.
	var read_new: Dictionary = burst_drill_build_state.source_drill_read_state({"progress": 3.0, "warmup": 0.25}, 12.5, 0.75, 1)
	proof["read_applies_at_revision_one"] = is_equal_approx(float(read_new.get("progress", -1.0)), 12.5) and is_equal_approx(float(read_new.get("warmup", -1.0)), 0.75)

	# version() returns 1, the save version; the BuildingComp base returns 0.
	var versioned: Dictionary = burst_drill_build_state.source_drill_version_state({})
	proof["version_returns_one"] = int(versioned.get("version", -1)) == 1

	# The inexact float32 value 0.1 round-trips: Java write.f stores a 32-bit
	# float, GDScript holds a 64-bit float, and the pure functions add no
	# rounding epsilon -- the value survives the round-trip within float32
	# tolerance.
	var written_inexact: Dictionary = burst_drill_build_state.source_drill_write_state({"progress": 0.1, "warmup": 0.1})
	var read_inexact: Dictionary = burst_drill_build_state.source_drill_read_state({}, float(written_inexact.get("progress", -1.0)), float(written_inexact.get("warmup", -1.0)), 1)
	proof["round_trip_inexact_float32_value"] = is_equal_approx(float(read_inexact.get("progress", -1.0)), 0.1) and is_equal_approx(float(read_inexact.get("warmup", -1.0)), 0.1)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
