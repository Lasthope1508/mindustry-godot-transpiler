extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_module(amounts: Array, current: int) -> Dictionary:
	return {"liquids": amounts, "current": current, "flow": null}


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
	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	# The liquid names by id (the tick builds this the same
	# way -- catalog.get_many("liquid") in catalog order,
	# index == id).
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(liquid.id)
	var item_order: Array = content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])

	# --- The dump neighbour live fill (N2394, DEFERRED #248):
	# N2293 ported the dump rows (dumpLiquid(current) 2f +
	# offloadSpeed x dumpAccumulate() at the end of
	# updateTile, PayloadUnloader.java:105-108) -- but the
	# six neighbour arrays stayed frame inputs (default []),
	# so a live unloader with no fill read an empty
	# proximity and never dumped. N2380/N2386 wired the
	# neighbour write-backs (the N2371 liquid + N2353 item
	# helpers) -- but with no fill the routing never ran.
	# This slice fills the six arrays from the live
	# proximity BEFORE the dump pure, in ring order (index
	# i is ring cell i, the N2353 convention): liquid
	# amounts + capacities from the neighbour frames,
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptItem REQUIRES consumesItem, :864-866;
	# acceptLiquid is hasLiquids && consumesLiquid,
	# :868-870; both canDump defaults are true, :910-912 /
	# :1124-1126). Per-block overrides are OUT of scope.
	# The item gate answers for the FIRST held item in
	# content order -- the item the dump pure offers.
	# A neighbour with no frame reports the no-frame
	# outcome (0.0 / 0.0 / false / false / false / false).
	# The size-3 ring has 12 cells (angle-sorted): ring 0
	# is the (-2, -1) offset, so the (28, 20) unloader's
	# ring 0 is (26, 19) and its ring 5 is (30, 20). The
	# neighbours here are a size-1 melter at ring 0
	# (consumes scrap, itemCapacity 10, no liquid -- the
	# catalog carries its consumeItem row) and a size-2
	# multi-press at ring 5 (consumes coal + water,
	# hasLiquids true, liquidCapacity 60f, itemCapacity 20
	# -- the catalog carries both rows). The multi-press
	# footprint (30..31, 20..21) also covers ring 6
	# (30, 21), so the ring reports it at BOTH indices 5
	# and 6 (Java updateProximity dedupes multi-cell
	# neighbours, but the ring convention this fill mirrors
	# does not -- a delivery to either index lands in the
	# same frame). A copper wall at ring 11 (26, 20) is the
	# frameless neighbour; the other ring cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var unloader_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var press_cell: Vector2i = ring[5]
	var wall_cell: Vector2i = ring[11]
	var unloader := Sprite2D.new()
	game.add_child(unloader)
	game.call("record_placed_block", unloader, blocks_by_id["payload-unloader"], unloader_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(unloader, true, game.get("content_catalog"))
	var unloader_liquids: Dictionary = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(unloader_liquids, water_id, 50.0)
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
	press_frame["liquids"] = press.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var press_liquids: Dictionary = press_frame.get("liquids", {})
	liquid_module_state.source_set_state(press_liquids, water_id, 5.0)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The liquid arrays fill from the live neighbour frames:
	# the unloader's current is water (50.0), the
	# multi-press holds 5.0 water at capacity 60f and
	# consumes water with hasLiquids true -- so it reports
	# 5.0 / 60.0 / accepts true / canDump true at BOTH of
	# its ring indices (5 and 6). The melter has no liquids
	# store, so it reports 0.0 / 0.0 / accepts false -- but
	# canDump true, because it HAS a frame (the canDump
	# default is unconditional). All six arrays are 12 long
	# (the size-3 ring).
	var liquid_frame: Dictionary = {"items": {}, "liquids": _liquid_module([50.0], water_id), "liquid_names_by_id": liquid_names_by_id}
	var liquid_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, liquid_frame, item_order)
	var fill_amounts: Array = liquid_fill.get("dump_neighbour_liquid_amounts", [])
	var fill_capacities: Array = liquid_fill.get("dump_neighbour_liquid_capacities", [])
	var fill_accepts_liquid: Array = liquid_fill.get("dump_neighbour_accepts_liquid", [])
	var fill_can_dump_liquid: Array = liquid_fill.get("dump_neighbour_can_dump_liquid", [])
	var fill_accepts_item: Array = liquid_fill.get("dump_neighbour_accepts_item", [])
	var fill_can_dump_item: Array = liquid_fill.get("dump_neighbour_can_dump_item", [])
	proof["fill_liquid_arrays_from_live_neighbour"] = ring.size() == 12 and melter_cell == Vector2i(26, 19) and press_cell == Vector2i(30, 20) and wall_cell == Vector2i(26, 20) and fill_amounts.size() == 12 and fill_capacities.size() == 12 and fill_accepts_liquid.size() == 12 and fill_can_dump_liquid.size() == 12 and fill_accepts_item.size() == 12 and fill_can_dump_item.size() == 12 and is_equal_approx(float(fill_amounts[5]), 5.0) and is_equal_approx(float(fill_amounts[6]), 5.0) and is_equal_approx(float(fill_capacities[5]), 60.0) and is_equal_approx(float(fill_capacities[6]), 60.0) and bool(fill_accepts_liquid[5]) and bool(fill_accepts_liquid[6]) and bool(fill_can_dump_liquid[5]) and bool(fill_can_dump_liquid[6]) and is_equal_approx(float(fill_amounts[0]), 0.0) and is_equal_approx(float(fill_capacities[0]), 0.0) and not bool(fill_accepts_liquid[0]) and bool(fill_can_dump_liquid[0])

	# The item arrays fill from the live neighbour frames:
	# the unloader holds coal only, so the offered item is
	# coal -- the multi-press consumes coal with room
	# (0 < 20), so it accepts at both indices 5 and 6, and
	# the melter (which consumes scrap, not coal) rejects.
	var coal_frame: Dictionary = {"items": {"coal": 3}, "liquids": {}, "liquid_names_by_id": liquid_names_by_id}
	var coal_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, coal_frame, item_order)
	var coal_accepts_item: Array = coal_fill.get("dump_neighbour_accepts_item", [])
	var coal_can_dump_item: Array = coal_fill.get("dump_neighbour_can_dump_item", [])
	proof["fill_item_arrays_from_live_neighbour"] = bool(coal_accepts_item[5]) and bool(coal_accepts_item[6]) and bool(coal_can_dump_item[5]) and bool(coal_can_dump_item[6]) and not bool(coal_accepts_item[0]) and bool(coal_can_dump_item[0])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}, "liquids": {}, "liquid_names_by_id": liquid_names_by_id}
	var copper_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, copper_frame, item_order)
	var copper_accepts_item: Array = copper_fill.get("dump_neighbour_accepts_item", [])
	var scrap_frame: Dictionary = {"items": {"scrap": 3}, "liquids": {}, "liquid_names_by_id": liquid_names_by_id}
	var scrap_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, scrap_frame, item_order)
	var scrap_accepts_item: Array = scrap_fill.get("dump_neighbour_accepts_item", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts_item[0]) and not bool(copper_accepts_item[5]) and bool(scrap_accepts_item[0]) and not bool(scrap_accepts_item[5])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, scrap_frame, item_order)
	var full_accepts_item: Array = full_fill.get("dump_neighbour_accepts_item", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_neighbour_live_fill_state(game, unloader_cell, 3, scrap_frame, item_order)
	var room_accepts_item: Array = room_fill.get("dump_neighbour_accepts_item", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts_item[0]) and bool(room_accepts_item[0])

	# The no-frame outcome: the copper wall at ring 11 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 1) report 0.0 / 0.0 /
	# false / false / false / false -- nothing routes
	# there (the N2353/N2371 no-frame precedent).
	var wall_amounts: Array = coal_fill.get("dump_neighbour_liquid_amounts", [])
	var wall_capacities: Array = coal_fill.get("dump_neighbour_liquid_capacities", [])
	var wall_accepts_liquid: Array = coal_fill.get("dump_neighbour_accepts_liquid", [])
	var wall_can_dump_liquid: Array = coal_fill.get("dump_neighbour_can_dump_liquid", [])
	var wall_accepts_item: Array = coal_fill.get("dump_neighbour_accepts_item", [])
	var wall_can_dump_item: Array = coal_fill.get("dump_neighbour_can_dump_item", [])
	proof["fill_no_frame_neighbour_reports_empty"] = is_equal_approx(float(wall_amounts[11]), 0.0) and is_equal_approx(float(wall_capacities[11]), 0.0) and not bool(wall_accepts_liquid[11]) and not bool(wall_can_dump_liquid[11]) and not bool(wall_accepts_item[11]) and not bool(wall_can_dump_item[11]) and is_equal_approx(float(wall_amounts[1]), 0.0) and is_equal_approx(float(wall_capacities[1]), 0.0) and not bool(wall_accepts_liquid[1]) and not bool(wall_can_dump_liquid[1]) and not bool(wall_accepts_item[1]) and not bool(wall_can_dump_item[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the payload-unloader placed live with
	# NO payload (the N2293 live setup: the shouldConsume
	# gate is false, so efficiency folds to 0.0 -- and the
	# dump STILL runs, because the dump rows are
	# unconditional, PayloadUnloader.java:105-108) and NO
	# seeded dump arrays -- the tick fills them live. The
	# unloader holds 5 coal + 50 water; the multi-press
	# water is reset to 0.0 first so the liquid transfer is
	# exact. The liquid phase transfers 25.0 to ring 5
	# ((0.5 - 0) * 100 / 2) then 12.5 to ring 6 ((0.25 - 0)
	# * 100 / 2, the fraction recomputes from the running
	# amount) -- 37.5 total, all landing in the press frame
	# through the N2371 helper (the first handled index
	# takes the total, the N2380 precedent). The item phase
	# dumps 4 coal (dump_accum 0.9 + 4 * 1.0, one attempt
	# per call) to the press at ring 5, then 6, then 5,
	# then 6 (the cursor walks: 0 -> 6 -> 7 -> 6 -> 7) --
	# all 4 land in the press frame through the N2353
	# helper. The melter takes nothing (it rejects coal).
	# The frame keeps the live-filled arrays and the
	# dump_neighbour_live flag.
	liquid_module_state.source_set_state(press_liquids, water_id, 0.0)
	unloader_frame["power_status"] = 1.0
	unloader_frame["items"] = {"coal": 5}
	unloader_frame["dump_accum"] = 0.9

	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	unloader_liquids = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	press_liquids = press_frame.get("liquids", {})
	var live_items: Dictionary = unloader_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_water: float = float(liquid_module_state.source_get_state(unloader_liquids, water_id).get("amount", -1.0))
	var press_water: float = float(liquid_module_state.source_get_state(press_liquids, water_id).get("amount", -1.0))
	var live_accepts_item: Array = unloader_frame.get("dump_neighbour_accepts_item", [])
	var live_capacities: Array = unloader_frame.get("dump_neighbour_liquid_capacities", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0) and int(live_items.get("coal", -1)) == 1 and int(unloader_frame.get("dumped_items", -1)) == 4 and int(press_items.get("coal", -1)) == 4 and int(melter_items.get("coal", 0)) == 0 and is_equal_approx(float(unloader_frame.get("dumped_liquid", -1.0)), 37.5) and is_equal_approx(live_water, 12.5) and is_equal_approx(press_water, 37.5) and int(unloader_frame.get("cdump", -1)) == 7 and is_equal_approx(float(unloader_frame.get("dump_accum", -1.0)), 0.9) and bool(unloader_frame.get("dump_neighbour_live", false)) and bool(live_accepts_item[5]) and not bool(live_accepts_item[0]) and is_equal_approx(float(live_capacities[5]), 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
