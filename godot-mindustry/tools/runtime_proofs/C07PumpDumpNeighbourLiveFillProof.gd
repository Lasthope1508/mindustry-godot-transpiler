extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mechanical_pump_build_state := preload("res://src/game/SourceMechanicalPumpBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const terrain_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
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
	var liquid_id_by_name: Dictionary = content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var shallow_water = catalog.get_by_id("shallow-water")

	# --- The dump neighbour live fill (N2410, DEFERRED
	# #228): N2285 ported the dumpLiquid rows
	# (if(liquidDrop != null) dumpLiquid(liquidDrop),
	# Pump.java:178-180, after the advance) -- but the
	# neighbour arrays stayed frame inputs (default []), so
	# a live pump with no fill read an empty proximity and
	# never dumped. N2378 wired the neighbour write-back --
	# but with no fill the routing never ran. This slice
	# fills the four neighbour arrays from the live
	# proximity BEFORE the dump pure, in ring order
	# (index i is ring cell i, the N2353 convention):
	# liquid amount / capacity from the neighbour frames,
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptLiquid is hasLiquids && consumesLiquid,
	# :868-870; canDumpLiquid defaults to true, :910-912).
	# Per-block overrides are OUT of scope. Unlike the
	# Fracker's def constant "oil", the pumped liquid
	# VARIES BY TILE: liquid_drop is a String NAME (the
	# N2378 precedent) -- here water, from the
	# shallow-water floor under the pump footprint -- so
	# the fill takes the NAME + the liquid_id_by_name map,
	# like the N2285 dump pure. A neighbour with no frame
	# reports the no-frame outcome (0.0 / 0.0 / false /
	# false). The size-2 ring has 8 cells (angle-sorted):
	# ring 0 is the (0, -1) offset (the N2371 pin), so the
	# (28, 20) pump's ring is (28, 19), (29, 19), (30, 20),
	# (30, 21), (29, 22), (28, 22), (27, 21), (27, 20).
	# The neighbours here are a size-1 melter at ring 0
	# (consumes scrap, no liquids store -- the catalog
	# carries no consumeLiquid row for it), a size-3
	# electrolyzer at (31, 19) whose footprint (30..32,
	# 18..20) covers ring 2 only (consumes water but has
	# NO hasLiquids key -- the catalog gap, so the Java
	# field default false applies; it still HAS a liquids
	# store, since record_placed_block hydrates one for
	# any block with consumeLiquid rows), a size-2
	# cryofluid-mixer at ring 3 (consumes water,
	# hasLiquids true, liquidCapacity 36f), and a size-2
	# plastanium-compressor at ring 5 (consumes oil, not
	# water, hasLiquids true, liquidCapacity 60f; its
	# footprint (28..29, 22..23) also covers ring 4, so
	# the ring reports it at BOTH indices 4 and 5). A
	# copper wall at ring 7 (27, 20) is the frameless
	# neighbour; the other ring cells (index 1, (29, 19),
	# and index 6, (27, 21)) are empty. No footprints
	# overlap the pump (28..29, 20..21) or each other.
	var ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var pump_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var electrolyzer_cell := Vector2i(31, 19)
	var mixer_cell: Vector2i = ring[3]
	var compressor_cell: Vector2i = ring[5]
	var wall_cell: Vector2i = ring[7]
	for occupied in game.call("occupied_cells", pump_cell, blocks_by_id["rotary-pump"]):
		terrain_state.source_set_world_floor_state(game, occupied.x, occupied.y, shallow_water)
	var pump := Sprite2D.new()
	game.add_child(pump)
	game.call("record_placed_block", pump, blocks_by_id["rotary-pump"], pump_cell)
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(pump, blocks_by_id["rotary-pump"])
	var pump_frame: Dictionary = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(pump, true, game.get("content_catalog"))
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var electrolyzer := Sprite2D.new()
	game.add_child(electrolyzer)
	game.call("record_placed_block", electrolyzer, blocks_by_id["electrolyzer"], electrolyzer_cell)
	factory_build_state.source_factory_bind_frame_state(electrolyzer, blocks_by_id["electrolyzer"])
	var electrolyzer_frame: Dictionary = electrolyzer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	electrolyzer_frame["liquids"] = electrolyzer.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var electrolyzer_liquids: Dictionary = electrolyzer_frame.get("liquids", {})
	liquid_module_state.source_set_state(electrolyzer_liquids, water_id, 3.0)
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
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The liquid arrays fill from the live neighbour
	# frames: the cryofluid-mixer holds 5.0 water at
	# capacity 36f and consumes water with hasLiquids true
	# -- so it reports 5.0 / 36.0 / accepts true /
	# can_dump true at ring 3. The plastanium-compressor
	# holds oil only, so its WATER amount is 0.0 at both
	# of its ring indices (4 and 5) while its capacity
	# still reads 60.0. The fill returns one entry per
	# ring cell (8 entries) in each of the four arrays.
	var filled: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_neighbour_live_fill_state(game, pump_cell, 2, "water", liquid_id_by_name)
	var amounts: Array = filled.get("dump_neighbour_amounts", [])
	var capacities: Array = filled.get("dump_neighbour_capacities", [])
	var accepts: Array = filled.get("dump_neighbour_accepts", [])
	var can_dump: Array = filled.get("dump_neighbour_can_dump", [])
	proof["fill_liquid_arrays_from_live_neighbours"] = ring.size() == 8 and melter_cell == Vector2i(28, 19) and mixer_cell == Vector2i(30, 21) and compressor_cell == Vector2i(28, 22) and wall_cell == Vector2i(27, 20) and amounts.size() == 8 and capacities.size() == 8 and accepts.size() == 8 and can_dump.size() == 8 and is_equal_approx(float(amounts[3]), 5.0) and is_equal_approx(float(capacities[3]), 36.0) and bool(accepts[3]) and bool(can_dump[3]) and is_equal_approx(float(amounts[4]), 0.0) and is_equal_approx(float(amounts[5]), 0.0) and is_equal_approx(float(capacities[4]), 60.0) and is_equal_approx(float(capacities[5]), 60.0)

	# The accepts gate REQUIRES hasLiquids: the
	# electrolyzer consumes water (the catalog carries
	# the consumeLiquid row) and HAS a liquids store (it
	# holds 3.0 water at capacity 50f) but has NO
	# hasLiquids key, so the Java field default false
	# applies and it rejects water at ring 2 -- even
	# though it HAS a frame (can_dump true) and consumes
	# the dumped liquid. The melter (no hasLiquids key, no
	# consumeLiquid row) rejects too.
	proof["fill_accepts_gate_requires_has_liquids"] = not bool(accepts[2]) and bool(can_dump[2]) and is_equal_approx(float(amounts[2]), 3.0) and is_equal_approx(float(capacities[2]), 50.0) and not bool(accepts[0]) and bool(can_dump[0])

	# The accepts gate REQUIRES consumesLiquid: the
	# plastanium-compressor HAS liquids (hasLiquids true,
	# a liquids store, capacity 60f) but consumes oil, not
	# water -- so it rejects water at both of its ring
	# indices (4 and 5) while reporting can_dump true.
	# Its water amount is 0.0 (it holds oil only).
	proof["fill_accepts_gate_requires_consumes_liquid"] = not bool(accepts[4]) and not bool(accepts[5]) and bool(can_dump[4]) and bool(can_dump[5]) and is_equal_approx(float(amounts[4]), 0.0) and is_equal_approx(float(amounts[5]), 0.0)

	# The capacity fills from the neighbour def: the mixer
	# reports 36f, the compressor 60f (both from the
	# catalog liquidCapacity key), the electrolyzer 50f
	# (its store is present even though the accepts gate
	# rejects it), while the melter -- whose frame carries
	# no liquids store -- reports 0.0 (the N2371
	# no_liquids_store precedent).
	proof["fill_capacity_from_live_neighbour"] = is_equal_approx(float(capacities[3]), 36.0) and is_equal_approx(float(capacities[4]), 60.0) and is_equal_approx(float(capacities[5]), 60.0) and is_equal_approx(float(capacities[2]), 50.0) and is_equal_approx(float(capacities[0]), 0.0)

	# The no-frame outcome: the copper wall at ring 7 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, indices 1 and 6) report 0.0 / 0.0 /
	# false / false -- nothing routes there (the
	# N2353/N2371 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = is_equal_approx(float(amounts[7]), 0.0) and is_equal_approx(float(capacities[7]), 0.0) and not bool(accepts[7]) and not bool(can_dump[7]) and is_equal_approx(float(amounts[1]), 0.0) and is_equal_approx(float(capacities[1]), 0.0) and not bool(accepts[1]) and not bool(can_dump[1]) and is_equal_approx(float(amounts[6]), 0.0) and is_equal_approx(float(capacities[6]), 0.0) and not bool(accepts[6]) and not bool(can_dump[6]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the rotary-pump placed live with NO
	# seeded neighbour arrays -- the tick fills them live.
	# The pump runs the N2285/N2378 live setup
	# (shallow-water floor so the per-tick proximity scan
	# finds liquidDrop water with amount 4.0; the tick
	# driver is called directly, so the graph update does
	# not overwrite the stamped power_status). One 1/60s
	# tick is one source tick: efficiency folds the power
	# min 0.5, edelta is 0.5, maxPump is min(80 - 0,
	# 4.0 * 0.2 * 0.5) = 0.4, and then the dump runs (Java
	# order: Pump.java:178-180 after :176) against the
	# live-filled arrays: fract 0.4/80 = 0.005, transfer
	# 0.005 * 80 / 2 = 0.2 to the mixer at ring 3 (the
	# only accepting neighbour -- the melter and the
	# electrolyzer reject on hasLiquids, the compressor
	# on consumesLiquid), so the store holds 0.2 after
	# the tick and the 0.2 dumped water lands in the mixer
	# frame through the N2378 helper. The mixer water is
	# reset to 0.0 first so the transfer is exact. The
	# cursor advances once per proximity iteration over 8
	# neighbours, so it wraps (0 + 8) % 8 back to 0. The
	# frame keeps the live-filled arrays and the
	# dump_neighbour_live flag.
	liquid_module_state.source_set_state(mixer_liquids, water_id, 0.0)
	pump_frame["power_status"] = 0.5

	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	mixer_frame = mixer.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var pump_liquids: Dictionary = pump.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var mixer_live_liquids: Dictionary = mixer_frame.get("liquids", {})
	var stored_water: float = 0.0
	if water_id >= 0 and water_id < pump_liquids.get("liquids", []).size():
		stored_water = float(pump_liquids["liquids"][water_id])
	var mixer_water: float = float(liquid_module_state.source_get_state(mixer_live_liquids, water_id).get("amount", -1.0))
	var live_amounts: Array = pump_frame.get("dump_neighbour_amounts", [])
	var live_capacities: Array = pump_frame.get("dump_neighbour_capacities", [])
	var live_accepts: Array = pump_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = pump_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(stored_water, 0.2) and is_equal_approx(mixer_water, 0.2) and int(pump_frame.get("cdump", -1)) == 0 and bool(pump_frame.get("dump_neighbour_live", false)) and live_amounts.size() == 8 and live_capacities.size() == 8 and live_accepts.size() == 8 and live_can_dump.size() == 8 and bool(live_accepts[3]) and not bool(live_accepts[0]) and not bool(live_accepts[2]) and not bool(live_accepts[4]) and is_equal_approx(float(live_capacities[3]), 36.0) and bool(live_can_dump[3])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PumpDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
