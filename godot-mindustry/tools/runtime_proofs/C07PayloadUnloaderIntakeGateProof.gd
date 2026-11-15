extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_module(amounts: Array, current: int) -> Dictionary:
	return {"liquids": amounts, "current": current, "flow": null}


func _payload_block(has_items: bool, unloadable: bool, item_capacity: int, size: int, has_liquids: bool, liquid_capacity: float, cons_power_capacity: Variant, cons_power_buffered: bool) -> Dictionary:
	return {"has_items": has_items, "unloadable": unloadable, "item_capacity": item_capacity, "size": size, "has_liquids": has_liquids, "liquid_capacity": liquid_capacity, "cons_power_capacity": cons_power_capacity, "cons_power_buffered": cons_power_buffered}


func _payload(block: Dictionary, items: Dictionary, liquids: Dictionary, power_status: float, is_build: bool, size_px: float, marker: String) -> Dictionary:
	return {"block": block, "build": {"items": items, "liquids": liquids, "power_status": power_status}, "is_build_payload": is_build, "size": size_px, "marker": marker}


func _payload_no_descriptor(block: Dictionary, items: Dictionary, liquids: Dictionary, power_status: float, marker: String) -> Dictionary:
	return {"block": block, "build": {"items": items, "liquids": liquids, "power_status": power_status}, "marker": marker}


func _incoming(payload: Dictionary, offset_x: float, offset_y: float) -> Dictionary:
	return {"payload": payload, "source_offset": {"x": offset_x, "y": offset_y}}


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

	# --- Live tick: the intake gate (N2313): the
	# payload-unloader is a PayloadUnloader build with a
	# power consumer (consumePower 2f), placed live; the
	# tick driver is called directly (as the
	# N2163/N2209/N2232/N2279/N2293/N2296 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Java only ever
	# calls handlePayload after acceptPayload returns true
	# (the pusher checks first, BuildingComp.java:822-824
	# movePayload and :844-845 dumpPayload), so the tick
	# computes the N2296 verdict from the incoming dict
	# itself and applies the push only when it accepts.
	# The incoming payload dict gains the is_build_payload
	# / size keys (the N2296 descriptor contract); a push
	# without them rejects (the pure defaults
	# is_build_payload to false and fits to false without
	# a size), as does a non-dict push. Occupancy and
	# rejection differ: an input that arrives while a
	# payload is held STAYS for a later tick (the N2279
	# keep-for-retry, preserved), while a rejected push is
	# DROPPED, still consumed -- a non-container / oversize
	# / non-BuildPayload push would retry forever. One
	# unloader is ticked sequentially (the N2308 proof
	# pattern), the frame reset between cases; the pushed
	# payload arrives 0.5 from the unloader, so one tick
	# moves it in by payloadSpeed 0.7 * delta 1 tick to the
	# center (moved_in true) and the held payload stays
	# held for the key to read. The pushed payloads hold
	# items, so shouldExport stays false and the advance
	# keeps them on the frame. The load timer is live since
	# N2320 and its clock is NOT cleared by the between-case
	# resets, so it fires on tick 4 (clock 3 -> 4 past the
	# 2f / efficiency threshold) and unloads the held
	# payload's items -- but no key after tick 1 asserts item
	# counts, and tick 1 itself does not fire (clock 0 -> 1),
	# so the items_unloaded == 0 assertion still holds.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unloader_cell := Vector2i(28, 20)
	var unloader := Sprite2D.new()
	game.add_child(unloader)
	game.call("record_placed_block", unloader, blocks_by_id["payload-unloader"], unloader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp the inputs on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	var empty_liquids: Dictionary = _liquid_module([0.0], 0)
	var item_block: Dictionary = _payload_block(true, true, 100, 2, false, 0.0, null, false)
	var valid_push: Dictionary = _payload(item_block, {"copper": 5}, empty_liquids, 0.0, true, 16.0, "accept")
	valid_push["rotation"] = 0.0
	var oversize_push: Dictionary = _payload(item_block, {"copper": 5}, empty_liquids, 0.0, true, 32.0, "oversize")
	oversize_push["rotation"] = 0.0
	var no_descriptor_push: Dictionary = _payload_no_descriptor(item_block, {"copper": 5}, empty_liquids, 0.0, "no-descriptor")
	no_descriptor_push["rotation"] = 0.0
	var keep_push: Dictionary = _payload(item_block, {"copper": 5}, empty_liquids, 0.0, true, 16.0, "keep-push")
	keep_push["rotation"] = 0.0
	var held_payload: Dictionary = _payload(item_block, {"copper": 5}, empty_liquids, 0.0, true, 16.0, "held")
	held_payload["rotation"] = 0.0

	unloader_frame["power_status"] = 1.0

	# Tick 1: a valid push (a fitting 2-tile item
	# container, empty unloader) is accepted: the payload
	# lands held, the pay_vector moves in from (0.5, 0) to
	# the center, the push is consumed, and the
	# newly-arrived payload feeds shouldConsume the same
	# tick (efficiency folds the power min 1.0).
	unloader_frame["incoming_payload"] = _incoming(valid_push, 0.5, 0.0)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var accepted_payload: Variant = unloader_frame.get("payload", null)
	var accepted_vector: Dictionary = unloader_frame.get("pay_vector", {})
	proof["intake_accepts_when_verdict_true"] = unloader_frame.get("incoming_payload", {}) == null and accepted_payload is Dictionary and str(accepted_payload.get("marker", "")) == "accept" and is_equal_approx(float(accepted_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(accepted_vector.get("y", -1.0)), 0.0) and bool(unloader_frame.get("moved_in", false)) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0) and int(unloader_frame.get("items_unloaded", -1)) == 0 and bool(unloader_frame.get("accepts_payload", true)) == false

	# Reset the held payload between cases.
	unloader_frame["payload"] = null
	unloader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_frame["pay_rotation"] = 0.0

	# Tick 2: an oversize push (size 32 = 4 tiles >
	# maxBlockSize 3) is refused by the fits term:
	# nothing lands, the pay_vector is untouched, the
	# push is still consumed, and efficiency folds 0
	# (shouldConsume reads payload null).
	unloader_frame["incoming_payload"] = _incoming(oversize_push, 0.5, 0.0)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var dropped_vector: Dictionary = unloader_frame.get("pay_vector", {})
	proof["intake_drops_when_verdict_false"] = unloader_frame.get("incoming_payload", {}) == null and unloader_frame.get("payload", {}) == null and is_equal_approx(float(dropped_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(dropped_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0)

	# Tick 3: a push with no descriptor keys (a plain
	# N2232 payload dict, no is_build_payload / size)
	# rejects (the pure defaults is_build_payload to
	# false and fits to false without a size): nothing
	# lands, and the push is still consumed.
	unloader_frame["incoming_payload"] = _incoming(no_descriptor_push, 0.5, 0.0)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var nodesc_vector: Dictionary = unloader_frame.get("pay_vector", {})
	proof["intake_drops_without_descriptor"] = unloader_frame.get("incoming_payload", {}) == null and unloader_frame.get("payload", {}) == null and is_equal_approx(float(nodesc_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(nodesc_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0)

	# Tick 4: a valid push against an occupied unloader
	# (a payload already held) is KEPT for retry -- the
	# N2279 keep-for-retry, preserved: the push is NOT
	# consumed, the held payload is untouched, and the
	# verdict is never evaluated (an occupied frame
	# would read has_payload true and reject, but
	# occupancy is not rejection).
	unloader_frame["payload"] = held_payload
	unloader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_frame["pay_rotation"] = 0.0
	unloader_frame["incoming_payload"] = _incoming(keep_push, 0.5, 0.0)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var kept_incoming: Variant = unloader_frame.get("incoming_payload", null)
	var kept_payload: Dictionary = {}
	if kept_incoming is Dictionary:
		kept_payload = (kept_incoming as Dictionary).get("payload", {})
	var kept_held: Variant = unloader_frame.get("payload", null)
	var kept_vector: Dictionary = unloader_frame.get("pay_vector", {})
	proof["intake_keeps_when_occupied"] = kept_incoming is Dictionary and str(kept_payload.get("marker", "")) == "keep-push" and kept_held is Dictionary and str(kept_held.get("marker", "")) == "held" and is_equal_approx(float(kept_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(kept_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0)

	# Reset the held payload and the kept push between
	# cases (the kept push would otherwise land on the
	# next tick, now that the frame is empty).
	unloader_frame["payload"] = null
	unloader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_frame["pay_rotation"] = 0.0
	unloader_frame["incoming_payload"] = null
	unloader_frame["offered_payload"] = null

	# Tick 5: the live tick wires the gate -- with BOTH
	# an offer and a push present, the verdict from the
	# offer governs frame["accepts_payload"] (the offered
	# 4-tile payload is oversize, so the frame verdict
	# reads false) while the push is gated by its own
	# verdict (the valid 2-tile push is accepted). The
	# intake never overwrites the frame verdict: the
	# intake accepted, but the frame still reads false.
	unloader_frame["offered_payload"] = {"is_build_payload": true, "size": 32.0, "block": item_block}
	unloader_frame["incoming_payload"] = _incoming(valid_push, 0.5, 0.0)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var gated_payload: Variant = unloader_frame.get("payload", null)
	proof["live_tick_wires_the_gate"] = bool(unloader_frame.get("accepts_payload", true)) == false and unloader_frame.get("incoming_payload", {}) == null and gated_payload is Dictionary and str(gated_payload.get("marker", "")) == "accept" and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0)

	# Reset the held payload and the offer between cases.
	unloader_frame["payload"] = null
	unloader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	unloader_frame["pay_rotation"] = 0.0
	unloader_frame["offered_payload"] = null

	# Tick 6: a null push is still consumed -- the tick
	# leaves incoming_payload null, holds nothing, and
	# the frame verdicts read false with no offer.
	unloader_frame["incoming_payload"] = null
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	proof["null_push_still_consumed"] = unloader_frame.get("incoming_payload", {}) == null and unloader_frame.get("payload", {}) == null and bool(unloader_frame.get("accepts_payload", true)) == false and bool(unloader_frame.get("accepts_item", true)) == false and bool(unloader_frame.get("accepts_liquid", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderIntakeGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
