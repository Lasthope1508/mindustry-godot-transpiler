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

	# --- Live tick: the intake gate (N2308): the
	# payload-deconstructor is a PayloadDeconstructor
	# build with a power consumer (consumePower 3f),
	# placed live; the tick driver is called directly
	# (as the N2147/N2148/N2149/N2150/N2153/N2154/
	# N2155/N2156/N2157/N2158/N2159/N2160/N2161 proofs
	# do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Java only ever calls handlePayload after
	# acceptPayload returns true (the pusher checks
	# first, BuildingComp.java:822-824 movePayload and
	# :844-845 dumpPayload), so the tick computes the
	# N2297 verdict from the incoming dict itself and
	# applies the push only when it accepts. The
	# incoming dict carries its requirements as the
	# N2233 array (the intake derives
	# requirements_length from its length) and gains
	# the block_size key (the payload size in tiles);
	# a push without block_size rejects (the pure
	# defaults it to maxPayloadSize + 1). The push is
	# consumed either way (the N2278 Loader
	# precedent). One deconstructor is ticked
	# sequentially (the N2297 proof pattern), the frame
	# reset between cases; the pushed payload arrives
	# 10.0 from the deconstructor, so one tick moves
	# it in by payloadSpeed 1f * delta 1 tick to 9.0
	# without arriving (the 0.01f squared-length
	# arrival needs len2 < 0.01) and the held payload
	# stays held for the key to read. At fold time
	# deconstructing is still null, so the N2210 gate
	# is false and efficiency folds to 0 -- payRotation
	# stays at the handled 45.0 (the payRotation
	# moveToward runs on edelta, which is 0).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_deconstructor_cell := Vector2i(28, 22)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp the inputs on it).
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})

	var valid_push: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "rotation": 45.0, "block_size": 2, "marker": "accept"}
	var oversize_push: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "rotation": 45.0, "block_size": 5, "marker": "oversize"}
	var no_size_push: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "rotation": 45.0, "marker": "no-size"}
	var busy_push: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "rotation": 45.0, "block_size": 2, "marker": "busy-push"}

	payload_deconstructor_frame["power_status"] = 1.0
	payload_deconstructor_frame["world_pos"] = {"x": 0.0, "y": 0.0}
	payload_deconstructor_frame["incoming_source_pos"] = {"x": 10.0, "y": 0.0}

	# Tick 1: a valid push (2 requirements, block_size 2
	# <= maxPayloadSize 4, empty deconstructor) is
	# accepted: the payload lands held, the pay_vector
	# approaches from 10.0 to 9.0 without arriving, and
	# the push is consumed.
	payload_deconstructor_frame["incoming_payload"] = valid_push
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var accepted_payload: Variant = payload_deconstructor_frame.get("payload", null)
	var accepted_vector: Vector2 = payload_deconstructor_frame.get("pay_vector", Vector2.ONE)
	proof["intake_accepts_when_verdict_true"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and accepted_payload is Dictionary and str(accepted_payload.get("marker", "")) == "accept" and payload_deconstructor_frame.get("deconstructing", {}) == null and is_equal_approx(accepted_vector.x, 9.0) and is_equal_approx(accepted_vector.y, 0.0) and is_equal_approx(float(payload_deconstructor_frame.get("pay_rotation", -1.0)), 45.0) and is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.0)

	# Reset the held payload between cases.
	payload_deconstructor_frame["payload"] = null
	payload_deconstructor_frame["pay_vector"] = Vector2.ZERO
	payload_deconstructor_frame["pay_rotation"] = 0.0
	payload_deconstructor_frame["accum"] = null

	# Tick 2: an oversize push (block_size 5 >
	# maxPayloadSize 4) is refused by the fits term:
	# nothing lands, the pay_vector is untouched, and
	# the push is still consumed.
	payload_deconstructor_frame["incoming_payload"] = oversize_push
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["intake_drops_when_verdict_false"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and payload_deconstructor_frame.get("payload", {}) == null and payload_deconstructor_frame.get("deconstructing", {}) == null and (payload_deconstructor_frame.get("pay_vector", Vector2.ONE) as Vector2) == Vector2.ZERO

	# Tick 3: a push with requirements but no block_size
	# key rejects (the pure defaults block_size to
	# maxPayloadSize + 1, so fits is false): nothing
	# lands, and the push is still consumed.
	payload_deconstructor_frame["incoming_payload"] = no_size_push
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["intake_drops_without_block_size"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and payload_deconstructor_frame.get("payload", {}) == null and payload_deconstructor_frame.get("deconstructing", {}) == null and (payload_deconstructor_frame.get("pay_vector", Vector2.ONE) as Vector2) == Vector2.ZERO

	# Tick 4: a valid push against a busy deconstructor
	# (deconstructing stamped) is refused by the
	# deconstructing_empty term: nothing lands, the
	# stamped deconstructing payload is untouched, and
	# the push is still consumed. The stamped
	# deconstructing payload is a contract-valid dict
	# (requirements + build_time), so the advance runs
	# one tick of progress on it (shift 1.0 * 6 / 60 =
	# 0.1, no finish) without disturbing the key.
	payload_deconstructor_frame["deconstructing"] = valid_push
	payload_deconstructor_frame["accum"] = null
	payload_deconstructor_frame["progress"] = 0.0
	payload_deconstructor_frame["incoming_payload"] = busy_push
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var busy_deconstructing: Variant = payload_deconstructor_frame.get("deconstructing", null)
	proof["intake_drops_when_deconstructing_busy"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and payload_deconstructor_frame.get("payload", {}) == null and busy_deconstructing is Dictionary and str(busy_deconstructing.get("marker", "")) == "accept" and is_equal_approx(float(payload_deconstructor_frame.get("progress", -1.0)), 0.1)

	# Reset the busy deconstructing payload between cases.
	payload_deconstructor_frame["deconstructing"] = null
	payload_deconstructor_frame["accum"] = null
	payload_deconstructor_frame["progress"] = 0.0
	payload_deconstructor_frame["items"] = {}

	# Tick 5: the live tick wires the gate -- with BOTH
	# an offer and a push present, the verdict from the
	# offer governs frame["accepts_payload"] (the
	# offered 5-tile payload is oversize, so the frame
	# verdict reads false) while the push is gated by
	# its own verdict (the valid 2-tile push is
	# accepted). The intake never overwrites the frame
	# verdict.
	payload_deconstructor_frame["offered_payload"] = {"requirements_length": 2, "block_size": 5}
	payload_deconstructor_frame["incoming_payload"] = valid_push
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var gated_payload: Variant = payload_deconstructor_frame.get("payload", null)
	proof["live_tick_wires_the_gate"] = bool(payload_deconstructor_frame.get("accepts_payload", true)) == false and payload_deconstructor_frame.get("incoming_payload", {}) == null and gated_payload is Dictionary and str(gated_payload.get("marker", "")) == "accept"

	# Reset the held payload and the offer between cases.
	payload_deconstructor_frame["payload"] = null
	payload_deconstructor_frame["pay_vector"] = Vector2.ZERO
	payload_deconstructor_frame["pay_rotation"] = 0.0
	payload_deconstructor_frame["accum"] = null
	payload_deconstructor_frame["offered_payload"] = null

	# Tick 6: a null push is still consumed -- the tick
	# leaves incoming_payload null, holds nothing, and
	# the frame verdicts read false with no offer.
	payload_deconstructor_frame["incoming_payload"] = null
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["null_push_still_consumed"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and payload_deconstructor_frame.get("payload", {}) == null and payload_deconstructor_frame.get("deconstructing", {}) == null and bool(payload_deconstructor_frame.get("accepts_payload", true)) == false and bool(payload_deconstructor_frame.get("accepts_unit_payload", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorIntakeGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
