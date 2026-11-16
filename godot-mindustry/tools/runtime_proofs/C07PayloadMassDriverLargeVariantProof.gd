extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_mass_driver_build_state := preload("res://src/game/SourcePayloadMassDriverBuildState.gd")
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

	# --- Large variant (N2357): the large-payload-mass-driver
	# def (Blocks.java:6629-6639) runs through the SAME driver
	# as the payload-mass-driver def (Blocks.java:6617-6627),
	# with per-def values resolved by the catalog (size /
	# reload / range / consumePower) and by the driver helpers
	# (chargeTime / maxPayloadSize -- the catalog carries
	# neither property). Large: size 5, reload 130f, chargeTime
	# 100f, range 2100f, maxPayloadSize 4f, consumePower 3f.
	# Small: size 3, reload 130f, chargeTime 90f, range 700f,
	# maxPayloadSize 2.5f, consumePower 0.5f. Class defaults
	# (PayloadMassDriver.java:24-30): range 100f, reload 30f,
	# chargeTime 100f, maxPayloadSize 3 -- the DEFs win on
	# every field except the large chargeTime, which happens
	# to equal the class default (100f) and is still resolved
	# per def by block id, not taken as the class fallback.

	# --- Catalog rows: both defs are PayloadMassDriver
	# implementations, and the catalog rows carry the per-def
	# size / reload / range / consumePower the live tick reads
	# (reload is 130f for both defs, beating the class 30f;
	# the other four values differ).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var small_block = blocks_by_id["payload-mass-driver"]
	var large_block = blocks_by_id["large-payload-mass-driver"]
	var small_properties: Dictionary = small_block.properties
	var large_properties: Dictionary = large_block.properties
	proof["large_def_catalog_rows"] = str(small_block.implementation) == "PayloadMassDriver" and str(large_block.implementation) == "PayloadMassDriver" and int(small_properties.get("size", -1)) == 3 and int(large_properties.get("size", -1)) == 5 and is_equal_approx(float(small_properties.get("reload", -1.0)), 130.0) and is_equal_approx(float(large_properties.get("reload", -1.0)), 130.0) and is_equal_approx(float(small_properties.get("range", -1.0)), 700.0) and is_equal_approx(float(large_properties.get("range", -1.0)), 2100.0) and is_equal_approx(float(small_properties.get("consumePower", -1.0)), 0.5) and is_equal_approx(float(large_properties.get("consumePower", -1.0)), 3.0) and is_equal_approx(float(small_properties.get("powerUsage", -1.0)), 0.5) and is_equal_approx(float(large_properties.get("powerUsage", -1.0)), 3.0) and not small_properties.has("chargeTime") and not large_properties.has("chargeTime") and not small_properties.has("maxPayloadSize") and not large_properties.has("maxPayloadSize")

	# --- Pure chargeTime (N2246 fixture): the shooting fire
	# gate + transfer (PayloadMassDriver.java:272-326), with
	# the chargeTime param as the only difference. The setup
	# is the N2246 transfer fixture: this tile (3, 5), the
	# partner (3, 10) at (80, 0) due east, loaded, at the
	# muzzle, turret aligned, partner accepting and first in
	# queue. Charge 95 + edelta 1.0 = 96: it fires the SMALL
	# def (96 >= 90) but NOT the large def (96 < 100) -- the
	# large driver keeps charging, holds its payload, and
	# stays shooting. Charge 99.5 + 1.0 = 100.5 fires the
	# LARGE def (100.5 >= 100): the self side resets and the
	# partner takes the payload with effectDelayTimer 11f.
	var this_pos: int = (3 << 16) | 5
	var partner_pos: int = (3 << 16) | 10
	var linked_accepting: Dictionary = {"exists": true, "pos": partner_pos, "is_payload_mass_driver": true, "same_block": true, "same_team": true, "within_range": true, "payload": null, "state": "accepting", "turret_rotation": 180.0, "reload_counter": 0.0, "effect_delay_timer": -1.0, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "pay_length": 0.0, "loaded": false, "last_other": null, "waiting_shooters": [this_pos], "x": 80.0, "y": 0.0}
	var small_fires_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 95.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var small_fires: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(small_fires_frame, 1.0, 1.0, 90.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var large_holds_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 95.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var large_holds: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(large_holds_frame, 1.0, 1.0, 100.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var large_fires_frame: Dictionary = {"efficiency": 1.0, "link": partner_pos, "state": "shooting", "payload": {"size": 16.0}, "rec_payload": null, "target_size": 16.0, "turret_rotation": 0.0, "pay_rotation": 0.0, "pay_length": 11.125, "loaded": true, "pay_vector": Vector2.ZERO, "charge": 99.5, "charging": false, "reload_counter": 0.0, "waiting_shooters": []}
	var large_fires: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_state_branches_state(large_fires_frame, 1.0, 1.0, 100.0, 11.125, 5.0, 5.0, 0.7, 5.0, 0.0, this_pos, 0.0, 0.0, linked_accepting, {})
	var large_fires_partner_payload: Dictionary = large_fires.get("partner_payload", {})
	proof["large_def_charge_time_100"] = bool(small_fires.get("fired", false)) == true and small_fires.get("payload", {"size": -1.0}) == null and str(small_fires.get("state", "")) == "idle" and is_equal_approx(float(small_fires.get("charge", -1.0)), 96.0) and bool(large_holds.get("fired", true)) == false and large_holds.get("payload", null) != null and str(large_holds.get("state", "")) == "shooting" and is_equal_approx(float(large_holds.get("charge", -1.0)), 96.0) and bool(large_holds.get("charging", false)) == true and bool(large_fires.get("fired", false)) == true and large_fires.get("payload", {"size": -1.0}) == null and str(large_fires.get("state", "")) == "idle" and is_equal_approx(float(large_fires.get("charge", -1.0)), 100.5) and is_equal_approx(float(large_fires_partner_payload.get("size", -1.0)), 16.0) and is_equal_approx(float(large_fires.get("partner_effect_delay_timer", -1.0)), 11.0)

	# --- Pure size-5 move-out (N2245 fixture): the dump when
	# idle (PayloadMassDriver.java:218-229) runs moveOutPayload
	# in pure form (PayloadBlock.java:204-207): the dest is
	# trns(rotdeg, size * tilesize / 2), so size 5 puts it at
	# (20, 0) and size 3 at (12, 0). A payVector at (19.5, 0)
	# approaching by 0.7 SNAPS to the large dest (0.5 away,
	# inside the step) but only STEPS toward the small dest
	# (7.5 away: 19.5 - 0.7 = 18.8). payRotation moves toward
	# rotdeg (90 -> 85) in both cases.
	var unlinked: Dictionary = {"exists": false, "pos": -1, "is_payload_mass_driver": false, "same_block": false, "same_team": false, "within_range": false}
	var large_move_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 90.0, "pay_vector": {"x": 19.5, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var large_moved: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(large_move_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 5, 8.0, 0.0, this_pos, unlinked, {})
	var large_moved_vector: Dictionary = large_moved.get("pay_vector", {})
	var small_move_frame: Dictionary = {"efficiency": 1.0, "link": -1, "charge": 0.0, "cur_size": 16.0, "target_size": 16.0, "effect_delay_timer": -1.0, "charging": false, "reload_counter": 0.0, "waiting_shooters": [], "state": "idle", "pay_length": 0.0, "pay_rotation": 90.0, "pay_vector": {"x": 19.5, "y": 0.0}, "loaded": false, "last_other": -1, "turret_rotation": 90.0, "payload": {"size": 24.0}}
	var small_moved: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_update_tile_advance_state(small_move_frame, 1.0, 1.0, 130.0, 8.0, 0.7, 5.0, 3, 8.0, 0.0, this_pos, unlinked, {})
	var small_moved_vector: Dictionary = small_moved.get("pay_vector", {})
	proof["large_def_size_5_move_out_dest"] = is_equal_approx(float(large_moved_vector.get("x", -1.0)), 20.0) and is_equal_approx(float(large_moved_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(large_moved.get("pay_rotation", -1.0)), 85.0) and is_equal_approx(float(small_moved_vector.get("x", -1.0)), 18.8) and is_equal_approx(float(small_moved_vector.get("y", -1.0)), 0.0) and is_equal_approx(float(small_moved.get("pay_rotation", -1.0)), 85.0)

	# --- Live tick: two linked pairs at different
	# separations. The tick reads the JAVA tilesize constant
	# 8.0 for world-coord math (N2364: the game tile_size 32
	# in playable_content.json is rendering px per tile, NOT
	# Java world units -- game.get("tile_size") is still 32
	# here, pinned by the key below, but the driver never
	# reads it for link math). The large pair is 40 cells
	# apart: 40 * 8 = 320 world units, inside the large range
	# 2100 -- both switch idle -> shooting
	# (PayloadMassDriver.java:212-213) with the link
	# refreshed to the partner pos. The small pair is 100
	# cells apart (N2365 re-seed: the pair was 40 cells,
	# 320 < 700, which LINKED under Java math after the N2364
	# fix -- 40 * 32 = 1280 > 700 only held under the old
	# 4x-wrong port math): 100 * 8 = 800 world units, past
	# the small range 700 -- both stay idle with the stale
	# link untouched (linkValid,
	# PayloadMassDriver.java:466-468, within is STRICT dst <
	# range). Footprints are disjoint (large size 5 spans
	# origin +- 2, small size 3 spans origin +- 1): large
	# (28, 21) / (68, 21), small (28, 26) / (128, 26). The
	# tick runs at half power (efficiency 0.5): the large
	# driver discharges its charge 50 -> 40 (raw Time.delta,
	# PayloadMassDriver.java:162) and decays its reload
	# counter 1.0 -> 1.0 - 0.5/130 = 0.9961538
	# (PayloadMassDriver.java:191). The accept gate reads the
	# per-def maxPayloadSize live: the large driver accepts
	# the 32 boundary and rejects 33, the small driver
	# rejects 24 (past its threshold 20) and accepts the 20
	# boundary.
	var large_a_cell := Vector2i(28, 21)
	var large_b_cell := Vector2i(68, 21)
	var small_a_cell := Vector2i(28, 26)
	var small_b_cell := Vector2i(128, 26)
	var large_a_pos: int = (28 << 16) | 21
	var large_b_pos: int = (68 << 16) | 21
	var small_a_pos: int = (28 << 16) | 26
	var small_b_pos: int = (128 << 16) | 26
	var large_a := Sprite2D.new()
	game.add_child(large_a)
	game.call("record_placed_block", large_a, blocks_by_id["large-payload-mass-driver"], large_a_cell)
	var large_b := Sprite2D.new()
	game.add_child(large_b)
	game.call("record_placed_block", large_b, blocks_by_id["large-payload-mass-driver"], large_b_cell)
	var small_a := Sprite2D.new()
	game.add_child(small_a)
	game.call("record_placed_block", small_a, blocks_by_id["payload-mass-driver"], small_a_cell)
	var small_b := Sprite2D.new()
	game.add_child(small_b)
	game.call("record_placed_block", small_b, blocks_by_id["payload-mass-driver"], small_b_cell)
	# Bind the frames explicitly (the N2149 pattern: the driver
	# binds them on their first tick, but the proof needs the live
	# frame dicts before the tick to stamp power_status, the
	# links, the charge, and the offered sizes on them).
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(large_a, blocks_by_id["large-payload-mass-driver"])
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(large_b, blocks_by_id["large-payload-mass-driver"])
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(small_a, blocks_by_id["payload-mass-driver"])
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(small_b, blocks_by_id["payload-mass-driver"])
	var large_a_frame: Dictionary = large_a.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var large_b_frame: Dictionary = large_b.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var small_a_frame: Dictionary = small_a.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var small_b_frame: Dictionary = small_b.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	large_a_frame["power_status"] = 0.5
	large_b_frame["power_status"] = 0.5
	small_a_frame["power_status"] = 0.5
	small_b_frame["power_status"] = 0.5
	large_a_frame["link"] = large_b_pos
	large_b_frame["link"] = large_a_pos
	small_a_frame["link"] = small_b_pos
	small_b_frame["link"] = small_a_pos
	large_a_frame["charge"] = 50.0
	large_a_frame["reload_counter"] = 1.0
	large_a_frame["offered_payload_size"] = 32.0
	large_b_frame["offered_payload_size"] = 33.0
	small_a_frame["offered_payload_size"] = 24.0
	small_b_frame["offered_payload_size"] = 20.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	large_a_frame = large_a.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	large_b_frame = large_b.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	small_a_frame = small_a.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	small_b_frame = small_b.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["large_def_range_2100_live_link"] = is_equal_approx(float(game.get("tile_size", -1.0)), 32.0) and is_equal_approx(float(large_a_frame.get("efficiency", -1.0)), 0.5) and str(large_a_frame.get("state", "")) == "shooting" and int(large_a_frame.get("link", -99)) == large_b_pos and str(large_b_frame.get("state", "")) == "shooting" and int(large_b_frame.get("link", -99)) == large_a_pos and str(small_a_frame.get("state", "")) == "idle" and int(small_a_frame.get("link", -99)) == small_b_pos and str(small_b_frame.get("state", "")) == "idle" and int(small_b_frame.get("link", -99)) == small_a_pos and is_equal_approx(float(large_a_frame.get("charge", -1.0)), 40.0) and is_equal_approx(float(large_a_frame.get("reload_counter", -1.0)), 0.9961538)
	proof["large_def_accepts_size_32_live"] = bool(large_a_frame.get("accepts_payload", false)) == true and bool(large_b_frame.get("accepts_payload", true)) == false and bool(small_a_frame.get("accepts_payload", true)) == false and bool(small_b_frame.get("accepts_payload", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverLargeVariantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
