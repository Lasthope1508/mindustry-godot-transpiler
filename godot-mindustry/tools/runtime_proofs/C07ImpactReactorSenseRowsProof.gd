extends Node

const main_scene := preload("res://scenes/Main.tscn")
const impact_reactor_build_state := preload("res://src/game/SourceImpactReactorBuildState.gd")
const building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# --- Sense rows (N2391): ImpactReactorBuild.sense()
	# (ImpactReactor.java:119-122). `public double
	# sense(LAccess sensor){` + `if(sensor ==
	# LAccess.heat) return warmup;` + `return
	# super.sense(sensor);`. warmup is the frame value
	# the N2192 advance tracks (`public float warmup,
	# totalProgress;`, :75) -- sense(heat) returns it
	# DIRECTLY, no clamp, no ratio (unlike the N2383
	# MendProjector progress clamp). super.sense is the
	# BuildingComp switch (BuildingComp.java:2093-2125,
	# `return switch(sensor){`), already modeled by the
	# port (SourceBuildingSenseState), so the pure takes
	# the caller's super.sense result as super_value;
	# null is the default branch (`default -> Float.NaN;
	# //gets converted to null in logic`). The warmup()
	# accessor (ImpactReactor.java:104-106) is a second
	# pure: the DRAWER calls it (DrawPlasma scales
	# light/alpha by build.warmup(), DrawPlasma.java:32,
	# 42), not logic. Pure-only: the tick never calls
	# sense or warmup() -- sense is called by logic,
	# warmup() by the drawer, and both call sites wait
	# for their own slices.

	# --- Heat zero: warmup 0.0 reads 0.0, and the
	# dispatch flag is true. The warmup accessor reads
	# the same 0.0.
	var zero: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("heat", 0.0)
	var zero_warmup: Dictionary = impact_reactor_build_state.source_impact_reactor_warmup_state(0.0)
	proof["sense_heat_zero"] = bool(zero.get("is_heat", false)) and is_equal_approx(float(zero.get("value", -1.0)), 0.0) and is_equal_approx(float(zero_warmup.get("value", -1.0)), 0.0)

	# --- Heat partial: warmup 0.5 reads 0.5 exactly --
	# no clamp, no ratio, the frame warmup IS the heat
	# value. The warmup accessor reads the same 0.5.
	var half: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("heat", 0.5)
	var half_warmup: Dictionary = impact_reactor_build_state.source_impact_reactor_warmup_state(0.5)
	proof["sense_heat_partial"] = bool(half.get("is_heat", false)) and is_equal_approx(float(half.get("value", -1.0)), 0.5) and is_equal_approx(float(half_warmup.get("value", -1.0)), 0.5)

	# --- Heat full: warmup 1.0 reads 1.0, and the
	# dispatch flag is true. The warmup accessor reads
	# the same 1.0.
	var full: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("heat", 1.0)
	var full_warmup: Dictionary = impact_reactor_build_state.source_impact_reactor_warmup_state(1.0)
	proof["sense_heat_full"] = bool(full.get("is_heat", false)) and is_equal_approx(float(full.get("value", -1.0)), 1.0) and is_equal_approx(float(full_warmup.get("value", -1.0)), 1.0)

	# --- Super sensor: a non-heat sensor returns the
	# caller-supplied super.sense result, not the frame
	# warmup. health 80.0 (via the modeled BuildingComp
	# health case, `case health -> health;`) and
	# efficiency 0.75 (via `case efficiency ->
	# efficiency;`) both pass through untouched, with
	# the dispatch flag false -- even though the frame
	# warmup would read 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("health", 0.5, health_super.get("health"))
	var efficiency_sensed: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("efficiency", 0.5, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_heat", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_heat", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	# progress is a real sensor the reactor override
	# does not handle, so it falls through to super too.
	var unknown_sensed: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("not_a_sensor", 0.5)
	var progress_sensed: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("progress", 0.5, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_heat", true)) and unknown_sensed.get("value", 0.0) == null and not bool(progress_sensed.get("is_heat", true)) and progress_sensed.get("value", 0.0) == null

	# --- Live frame values: a placed impact reactor's
	# frame warmup feeds the heat value. The frame
	# starts at warmup 0.5 with efficiency 1.0 and
	# power_status 1.0, so the gate holds; one N2192
	# advance tick (time_scale 1.0, delta 60.0 = 1s)
	# lerps the warmup toward 1.0 at warmupSpeed
	# 0.001, so the live warmup is 0.53 -- the sense
	# pure and the warmup accessor both read the live
	# frame state, they just never run inside the tick.
	var impact_reactor_cell := Vector2i(30, 21)
	var impact_reactor := Sprite2D.new()
	game.add_child(impact_reactor)
	game.call("record_placed_block", impact_reactor, blocks_by_id["impact-reactor"], impact_reactor_cell)
	impact_reactor_build_state.source_impact_reactor_bind_frame_state(impact_reactor, blocks_by_id["impact-reactor"])
	var impact_reactor_frame: Dictionary = impact_reactor.get_meta(impact_reactor_build_state.SOURCE_IMPACT_REACTOR_BUILDING_META_KEY, {})
	impact_reactor_frame["efficiency"] = 1.0
	impact_reactor_frame["power_status"] = 1.0
	impact_reactor_frame["warmup"] = 0.5
	impact_reactor_frame["total_progress"] = 0.0
	var advance: Dictionary = impact_reactor_build_state.source_impact_reactor_update_tile_advance_state(impact_reactor_frame, 1.0, 60.0)
	impact_reactor_frame["warmup"] = advance.get("warmup", 0.0)
	var live: Dictionary = impact_reactor_build_state.source_impact_reactor_sense_state("heat", float(impact_reactor_frame.get("warmup", -1.0)))
	var live_warmup: Dictionary = impact_reactor_build_state.source_impact_reactor_warmup_state(float(impact_reactor_frame.get("warmup", -1.0)))
	proof["sense_live_frame_values"] = is_equal_approx(float(impact_reactor_frame.get("warmup", -1.0)), 0.53) and is_equal_approx(float(live.get("value", -1.0)), 0.53) and is_equal_approx(float(live_warmup.get("value", -1.0)), 0.53)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ImpactReactorSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
