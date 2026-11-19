extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Write/read persistence (N2310): RadarBuild persists
	# exactly ONE field, its discovery progress (`public void
	# write(Writes write){` / `super.write(write);` /
	# `write.f(progress);`, Radar.java:98-101), and restores
	# it unconditionally (`public void read(Reads read, byte
	# revision){` / `super.read(read, revision);` / `progress
	# = read.f();`, Radar.java:105-108). RadarBuild does NOT
	# override version(), so `revision` is passed to super
	# only and never read in the body -- there is no
	# `if(revision >= ...)` guard like RepairTurret's
	# (N2217). lastRadius / smoothEfficiency / totalProgress
	# are NOT persisted -- they are recomputed every tick
	# (Radar.java:61, :65, :71, N2248) -- so the write and
	# read results have exactly one key each. Java write.f
	# is a 32-bit float while GDScript float is 64-bit -- the
	# pure functions add NO rounding epsilon; the proof
	# round-trips float32-safe values exactly and checks the
	# inexact value 0.1 with is_equal_approx. The proof calls
	# the pure functions with synthetic frames (no live tick,
	# no save file: the persisted value is one float).

	# Write 0.0 (the Java field default, Radar.java:49):
	# 0.0 in -> 0.0 out.
	var written_zero: Dictionary = radar_build_state.source_radar_write_state({}, 0.0)
	proof["write_progress_zero"] = is_equal_approx(float(written_zero.get("progress", -1.0)), 0.0)

	# Write 0.5 round-trips through read: write 0.5, read
	# the stored value back at revision 1 -> 0.5.
	var written_half: Dictionary = radar_build_state.source_radar_write_state({}, 0.5)
	var read_half: Dictionary = radar_build_state.source_radar_read_state({}, float(written_half.get("progress", -1.0)), 1)
	proof["write_progress_half_round_trips"] = is_equal_approx(float(read_half.get("progress", -1.0)), 0.5)

	# Write 1.0 (the clamp max, Radar.java:69): 1.0 in ->
	# 1.0 out.
	var written_full: Dictionary = radar_build_state.source_radar_write_state({}, 1.0)
	proof["write_progress_full"] = is_equal_approx(float(written_full.get("progress", -1.0)), 1.0)

	# Write returns ONLY progress: lastRadius /
	# smoothEfficiency / totalProgress are recomputed every
	# tick, not persisted, so the result has exactly one key.
	proof["write_returns_only_progress"] = written_half.size() == 1

	# Read returns ONLY progress as well.
	proof["read_returns_only_progress"] = read_half.size() == 1

	# Read ignores revision entirely: RadarBuild has no
	# version() override and no revision guard, so revisions
	# 0, 1 and 2 all restore the same stored value (0.5).
	var read_rev0: Dictionary = radar_build_state.source_radar_read_state({}, 0.5, 0)
	var read_rev1: Dictionary = radar_build_state.source_radar_read_state({}, 0.5, 1)
	var read_rev2: Dictionary = radar_build_state.source_radar_read_state({}, 0.5, 2)
	proof["read_ignores_revision"] = is_equal_approx(float(read_rev0.get("progress", -1.0)), 0.5) and is_equal_approx(float(read_rev1.get("progress", -1.0)), 0.5) and is_equal_approx(float(read_rev2.get("progress", -1.0)), 0.5)

	# The inexact float32 value 0.1 round-trips: Java
	# write.f stores a 32-bit float, GDScript holds a
	# 64-bit float, and the pure functions add no rounding
	# epsilon -- the value survives the round-trip within
	# float32 tolerance.
	var written_inexact: Dictionary = radar_build_state.source_radar_write_state({}, 0.1)
	var read_inexact: Dictionary = radar_build_state.source_radar_read_state({}, float(written_inexact.get("progress", -1.0)), 1)
	proof["round_trip_inexact_float32_value"] = is_equal_approx(float(read_inexact.get("progress", -1.0)), 0.1)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
