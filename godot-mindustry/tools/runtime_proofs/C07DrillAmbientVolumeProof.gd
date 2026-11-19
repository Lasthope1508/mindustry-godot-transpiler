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

	# --- DrillBuild ambientVolume() super leg (N2277):
	# DrillBuild.ambientVolume() (Drill.java:257-259,
	# `public float ambientVolume(){`) returns
	# `efficiency * (size * size) / 4f;` (:258).
	# `efficiency` is the live Building efficiency
	# (`transient float efficiency;`,
	# BuildingComp.java:85), carried on the frame
	# (absent defaults to 0.0 -- the N2296 liquid-rows
	# frame-key precedent). `size` is the block size in
	# tiles (`public int size = 1;`, Block.java:215), a
	# per-def param passed explicitly (the N2212
	# per-def-param precedent): impact-drill size 4
	# (Blocks.java:3073), eruption-drill size 5
	# (Blocks.java:3096). At efficiency 1 the super is
	# 4.0 vs 6.25 -- the exact values N2271 takes as its
	# explicit super input. This slice closes the
	# super-leg deferred entry N2271 carried. There is
	# NO driver tick line: the ambient-sound live loop
	# reads ambientVolume per tick
	# (BuildingComp.java:2271); the driver side waits
	# for ambient C (N2264).

	# efficiency 0 silences the drill: 0 * 16 / 4 == 0.
	var zero: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 0.0}, 4)
	proof["ambient_volume_efficiency_zero"] = is_equal_approx(float(zero.get("ambient_volume", -1.0)), 0.0)

	# efficiency 1 with size 4 gives 4.0: 1 * 16 / 4.
	var full: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 1.0}, 4)
	proof["ambient_volume_efficiency_full"] = is_equal_approx(float(full.get("ambient_volume", -1.0)), 4.0)

	# efficiency 0.5 with size 4 gives 2.0: 0.5 * 16 / 4.
	var half: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 0.5}, 4)
	proof["ambient_volume_efficiency_half"] = is_equal_approx(float(half.get("ambient_volume", -1.0)), 2.0)

	# The Block default size 1 gives 0.25 at efficiency 1.
	var size_one: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 1.0}, 1)
	proof["ambient_volume_size_one"] = is_equal_approx(float(size_one.get("ambient_volume", -1.0)), 0.25)

	# Per-def sizes at efficiency 1 (size 4 impact-drill,
	# Blocks.java:3073; size 5 eruption-drill,
	# Blocks.java:3096): 4.0 vs 6.25 at efficiency 1, and
	# 2.0 vs 3.125 at efficiency 0.5.
	var impact_full: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 1.0}, 4)
	var eruption_full: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 1.0}, 5)
	var impact_half: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 0.5}, 4)
	var eruption_half: Dictionary = burst_drill_build_state.source_drill_ambient_volume_state({"efficiency": 0.5}, 5)
	proof["ambient_volume_per_def"] = is_equal_approx(float(impact_full.get("ambient_volume", -1.0)), 4.0) and is_equal_approx(float(eruption_full.get("ambient_volume", -1.0)), 6.25) and is_equal_approx(float(impact_half.get("ambient_volume", -1.0)), 2.0) and is_equal_approx(float(eruption_half.get("ambient_volume", -1.0)), 3.125)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillAmbientVolumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
