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

	# --- Live tick: the intake gate (N2315): the
	# payload-loader is a PayloadLoader build with a
	# power consumer (consumePower 2f), placed live;
	# the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/
	# N2156/N2157/N2158/N2159/N2160/N2161 proofs do),
	# not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142.
	# Java only ever calls handlePayload after
	# acceptPayload returns true (the pusher checks
	# first, BuildingComp.java:822-824 movePayload and
	# :844-845 dumpPayload, and the unit drop at
	# InputHandler.java:667-669), so the tick computes
	# the N2295 verdict from the incoming dict itself
	# and applies the push only when it accepts. The
	# incoming dict IS the N2295 descriptor
	# (is_build_payload / block_size / has_items /
	# unloadable / item_capacity / has_liquids /
	# liquid_capacity / has_cons_power /
	# cons_power_buffered); a push without block_size
	# gets the rejecting default (maxBlockSize + 1)
	# from the intake (the N2308 missing-block_size
	# precedent -- the pure defaults block_size to 0,
	# which fits). The push is consumed either way
	# (the N2278 drop). One loader is ticked
	# sequentially (the N2297 proof pattern), the frame
	# reset between cases; the pushed payload arrives
	# 100.0 from the loader, so the handle clamps the
	# payVector to (12, 0) and one tick moves it in by
	# payloadSpeed 0.7 * delta 1 tick to (11.3, 0)
	# without arriving (the 0.01f squared-length
	# arrival needs len2 < 0.01) and the held payload
	# stays held for the key to read; payRotation 45
	# moves toward rotdeg 0 by payloadRotateSpeed 5 *
	# delta 1 tick to 40 (the N2278 live-fill numbers).
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

	var valid_push: Dictionary = {"is_build_payload": true, "block_size": 2, "has_items": true, "unloadable": true, "item_capacity": 10, "rotation": 45.0, "marker": "accept"}
	var oversize_push: Dictionary = {"is_build_payload": true, "block_size": 4, "has_items": true, "unloadable": true, "item_capacity": 10, "rotation": 45.0, "marker": "oversize"}
	var no_size_push: Dictionary = {"is_build_payload": true, "has_items": true, "unloadable": true, "item_capacity": 10, "rotation": 45.0, "marker": "no-size"}

	payload_loader_frame["power_status"] = 1.0
	payload_loader_frame["world_pos"] = {"x": 0.0, "y": 0.0}
	payload_loader_frame["incoming_source_pos"] = {"x": 100.0, "y": 0.0}

	# Tick 1: a valid push (an item container, block_size
	# 2 <= maxBlockSize 3, empty loader) is accepted:
	# the payload lands held, the pay_vector clamps to
	# (12, 0) at handle time and moves in to (11.3, 0),
	# payRotation moves from 45 to 40, exporting clears,
	# and the push is consumed.
	payload_loader_frame["exporting"] = true
	payload_loader_frame["incoming_payload"] = valid_push
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var accepted_payload: Variant = payload_loader_frame.get("payload", null)
	var accepted_vector: Dictionary = payload_loader_frame.get("pay_vector", {})
	proof["intake_accepts_when_verdict_true"] = payload_loader_frame.get("incoming_payload", {}) == null and accepted_payload is Dictionary and str(accepted_payload.get("marker", "")) == "accept" and is_equal_approx(float(accepted_vector.get("x", 0.0)), 11.3) and is_equal_approx(float(accepted_vector.get("y", 0.0)), 0.0) and is_equal_approx(float(payload_loader_frame.get("pay_rotation", -1.0)), 40.0) and bool(payload_loader_frame.get("exporting", true)) == false

	# Reset the held payload between cases.
	payload_loader_frame["payload"] = null
	payload_loader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	payload_loader_frame["pay_rotation"] = 0.0

	# Tick 2: an oversize push (block_size 4 >
	# maxBlockSize 3) is refused by the fits term:
	# nothing lands, the pay_vector is untouched, and
	# the push is still consumed (the N2278 drop).
	payload_loader_frame["incoming_payload"] = oversize_push
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var oversize_vector: Dictionary = payload_loader_frame.get("pay_vector", {})
	proof["intake_drops_when_verdict_false"] = payload_loader_frame.get("incoming_payload", {}) == null and payload_loader_frame.get("payload", {}) == null and is_equal_approx(float(oversize_vector.get("x", 0.0)), 0.0) and is_equal_approx(float(oversize_vector.get("y", 0.0)), 0.0)

	# Tick 3: a push with the item-container flags but
	# no block_size key rejects (the intake injects the
	# rejecting default maxBlockSize + 1, so fits is
	# false): nothing lands, and the push is still
	# consumed.
	payload_loader_frame["incoming_payload"] = no_size_push
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var no_size_vector: Dictionary = payload_loader_frame.get("pay_vector", {})
	proof["intake_drops_without_block_size"] = payload_loader_frame.get("incoming_payload", {}) == null and payload_loader_frame.get("payload", {}) == null and is_equal_approx(float(no_size_vector.get("x", 0.0)), 0.0) and is_equal_approx(float(no_size_vector.get("y", 0.0)), 0.0)

	# Tick 4: a valid push against a loader already
	# holding a payload is refused by the base gate
	# (super.acceptPayload returns this.payload ==
	# null, PayloadBlock.java:117): nothing lands, the
	# held payload is untouched, and the push is still
	# consumed.
	payload_loader_frame["payload"] = {"marker": "held"}
	payload_loader_frame["incoming_payload"] = valid_push
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var kept_payload: Variant = payload_loader_frame.get("payload", null)
	proof["intake_drops_when_payload_present"] = payload_loader_frame.get("incoming_payload", {}) == null and kept_payload is Dictionary and str(kept_payload.get("marker", "")) == "held"

	# Reset the held payload between cases.
	payload_loader_frame["payload"] = null
	payload_loader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	payload_loader_frame["pay_rotation"] = 0.0

	# Tick 5: the live tick wires the gate -- with BOTH
	# an offer and a push present, the verdict from the
	# offer governs frame["accepts_payload"] (the
	# offered 5-tile payload is oversize, so the frame
	# verdict reads false) while the push is gated by
	# its own verdict (the valid 2-tile push is
	# accepted). The intake never overwrites the frame
	# verdict.
	payload_loader_frame["offered_payload"] = {"is_build_payload": true, "block_size": 5, "has_items": true, "unloadable": true, "item_capacity": 100}
	payload_loader_frame["incoming_payload"] = valid_push
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var gated_payload: Variant = payload_loader_frame.get("payload", null)
	proof["live_tick_wires_the_gate"] = bool(payload_loader_frame.get("accepts_payload", true)) == false and payload_loader_frame.get("incoming_payload", {}) == null and gated_payload is Dictionary and str(gated_payload.get("marker", "")) == "accept"

	# Reset the held payload and the offer between cases.
	payload_loader_frame["payload"] = null
	payload_loader_frame["pay_vector"] = {"x": 0.0, "y": 0.0}
	payload_loader_frame["pay_rotation"] = 0.0
	payload_loader_frame["offered_payload"] = null

	# Tick 6: a null push is still consumed -- the tick
	# leaves incoming_payload null, holds nothing, and
	# the frame verdict reads false with no offer.
	payload_loader_frame["incoming_payload"] = null
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	proof["null_push_still_consumed"] = payload_loader_frame.get("incoming_payload", {}) == null and payload_loader_frame.get("payload", {}) == null and bool(payload_loader_frame.get("accepts_payload", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderIntakeGateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
