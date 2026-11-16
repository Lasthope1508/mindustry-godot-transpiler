extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Bar row (N2464): PayloadDeconstructor.
	# setBars() (PayloadDeconstructor.java:45-49)
	# adds the "progress" bar -- the label is the
	# bundle KEY "bar.progress" itself (the 3-arg
	# Bar constructor takes the key directly,
	# Bar.java:23-29, and resolves it at render
	# via Core.bundle.get(name, name), Bar.java:
	# 25; the bundle value is "Build Progress",
	# bundle.properties:1299), the color is
	# Pal.ammo, the fraction is the build
	# progress RAW (the Bar clamps at render,
	# Bar.java:80; the 3-arg constructor stores
	# it raw, Bar.java:27). There is NO Core.
	# bundle.format Dict form here (the N2450
	# Dict form applies only when Java calls
	# Core.bundle.format with args, which this
	# bar does not). Progress can pass 1f (the
	# N2233 advance adds shift, NOT realShift),
	# so the overfull case reports raw here and
	# the Bar draws it full (the N2422 lesson).
	# Pure-only: the tick never calls setBars.

	# --- Bar label: the label is the bundle KEY
	# "bar.progress" at every progress value --
	# 0.0, 0.5, 1.0 and the overfull 1.5 -- and
	# the bar name is "progress".
	var zero_bar: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_bar_state(0.0)
	var half_bar: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_bar_state(0.5)
	var full_bar: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_bar_state(1.0)
	var over_bar: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_bar_state(1.5)
	proof["bar_label"] = str(zero_bar.get("label", "")) == "bar.progress" and str(half_bar.get("label", "")) == "bar.progress" and str(full_bar.get("label", "")) == "bar.progress" and str(over_bar.get("label", "")) == "bar.progress" and str(zero_bar.get("bar_name", "")) == "progress"

	# --- Bar color: the color token is
	# "Pal.ammo" at every progress value --
	# 0.0, 0.5, 1.0 and the overfull 1.5 --
	# carried as a symbolic token, never
	# resolved to RGB (the N2373 precedent).
	proof["bar_color"] = str(zero_bar.get("color", "")) == "Pal.ammo" and str(half_bar.get("color", "")) == "Pal.ammo" and str(full_bar.get("color", "")) == "Pal.ammo" and str(over_bar.get("color", "")) == "Pal.ammo"

	# --- Bar fraction zero: progress 0.0 reads
	# fraction 0.0.
	proof["bar_fraction_zero"] = is_equal_approx(float(zero_bar.get("fraction", -1.0)), 0.0) and is_equal_approx(float(zero_bar.get("progress", -1.0)), 0.0)

	# --- Bar fraction half: progress 0.5 reads
	# fraction 0.5.
	proof["bar_fraction_half"] = is_equal_approx(float(half_bar.get("fraction", -1.0)), 0.5) and is_equal_approx(float(half_bar.get("progress", -1.0)), 0.5)

	# --- Bar fraction full: progress 1.0 reads
	# fraction 1.0.
	proof["bar_fraction_full"] = is_equal_approx(float(full_bar.get("fraction", -1.0)), 1.0) and is_equal_approx(float(full_bar.get("progress", -1.0)), 1.0)

	# --- Bar fraction raw overfull: progress
	# 1.5 reads fraction 1.5 RAW -- the pure
	# does NOT clamp (the Bar clamps at render,
	# Bar.java:80); a second overfull value
	# 2.25 stays 2.25 too.
	var over2_bar: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_bar_state(2.25)
	proof["bar_fraction_raw_overfull"] = is_equal_approx(float(over_bar.get("fraction", -1.0)), 1.5) and is_equal_approx(float(over2_bar.get("fraction", -1.0)), 2.25)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorBarRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
