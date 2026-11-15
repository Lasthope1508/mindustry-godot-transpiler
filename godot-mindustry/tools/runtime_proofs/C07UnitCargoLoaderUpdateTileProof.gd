extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_cargo_loader_build_state := preload("res://src/game/SourceUnitCargoLoaderBuildState.gd")
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

	# --- Pure advance (N2234): UnitTransportSourceBuild.updateTile()
	# (UnitCargoLoader.java:92-125): the unit lost/destroyed clear
	# (UnitCargoLoader.java:94-96), the readUnitId unbox
	# (UnitCargoLoader.java:98-103), the warmup / readyness
	# approachDelta folds (UnitCargoLoader.java:105-106), the
	# canCreate-gated build advance (UnitCargoLoader.java:108-110)
	# and the spawn at build complete (UnitCargoLoader.java:112-122),
	# with the buildProgress reset via spawned()
	# (UnitCargoLoader.java:127-133). source_delta is Time.delta in
	# ticks (1.0 = one tick). The live Groups.unit.getByID query has
	# no fill yet, so the pure advance takes found_unit as an
	# explicit param (dict or null, default null); the port is
	# single-player (!net.client() always true), so a null
	# found_unit still clears readUnitId and the spawn always
	# takes the server branch. Units.canCreate arrives as the
	# explicit can_create param (default true); the live cap check
	# waits for the N2140 helper wiring. The spawn is a pure result
	# (the N2228 `consumed` precedent): spawned_unit is
	# {type: manifold, x, y, rotation: 90} plus the unit-dict
	# contract flags (dead false, added true) when buildProgress
	# reaches 1f, else null; the live creation/application defers.
	# The unit dict contract is {type, x, y, rotation, dead
	# (default false), added (default true)}.
	var dead_unit: Dictionary = {"type": "dart", "dead": true, "added": true}
	var removed_unit: Dictionary = {"type": "dart", "dead": false, "added": false}
	var live_unit: Dictionary = {"type": "dart", "dead": false, "added": true}
	var minimal_unit: Dictionary = {"type": "dart"}
	var lost_dead: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"unit": dead_unit}, 1.0, 1.0)
	var lost_removed: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"unit": removed_unit}, 1.0, 1.0)
	var kept_live: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"unit": live_unit}, 1.0, 1.0)
	var kept_minimal: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"unit": minimal_unit}, 1.0, 1.0)
	proof["lost_unit_clears"] = lost_dead.get("unit", {}) == null and lost_removed.get("unit", {}) == null and kept_live.get("unit", null) != null and kept_minimal.get("unit", null) != null

	var warmup_frame: Dictionary = {"efficiency": 1.0, "warmup": 0.0}
	for iteration in range(60):
		var advanced: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state(warmup_frame, 1.0, 1.0)
		warmup_frame["warmup"] = advanced["warmup"]
	var decay_frame: Dictionary = {"efficiency": 0.0, "warmup": 1.0}
	for iteration in range(60):
		var decayed: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state(decay_frame, 1.0, 1.0)
		decay_frame["warmup"] = decayed["warmup"]
	var single_step: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 0.25, "warmup": 0.5}, 1.0, 1.0)
	var scaled_step: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "warmup": 0.0}, 1.0, 2.0)
	proof["warmup_approaches_efficiency"] = is_equal_approx(float(warmup_frame.get("warmup", -1.0)), 1.0) and is_equal_approx(float(decay_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(single_step.get("warmup", -1.0)), 0.5 - 1.0 / 60.0) and is_equal_approx(float(scaled_step.get("warmup", -1.0)), 1.0 / 60.0)

	var build_base: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0)
	var build_half: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 0.5, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0)
	var build_scaled: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 2.0)
	var build_blocked: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0, null, false)
	var build_held: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "unit": live_unit, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0)
	var unbox_found: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "read_unit_id": 7, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0, live_unit)
	var unbox_null: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "read_unit_id": 7, "build_progress": 0.0, "total_progress": 0.0}, 1.0, 1.0, null)
	proof["build_progress_advances_when_empty"] = is_equal_approx(float(build_base.get("build_progress", -1.0)), 1.0 / 480.0) and is_equal_approx(float(build_base.get("total_progress", -1.0)), 1.0) and is_equal_approx(float(build_half.get("build_progress", -1.0)), 0.5 / 480.0) and is_equal_approx(float(build_half.get("total_progress", -1.0)), 0.5) and is_equal_approx(float(build_scaled.get("build_progress", -1.0)), 2.0 / 480.0) and is_equal_approx(float(build_scaled.get("total_progress", -1.0)), 2.0) and is_equal_approx(float(build_blocked.get("build_progress", -1.0)), 0.0) and is_equal_approx(float(build_blocked.get("total_progress", -1.0)), 0.0) and is_equal_approx(float(build_held.get("build_progress", -1.0)), 0.0) and is_equal_approx(float(build_held.get("total_progress", -1.0)), 0.0) and unbox_found.get("unit", null) != null and int(unbox_found.get("read_unit_id", -99)) == -1 and is_equal_approx(float(unbox_found.get("build_progress", -1.0)), 0.0) and unbox_null.get("unit", {}) == null and int(unbox_null.get("read_unit_id", -99)) == -1 and is_equal_approx(float(unbox_null.get("build_progress", -1.0)), 1.0 / 480.0) and is_equal_approx(float(unbox_null.get("total_progress", -1.0)), 1.0)

	var spawn_frame: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 1.0 - 1.0 / 480.0, "total_progress": 10.0, "x": 120.0, "y": 240.0}, 1.0, 1.0)
	var spawn_unit: Dictionary = spawn_frame.get("spawned_unit", {})
	var below_frame: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 0.5, "total_progress": 0.0}, 1.0, 1.0)
	var blocked_frame: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"efficiency": 1.0, "build_progress": 0.999, "total_progress": 0.0}, 1.0, 1.0, null, false)
	proof["spawn_at_build_complete"] = is_equal_approx(float(spawn_frame.get("build_progress", -1.0)), 0.0) and is_equal_approx(float(spawn_frame.get("total_progress", -1.0)), 11.0) and spawn_frame.get("spawned_unit", null) != null and str(spawn_unit.get("type", "")) == "manifold" and is_equal_approx(float(spawn_unit.get("x", -1.0)), 120.0) and is_equal_approx(float(spawn_unit.get("y", -1.0)), 240.0) and is_equal_approx(float(spawn_unit.get("rotation", -1.0)), 90.0) and bool(spawn_unit.get("dead", true)) == false and bool(spawn_unit.get("added", false)) and spawn_frame.get("unit", null) != null and below_frame.get("spawned_unit", {}) == null and is_equal_approx(float(below_frame.get("build_progress", -1.0)), 0.5 + 1.0 / 480.0) and below_frame.get("unit", {}) == null and blocked_frame.get("spawned_unit", {}) == null and is_equal_approx(float(blocked_frame.get("build_progress", -1.0)), 0.999)

	var ready_frame: Dictionary = {"unit": live_unit, "readyness": 0.0}
	for iteration in range(60):
		var advanced: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state(ready_frame, 1.0, 1.0)
		ready_frame["readyness"] = advanced["readyness"]
	var unready_frame: Dictionary = {"unit": null, "readyness": 1.0}
	for iteration in range(60):
		var advanced: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state(unready_frame, 1.0, 1.0)
		unready_frame["readyness"] = advanced["readyness"]
	var lost_ready: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"unit": dead_unit, "readyness": 0.5}, 1.0, 1.0)
	var found_ready: Dictionary = unit_cargo_loader_build_state.source_unit_cargo_loader_update_tile_advance_state({"read_unit_id": 7, "readyness": 0.0}, 1.0, 1.0, live_unit)
	proof["readyness_folds_unit_presence"] = is_equal_approx(float(ready_frame.get("readyness", -1.0)), 1.0) and is_equal_approx(float(unready_frame.get("readyness", -1.0)), 0.0) and is_equal_approx(float(lost_ready.get("readyness", -1.0)), 0.5 - 1.0 / 60.0) and is_equal_approx(float(found_ready.get("readyness", -1.0)), 1.0 / 60.0)

	# --- Live tick: a unit-cargo-loader placed live; the tick
	# driver is called directly (as the N2165/N2211 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5, warmup
	# rises 1/60 toward 0.5, readyness stays 0 (no unit held),
	# build_progress rises 0.5/480 = 1/960 and total_progress
	# rises 0.5; nothing spawns (build_progress is far below
	# 1f), so the INVERTED gate stays open and the second tick
	# keeps consuming.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unit_cargo_loader_cell := Vector2i(28, 20)
	var unit_cargo_loader := Sprite2D.new()
	game.add_child(unit_cargo_loader)
	game.call("record_placed_block", unit_cargo_loader, blocks_by_id["unit-cargo-loader"], unit_cargo_loader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	unit_cargo_loader_build_state.source_unit_cargo_loader_bind_frame_state(unit_cargo_loader, blocks_by_id["unit-cargo-loader"])
	var unit_cargo_loader_frame: Dictionary = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})

	# A freshly bound frame carries the updateTile state keys
	# with the Java build-field defaults (UnitCargoLoader.java:
	# 86-89).
	var fresh_defaults: bool = unit_cargo_loader_frame.has("unit") and unit_cargo_loader_frame["unit"] == null and unit_cargo_loader_frame.has("read_unit_id") and int(unit_cargo_loader_frame["read_unit_id"]) == -1 and unit_cargo_loader_frame.has("build_progress") and is_equal_approx(float(unit_cargo_loader_frame["build_progress"]), 0.0) and unit_cargo_loader_frame.has("total_progress") and is_equal_approx(float(unit_cargo_loader_frame["total_progress"]), 0.0) and unit_cargo_loader_frame.has("warmup") and is_equal_approx(float(unit_cargo_loader_frame["warmup"]), 0.0) and unit_cargo_loader_frame.has("readyness") and is_equal_approx(float(unit_cargo_loader_frame["readyness"]), 0.0)

	unit_cargo_loader_frame["power_status"] = 0.5
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	unit_cargo_loader_frame = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var tick1_ok: bool = is_equal_approx(float(unit_cargo_loader_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(unit_cargo_loader_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(unit_cargo_loader_frame.get("readyness", -1.0)), 0.0) and is_equal_approx(float(unit_cargo_loader_frame.get("build_progress", -1.0)), 1.0 / 960.0) and is_equal_approx(float(unit_cargo_loader_frame.get("total_progress", -1.0)), 0.5) and unit_cargo_loader_frame.get("spawned_unit", {}) == null and unit_cargo_loader_frame.get("unit", {}) == null and int(unit_cargo_loader_frame.get("read_unit_id", -99)) == -1

	unit_cargo_loader_frame["power_status"] = 0.5
	unit_cargo_loader_build_state.source_unit_cargo_loader_tick_buildings_state(game, 1.0 / 60.0)
	unit_cargo_loader_frame = unit_cargo_loader.get_meta(unit_cargo_loader_build_state.SOURCE_UNIT_CARGO_LOADER_BUILDING_META_KEY, {})
	var tick2_ok: bool = is_equal_approx(float(unit_cargo_loader_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(unit_cargo_loader_frame.get("warmup", -1.0)), 2.0 / 60.0) and is_equal_approx(float(unit_cargo_loader_frame.get("readyness", -1.0)), 0.0) and is_equal_approx(float(unit_cargo_loader_frame.get("build_progress", -1.0)), 2.0 / 960.0) and is_equal_approx(float(unit_cargo_loader_frame.get("total_progress", -1.0)), 1.0) and unit_cargo_loader_frame.get("spawned_unit", {}) == null and unit_cargo_loader_frame.get("unit", {}) == null
	proof["live_tick_advances_cargo_frame"] = fresh_defaults and tick1_ok and tick2_ok

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitCargoLoaderUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
