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

	# --- Pure acceptPayload (N2295): acceptPayload
	# (PayloadLoader.java:90-101): `return
	# super.acceptPayload(source, payload) &&` (:91),
	# `payload.fits(maxBlockSize) &&` (:92), `payload
	# instanceof BuildPayload build && (` (:93), then
	# the three branches -- the item container (:95),
	# the liquid container (:97), the battery (:99).
	# super.acceptPayload is `return this.payload ==
	# null;` (PayloadBlock.java:116-118), so the base
	# gate is the has_payload param. fits is `return
	# size() / tilesize <= s;` (Payload.java:50-52)
	# with `return build.block.size * tilesize;`
	# (BuildPayload.java:86-88), so for a BuildPayload
	# fits is block.size <= maxBlockSize (maxBlockSize
	# 3, PayloadLoader.java:25). The descriptor carries
	# the block flags Java reads live: unloadable
	# (Block.java:106, default true), itemCapacity
	# (Block.java:75, default 10), liquidCapacity
	# (Block.java:77, default -1f), consPower
	# (Block.java:414) with buffered
	# (ConsumePower.java:14). Missing keys default to
	# the rejecting value (false / 0) -- a partial
	# fixture must NOT accept.
	var item_container: Dictionary = {"is_build_payload": true, "block_size": 2, "has_items": true, "unloadable": true, "item_capacity": 10}
	var liquid_container: Dictionary = {"is_build_payload": true, "block_size": 3, "has_liquids": true, "liquid_capacity": 10.0}
	var battery: Dictionary = {"is_build_payload": true, "block_size": 1, "has_cons_power": true, "cons_power_buffered": true}
	var unit_payload: Dictionary = {"is_build_payload": false, "block_size": 2, "has_items": true, "unloadable": true, "item_capacity": 100}

	var item_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(item_container, false)
	var liquid_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(liquid_container, false)
	var battery_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(battery, false)
	var held_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(item_container, true)
	var unit_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(unit_payload, false)
	proof["item_container_accepted"] = bool(item_verdict.get("accepts", false)) and bool(item_verdict.get("fits", false)) and bool(item_verdict.get("is_item_container", false)) and not bool(item_verdict.get("is_liquid_container", true)) and not bool(item_verdict.get("is_battery", true))
	proof["liquid_container_accepted"] = bool(liquid_verdict.get("accepts", false)) and bool(liquid_verdict.get("fits", false)) and bool(liquid_verdict.get("is_liquid_container", false)) and not bool(liquid_verdict.get("is_item_container", true)) and not bool(liquid_verdict.get("is_battery", true))
	proof["battery_accepted"] = bool(battery_verdict.get("accepts", false)) and bool(battery_verdict.get("fits", false)) and bool(battery_verdict.get("is_battery", false)) and not bool(battery_verdict.get("is_item_container", true)) and not bool(battery_verdict.get("is_liquid_container", true))
	proof["base_gate_rejects_when_payload_present"] = not bool(held_verdict.get("accepts", true)) and bool(held_verdict.get("fits", false)) and bool(held_verdict.get("is_item_container", false))
	proof["non_build_payload_rejected"] = not bool(unit_verdict.get("accepts", true)) and not bool(unit_verdict.get("is_item_container", true)) and not bool(unit_verdict.get("is_liquid_container", true)) and not bool(unit_verdict.get("is_battery", true))

	# The boundary cases: oversize (block_size 4 > maxBlockSize
	# 3) fails fits and the item branch's own size check;
	# under-capacity (itemCapacity 9 < 10, liquidCapacity
	# 9.9 < 10f), a non-unloadable item block, an
	# unbuffered consPower, and a partial fixture (the
	# empty descriptor) all fail every branch -- the
	# capacity thresholds are inclusive (>= 10 / >= 10f),
	# so exactly 10 / 10.0 accepts (pinned above).
	var oversize: Dictionary = {"is_build_payload": true, "block_size": 4, "has_items": true, "unloadable": true, "item_capacity": 100}
	var oversize_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(oversize, false)
	var small_items: Dictionary = {"is_build_payload": true, "block_size": 2, "has_items": true, "unloadable": true, "item_capacity": 9}
	var small_items_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(small_items, false)
	var small_liquid: Dictionary = {"is_build_payload": true, "block_size": 2, "has_liquids": true, "liquid_capacity": 9.9}
	var small_liquid_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(small_liquid, false)
	var locked: Dictionary = {"is_build_payload": true, "block_size": 2, "has_items": true, "unloadable": false, "item_capacity": 100}
	var locked_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(locked, false)
	var unbuffered: Dictionary = {"is_build_payload": true, "block_size": 2, "has_cons_power": true, "cons_power_buffered": false}
	var unbuffered_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state(unbuffered, false)
	var partial_verdict: Dictionary = payload_loader_build_state.source_payload_loader_accept_payload_state({}, false)
	proof["oversize_or_under_capacity_rejected"] = not bool(oversize_verdict.get("fits", true)) and not bool(oversize_verdict.get("accepts", true)) and not bool(oversize_verdict.get("is_item_container", true)) and not bool(small_items_verdict.get("accepts", true)) and not bool(small_items_verdict.get("is_item_container", true)) and not bool(small_liquid_verdict.get("accepts", true)) and not bool(small_liquid_verdict.get("is_liquid_container", true)) and not bool(locked_verdict.get("accepts", true)) and not bool(locked_verdict.get("is_item_container", true)) and not bool(unbuffered_verdict.get("accepts", true)) and not bool(unbuffered_verdict.get("is_battery", true)) and not bool(partial_verdict.get("accepts", true))

	# --- Live tick: the payload-loader is a PayloadLoader
	# build with a power consumer (consumePower 2f), placed
	# live; the tick driver is called directly (as the
	# N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/
	# N2157/N2158/N2159/N2160/N2161 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The driver stamps
	# frame["accepts_payload"] every tick from the
	# frame-supplied offered-payload descriptor
	# (frame["offered_payload"]) and the frame payload
	# null-ness: acceptPayload is consulted BEFORE
	# handlePayload, so the stamp sits before the N2278
	# intake. No payload offered means accepts false.
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

	# A fresh frame offers nothing: accepts_payload false
	# before any offer lands.
	var fresh_accepts: bool = bool(payload_loader_frame.get("accepts_payload", true)) == false
	payload_loader_frame["power_status"] = 1.0
	payload_loader_frame["offered_payload"] = item_container.duplicate(true)
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	proof["item_container_accepted"] = bool(proof["item_container_accepted"]) and fresh_accepts and bool(payload_loader_frame.get("accepts_payload", false))

	# A payload is held now (the N2278 intake set it on a
	# live loader; here the frame carries it directly):
	# the same offer is refused by the base gate, and the
	# frame keeps the held payload.
	payload_loader_frame["payload"] = {"marker": "held"}
	payload_loader_frame["offered_payload"] = item_container.duplicate(true)
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var kept_payload: Variant = payload_loader_frame.get("payload", null)
	proof["base_gate_rejects_when_payload_present"] = bool(proof["base_gate_rejects_when_payload_present"]) and kept_payload is Dictionary and str(kept_payload.get("marker", "")) == "held" and not bool(payload_loader_frame.get("accepts_payload", true))

	# The offer is withdrawn: the verdict falls back to
	# false (no payload offered, no verdict to give).
	payload_loader_frame["payload"] = null
	payload_loader_frame["offered_payload"] = null
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	proof["item_container_accepted"] = bool(proof["item_container_accepted"]) and not bool(payload_loader_frame.get("accepts_payload", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderAcceptPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
