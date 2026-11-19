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

	# --- BurstDrill ambientVolume() (N2271):
	# BurstDrill.ambientVolume() (BurstDrill.java:123-125,
	# `public float ambientVolume(){`) returns
	# `super.ambientVolume() * Mathf.pow(progress(), 4f);`
	# (:124). The super is DrillBuild.ambientVolume
	# (Drill.java:257-259, `return efficiency * (size *
	# size) / 4f;`), NOT this slice: the proof passes the
	# already-computed super result as an explicit input
	# (the N2316 explicit-param precedent). progress() is
	# DrillBuild.progress (Drill.java:327-329, `return
	# dominantItem == null ? 0f : Mathf.clamp(progress /
	# getDrillTime(dominantItem));`), also NOT this slice
	# for DrillBuild: the proof passes progress explicitly.
	# There is NO driver tick line: the ambient-sound live
	# loop reads ambientVolume per tick
	# (BuildingComp.java:2271); the driver side waits for
	# ambient C (N2264).

	# progress 0 silences the drill: 4.0 * 0^4 == 0.
	var zero: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(4.0, 0.0)
	proof["ambient_volume_progress_zero"] = is_equal_approx(float(zero.get("ambient_volume", -1.0)), 0.0)

	# progress 1 passes the super through unchanged.
	var full: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(4.0, 1.0)
	proof["ambient_volume_progress_full"] = is_equal_approx(float(full.get("ambient_volume", -1.0)), 4.0)

	# progress 0.5 quarters it twice: 4.0 * 0.5^4 == 0.25.
	var half: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(4.0, 0.5)
	proof["ambient_volume_progress_half"] = is_equal_approx(float(half.get("ambient_volume", -1.0)), 0.25)

	# super 0 stays 0 at any progress.
	var super_zero: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(0.0, 1.0)
	proof["ambient_volume_super_zero"] = is_equal_approx(float(super_zero.get("ambient_volume", -1.0)), 0.0)

	# Per-def supers at efficiency 1 (size 4 impact-drill,
	# Blocks.java:3073; size 5 eruption-drill,
	# Blocks.java:3096): 4.0 vs 6.25 at progress 1, and
	# 0.25 vs 0.390625 at progress 0.5.
	var impact_full: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(4.0, 1.0)
	var eruption_full: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(6.25, 1.0)
	var impact_half: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(4.0, 0.5)
	var eruption_half: Dictionary = burst_drill_build_state.source_burst_drill_ambient_volume_state(6.25, 0.5)
	proof["ambient_volume_per_def"] = is_equal_approx(float(impact_full.get("ambient_volume", -1.0)), 4.0) and is_equal_approx(float(eruption_full.get("ambient_volume", -1.0)), 6.25) and is_equal_approx(float(impact_half.get("ambient_volume", -1.0)), 0.25) and is_equal_approx(float(eruption_half.get("ambient_volume", -1.0)), 0.390625)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillAmbientVolumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
