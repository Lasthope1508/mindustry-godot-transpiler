extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- BeamDrill getDrillTime() (N2478):
	# BeamDrill.getDrillTime() (BeamDrill.java:216-218,
	# `public float getDrillTime(Item item){`) returns
	# the drill time divided by the per-item multiplier
	# (`return drillTime / drillMultipliers.get(item,
	# 1f);`, BeamDrill.java:217). drillTime is the
	# BeamDrill field (`public float drillTime = 200f;`,
	# BeamDrill.java:39) -- NOT Drill's `public float
	# drillTime = 300;` (Drill.java:36): BeamDrill
	# extends Block, not Drill. The multiplier arrives
	# PRE-RESOLVED: the caller applies
	# `drillMultipliers.get(item, 1f)` (default 1f) at
	# the call boundary, so a missing item -- including
	# a null item -- resolves to 1.0 before this pure
	# function sees it. Per-def drillTime: plasma-bore
	# 160f, large-plasma-bore 100f (Blocks.java:3042/
	# 3055); neither def puts any multiplier, so in
	# practice every item drills at the default 1f.
	# TRAPS: multiplier 0 gives Infinity (Java float
	# division, no exception); a negative multiplier
	# passes through (no clamp); drillTime is a per-def
	# input, NOT hardcoded. TWIN-REGISTER (main-thread
	# approval 2026-11-26): the same body was already
	# ported per-class for BurstDrill (N2344) and Drill
	# (N690/N1367); this slice adds BeamDrill's own
	# function. The proof calls the pure function
	# directly with the per-def drill times and
	# pre-resolved multipliers (the N2476/N2477
	# precomputed-input pattern).

	# Class default (drillTime 200f, BeamDrill.java:39)
	# + multiplier 1 (resolved default): 200 / 1 = 200.
	var mult_one: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(200.0, 1.0)
	proof["multiplier_one_returns_drill_time"] = mult_one.get("drill_time", -1.0) == 200.0

	# Class default + multiplier 2: 200 / 2 = 100.
	var mult_two: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(200.0, 2.0)
	proof["multiplier_two_halves"] = mult_two.get("drill_time", -1.0) == 100.0

	# Plasma-bore (drillTime 160f, Blocks.java:3042)
	# + unknown item (no multiplier entry, resolves to
	# the default 1f): 160 / 1 = 160.
	var plasma_unknown: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(160.0, 1.0)
	proof["unknown_item_default_one_returns_drill_time"] = plasma_unknown.get("drill_time", -1.0) == 160.0

	# Multiplier 0: Java float division gives Infinity
	# (no exception) -- GDScript float division behaves
	# the same. The inf value itself never enters the
	# proof dict (JSON cannot carry it); only the
	# is_inf boolean does.
	var mult_zero: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(200.0, 0.0)
	proof["multiplier_zero_is_inf"] = is_inf(float(mult_zero.get("drill_time", 0.0)))

	# Negative multiplier passes through (no clamp):
	# 200 / -2 = -100.
	var mult_negative: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(200.0, -2.0)
	proof["negative_multiplier_passes_through"] = mult_negative.get("drill_time", 0.0) == -100.0

	# Large-plasma-bore (drillTime 100f,
	# Blocks.java:3055) + multiplier 2: 100 / 2 = 50.
	var large_two: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(100.0, 2.0)
	proof["large_plasma_bore_def"] = large_two.get("drill_time", -1.0) == 50.0

	# The function returns exactly one key.
	proof["returns_only_one_key"] = mult_one.size() == 1

	# A second identical call returns the same value.
	var mult_one_again: Dictionary = beam_drill_build_state.source_beam_drill_get_drill_time_state(200.0, 1.0)
	proof["idempotent_second_call"] = mult_one_again.get("drill_time", -1.0) == mult_one.get("drill_time", -2.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillGetDrillTimeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
