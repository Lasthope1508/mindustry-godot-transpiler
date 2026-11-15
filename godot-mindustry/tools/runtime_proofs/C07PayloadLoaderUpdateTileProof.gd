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

	# --- Pure advance (N2231): PayloadLoaderBuild.updateTile()
	# (PayloadLoader.java:148-220): shouldExport()
	# (PayloadLoader.java:227-233) -> moveOutPayload()
	# (PayloadBlock.java:199-226, reused helper) else
	# moveInPayload() (PayloadBlock.java:186-197) -> the load
	# branches (items PayloadLoader.java:154-177, liquids
	# PayloadLoader.java:179-196, power
	# PayloadLoader.java:198-217). source_delta is Time.delta
	# in ticks (1.0 = one tick); loadTime 2f, itemsLoaded 8,
	# liquidsLoaded 40f, maxBlockSize 3, maxPowerConsumption
	# 40f, basePowerUse 2f, size 3, payloadSpeed 0.7f,
	# payloadRotateSpeed 5f. PayloadLoader DOES rotate
	# (PayloadLoader.java:45), so the moveIn target is
	# rotdeg(). The payload dict follows this slice's contract
	# (block flags + build items/liquids/power_status).
	var item_order: Array = ["copper", "lead", "silicon"]
	var liquid_names_by_id: Array = ["water", "slag", "oil"]
	var front_empty: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false}
	var front_receiver: Dictionary = {"present": true, "solid": true, "outputs_payload": false, "accepts_payload": true}
	var storage_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}

	# moveInPayload (PayloadBlock.java:186-197): payRotation
	# moves toward rotdeg() by payloadRotateSpeed * delta()
	# (80 -> 85 toward 90 in one tick), payVector approaches
	# Vec2.ZERO by payloadSpeed * delta() (0.7), and
	# hasArrived is payVector.isZero(0.01f) -- len2 < 0.01,
	# not len < 0.01 (arc Vec2.java:679-681). A payload 0.05
	# from the center arrives in one tick; a payload 5 away
	# moves to 4.3 and has not arrived. With block_rotate
	# false the target is the 90f fallback; with it true the
	# target is rotdeg() (80 -> 75 toward 0). No payload means
	# no arrival and no movement.
	var near_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.05, "y": 0.0}, "pay_rotation": 80.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var near: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(near_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var near_vector: Dictionary = near.get("pay_vector", {})
	var far_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 5.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var far: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(far_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var far_vector: Dictionary = far.get("pay_vector", {})
	var fixed_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 80.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var fixed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(fixed_frame, 1.0, 1.0, false, 0.0, false, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var rotated: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(fixed_frame, 1.0, 1.0, false, 0.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var empty_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 5.0, "y": 0.0}, "pay_rotation": 80.0, "items": {}, "liquids": {}, "payload": null}
	var empty: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(empty_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var empty_vector: Dictionary = empty.get("pay_vector", {})
	proof["move_in_arrives_at_center"] = bool(near.get("has_arrived", false)) == true and is_equal_approx(float(near_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(near_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(near.get("pay_rotation", -1.0)), 85.0) and bool(far.get("has_arrived", true)) == false and is_equal_approx(float(far_vector.get("x", -1.0)), 4.3) and is_equal_approx(float(fixed.get("pay_rotation", -1.0)), 85.0) and is_equal_approx(float(rotated.get("pay_rotation", -1.0)), 75.0) and bool(empty.get("has_arrived", true)) == false and is_equal_approx(float(empty_vector.get("x", -1.0)), 5.0)

	# Load items (PayloadLoader.java:154-177): on a load tick
	# with efficiency > 0.01f, up to itemsLoaded (8) items move
	# into the payload in content-id order (5 coppers move,
	# the loop stops when the loader is empty); without a tick
	# or at efficiency 0.005 nothing moves. A payload at 99
	# of 100 with separateItemCapacity takes one more copper,
	# then rejects the next (at capacity) and exports -- the
	# separate-reject path only fires once the payload fills
	# DURING the loop, because a payload already full at tick
	# start takes the shouldExport branch instead. The default
	# acceptItem rule needs consumesItem (a consuming payload
	# accepts; a full consuming payload rejects and exports
	# through the consumesItem branch).
	var tick_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 5}, "liquids": {}, "payload": storage_payload}
	var ticked: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(tick_frame, 1.0, 1.0, true, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var ticked_items: Dictionary = ticked.get("items", {})
	var ticked_payload: Dictionary = ticked.get("payload", {})
	var ticked_payload_items: Dictionary = ticked_payload.get("build_items", {})
	var unticked: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(tick_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var unticked_items: Dictionary = unticked.get("items", {})
	var slow_frame: Dictionary = {"efficiency": 0.005, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 5}, "liquids": {}, "payload": storage_payload}
	var slowed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(slow_frame, 1.0, 1.0, true, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var full_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": true, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {"copper": 100}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var almost_full_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": true, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": true, "accept_liquid_open": false, "build_items": {"copper": 99}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var full_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 5}, "liquids": {}, "payload": almost_full_payload}
	var rejected: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(full_frame, 1.0, 1.0, true, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var rejected_items: Dictionary = rejected.get("items", {})
	var rejected_payload: Dictionary = rejected.get("payload", {})
	var rejected_payload_items: Dictionary = rejected_payload.get("build_items", {})
	var consuming_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": ["copper"], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var consuming_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 2}, "liquids": {}, "payload": consuming_payload}
	var consumed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(consuming_frame, 1.0, 1.0, true, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var consumed_payload: Dictionary = consumed.get("payload", {})
	var consumed_payload_items: Dictionary = consumed_payload.get("build_items", {})
	var consuming_full_payload: Dictionary = {"block_has_items": true, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 100, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": ["copper"], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {"copper": 100}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var consuming_full_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 2}, "liquids": {}, "payload": consuming_full_payload}
	var consuming_rejected: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(consuming_full_frame, 1.0, 1.0, true, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var consuming_rejected_items: Dictionary = consuming_rejected.get("items", {})
	proof["load_items_on_timer_tick"] = int(ticked.get("items_loaded", -1)) == 5 and int(ticked_items.get("copper", -1)) == 0 and int(ticked_payload_items.get("copper", -1)) == 5 and bool(ticked.get("exporting", true)) == false and int(unticked.get("items_loaded", -1)) == 0 and int(unticked_items.get("copper", -1)) == 5 and int(slowed.get("items_loaded", -1)) == 0 and int(rejected.get("items_loaded", -1)) == 1 and int(rejected_items.get("copper", -1)) == 4 and int(rejected_payload_items.get("copper", -1)) == 100 and bool(rejected.get("exporting", false)) == true and int(consumed.get("items_loaded", -1)) == 2 and int(consumed_payload_items.get("copper", -1)) == 2 and int(consuming_rejected.get("items_loaded", -1)) == 0 and int(consuming_rejected_items.get("copper", -1)) == 2 and bool(consuming_rejected.get("exporting", false)) == true

	# Load liquids (PayloadLoader.java:179-196): flow =
	# min(min(liquidsLoaded * edelta(), payload liquidCapacity
	# - payload held), loader total) -- at efficiency 0.5 one
	# tick flows 20 (40 * 0.5) of 50 water into the empty
	# tank, leaving 30; at efficiency 0 nothing flows. A
	# LiquidVoid payload accepts but never stores (the loader
	# still loses the flow). A payload that does not consume
	# the liquid rejects under the default rule and exports.
	var tank_payload: Dictionary = {"block_has_items": false, "block_has_liquids": true, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 100.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": true, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var flow_frame: Dictionary = {"efficiency": 0.5, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {"liquids": [50.0, 0.0, 0.0], "current": 0, "flow": null}, "payload": tank_payload}
	var flowed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(flow_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var flowed_liquids: Dictionary = flowed.get("liquids", {})
	var flowed_amounts: Array = flowed_liquids.get("liquids", [])
	var flowed_payload: Dictionary = flowed.get("payload", {})
	var flowed_payload_liquids: Dictionary = flowed_payload.get("build_liquids", {})
	var dry_frame: Dictionary = {"efficiency": 0.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {"liquids": [50.0, 0.0, 0.0], "current": 0, "flow": null}, "payload": tank_payload}
	var dried: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(dry_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var void_payload: Dictionary = {"block_has_items": false, "block_has_liquids": true, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 10000.0, "block_is_liquid_void": true, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var void_frame: Dictionary = {"efficiency": 0.5, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {"liquids": [50.0, 0.0, 0.0], "current": 0, "flow": null}, "payload": void_payload}
	var voided: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(void_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var voided_liquids: Dictionary = voided.get("liquids", {})
	var voided_amounts: Array = voided_liquids.get("liquids", [])
	var voided_payload: Dictionary = voided.get("payload", {})
	var voided_payload_liquids: Dictionary = voided_payload.get("build_liquids", {})
	var closed_payload: Dictionary = {"block_has_items": false, "block_has_liquids": true, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 100.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.0}
	var closed_frame: Dictionary = {"efficiency": 0.5, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {"liquids": [50.0, 0.0, 0.0], "current": 0, "flow": null}, "payload": closed_payload}
	var closed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(closed_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var closed_liquids: Dictionary = closed.get("liquids", {})
	var closed_amounts: Array = closed_liquids.get("liquids", [])
	proof["load_liquids_folds_edelta"] = is_equal_approx(float(flowed.get("liquid_flow", -1.0)), 20.0) and is_equal_approx(float(flowed_payload_liquids.get("water", -1.0)), 20.0) and is_equal_approx(float(flowed_amounts[0]), 30.0) and is_equal_approx(float(dried.get("liquid_flow", -1.0)), 0.0) and is_equal_approx(float(voided.get("liquid_flow", -1.0)), 20.0) and is_equal_approx(float(voided_amounts[0]), 30.0) and is_equal_approx(float(voided_payload_liquids.get("water", 0.0)), 0.0) and is_equal_approx(float(closed.get("liquid_flow", -1.0)), 0.0) and bool(closed.get("exporting", false)) == true and is_equal_approx(float(closed_amounts[0]), 50.0)

	# Load power (PayloadLoader.java:198-217): powerInput =
	# power.status * (basePowerUse + maxPowerConsumption),
	# availableInput = max(powerInput - basePowerUse, 0),
	# status += availableInput / cap * edelta(). At full power
	# a 0.9 battery with cap 100 gains 0.4 in one tick, passes
	# 1f, exports, and clamps to 1.0; at power.status 0.5 a
	# 0.5 battery gains 0.19 and keeps charging. A payload
	# without a battery charges nothing.
	var battery_payload: Dictionary = {"block_has_items": false, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": true, "block_cons_power_capacity": 100.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.9}
	var full_charge_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": battery_payload}
	var charged: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(full_charge_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var charged_payload: Dictionary = charged.get("payload", {})
	var half_payload: Dictionary = {"block_has_items": false, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": true, "block_cons_power_capacity": 100.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 0.5}
	var half_charge_frame: Dictionary = {"efficiency": 1.0, "power_status": 0.5, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": half_payload}
	var half_charged: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(half_charge_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var half_charged_payload: Dictionary = half_charged.get("payload", {})
	var uncharged: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(near_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	proof["battery_charges_and_exports_when_full"] = is_equal_approx(float(charged_payload.get("build_power_status", -1.0)), 1.0) and bool(charged.get("exporting", false)) == true and is_equal_approx(float(charged.get("power_charged", -1.0)), 0.4) and is_equal_approx(float(half_charged_payload.get("build_power_status", -1.0)), 0.69) and bool(half_charged.get("exporting", true)) == false and is_equal_approx(float(half_charged.get("power_charged", -1.0)), 0.19) and is_equal_approx(float(uncharged.get("power_charged", -1.0)), 0.0)

	# shouldExport (PayloadLoader.java:227-233) folds all four
	# flags: the exporting flag itself, the liquids-full
	# clause (loader >= 0.1f and payload >= capacity -
	# 0.001f), the separate-items-full clause (payload at
	# itemCapacity for an item the loader still holds), and
	# the battery-full clause (status >= 0.999999999f). An
	# empty payload exports for none of them, and no payload
	# never exports.
	var exporting_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": true, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var exporting: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(exporting_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var full_tank_payload: Dictionary = {"block_has_items": false, "block_has_liquids": true, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 100.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": false, "block_cons_power_capacity": 0.0, "accept_item_open": false, "accept_liquid_open": true, "build_items": {}, "build_liquids": {"water": 100.0}, "build_current_liquid": "water", "build_power_status": 0.0}
	var liquids_full_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {"liquids": [5.0, 0.0, 0.0], "current": 0, "flow": null}, "payload": full_tank_payload}
	var liquids_full: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(liquids_full_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var items_full_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {"copper": 3}, "liquids": {}, "payload": full_payload}
	var items_full: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(items_full_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var charged_battery_payload: Dictionary = {"block_has_items": false, "block_has_liquids": false, "block_separate_item_capacity": false, "block_item_capacity": 0, "block_liquid_capacity": 0.0, "block_is_liquid_void": false, "block_consumes_items": [], "block_consumes_liquids": [], "block_cons_power_buffered": true, "block_cons_power_capacity": 100.0, "accept_item_open": false, "accept_liquid_open": false, "build_items": {}, "build_liquids": {}, "build_current_liquid": "", "build_power_status": 1.0}
	var battery_full_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": charged_battery_payload}
	var battery_full: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(battery_full_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var idle_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": false, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 90.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var idle: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(idle_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var no_payload: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(empty_frame, 1.0, 1.0, false, 90.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	proof["should_export_folds_flags"] = bool(exporting.get("should_export", false)) == true and bool(liquids_full.get("should_export", false)) == true and bool(items_full.get("should_export", false)) == true and bool(battery_full.get("should_export", false)) == true and bool(idle.get("should_export", true)) == false and bool(no_payload.get("should_export", true)) == false

	# moveOutPayload (PayloadBlock.java:199-226, reused
	# helper): the dest is trns(rotdeg(), size * tilesize / 2)
	# = (12, 0) for rotdeg 0, so one tick moves payVector
	# 0 -> 0.7 toward it and rotates 80 -> 75 toward 0; with
	# no front building canDump holds and the push fraction is
	# 1 - (11.3 / 12). At the dest with a receiving front
	# building and a successful movePayload the payload hands
	# off (payload_moved, payload null); at the dest with no
	# front building it dumps (payload_dumped, payload kept --
	# dumpPayload clears only on payload.dump() success).
	var push_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": true, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 80.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var pushed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(push_frame, 1.0, 1.0, false, 0.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	var pushed_vector: Dictionary = pushed.get("pay_vector", {})
	var handoff_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": true, "pay_vector": {"x": 11.9999, "y": 0.0}, "pay_rotation": 0.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var handed: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(handoff_frame, 1.0, 1.0, false, 0.0, true, item_order, liquid_names_by_id, front_receiver, true, 2.0)
	var dump_frame: Dictionary = {"efficiency": 1.0, "power_status": 1.0, "exporting": true, "pay_vector": {"x": 12.0, "y": 0.0}, "pay_rotation": 0.0, "items": {}, "liquids": {}, "payload": storage_payload}
	var dumped: Dictionary = payload_loader_build_state.source_payload_loader_update_tile_advance_state(dump_frame, 1.0, 1.0, false, 0.0, true, item_order, liquid_names_by_id, front_empty, false, 2.0)
	proof["move_out_pushes_payload"] = is_equal_approx(float(pushed_vector.get("x", -1.0)), 0.7) and is_equal_approx(float(pushed.get("pay_rotation", -1.0)), 75.0) and is_equal_approx(float(pushed.get("pushed_output_fraction", -1.0)), 0.7 / 12.0) and bool(pushed.get("payload_moved", true)) == false and bool(pushed.get("payload_dumped", true)) == false and pushed.get("payload", {}) != null and bool(handed.get("payload_moved", false)) == true and handed.get("payload", {}) == null and bool(dumped.get("payload_dumped", false)) == true and dumped.get("payload", {}) != null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
