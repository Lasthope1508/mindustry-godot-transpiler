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

	# --- Pure acceptPayload (N2297):
	# PayloadDeconstructorBuild.acceptPayload(Building
	# source, Payload payload)
	# (PayloadDeconstructor.java:104-106):
	# `return deconstructing == null && this.payload ==
	# null && super.acceptPayload(source, payload) &&
	# payload.requirements().length > 0 &&
	# payload.fits(maxPayloadSize);`
	# `deconstructing == null` reads the nullable field
	# `public @Nullable Payload deconstructing;`
	# (PayloadDeconstructor.java:52); `this.payload ==
	# null` reads the held payload (`public @Nullable T
	# payload;`, PayloadBlock.java:92);
	# `super.acceptPayload(source, payload)` is the
	# PayloadBlock base gate (PayloadBlock.java:116-118,
	# `return this.payload == null;`) -- the SAME term
	# as the one before it, so it is REDUNDANT here, and
	# the pure ANDs it in again anyway to stay
	# Java-exact. `payload.requirements().length > 0`
	# requires deconstructable requirements (a
	# BuildPayload's are its block requirements,
	# `return build.block.requirements;`,
	# BuildPayload.java:66-68; a UnitPayload's are its
	# unit type total requirements, `return
	# unit.type.getTotalRequirements();`,
	# UnitPayload.java:61-63). `payload.fits(
	# maxPayloadSize)` is the Payload default (`return
	# size() / tilesize <= s;`, Payload.java:50-52): a
	# BuildPayload is block.size tiles (`return
	# build.block.size * tilesize;`,
	# BuildPayload.java:86-88), so it fits when
	# block.size <= maxPayloadSize (4,
	# PayloadDeconstructor.java:18, `public float
	# maxPayloadSize = 4;`). The payload descriptor
	# carries requirements_length (int) and block_size
	# (int, the payload size in tiles); missing keys
	# default to the rejecting value.
	var offered: Dictionary = {"requirements_length": 2, "block_size": 3}
	var accepted: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state(offered, false, false)
	var accepted_edge: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state({"requirements_length": 1, "block_size": 4}, false, false)
	proof["accepts_payload_when_empty_with_requirements"] = bool(accepted.get("accepts", false)) == true and bool(accepted.get("deconstructing_empty", false)) == true and bool(accepted.get("payload_empty", false)) == true and bool(accepted.get("has_requirements", false)) == true and bool(accepted.get("fits", false)) == true and bool(accepted_edge.get("accepts", false)) == true and bool(accepted_edge.get("fits", false)) == true

	# A busy deconstructor takes no payload: deconstructing
	# present rejects (deconstructing_empty false, the rest
	# of the terms still true), and a held payload rejects
	# too (payload_empty false -- and the redundant super
	# term with it).
	var busy_deconstructing: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state(offered, false, true)
	var busy_payload: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state(offered, true, false)
	var busy_both: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state(offered, true, true)
	proof["rejects_payload_when_deconstructing_busy"] = bool(busy_deconstructing.get("accepts", true)) == false and bool(busy_deconstructing.get("deconstructing_empty", true)) == false and bool(busy_deconstructing.get("payload_empty", false)) == true and bool(busy_deconstructing.get("has_requirements", false)) == true and bool(busy_deconstructing.get("fits", false)) == true and bool(busy_payload.get("accepts", true)) == false and bool(busy_payload.get("payload_empty", true)) == false and bool(busy_payload.get("deconstructing_empty", false)) == true and bool(busy_both.get("accepts", true)) == false

	# A payload with nothing to deconstruct is refused
	# (requirements_length 0), and so is an oversize one
	# (block_size 5 > maxPayloadSize 4); a descriptor
	# missing both keys rejects on both terms.
	var empty_reqs: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state({"requirements_length": 0, "block_size": 3}, false, false)
	var oversize: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state({"requirements_length": 2, "block_size": 5}, false, false)
	var missing: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_payload_state({}, false, false)
	proof["rejects_empty_requirements_payload"] = bool(empty_reqs.get("accepts", true)) == false and bool(empty_reqs.get("has_requirements", true)) == false and bool(empty_reqs.get("fits", false)) == true and bool(oversize.get("accepts", true)) == false and bool(oversize.get("fits", true)) == false and bool(oversize.get("has_requirements", false)) == true and bool(missing.get("accepts", true)) == false and bool(missing.get("has_requirements", true)) == false and bool(missing.get("fits", true)) == false

	# --- Pure acceptUnitPayload (N2297):
	# PayloadDeconstructorBuild.acceptUnitPayload(Unit
	# unit) (PayloadDeconstructor.java:92-95):
	# `return payload == null && deconstructing == null
	# && unit.type.allowedInPayloads && !unit.spawnedByCore`
	# `&& unit.type.getTotalRequirements().length > 0 &&
	# unit.hitSize / tilesize <= maxPayloadSize;`
	# `unit.type.allowedInPayloads` is the unit-type flag
	# (`allowedInPayloads = true,`, UnitType.java:189,
	# "if false, this unit cannot be moved into
	# payloads"); `!unit.spawnedByCore` reads the unit
	# flag (`boolean spawnedByCore;`, UnitComp.java:52);
	# `unit.type.getTotalRequirements().length > 0`
	# requires deconstructable requirements (`public
	# ItemStack[] getTotalRequirements(){`,
	# UnitType.java:1323); `unit.hitSize / tilesize <=
	# maxPayloadSize` is the UnitPayload fits check
	# inlined: a UnitPayload is hitSize pixels (`return
	# unit.hitSize;`, UnitPayload.java:99-101), so it
	# fits when hitSize / 8 <= 4, i.e. hitSize <= 32
	# (`public static final int tilesize = 8;`,
	# Vars.java:135). The unit descriptor carries
	# allowed_in_payloads (bool), spawned_by_core
	# (bool), total_requirements_length (int) and
	# hit_size (float, pixels); missing keys default to
	# the rejecting value.
	var unit: Dictionary = {"allowed_in_payloads": true, "spawned_by_core": false, "total_requirements_length": 3, "hit_size": 24.0}
	var unit_accepted: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state(unit, false, false)
	var unit_edge: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({"allowed_in_payloads": true, "spawned_by_core": false, "total_requirements_length": 1, "hit_size": 32.0}, false, false)
	var unit_busy: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state(unit, false, true)
	var unit_held: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state(unit, true, false)
	proof["accepts_unit_when_allowed"] = bool(unit_accepted.get("accepts", false)) == true and bool(unit_accepted.get("allowed", false)) == true and bool(unit_accepted.get("has_requirements", false)) == true and bool(unit_accepted.get("fits", false)) == true and bool(unit_edge.get("accepts", false)) == true and bool(unit_edge.get("fits", false)) == true and bool(unit_busy.get("accepts", true)) == false and bool(unit_held.get("accepts", true)) == false

	# A core-spawned unit is refused even when its type
	# allows payloads, and a type that forbids payloads
	# is refused even when the unit is not core-spawned;
	# both refuse through the allowed term.
	var core_spawned: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({"allowed_in_payloads": true, "spawned_by_core": true, "total_requirements_length": 3, "hit_size": 24.0}, false, false)
	var not_allowed: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({"allowed_in_payloads": false, "spawned_by_core": false, "total_requirements_length": 3, "hit_size": 24.0}, false, false)
	proof["rejects_core_spawned_unit"] = bool(core_spawned.get("accepts", true)) == false and bool(core_spawned.get("allowed", true)) == false and bool(core_spawned.get("has_requirements", false)) == true and bool(core_spawned.get("fits", false)) == true and bool(not_allowed.get("accepts", true)) == false and bool(not_allowed.get("allowed", true)) == false

	# An oversize unit is refused (hitSize 40 -> 40 / 8
	# = 5 > maxPayloadSize 4); a unit with no total
	# requirements is refused too; a descriptor missing
	# every key rejects on every term.
	var oversize_unit: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({"allowed_in_payloads": true, "spawned_by_core": false, "total_requirements_length": 3, "hit_size": 40.0}, false, false)
	var no_reqs_unit: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({"allowed_in_payloads": true, "spawned_by_core": false, "total_requirements_length": 0, "hit_size": 24.0}, false, false)
	var missing_unit: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_accept_unit_payload_state({}, false, false)
	proof["rejects_oversize_unit"] = bool(oversize_unit.get("accepts", true)) == false and bool(oversize_unit.get("fits", true)) == false and bool(oversize_unit.get("allowed", false)) == true and bool(oversize_unit.get("has_requirements", false)) == true and bool(no_reqs_unit.get("accepts", true)) == false and bool(no_reqs_unit.get("has_requirements", true)) == false and bool(missing_unit.get("accepts", true)) == false and bool(missing_unit.get("allowed", true)) == false and bool(missing_unit.get("has_requirements", true)) == false and bool(missing_unit.get("fits", true)) == false

	# --- Live tick: the payload-deconstructor is a
	# PayloadDeconstructor build with a power consumer
	# (consumePower 3f), placed live; the tick driver is
	# called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/
	# N2161 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped
	# power_status -- the write-back itself is already
	# proven by N2142. The tick wires the acceptance
	# verdicts from the frame offered descriptors: with
	# an empty deconstructor and a 3-tile payload with
	# requirements offered, frame accepts_payload reads
	# true; with an allowed 24-pixel unit with
	# requirements offered, frame accepts_unit_payload
	# reads true. A second tick with no offer (the
	# descriptors cleared) reads both verdicts false.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var payload_deconstructor_cell := Vector2i(28, 22)
	var payload_deconstructor := Sprite2D.new()
	game.add_child(payload_deconstructor)
	game.call("record_placed_block", payload_deconstructor, blocks_by_id["deconstructor"], payload_deconstructor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp the inputs on it).
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(payload_deconstructor, blocks_by_id["deconstructor"])
	var payload_deconstructor_frame: Dictionary = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})

	payload_deconstructor_frame["power_status"] = 1.0
	payload_deconstructor_frame["offered_payload"] = offered
	payload_deconstructor_frame["offered_unit"] = unit
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["accepts_payload_when_empty_with_requirements"] = bool(proof["accepts_payload_when_empty_with_requirements"]) and bool(payload_deconstructor_frame.get("accepts_payload", false)) == true
	proof["accepts_unit_when_allowed"] = bool(proof["accepts_unit_when_allowed"]) and bool(payload_deconstructor_frame.get("accepts_unit_payload", false)) == true
	payload_deconstructor_frame["offered_payload"] = null
	payload_deconstructor_frame["offered_unit"] = null
	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	payload_deconstructor_frame = payload_deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	proof["accepts_payload_when_empty_with_requirements"] = bool(proof["accepts_payload_when_empty_with_requirements"]) and bool(payload_deconstructor_frame.get("accepts_payload", true)) == false
	proof["accepts_unit_when_allowed"] = bool(proof["accepts_unit_when_allowed"]) and bool(payload_deconstructor_frame.get("accepts_unit_payload", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorAcceptPayloadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
