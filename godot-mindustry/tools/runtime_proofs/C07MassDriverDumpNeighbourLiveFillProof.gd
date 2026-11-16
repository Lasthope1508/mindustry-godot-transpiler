extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var item_order: Array = content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])

	# --- The dump neighbour live fill (N2406, DEFERRED #247):
	# N2294 ported the dump rows (dumpAccumulate() between
	# the state switch and the no-power skip,
	# MassDriver.java:163-166) -- but the two neighbour
	# arrays stayed frame inputs (default []), so a live
	# mass driver with no fill read an empty proximity and
	# never dumped. N2369 wired the neighbour write-back
	# (the N2353 item helper) -- but with no fill the
	# routing never ran. This slice fills the two arrays
	# from the live proximity BEFORE the dump pure, in ring
	# order (index i is ring cell i, the N2353 convention):
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptItem REQUIRES consumesItem, :864-866; the
	# canDump default is true, :1124-1126). Per-block
	# overrides are OUT of scope. The gate answers for the
	# FIRST held item in content order -- the item the dump
	# pure offers. A neighbour with no frame reports the
	# no-frame outcome (false / false).
	# The size-3 ring has 12 cells (angle-sorted): ring 0
	# is the (-2, -1) offset, so the (28, 20) mass driver's
	# ring 0 is (26, 19), ring 4 is (30, 19), ring 5 is
	# (30, 20), ring 6 is (30, 21), and ring 11 is
	# (26, 20). The neighbours here are a size-1 melter at
	# ring 0 (consumes scrap, itemCapacity 10 -- the
	# catalog carries its consumeItem row) and a size-3
	# multi-press CENTRED at (31, 20) (consumes coal,
	# itemCapacity 20 -- the catalog carries its row): its
	# footprint (30..32, 19..21) covers ring 4, 5 AND 6, so
	# the ring reports it at all three indices (Java
	# updateProximity dedupes multi-cell neighbours, but
	# the ring convention this fill mirrors does not -- a
	# delivery to any index lands in the same frame).
	# Centring the press at (31, 20) keeps its footprint
	# adjacent to, not overlapping, the mass driver's own
	# (27..29, 19..21) -- a size-3 neighbour centred ON a
	# ring cell would overlap the origin (the N2369 note).
	# A copper wall at ring 11 (26, 20) is the frameless
	# neighbour; the other ring cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var mass_driver_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var press_cell := Vector2i(31, 20)
	var wall_cell: Vector2i = ring[11]
	var mass_driver := Sprite2D.new()
	game.add_child(mass_driver)
	game.call("record_placed_block", mass_driver, blocks_by_id["mass-driver"], mass_driver_cell)
	mass_driver_build_state.source_mass_driver_bind_frame_state(mass_driver, blocks_by_id["mass-driver"])
	var mass_driver_frame: Dictionary = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var melter_frame: Dictionary = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame["items"] = {}
	var press := Sprite2D.new()
	game.add_child(press)
	game.call("record_placed_block", press, blocks_by_id["multi-press"], press_cell)
	factory_build_state.source_factory_bind_frame_state(press, blocks_by_id["multi-press"])
	var press_frame: Dictionary = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame["items"] = {}
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The accepts array fills from the live neighbour
	# frames: the driver holds coal only, so the offered
	# item is coal -- the multi-press consumes coal with
	# room (0 < 20), so it accepts at all three of its ring
	# indices (4, 5 and 6), and the melter (which consumes
	# scrap, not coal) rejects. Both arrays are 12 long
	# (the size-3 ring).
	var coal_frame: Dictionary = {"items": {"coal": 3}}
	var coal_fill: Dictionary = mass_driver_build_state.source_mass_driver_dump_neighbour_live_fill_state(game, mass_driver_cell, 3, coal_frame, item_order)
	var coal_accepts: Array = coal_fill.get("dump_neighbour_accepts", [])
	var coal_can_dump: Array = coal_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbour"] = ring.size() == 12 and melter_cell == Vector2i(26, 19) and ring[4] == Vector2i(30, 19) and ring[5] == Vector2i(30, 20) and ring[6] == Vector2i(30, 21) and wall_cell == Vector2i(26, 20) and coal_accepts.size() == 12 and coal_can_dump.size() == 12 and bool(coal_accepts[4]) and bool(coal_accepts[5]) and bool(coal_accepts[6]) and not bool(coal_accepts[0])

	# The canDump array fills from the live neighbour
	# frames: every FRAMED neighbour reports true (the
	# Java default is unconditional) -- the melter at ring
	# 0 and the press at 4, 5 and 6 -- while the frameless
	# copper wall at ring 11 and the empty ring cells
	# (e.g. index 1) report false.
	proof["fill_can_dump_from_live_neighbour"] = bool(coal_can_dump[0]) and bool(coal_can_dump[4]) and bool(coal_can_dump[5]) and bool(coal_can_dump[6]) and not bool(coal_can_dump[11]) and not bool(coal_can_dump[1])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = mass_driver_build_state.source_mass_driver_dump_neighbour_live_fill_state(game, mass_driver_cell, 3, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = mass_driver_build_state.source_mass_driver_dump_neighbour_live_fill_state(game, mass_driver_cell, 3, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and not bool(copper_accepts[5]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[5])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = mass_driver_build_state.source_mass_driver_dump_neighbour_live_fill_state(game, mass_driver_cell, 3, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = mass_driver_build_state.source_mass_driver_dump_neighbour_live_fill_state(game, mass_driver_cell, 3, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 11 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 1) report false / false --
	# nothing routes there (the N2353 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(coal_accepts[11]) and not bool(coal_can_dump[11]) and not bool(coal_accepts[1]) and not bool(coal_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the mass driver placed live with NO
	# power (the N2294 live setup: efficiency folds 0.0 --
	# and the dump STILL runs, because the dump gate sits
	# before the no-power skip, MassDriver.java:164-166
	# before :168-171) and NO seeded dump arrays -- the
	# tick fills them live. The driver holds 5 coal with
	# dump_accum 0.9 and cdump 0; one 1/60s tick is one
	# source tick, so the accumulator grows 0.9 + 1 = 1.9:
	# one dump attempt, remainder 0.9. The attempt checks
	# neighbours from the cursor: ring 0 (the melter
	# rejects coal), 1, 2, 3 (empty), then ring 4 (the
	# press accepts coal) -- 1 coal leaves the store (5 ->
	# 4) and lands in the press frame through the N2353
	# helper, and the cursor advances once per neighbour
	# checked (0 -> 5). The melter takes nothing. The frame
	# keeps the live-filled arrays and the
	# dump_neighbour_live flag.
	mass_driver_frame["power_status"] = 0.0
	mass_driver_frame["items"] = {"coal": 5}
	mass_driver_frame["dump_accum"] = 0.9

	mass_driver_build_state.source_mass_driver_tick_buildings_state(game, 1.0 / 60.0)
	mass_driver_frame = mass_driver.get_meta(mass_driver_build_state.SOURCE_MASS_DRIVER_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = mass_driver_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = mass_driver_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = mass_driver_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(mass_driver_frame.get("efficiency", -1.0)), 0.0) and str(mass_driver_frame.get("state", "")) == "idle" and is_equal_approx(float(mass_driver_frame.get("reload_counter", -1.0)), 0.0) and int(live_items.get("coal", -1)) == 4 and int(press_items.get("coal", -1)) == 1 and int(melter_items.get("coal", 0)) == 0 and int(mass_driver_frame.get("cdump", -1)) == 5 and is_equal_approx(float(mass_driver_frame.get("dump_accum", -1.0)), 0.9) and bool(mass_driver_frame.get("dump_neighbour_live", false)) and bool(live_accepts[4]) and not bool(live_accepts[0]) and bool(live_can_dump[0])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
