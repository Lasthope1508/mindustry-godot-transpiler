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

	# --- Pure gate (N2298): PayloadDriverBuild.acceptPayload
	# (PayloadMassDriver.java:462-463):
	# `return super.acceptPayload(source, payload) &&
	# payload.size() <= maxPayloadSize * tilesize;`, where
	# super.acceptPayload is `return this.payload == null;`
	# (PayloadBlock.java:116-118) and maxPayloadSize is
	# `public float maxPayloadSize = 3;`
	# (PayloadMassDriver.java:30) times tilesize 8
	# (Vars.java:135) -- the class-default threshold is 24. A
	# BuildPayload size is `return build.block.size *
	# tilesize;` (BuildPayload.java:86-88), so a size-2 block
	# payload measures 16, a size-3 block payload measures 24
	# (exactly on the boundary -- the comparison is <=, so the
	# boundary accepts), and a size-4 block payload measures
	# 32. The DEFERRED entry that scoped this slice cited
	# PayloadMassDriver.java:317-319 -- that range is the
	# transfer reset (other.state = idle), NOT acceptPayload;
	# the correct cite is :462-463. The per-def overrides
	# (maxPayloadSize 2.5f / 4f, Blocks.java:6624/6636) beat
	# the class default in Java; this pure uses the class
	# default (threshold 24) and the per-def thresholds
	# (20 / 32) wait for their own slice.

	# Accepts when empty and the size fits: a size-2 payload
	# (16) and a size-1 payload (8) both fit under 24, and the
	# threshold reads 24 in both cases.
	var fits_small: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(8.0, false)
	var fits: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(16.0, false)
	proof["accepts_when_empty_and_size_fits"] = bool(fits_small.get("accepts", false)) == true and bool(fits_small.get("size_fits", false)) == true and is_equal_approx(float(fits_small.get("threshold", -1.0)), 24.0) and bool(fits.get("accepts", false)) == true and bool(fits.get("size_fits", false)) == true and is_equal_approx(float(fits.get("threshold", -1.0)), 24.0)

	# Rejects when a payload is held: the base gate
	# (this.payload == null) fails, so even a fitting size-2
	# payload (16) is refused -- size_fits stays true, the
	# verdict is the AND of the two gates.
	var held: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(16.0, true)
	var held_small: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(8.0, true)
	proof["rejects_when_payload_present"] = bool(held.get("accepts", true)) == false and bool(held.get("size_fits", false)) == true and bool(held_small.get("accepts", true)) == false and bool(held_small.get("size_fits", false)) == true

	# Rejects oversize: a size-4 payload (32) exceeds 24, so
	# size_fits is false and the verdict is false even with no
	# payload held.
	var oversize: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(32.0, false)
	var just_over: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(25.0, false)
	proof["rejects_oversize"] = bool(oversize.get("accepts", true)) == false and bool(oversize.get("size_fits", true)) == false and bool(just_over.get("accepts", true)) == false and bool(just_over.get("size_fits", true)) == false

	# Boundary: a size-3 payload (24) sits exactly on the
	# threshold, and the comparison is <=, so it accepts.
	var boundary: Dictionary = payload_mass_driver_build_state.source_payload_mass_driver_accept_payload_state(24.0, false)
	proof["boundary_size_24_accepted"] = bool(boundary.get("accepts", false)) == true and bool(boundary.get("size_fits", false)) == true and is_equal_approx(float(boundary.get("threshold", -1.0)), 24.0)

	# Live tick: a placed payload-mass-driver exposes the
	# verdict on the frame as accepts_payload, from the
	# frame-supplied offered_payload_size. Offered 16 with no
	# payload held -> true; offered 32 -> false; offered 16
	# while holding a payload -> false. The tick runs at half
	# power (efficiency 0.5); the gate itself does not depend
	# on efficiency, so the verdict tracks the offered size
	# and the held payload only.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var payload_mass_driver_cell := Vector2i(28, 21)
	var payload_mass_driver := Sprite2D.new()
	game.add_child(payload_mass_driver)
	game.call("record_placed_block", payload_mass_driver, blocks_by_id["payload-mass-driver"], payload_mass_driver_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and the
	# offered size on it).
	payload_mass_driver_build_state.source_payload_mass_driver_bind_frame_state(payload_mass_driver, blocks_by_id["payload-mass-driver"])
	var payload_mass_driver_frame: Dictionary = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	payload_mass_driver_frame["power_status"] = 0.5
	payload_mass_driver_frame["offered_payload_size"] = 16.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_fits: bool = is_equal_approx(float(payload_mass_driver_frame.get("efficiency", -1.0)), 0.5) and bool(payload_mass_driver_frame.get("accepts_payload", false)) == true
	payload_mass_driver_frame["offered_payload_size"] = 32.0
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_oversize: bool = bool(payload_mass_driver_frame.get("accepts_payload", true)) == false
	payload_mass_driver_frame["offered_payload_size"] = 16.0
	payload_mass_driver_frame["payload"] = {"size": 16.0}
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_held: bool = bool(payload_mass_driver_frame.get("accepts_payload", true)) == false
	proof["live_tick_exposes_verdict"] = live_fits and live_oversize and live_held

	# No payload offered: the frame carries no
	# offered_payload_size, so there is nothing to accept and
	# the verdict defaults false (the held payload is cleared
	# first so the only reason for false is the missing offer).
	payload_mass_driver_frame["payload"] = null
	payload_mass_driver_frame.erase("offered_payload_size")
	payload_mass_driver_build_state.source_payload_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	payload_mass_driver_frame = payload_mass_driver.get_meta(payload_mass_driver_build_state.SOURCE_PAYLOAD_MASS_DRIVER_BUILDING_META_KEY, {})
	proof["no_payload_offered_false"] = bool(payload_mass_driver_frame.get("accepts_payload", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadMassDriverAcceptPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
