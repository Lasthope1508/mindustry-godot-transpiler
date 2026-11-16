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

	# --- CanPickup / progress rows (N2479):
	# RadarBuild.canPickup() (Radar.java:75-77)
	# returns false unconditionally -- the base
	# BuildingComp.canPickup() returns block.canPickup
	# (BuildingComp.java:1838-1840, default true,
	# Block.java:176), so the override is what makes
	# a radar unpickupable -- and progress()
	# (Radar.java:93-95) returns the build progress
	# field (the base BuildingComp.progress() returns
	# 0f, BuildingComp.java:617-619). The field is
	# `public float progress;` (Radar.java:49),
	# tracked on the frame under the same key name
	# (progress) since the N2190 advance, which
	# advances it (`progress += edelta() /
	# discoveryTime;`, Radar.java:68) and clamps it
	# (`progress = Mathf.clamp(progress);`,
	# Radar.java:69) to [0, 1]. The clamp lives in
	# updateTile, NOT in progress() -- so the pure
	# itself does not clamp: it returns its input
	# as-is, and the clamped key pins the LIVE input
	# (the advance output), not the pure. Pure-only:
	# the caller (pickup/UI path) reads it; no tick
	# wiring here, so this proof has no live-tick
	# key -- the live-input key feeds the N2190
	# advance output (plus the tick write-back)
	# into the pure instead. The forceUpdate call
	# (Radar.java:64, #123) and the read/write rows
	# (Radar.java:98-110, #32) are NOT in scope.

	# --- Pickup verdict: canPickup() is false
	# whatever the progress -- fresh (0.0), half
	# discovered (0.5), fully discovered (1.0).
	var pickup_fresh: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(0.0)
	var pickup_half: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(0.5)
	var pickup_full: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(1.0)
	proof["pickup_false"] = pickup_fresh.get("can_pickup", true) == false and pickup_half.get("can_pickup", true) == false and pickup_full.get("can_pickup", true) == false

	# --- Zero progress: a fresh radar reports 0 --
	# progress() returns the field, and the field
	# starts at 0 (the frame default, N2190).
	proof["progress_zero"] = is_equal_approx(float(pickup_fresh.get("progress", -1.0)), 0.0)

	# --- Half progress: progress() is the identity
	# on the field -- 0.5 in, 0.5 out.
	proof["progress_half"] = is_equal_approx(float(pickup_half.get("progress", -1.0)), 0.5)

	# --- Full progress: a fully discovered radar
	# reports 1 -- 1.0 in, 1.0 out.
	proof["progress_full"] = is_equal_approx(float(pickup_full.get("progress", -1.0)), 1.0)

	# --- Clamped live input: the N2190 advance
	# clamps progress to [0, 1] (Radar.java:69) --
	# frame progress 0.999 plus edelta 600 over
	# discoveryTime 600 would land at 1.999, but
	# the advance clamps it to 1.0, and the pure
	# reports that clamped live value. The pure
	# itself does NOT clamp (progress() returns the
	# field as-is): 1.5 in, 1.5 out -- the clamp
	# is the advance's job, not the accessor's.
	var clamp_frame: Dictionary = {"progress": 0.999, "smooth_efficiency": 1.0, "total_progress": 0.0, "last_radius": 0.0}
	var clamp_advance: Dictionary = radar_build_state.source_radar_update_tile_state(clamp_frame, 1.0, 600.0, 0.0, 34.0, 600.0)
	var clamp_advanced: Dictionary = clamp_advance.get("advance", {})
	var clamp_pure: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(float(clamp_advanced.get("progress", -1.0)))
	var unclamped_pure: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(1.5)
	proof["progress_clamped"] = is_equal_approx(float(clamp_advanced.get("progress", -1.0)), 1.0) and is_equal_approx(float(clamp_pure.get("progress", -1.0)), 1.0) and is_equal_approx(float(unclamped_pure.get("progress", -1.0)), 1.5)

	# --- Live input wiring: this pure reads the
	# SAME frame progress key the N2190 advance
	# writes -- with frame progress 0.5, efficiency
	# 1.0, edelta 60 over discoveryTime 600, the
	# advance lands on 0.6, the tick writes it back
	# to frame["progress"] (SourceRadarBuildState
	# tick), and the pure fed that live value
	# reports 0.6 -- exactly the advance output.
	var frame: Dictionary = {"progress": 0.5, "smooth_efficiency": 1.0, "total_progress": 0.0, "last_radius": 0.0}
	var advance: Dictionary = radar_build_state.source_radar_update_tile_state(frame, 1.0, 60.0, 0.0, 34.0, 600.0)
	var advanced: Dictionary = advance.get("advance", {})
	frame["progress"] = advanced.get("progress", frame.get("progress", 0.0))
	var live_pure: Dictionary = radar_build_state.source_radar_can_pickup_progress_state(float(frame.get("progress", -1.0)))
	proof["progress_live_input"] = is_equal_approx(float(advanced.get("progress", -1.0)), 0.6) and is_equal_approx(float(frame.get("progress", -1.0)), 0.6) and is_equal_approx(float(live_pure.get("progress", -1.0)), 0.6) and is_equal_approx(float(live_pure.get("progress", -1.0)), float(advanced.get("progress", -1.0)))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarCanPickupProgressProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
