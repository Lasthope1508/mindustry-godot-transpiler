extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	var item_order: Array = content_registry_runtime_state.source_item_catalog_state(catalog).get("item_names_by_id", [])

	# --- The dump neighbour live fill (N2403, DEFERRED #228):
	# N2282 ported the timerDump dump (the frame-local
	# Interval-equivalent, 5f/time_scale, BurstDrill.java:83-84)
	# -- but the two neighbour arrays stayed frame inputs
	# (default []), so a live burst drill with no fill read
	# an empty proximity and never dumped. N2360 wired the
	# neighbour write-back (the N2353 helper lands the
	# routed dump in the neighbour store) -- but with no
	# fill the routing never ran. This slice fills the two
	# arrays from the live proximity BEFORE the dump pure,
	# in ring order (index i is ring cell i, the N2353
	# convention): accepts/canDump from the DEFAULT
	# BuildingComp gates (acceptItem REQUIRES consumesItem,
	# :864-866; the canDump default is true, :1124-1126).
	# Per-block overrides are OUT of scope. The item gate
	# answers for the FIRST held item in content order --
	# the item the dump pure offers. A neighbour with no
	# frame reports the no-frame outcome (false / false).
	# The size-5 ring has 20 cells (angle-sorted): ring 0
	# is the (-3, -1) offset, so the (28, 20) drill's ring
	# 0 is (25, 19) and its ring 14 is (28, 23). The
	# neighbours here are a size-1 melter at ring 0
	# (consumes scrap, itemCapacity 10 -- the catalog
	# carries its consumeItem row) and a size-3
	# surge-smelter at ring 14 (consumes copper + lead +
	# titanium + silicon, itemCapacity 20 -- the catalog
	# carries its consumeItem rows; it is the ONLY catalog
	# def that consumes copper). The surge-smelter
	# footprint (28..30, 23..25) also covers ring 12
	# (30, 23) and ring 13 (29, 23), so the ring reports
	# it at indices 12, 13 AND 14 (Java updateProximity
	# dedupes multi-cell neighbours, but the ring
	# convention this fill mirrors does not -- a delivery
	# to either index lands in the same frame). A copper
	# wall at ring 19 (25, 20) is the frameless neighbour;
	# the other ring cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(5, 28, 20).get("cells", [])
	var drill_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var surge_cell: Vector2i = ring[14]
	var wall_cell: Vector2i = ring[19]
	var eruption := Sprite2D.new()
	game.add_child(eruption)
	for occupied in game.call("occupied_cells", drill_cell, blocks_by_id["eruption-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", eruption, blocks_by_id["eruption-drill"], drill_cell)
	drill_build_state.source_on_proximity_update_state(game, eruption, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var melter_frame: Dictionary = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame["items"] = {}
	var surge := Sprite2D.new()
	game.add_child(surge)
	# The ring variable denotes the contact; move the size-3 origin outside the source footprint.
	game.call("record_placed_block", surge, blocks_by_id["surge-smelter"], surge_cell + Vector2i(1, 1))
	factory_build_state.source_factory_bind_frame_state(surge, blocks_by_id["surge-smelter"])
	var surge_frame: Dictionary = surge.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	surge_frame["items"] = {}
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The accepts array fills from the live neighbour
	# frames: the drill holds copper only, so the offered
	# item is copper -- the surge-smelter consumes copper
	# with room (0 < 20), so it accepts at all three of its
	# ring indices (12, 13, 14), and the melter (which
	# consumes scrap, not copper) rejects. Both arrays are
	# 20 long (the size-5 ring).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = burst_drill_build_state.source_burst_drill_dump_neighbour_live_fill_state(game, drill_cell, 5, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	var copper_can_dump: Array = copper_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbours"] = ring.size() == 20 and melter_cell == Vector2i(25, 19) and surge_cell == Vector2i(28, 23) and wall_cell == Vector2i(25, 20) and copper_accepts.size() == 20 and copper_can_dump.size() == 20 and bool(copper_accepts[12]) and bool(copper_accepts[13]) and bool(copper_accepts[14]) and not bool(copper_accepts[0]) and not bool(copper_accepts[19]) and not bool(copper_accepts[1])

	# The canDump array fills from the live neighbour
	# frames: every FRAMED neighbour reports true (the
	# Java default returns true unconditionally) -- the
	# melter at 0 and the surge-smelter at 12, 13, 14 --
	# while the frameless wall at 19 and the empty ring
	# cell at 1 report false.
	proof["fill_can_dump_from_live_neighbours"] = bool(copper_can_dump[0]) and bool(copper_can_dump[12]) and bool(copper_can_dump[13]) and bool(copper_can_dump[14]) and not bool(copper_can_dump[19]) and not bool(copper_can_dump[1])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, the melter rejects (it
	# consumes scrap, not copper) while the surge-smelter
	# accepts; with scrap held, the melter accepts (0 < 10)
	# and the surge-smelter rejects (it consumes copper,
	# lead, titanium and silicon -- not scrap). Both have
	# room in both cases, so only the consumesItem half
	# decides.
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = burst_drill_build_state.source_burst_drill_dump_neighbour_live_fill_state(game, drill_cell, 5, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and bool(copper_accepts[14]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[14])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = burst_drill_build_state.source_burst_drill_dump_neighbour_live_fill_state(game, drill_cell, 5, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = burst_drill_build_state.source_burst_drill_dump_neighbour_live_fill_state(game, drill_cell, 5, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 19 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 1) report false / false --
	# nothing routes there (the N2353 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(copper_accepts[19]) and not bool(copper_can_dump[19]) and not bool(copper_accepts[1]) and not bool(copper_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the eruption-drill placed live on
	# copper ore (the N2282 live setup, power_status
	# stamped 0.5) with NO seeded dump arrays -- the tick
	# fills them live. The drill holds 5 copper with the
	# timer at 4.0, so the dump fires (4.0 + 1.0 >= 5f)
	# and routes to ring 12 -- the first accepting
	# neighbour in cursor order (the melter at 0 rejects
	# copper, rings 1-11 are empty, the surge-smelter
	# accepts at 12) -- and the dumped copper lands in the
	# surge-smelter frame through the N2353 helper. The
	# cursor advances once per neighbour checked (0..12),
	# so it stops at 13. The frame keeps the live-filled
	# arrays and the dump_neighbour_live flag.
	eruption_frame["items"] = {"copper": 5}
	eruption_frame["timer_dump_elapsed"] = 4.0
	eruption_frame["power_status"] = 0.5

	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	surge_frame = surge.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = eruption_frame.get("items", {})
	var surge_items: Dictionary = surge_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = eruption_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = eruption_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = int(live_items.get("copper", -1)) == 4 and is_equal_approx(float(eruption_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(eruption_frame.get("cdump", -1)) == 13 and int(eruption_frame.get("dominant_items", 0)) > 0 and int(surge_items.get("copper", -1)) == 1 and int(melter_items.get("copper", 0)) == 0 and bool(eruption_frame.get("dump_neighbour_live", false)) and live_accepts.size() == 20 and live_can_dump.size() == 20 and bool(live_accepts[12]) and bool(live_accepts[14]) and not bool(live_accepts[0]) and bool(live_can_dump[0]) and not bool(live_can_dump[19])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
