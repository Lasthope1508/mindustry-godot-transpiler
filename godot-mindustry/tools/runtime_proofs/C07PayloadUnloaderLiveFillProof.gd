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

	# --- Pure handle (N2279): PayloadBlockBuild.handlePayload
	# (PayloadBlock.java:121-127): `this.payload = (T)payload;`
	# + the payVector set/sub/clamp + `this.payRotation =
	# payload.rotation();` + updatePayload() (not ported -- it
	# only positions the live payload entity, and the port has
	# no live payload entity). The Unloader does NOT override
	# handlePayload (no handlePayload, no exporting flag in
	# PayloadUnloader.java at all; the exporting flag lives
	# only on the Loader, PayloadLoader.java:87, cleared in
	# the Loader override at :104-107). The clamp is the 4-arg
	# Vec2.clamp (Vec2.java:318-322), component-wise: half is
	# size * tilesize / 2 = 3 * 8 / 2 = 12.0 for the
	# payload-unloader def (Blocks.java:6696). The incoming
	# frame input carries the payload dict (the N2232
	# contract, plus a "rotation" key) and the source_offset
	# (source world position minus self world position -- the
	# set(source).sub(this) result, supplied by the pusher
	# because the port has no live building world positions).
	# The intake applies only when the frame payload is null
	# (the acceptPayload gate, PayloadBlock.java:116-118).
	var empty_liquids: Dictionary = _liquid_module([0.0], 0)
	var empty_frame: Dictionary = {"payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0}

	var set_block: Dictionary = _payload_block(true, true, false, null, false)
	var set_payload: Dictionary = _payload(set_block, {"copper": 5}, empty_liquids, 0.0)
	set_payload["rotation"] = 30.0
	var set: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(set_payload, 5.0, -3.0))
	var set_vector: Dictionary = set.get("pay_vector", {})
	var set_result: Dictionary = set.get("payload", {})
	var set_build: Dictionary = set_result.get("build", {})
	var set_items: Dictionary = set_build.get("items", {})
	proof["handle_sets_payload_and_vector"] = set.get("payload", null) != null and int(set_items.get("copper", -1)) == 5 and is_equal_approx(float(set_vector.get("x", -1.0)), 5.0) and is_equal_approx(float(set_vector.get("y", -1.0)), -3.0) and is_equal_approx(float(set.get("pay_rotation", -1.0)), 30.0)

	var clamp_pos: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(set_payload, 100.0, -50.0))
	var clamp_pos_vector: Dictionary = clamp_pos.get("pay_vector", {})
	var clamp_neg: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(set_payload, -100.0, 50.0))
	var clamp_neg_vector: Dictionary = clamp_neg.get("pay_vector", {})
	var clamp_edge: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(set_payload, 12.0, -12.0))
	var clamp_edge_vector: Dictionary = clamp_edge.get("pay_vector", {})
	var clamp_zero: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(set_payload, 0.0, 0.0))
	var clamp_zero_vector: Dictionary = clamp_zero.get("pay_vector", {})
	proof["handle_clamps_pay_vector_to_half_size"] = is_equal_approx(float(clamp_pos_vector.get("x", -1.0)), 12.0) and is_equal_approx(float(clamp_pos_vector.get("y", -1.0)), -12.0) and is_equal_approx(float(clamp_neg_vector.get("x", -1.0)), -12.0) and is_equal_approx(float(clamp_neg_vector.get("y", -1.0)), 12.0) and is_equal_approx(float(clamp_edge_vector.get("x", -1.0)), 12.0) and is_equal_approx(float(clamp_edge_vector.get("y", -1.0)), -12.0) and is_equal_approx(float(clamp_zero_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(clamp_zero_vector.get("y", -1.0)), 0.0)

	var rotated_payload: Dictionary = _payload(set_block, {"copper": 5}, empty_liquids, 0.0)
	rotated_payload["rotation"] = 135.0
	var rotated: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(rotated_payload, 0.0, 0.0))
	var unrotated_payload: Dictionary = _payload(set_block, {"copper": 5}, empty_liquids, 0.0)
	var unrotated: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(unrotated_payload, 0.0, 0.0))
	var negative_payload: Dictionary = _payload(set_block, {"copper": 5}, empty_liquids, 0.0)
	negative_payload["rotation"] = -45.0
	var negative: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, _incoming(negative_payload, 0.0, 0.0))
	proof["handle_sets_pay_rotation"] = is_equal_approx(float(rotated.get("pay_rotation", -1.0)), 135.0) and is_equal_approx(float(unrotated.get("pay_rotation", -1.0)), 0.0) and is_equal_approx(float(negative.get("pay_rotation", -1.0)), -45.0)

	var held_block: Dictionary = _payload_block(true, false, false, null, false)
	var held_payload: Dictionary = _payload(held_block, {"copper": 5}, empty_liquids, 0.0)
	var held_frame: Dictionary = {"payload": held_payload, "pay_vector": {"x": 1.0, "y": 2.0}, "pay_rotation": 7.0}
	var other_payload: Dictionary = _payload(held_block, {"copper": 9}, empty_liquids, 0.0)
	other_payload["rotation"] = 90.0
	var ignored: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(held_frame, _incoming(other_payload, 50.0, 50.0))
	var ignored_vector: Dictionary = ignored.get("pay_vector", {})
	var ignored_result: Dictionary = ignored.get("payload", {})
	var ignored_build: Dictionary = ignored_result.get("build", {})
	var ignored_items: Dictionary = ignored_build.get("items", {})
	var no_incoming: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, null)
	var no_incoming_vector: Dictionary = no_incoming.get("pay_vector", {})
	var empty_incoming: Dictionary = payload_unloader_build_state.source_payload_unloader_handle_payload_state(empty_frame, {"payload": null, "source_offset": {"x": 50.0, "y": 50.0}})
	proof["handle_ignored_when_payload_present"] = int(ignored_items.get("copper", -1)) == 5 and is_equal_approx(float(ignored_vector.get("x", -1.0)), 1.0) and is_equal_approx(float(ignored_vector.get("y", -1.0)), 2.0) and is_equal_approx(float(ignored.get("pay_rotation", -1.0)), 7.0) and no_incoming.get("payload", {}) == null and is_equal_approx(float(no_incoming_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(no_incoming_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(no_incoming.get("pay_rotation", -1.0)), 0.0) and empty_incoming.get("payload", {}) == null

	# --- Pure take (N2279): PayloadBlockBuild.takePayload
	# (PayloadBlock.java:145-149): `T t = payload; payload =
	# null; return t;`. The pure is NOT wired live (the
	# unit-pickup path waits for live units; the move-out
	# clear is already live through the N2232 advance).
	var taken: Dictionary = payload_unloader_build_state.source_payload_unloader_take_payload_state(held_payload)
	var taken_result: Dictionary = taken.get("payload_taken", {})
	var taken_build: Dictionary = taken_result.get("build", {})
	var taken_items: Dictionary = taken_build.get("items", {})
	var taken_empty: Dictionary = payload_unloader_build_state.source_payload_unloader_take_payload_state(null)
	proof["take_returns_and_clears_payload"] = int(taken_items.get("copper", -1)) == 5 and taken.get("payload_after", {}) == null and taken_empty.get("payload_taken", {}) == null and taken_empty.get("payload_after", {}) == null

	# --- No exporting flag on the Unloader: neither pure
	# returns an exporting key, and a freshly bound frame
	# carries no exporting key (the flag lives only on the
	# Loader, PayloadLoader.java:87).
	var fresh_frame: Dictionary = {"payload": null, "pay_vector": {"x": 0.0, "y": 0.0}, "pay_rotation": 0.0, "rotation": 0, "items": {}, "last_output_power": 0.0, "incoming_payload": null}
	proof["no_exporting_flag_on_unloader"] = not set.has("exporting") and not taken.has("exporting") and not fresh_frame.has("exporting")

	# --- Live tick: a payload-unloader placed live; the tick
	# driver is called directly (as the N2163/N2209/N2232
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The frame
	# incoming_payload input is seeded (the live push source
	# waits for its own slice, so an unseeded live unloader
	# reads incoming null and never fills). One 1/60s tick is
	# one source tick: the intake applies BEFORE the
	# consumption fold and the advance, so the newly-arrived
	# payload feeds shouldConsume the same tick (efficiency
	# folds the power min 1.0), the payload moves in from
	# (0.5, 0) to the center, the timer never fires live (the
	# driver passes load_tick false), the liquid flow is
	# min(40 * 1, 100 - 0, 60) = 40, and the battery unloads
	# min(80 * 1, 0.5 * 100) = 50 into last_output_power. The
	# second tick drains the remaining 20 liquid and unloads
	# no more power (the payload battery is empty); the
	# incoming input stays consumed (null) and the payload
	# stays on the frame (takePayload is not wired live).
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
	# the incoming input on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	# A freshly bound frame carries the live-fill input key at
	# its null default, next to the updateTile state keys
	# with the Java build-field defaults (PayloadBlock.java:
	# 92-95, PayloadUnloader.java:33, BuildingComp.java:69).
	var fresh_vector: Dictionary = unloader_frame.get("pay_vector", {})
	var fresh_defaults: bool = unloader_frame.has("payload") and unloader_frame.get("payload", {}) == null and is_equal_approx(float(fresh_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(fresh_vector.get("y", -1.0)), 0.0) and unloader_frame.has("pay_rotation") and is_equal_approx(float(unloader_frame["pay_rotation"]), 0.0) and unloader_frame.has("rotation") and int(unloader_frame["rotation"]) == 0 and unloader_frame.has("items") and (unloader_frame["items"] as Dictionary).is_empty() and unloader_frame.has("last_output_power") and is_equal_approx(float(unloader_frame["last_output_power"]), 0.0) and unloader_frame.has("incoming_payload") and unloader_frame.get("incoming_payload", {}) == null and not unloader_frame.has("exporting")

	# The intake runs BEFORE the consumption fold, so the
	# seeded push lets the first tick consume (the N2209 proof
	# pattern); the advance then keeps the payload on the
	# frame (it still holds items, so should_export stays
	# false) and consumes the incoming input.
	var live_block: Dictionary = _payload_block(true, true, false, 100.0, true)
	var live_payload: Dictionary = _payload(live_block, {"copper": 5}, _liquid_module([0.0, 60.0], 1), 0.5)
	live_payload["rotation"] = 0.0
	unloader_frame["incoming_payload"] = _incoming(live_payload, 0.5, 0.0)
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
	var tick1_ok: bool = unloader_frame.get("incoming_payload", {}) == null and unloader_frame.get("payload", null) != null and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_frame.get("moved_in", false)) and is_equal_approx(float(tick1_vector.get("x", -1.0)), 0.0) and is_equal_approx(float(tick1_vector.get("y", -1.0)), 0.0) and int(unloader_frame.get("items_unloaded", -1)) == 0 and int(tick1_items.get("copper", 0)) == 0 and is_equal_approx(float(unloader_frame.get("liquids_unloaded", -1.0)), 40.0) and is_equal_approx(float(tick1_amounts[1]), 40.0) and is_equal_approx(float(tick1_held_amounts[1]), 20.0) and is_equal_approx(float(unloader_frame.get("last_output_power", -1.0)), 50.0) and is_equal_approx(float(tick1_build.get("power_status", -1.0)), 0.0) and bool(unloader_frame.get("should_export", true)) == false

	unloader_frame["power_status"] = 1.0
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var tick2_liquids: Dictionary = unloader_frame.get("liquids", {})
	var tick2_amounts: Array = tick2_liquids.get("liquids", [])
	var tick2_payload: Dictionary = unloader_frame.get("payload", {})
	var tick2_build: Dictionary = tick2_payload.get("build", {})
	var tick2_held: Dictionary = tick2_build.get("liquids", {})
	var tick2_held_amounts: Array = tick2_held.get("liquids", [])
	var tick2_ok: bool = unloader_frame.get("incoming_payload", {}) == null and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 1.0) and bool(unloader_frame.get("moved_in", false)) and is_equal_approx(float(unloader_frame.get("liquids_unloaded", -1.0)), 20.0) and is_equal_approx(float(tick2_amounts[1]), 60.0) and is_equal_approx(float(tick2_held_amounts[1]), 0.0) and is_equal_approx(float(unloader_frame.get("last_output_power", -1.0)), 0.0) and unloader_frame.get("payload", null) != null
	proof["live_tick_fills_payload_from_incoming"] = fresh_defaults and tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
