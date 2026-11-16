extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
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
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))

	# --- The dump neighbour live fill (N2411, DEFERRED
	# #230): N2286 ported the dump rows (dumpLiquid(result)
	# 2f after the advance, SolidPump.java:140) -- but the
	# neighbour arrays stayed frame inputs (default []), so
	# a live solid pump with no fill read an empty proximity
	# and never dumped. N2377 wired the neighbour
	# write-back -- but with no fill the routing never ran.
	# This slice fills the four neighbour arrays from the
	# live proximity BEFORE the dump pure, in ring order
	# (index i is ring cell i, the N2353 convention):
	# liquid amount / capacity from the neighbour frames,
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptLiquid is hasLiquids && consumesLiquid,
	# :868-870; canDumpLiquid defaults to true, :910-912).
	# Per-block overrides are OUT of scope. The dumped
	# liquid is the fixed def result water (not
	# liquids.current(), the N2394 unloader case). A
	# neighbour with no frame reports the no-frame outcome
	# (0.0 / 0.0 / false / false). The size-2 ring has 8
	# cells (angle-sorted): ring 0 is the (0, -1) offset
	# (the N2377 pin), so the (28, 20) pump's ring 0 is
	# (28, 19), ring 2 is (30, 20), ring 4 is (29, 22),
	# ring 6 is (27, 21) and ring 7 is (27, 20). The
	# neighbours here are a size-1 melter at ring 0
	# (consumes no liquid, no liquids store -- the catalog
	# carries no consumeLiquid row for it), a size-2
	# cryofluid-mixer at ring 2 (consumes water, hasLiquids
	# true, liquidCapacity 36f; its footprint (30..31,
	# 20..21) also covers ring 3, so the ring reports it at
	# BOTH indices 2 and 3), a size-3 electrolyzer at
	# (29, 23) whose footprint (28..30, 22..24) covers
	# rings 4 and 5 (consumes water but has NO hasLiquids
	# key -- the catalog gap, so the Java field default
	# false applies), a size-2 plastanium-compressor at
	# (26, 21) whose footprint (26..27, 21..22) covers ring
	# 6 only (consumes oil, not water, hasLiquids true,
	# liquidCapacity 60f). A copper wall at ring 7 (27, 20)
	# is the frameless neighbour; the other ring cells
	# (index 1, (29, 19)) are empty. No footprints overlap
	# the pump (28..29, 20..21) or each other.
	var ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var extractor_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var mixer_cell: Vector2i = ring[2]
	var electrolyzer_cell := Vector2i(29, 23)
	var compressor_cell := Vector2i(26, 21)
	var wall_cell: Vector2i = ring[7]
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["water-extractor"], extractor_cell)
	solid_pump_build_state.source_solid_pump_bind_frame_state(extractor, blocks_by_id["water-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(extractor, true, game.get("content_catalog"))
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 20.0)
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var mixer := Sprite2D.new()
	game.add_child(mixer)
	game.call("record_placed_block", mixer, blocks_by_id["cryofluid-mixer"], mixer_cell)
	factory_build_state.source_factory_bind_frame_state(mixer, blocks_by_id["cryofluid-mixer"])
	placed_block_state.source_initialize_building_liquids_state(mixer, true, game.get("content_catalog"))
	var mixer_frame: Dictionary = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["liquids"] = mixer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var mixer_liquids: Dictionary = mixer_frame.get("liquids", {})
	liquid_module_state.source_set_state(mixer_liquids, water_id, 5.0)
	var electrolyzer := Sprite2D.new()
	game.add_child(electrolyzer)
	game.call("record_placed_block", electrolyzer, blocks_by_id["electrolyzer"], electrolyzer_cell)
	factory_build_state.source_factory_bind_frame_state(electrolyzer, blocks_by_id["electrolyzer"])
	placed_block_state.source_initialize_building_liquids_state(electrolyzer, true, game.get("content_catalog"))
	var electrolyzer_frame: Dictionary = electrolyzer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	electrolyzer_frame["liquids"] = electrolyzer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var compressor := Sprite2D.new()
	game.add_child(compressor)
	game.call("record_placed_block", compressor, blocks_by_id["plastanium-compressor"], compressor_cell)
	factory_build_state.source_factory_bind_frame_state(compressor, blocks_by_id["plastanium-compressor"])
	placed_block_state.source_initialize_building_liquids_state(compressor, true, game.get("content_catalog"))
	var compressor_frame: Dictionary = compressor.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	compressor_frame["liquids"] = compressor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var compressor_liquids: Dictionary = compressor_frame.get("liquids", {})
	liquid_module_state.source_set_state(compressor_liquids, oil_id, 5.0)
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The liquid arrays fill from the live neighbour
	# frames: the cryofluid-mixer holds 5.0 water at
	# capacity 36f and consumes water with hasLiquids true --
	# so it reports 5.0 / 36.0 / accepts true / can_dump
	# true at BOTH of its ring indices (2 and 3). The fill
	# returns one entry per ring cell (8 entries) in each of
	# the four arrays.
	var filled: Dictionary = solid_pump_build_state.source_solid_pump_dump_neighbour_live_fill_state(game, extractor_cell, 2, water_id)
	var amounts: Array = filled.get("dump_neighbour_liquid_amounts", [])
	var capacities: Array = filled.get("dump_neighbour_liquid_capacities", [])
	var accepts: Array = filled.get("dump_neighbour_accepts_liquid", [])
	var can_dump: Array = filled.get("dump_neighbour_can_dump_liquid", [])
	proof["fill_liquid_arrays_from_live_neighbours"] = ring.size() == 8 and melter_cell == Vector2i(28, 19) and mixer_cell == Vector2i(30, 20) and wall_cell == Vector2i(27, 20) and amounts.size() == 8 and capacities.size() == 8 and accepts.size() == 8 and can_dump.size() == 8 and is_equal_approx(float(amounts[2]), 5.0) and is_equal_approx(float(amounts[3]), 5.0) and is_equal_approx(float(capacities[2]), 36.0) and is_equal_approx(float(capacities[3]), 36.0) and bool(accepts[2]) and bool(accepts[3]) and bool(can_dump[2]) and bool(can_dump[3])

	# The accepts gate REQUIRES hasLiquids: the electrolyzer
	# consumes water (the catalog carries the consumeLiquid
	# row) but has NO hasLiquids key, so the Java field
	# default false applies and it rejects water at both of
	# its ring indices (4 and 5) -- even though it HAS a
	# frame (can_dump true) and consumes the dumped liquid.
	# The melter (no hasLiquids key, no consumeLiquid row)
	# rejects too.
	proof["fill_accepts_gate_requires_has_liquids"] = not bool(accepts[4]) and not bool(accepts[5]) and bool(can_dump[4]) and bool(can_dump[5]) and not bool(accepts[0]) and bool(can_dump[0])

	# The accepts gate REQUIRES consumesLiquid: the
	# plastanium-compressor HAS liquids (hasLiquids true, a
	# liquids store, capacity 60f) but consumes oil, not
	# water -- so it rejects water at its ring index (6)
	# while reporting can_dump true. Its water amount is 0.0
	# (it holds oil only -- the fill reads the dumped result
	# liquid, not liquids.current()).
	proof["fill_accepts_gate_requires_consumes_liquid"] = not bool(accepts[6]) and bool(can_dump[6]) and is_equal_approx(float(capacities[6]), 60.0) and is_equal_approx(float(amounts[6]), 0.0)

	# The capacity fills from the neighbour def: the mixer
	# reports 36f, the compressor 60f, the electrolyzer 50f
	# (all from the catalog liquidCapacity key), while the
	# melter -- whose frame carries no liquids store --
	# reports 0.0 (the N2371 no_liquids_store precedent).
	proof["fill_capacity_from_live_neighbour"] = is_equal_approx(float(capacities[2]), 36.0) and is_equal_approx(float(capacities[3]), 36.0) and is_equal_approx(float(capacities[6]), 60.0) and is_equal_approx(float(capacities[4]), 50.0) and is_equal_approx(float(capacities[5]), 50.0) and is_equal_approx(float(capacities[0]), 0.0)

	# The no-frame outcome: the copper wall at ring 7 (no
	# frame on its sprite) and the empty ring cell (no
	# sprite at all, index 1) report 0.0 / 0.0 / false /
	# false -- nothing routes there (the N2353/N2371
	# no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = is_equal_approx(float(amounts[7]), 0.0) and is_equal_approx(float(capacities[7]), 0.0) and not bool(accepts[7]) and not bool(can_dump[7]) and is_equal_approx(float(amounts[1]), 0.0) and is_equal_approx(float(capacities[1]), 0.0) and not bool(accepts[1]) and not bool(can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the water-extractor placed live with NO
	# seeded dump neighbour arrays -- the tick fills them
	# live. The extractor runs at full power (the fraction
	# inputs are 0, so the pump adds nothing and the dump
	# sees the seeded 20 water). The mixer water is reset
	# to 0.0 first so the transfer is exact: ring 2 takes
	# (0.5 - 0) * 40 / 2 = 10, then ring 3 takes
	# (0.25 - 0) * 40 / 2 = 5 (the fraction recomputes from
	# the running amount) -- 15 total, all landing in the
	# mixer frame through the N2377 helper (the first
	# handled index takes the total, the N2380 precedent).
	# The melter, electrolyzer and compressor take nothing
	# (they reject water). The cursor advances once per
	# proximity iteration over 8 neighbours, so it wraps
	# (0 + 8) % 8 back to 0. The frame keeps the
	# live-filled arrays and the dump_neighbour_live flag.
	liquid_module_state.source_set_state(mixer_liquids, water_id, 0.0)
	extractor_frame["power_status"] = 1.0

	solid_pump_build_state.source_solid_pump_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(solid_pump_build_state.SOURCE_SOLID_PUMP_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	extractor_liquids = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	mixer_liquids = mixer_frame.get("liquids", {})
	var live_water: float = float(liquid_module_state.source_get_state(extractor_liquids, water_id).get("amount", -1.0))
	var mixer_water: float = float(liquid_module_state.source_get_state(mixer_liquids, water_id).get("amount", -1.0))
	var live_amounts: Array = extractor_frame.get("dump_neighbour_liquid_amounts", [])
	var live_capacities: Array = extractor_frame.get("dump_neighbour_liquid_capacities", [])
	var live_accepts: Array = extractor_frame.get("dump_neighbour_accepts_liquid", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(live_water, 5.0) and is_equal_approx(mixer_water, 15.0) and int(extractor_frame.get("cdump", -1)) == 0 and bool(extractor_frame.get("dump_neighbour_live", false)) and live_amounts.size() == 8 and live_capacities.size() == 8 and live_accepts.size() == 8 and bool(live_accepts[2]) and not bool(live_accepts[0]) and is_equal_approx(float(live_capacities[2]), 36.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
