extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Per-def stat rows (N2498): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442 / N2489 /
	# N2490 precedent). The single Accelerator def
	# interplanetary-accelerator (Blocks.java:6823-6832)
	# sets size 7, scaledHealth 80,
	# powerBufferRequirement 1,000,000f and
	# requirements copper 16000 / silicon 11000 /
	# thorium 13000 / titanium 12000 / surge-alloy
	# 6000 / phase-fabric 5000. An unknown def id
	# falls back to the CLASS defaults (the N2304
	# fallback precedent): size 1 (Block.java:215),
	# scaledHealth -1 (Block.java:188 -- the FIELD
	# default; Block.init() resolves it to 40 when
	# health == -1, Block.java:1380-1381, and that
	# resolution lives in SourceBlockInitHealthState,
	# not here), powerBufferRequirement 0f (the
	# uninitialized float field, Accelerator.java:41)
	# and NO requirements (the Block default is the
	# empty array, Block.java:356). Pure-only: the
	# caller reads it; the existing pures are
	# unchanged.

	# --- Def row: interplanetary-accelerator -- size 7,
	# scaledHealth 80, powerBufferRequirement 1,000,000f,
	# requirements copper 16000 / silicon 11000 / thorium
	# 13000 / titanium 12000 / surge-alloy 6000 /
	# phase-fabric 5000.
	var accelerator: Dictionary = accelerator_build_state.source_accelerator_per_def_stats_state("interplanetary-accelerator")
	var accelerator_requirements: Dictionary = accelerator.get("requirements", {})
	proof["stats_accelerator"] = int(accelerator.get("size", -1)) == 7 and is_equal_approx(float(accelerator.get("scaled_health", -1.0)), 80.0) and is_equal_approx(float(accelerator.get("power_buffer_requirement", -1.0)), 1000000.0) and int(accelerator_requirements.get("copper", -1)) == 16000 and int(accelerator_requirements.get("silicon", -1)) == 11000 and int(accelerator_requirements.get("thorium", -1)) == 13000 and int(accelerator_requirements.get("titanium", -1)) == 12000 and int(accelerator_requirements.get("surge-alloy", -1)) == 6000 and int(accelerator_requirements.get("phase-fabric", -1)) == 5000

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, scaledHealth -1, powerBufferRequirement
	# 0f, and NO requirements.
	var fallback: Dictionary = accelerator_build_state.source_accelerator_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = accelerator_build_state.source_accelerator_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("scaled_health", -2.0)), -1.0) and is_equal_approx(float(fallback.get("power_buffer_requirement", -1.0)), 0.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("scaled_health", -2.0)), -1.0) and is_equal_approx(float(empty_fallback.get("power_buffer_requirement", -1.0)), 0.0) and empty_requirements.is_empty()

	# --- Size / health: the def is size 7 with
	# scaledHealth 80, so Block.init computes health
	# 7 * 7 * 80 = 3920 (the catalog health); the
	# class defaults are size 1 with the -1
	# scaledHealth sentinel (Block.init resolves it
	# to 40 when health == -1).
	proof["stats_size_health"] = int(accelerator.get("size", -1)) == 7 and is_equal_approx(float(accelerator.get("scaled_health", -1.0)), 80.0) and is_equal_approx(float(accelerator.get("size", 0)) * float(accelerator.get("size", 0)) * float(accelerator.get("scaled_health", 0.0)), 3920.0) and int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("scaled_health", -2.0)), -1.0)

	# --- Power buffer: the def requires a
	# 1,000,000f battery; the class default is 0f
	# (the uninitialized field).
	proof["stats_power_buffer"] = is_equal_approx(float(accelerator.get("power_buffer_requirement", -1.0)), 1000000.0) and is_equal_approx(float(fallback.get("power_buffer_requirement", -1.0)), 0.0)

	# --- Requirements: the def dict carries
	# exactly the six items (copper 16000, silicon
	# 11000, thorium 13000, titanium 12000,
	# surge-alloy 6000, phase-fabric 5000); the
	# class fallback carries none.
	proof["stats_requirements"] = accelerator_requirements.size() == 6 and int(accelerator_requirements.get("copper", -1)) == 16000 and int(accelerator_requirements.get("silicon", -1)) == 11000 and int(accelerator_requirements.get("thorium", -1)) == 13000 and int(accelerator_requirements.get("titanium", -1)) == 12000 and int(accelerator_requirements.get("surge-alloy", -1)) == 6000 and int(accelerator_requirements.get("phase-fabric", -1)) == 5000 and fallback_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2422 bar pure as its caller-supplied inputs
	# -- the def requirement 1,000,000f with a
	# 500,000f battery reads fraction 0.5 with the
	# bar present, while the class fallback 0f
	# reads bar absent (the strict > 0f gate) with
	# fraction 0.0.
	var def_bar: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.0, float(accelerator.get("power_buffer_requirement", 0.0)))
	var fallback_bar: Dictionary = accelerator_build_state.source_accelerator_power_buffer_bar_state(500000.0, float(fallback.get("power_buffer_requirement", 0.0)))
	proof["stats_live_input"] = bool(def_bar.get("bar_present", false)) and is_equal_approx(float(def_bar.get("fraction", -1.0)), 0.5) and int(def_bar.get("requirement_amount", -1)) == 1000000 and not bool(fallback_bar.get("bar_present", true)) and is_equal_approx(float(fallback_bar.get("fraction", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
