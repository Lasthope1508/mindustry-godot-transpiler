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

	# --- Progress / isCoreBuilt rows (N2485):
	# AcceleratorBuild.progress() (Accelerator.java:149-150)
	# returns the build progress field, and
	# isCoreBuilt() (Accelerator.java:153-154)
	# returns progress >= 1f -- the >= 1f boundary
	# is exact (progress exactly 1f IS core-built).
	# The field is `public float progress;`
	# (Accelerator.java:121), tracked on the frame
	# under the same key name (progress) since the
	# N2191 advance, which advances it (`progress +=
	# Time.delta * efficiency / buildDuration;`,
	# Accelerator.java:143) and clamps it (`progress
	# = Math.min(progress, 1f);`, Accelerator.java:144).
	# The clamp lives in updateTile, NOT in
	# progress() -- so the pure itself does not
	# clamp: it returns its input as-is, and a
	# progress above 1f still reports is_core_built
	# true. Pure-only: the caller (launch/UI path)
	# reads it; no tick wiring here, so this proof
	# has no live-tick key -- the live-input key
	# feeds the N2191 advance output (plus the tick
	# write-back) into the pure instead. Until this
	# slice, is_core_built was only an INPUT of
	# source_accelerator_get_maximum_accepted_state
	# and source_accelerator_accept_item_state -- no
	# pure COMPUTED it. The write/read serialization
	# (`write.f(progress);`, Accelerator.java:310 /
	# `progress = read.f();`, Accelerator.java:318)
	# is NOT in scope.

	# --- Zero progress: a fresh accelerator reports
	# 0 and is not core-built -- progress() returns
	# the field, and the field starts at 0 (the
	# frame default, N2191).
	var fresh: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(0.0)
	proof["progress_zero"] = is_equal_approx(float(fresh.get("progress", -1.0)), 0.0) and fresh.get("is_core_built", true) == false

	# --- Half progress: progress() is the identity
	# on the field -- 0.5 in, 0.5 out -- and half
	# built is not core-built.
	var half: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(0.5)
	proof["progress_half"] = is_equal_approx(float(half.get("progress", -1.0)), 0.5) and half.get("is_core_built", true) == false

	# --- Full progress: a fully charged accelerator
	# reports 1 and IS core-built -- 1.0 in, 1.0
	# out, is_core_built true.
	var full: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(1.0)
	proof["progress_full"] = is_equal_approx(float(full.get("progress", -1.0)), 1.0) and full.get("is_core_built", false) == true

	# --- Core-built verdict: the verdict follows the
	# progress -- 1.0 built, 0.5 not, 0.0 not -- and
	# the verdict is what the getMaximumAccepted /
	# acceptItem accessors take as their input.
	proof["core_built_true"] = full.get("is_core_built", false) == true and half.get("is_core_built", true) == false and fresh.get("is_core_built", true) == false

	# --- Exact 1f boundary: progress exactly 1f IS
	# core-built, 0.999 is not -- the >= comparison
	# is strict about the boundary, not a rounding.
	# The pure itself does NOT clamp (progress()
	# returns the field as-is): 1.5 in, 1.5 out,
	# is_core_built true -- the clamp is the
	# advance's job, not the accessor's.
	var below: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(0.999)
	var over: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(1.5)
	proof["core_built_boundary"] = full.get("is_core_built", false) == true and below.get("is_core_built", true) == false and is_equal_approx(float(over.get("progress", -1.0)), 1.5) and over.get("is_core_built", false) == true

	# --- Live input wiring: this pure reads the
	# SAME frame progress key the N2191 advance
	# writes -- with frame progress 0.5, efficiency
	# 1.0, source_delta 30 over buildDuration 120,
	# the advance lands on 0.75, the tick writes it
	# back to frame["progress"] (SourceAcceleratorBuildState
	# tick), and the pure fed that live value
	# reports 0.75, not core-built -- exactly the
	# advance output. The advance clamps to 1f
	# (Accelerator.java:144): frame progress 0.999
	# plus source_delta 60 over buildDuration 120
	# would land at 1.499, but the advance clamps
	# it to 1.0, and the pure reports that clamped
	# live value with is_core_built true.
	var frame: Dictionary = {"progress": 0.5, "efficiency": 1.0}
	var advance: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(frame, 30.0)
	frame["progress"] = advance.get("progress", frame.get("progress", 0.0))
	var live_pure: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(float(frame.get("progress", -1.0)))
	var clamp_frame: Dictionary = {"progress": 0.999, "efficiency": 1.0}
	var clamp_advance: Dictionary = accelerator_build_state.source_accelerator_update_tile_advance_state(clamp_frame, 60.0)
	var clamp_pure: Dictionary = accelerator_build_state.source_accelerator_progress_is_core_built_state(float(clamp_advance.get("progress", -1.0)))
	proof["progress_live_input"] = is_equal_approx(float(advance.get("progress", -1.0)), 0.75) and is_equal_approx(float(frame.get("progress", -1.0)), 0.75) and is_equal_approx(float(live_pure.get("progress", -1.0)), 0.75) and live_pure.get("is_core_built", true) == false and is_equal_approx(float(clamp_advance.get("progress", -1.0)), 1.0) and is_equal_approx(float(clamp_pure.get("progress", -1.0)), 1.0) and clamp_pure.get("is_core_built", false) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorProgressIsCoreBuiltRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
