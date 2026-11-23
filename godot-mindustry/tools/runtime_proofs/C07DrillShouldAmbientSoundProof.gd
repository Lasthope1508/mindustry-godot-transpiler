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

	# --- DrillBuild shouldAmbientSound() gate (N2305):
	# DrillBuild.shouldAmbientSound() (Drill.java:252-254,
	# `public boolean shouldAmbientSound(){`) returns
	# `efficiency > 0.01f && items.total() < itemCapacity;`
	# (:253). `efficiency` is the live Building efficiency
	# (`transient float efficiency;`,
	# BuildingComp.java:85); `items.total()` is the cached
	# ItemModule total (`public int total(){` with `return
	# total;`, ItemModule.java:174-175); `itemCapacity` is
	# the per-def capacity (`public int itemCapacity = 10;`,
	# Block.java:75, with `itemCapacity = 40;`,
	# Blocks.java:3078, for impact-drill and
	# `itemCapacity = 60;`, Blocks.java:3107, for
	# eruption-drill). The BuildingComp default delegates
	# to shouldConsume (BuildingComp.java:1212-1214). The
	# gate is read per tick by the ambient-sound live loop
	# (BuildingComp.java:2270-2271). This is a Drill-local
	# boolean predicate -- NOT part of the ambient B/C chain
	# (B = RepairTurret driver tick, Windows line; C =
	# SoundControl.updateLoops mixer, N2304 held). There is
	# NO driver tick line: the gate is a pure predicate the
	# loop reads; the driver side waits for ambient C (N2304).

	# Efficient with room passes the gate: 0.5 > 0.01 and 5 < 40.
	var passes: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.5, 5, 40)
	proof["gate_passes_efficient_with_room"] = bool(passes.get("should_ambient_sound", false)) == true

	# Efficiency 0 blocks the gate: 0.0 > 0.01 is false.
	var zero: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.0, 5, 40)
	proof["gate_blocks_when_efficiency_zero"] = bool(zero.get("should_ambient_sound", true)) == false

	# The efficiency threshold is strict: 0.01 > 0.01 is false.
	var threshold: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.01, 5, 40)
	proof["gate_blocks_at_threshold"] = bool(threshold.get("should_ambient_sound", true)) == false

	# A full store blocks the gate: 40 < 40 is false.
	var full: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.5, 40, 40)
	proof["gate_blocks_when_full"] = bool(full.get("should_ambient_sound", true)) == false

	# One slot short of full passes: 39 < 40.
	var room: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.5, 39, 40)
	proof["gate_passes_at_capacity_minus_one"] = bool(room.get("should_ambient_sound", false)) == true

	# Per-def capacities (impact-drill 40, Blocks.java:3078;
	# eruption-drill 60, Blocks.java:3107): 59 < 60 passes
	# but 60 < 60 blocks.
	var eruption_room: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.5, 59, 60)
	var eruption_full: Dictionary = burst_drill_build_state.source_drill_should_ambient_sound_state({}, 0.5, 60, 60)
	proof["gate_eruption_def_uses_capacity_60"] = bool(eruption_room.get("should_ambient_sound", false)) == true and bool(eruption_full.get("should_ambient_sound", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillShouldAmbientSoundProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
