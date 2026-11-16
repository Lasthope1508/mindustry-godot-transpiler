extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
const building_item_state := preload("res://src/game/SourceBuildingItemState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
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

	# --- The dump advance exposes its deliveries (N2369):
	# N2294 ported the dumpAccumulate dump
	# (MassDriver.java:163-166, `//dump when idle or
	# accepting` / `if(state == DriverState.idle || state ==
	# DriverState.accepting){ dumpAccumulate(); }`,
	# dumpAccumulate(null) accumulating `dumpAccum +=
	# delta();` and dumping while `dumpAccum >= 1f`
	# (BuildingComp.java:1053-1061) through dump() =
	# dump(null) (BuildingComp.java:1064-1066), the
	# neighbour-outer / item-inner scan (BuildingComp.
	# java:1072-1114)) -- but the dumped item left the mass
	# driver without landing in any neighbour store. Java
	# hands it over for real (`other.handleItem(self(),
	# item);`, BuildingComp.java:1089), and handleItem is
	# `items.add(item, 1);` (BuildingComp.java:860-862).
	# dumpAccumulate can dump MULTIPLE times per frame
	# ("May dump multiple times per frame",
	# BuildingComp.java:1052), so the advance returns
	# dump_deliveries -- one {"neighbour_index": ...,
	# "item": ...} dict per successful attempt, in attempt
	# order (empty when nothing dumped) -- and the tick
	# lands each one through the shared N2353 helper.
	# Index i is ring cell i (the N2353 convention): the
	# helper resolves the index through the
	# source_block_proximity_cells_state ring. Content
	# items here are ["copper", "lead"] in catalog order;
	# the dump takes the first held item in that order.
	var item_ids: Array = ["copper", "lead"]
	var one_accepting: Array = [true]
	var one_can_dump: Array = [true]

	# A single dump delivers one item to neighbour 0: the
	# accumulator fires once (0.0 + 1.0), copper 3 -> 2,
	# the cursor stays 0 over the single neighbour, and
	# the single delivery is {neighbour_index 0, copper}.
	var single_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var single: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(single_frame, "idle", 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var single_items: Dictionary = single.get("items_after", {})
	var single_deliveries: Array = single.get("dump_deliveries", [])
	var single_delivery: Dictionary = single_deliveries[0] if single_deliveries.size() == 1 else {}

	# A large delta dumps multiple times per frame: 0.0 +
	# 3.0 fires 3 attempts (copper 5 -> 2, remainder 0.0)
	# and delivers 3 coppers, all to neighbour 0 -- a
	# scalar routed index would have dropped two of them.
	var multi_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var multi: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(multi_frame, "idle", 3.0, 1.0, item_ids, one_accepting, one_can_dump)
	var multi_items: Dictionary = multi.get("items_after", {})
	var multi_deliveries: Array = multi.get("dump_deliveries", [])
	var multi_all_copper_to_zero := multi_deliveries.size() == 3
	for delivery in multi_deliveries:
		var entry: Dictionary = delivery
		multi_all_copper_to_zero = multi_all_copper_to_zero and int(entry.get("neighbour_index", -9)) == 0 and str(entry.get("item", "")) == "copper"

	# The second neighbour takes the delivery when the
	# first rejects: accepts [false, true] routes to
	# index 1 (the cursor wraps back to 0 after the
	# two-neighbour scan) and copper 3 -> 2.
	var second_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var second: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(second_frame, "idle", 1.0, 1.0, item_ids, [false, true], [true, true])
	var second_items: Dictionary = second.get("items_after", {})
	var second_deliveries: Array = second.get("dump_deliveries", [])
	var second_delivery: Dictionary = second_deliveries[0] if second_deliveries.size() == 1 else {}

	# No dump means no deliveries: shooting (the gate is
	# closed, so the accumulator does NOT grow -- 0.0
	# stays 0.0 -- and the store is untouched), a
	# rejecting neighbour (1 attempt, dumped false, the
	# store untouched, the accumulator spends its 1f),
	# and an empty store (1 attempt, dumped false, the
	# accumulator still spends its 1f, the cursor stays).
	var shooting_frame: Dictionary = {"items": {"copper": 5}, "dump_accum": 0.0, "cdump": 0}
	var shooting: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(shooting_frame, "shooting", 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	var shooting_items: Dictionary = shooting.get("items_after", {})
	var rejected_frame: Dictionary = {"items": {"copper": 3}, "dump_accum": 0.0, "cdump": 0}
	var rejected: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(rejected_frame, "idle", 1.0, 1.0, item_ids, [false], one_can_dump)
	var rejected_items: Dictionary = rejected.get("items_after", {})
	var empty_frame: Dictionary = {"items": {}, "dump_accum": 0.0, "cdump": 0}
	var empty: Dictionary = mass_driver_build_state.source_mass_driver_dump_state(empty_frame, "idle", 1.0, 1.0, item_ids, one_accepting, one_can_dump)
	proof["advance_exposes_dump_deliveries"] = bool(single.get("dumped", false)) and int(single_items.get("copper", -1)) == 2 and is_equal_approx(float(single.get("dump_accum_after", -1.0)), 0.0) and int(single.get("cursor_after", -1)) == 0 and single_deliveries.size() == 1 and int(single_delivery.get("neighbour_index", -9)) == 0 and str(single_delivery.get("item", "")) == "copper" and bool(multi.get("dumped", false)) and int(multi_items.get("copper", -1)) == 2 and is_equal_approx(float(multi.get("dump_accum_after", -1.0)), 0.0) and multi_all_copper_to_zero and bool(second.get("dumped", false)) and int(second_items.get("copper", -1)) == 2 and int(second.get("cursor_after", -1)) == 0 and second_deliveries.size() == 1 and int(second_delivery.get("neighbour_index", -9)) == 1 and str(second_delivery.get("item", "")) == "copper" and not bool(shooting.get("dumped", true)) and is_equal_approx(float(shooting.get("dump_accum_after", -1.0)), 0.0) and int(shooting_items.get("copper", -1)) == 5 and int(shooting.get("cursor_after", -1)) == 0 and (shooting.get("dump_deliveries", [1]) as Array).is_empty() and not bool(rejected.get("dumped", true)) and int(rejected_items.get("copper", -1)) == 3 and is_equal_approx(float(rejected.get("dump_accum_after", -1.0)), 0.0) and (rejected.get("dump_deliveries", [1]) as Array).is_empty() and not bool(empty.get("dumped", true)) and is_equal_approx(float(empty.get("dump_accum_after", -1.0)), 0.0) and int(empty.get("cursor_after", -1)) == 0 and (empty.get("dump_deliveries", [1]) as Array).is_empty()

	# --- Live tick: two unpowered mass drivers dump in
	# one tick (the N2294 live setup: link -1, no waiting
	# shooter, power_status 0.0 -- the dump runs even
	# without power, the gate sits before the no-power
	# skip, MassDriver.java:164-166 before :168-171).
	# The first dumps to ring 0 -- the phase-conveyor at
	# (26, 20) -- and the copper lands in its frame items
	# (+1). The second dumps to ring 0 -- a copper wall
	# with no store -- and the copper still leaves the
	# driver (3 -> 2), dropping with reason no_frame.
	# The size-3 ring is angle-sorted: ring 0 is offset
	# (-2, -1) from the origin cell. The neighbour is a
	# size-1 phase-conveyor (its frame carries an items
	# store, the N2362 precedent) -- a size-3 mass-driver
	# neighbour centred on a ring cell would overlap the
	# source footprint.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var mass_driver_cell := Vector2i(28, 21)
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["phase-conveyor"], live_neighbour_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(live_neighbour, blocks_by_id["phase-conveyor"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	mass_driver_frame["power_status"] = 0.0
	mass_driver_frame["items"] = {"copper": 5}
	mass_driver_frame["dump_accum"] = 0.0
	mass_driver_frame["dump_neighbour_accepts"] = [true]
	mass_driver_frame["dump_neighbour_can_dump"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(3, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_driver_cell := Vector2i(50, 30)
	var bare_driver := Sprite2D.new()
	game.add_child(bare_driver)
	game.call("record_placed_block", bare_driver, blocks_by_id["mass-driver"], bare_driver_cell)
	mass_driver_build_state.source_mass_driver_bind_frame_state(bare_driver, blocks_by_id["mass-driver"])
	var bare_frame: Dictionary = bare_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 0.0
	bare_frame["items"] = {"copper": 3}
	bare_frame["dump_accum"] = 0.0
	bare_frame["dump_neighbour_accepts"] = [true]
	bare_frame["dump_neighbour_can_dump"] = [true]

	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	mass_driver_frame = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	bare_frame = bare_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var live_items: Dictionary = mass_driver_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(26, 20) and is_equal_approx(float(mass_driver_frame.get("efficiency", -1.0)), 0.0) and str(mass_driver_frame.get("state", "")) == "idle" and is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.0) and int(live_items.get("copper", -1)) == 4 and is_equal_approx(float(mass_driver_frame.get("dump_accum", -1.0)), 0.0) and int(mass_driver_frame.get("cdump", -1)) == 0 and int(live_neighbour_items.get("copper", -1)) == 1
	proof["live_tick_dumped_item_leaves_driver_without_frame"] = bare_cell == Vector2i(48, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.0) and str(bare_frame.get("state", "")) == "idle" and is_equal_approx(float(bare_frame.get("reload_counter", -1.0)), 0.0) and int(bare_items.get("copper", -1)) == 2 and is_equal_approx(float(bare_frame.get("dump_accum", -1.0)), 0.0) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
