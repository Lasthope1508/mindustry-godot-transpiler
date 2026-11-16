extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- The advance exposes the handled neighbour (N2377,
	# the N2371 Fracker precedent): the dumped liquid name is
	# the def constant "water" (Blocks.java:2922) and
	# dump_neighbour_index is the FIRST eligible neighbour
	# whose transfer actually moved liquid
	# (handle_liquid_called AND flow > 0), -1 when nothing
	# moved. The N2286 values: 20 water in a 40f store
	# (fract 0.5) against an empty 40f neighbour (ofract 0)
	# transfers (0.5 - 0.0) * 40 / 2 = 10. A fuller neighbour
	# (ofract 0.5) takes nothing; a refusing neighbour
	# (accepts false) takes nothing either -- and is NOT the
	# handled index even though it computes a flow, so a
	# [refusing, empty] pair reports index 1. Two empty
	# neighbours take 10 + 5 = 15 (the fraction recomputes
	# from the running amount) and report the FIRST index
	# only -- the multi-recipient split defers. With no
	# neighbours nothing moves and the cursor stays 0. The
	# cursor ALWAYS ends where it started (the N2286
	# full-cycle invariant: a full scan over N neighbours
	# calls incrementDump N times = one full circle), so
	# every case below pins cursor_after 0. Each case gets a
	# fresh module because the pure dump mutates the store
	# in place (the N2220 advance precedent).
	var transfer_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(transfer_liquids, water_id, 20.0)
	var transferred: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": transfer_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [true], [true])
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, water_id, 10.0)
	var full: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": full_liquids, "cdump": 0}, water_id, 40.0, [20.0], [40.0], [true], [true])
	var refused_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(refused_liquids, water_id, 20.0)
	var refused: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": refused_liquids, "cdump": 0}, water_id, 40.0, [0.0], [40.0], [false], [true])
	var pair_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(pair_liquids, water_id, 20.0)
	var pair: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": pair_liquids, "cdump": 0}, water_id, 40.0, [0.0, 0.0], [40.0, 40.0], [false, true], [true, true])
	var multi_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(multi_liquids, water_id, 20.0)
	var multi: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": multi_liquids, "cdump": 0}, water_id, 40.0, [0.0, 0.0], [40.0, 40.0], [true, true], [true, true])
	var alone_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(alone_liquids, water_id, 20.0)
	var alone: Dictionary = solid_pump_build_state.source_solid_pump_dump_liquid_state({"liquids": alone_liquids, "cdump": 0}, water_id, 40.0, [], [], [], [])
	proof["advance_exposes_dump_neighbour_index"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 10.0) and int(transferred.get("dump_neighbour_index", -9)) == 0 and str(transferred.get("dumped_liquid", "")) == "water" and int(transferred.get("cursor_after", -1)) == 0 and is_equal_approx(float(full.get("dumped_amount", -1.0)), 0.0) and int(full.get("dump_neighbour_index", -9)) == -1 and int(full.get("cursor_after", -1)) == 0 and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and int(refused.get("dump_neighbour_index", -9)) == -1 and int(refused.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_amount", -1.0)), 10.0) and int(pair.get("dump_neighbour_index", -9)) == 1 and int(pair.get("cursor_after", -1)) == 0 and is_equal_approx(float(multi.get("dumped_amount", -1.0)), 15.0) and int(multi.get("dump_neighbour_index", -9)) == 0 and int(multi.get("cursor_after", -1)) == 0 and is_equal_approx(float(alone.get("dumped_amount", -1.0)), 0.0) and int(alone.get("dump_neighbour_index", -9)) == -1 and int(alone.get("cursor_after", -1)) == 0

	# --- Live tick: two water-extractors placed live (the
	# N2286 live setup: full power, so the folded efficiency
	# is 1.0; the fraction inputs are 0, so the pump adds
	# nothing and the dump sees the seeded 20 water). The
	# first dumps to ring 0 -- the neighbour separator at
	# (28, 19) -- and the 10 dumped water lands in its frame
	# liquids. The second dumps to ring 0 -- a copper wall
	# with no store -- and the water still leaves the pump
	# (20 -> 10, cursor ends where it started), dropping with
	# reason no_frame. The size-2 ring 0 is the (0, -1)
	# offset (the angle-sorted ring, the N2371 pin), so the
	# (28, 20) pump's ring 0 is (28, 19) and the (20, 10)
	# pump's is (20, 9). The neighbour arrays are frame
	# inputs (default []), stamped here like the N2286 live
	# setup; the live fill must fill them in ring order.
	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["water-extractor"], extractor_cell)
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor, blocks_by_id["water-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(extractor, true, game.get("content_catalog"))
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 20.0)
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["liquids"] = live_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	extractor_frame["power_status"] = 1.0
	extractor_frame["dump_neighbour_liquid_amounts"] = [0.0]
	extractor_frame["dump_neighbour_liquid_capacities"] = [40.0]
	extractor_frame["dump_neighbour_accepts_liquid"] = [true]
	extractor_frame["dump_neighbour_can_dump_liquid"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_extractor_cell := Vector2i(20, 10)
	var bare_extractor := Sprite2D.new()
	game.add_child(bare_extractor)
	game.call("record_placed_block", bare_extractor, blocks_by_id["water-extractor"], bare_extractor_cell)
	solid_pump_build_state.source_solid_pump_bind_frame_state(bare_extractor, blocks_by_id["water-extractor"])
	var bare_frame: Dictionary = bare_extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(bare_extractor, true, game.get("content_catalog"))
	var bare_liquids: Dictionary = bare_extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bare_liquids, water_id, 20.0)
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 1.0
	bare_frame["dump_neighbour_liquid_amounts"] = [0.0]
	bare_frame["dump_neighbour_liquid_capacities"] = [40.0]
	bare_frame["dump_neighbour_accepts_liquid"] = [true]
	bare_frame["dump_neighbour_can_dump_liquid"] = [true]

	solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	extractor_liquids = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	bare_liquids = bare_extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var extractor_water: float = float(liquid_module_state.source_get_state(extractor_liquids, water_id).get("amount", -1.0))
	var bare_water: float = float(liquid_module_state.source_get_state(bare_liquids, water_id).get("amount", -1.0))
	var live_neighbour_liquids: Dictionary = live_neighbour_frame.get("liquids", {})
	var live_neighbour_water: float = float(liquid_module_state.source_get_state(live_neighbour_liquids, water_id).get("amount", -1.0))
	proof["live_tick_writes_dumped_liquid_to_neighbour_frame"] = live_neighbour_cell == Vector2i(28, 19) and is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(extractor_water, 10.0) and int(extractor_frame.get("cdump", -1)) == 0 and is_equal_approx(live_neighbour_water, 10.0)
	proof["live_tick_dumped_liquid_leaves_pump_without_frame"] = bare_cell == Vector2i(20, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(bare_water, 10.0) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpDumpLiquidWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
