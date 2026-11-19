extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	# --- Pure dump (N2294): the dumpAccumulate dump
	# (MassDriver.java:163-166, `//dump when idle or
	# accepting` / `if(state == DriverState.idle || state ==
	# DriverState.accepting){ dumpAccumulate(); }`) -- between
	# the state switch (:154-161) and the no-power skip
	# (`if(efficiency <= 0f){`, :168-171), so it runs even with
	# no power. dumpAccumulate() delegates to
	# dumpAccumulate(null) (BuildingComp.java:1048-1050),
	# which accumulates `dumpAccum += delta();` and dumps
	# while `dumpAccum >= 1f` (BuildingComp.java:1053-1061)
	# -- possibly MULTIPLE times per tick -- through dump() =
	# dump(null) (BuildingComp.java:1064-1066): neighbours
	# outer, content items inner -- for each neighbour from
	# the cdump cursor, the first held item in content order
	# an accepting neighbour takes is handed over, 1 leaves
	# the store, and the cursor advances once per neighbour
	# checked (incrementDump, BuildingComp.java:1116-1120,
	# guarded on prox != 0). dumpAccumulate() is only CALLED
	# while idle or accepting, so the accumulator does NOT
	# grow while shooting. delta() is `Time.delta * timeScale`
	# (BuildingComp.java:1922-1924), so the accumulator grows
	# by source_delta * time_scale. The pure gates on the
	# post-switch state (state_after_switch, returned by the
	# N2237 advance -- NOT the final state, which the
	# accepting/shooting branches may flip back to idle). The
	# content item order here is [copper, lead], the catalog
	# order Java iterates (content.items()).
	var content_item_ids: Array = ["copper", "lead"]
	var accepting: Array = [true]
	var can_dump: Array = [true]

	# Fires when idle: accum 0 + 1 hits the threshold, one
	# copper leaves the store (5 -> 4) to the accepting
	# neighbour, the accumulator resets to 0.0, and the cursor
	# stays 0 over the single-neighbour proximity ((0 + 1) %
	# 1 == 0). A 2.5-tick delta fires TWICE (the while loop):
	# copper 5 -> 3 and the accumulator keeps the 0.5
	# remainder. Below the threshold (0 + 0.5) nothing dumps
	# and the accumulator keeps growing. At time_scale 2.0 a
	# 0.5-tick delta is a full 1.0 of delta(), so it fires.
	var idle_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var idle: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(idle_frame, "idle", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var idle_items: Dictionary = idle.get("items_after", {})
	var multi: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 2.5, 1.0, content_item_ids, accepting, can_dump)
	var multi_items: Dictionary = multi.get("items_after", {})
	var below: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 0.5, 1.0, content_item_ids, accepting, can_dump)
	var below_items: Dictionary = below.get("items_after", {})
	var overdrive: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 0.5, 2.0, content_item_ids, accepting, can_dump)
	var overdrive_items: Dictionary = overdrive.get("items_after", {})
	proof["dump_fires_when_idle"] = bool(idle.get("dumped", false)) and int(idle_items.get("copper", -1)) == 4 and is_equal_approx(float(idle.get("dump_accum_after", -1.0)), 0.0) and int(idle.get("cursor_after", -1)) == 0 and bool(multi.get("dumped", false)) and int(multi_items.get("copper", -1)) == 3 and is_equal_approx(float(multi.get("dump_accum_after", -1.0)), 0.5) and bool(below.get("dumped", true)) == false and is_equal_approx(float(below.get("dump_accum_after", -1.0)), 0.5) and int(below_items.get("copper", -1)) == 5 and int(below.get("cursor_after", -1)) == 0 and bool(overdrive.get("dumped", false)) and int(overdrive_items.get("copper", -1)) == 4 and is_equal_approx(float(overdrive.get("dump_accum_after", -1.0)), 0.0)

	# Fires when accepting: the same tick dumps one copper
	# (5 -> 4) with the accumulator resetting to 0.0. A
	# pre-existing accumulator carries over: 0.9 + 0.5 = 1.4
	# fires once and keeps the 0.4 remainder.
	var accepting_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var accepted: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(accepting_frame, "accepting", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var accepted_items: Dictionary = accepted.get("items_after", {})
	var carried: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.9, "cdump": 0}, "accepting", 0.5, 1.0, content_item_ids, accepting, can_dump)
	var carried_items: Dictionary = carried.get("items_after", {})
	proof["dump_fires_when_accepting"] = bool(accepted.get("dumped", false)) and int(accepted_items.get("copper", -1)) == 4 and is_equal_approx(float(accepted.get("dump_accum_after", -1.0)), 0.0) and int(accepted.get("cursor_after", -1)) == 0 and bool(carried.get("dumped", false)) and int(carried_items.get("copper", -1)) == 4 and is_equal_approx(float(carried.get("dump_accum_after", -1.0)), 0.4)

	# Blocked when shooting: dumpAccumulate() is never called
	# there (MassDriver.java:164-166), so the accumulator does
	# NOT grow -- a full 1.0-tick delta leaves it at 0.0, and
	# a pre-existing 0.9 stays 0.9. Nothing dumps, the store
	# is untouched, and the cursor does not move.
	var shooting: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "shooting", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var shooting_items: Dictionary = shooting.get("items_after", {})
	var shooting_held: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.9, "cdump": 0}, "shooting", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var shooting_held_items: Dictionary = shooting_held.get("items_after", {})
	proof["dump_blocked_when_shooting"] = bool(shooting.get("dumped", true)) == false and is_equal_approx(float(shooting.get("dump_accum_after", -1.0)), 0.0) and int(shooting_items.get("copper", -1)) == 5 and int(shooting.get("cursor_after", -1)) == 0 and bool(shooting_held.get("dumped", true)) == false and is_equal_approx(float(shooting_held.get("dump_accum_after", -1.0)), 0.9) and int(shooting_held_items.get("copper", -1)) == 5 and int(shooting_held.get("cursor_after", -1)) == 0

	# Runs without power: the dump sits BEFORE the efficiency
	# check (MassDriver.java:164-166 before :168-171), so the
	# pure takes no efficiency input at all -- a frame stamped
	# efficiency 0.0 still dumps when idle (5 -> 4) and when
	# accepting, with the accumulator resetting to 0.0. The
	# gate is the state, not the power: a shooting driver at
	# efficiency 1.0 still does not dump (see the key above).
	var unpowered_idle: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"efficiency": 0.0, "items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var unpowered_idle_items: Dictionary = unpowered_idle.get("items_after", {})
	var unpowered_accepting: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"efficiency": 0.0, "items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "accepting", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var unpowered_accepting_items: Dictionary = unpowered_accepting.get("items_after", {})
	proof["dump_runs_without_power"] = bool(unpowered_idle.get("dumped", false)) and int(unpowered_idle_items.get("copper", -1)) == 4 and is_equal_approx(float(unpowered_idle.get("dump_accum_after", -1.0)), 0.0) and bool(unpowered_accepting.get("dumped", false)) and int(unpowered_accepting_items.get("copper", -1)) == 4 and is_equal_approx(float(unpowered_accepting.get("dump_accum_after", -1.0)), 0.0)

	# Removes from the store: the dump takes the first held
	# item in CONTENT order, so with copper and lead held it
	# drains copper 5 -> 4 and leaves lead at 2. Cursor
	# advances: with 3 neighbours where only neighbour 1
	# accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2). A
	# neighbour that refuses takes nothing: the attempt still
	# consumes its 1f of accumulator (Java calls dump() inside
	# the while loop whether or not it succeeds), so the
	# accumulator resets to 0.0 and the store is untouched; a
	# neighbour that accepts but canDump-blocks takes nothing
	# the same way. Empty store: the dump guards on the empty
	# store and dumps nothing -- the accumulator is still
	# consumed (0.0) but the cursor stays 2 (the guard returns
	# before any neighbour is checked). No neighbours at all
	# (the default [] frame inputs): the proximity guard
	# blocks the dump, the store and the cursor are untouched,
	# and the accumulator is still consumed.
	var store_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "dump_accum": 0.0, "cdump": 0}
	var stored: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(store_frame, "idle", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var stored_items: Dictionary = stored.get("items_after", {})
	var cursor_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var cursor: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(cursor_frame, "idle", 1.0, 1.0, content_item_ids, [false, true, false], [true, true, true])
	var cursor_items: Dictionary = cursor.get("items_after", {})
	var refused: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 1.0, 1.0, content_item_ids, [false], [true])
	var refused_items: Dictionary = refused.get("items_after", {})
	var blocked: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}, "idle", 1.0, 1.0, content_item_ids, [true], [false])
	var blocked_items: Dictionary = blocked.get("items_after", {})
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.0, "cdump": 2}
	var emptied: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(empty_frame, "idle", 1.0, 1.0, content_item_ids, accepting, can_dump)
	var no_neighbour: Dictionary = mass_driver_build_state.source_mass_driver_dump_state({"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 2}, "idle", 1.0, 1.0, content_item_ids, [], [])
	var no_neighbour_items: Dictionary = no_neighbour.get("items_after", {})
	proof["dump_removes_item_from_store"] = bool(stored.get("dumped", false)) and int(stored_items.get("copper", -1)) == 4 and int(stored_items.get("lead", -1)) == 2 and bool(cursor.get("dumped", false)) and int(cursor_items.get("copper", -1)) == 4 and int(cursor.get("cursor_after", -1)) == 2 and bool(refused.get("dumped", true)) == false and int(refused_items.get("copper", -1)) == 5 and is_equal_approx(float(refused.get("dump_accum_after", -1.0)), 0.0) and int(refused.get("cursor_after", -1)) == 0 and bool(blocked.get("dumped", true)) == false and int(blocked_items.get("copper", -1)) == 5 and is_equal_approx(float(blocked.get("dump_accum_after", -1.0)), 0.0) and bool(emptied.get("dumped", true)) == false and is_equal_approx(float(emptied.get("dump_accum_after", -1.0)), 0.0) and int(emptied.get("cursor_after", -1)) == 2 and bool(no_neighbour.get("dumped", true)) == false and int(no_neighbour_items.get("copper", -1)) == 5 and is_equal_approx(float(no_neighbour.get("dump_accum_after", -1.0)), 0.0) and int(no_neighbour.get("cursor_after", -1)) == 2

	# --- Live tick: the mass driver is a MassDriver build with a
	# power consumer (consumePower 1.75f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/
	# N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/N2237
	# proofs do), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. NO power: efficiency
	# folds 0.0, the advance keeps the driver idle (no waiting
	# shooter, no link) with the reload counter at 0.0 -- and
	# the dump STILL runs (the gate sits before the no-power
	# skip, MassDriver.java:164-166 before :168-171): one
	# 1/60s tick is one source tick, so the accumulator grows
	# 0 + 1 = 1, one copper leaves the store (5 -> 4) to the
	# first accepting neighbour, the cursor advances 0 -> 1
	# over the two neighbours, and the accumulator resets to
	# 0.0. The neighbour arrays are frame inputs (default []),
	# stamped here like the N2228 targets precedent.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var mass_driver_cell := Vector2i(28, 21)
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the dump inputs on it).
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	mass_driver_frame["items"] = {"copper": 5}
	mass_driver_frame["dump_accum"] = 0.0
	mass_driver_frame["dump_neighbour_accepts"] = [true, true]
	mass_driver_frame["dump_neighbour_can_dump"] = [true, true]
	mass_driver_frame["power_status"] = 0.0
	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	mass_driver_frame = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_items: Dictionary = mass_driver_frame.get("items", {})
	proof["live_tick_dumps_item"] = is_equal_approx(float(mass_driver_frame.get("efficiency", -1.0)), 0.0) and str(mass_driver_frame.get("state", "")) == "idle" and is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.0) and int(live_items.get("copper", -1)) == 4 and int(mass_driver_frame.get("cdump", -1)) == 1 and is_equal_approx(float(mass_driver_frame.get("dump_accum", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
