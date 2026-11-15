extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_loader_build_state := preload("res://src/game/SourcePayloadLoaderBuildState.gd")
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

	# --- Pure handlePayload (N2278): handlePayload
	# (PayloadBlock.java:121-127): `this.payload =
	# (T)payload;` (:122), `this.payVector.set(source).
	# sub(this).clamp(-size * tilesize / 2f, -size *
	# tilesize / 2f, size * tilesize / 2f, size * tilesize
	# / 2f);` (:123), `this.payRotation =
	# payload.rotation();` (:124), `updatePayload();`
	# (:126) -- plus the Loader override
	# (PayloadLoader.java:104-107): `super.handlePayload
	# (source, payload);` (:105) then `exporting = false;`
	# (:106). updatePayload() only positions the live
	# payload entity (`payload.set(x + payVector.x, y +
	# payVector.y, payRotation);`, PayloadBlock.java:176)
	# and the port has no live payload entity, so it is
	# NOT ported. The clamp is Vec2.clamp(minx, miny,
	# maxx, maxy) (arc Vec2.java:318-322), clamping each
	# axis to +/-size*tilesize/2: size 3 (the only def,
	# payload-loader, Blocks.java:6682-6689) gives
	# +/-12.0; size 4 would give +/-16.0. There is NO
	# large-payload-loader def.
	var fixture: Dictionary = {"rotation": 45.0, "marker": "first"}
	var handled: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 24.0, 8.0, 0.0, 0.0, 45.0, 3, 8.0)
	var handled_vector: Dictionary = handled.get("pay_vector", {})
	proof["handle_sets_payload_and_vector"] = handled.get("payload", {}) == fixture and is_equal_approx(float(handled_vector.get("x", 0.0)), 12.0) and is_equal_approx(float(handled_vector.get("y", 0.0)), 8.0) and is_equal_approx(float(handled.get("pay_rotation", -1.0)), 45.0) and bool(handled.get("exporting", true)) == false

	var clamped3: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 100.0, -100.0, 0.0, 0.0, 0.0, 3, 8.0)
	var clamped3_vector: Dictionary = clamped3.get("pay_vector", {})
	var clamped3_neg: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, -100.0, 100.0, 0.0, 0.0, 0.0, 3, 8.0)
	var clamped3_neg_vector: Dictionary = clamped3_neg.get("pay_vector", {})
	var clamped4: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 100.0, -100.0, 0.0, 0.0, 0.0, 4, 8.0)
	var clamped4_vector: Dictionary = clamped4.get("pay_vector", {})
	var unclamped: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 5.0, -5.0, 0.0, 0.0, 0.0, 3, 8.0)
	var unclamped_vector: Dictionary = unclamped.get("pay_vector", {})
	proof["handle_clamps_pay_vector_to_half_size"] = is_equal_approx(float(clamped3_vector.get("x", 0.0)), 12.0) and is_equal_approx(float(clamped3_vector.get("y", 0.0)), -12.0) and is_equal_approx(float(clamped3_neg_vector.get("x", 0.0)), -12.0) and is_equal_approx(float(clamped3_neg_vector.get("y", 0.0)), 12.0) and is_equal_approx(float(clamped4_vector.get("x", 0.0)), 16.0) and is_equal_approx(float(clamped4_vector.get("y", 0.0)), -16.0) and is_equal_approx(float(unclamped_vector.get("x", 0.0)), 5.0) and is_equal_approx(float(unclamped_vector.get("y", 0.0)), -5.0)

	var rotated135: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 0.0, 0.0, 0.0, 0.0, 135.0, 3, 8.0)
	var rotated_neg90: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 0.0, 0.0, 0.0, 0.0, -90.0, 3, 8.0)
	var rotated0: Dictionary = payload_loader_build_state.source_payload_loader_handle_payload_state(fixture, 0.0, 0.0, 0.0, 0.0, 0.0, 3, 8.0)
	proof["handle_sets_pay_rotation"] = is_equal_approx(float(rotated135.get("pay_rotation", -1.0)), 135.0) and is_equal_approx(float(rotated_neg90.get("pay_rotation", -1.0)), -90.0) and is_equal_approx(float(rotated0.get("pay_rotation", -1.0)), 0.0)

	proof["handle_clears_exporting"] = bool(handled.get("exporting", true)) == false and bool(clamped3.get("exporting", true)) == false

	# --- Pure takePayload (N2278): takePayload
	# (PayloadBlock.java:145-149): `T t = payload;`
	# (:146), `payload = null;` (:147), `return t;`
	# (:148). Pure + tested only: the unit-pickup live
	# path waits for live units, and the move-out clear
	# is already live through the N2231 advance, so the
	# driver does NOT call it (no double clear).
	var taken: Dictionary = payload_loader_build_state.source_payload_loader_take_payload_state(fixture)
	var taken_empty: Dictionary = payload_loader_build_state.source_payload_loader_take_payload_state(null)
	proof["take_returns_and_clears_payload"] = taken.get("payload_taken", null) == fixture and taken.get("payload_after", {}) == null and taken_empty.get("payload_taken", {}) == null and taken_empty.get("payload_after", {}) == null

	# --- Live tick: the payload-loader is a PayloadLoader
	# build with a power consumer (consumePower 2f), placed
	# live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/
	# N2157/N2158/N2159/N2160/N2161 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The intake runs
	# BEFORE the consumption fold and the advance call:
	# Java handlePayload is an external call (the source's
	# moveOutPayload or a unit drop), so it lands before
	# the next tick starts. The intake reads the frame
	# inputs incoming_payload / incoming_source_pos /
	# world_pos (no live source pushes them yet) and
	# applies only when the frame payload is null
	# (acceptPayload returns `this.payload == null`,
	# PayloadBlock.java:117).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_loader_cell := Vector2i(28, 20)
	var payload_loader := Sprite2D.new()
	game.add_child(payload_loader)
	game.call("record_placed_block", payload_loader, blocks_by_id["payload-loader"], payload_loader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp the inputs on it).
	payload_loader_build_state.source_payload_loader_bind_frame_state(payload_loader, blocks_by_id["payload-loader"])
	var payload_loader_frame: Dictionary = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})

	# Empty loader, exporting left true from a previous
	# export: the push lands, exporting clears, and the
	# payVector clamps to (12, 0) at handle time -- then
	# the N2231 advance moves it in by payloadSpeed * delta
	# (0.7 * 1 tick) toward (0, 0), so one tick leaves
	# (11.3, 0); payRotation 45 moves toward rotdeg 0 by
	# payloadRotateSpeed * delta (5 * 1 tick) to 40.
	payload_loader_frame["exporting"] = true
	payload_loader_frame["power_status"] = 1.0
	payload_loader_frame["world_pos"] = {"x": 0.0, "y": 0.0}
	payload_loader_frame["incoming_source_pos"] = {"x": 100.0, "y": 0.0}
	payload_loader_frame["incoming_payload"] = {"rotation": 45.0, "marker": "first"}
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var live_payload: Variant = payload_loader_frame.get("payload", null)
	var live_vector: Dictionary = payload_loader_frame.get("pay_vector", {})
	var live_applied: bool = live_payload is Dictionary and str(live_payload.get("marker", "")) == "first" and is_equal_approx(float(live_vector.get("x", 0.0)), 11.3) and is_equal_approx(float(live_vector.get("y", 0.0)), 0.0) and payload_loader_frame.get("incoming_payload", {}) == null
	proof["handle_sets_payload_and_vector"] = bool(proof["handle_sets_payload_and_vector"]) and live_applied
	proof["handle_sets_pay_rotation"] = bool(proof["handle_sets_pay_rotation"]) and is_equal_approx(float(payload_loader_frame.get("pay_rotation", -1.0)), 40.0)
	proof["handle_clears_exporting"] = bool(proof["handle_clears_exporting"]) and bool(payload_loader_frame.get("exporting", true)) == false

	# A payload is held now: a second push is ignored (the
	# payload stays the first fixture) and the push is
	# consumed either way.
	payload_loader_frame["incoming_payload"] = {"rotation": 90.0, "marker": "second"}
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var kept_payload: Variant = payload_loader_frame.get("payload", null)
	proof["handle_ignored_when_payload_present"] = kept_payload is Dictionary and str(kept_payload.get("marker", "")) == "first" and payload_loader_frame.get("incoming_payload", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
