extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Sense rows (N2387): PayloadDeconstructorBuild.sense()
	# (PayloadDeconstructor.java:206-216). `public double
	# sense(Content content){` + `if(deconstructing
	# instanceof UnitPayload up) return up.unit.type ==
	# content ? 1 : 0;` + `if(deconstructing instanceof
	# BuildPayload bp) return bp.build.block == content
	# ? 1 : 0;` + `return super.sense(content);`, and
	# `public double sense(LAccess sensor){` +
	# `if(sensor == LAccess.progress) return progress;`
	# + `return super.sense(sensor);`. progress is the
	# frame value the N2233 advance tracks (`public float
	# progress;`, :54) and Java returns it AS-IS -- NO
	# clamp, unlike the MendProjector clamp. The
	# deconstructing descriptor format (VERIFIED): the
	# N2233 payload dict contract -- kind ("build" /
	# "unit"), requirements, build_time; kind runs the
	# instanceof dispatch, but the descriptor carries NO
	# identity key, so the equality operand arrives as
	# the caller-supplied payload_content_id explicit
	# input (no descriptor key invented). super.sense is
	# the BuildingComp switch (BuildingComp.java:2093-
	# 2122 for LAccess, :2139-2147 for Content), already
	# modeled by the port (SourceBuildingSenseState), so
	# both pures take the caller's super.sense result as
	# super_value; null is the default branch (`default
	# -> Float.NaN; //gets converted to null in logic` /
	# `return Float.NaN; //invalid sense`).
	# Pure-only: the tick never calls sense -- sense is
	# called by logic, and the logic call site waits for
	# a logic-executor slice.
	var build_payload: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0}
	var unit_payload: Dictionary = {"kind": "unit", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 600.0}

	# --- Progress zero: progress 0.0 reads 0.0, and the
	# dispatch flag is true -- even with a super value
	# present, the progress branch ignores it.
	var zero: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress", 0.0)
	var zero_super: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress", 0.0, 99.0)
	proof["sense_progress_zero"] = bool(zero.get("is_progress", false)) and is_equal_approx(float(zero.get("value", -1.0)), 0.0) and bool(zero_super.get("is_progress", false)) and is_equal_approx(float(zero_super.get("value", -1.0)), 0.0)

	# --- Progress partial: progress 0.5 reads 0.5
	# as-is, and a progress past 1.0 reads past 1.0 --
	# Java returns progress with NO clamp (the N2233
	# advance adds shift, NOT realShift, so progress
	# can pass 1f, and the sensed value passes 1f too).
	# Unlike the MendProjector clamp, 1.25 stays 1.25.
	var half: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress", 0.5)
	var over: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress", 1.25)
	proof["sense_progress_partial"] = is_equal_approx(float(half.get("value", -1.0)), 0.5) and is_equal_approx(float(over.get("value", -1.0)), 1.25)

	# --- Super sensor: a non-progress sensor returns
	# the caller-supplied super.sense result, not the
	# frame progress. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the frame progress is 0.5.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("health", 0.5, health_super.get("health"))
	var efficiency_sensed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("efficiency", 0.5, health_super.get("efficiency"))
	proof["sense_super_sensor"] = not bool(health_sensed.get("is_progress", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("is_progress", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75)

	# --- Super default: an unknown sensor with no
	# super value returns null -- the super switch's
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). The default
	# super_value is null, so the caller passes nothing.
	# A null deconstructing payload falls through to
	# super.sense(content) the same way -- the Content
	# default (`return Float.NaN; //invalid sense`).
	var unknown_sensed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("not_a_sensor", 0.5)
	var unknown_explicit: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress2", 0.5, null)
	var content_default: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(null, "copper", "", null)
	proof["sense_super_default"] = not bool(unknown_sensed.get("is_progress", true)) and unknown_sensed.get("value", 0.0) == null and not bool(unknown_explicit.get("is_progress", true)) and unknown_explicit.get("value", 0.0) == null and not bool(content_default.get("is_unit_payload", true)) and content_default.get("value", 0.0) == null

	# --- Content unit match: a unit payload whose type
	# id matches the queried content reads 1.0 with the
	# unit-payload flag true; a different unit type
	# reads 0.0 with the flag still true -- the kind
	# key runs the instanceof dispatch, the
	# caller-supplied payload_content_id runs the
	# equality (the descriptor carries no identity key).
	var unit_match: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(unit_payload, "dagger", "dagger")
	var unit_mismatch: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(unit_payload, "flare", "dagger")
	proof["sense_content_unit_match"] = bool(unit_match.get("is_unit_payload", false)) and is_equal_approx(float(unit_match.get("value", -1.0)), 1.0) and bool(unit_mismatch.get("is_unit_payload", false)) and is_equal_approx(float(unit_mismatch.get("value", -1.0)), 0.0)

	# --- Content build match: a build payload whose
	# block id matches the queried content reads 1.0
	# with the unit-payload flag false; a different
	# block reads 0.0. A null deconstructing payload
	# falls through to super.sense(content) -- the
	# modeled item case (5 copper in the store) passes
	# through untouched.
	var build_match: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(build_payload, "conveyor", "conveyor")
	var build_mismatch: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(build_payload, "router", "conveyor")
	var item_super: Dictionary = building_sense_state.sense_content_state("item", true, 5.0, false, 0.0, false, 0.0)
	var content_super: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(null, "copper", "", item_super.get("value"))
	proof["sense_content_build_match"] = not bool(build_match.get("is_unit_payload", true)) and is_equal_approx(float(build_match.get("value", -1.0)), 1.0) and not bool(build_mismatch.get("is_unit_payload", true)) and is_equal_approx(float(build_mismatch.get("value", -1.0)), 0.0) and not bool(content_super.get("is_unit_payload", true)) and is_equal_approx(float(content_super.get("value", -1.0)), 5.0)

	# --- Live frame values: a placed deconstructor's
	# frame progress + deconstructing payload feed both
	# pures. One N2233 advance tick (delta 1.0, the
	# deconstructor def values 6f / 250, build_time
	# 60.0) moves progress 0.0 -> 0.1 (shift = edelta()
	# * deconstructSpeed / buildTime() = 1.0 * 6 / 60),
	# so the sensed progress is 0.1; the content sense
	# reads the live frame deconstructing kind ("build")
	# and matches the conveyor block id. The sense pures
	# read live frame state, they just never run inside
	# the tick.
	var payload_deconstructor_cell := Vector2i(28, 21)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	payload_deconstructor_frame["efficiency"] = 1.0
	payload_deconstructor_frame["deconstructing"] = build_payload
	payload_deconstructor_frame["progress"] = 0.0
	payload_deconstructor_frame["time"] = 0.0
	payload_deconstructor_frame["speed_scl"] = 0.0
	payload_deconstructor_frame["items"] = {}
	var advanced: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(payload_deconstructor_frame, 1.0, 1.0, 6.0, 250)
	payload_deconstructor_frame["progress"] = advanced["progress"]
	payload_deconstructor_frame["deconstructing"] = advanced["deconstructing"]
	var live_progress: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_state("progress", float(payload_deconstructor_frame.get("progress", -1.0)))
	var live_content: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_sense_content_state(payload_deconstructor_frame.get("deconstructing", null), "conveyor", "conveyor")
	proof["sense_live_frame_values"] = is_equal_approx(float(payload_deconstructor_frame.get("progress", -1.0)), 0.1) and is_equal_approx(float(live_progress.get("value", -1.0)), 0.1) and not bool(live_content.get("is_unit_payload", true)) and is_equal_approx(float(live_content.get("value", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
