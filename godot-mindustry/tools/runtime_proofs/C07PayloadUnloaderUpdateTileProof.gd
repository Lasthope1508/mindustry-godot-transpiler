extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_module(amounts: Array, current: int) -> Dictionary:
	return {"liquids": amounts, "current": current, "flow": null}


func _payload_block(has_items: bool, has_liquids: bool, instant: bool, cap: Variant, buffered: bool) -> Dictionary:
	return {"has_items": has_items, "has_liquids": has_liquids, "instant_deconstruct": instant, "cons_power_capacity": cap, "cons_power_buffered": buffered}


func _payload(block: Dictionary, items: Dictionary, liquids: Dictionary, power_status: float) -> Dictionary:
	return {"block": block, "build": {"items": items, "liquids": liquids, "power_status": power_status}}


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

	# --- Pure advance (N2232): PayloadUnloaderBuild.updateTile()
	# (PayloadUnloader.java:50-110): lastOutputPower reset
	# (PayloadUnloader.java:54), the shouldExport branch
	# (PayloadUnloader.java:56-64), the moveInPayload gate
	# (PayloadUnloader.java:65), the item unload loop
	# (PayloadUnloader.java:68-80), the liquid unload fold
	# (PayloadUnloader.java:82-92), the battery unload into
	# lastOutputPower (PayloadUnloader.java:94-102), and the
	# dump (PayloadUnloader.java:104-110, deferred).
	# source_delta is Time.delta in ticks (1.0 = one tick).
	# The timer cadence defers (no timer helper in the port),
	# so the pure advance takes load_tick and the driver passes
	# false; the item scan runs over item_order -- the catalog
	# item_names_by_id, the content-id order Java iterates
	# (the N2225 precedent). The front flags arrive as explicit
	# params (no live neighbor query). moveOut reuses the
	# ported SourceBlockProducerMoveOutPayloadState helper.
	var front_absent: Dictionary = {"present": false, "solid": false, "outputs_payload": false, "accepts_payload": false, "move_payload_result": false}
	var front_accepting: Dictionary = {"present": true, "solid": true, "outputs_payload": false, "accepts_payload": true, "move_payload_result": true}
	var front_rejecting: Dictionary = {"present": true, "solid": true, "outputs_payload": false, "accepts_payload": true, "move_payload_result": false}
	var empty_liquids: Dictionary = _liquid_module([0.0], 0)

	var full_block: Dictionary = _payload_block(true, true, false, null, false)
	var full_payload: Dictionary = _payload(full_block, {"copper": 5}, empty_liquids, 0.0)
	var arrive: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": full_payload, "pay_vector": {"x": 0.5, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, ["copper"], front_absent)
	var arrive_vector: Dictionary = arrive.get("pay_vector", {})
	var far: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": full_payload, "pay_vector": {"x": 5.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, ["copper"], front_absent)
	var far_vector: Dictionary = far.get("pay_vector", {})
	var rotated: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": full_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 45.0, "rotation": 1, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, ["copper"], front_absent)
	var no_payload: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0}, 1.0, 1.0, false, ["copper"], front_absent)
	proof["move_in_arrives_at_center"] = bool(arrive.get("moved_in", false)) and is_equal_approx(float(arrive_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(arrive_vector.get("y", -1.0)), 0.0) and arrive.get("payload", null) != null and bool(arrive.get("should_export", true)) == false and is_equal_approx(float(arrive.get("last_output_power", -1.0)), 0.0) and bool(far.get("moved_in", true)) == false and is_equal_approx(float(far_vector.get("x", -1.0)), 4.3) and is_equal_approx(float(rotated.get("pay_rotation", -1.0)), 50.0) and bool(rotated.get("moved_in", false)) and bool(no_payload.get("moved_in", true)) == false and bool(no_payload.get("should_export", true)) == false and no_payload.get("payload", {}) == null

	var item_block: Dictionary = _payload_block(true, false, false, null, false)
	var item_payload: Dictionary = _payload(item_block, {"copper": 10, "lead": 3}, empty_liquids, 0.0)
	var ticked: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": item_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, true, ["copper", "lead"], front_absent)
	var ticked_items: Dictionary = ticked.get("items", {})
	var ticked_payload: Dictionary = ticked.get("payload", {})
	var ticked_build: Dictionary = ticked_payload.get("build", {})
	var ticked_payload_items: Dictionary = ticked_build.get("items", {})
	var unticked: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": item_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, ["copper", "lead"], front_absent)
	var unticked_items: Dictionary = unticked.get("items", {})
	var unpowered: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 0.0, "payload": item_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, true, ["copper", "lead"], front_absent)
	var full_store: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": item_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {"copper": 100}, "liquids": empty_liquids}, 1.0, 1.0, true, ["copper", "lead"], front_absent)
	var near_full: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": item_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {"copper": 97}, "liquids": empty_liquids}, 1.0, 1.0, true, ["copper", "lead"], front_absent)
	var near_full_items: Dictionary = near_full.get("items", {})
	var near_full_payload: Dictionary = near_full.get("payload", {})
	var near_full_build: Dictionary = near_full_payload.get("build", {})
	var near_full_payload_items: Dictionary = near_full_build.get("items", {})
	var lead_only_payload: Dictionary = _payload(item_block, {"lead": 5}, empty_liquids, 0.0)
	var lead_only: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": lead_only_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, true, ["copper", "lead"], front_absent)
	var lead_only_items: Dictionary = lead_only.get("items", {})
	proof["unload_items_on_timer_tick"] = int(ticked.get("items_unloaded", -1)) == 8 and int(ticked_items.get("copper", -1)) == 8 and int(ticked_payload_items.get("copper", -1)) == 2 and int(ticked_payload_items.get("lead", -1)) == 3 and int(unticked.get("items_unloaded", -1)) == 0 and int(unticked_items.get("copper", 0)) == 0 and int(unpowered.get("items_unloaded", -1)) == 0 and int(full_store.get("items_unloaded", -1)) == 0 and int(near_full.get("items_unloaded", -1)) == 3 and int(near_full_items.get("copper", -1)) == 100 and int(near_full_payload_items.get("copper", -1)) == 7 and int(lead_only.get("items_unloaded", -1)) == 5 and int(lead_only_items.get("lead", -1)) == 5

	var liquid_block: Dictionary = _payload_block(false, true, false, null, false)
	var liquid_payload: Dictionary = _payload(liquid_block, {}, _liquid_module([0.0, 60.0], 1), 0.0)
	var liquid_base: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": liquid_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": _liquid_module([0.0, 0.0], 1)}, 1.0, 1.0, false, [], front_absent)
	var liquid_base_own: Dictionary = liquid_base.get("liquids", {})
	var liquid_base_own_amounts: Array = liquid_base_own.get("liquids", [])
	var liquid_base_payload: Dictionary = liquid_base.get("payload", {})
	var liquid_base_build: Dictionary = liquid_base_payload.get("build", {})
	var liquid_base_held: Dictionary = liquid_base_build.get("liquids", {})
	var liquid_base_held_amounts: Array = liquid_base_held.get("liquids", [])
	var liquid_scaled: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": liquid_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": _liquid_module([0.0, 0.0], 1)}, 1.0, 2.0, false, [], front_absent)
	var liquid_scaled_own: Dictionary = liquid_scaled.get("liquids", {})
	var liquid_scaled_own_amounts: Array = liquid_scaled_own.get("liquids", [])
	var liquid_mismatch: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": liquid_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": _liquid_module([50.0, 0.0], 0)}, 1.0, 1.0, false, [], front_absent)
	var liquid_low: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": liquid_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": _liquid_module([0.2, 0.0], 0)}, 1.0, 1.0, false, [], front_absent)
	var liquid_low_own: Dictionary = liquid_low.get("liquids", {})
	var liquid_low_own_amounts: Array = liquid_low_own.get("liquids", [])
	var trace_payload: Dictionary = _payload(liquid_block, {}, _liquid_module([0.0, 0.005], 1), 0.0)
	var liquid_trace: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": trace_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": _liquid_module([0.0, 0.0], 1)}, 1.0, 1.0, false, [], front_absent)
	proof["unload_liquids_folds_edelta"] = is_equal_approx(float(liquid_base.get("liquids_unloaded", -1.0)), 40.0) and is_equal_approx(float(liquid_base_own_amounts[1]), 40.0) and is_equal_approx(float(liquid_base_held_amounts[1]), 20.0) and is_equal_approx(float(liquid_scaled.get("liquids_unloaded", -1.0)), 60.0) and is_equal_approx(float(liquid_scaled_own_amounts[1]), 60.0) and is_equal_approx(float(liquid_mismatch.get("liquids_unloaded", -1.0)), 0.0) and is_equal_approx(float(liquid_low.get("liquids_unloaded", -1.0)), 40.0) and is_equal_approx(float(liquid_low_own_amounts[1]), 40.0) and int(liquid_low_own.get("current", -1)) == 1 and is_equal_approx(float(liquid_trace.get("liquids_unloaded", -1.0)), 0.0)

	var battery_block: Dictionary = _payload_block(false, false, false, 100.0, true)
	var battery_payload: Dictionary = _payload(battery_block, {}, empty_liquids, 0.5)
	var battery_base: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": battery_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var battery_base_payload: Dictionary = battery_base.get("payload", {})
	var battery_base_build: Dictionary = battery_base_payload.get("build", {})
	var big_block: Dictionary = _payload_block(false, false, false, 1000.0, true)
	var big_payload: Dictionary = _payload(big_block, {}, empty_liquids, 1.0)
	var battery_big: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": big_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var battery_big_payload: Dictionary = battery_big.get("payload", {})
	var battery_big_build: Dictionary = battery_big_payload.get("build", {})
	var flat_block: Dictionary = _payload_block(false, false, false, null, false)
	var flat_payload: Dictionary = _payload(flat_block, {}, empty_liquids, 0.0)
	var no_battery: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": flat_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var empty_battery_payload: Dictionary = _payload(battery_block, {}, empty_liquids, 0.0)
	var empty_battery: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": empty_battery_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var empty_battery_vector: Dictionary = empty_battery.get("pay_vector", {})
	proof["battery_unloads_to_last_output_power"] = is_equal_approx(float(battery_base.get("last_output_power", -1.0)), 50.0) and is_equal_approx(float(battery_base_build.get("power_status", -1.0)), 0.0) and bool(battery_base.get("should_export", true)) == false and is_equal_approx(float(battery_big.get("last_output_power", -1.0)), 80.0) and is_equal_approx(float(battery_big_build.get("power_status", -1.0)), 0.92) and is_equal_approx(float(no_battery.get("last_output_power", -1.0)), 0.0) and bool(no_battery.get("should_export", false)) and is_equal_approx(float(empty_battery.get("last_output_power", -1.0)), 0.0) and bool(empty_battery.get("should_export", false)) and bool(empty_battery.get("moved_in", true)) == false and empty_battery.get("payload", null) != null and is_equal_approx(float(empty_battery_vector.get("x", -1.0)), 0.7)

	var doomed_block: Dictionary = _payload_block(true, true, true, null, false)
	var doomed_payload: Dictionary = _payload(doomed_block, {}, empty_liquids, 0.0)
	var doomed: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": doomed_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var kept_block: Dictionary = _payload_block(true, true, false, null, false)
	var kept_payload: Dictionary = _payload(kept_block, {}, empty_liquids, 0.0)
	var kept: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": kept_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var kept_vector: Dictionary = kept.get("pay_vector", {})
	proof["instant_deconstruct_clears_payload"] = bool(doomed.get("should_export", false)) and bool(doomed.get("deconstructed", false)) and doomed.get("payload", {}) == null and is_equal_approx(float(doomed.get("last_output_power", -1.0)), 0.0) and bool(kept.get("should_export", false)) and bool(kept.get("deconstructed", true)) == false and kept.get("payload", null) != null and bool(kept.get("moved_in", true)) == false and is_equal_approx(float(kept_vector.get("x", -1.0)), 0.7)

	var pushed: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": kept_payload, "pay_vector": {"x": 12.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_accepting)
	var rejected: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": kept_payload, "pay_vector": {"x": 12.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_rejecting)
	var dumped: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": kept_payload, "pay_vector": {"x": 12.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_absent)
	var departing: Dictionary = payload_unloader_build_state.source_payload_unloader_update_tile_advance_state({"efficiency": 1.0, "payload": kept_payload, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "liquids": empty_liquids}, 1.0, 1.0, false, [], front_accepting)
	var departing_vector: Dictionary = departing.get("pay_vector", {})
	proof["move_out_pushes_payload"] = bool(pushed.get("should_export", false)) and bool(pushed.get("payload_moved", false)) and pushed.get("payload", {}) == null and bool(rejected.get("payload_moved", true)) == false and rejected.get("payload", null) != null and bool(dumped.get("payload_dumped", false)) and dumped.get("payload", null) != null and bool(departing.get("payload_moved", true)) == false and departing.get("payload", null) != null and is_equal_approx(float(departing_vector.get("x", -1.0)), 0.7)

	# --- Live tick: a payload-unloader placed live; the tick
	# driver is called directly (as the N2163/N2209 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The frame payload
	# input is seeded (the live payload fill waits for its own
	# slice, so an unseeded live unloader reads payload null
	# and does not consume). One 1/60s tick is one source tick:
	# efficiency folds the power min 1.0, the payload moves in
	# from (0.5, 0) to the center, the load timer fires on the
	# second tick (live since N2320: clock 1 -> 2 reaches the
	# 2f / efficiency threshold), but the liquid flow and the
	# battery unload do not depend on load_tick, so the values
	# below are unchanged. The liquid flow is
	# min(40 * 1, 100 - 0, 60) = 40, and the battery unloads
	# min(80 * 1, 0.5 * 100) = 50 into last_output_power. The
	# second tick drains the remaining 20 liquid and unloads
	# no more power (the payload battery is empty).
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
	# frame dict before the tick to stamp power_status and seed
	# the payload input on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	# A freshly bound frame carries the updateTile state keys
	# with the Java build-field defaults (PayloadBlock.java:
	# 92-95, PayloadUnloader.java:33, BuildingComp.java:69).
	var fresh_vector: Dictionary = unloader_frame.get("pay_vector", {})
	var fresh_defaults: bool = unloader_frame.has("payload") and unloader_frame.get("payload", {}) == null and is_equal_approx(float(fresh_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(fresh_vector.get("y", -1.0)), 0.0) and unloader_frame.has("pay_rotation") and is_equal_approx(float(unloader_frame["pay_rotation"]), 0.0) and unloader_frame.has("rotation") and int(unloader_frame["rotation"]) == 0 and unloader_frame.has("items") and (unloader_frame["items"] as Dictionary).is_empty() and unloader_frame.has("last_output_power") and is_equal_approx(float(unloader_frame["last_output_power"]), 0.0)

	# The gate reads the frame payload BEFORE the advance runs,
	# so the seeded payload lets the first tick consume (the
	# N2209 proof pattern); the advance then keeps it on the
	# frame (the payload still holds items, so should_export
	# stays false).
	var live_block: Dictionary = _payload_block(true, true, false, 100.0, true)
	unloader_frame["payload"] = _payload(live_block, {"copper": 5}, _liquid_module([0.0, 60.0], 1), 0.5)
	unloader_frame["pay_vector"] = {"x": 0.5, "y": 0.0}
	unloader_frame["power_status"] = 1.0
	unloader.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, _liquid_module([0.0, 0.0], 1))
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var tick1_vector: Dictionary = unloader_frame.get("pay_vector", {})
	var tick1_items: Dictionary = unloader_frame.get("items", {})
	var tick1_liquids: Dictionary = unloader_frame.get("liquids", {})
	var tick1_amounts: Array = tick1_liquids.get("liquids", [])
	var tick1_payload: Dictionary = unloader_frame.get("payload", {})
	var tick1_build: Dictionary = tick1_payload.get("build", {})
	var tick1_held: Dictionary = tick1_build.get("liquids", {})
	var tick1_held_amounts: Array = tick1_held.get("liquids", [])
	var tick1_ok: bool = is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_frame.get("moved_in", false)) and is_equal_approx(float(tick1_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(tick1_vector.get("y", -1.0)), 0.0) and int(unloader_frame.get("items_unloaded", -1)) == 0 and int(tick1_items.get("copper", 0)) == 0 and is_equal_approx(float(unloader_frame.get("liquids_unloaded", -1.0)), 40.0) and is_equal_approx(float(tick1_amounts[1]), 40.0) and is_equal_approx(float(tick1_held_amounts[1]), 20.0) and is_equal_approx(float(unloader_frame.get("last_output_power", -1.0)), 50.0) and is_equal_approx(float(tick1_build.get("power_status", -1.0)), 0.0) and bool(unloader_frame.get("should_export", true)) == false

	unloader_frame["power_status"] = 1.0
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var tick2_liquids: Dictionary = unloader_frame.get("liquids", {})
	var tick2_amounts: Array = tick2_liquids.get("liquids", [])
	var tick2_payload: Dictionary = unloader_frame.get("payload", {})
	var tick2_build: Dictionary = tick2_payload.get("build", {})
	var tick2_held: Dictionary = tick2_build.get("liquids", {})
	var tick2_held_amounts: Array = tick2_held.get("liquids", [])
	var tick2_ok: bool = is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_frame.get("moved_in", false)) and is_equal_approx(float(unloader_frame.get("liquids_unloaded", -1.0)), 20.0) and is_equal_approx(float(tick2_amounts[1]), 60.0) and is_equal_approx(float(tick2_held_amounts[1]), 0.0) and is_equal_approx(float(unloader_frame.get("last_output_power", -1.0)), 0.0) and unloader_frame.get("payload", null) != null
	proof["live_tick_advances_unloader_frame"] = fresh_defaults and tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
