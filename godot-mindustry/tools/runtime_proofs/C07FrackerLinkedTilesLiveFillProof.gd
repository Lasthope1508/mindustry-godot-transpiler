extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure fill (N2414): the live linked-tile scan that
	# fills frame["proximity_linked_tiles"] (DEFERRED #247),
	# which the N2305 tick recomputes validTiles/boost from
	# each enabled tick. The linked tiles are the size x size
	# FOOTPRINT (Tile.getLinkedTiles, Tile.java:474-485 -- dx
	# outer 0..size-1, dy inner 0..size-1, at (x + dx + o,
	# y + dy + o) with o = sizeOffset = -((size - 1) / 2),
	# Block.java:762/1430), NOT a ring: for the size-3
	# oil-extractor the footprint is the 3x3 centred on the
	# origin cell, in Java walk order. Java skips null tiles
	# (`if(other != null) cons.get(other);`, Tile.java:480),
	# so a missing map entry contributes no dict. Each entry
	# is the exact N2305 dict shape ({can_pump,
	# attribute_value, is_deep}): can_pump is the canPump
	# answer (`tile != null && !tile.floor().isLiquid`,
	# SolidPump.java:80-81), attribute_value is the floor OIL
	# attribute (sumAttribute, Block.java:575-582 -- the value
	# adds whether or not the tile is pumpable), is_deep is
	# the deep-floor flag (the N2305 pure applies the deep
	# exclusion, Block.java:580, not this fill). The tile map
	# is frame["world_tiles"] (the BeamDrill N2339 pattern,
	# Dict keyed "x,y") with the MINIMAL floor extension
	# {floor_is_liquid, oil_attribute, is_deep} per tile --
	# the BeamDrill {solid, wall_drop} shape carries no floor
	# fields (SourceBeamDrillBuildState.gd:374), and no live
	# producer stamps the frame input yet (the producer gap
	# is documented, not invented here). Every pure case
	# below uses cell (10, 10) and size 3, so the footprint
	# is x 9..11, y 9..11, and Java walk order is (9,9),
	# (9,10), (9,11), (10,9), (10,10), (10,11), (11,9),
	# (11,10), (11,11).

	# Linked tiles filled from the live tile map: a full 9-tile
	# map fills 9 entries in Java walk order -- entry 0 is the
	# (9,9) tile (oil 0.9), entry 3 is the (10,9) tile (oil
	# 0.45), entry 8 is the (11,11) tile (oil 0.0).
	var full_map: Dictionary = {
		"9,9": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": false},
		"9,10": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"9,11": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"10,9": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"10,10": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"10,11": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"11,9": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"11,10": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"11,11": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
	}
	var filled_full: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state(full_map, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	proof["linked_tiles_filled_from_live_tile_map"] = filled_full.size() == 9 and is_equal_approx(float(filled_full[0].get("attribute_value", -1.0)), 0.9) and is_equal_approx(float(filled_full[3].get("attribute_value", -1.0)), 0.45) and is_equal_approx(float(filled_full[8].get("attribute_value", -1.0)), 0.0)

	# The can_pump gate requires a non-liquid floor: the
	# liquid-floor tile (9,9) reports can_pump false, the
	# dry tile (9,10) reports true -- `tile != null &&
	# !tile.floor().isLiquid` (SolidPump.java:81). The missing
	# (9,11) tile contributes no dict at all (Java skips null
	# tiles, Tile.java:480), so the fill reports 2 entries.
	var gate_map: Dictionary = {
		"9,9": {"floor_is_liquid": true, "oil_attribute": 0.9, "is_deep": false},
		"9,10": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
	}
	var filled_gate: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state(gate_map, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	proof["can_pump_gate_requires_non_liquid_floor"] = filled_gate.size() == 2 and filled_gate[0].get("can_pump", true) == false and filled_gate[1].get("can_pump", false) == true

	# Attribute values summed from the floors: oil values
	# 0.9 / 0.45 / 0.45 on three tiles fill attribute_value
	# 0.9 / 0.45 / 0.45, and the N2305 fraction pure sums
	# them to boost 0.2 (1.8 / 9). The liquid-floor tile's
	# 0.9 counts too -- sumAttribute has no canPump gate
	# (Block.java:579-580) -- so the fill carries the oil
	# attribute regardless of floor_is_liquid.
	var valued_map: Dictionary = {
		"9,9": {"floor_is_liquid": true, "oil_attribute": 0.9, "is_deep": false},
		"9,10": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"9,11": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
	}
	var filled_valued: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state(valued_map, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	var valued: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(filled_valued, 0.0)
	proof["attribute_values_summed_from_floors"] = filled_valued.size() == 3 and is_equal_approx(float(filled_valued[0].get("attribute_value", -1.0)), 0.9) and is_equal_approx(float(valued.get("boost", -1.0)), 0.2)

	# The deep flag is carried: a deep tile with oil 0.9
	# reports is_deep true, and the N2305 fraction pure
	# excludes its attribute (boost 0.0 -- !floating &&
	# !placeableLiquid, Block.java:580). The same tile
	# non-deep counts (0.9 / 9 = 0.1).
	var deep_map: Dictionary = {
		"9,9": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": true},
	}
	var filled_deep: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state(deep_map, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	var grounded: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(filled_deep, 0.0)
	var shallow_map: Dictionary = {
		"9,9": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": false},
	}
	var filled_shallow: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state(shallow_map, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	var shallow: Dictionary = fracker_build_state.source_fracker_proximity_fraction_state(filled_shallow, 0.0)
	proof["deep_flag_carried"] = filled_deep.size() == 1 and filled_deep[0].get("is_deep", false) == true and is_equal_approx(float(grounded.get("boost", -1.0)), 0.0) and is_equal_approx(float(shallow.get("boost", -1.0)), 0.1)

	# No tile map reports empty: an empty world_tiles dict
	# fills an empty list (preserving the no-fill behavior),
	# and a map with only out-of-footprint keys fills an
	# empty list too.
	var filled_empty: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state({}, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	var filled_far: Array = fracker_build_state.source_fracker_linked_tiles_live_fill_state({"50,50": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": false}}, Vector2i(10, 10), 3).get("proximity_linked_tiles", [])
	proof["no_tile_map_reports_empty"] = filled_empty.is_empty() and filled_far.is_empty()

	# --- Live tick: an oil-extractor placed live; the tick
	# driver is called directly (as the N2153/N2207 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. One 1/60s tick is one
	# source tick: efficiency folds the power min 0.5 (water
	# 0.3 seeded so the water row is 1.0, 1 sand seeded so
	# the sand row is 1.0), the fill runs BEFORE the N2305
	# recompute (Java order: onProximityUpdate stamps
	# validTiles / boost, SolidPump.java:150-159, and
	# updateTile reads them at :124), so with the tile map
	# seeding oil attribute values 0.9 / 0.45 / 0.45 (boost
	# 0.2), a deep tile excluded, and env 0.3, the frame reads
	# valid_tiles 0.0 (baseEfficiency 0f), boost 0.2, and
	# fraction 0.5 after one tick -- and the pump moves oil
	# (max_pump 0.0625 = 0.25 * 1 * 0.5 * 0.5). The tile map
	# is the frame input world_tiles, stamped here like the
	# N2228 targets precedent; proximity_linked_tiles is NOT
	# seeded, so the fill runs (supplied arrays win -- the
	# N2305 proof seeds by hand and keeps its seed).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(catalog)
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["oil-extractor"], extractor_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the tile-map input on it).
	fracker_build_state.source_fracker_bind_frame_state(extractor, blocks_by_id["oil-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, water_id, 0.3)

	extractor_frame["items"] = {"sand": 1}
	extractor_frame["power_status"] = 0.5
	extractor_frame["attribute_env"] = 0.3
	extractor_frame["world_tiles"] = {
		"27,19": {"floor_is_liquid": false, "oil_attribute": 0.9, "is_deep": false},
		"27,20": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"27,21": {"floor_is_liquid": false, "oil_attribute": 0.45, "is_deep": false},
		"28,19": {"floor_is_liquid": false, "oil_attribute": 0.0, "is_deep": false},
		"28,20": {"floor_is_liquid": false, "oil_attribute": 1.0, "is_deep": true},
	}
	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var live_filled: Array = extractor_frame.get("proximity_linked_tiles", [])
	proof["live_tick_pumps_with_fill"] = extractor_frame.get("proximity_linked_tiles_live", false) == true and live_filled.size() == 5 and is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(extractor_frame.get("valid_tiles", -1.0)), 0.0) and is_equal_approx(float(extractor_frame.get("boost", -1.0)), 0.2) and is_equal_approx(float(extractor_frame.get("fraction", -1.0)), 0.5) and float(extractor_frame.get("max_pump", 0.0)) > 0.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerLinkedTilesLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
