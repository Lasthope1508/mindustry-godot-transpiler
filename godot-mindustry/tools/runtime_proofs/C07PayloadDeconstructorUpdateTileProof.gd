extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- Pure advance (N2233): PayloadDeconstructorBuild.updateTile()
	# (PayloadDeconstructor.java:109-204): progress resets to 0f
	# with no deconstructing payload (:117-119); payRotation moves
	# toward 90f at payloadRotateSpeed * edelta() (:121, NOTE
	# edelta(), not delta() as in moveInPayload); the deconstruct
	# branch (:123-196) resizes accum (:126-128), gates on
	# canProgress (items.total() <= itemCapacity && every accum <
	# 1f, :132-140), advances shift = edelta() * deconstructSpeed
	# / buildTime() (:142) with progress += shift -- NOT
	# realShift, so progress can pass 1f (:159) -- folds the
	# requirements into accum with the build / unit cost
	# multiplier (:163-165), lerps speedScl toward 1f / 0f at
	# 0.1f (:167), transfers whole items into the inventory
	# (:170-176), and at progress >= 1f (:179) runs the rounding
	# check (equal(accum[i], 1f, 0.0001f), :182) before clearing
	# deconstructing / accum (:191-194); the intake branch
	# (:197-201) moves the payload in with rotate = FALSE and
	# starts deconstructing it. source_delta is Time.delta in
	# ticks (1.0 = one tick). The payload dict contract is kind
	# ("build" / "unit"), requirements (ItemStack list of {item,
	# amount}), build_time; the deconstructSpeed / itemCapacity
	# here are the deconstructor def values (6f / 250,
	# Blocks.java:6655/6652).
	var build_payload: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 60.0}
	var slow_payload: Dictionary = {"kind": "build", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 600.0}
	var unit_payload: Dictionary = {"kind": "unit", "requirements": [{"item": "copper", "amount": 10}, {"item": "lead", "amount": 5}], "build_time": 600.0}

	# Intake: a payload nearly at the center (payVector 0.05)
	# snaps to zero at payloadSpeed 1f over one tick (approach
	# alpha 1.0) and arrives (len2 0 < 0.01), so the payload
	# moves into deconstructing with a fresh zero accum and
	# progress 0f -- even though the frame progress was 0.7. A
	# payload 5 tiles out only approaches to 4.0 and does not
	# arrive, so the payload stays held (progress still resets
	# to 0f, the no-deconstructing branch).
	var intake_frame: Dictionary = {"efficiency": 1.0, "payload": build_payload, "deconstructing": null, "pay_vector": Vector2(0.05, 0.0), "pay_rotation": 0.0, "progress": 0.7, "items": {}}
	var intaken: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(intake_frame, 1.0, 1.0, 6.0, 250)
	var far_frame: Dictionary = {"efficiency": 1.0, "payload": build_payload, "deconstructing": null, "pay_vector": Vector2(5.0, 0.0), "pay_rotation": 0.0, "progress": 0.7, "items": {}}
	var far: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(far_frame, 1.0, 1.0, 6.0, 250)
	proof["intake_moves_payload_to_deconstructing"] = intaken.get("deconstructing") != null and intaken.get("payload") == null and (intaken.get("accum", []) as Array) == [0.0, 0.0] and is_equal_approx(float(intaken.get("progress", -1.0)), 0.0) and (intaken.get("pay_vector", Vector2.ONE) as Vector2) == Vector2.ZERO and far.get("deconstructing") == null and far.get("payload") != null and (far.get("pay_vector", Vector2.ZERO) as Vector2) == Vector2(4.0, 0.0) and is_equal_approx(float(far.get("progress", -1.0)), 0.0)

	# Progress: shift = edelta() * deconstructSpeed / buildTime()
	# = 1.0 * 6 / 60 = 0.1 at full efficiency, 0.05 at half
	# efficiency, 0.2 at a doubled timeScale; time gains edelta()
	# (1.0 / 0.5 / 2.0).
	var progress_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.0, "time": 0.0, "speed_scl": 0.0, "items": {}}
	var progressed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(progress_frame, 1.0, 1.0, 6.0, 250)
	var half_frame: Dictionary = {"efficiency": 0.5, "deconstructing": build_payload, "progress": 0.0, "time": 0.0, "speed_scl": 0.0, "items": {}}
	var half: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(half_frame, 1.0, 1.0, 6.0, 250)
	var scaled: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(progress_frame, 1.0, 2.0, 6.0, 250)
	proof["progress_advances_with_edelta"] = is_equal_approx(float(progressed.get("progress", -1.0)), 0.1) and is_equal_approx(float(progressed.get("time", -1.0)), 1.0) and is_equal_approx(float(half.get("progress", -1.0)), 0.05) and is_equal_approx(float(half.get("time", -1.0)), 0.5) and is_equal_approx(float(scaled.get("progress", -1.0)), 0.2) and is_equal_approx(float(scaled.get("time", -1.0)), 2.0) and bool(progressed.get("finished", true)) == false

	# Accum: with buildTime 600 the shift is 0.01, so one tick
	# folds copper 10 * 1.0 * 0.01 = 0.1 and lead 5 * 1.0 *
	# 0.01 = 0.05 -- below 1, so no transfer runs. A unit
	# payload with a unit cost multiplier of 2.0 folds twice
	# that; a build payload with a build cost multiplier of
	# 0.5 folds half.
	var accum_frame: Dictionary = {"efficiency": 1.0, "deconstructing": slow_payload, "progress": 0.0, "time": 0.0, "speed_scl": 0.0, "items": {}}
	var folded: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(accum_frame, 1.0, 1.0, 6.0, 250)
	var folded_accum: Array = folded.get("accum", [])
	var unit_frame: Dictionary = {"efficiency": 1.0, "deconstructing": unit_payload, "progress": 0.0, "time": 0.0, "speed_scl": 0.0, "items": {}}
	var unit_folded: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(unit_frame, 1.0, 1.0, 6.0, 250, 1.0, 2.0)
	var unit_accum: Array = unit_folded.get("accum", [])
	var cheap_folded: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(accum_frame, 1.0, 1.0, 6.0, 250, 0.5, 1.0)
	var cheap_accum: Array = cheap_folded.get("accum", [])
	proof["accum_folds_requirements"] = is_equal_approx(float(folded_accum[0]), 0.1) and is_equal_approx(float(folded_accum[1]), 0.05) and is_equal_approx(float(unit_accum[0]), 0.2) and is_equal_approx(float(unit_accum[1]), 0.1) and is_equal_approx(float(cheap_accum[0]), 0.05) and is_equal_approx(float(cheap_accum[1]), 0.025) and (folded.get("items", {}) as Dictionary).is_empty()

	# Transfer: accum [2.7, 0.9] blocks progress (accum[0] >=
	# 1f, so canProgress is false and progress stays 0.5 while
	# speedScl lerps toward 0f: 1.0 -> 0.9), but the transfer
	# still runs: 2 copper move into the inventory (3 -> 5)
	# and accum[0] drops to 0.7. Near capacity only the room
	# fits: 1 copper moves (249 -> 250) and accum[0] drops to
	# 1.7.
	var transfer_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.5, "accum": [2.7, 0.9], "time": 0.0, "speed_scl": 1.0, "items": {"copper": 3}}
	var transferred: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(transfer_frame, 1.0, 1.0, 6.0, 250)
	var transferred_items: Dictionary = transferred.get("items", {})
	var transferred_accum: Array = transferred.get("accum", [])
	var full_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.5, "accum": [2.7, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {"copper": 249}}
	var full: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(full_frame, 1.0, 1.0, 6.0, 250)
	var full_items: Dictionary = full.get("items", {})
	var full_accum: Array = full.get("accum", [])
	proof["transfer_moves_whole_items"] = is_equal_approx(float(transferred.get("progress", -1.0)), 0.5) and is_equal_approx(float(transferred.get("speed_scl", -1.0)), 0.9) and int(transferred_items.get("copper", -1)) == 5 and is_equal_approx(float(transferred_accum[0]), 0.7) and is_equal_approx(float(transferred_accum[1]), 0.9) and int(full_items.get("copper", -1)) == 250 and is_equal_approx(float(full_accum[0]), 1.7)

	# Finish: progress 0.95 + shift 0.1 = 1.05 -- past 1f,
	# because progress += shift, NOT realShift -- so the
	# deconstruction finishes and deconstructing / accum clear.
	# The rounding check catches accum 0.99995 (within 0.0001
	# of 1f after the fold) and pays out 1 copper; with a full
	# inventory the same rounding check blocks the finish and
	# the payload stays deconstructing.
	var finish_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.95, "accum": [0.0, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {}}
	var finished: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(finish_frame, 1.0, 1.0, 6.0, 250)
	var rounding_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.95, "accum": [0.49995, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {}}
	var rounded: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(rounding_frame, 1.0, 1.0, 6.0, 250)
	var rounded_items: Dictionary = rounded.get("items", {})
	var blocked_frame: Dictionary = {"efficiency": 1.0, "deconstructing": build_payload, "progress": 0.95, "accum": [0.49995, 0.0], "time": 0.0, "speed_scl": 0.0, "items": {"copper": 250}}
	var blocked: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(blocked_frame, 1.0, 1.0, 6.0, 250)
	proof["finish_clears_deconstructing"] = bool(finished.get("finished", false)) and finished.get("deconstructing") == null and finished.get("accum") == null and is_equal_approx(float(finished.get("progress", -1.0)), 1.05) and bool(rounded.get("finished", false)) and int(rounded_items.get("copper", -1)) == 1 and bool(blocked.get("finished", true)) == false and blocked.get("deconstructing") != null

	# No deconstructing payload: progress resets to 0f, but
	# time / speedScl / accum are untouched (only the reset
	# runs outside the deconstruct branch); payRotation still
	# moves toward 90f at 5 * edelta() = 5.0.
	var idle_frame: Dictionary = {"efficiency": 1.0, "deconstructing": null, "payload": null, "progress": 0.7, "time": 3.0, "speed_scl": 0.5, "accum": [1.0, 2.0], "pay_rotation": 0.0, "items": {}}
	var idled: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_update_tile_advance_state(idle_frame, 1.0, 1.0, 6.0, 250)
	proof["progress_zero_without_deconstructing"] = is_equal_approx(float(idled.get("progress", -1.0)), 0.0) and is_equal_approx(float(idled.get("time", -1.0)), 3.0) and is_equal_approx(float(idled.get("speed_scl", -1.0)), 0.5) and (idled.get("accum", []) as Array) == [1.0, 2.0] and is_equal_approx(float(idled.get("pay_rotation", -1.0)), 5.0) and bool(idled.get("finished", true)) == false

	# --- Live tick: the payload-deconstructor is a PayloadDeconstructor build
	# with a power consumer (consumePower 3f), placed live; the
	# tick driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2200/N2210
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. One 1/60s
	# tick is one source tick: efficiency folds the power min
	# 0.5, the advance runs after consumption with the
	# deconstructor def values (deconstructSpeed 6f,
	# itemCapacity 250), so progress rises 0.5 * 6 / 60 = 0.05,
	# time gains 0.5, accum folds copper 10 * 0.05 = 0.5 and
	# lead 5 * 0.05 = 0.25, speedScl lerps to 0.1, and
	# payRotation moves toward 90f by 5 * 0.5 = 2.5. The
	# deconstructing fixture is a contract payload (kind /
	# requirements / build_time), not the minimal
	# {"block": "conveyor"} dicts the N2166/N2210 proofs use.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_deconstructor_cell := Vector2i(28, 21)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the deconstructing payload on it).
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})

	payload_deconstructor_frame["deconstructing"] = build_payload
	payload_deconstructor_frame["power_status"] = 0.5
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	var live_accum: Array = payload_deconstructor_frame.get("accum", [])
	proof["live_tick_advances_progress"] = is_equal_approx(float(payload_deconstructor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(payload_deconstructor_frame.get("progress", -1.0)), 0.05) and is_equal_approx(float(payload_deconstructor_frame.get("time", -1.0)), 0.5) and is_equal_approx(float(live_accum[0]), 0.5) and is_equal_approx(float(live_accum[1]), 0.25) and is_equal_approx(float(payload_deconstructor_frame.get("speed_scl", -1.0)), 0.1) and is_equal_approx(float(payload_deconstructor_frame.get("pay_rotation", -1.0)), 2.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
