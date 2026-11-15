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

	# --- Per-def gate (N2304): PayloadDriverBuild.acceptPayload
	# (PayloadMassDriver.java:462-463):
	# `return super.acceptPayload(source, payload) &&
	# payload.size() <= maxPayloadSize * tilesize;`, where
	# super.acceptPayload is `return this.payload == null;`
	# (PayloadBlock.java:116-118) and maxPayloadSize is per
	# def: `maxPayloadSize = 2.5f;` (Blocks.java:6624,
	# payload-mass-driver, threshold 20) and `maxPayloadSize
	# = 4f;` (Blocks.java:6636, large-payload-mass-driver,
	# threshold 32), beating the class `public float
	# maxPayloadSize = 3;` (PayloadMassDriver.java:30,
	# threshold 24) times tilesize 8 (Vars.java:135). A
	# BuildPayload size is `return build.block.size *
	# tilesize;` (BuildPayload.java:86-88), so a size-3 block
	# payload measures 24: it fits the class default and the
	# large def, but NOT the small def (threshold 20). The
	# comparison is <=, so each boundary accepts. The N2298
	# pure stays as the class-default gate; this slice adds
	# the for_def pure, which the tick calls with the
	# helper-resolved per-def value (the catalog carries no
	# maxPayloadSize property).

	# Small def boundary: a size-2.5 payload (20) sits
	# exactly on the payload-mass-driver threshold, and the
	# comparison is <=, so it accepts; a size-2 payload (16)
	# fits under it too, and the threshold reads 20 in both
	# cases.
	var small_boundary: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(20.0, false, 2.5)
	var small_fits: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(16.0, false, 2.5)
	proof["small_def_boundary_20_accepted"] = bool(small_boundary.get("accepts", false)) == true and bool(small_boundary.get("size_fits", false)) == true and is_equal_approx(float(small_boundary.get("threshold", -1.0)), 20.0) and bool(small_fits.get("accepts", false)) == true and bool(small_fits.get("size_fits", false)) == true and is_equal_approx(float(small_fits.get("threshold", -1.0)), 20.0)

	# Small def rejects what the class default accepts: a
	# size-3 payload (24) fits the class-default threshold
	# 24, but exceeds the payload-mass-driver threshold 20,
	# so size_fits is false and the verdict is false even
	# with no payload held. Size 21 (just over 20) rejects
	# too.
	var small_class_size: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(24.0, false, 2.5)
	var small_just_over: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(21.0, false, 2.5)
	proof["small_def_size_24_rejected"] = bool(small_class_size.get("accepts", true)) == false and bool(small_class_size.get("size_fits", true)) == false and bool(small_just_over.get("accepts", true)) == false and bool(small_just_over.get("size_fits", true)) == false

	# Large def boundary: a size-4 payload (32) sits exactly
	# on the large-payload-mass-driver threshold, and the
	# comparison is <=, so it accepts; a size-3 payload (24)
	# fits under it too, and the threshold reads 32 in both
	# cases.
	var large_boundary: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(32.0, false, 4.0)
	var large_fits: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(24.0, false, 4.0)
	proof["large_def_boundary_32_accepted"] = bool(large_boundary.get("accepts", false)) == true and bool(large_boundary.get("size_fits", false)) == true and is_equal_approx(float(large_boundary.get("threshold", -1.0)), 32.0) and bool(large_fits.get("accepts", false)) == true and bool(large_fits.get("size_fits", false)) == true and is_equal_approx(float(large_fits.get("threshold", -1.0)), 32.0)

	# Large def rejects oversize: size 33 exceeds 32, so
	# size_fits is false and the verdict is false even with
	# no payload held.
	var large_oversize: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(33.0, false, 4.0)
	proof["large_def_size_33_rejected"] = bool(large_oversize.get("accepts", true)) == false and bool(large_oversize.get("size_fits", true)) == false

	# Class default boundary: passing the class default 3.0
	# reproduces the N2298 pure exactly -- a size-3 payload
	# (24) sits exactly on the threshold 24 and accepts.
	var default_boundary: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state_for_def(24.0, false, 3.0)
	var default_n2298: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(24.0, false)
	proof["class_default_boundary_24_accepted"] = bool(default_boundary.get("accepts", false)) == true and bool(default_boundary.get("size_fits", false)) == true and is_equal_approx(float(default_boundary.get("threshold", -1.0)), 24.0) and bool(default_n2298.get("accepts", false)) == true and is_equal_approx(float(default_n2298.get("threshold", -1.0)), 24.0)

	# Live tick: a placed payload-mass-driver exposes the
	# per-def verdict on the frame as accepts_payload, from
	# the frame-supplied offered_payload_size. Offered 21
	# with no payload held -> false (the class default would
	# accept it -- the per-def discriminator); offered 20 ->
	# true; offered 16 while holding a payload -> false. A
	# placed large-payload-mass-driver exposes its own
	# verdict: offered 32 -> true; offered 33 -> false. The
	# tick runs at half power (efficiency 0.5); the gate
	# itself does not depend on efficiency, so the verdict
	# tracks the offered size, the held payload, and the def
	# only.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var payload_mass_driver_cell := Vector2i(28, 21)
	var payload_mass_driver := Sprite2D.new()
	game.add_child(payload_mass_driver)
	game.call("record_placed_block", payload_mass_driver, blocks_by_id["payload-mass-driver"], payload_mass_driver_cell)
	var large_payload_mass_driver_cell := Vector2i(32, 21)
	var large_payload_mass_driver := Sprite2D.new()
	game.add_child(large_payload_mass_driver)
	game.call("record_placed_block", large_payload_mass_driver, blocks_by_id["large-payload-mass-driver"], large_payload_mass_driver_cell)
	# Bind the frames explicitly (the N2149 pattern: the driver
	# binds them on their first tick, but the proof needs the live
	# frame dicts before the tick to stamp power_status and the
	# offered sizes on them).
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(payload_mass_driver, blocks_by_id["payload-mass-driver"])
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(large_payload_mass_driver, blocks_by_id["large-payload-mass-driver"])
	var payload_mass_driver_frame: Dictionary = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var large_payload_mass_driver_frame: Dictionary = large_payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	payload_mass_driver_frame["power_status"] = 0.5
	large_payload_mass_driver_frame["power_status"] = 0.5
	payload_mass_driver_frame["offered_payload_size"] = 21.0
	large_payload_mass_driver_frame["offered_payload_size"] = 32.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	large_payload_mass_driver_frame = large_payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_small_rejects_21: bool = is_equal_approx(float(payload_mass_driver_frame.get("efficiency", -1.0)), 0.5) and bool(payload_mass_driver_frame.get("accepts_payload", true)) == false
	var live_large_accepts_32: bool = bool(large_payload_mass_driver_frame.get("accepts_payload", false)) == true
	payload_mass_driver_frame["offered_payload_size"] = 20.0
	large_payload_mass_driver_frame["offered_payload_size"] = 33.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	large_payload_mass_driver_frame = large_payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_small_accepts_20: bool = bool(payload_mass_driver_frame.get("accepts_payload", false)) == true
	var live_large_rejects_33: bool = bool(large_payload_mass_driver_frame.get("accepts_payload", true)) == false
	payload_mass_driver_frame["offered_payload_size"] = 16.0
	payload_mass_driver_frame["payload"] = {"size": 16.0}
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_held: bool = bool(payload_mass_driver_frame.get("accepts_payload", true)) == false
	proof["live_tick_exposes_per_def_verdict"] = live_small_rejects_21 and live_large_accepts_32 and live_small_accepts_20 and live_large_rejects_33 and live_held

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverPerDefThresholdProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
