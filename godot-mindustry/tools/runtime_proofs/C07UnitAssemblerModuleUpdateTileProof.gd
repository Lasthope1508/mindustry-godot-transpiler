extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
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

	# --- Pure link refresh (N2248): `if(lastChange != world.
	# tileChanges){` / `lastChange = world.tileChanges;` /
	# `findLink();` (UnitAssemblerModule.java:133-135, lastChange
	# init -2 at :73) with tileChanges starting at 1
	# (World.java:35, `public int tileChanges = 1,
	# floorChanges = 1;`), so a fresh module refreshes on its
	# first tick. findLink re-discovers the link
	# (`link = getLink(team, tile.x, tile.y, rotation);`,
	# UnitAssemblerModule.java:79) over the explicit
	# link-candidate frame input; the removeModule /
	# updateModules side effects on the assembler defer.
	var mech_assembler := {"block": "mech-assembler"}
	var tank_assembler := {"block": "tank-assembler"}
	var refreshed: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": -2, "tile_changes": 1, "link": null, "link_candidate": mech_assembler}, 1.0, 1.0)
	proof["link_refreshes_on_tile_change"] = int(refreshed.get("last_change", 0)) == 1 and bool(refreshed.get("link_refreshed", false)) and refreshed.get("link", null) == mech_assembler

	var kept: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": mech_assembler, "link_candidate": tank_assembler}, 1.0, 1.0)
	proof["no_refresh_without_change"] = int(kept.get("last_change", 0)) == 1 and bool(kept.get("link_refreshed", true)) == false and kept.get("link", null) == mech_assembler

	# --- Pure handoff gate (N2248): `if(moveInPayload() &&
	# link != null && link.moduleFits(block, x, y, rotation) &&
	# !link.wasOccupied && link.acceptPayload(this, payload) &&
	# efficiency > 0){` (UnitAssemblerModule.java:138) with
	# `link.yeetPayload(payload);` / `payload = null;` (:139-140).
	# moveInPayload(true) (PayloadBlock.java:181-197) approaches
	# the payVector toward zero at payloadSpeed * delta()
	# (0.7f, the PayloadBlock class default) and returns
	# hasArrived() (`return payVector.isZero(0.01f);`, the
	# SQUARED length under 0.01); moduleFits / wasOccupied /
	# acceptPayload are explicit frame predicates (the port has
	# no assembler object to evaluate them on).
	var payload := {"block": "conveyor"}
	var no_link: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": null, "payload": payload, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "rotation": 0, "module_fits": true, "was_occupied": false, "accept_payload": true, "efficiency": 1.0}, 1.0, 1.0)
	var no_fit: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": mech_assembler, "payload": payload, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "rotation": 0, "module_fits": false, "was_occupied": false, "accept_payload": true, "efficiency": 1.0}, 1.0, 1.0)
	# Not arrived yet: payVector (5, 0) approaches zero by 0.7
	# in one tick (delta() = 1.0 * 1.0) to (4.3, 0), whose
	# squared length 18.49 is still above the 0.01 margin, so
	# moveInPayload returns false and the gate never fires --
	# even though the link fits and would accept.
	var not_arrived: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": mech_assembler, "payload": payload, "pay_vector": Vector2(5, 0), "pay_rotation": 0.0, "rotation": 0, "module_fits": true, "was_occupied": false, "accept_payload": true, "efficiency": 1.0}, 1.0, 1.0)
	var not_arrived_vector: Vector2 = not_arrived.get("pay_vector", Vector2.ZERO)
	proof["handoff_needs_link_and_fit"] = bool(no_link.get("moved_in", false)) and bool(no_link.get("handed_off", true)) == false and no_link.get("payload", null) != null and bool(no_fit.get("handed_off", true)) == false and no_fit.get("payload", null) != null and bool(not_arrived.get("moved_in", true)) == false and bool(not_arrived.get("handed_off", true)) == false and not_arrived.get("payload", null) != null and is_equal_approx(not_arrived_vector.x, 4.3) and is_equal_approx(not_arrived_vector.y, 0.0)

	var occupied: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": mech_assembler, "payload": payload, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "rotation": 0, "module_fits": true, "was_occupied": true, "accept_payload": true, "efficiency": 1.0}, 1.0, 1.0)
	proof["handoff_blocked_when_occupied"] = bool(occupied.get("moved_in", false)) and bool(occupied.get("handed_off", true)) == false and occupied.get("payload", null) != null

	var no_power: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_update_tile_advance_state({"last_change": 1, "tile_changes": 1, "link": mech_assembler, "payload": payload, "pay_vector": Vector2.ZERO, "pay_rotation": 0.0, "rotation": 0, "module_fits": true, "was_occupied": false, "accept_payload": true, "efficiency": 0.0}, 1.0, 1.0)
	proof["handoff_blocked_without_power"] = bool(no_power.get("moved_in", false)) and bool(no_power.get("handed_off", true)) == false and no_power.get("payload", null) != null

	# --- Live tick: the unit-assembler-module is a
	# UnitAssemblerModule build with a power consumer
	# (consumePower 3.5f), placed live; the tick driver is
	# called directly (as the N2168 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The frame is seeded with a held
	# payload, a link candidate, and the handoff predicates;
	# the fresh frame's lastChange is -2 against tileChanges 1,
	# so the first tick refreshes the link to the candidate and
	# -- with full power -- hands the payload off, clearing the
	# frame payload. The assembler-side yeetPayload receive is
	# N2131's intake state; the module side only clears.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unit_assembler_module_cell := Vector2i(28, 21)
	var unit_assembler_module := Sprite2D.new()
	game.add_child(unit_assembler_module)
	game.call("record_placed_block", unit_assembler_module, blocks_by_id["basic-assembler-module"], unit_assembler_module_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to seed the payload + link
	# candidate + predicates on it).
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(unit_assembler_module, blocks_by_id["basic-assembler-module"])
	var unit_assembler_module_frame: Dictionary = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})

	unit_assembler_module_frame["payload"] = {"block": "conveyor"}
	unit_assembler_module_frame["link_candidate"] = mech_assembler
	unit_assembler_module_frame["module_fits"] = true
	unit_assembler_module_frame["was_occupied"] = false
	unit_assembler_module_frame["accept_payload"] = true
	unit_assembler_module_frame["pay_vector"] = Vector2.ZERO
	unit_assembler_module_frame["pay_rotation"] = 0.0
	unit_assembler_module_frame["power_status"] = 1.0
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["handoff_clears_payload"] = is_equal_approx(float(unit_assembler_module_frame.get("efficiency", -1.0)), 1.0) and unit_assembler_module_frame.get("link", null) == mech_assembler and bool(unit_assembler_module_frame.get("link_refreshed", false)) and bool(unit_assembler_module_frame.get("moved_in", false)) and bool(unit_assembler_module_frame.get("handed_off", false)) and unit_assembler_module_frame.get("payload", {"block": "conveyor"}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
