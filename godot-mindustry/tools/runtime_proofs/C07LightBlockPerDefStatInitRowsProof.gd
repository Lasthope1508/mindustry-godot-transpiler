extends Node

const main_scene := preload("res://scenes/Main.tscn")
const light_block_build_state := preload("res://src/game/SourceLightBlockBuildState.gd")
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

	# --- Per-def stat + init rows (N2500): the
	# VERIFICATION slice -- the values are already
	# constants in the driver header (the N2304 /
	# N2442 / N2489 / N2490 precedent) PLUS the
	# init derivation (the N2427 multi-entry
	# precedent). The single LightBlock def
	# illuminator (Blocks.java:6763-6767) sets
	# brightness 0.75f, radius 140f and
	# requirements graphite 12 / silicon 8 / lead
	# 8; the def sets NO size line, so size 1 is
	# the inherited Block class default
	# (Block.java:215). An unknown def id falls
	# back to the CLASS defaults (the N2304
	# fallback precedent): size 1 (Block.java:215),
	# brightness 0.9f (LightBlock.java:22), radius
	# 200f (LightBlock.java:23) and NO requirements
	# (the Block default is the empty array,
	# Block.java:356). The init rows
	# (LightBlock.init(), LightBlock.java:39-43):
	# lightRadius = radius*2.5f (:40),
	# lightClipSize = Math.max(lightClipSize,
	# lightRadius * 3f) (:41), emitLight = true
	# (:42). Pure-only: the caller reads them;
	# the existing pures are unchanged.

	# --- Def row: illuminator -- size 1 (the Block
	# class default, the def sets no size line),
	# brightness 0.75f, radius 140f, requirements
	# graphite 12 / silicon 8 / lead 8.
	var illuminator: Dictionary = light_block_build_state.source_light_block_per_def_stats_state("illuminator")
	var illuminator_requirements: Dictionary = illuminator.get("requirements", {})
	proof["stats_block"] = int(illuminator.get("size", -1)) == 1 and is_equal_approx(float(illuminator.get("brightness", -1.0)), 0.75) and is_equal_approx(float(illuminator.get("radius", -1.0)), 140.0) and int(illuminator_requirements.get("graphite", -1)) == 12 and int(illuminator_requirements.get("silicon", -1)) == 8 and int(illuminator_requirements.get("lead", -1)) == 8

	# --- Brightness / radius: the def is 0.75f /
	# 140f, the class defaults are 0.9f / 200f
	# (LightBlock.java:22-23).
	var fallback: Dictionary = light_block_build_state.source_light_block_per_def_stats_state("no-such-def")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	proof["stats_brightness_radius"] = is_equal_approx(float(illuminator.get("brightness", -1.0)), 0.75) and is_equal_approx(float(illuminator.get("radius", -1.0)), 140.0) and is_equal_approx(float(fallback.get("brightness", -1.0)), 0.9) and is_equal_approx(float(fallback.get("radius", -1.0)), 200.0)

	# --- Requirements: the def dict carries
	# exactly the three items (graphite 12,
	# silicon 8, lead 8); the class fallback
	# carries none.
	proof["stats_requirements"] = illuminator_requirements.size() == 3 and int(illuminator_requirements.get("graphite", -1)) == 12 and int(illuminator_requirements.get("silicon", -1)) == 8 and int(illuminator_requirements.get("lead", -1)) == 8 and fallback_requirements.is_empty()

	# --- Init derived: the def radius 140f
	# derives lightRadius 350f / lightClipSize
	# max(in, 1050f); the class radius 200f
	# derives 500f / max(in, 1500f); emitLight is
	# always true; the MAX keeps a larger
	# incoming clip size (2000f stays 2000f
	# against the 1050f floor).
	var def_init: Dictionary = light_block_build_state.source_light_block_init_rows_state(140.0, 0.0)
	var class_init: Dictionary = light_block_build_state.source_light_block_init_rows_state(200.0, 0.0)
	var max_init: Dictionary = light_block_build_state.source_light_block_init_rows_state(140.0, 2000.0)
	proof["stats_init_derived"] = is_equal_approx(float(def_init.get("light_radius", -1.0)), 350.0) and is_equal_approx(float(def_init.get("light_clip_size", -1.0)), 1050.0) and bool(def_init.get("emit_light", false)) and is_equal_approx(float(class_init.get("light_radius", -1.0)), 500.0) and is_equal_approx(float(class_init.get("light_clip_size", -1.0)), 1500.0) and bool(class_init.get("emit_light", false)) and is_equal_approx(float(max_init.get("light_clip_size", -1.0)), 2000.0) and bool(max_init.get("emit_light", false))

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, brightness 0.9f, radius 200f, and NO
	# requirements.
	var empty_fallback: Dictionary = light_block_build_state.source_light_block_per_def_stats_state("")
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("brightness", -1.0)), 0.9) and is_equal_approx(float(fallback.get("radius", -1.0)), 200.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("brightness", -1.0)), 0.9) and is_equal_approx(float(empty_fallback.get("radius", -1.0)), 200.0) and empty_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# init pure as its caller-supplied radius --
	# the def radius 140f derives lightRadius
	# 350f / lightClipSize max(in, 1050f), while
	# the class fallback radius 200f derives
	# 500f / max(in, 1500f).
	var live_def_init: Dictionary = light_block_build_state.source_light_block_init_rows_state(float(illuminator.get("radius", 0.0)), 0.0)
	var live_class_init: Dictionary = light_block_build_state.source_light_block_init_rows_state(float(fallback.get("radius", 0.0)), 0.0)
	proof["stats_live_input"] = is_equal_approx(float(live_def_init.get("light_radius", -1.0)), 350.0) and is_equal_approx(float(live_def_init.get("light_clip_size", -1.0)), 1050.0) and bool(live_def_init.get("emit_light", false)) and is_equal_approx(float(live_class_init.get("light_radius", -1.0)), 500.0) and is_equal_approx(float(live_class_init.get("light_clip_size", -1.0)), 1500.0) and bool(live_class_init.get("emit_light", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LightBlockPerDefStatInitRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
