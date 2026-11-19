extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var item_order: Array = content_registry_state.source_item_catalog_state(catalog).get("item_names_by_id", [])

	# --- The dump neighbour live fill (N2402, DEFERRED #226):
	# N2281 ported the timerDump dump (the frame-local
	# Interval-equivalent, dumpTime 5f / timeScale,
	# Separator.java:165-166, dump(null) through the shared
	# dump_item_state routing) -- but the two neighbour
	# arrays stayed frame inputs (default []), so a live
	# separator with no fill read an empty proximity and
	# never dumped. N2343 wired the offload neighbour
	# routing and N2353/N2361 wired the neighbour
	# write-backs -- but with no fill the routing never ran.
	# This slice fills the two arrays from the live
	# proximity BEFORE the timerDump dump reads them, in
	# ring order (index i is ring cell i, the N2353
	# convention): accepts/canDump from the DEFAULT
	# BuildingComp gates (acceptItem REQUIRES consumesItem,
	# :864-866; the canDump default is true, :1124-1126).
	# Per-block overrides are OUT of scope. The item gate
	# answers for the FIRST held item in content order --
	# the item the dump pure offers. A neighbour with no
	# frame reports the no-frame outcome (false / false).
	# The size-2 ring has 8 cells (angle-sorted): ring 0 is
	# the (0, -1) offset, so the (28, 21) separator's ring 0
	# is (28, 20) and its ring 2 is (30, 21). The neighbours
	# here are a size-1 melter at ring 0 (consumes scrap,
	# itemCapacity 10 -- the catalog carries its consumeItem
	# row) and a size-3 multi-press at ring 2 (consumes coal,
	# itemCapacity 20 -- the catalog carries its consumeItem
	# row). The multi-press footprint (30..32, 21..23) also
	# covers ring 3 (30, 22), so the ring reports it at BOTH
	# indices 2 and 3 (Java updateProximity dedupes
	# multi-cell neighbours, but the ring convention this
	# fill mirrors does not -- a delivery to either index
	# lands in the same frame). A copper wall at ring 7
	# (27, 21) is the frameless neighbour; the other ring
	# cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 21).get("cells", [])
	var separator_cell := Vector2i(28, 21)
	var melter_cell: Vector2i = ring[0]
	var press_cell: Vector2i = ring[2]
	var wall_cell: Vector2i = ring[7]
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var melter_frame: Dictionary = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame["items"] = {}
	var press := Sprite2D.new()
	game.add_child(press)
	# The ring variable denotes the contact; move the size-3 origin outside the source footprint.
	game.call("record_placed_block", press, blocks_by_id["multi-press"], press_cell + Vector2i(1, 0))
	factory_build_state.source_factory_bind_frame_state(press, blocks_by_id["multi-press"])
	var press_frame: Dictionary = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame["items"] = {}
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The accepts array fills from the live neighbour frames:
	# with scrap held, the melter accepts at ring 0 (it
	# consumes scrap with room, 0 < 10) and the multi-press
	# rejects at both of its ring indices (it consumes coal,
	# not scrap); with coal held, the press accepts at both
	# indices 2 and 3 and the melter rejects. Both arrays are
	# 8 long (the size-2 ring).
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = separator_build_state.source_separator_dump_neighbour_live_fill_state(game, separator_cell, 2, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	var scrap_can_dump: Array = scrap_fill.get("dump_neighbour_can_dump", [])
	var coal_frame: Dictionary = {"items": {"coal": 3}}
	var coal_fill: Dictionary = separator_build_state.source_separator_dump_neighbour_live_fill_state(game, separator_cell, 2, coal_frame, item_order)
	var coal_accepts: Array = coal_fill.get("dump_neighbour_accepts", [])
	var coal_can_dump: Array = coal_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbours"] = ring.size() == 8 and melter_cell == Vector2i(28, 20) and press_cell == Vector2i(30, 21) and wall_cell == Vector2i(27, 21) and scrap_accepts.size() == 8 and scrap_can_dump.size() == 8 and coal_accepts.size() == 8 and coal_can_dump.size() == 8 and bool(scrap_accepts[0]) and not bool(scrap_accepts[2]) and not bool(scrap_accepts[3]) and bool(coal_accepts[2]) and bool(coal_accepts[3]) and not bool(coal_accepts[0])

	# The canDump array fills from the live neighbour frames:
	# every FRAMED neighbour reports true (the Java default
	# is unconditional) -- the melter at ring 0 and the press
	# at both indices 2 and 3 -- while the frameless wall at
	# ring 7 and the empty ring cell at index 1 report false.
	proof["fill_can_dump_from_live_neighbours"] = bool(scrap_can_dump[0]) and bool(scrap_can_dump[2]) and bool(scrap_can_dump[3]) and not bool(scrap_can_dump[7]) and not bool(scrap_can_dump[1]) and bool(coal_can_dump[0]) and bool(coal_can_dump[2]) and not bool(coal_can_dump[7])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = separator_build_state.source_separator_dump_neighbour_live_fill_state(game, separator_cell, 2, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and not bool(copper_accepts[2]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[2])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = separator_build_state.source_separator_dump_neighbour_live_fill_state(game, separator_cell, 2, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = separator_build_state.source_separator_dump_neighbour_live_fill_state(game, separator_cell, 2, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 7 (no
	# frame on its sprite) and the empty ring cell at index
	# 1 (no sprite at all) report false / false -- nothing
	# routes there (the N2353/N2371 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(scrap_accepts[7]) and not bool(scrap_can_dump[7]) and not bool(scrap_accepts[1]) and not bool(scrap_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the separator is placed live with NO
	# seeded dump arrays (the N2281 live setup: clock 4.0 at
	# full efficiency with slag-full so the liquid row folds
	# 1.0, progress 0.0 so the advance crafts nothing and
	# the offload never runs -- the timerDump path is the
	# only item movement this tick). The tick fills the two
	# arrays live, the clock fires (4 + 1 = 5), and one
	# scrap leaves the store (5 -> 4) to the melter at ring
	# 0 (the first accepting neighbour from the cdump
	# cursor), landing in the melter frame through the N2361
	# write-back; the press takes nothing (it rejects scrap)
	# and the cursor advances 0 -> 1. The frame keeps the
	# live-filled arrays and the dump_neighbour_live flag.
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)

	separator_frame["items"] = {"scrap": 5}
	separator_frame["timer_dump_elapsed"] = 4.0
	separator_frame["power_status"] = 1.0
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = separator_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var live_accepts: Array = separator_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = separator_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 1.0 / 35.0) and int(live_items.get("scrap", -1)) == 4 and int(melter_items.get("scrap", -1)) == 1 and int(press_items.get("scrap", 0)) == 0 and int(separator_frame.get("cdump", -1)) == 1 and is_equal_approx(float(separator_frame.get("timer_dump_elapsed", -1.0)), 0.0) and bool(separator_frame.get("dump_neighbour_live", false)) and bool(live_accepts[0]) and not bool(live_accepts[2]) and bool(live_can_dump[0]) and bool(live_can_dump[2]) and not bool(live_can_dump[7])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
