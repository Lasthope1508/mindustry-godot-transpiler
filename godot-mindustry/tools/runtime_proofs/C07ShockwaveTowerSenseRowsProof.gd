extends Node

const main_scene := preload("res://scenes/Main.tscn")
const shockwave_tower_build_state := preload("res://src/game/SourceShockwaveTowerBuildState.gd")
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

	# --- Sense / warmup rows (N2390):
	# ShockwaveTowerBuild.sense()
	# (ShockwaveTower.java:109-112). `public double
	# sense(LAccess sensor) {` + `if(sensor ==
	# LAccess.progress) return reloadCounter /
	# reload;` + `return super.sense(sensor);`.
	# The ratio is BARE -- Java has NO clamp here,
	# unlike the MendProjector (Mathf.clamp(charge
	# / reload), MendProjector.java:127) and the
	# LaunchPad, so a counter past the reload reads
	# above 1.0. reload_counter is the frame value
	# the N2187 gate and the N2247 advance track
	# (`public float reloadCounter =
	# Mathf.random(reload);`, :67); reload is
	# per-def (shockwave-tower 80f,
	# Blocks.java:2044; the class default is
	# `public float reload = 60f * 1.5f;`, :26).
	# warmup() (ShockwaveTower.java:115-118):
	# `public float warmup(){` + `return heat;`
	# -- heat is the frame value (`public float
	# heat = 0f;`, :68), set to 1f on fire and
	# decayed every tick by the N2247 advance.
	# super.sense is the BuildingComp switch
	# (BuildingComp.java:2094-2123, `return
	# switch(sensor){`), already modeled by the port
	# (SourceBuildingSenseState), so the pure takes
	# the caller's super.sense result as super_value;
	# null is the default branch (`default ->
	# Float.NaN; //gets converted to null in
	# logic`). Pure-only: the tick never calls sense
	# or warmup -- sense is called by logic, warmup
	# by UI/display, and the call sites wait for
	# logic-executor / display slices.

	# --- Progress zero: counter 0.0 at any reload
	# reads 0.0, and the dispatch flag is true.
	var zero_def: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 0.0, 80.0)
	var zero_class: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 0.0, 90.0)
	proof["sense_progress_zero"] = bool(zero_def.get("is_progress", false)) and is_equal_approx(float(zero_def.get("value", -1.0)), 0.0) and bool(zero_class.get("is_progress", false)) and is_equal_approx(float(zero_class.get("value", -1.0)), 0.0)

	# --- Progress partial: counter 40.0 at the
	# shockwave-tower reload 80f reads 0.5, and
	# counter 45.0 at the class default reload
	# 60f * 1.5f = 90f reads 0.5 too -- the reload
	# is the per-def explicit input, not a
	# constant. And the ratio is BARE: counter
	# 120.0 at reload 80f reads 1.5, NOT clamped
	# to 1.0 -- Java has no clamp here, unlike
	# the MendProjector.
	var half_def: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 40.0, 80.0)
	var half_class: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 45.0, 90.0)
	var over: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", 120.0, 80.0)
	proof["sense_progress_partial"] = is_equal_approx(float(half_def.get("value", -1.0)), 0.5) and is_equal_approx(float(half_class.get("value", -1.0)), 0.5) and is_equal_approx(float(over.get("value", -1.0)), 1.5)

	# --- Warmup value: warmup() returns heat
	# unchanged -- 0.6 reads 0.6, 0.0 reads 0.0,
	# and 1.0 (just fired) reads 1.0.
	var warm_half: Dictionary = shockwave_tower_build_state.source_shockwave_tower_warmup_state(0.6)
	var warm_zero: Dictionary = shockwave_tower_build_state.source_shockwave_tower_warmup_state(0.0)
	var warm_full: Dictionary = shockwave_tower_build_state.source_shockwave_tower_warmup_state(1.0)
	proof["warmup_value"] = is_equal_approx(float(warm_half.get("warmup", -1.0)), 0.6) and is_equal_approx(float(warm_zero.get("warmup", -1.0)), 0.0) and is_equal_approx(float(warm_full.get("warmup", -1.0)), 1.0)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# counter ratio. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the counter ratio would be 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("health", 40.0, 80.0, health_super.get("health"))
	var efficiency_sensed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("efficiency", 40.0, 80.0, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	var unknown_sensed: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("not_a_sensor", 40.0, 80.0)
	var unknown_explicit: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress2", 40.0, 80.0, null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null

	# --- Live frame values: a placed shockwave
	# tower's frame counter + heat feed the progress
	# + warmup values. The frame starts at
	# reload_counter 40.0 with heat 0.6 and
	# potential_efficiency 1.0; one N2247 advance
	# tick (delta 1.0, check not ready) leaves the
	# counter at 40.0 (the fire gate needs counter
	# >= reload) and decays heat by 1.0 / 80f to
	# 0.5875, so the sensed progress at the def
	# reload 80f is 0.5 and the warmup reads
	# 0.5875 -- the pures read live frame state,
	# they just never run inside the tick.
	var shockwave_tower_cell := Vector2i(28, 21)
	var shockwave_tower := Sprite2D.new()
	game.add_child(shockwave_tower)
	game.call("record_placed_block", shockwave_tower, blocks_by_id["shockwave-tower"], shockwave_tower_cell)
	shockwave_tower_build_state.source_shockwave_tower_bind_frame_state(shockwave_tower, blocks_by_id["shockwave-tower"])
	var shockwave_tower_frame: Dictionary = shockwave_tower.get_meta(shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BUILDING_META_KEY, {})
	shockwave_tower_frame["potential_efficiency"] = 1.0
	shockwave_tower_frame["reload_counter"] = 40.0
	shockwave_tower_frame["heat"] = 0.6
	var tower_reload: float = float(blocks_by_id["shockwave-tower"].properties.get("reload", 80.0))
	var advanced: Dictionary = shockwave_tower_build_state.source_shockwave_tower_update_tile_advance_state(shockwave_tower_frame, 1.0, tower_reload, shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_BULLET_DAMAGE, shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_FALLOFF_COUNT, shockwave_tower_build_state.SOURCE_SHOCKWAVE_TOWER_COOLDOWN_MULTIPLIER, [], false)
	shockwave_tower_frame["reload_counter"] = advanced.get("reload_counter", shockwave_tower_frame.get("reload_counter", 0.0))
	shockwave_tower_frame["heat"] = advanced.get("heat", shockwave_tower_frame.get("heat", 0.0))
	var live: Dictionary = shockwave_tower_build_state.source_shockwave_tower_sense_state("progress", float(shockwave_tower_frame.get("reload_counter", -1.0)), tower_reload)
	var live_warmup: Dictionary = shockwave_tower_build_state.source_shockwave_tower_warmup_state(float(shockwave_tower_frame.get("heat", -1.0)))
	proof["sense_live_frame_values"] = is_equal_approx(tower_reload, 80.0) and is_equal_approx(float(shockwave_tower_frame.get("reload_counter", -1.0)), 40.0) and is_equal_approx(float(shockwave_tower_frame.get("heat", -1.0)), 0.5875) and is_equal_approx(float(live.get("value", -1.0)), 0.5) and is_equal_approx(float(live_warmup.get("warmup", -1.0)), 0.5875)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ShockwaveTowerSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
