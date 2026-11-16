extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
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
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))

	# --- The dumpLiquid neighbour live fill (N2408, DEFERRED
	# #230): N2284 ported the dump rows (dumpLiquid(result)
	# 2f after the advance in BOTH updateTile branches,
	# Fracker.java:42 / SolidPump.java:140) -- but the
	# neighbour entries stayed frame inputs (default []), so
	# a live fracker with no fill read an empty proximity
	# and never dumped. N2371 wired the neighbour
	# write-back -- but with no fill the routing never ran.
	# This slice fills the neighbour dict array from the
	# live proximity BEFORE the dump pure, in ring order
	# (index i is ring cell i, the N2353 convention):
	# liquid amount / capacity from the neighbour frames,
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptLiquid is hasLiquids && consumesLiquid,
	# :868-870; canDumpLiquid defaults to true, :910-912).
	# Per-block overrides are OUT of scope. The dumped
	# liquid is the fixed def result oil (not
	# liquids.current(), the N2394 unloader case). A
	# neighbour with no frame reports the no-frame outcome
	# (0.0 / 0.0 / false / false / false / false / false /
	# 0). The size-3 ring has 12 cells (angle-sorted): ring
	# 0 is the (-2, -1) offset, so the (28, 20) fracker's
	# ring 0 is (26, 19), its ring 5 is (30, 20) and its
	# ring 11 is (26, 20). The neighbours here are a size-1
	# melter at ring 0 (consumes scrap, no liquids store --
	# the catalog carries no consumeLiquid row for it), a
	# size-4 advanced-launch-pad at (28, 16) whose
	# footprint (27..30, 15..18) covers rings 1, 2 and 3
	# (consumes oil but has NO hasLiquids key -- the
	# catalog gap, so the Java field default false
	# applies), a size-2 plastanium-compressor at ring 5
	# (consumes oil, hasLiquids true, liquidCapacity 60f --
	# the catalog carries the row; its footprint (30..31,
	# 20..21) also covers ring 6, so the ring reports it at
	# BOTH indices 5 and 6), and a size-2 cryofluid-mixer
	# at ring 8 (consumes water, not oil, hasLiquids true,
	# liquidCapacity 36f; its footprint (28..29, 22..23)
	# also covers ring 7). A copper wall at ring 11 (26,
	# 20) is the frameless neighbour; the other ring cells
	# (e.g. index 4, (30, 19)) are empty. No footprints
	# overlap the fracker (27..29, 19..21) or each other.
	var ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var extractor_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var launch_pad_cell := Vector2i(28, 16)
	var compressor_cell: Vector2i = ring[5]
	var mixer_cell: Vector2i = ring[8]
	var wall_cell: Vector2i = ring[11]
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["oil-extractor"], extractor_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor, blocks_by_id["oil-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(extractor, true, game.get("content_catalog"))
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, oil_id, 20.0)
	liquid_module_state.source_set_state(extractor_liquids, water_id, 0.3)
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var launch_pad := Sprite2D.new()
	game.add_child(launch_pad)
	game.call("record_placed_block", launch_pad, blocks_by_id["advanced-launch-pad"], launch_pad_cell)
	launch_pad_build_state.source_launch_pad_bind_frame_state(launch_pad, blocks_by_id["advanced-launch-pad"])
	var compressor := Sprite2D.new()
	game.add_child(compressor)
	game.call("record_placed_block", compressor, blocks_by_id["plastanium-compressor"], compressor_cell)
	factory_build_state.source_factory_bind_frame_state(compressor, blocks_by_id["plastanium-compressor"])
	var compressor_frame: Dictionary = compressor.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	compressor_frame["liquids"] = compressor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var compressor_liquids: Dictionary = compressor_frame.get("liquids", {})
	liquid_module_state.source_set_state(compressor_liquids, oil_id, 5.0)
	var mixer := Sprite2D.new()
	game.add_child(mixer)
	game.call("record_placed_block", mixer, blocks_by_id["cryofluid-mixer"], mixer_cell)
	factory_build_state.source_factory_bind_frame_state(mixer, blocks_by_id["cryofluid-mixer"])
	var mixer_frame: Dictionary = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["liquids"] = mixer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var mixer_liquids: Dictionary = mixer_frame.get("liquids", {})
	liquid_module_state.source_set_state(mixer_liquids, water_id, 5.0)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The liquid entries fill from the live neighbour
	# frames: the plastanium-compressor holds 5.0 oil at
	# capacity 60f and consumes oil with hasLiquids true --
	# so it reports 5.0 / 60.0 / accepts true / has_liquids
	# true / can_dump true / liquids_present true /
	# destination_present true / relative_to 0 at BOTH of
	# its ring indices (5 and 6). The fill returns one dict
	# per ring cell (12 entries), each with the exact N2284
	# dict shape.
	var filled: Dictionary = fracker_build_state.source_fracker_dump_liquid_neighbour_live_fill_state(game, extractor_cell, 3, oil_id)
	var neighbours: Array = filled.get("dump_liquid_neighbours", [])
	var entry5: Dictionary = neighbours[5] if neighbours.size() > 5 and neighbours[5] is Dictionary else {}
	var entry6: Dictionary = neighbours[6] if neighbours.size() > 6 and neighbours[6] is Dictionary else {}
	proof["fill_liquid_entries_from_live_neighbours"] = ring.size() == 12 and melter_cell == Vector2i(26, 19) and compressor_cell == Vector2i(30, 20) and mixer_cell == Vector2i(28, 22) and wall_cell == Vector2i(26, 20) and neighbours.size() == 12 and is_equal_approx(float(entry5.get("amount", -1.0)), 5.0) and is_equal_approx(float(entry6.get("amount", -1.0)), 5.0) and is_equal_approx(float(entry5.get("capacity", -1.0)), 60.0) and is_equal_approx(float(entry6.get("capacity", -1.0)), 60.0) and bool(entry5.get("accepts", false)) and bool(entry6.get("accepts", false)) and bool(entry5.get("has_liquids", false)) and bool(entry6.get("has_liquids", false)) and bool(entry5.get("can_dump", false)) and bool(entry6.get("can_dump", false)) and bool(entry5.get("liquids_present", false)) and bool(entry6.get("liquids_present", false)) and bool(entry5.get("destination_present", false)) and int(entry5.get("relative_to", -1)) == 0

	# The accepts gate REQUIRES hasLiquids: the
	# advanced-launch-pad consumes oil (the catalog carries
	# the consumeLiquid row) but has NO hasLiquids key, so
	# the Java field default false applies and it rejects
	# oil at all three of its ring indices (1, 2, 3) -- even
	# though it HAS a frame (can_dump true) and consumes
	# the dumped liquid. The melter (no hasLiquids key, no
	# consumeLiquid row) rejects too.
	var entry1: Dictionary = neighbours[1] if neighbours.size() > 1 and neighbours[1] is Dictionary else {}
	var entry2: Dictionary = neighbours[2] if neighbours.size() > 2 and neighbours[2] is Dictionary else {}
	var entry3: Dictionary = neighbours[3] if neighbours.size() > 3 and neighbours[3] is Dictionary else {}
	var entry0: Dictionary = neighbours[0] if neighbours.size() > 0 and neighbours[0] is Dictionary else {}
	proof["fill_accepts_gate_requires_has_liquids"] = not bool(entry1.get("accepts", true)) and not bool(entry2.get("accepts", true)) and not bool(entry3.get("accepts", true)) and not bool(entry1.get("has_liquids", true)) and not bool(entry2.get("has_liquids", true)) and not bool(entry3.get("has_liquids", true)) and bool(entry1.get("can_dump", false)) and bool(entry2.get("can_dump", false)) and bool(entry3.get("can_dump", false)) and not bool(entry0.get("accepts", true)) and not bool(entry0.get("has_liquids", true)) and bool(entry0.get("can_dump", false))

	# The accepts gate REQUIRES consumesLiquid: the
	# cryofluid-mixer HAS liquids (hasLiquids true, a
	# liquids store, capacity 36f) but consumes water, not
	# oil -- so it rejects oil at both of its ring indices
	# (7 and 8) while reporting has_liquids true,
	# liquids_present true and can_dump true. Its oil
	# amount is 0.0 (it holds water only).
	var entry7: Dictionary = neighbours[7] if neighbours.size() > 7 and neighbours[7] is Dictionary else {}
	var entry8: Dictionary = neighbours[8] if neighbours.size() > 8 and neighbours[8] is Dictionary else {}
	proof["fill_accepts_gate_requires_consumes_liquid"] = not bool(entry7.get("accepts", true)) and not bool(entry8.get("accepts", true)) and bool(entry7.get("has_liquids", false)) and bool(entry8.get("has_liquids", false)) and bool(entry7.get("liquids_present", false)) and bool(entry8.get("liquids_present", false)) and bool(entry7.get("can_dump", false)) and bool(entry8.get("can_dump", false)) and is_equal_approx(float(entry7.get("amount", -1.0)), 0.0) and is_equal_approx(float(entry8.get("amount", -1.0)), 0.0)

	# The capacity fills from the neighbour def: the
	# compressor reports 60f, the mixer 36f (both from the
	# catalog liquidCapacity key), while the melter -- whose
	# frame carries no liquids store -- reports 0.0 (the
	# N2371 no_liquids_store precedent).
	proof["fill_capacity_from_live_neighbour"] = is_equal_approx(float(entry5.get("capacity", -1.0)), 60.0) and is_equal_approx(float(entry7.get("capacity", -1.0)), 36.0) and is_equal_approx(float(entry8.get("capacity", -1.0)), 36.0) and is_equal_approx(float(entry0.get("capacity", -1.0)), 0.0) and not bool(entry0.get("liquids_present", true))

	# The no-frame outcome: the copper wall at ring 11 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 4) report 0.0 / 0.0 / false
	# / false / false / false / false / 0 -- nothing routes
	# there (the N2353/N2371 no-frame precedent).
	var entry11: Dictionary = neighbours[11] if neighbours.size() > 11 and neighbours[11] is Dictionary else {}
	var entry4: Dictionary = neighbours[4] if neighbours.size() > 4 and neighbours[4] is Dictionary else {}
	proof["fill_no_frame_neighbour_reports_empty"] = is_equal_approx(float(entry11.get("amount", -1.0)), 0.0) and is_equal_approx(float(entry11.get("capacity", -1.0)), 0.0) and not bool(entry11.get("accepts", true)) and not bool(entry11.get("has_liquids", true)) and not bool(entry11.get("can_dump", true)) and not bool(entry11.get("liquids_present", true)) and not bool(entry11.get("destination_present", true)) and int(entry11.get("relative_to", -1)) == 0 and is_equal_approx(float(entry4.get("amount", -1.0)), 0.0) and is_equal_approx(float(entry4.get("capacity", -1.0)), 0.0) and not bool(entry4.get("accepts", true)) and not bool(entry4.get("has_liquids", true)) and not bool(entry4.get("can_dump", true)) and not bool(entry4.get("liquids_present", true)) and not bool(entry4.get("destination_present", true)) and int(entry4.get("relative_to", -1)) == 0 and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the oil-extractor placed live with NO
	# seeded dump_liquid_neighbours -- the tick fills them
	# live. The extractor runs the if-branch (full power,
	# water + sand seeded so the folded efficiency is 1.0;
	# the fraction inputs are 0, so the pump adds nothing
	# and the dump sees the seeded 20 oil). The compressor
	# oil is reset to 0.0 first so the transfer is exact:
	# ring 5 takes (0.5 - 0) * 40 / 2 = 10, then ring 6
	# takes (0.25 - 0) * 40 / 2 = 5 (the fraction
	# recomputes from the running amount) -- 15 total, all
	# landing in the compressor frame through the N2371
	# helper (the first handled index takes the total, the
	# N2380 precedent). The melter, launch pad and mixer
	# take nothing (they reject oil). The cursor advances
	# once per proximity iteration over 12 neighbours, so
	# it wraps (0 + 12) % 12 back to 0. The frame keeps the
	# live-filled array and the dump_liquid_neighbours_live
	# flag.
	liquid_module_state.source_set_state(compressor_liquids, oil_id, 0.0)
	extractor_frame["items"] = {"sand": 1}
	extractor_frame["power_status"] = 1.0

	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	compressor_frame = compressor.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	extractor_liquids = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	compressor_liquids = compressor_frame.get("liquids", {})
	var live_oil: float = float(liquid_module_state.source_get_state(extractor_liquids, oil_id).get("amount", -1.0))
	var compressor_oil: float = float(liquid_module_state.source_get_state(compressor_liquids, oil_id).get("amount", -1.0))
	var live_neighbours: Array = extractor_frame.get("dump_liquid_neighbours", [])
	var live_entry5: Dictionary = live_neighbours[5] if live_neighbours.size() > 5 and live_neighbours[5] is Dictionary else {}
	var live_entry0: Dictionary = live_neighbours[0] if live_neighbours.size() > 0 and live_neighbours[0] is Dictionary else {}
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(live_oil, 5.0) and is_equal_approx(compressor_oil, 15.0) and int(extractor_frame.get("cdump", -1)) == 0 and bool(extractor_frame.get("dump_liquid_neighbours_live", false)) and live_neighbours.size() == 12 and bool(live_entry5.get("accepts", false)) and not bool(live_entry0.get("accepts", true)) and is_equal_approx(float(live_entry5.get("capacity", -1.0)), 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerDumpLiquidNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
