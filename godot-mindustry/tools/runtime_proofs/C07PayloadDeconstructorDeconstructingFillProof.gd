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

	# --- Pure handlePayload (N2291): handlePayload
	# (PayloadBlock.java:121-127): `this.payload =
	# (T)payload;` (:122), `this.payVector.set(source).
	# sub(this).clamp(-size * tilesize / 2f, -size *
	# tilesize / 2f, size * tilesize / 2f, size * tilesize
	# / 2f);` (:123), `this.payRotation =
	# payload.rotation();` (:124), `updatePayload();`
	# (:126) -- plus the Deconstructor override
	# (PayloadDeconstructor.java:98-101): `super.
	# handlePayload(source, payload);` (:99) then `accum =
	# null;` (:100). updatePayload() only positions the
	# live payload entity (`payload.set(x + payVector.x, y
	# + payVector.y, payRotation);`, PayloadBlock.java:176)
	# and the port has no live payload entity, so it is
	# NOT ported. The clamp is Vec2.clamp(minx, miny,
	# maxx, maxy) (arc Vec2.java:318-322), clamping each
	# axis to +/-size*tilesize/2: size 5 (deconstructor,
	# Blocks.java:6654) gives +/-20.0; size 3
	# (small-deconstructor, Blocks.java:6645) gives
	# +/-12.0.
	# N2308: the fixture doubles as the live-tick push, so it carries the block_size key the
	# intake gate reads (a 2-tile payload, fits maxPayloadSize 4); the pure handle / move-in
	# calls below ignore the extra key.
	var fixture: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0, "rotation": 45.0, "block_size": 2, "marker": "first"}
	var handled: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 24.0, 8.0, 0.0, 0.0, 45.0, 5, 8.0)
	var handled_vector: Dictionary = handled.get("pay_vector", {})
	proof["handle_sets_payload_and_clears_accum"] = handled.get("payload", {}) == fixture and is_equal_approx(float(handled_vector.get("x", 0.0)), 20.0) and is_equal_approx(float(handled_vector.get("y", 0.0)), 8.0) and is_equal_approx(float(handled.get("pay_rotation", -1.0)), 45.0) and handled.get("accum", {}) == null

	var clamped5: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 100.0, -100.0, 0.0, 0.0, 0.0, 5, 8.0)
	var clamped5_vector: Dictionary = clamped5.get("pay_vector", {})
	var clamped3: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 100.0, -100.0, 0.0, 0.0, 0.0, 3, 8.0)
	var clamped3_vector: Dictionary = clamped3.get("pay_vector", {})
	var clamped3_neg: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, -100.0, 100.0, 0.0, 0.0, 0.0, 3, 8.0)
	var clamped3_neg_vector: Dictionary = clamped3_neg.get("pay_vector", {})
	var unclamped: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 5.0, -5.0, 0.0, 0.0, 0.0, 5, 8.0)
	var unclamped_vector: Dictionary = unclamped.get("pay_vector", {})
	var rotated135: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 0.0, 0.0, 0.0, 0.0, 135.0, 5, 8.0)
	var rotated_neg90: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_handle_payload_state(fixture, 0.0, 0.0, 0.0, 0.0, -90.0, 5, 8.0)
	proof["handle_sets_payload_and_clears_accum"] = bool(proof["handle_sets_payload_and_clears_accum"]) and is_equal_approx(float(clamped5_vector.get("x", 0.0)), 20.0) and is_equal_approx(float(clamped5_vector.get("y", 0.0)), -20.0) and is_equal_approx(float(clamped3_vector.get("x", 0.0)), 12.0) and is_equal_approx(float(clamped3_vector.get("y", 0.0)), -12.0) and is_equal_approx(float(clamped3_neg_vector.get("x", 0.0)), -12.0) and is_equal_approx(float(clamped3_neg_vector.get("y", 0.0)), 12.0) and is_equal_approx(float(unclamped_vector.get("x", 0.0)), 5.0) and is_equal_approx(float(unclamped_vector.get("y", 0.0)), -5.0) and is_equal_approx(float(rotated135.get("pay_rotation", -1.0)), 135.0) and is_equal_approx(float(rotated_neg90.get("pay_rotation", -1.0)), -90.0) and clamped5.get("accum", {}) == null and clamped3.get("accum", {}) == null

	# --- Pure moveInPayload handoff (N2291): the
	# updateTile else-if branch
	# (PayloadDeconstructor.java:197-202),
	# `}else if(moveInPayload(false) && payload != null){`
	# `accum = new float[payload.requirements().length];`
	# `deconstructing = payload;` `payload = null;`
	# `progress = 0f;`. moveInPayload(false)
	# (PayloadBlock.java:186-197): null payload returns
	# false BEFORE any movement (:187); rotate is FALSE so
	# the rotation branch (:191-193) never runs;
	# `payVector.approach(Vec2.ZERO, payloadSpeed *
	# delta());` (:194) moves the offset toward zero at
	# payloadSpeed * delta() -- the SCALED delta
	# (BuildingComp.java:1922-1924, `return Time.delta *
	# timeScale;`), NOT edelta(); the deconstructor
	# payloadSpeed is 1f (PayloadDeconstructor.java:31),
	# the PayloadBlock class default 0.7f
	# (PayloadBlock.java:18); `return hasArrived();`
	# (:196) with `return payVector.isZero(0.01f);`
	# (PayloadBlock.java:242-244, Vec2.java:679-681,
	# `return len2() < margin;`) -- the SQUARED length
	# against 0.01, so a vector of length 0.09 has
	# already arrived.
	var approached: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 5.0, "y": 0.0}, null, 0.7, 1.0, 1.0)
	var approached_vector: Dictionary = approached.get("pay_vector_after", {})
	var approached07: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 5.0, "y": 0.0}, null, 0.7, 1.0, 0.7)
	var approached07_vector: Dictionary = approached07.get("pay_vector_after", {})
	var snapped: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 0.05, "y": 0.0}, null, 0.7, 1.0, 1.0)
	var snapped_vector: Dictionary = snapped.get("pay_vector_after", {})
	# The 0.01f arrival margin is a SQUARED length:
	# (0.05, 0) approached by 0.01 lands at (0.04, 0),
	# len2 0.0016 < 0.01 -- arrived without reaching zero;
	# (0.2, 0) approached by 0.01 lands at (0.19, 0),
	# len2 0.0361 > 0.01 -- not arrived.
	var threshold_in: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 0.05, "y": 0.0}, null, 0.0, 0.01, 1.0)
	var threshold_in_vector: Dictionary = threshold_in.get("pay_vector_after", {})
	var threshold_out: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 0.2, "y": 0.0}, null, 0.0, 0.01, 1.0)
	var threshold_out_vector: Dictionary = threshold_out.get("pay_vector_after", {})
	proof["move_in_approaches_zero"] = bool(approached.get("arrived", true)) == false and is_equal_approx(float(approached_vector.get("x", 0.0)), 4.0) and is_equal_approx(float(approached_vector.get("y", 0.0)), 0.0) and is_equal_approx(float(approached07_vector.get("x", 0.0)), 4.3) and is_equal_approx(float(approached07_vector.get("y", 0.0)), 0.0) and bool(snapped.get("arrived", false)) == true and is_equal_approx(float(snapped_vector.get("x", 0.0)), 0.0) and is_equal_approx(float(snapped_vector.get("y", 0.0)), 0.0) and bool(threshold_in.get("arrived", false)) == true and is_equal_approx(float(threshold_in_vector.get("x", 0.0)), 0.04) and bool(threshold_out.get("arrived", true)) == false and is_equal_approx(float(threshold_out_vector.get("x", 0.0)), 0.19) and not approached.has("pay_rotation")

	# Arrival hands the payload to deconstructing: the
	# held payload clears, progress resets to 0f, and
	# accum rebuilds as a zero array the length of the
	# payload requirements (2 here).
	var handed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 0.05, "y": 0.0}, null, 0.7, 1.0, 1.0)
	proof["handoff_sets_deconstructing_on_arrival"] = bool(handed.get("arrived", false)) == true and handed.get("deconstructing", null) == fixture and handed.get("payload_after", {}) == null and is_equal_approx(float(handed.get("progress_after", -1.0)), 0.0) and (handed.get("accum_after", []) as Array) == [0.0, 0.0]

	# Before arrival nothing hands off: the payload stays
	# held, progress and accum pass through unchanged,
	# only the pay_vector moves.
	var waiting: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(fixture, {"x": 5.0, "y": 0.0}, [1.0, 2.0], 0.7, 1.0, 1.0)
	var waiting_vector: Dictionary = waiting.get("pay_vector_after", {})
	proof["no_handoff_before_arrival"] = bool(waiting.get("arrived", true)) == false and waiting.get("deconstructing", {}) == null and waiting.get("payload_after", null) == fixture and is_equal_approx(float(waiting.get("progress_after", -1.0)), 0.7) and (waiting.get("accum_after", []) as Array) == [1.0, 2.0] and is_equal_approx(float(waiting_vector.get("x", 0.0)), 4.0) and is_equal_approx(float(waiting_vector.get("y", 0.0)), 0.0)

	# Without a payload there is no move-in at all:
	# moveInPayload returns false before the approach, so
	# the pay_vector is untouched.
	var empty: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_move_in_payload_state(null, {"x": 5.0, "y": 0.0}, [1.0, 2.0], 0.7, 1.0, 1.0)
	var empty_vector: Dictionary = empty.get("pay_vector_after", {})
	proof["no_handoff_without_payload"] = bool(empty.get("arrived", true)) == false and empty.get("deconstructing", {}) == null and empty.get("payload_after", {}) == null and is_equal_approx(float(empty.get("progress_after", -1.0)), 0.7) and (empty.get("accum_after", []) as Array) == [1.0, 2.0] and is_equal_approx(float(empty_vector.get("x", 0.0)), 5.0) and is_equal_approx(float(empty_vector.get("y", 0.0)), 0.0)

	# --- Live tick: the payload-deconstructor is a
	# PayloadDeconstructor build with a power consumer
	# (consumePower 3f), placed live; the tick driver is
	# called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/
	# N2161 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. The intake runs BEFORE the
	# consumption fold and the advance call: Java
	# handlePayload is an external call (the source's
	# moveOutPayload or a unit drop), so it lands before
	# the next tick starts. The pushed payload arrives
	# 0.05 from the deconstructor, so one tick moves it
	# in (payloadSpeed 1f * delta 1 tick snaps the
	# 0.05 offset to zero) and the handoff fills
	# deconstructing on the same tick. At fold time
	# deconstructing is still null, so the N2210 gate is
	# false and efficiency folds to 0 -- payRotation
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

	payload_deconstructor_frame["power_status"] = 1.0
	payload_deconstructor_frame["world_pos"] = {"x": 0.0, "y": 0.0}
	payload_deconstructor_frame["incoming_source_pos"] = {"x": 0.05, "y": 0.0}
	payload_deconstructor_frame["incoming_payload"] = fixture
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var live_deconstructing: Variant = payload_deconstructor_frame.get("deconstructing", null)
	var live_accum: Array = payload_deconstructor_frame.get("accum", [])
	proof["live_tick_fills_deconstructing"] = payload_deconstructor_frame.get("incoming_payload", {}) == null and payload_deconstructor_frame.get("payload", {}) == null and live_deconstructing is Dictionary and str(live_deconstructing.get("marker", "")) == "first" and live_accum == [0.0, 0.0] and is_equal_approx(float(payload_deconstructor_frame.get("progress", -1.0)), 0.0) and (payload_deconstructor_frame.get("pay_vector", Vector2.ONE) as Vector2) == Vector2.ZERO and is_equal_approx(float(payload_deconstructor_frame.get("pay_rotation", -1.0)), 45.0) and is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorDeconstructingFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
