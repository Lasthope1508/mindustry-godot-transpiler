extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _block(has_items: bool, unloadable: bool, item_capacity: int, size: int, has_liquids: bool, liquid_capacity: float, cons_power_capacity: Variant, cons_power_buffered: bool) -> Dictionary:
	return {"has_items": has_items, "unloadable": unloadable, "item_capacity": item_capacity, "size": size, "has_liquids": has_liquids, "liquid_capacity": liquid_capacity, "cons_power_capacity": cons_power_capacity, "cons_power_buffered": cons_power_buffered}


func _offered(is_build: bool, size_px: float, block: Dictionary) -> Dictionary:
	return {"is_build_payload": is_build, "size": size_px, "block": block}


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

	# --- Pure gate (N2296): the acceptPayload gate
	# (PayloadLoaderBuild.acceptPayload(),
	# PayloadLoader.java:90-101), inherited verbatim by
	# PayloadUnloaderBuild (PayloadUnloader.java:32, `public
	# class PayloadUnloaderBuild extends PayloadLoaderBuild{`;
	# PayloadUnloader.java has NO acceptPayload at all), so
	# the Unloader inherits the Loader's override -- the base
	# null gate AND fits(maxBlockSize) AND instanceof
	# BuildPayload AND the item-container / liquid-container
	# / battery branches -- NOT the bare PayloadBlock base
	# gate (PayloadBlock.java:116-118). fits is `return
	# size() / tilesize <= s;` (Payload.java:50-52) with
	# tilesize 8 (Vars.java:135) and maxBlockSize 3
	# (PayloadLoader.java:25); a BuildPayload's size() is
	# `return build.block.size * tilesize;`
	# (BuildPayload.java:86-88), so fits(3) is block.size <=
	# 3 for build payloads. acceptItem / acceptLiquid are
	# hard-coded false (PayloadUnloader.java:35-44), so the
	# Unloader accepts payloads but never loose items or
	# liquids -- that is why its dump rows (N2293) move
	# items/liquids OUT only.

	# Accepts a fitting container when empty: an item
	# container (block size 2, 16px, fits 2 <= 3; hasItems,
	# unloadable, itemCapacity 100 >= 10), a liquid
	# container (block size 3, 24px, fits 3 <= 3 -- the
	# boundary; hasLiquids, liquidCapacity 100f >= 10f),
	# and a battery (block size 1, 8px; consPower capacity
	# 1000f, buffered) each accept with no payload held.
	var item_block: Dictionary = _block(true, true, 100, 2, false, 0.0, null, false)
	var liquid_block: Dictionary = _block(false, true, 0, 3, true, 100.0, null, false)
	var battery_block: Dictionary = _block(false, true, 0, 1, false, 0.0, 1000.0, true)
	var item_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 16.0, item_block))
	var liquid_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 24.0, liquid_block))
	var battery_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 8.0, battery_block))
	proof["accepts_container_when_empty"] = bool(item_result.get("accept_payload", false)) and bool(liquid_result.get("accept_payload", false)) and bool(battery_result.get("accept_payload", false))

	# Rejects when a payload is already held: the same
	# fitting item container is refused once the unloader
	# holds a payload (the base gate, PayloadBlock.java:117).
	var held_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(true, _offered(true, 16.0, item_block))
	proof["rejects_when_payload_present"] = not bool(held_result.get("accept_payload", true))

	# Rejects non-container payloads: a unit payload (not a
	# BuildPayload) is refused even when it fits; an
	# oversize build payload (block size 4, 32px, fits 4 >
	# 3) is refused even with a container block; a plain
	# block with no container branch (no items, no liquids,
	# no consPower) is refused; an item container with
	# itemCapacity 5 (< 10) is refused; a non-unloadable
	# item container is refused; and with no payload
	# offered at all (null) there is nothing to accept.
	var unit_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(false, 16.0, item_block))
	var oversize_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 32.0, _block(true, true, 100, 4, false, 0.0, null, false)))
	var plain_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 16.0, _block(false, true, 0, 2, false, 0.0, null, false)))
	var small_cap_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 16.0, _block(true, true, 5, 2, false, 0.0, null, false)))
	var locked_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, _offered(true, 16.0, _block(true, false, 100, 2, false, 0.0, null, false)))
	var no_offer_result: Dictionary = payload_unloader_build_state.source_payload_unloader_accept_payload_state(false, null)
	proof["rejects_non_container_payload"] = not bool(unit_result.get("accept_payload", true)) and not bool(oversize_result.get("accept_payload", true)) and not bool(plain_result.get("accept_payload", true)) and not bool(small_cap_result.get("accept_payload", true)) and not bool(locked_result.get("accept_payload", true)) and not bool(no_offer_result.get("accept_payload", true))

	# acceptItem is always false (PayloadUnloader.java:36-38)
	# and acceptLiquid is always false
	# (PayloadUnloader.java:41-43) -- across every case
	# above: empty or holding, container or not, offered or
	# not.
	proof["accept_item_always_false"] = not bool(item_result.get("accept_item", true)) and not bool(liquid_result.get("accept_item", true)) and not bool(battery_result.get("accept_item", true)) and not bool(held_result.get("accept_item", true)) and not bool(unit_result.get("accept_item", true)) and not bool(no_offer_result.get("accept_item", true))
	proof["accept_liquid_always_false"] = not bool(item_result.get("accept_liquid", true)) and not bool(liquid_result.get("accept_liquid", true)) and not bool(battery_result.get("accept_liquid", true)) and not bool(held_result.get("accept_liquid", true)) and not bool(unit_result.get("accept_liquid", true)) and not bool(no_offer_result.get("accept_liquid", true))

	# --- Live tick: a payload-unloader placed live with NO
	# payload; the tick driver is called directly (as the
	# N2163/N2209/N2232/N2279/N2293 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is
	# one source tick. With a fitting item container
	# offered, the frame exposes accepts_payload true and
	# accepts_item / accepts_liquid false -- and the payload
	# stays null, because the gate only answers: it does not
	# intake (the N2279 intake reads incoming_payload, not
	# offered_payload). A second tick with no offer exposes
	# accepts_payload false and still moves nothing.
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
	# frame dict before the tick to stamp power_status and set
	# the offered payload on it).
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})

	unloader_frame["power_status"] = 1.0
	unloader_frame["offered_payload"] = _offered(true, 16.0, item_block)
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	var offered_accepts: bool = bool(unloader_frame.get("accepts_payload", false))
	var offered_accepts_item: bool = bool(unloader_frame.get("accepts_item", true))
	var offered_accepts_liquid: bool = bool(unloader_frame.get("accepts_liquid", true))
	var offered_payload_still_null: bool = unloader_frame.get("payload", null) == null
	unloader_frame["offered_payload"] = null
	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	proof["live_tick_exposes_all_three_verdicts"] = offered_accepts and not offered_accepts_item and not offered_accepts_liquid and offered_payload_still_null and not bool(unloader_frame.get("accepts_payload", true)) and not bool(unloader_frame.get("accepts_item", true)) and not bool(unloader_frame.get("accepts_liquid", true)) and unloader_frame.get("payload", null) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderAcceptPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
