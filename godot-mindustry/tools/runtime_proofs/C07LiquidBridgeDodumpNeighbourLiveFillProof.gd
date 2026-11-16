extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
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
	var liquid_names_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_names_by_id.append(liquid.id)

	# --- The doDump neighbour live fill (N2412, DEFERRED
	# #232): N2287 ported the doDump rows
	# (dumpLiquid(liquids.current(), 1f) in the unlinked
	# branch only, LiquidBridge.java:29-31) -- but the eight
	# neighbour arrays stayed frame inputs (default []), so
	# a live bridge with no fill read an empty proximity and
	# never dumped. N2379 wired the neighbour write-back --
	# but with no fill the routing never ran. This slice
	# fills the eight neighbour arrays from the live
	# proximity BEFORE the dump reads them at :540, in ring
	# order (index i is ring cell i, the N2353 convention):
	# liquid amount / capacity from the neighbour frames,
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptLiquid is hasLiquids && consumesLiquid,
	# :868-870; canDumpLiquid defaults to true, :910-912).
	# Per-block overrides are OUT of scope. The dumped
	# liquid is liquids.current() (the N2394 unloader case,
	# NOT the N2408 fixed def result) -- the bridge holds
	# water here, so the fill reads the water amounts and
	# matches the consumeLiquid rows against "water". A
	# neighbour with no frame reports the no-frame outcome
	# (0.0 / 0.0 / false / false / false / false / false /
	# 0). The size-1 ring has 4 cells (angle-sorted): ring
	# 0 is the (0, -1) offset, so the (28, 21) bridge's ring
	# 0 is (28, 20), its ring 1 is (29, 21), its ring 2 is
	# (28, 22) and its ring 3 is (27, 21). The neighbours
	# here are a size-2 cryofluid-mixer at (28, 19) whose
	# footprint (28..29, 19..20) covers ring 0 (consumes
	# water, hasLiquids true, liquidCapacity 36f -- the
	# accepting neighbour), a size-2 plastanium-compressor
	# at (29, 21) whose footprint (29..30, 21..22) covers
	# ring 1 (consumes oil, not water, hasLiquids true,
	# liquidCapacity 60f), a size-3 electrolyzer at (27, 23)
	# whose CENTRED footprint (26..28, 22..24) covers ring
	# 2 (consumes water but has NO hasLiquids key -- the
	# catalog gap, so the Java field default false applies;
	# the size-3 footprint is centred on its origin cell,
	# SourceBlockFootprint.footprint_offset -- the N2394
	# press-centre lesson, so the origin sits one cell
	# north of the ring cell), and a copper wall at ring 3
	# (27, 21), the frameless neighbour. No footprints
	# overlap the bridge (28, 21) or each other.
	var ring: Array = block_geometry.source_block_proximity_cells_state(1, 28, 21).get("cells", [])
	var bridge_cell := Vector2i(28, 21)
	var mixer_cell := Vector2i(28, 19)
	var compressor_cell := Vector2i(29, 21)
	var electrolyzer_cell := Vector2i(27, 23)
	var wall_cell := Vector2i(27, 21)
	var bridge := Sprite2D.new()
	game.add_child(bridge)
	game.call("record_placed_block", bridge, blocks_by_id["phase-conduit"], bridge_cell)
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(bridge, blocks_by_id["phase-conduit"])
	var bridge_frame: Dictionary = bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(bridge, true, game.get("content_catalog"))
	var bridge_liquids: Dictionary = bridge.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bridge_liquids, water_id, 50.0)
	var mixer := Sprite2D.new()
	game.add_child(mixer)
	game.call("record_placed_block", mixer, blocks_by_id["cryofluid-mixer"], mixer_cell)
	factory_build_state.source_factory_bind_frame_state(mixer, blocks_by_id["cryofluid-mixer"])
	var mixer_frame: Dictionary = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["liquids"] = mixer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var mixer_liquids: Dictionary = mixer_frame.get("liquids", {})
	liquid_module_state.source_set_state(mixer_liquids, water_id, 5.0)
	var compressor := Sprite2D.new()
	game.add_child(compressor)
	game.call("record_placed_block", compressor, blocks_by_id["plastanium-compressor"], compressor_cell)
	factory_build_state.source_factory_bind_frame_state(compressor, blocks_by_id["plastanium-compressor"])
	var compressor_frame: Dictionary = compressor.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	compressor_frame["liquids"] = compressor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var compressor_liquids: Dictionary = compressor_frame.get("liquids", {})
	liquid_module_state.source_set_state(compressor_liquids, oil_id, 5.0)
	var electrolyzer := Sprite2D.new()
	game.add_child(electrolyzer)
	game.call("record_placed_block", electrolyzer, blocks_by_id["electrolyzer"], electrolyzer_cell)
	factory_build_state.source_factory_bind_frame_state(electrolyzer, blocks_by_id["electrolyzer"])
	var electrolyzer_frame: Dictionary = electrolyzer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	electrolyzer_frame["liquids"] = electrolyzer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The liquid arrays fill from the live neighbour
	# frames: the cryofluid-mixer holds 5.0 water at
	# capacity 36f and consumes water with hasLiquids true
	# -- so it reports 5.0 / 36.0 / accepts true /
	# has_liquids true / can_dump true / liquids_present
	# true / destination_present true / relative_to 0 at
	# ring index 0. The fill returns eight parallel arrays
	# with one entry per ring cell (4 entries each).
	var filled: Dictionary = liquid_bridge_build_state.source_liquid_bridge_dodump_neighbour_live_fill_state(game, bridge_cell, 1, bridge_liquids, liquid_names_by_id)
	var amounts: Array = filled.get("dump_neighbour_amounts", [])
	var capacities: Array = filled.get("dump_neighbour_capacities", [])
	var accepts: Array = filled.get("dump_neighbour_accepts", [])
	var has_liquids: Array = filled.get("dump_neighbour_has_liquids", [])
	var can_dump: Array = filled.get("dump_neighbour_can_dump", [])
	var liquids_present: Array = filled.get("dump_neighbour_liquids_present", [])
	var destination_present: Array = filled.get("dump_neighbour_destination_present", [])
	var relative_to: Array = filled.get("dump_neighbour_relative_to", [])
	proof["fill_liquid_arrays_from_live_neighbours"] = ring.size() == 4 and ring[0] == Vector2i(28, 20) and ring[1] == Vector2i(29, 21) and ring[2] == Vector2i(28, 22) and ring[3] == Vector2i(27, 21) and int(bridge_liquids.get("current", -1)) == water_id and amounts.size() == 4 and capacities.size() == 4 and accepts.size() == 4 and has_liquids.size() == 4 and can_dump.size() == 4 and liquids_present.size() == 4 and destination_present.size() == 4 and relative_to.size() == 4 and is_equal_approx(float(amounts[0]), 5.0) and is_equal_approx(float(capacities[0]), 36.0) and bool(accepts[0]) and bool(has_liquids[0]) and bool(can_dump[0]) and bool(liquids_present[0]) and bool(destination_present[0]) and int(relative_to[0]) == 0

	# The accepts gate REQUIRES hasLiquids: the
	# electrolyzer consumes water (the catalog carries the
	# consumeLiquid row) but has NO hasLiquids key, so the
	# Java field default false applies and it rejects water
	# at ring index 2 -- even though it HAS a frame (can_dump
	# true), a liquids store (liquids_present true,
	# capacity 50f) and consumes the dumped liquid.
	var electrolyzer_consumes_water := false
	for row in blocks_by_id["electrolyzer"].properties.get("consumeLiquid", []):
		if row is Dictionary and str(row.get("liquid", "")) == "water":
			electrolyzer_consumes_water = true
	proof["fill_accepts_gate_requires_has_liquids"] = electrolyzer_consumes_water and not bool(blocks_by_id["electrolyzer"].properties.has("hasLiquids")) and not bool(accepts[2]) and not bool(has_liquids[2]) and bool(can_dump[2]) and bool(liquids_present[2]) and bool(destination_present[2]) and is_equal_approx(float(capacities[2]), 50.0) and is_equal_approx(float(amounts[2]), 0.0)

	# The accepts gate REQUIRES consumesLiquid: the
	# plastanium-compressor HAS liquids (hasLiquids true, a
	# liquids store, capacity 60f) but consumes oil, not
	# water -- so it rejects water at ring index 1 while
	# reporting has_liquids true, liquids_present true and
	# can_dump true. Its water amount is 0.0 (it holds oil
	# only -- the fill reads the CURRENT liquid's amount).
	proof["fill_accepts_gate_requires_consumes_liquid"] = not bool(accepts[1]) and bool(has_liquids[1]) and bool(liquids_present[1]) and bool(can_dump[1]) and is_equal_approx(float(amounts[1]), 0.0) and is_equal_approx(float(capacities[1]), 60.0) and is_equal_approx(float(liquid_module_state.source_get_state(compressor_liquids, oil_id).get("amount", -1.0)), 5.0)

	# The capacity fills from the neighbour def: the mixer
	# reports 36f, the compressor 60f, the electrolyzer 50f
	# (all from the catalog liquidCapacity key), while the
	# copper wall -- no frame at all -- reports 0.0. The
	# no-store branch: a framed neighbour whose frame
	# carries no liquids store reports capacity 0.0 and
	# liquids_present false (the N2371 no_liquids_store
	# precedent) -- probed here by erasing the mixer frame
	# liquids and refilling, then re-attaching the store.
	var no_store_capacity := -1.0
	var no_store_liquids_present := true
	var no_store_can_dump := false
	mixer_frame.erase("liquids")
	var refilled: Dictionary = liquid_bridge_build_state.source_liquid_bridge_dodump_neighbour_live_fill_state(game, bridge_cell, 1, bridge_liquids, liquid_names_by_id)
	var refilled_capacities: Array = refilled.get("dump_neighbour_capacities", [])
	var refilled_liquids_present: Array = refilled.get("dump_neighbour_liquids_present", [])
	var refilled_can_dump: Array = refilled.get("dump_neighbour_can_dump", [])
	if refilled_capacities.size() > 0:
		no_store_capacity = float(refilled_capacities[0])
	if refilled_liquids_present.size() > 0:
		no_store_liquids_present = bool(refilled_liquids_present[0])
	if refilled_can_dump.size() > 0:
		no_store_can_dump = bool(refilled_can_dump[0])
	mixer_frame["liquids"] = mixer_liquids
	proof["fill_capacity_from_live_neighbour"] = is_equal_approx(float(capacities[0]), 36.0) and is_equal_approx(float(capacities[1]), 60.0) and is_equal_approx(float(capacities[2]), 50.0) and is_equal_approx(float(capacities[3]), 0.0) and is_equal_approx(no_store_capacity, 0.0) and not no_store_liquids_present and no_store_can_dump

	# The no-frame outcome: the copper wall at ring 3 (no
	# frame on its sprite) reports 0.0 / 0.0 / false / false
	# / false / false / false / 0 -- nothing routes there
	# (the N2353/N2371 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = is_equal_approx(float(amounts[3]), 0.0) and is_equal_approx(float(capacities[3]), 0.0) and not bool(accepts[3]) and not bool(has_liquids[3]) and not bool(can_dump[3]) and not bool(liquids_present[3]) and not bool(destination_present[3]) and int(relative_to[3]) == 0 and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the phase-conduit placed live and
	# unlinked (link -1, had_valid_link false), with 50
	# water in its liquids meta and NO seeded dump
	# neighbour arrays -- the tick fills them live. The
	# mixer water is reset to 0.0 first so the transfer is
	# exact: ring 0 takes (0.5 - 0) * 100 / 1 = 50, capped
	# by the mixer's free capacity (36 - 0) to 36 -- 36
	# total, landing in the mixer frame through the N2371
	# helper (the first handled index takes the total, the
	# N2380 precedent). The compressor, electrolyzer and
	# wall take nothing (they reject water / have no frame).
	# The cursor advances once per proximity iteration over
	# 4 neighbours, so it wraps (0 + 4) % 4 back to 0. The
	# frame keeps the live-filled arrays and the
	# dump_neighbour_live flag. The shouldConsume gate is
	# closed while unlinked (ItemBridge.java:495-496), so
	# efficiency folds 0 (potential 0.5, the power min) and
	# warmup is 0f (ItemBridge.java:337).
	liquid_module_state.source_set_state(mixer_liquids, water_id, 0.0)
	bridge_frame["power_status"] = 0.5

	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_frame = bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	bridge_liquids = bridge.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	mixer_liquids = mixer_frame.get("liquids", {})
	var live_water: float = float(liquid_module_state.source_get_state(bridge_liquids, water_id).get("amount", -1.0))
	var mixer_water: float = float(liquid_module_state.source_get_state(mixer_liquids, water_id).get("amount", -1.0))
	var live_amounts: Array = bridge_frame.get("dump_neighbour_amounts", [])
	var live_accepts: Array = bridge_frame.get("dump_neighbour_accepts", [])
	var live_capacities: Array = bridge_frame.get("dump_neighbour_capacities", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(bridge_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(bridge_frame.get("warmup", -1.0)), 0.0) and bool(bridge_frame.get("had_valid_link", true)) == false and is_equal_approx(live_water, 14.0) and is_equal_approx(mixer_water, 36.0) and int(bridge_frame.get("cdump", -1)) == 0 and bool(bridge_frame.get("dump_neighbour_live", false)) and live_amounts.size() == 4 and live_accepts.size() == 4 and live_capacities.size() == 4 and bool(live_accepts[0]) and not bool(live_accepts[1]) and not bool(live_accepts[2]) and not bool(live_accepts[3]) and is_equal_approx(float(live_capacities[0]), 36.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeDodumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
