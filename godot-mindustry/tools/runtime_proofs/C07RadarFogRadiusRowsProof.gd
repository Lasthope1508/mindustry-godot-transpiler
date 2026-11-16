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

	# --- Fog radius rows (N2474): RadarBuild.fogRadius()
	# (Radar.java:55-57) returns fogRadius * progress *
	# smoothEfficiency -- the field times the build
	# progress times the smoothed efficiency, Java-exact
	# multiplication order. The field is `public int
	# fogRadius = -1;` (Block.java:348); the Radar
	# constructor sets the class default `fogRadius =
	# 10;` (Radar.java:33) and the single radar def
	# overrides it to `fogRadius = 34;`
	# (Blocks.java:1991). Pure-only: the tick never
	# calls this pure -- it COMPUTES the input the
	# update_tile advance (N2190) already computes
	# inline as fog_radius_now and the draw pure
	# (N2427) already takes as the caller-supplied
	# fog_radius_live input, and the caller wires it
	# later, so this proof has no live-tick key. The
	# forceUpdate call (Radar.java:64, #127) and
	# canPickup / progress() (#34) are NOT in scope.

	# --- Full discovery: field 34, progress 1,
	# smoothEfficiency 1 -- the radar sees its full
	# def radius, 34 * 1 * 1 = 34.
	var full: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 1.0, 1.0)
	proof["fog_full"] = is_equal_approx(float(full.get("fog_radius", -1.0)), 34.0)

	# --- Zero progress: a fresh radar sees nothing --
	# 34 * 0 * 1 = 0, whatever the efficiency.
	var zero_progress: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 0.0, 1.0)
	var zero_progress_unpowered: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 0.0, 0.0)
	proof["fog_zero_progress"] = is_equal_approx(float(zero_progress.get("fog_radius", -1.0)), 0.0) and is_equal_approx(float(zero_progress_unpowered.get("fog_radius", -1.0)), 0.0)

	# --- Half efficiency: full discovery at half
	# smoothed efficiency sees half the radius --
	# 34 * 1 * 0.5 = 17 -- and half discovery at full
	# efficiency sees the same, 34 * 0.5 * 1 = 17.
	# Zero efficiency sees nothing: 34 * 1 * 0 = 0.
	var half_efficiency: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 1.0, 0.5)
	var half_discovery: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 0.5, 1.0)
	var zero_efficiency: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 1.0, 0.0)
	proof["fog_half_efficiency"] = is_equal_approx(float(half_efficiency.get("fog_radius", -1.0)), 17.0) and is_equal_approx(float(half_discovery.get("fog_radius", -1.0)), 17.0) and is_equal_approx(float(zero_efficiency.get("fog_radius", -1.0)), 0.0)

	# --- Def values: the pure takes the field as an
	# input, so the class default (10, Radar.java:33)
	# and the def override (34, Blocks.java:1991) both
	# work -- 10 * 1 * 1 = 10 vs 34 * 1 * 1 = 34.
	var class_default: Dictionary = radar_build_state.source_radar_fog_radius_state(10.0, 1.0, 1.0)
	proof["fog_def"] = is_equal_approx(float(class_default.get("fog_radius", -1.0)), 10.0) and is_equal_approx(float(full.get("fog_radius", -1.0)), 34.0)

	# --- Formula order: Java evaluates left to right,
	# (field * progress) * smoothEfficiency. With
	# field 0.1, progress 3, smoothEfficiency 3 the
	# left-to-right double is 0.9000000000000001 while
	# the reordered field * (progress * smoothEfficiency)
	# is exactly 0.9 -- so this key uses EXACT ==
	# (not is_equal_approx, which would blur the two).
	var ordered: Dictionary = radar_build_state.source_radar_fog_radius_state(0.1, 3.0, 3.0)
	proof["fog_formula_order"] = float(ordered.get("fog_radius", -1.0)) == 0.9000000000000001

	# --- Live input wiring: this pure computes the
	# SAME quantity the N2190 update_tile advance
	# computes inline as fog_radius_now -- with frame
	# progress 0.5, smoothEfficiency 1.0, efficiency
	# 1.0 (so the lerp holds 1.0), edelta 0 and delta
	# 0, the advance's fog_radius_now is 34 * 0.5 * 1
	# = 17, |17 - 0| >= 0.5 trips the gate
	# (Radar.java:63), and last_radius lands on 17 --
	# exactly this pure's output for the same inputs.
	var frame: Dictionary = {"progress": 0.5, "smooth_efficiency": 1.0, "total_progress": 0.0, "last_radius": 0.0}
	var advance: Dictionary = radar_build_state.source_radar_update_tile_state(frame, 1.0, 0.0, 0.0, 34.0, 600.0)
	var advanced: Dictionary = advance.get("advance", {})
	var live_pure: Dictionary = radar_build_state.source_radar_fog_radius_state(34.0, 0.5, 1.0)
	proof["fog_live_input"] = bool(advance.get("force_update_needed", false)) and is_equal_approx(float(advanced.get("last_radius", -1.0)), 17.0) and is_equal_approx(float(live_pure.get("fog_radius", -1.0)), 17.0) and is_equal_approx(float(advanced.get("last_radius", -1.0)), float(live_pure.get("fog_radius", -1.0)))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarFogRadiusRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
