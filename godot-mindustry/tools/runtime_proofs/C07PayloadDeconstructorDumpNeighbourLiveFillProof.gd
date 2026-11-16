extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_deconstructor_build_state := preload("res://src/game/SourcePayloadDeconstructorBuildState.gd")
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

	# --- The dump neighbour live fill (N2407, DEFERRED #217):
	# N2276 ported the dump rows (dumpRate 4 x
	# dumpAccumulate() at the top of updateTile,
	# PayloadDeconstructor.java:111-115, BEFORE the
	# deconstructing progress block, :117+) -- but the two
	# neighbour arrays stayed frame inputs (default []), so
	# a live deconstructor with no fill read an empty
	# proximity and never dumped. N2368 wired the neighbour
	# write-back (the N2353 item helper) -- but with no fill
	# the routing never ran. This slice fills the two arrays
	# from the live proximity BEFORE the dump pure, in ring
	# order (index i is ring cell i, the N2353 convention):
	# accepts/canDump from the DEFAULT BuildingComp gates
	# (acceptItem REQUIRES consumesItem, :864-866; the
	# canDump default is true, :1124-1126). Per-block
	# overrides are OUT of scope. The item gate answers for
	# the FIRST held item in content order -- the item the
	# dump pure offers. A neighbour with no frame reports
	# the no-frame outcome (false / false). The size-5 ring
	# has 20 cells (angle-sorted): ring 0 is the (-3, -1)
	# offset, so the (28, 21) deconstructor's ring 0 is
	# (25, 20) and its ring 5 is (29, 18). The neighbours
	# here are a size-1 melter at ring 0 (consumes scrap,
	# itemCapacity 10 -- the catalog carries its consumeItem
	# row) and a size-3 multi-press at ring 5 (consumes
	# coal, itemCapacity 20 -- the catalog carries its
	# consumeItem row; size 3, Blocks.java:1059). The
	# multi-press footprint (28..30, 17..19) also covers
	# ring 4 (28, 18) and ring 6 (30, 18), so the ring
	# reports it at THREE indices 4, 5 and 6 (Java
	# updateProximity dedupes multi-cell neighbours, but
	# the ring convention this fill mirrors does not -- a
	# delivery to any index lands in the same frame). A
	# copper wall at ring 11 (31, 23) is the frameless
	# neighbour; the other ring cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(5, 28, 21).get("cells", [])
	var deconstructor_cell := Vector2i(28, 21)
	var melter_cell: Vector2i = ring[0]
	var press_cell: Vector2i = ring[5]
	var wall_cell: Vector2i = ring[11]
	var deconstructor := Sprite2D.new()
	game.add_child(deconstructor)
	game.call("record_placed_block", deconstructor, blocks_by_id["deconstructor"], deconstructor_cell)
	payload_deconstructor_build_state.source_payload_deconstructor_bind_frame_state(deconstructor, blocks_by_id["deconstructor"])
	var deconstructor_frame: Dictionary = deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
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
	# frames: the deconstructor holds coal only, so the
	# offered item is coal -- the multi-press consumes coal
	# with room (0 < 20), so it accepts at all three of its
	# ring indices (4, 5 and 6), and the melter (which
	# consumes scrap, not coal) rejects. Both arrays are 20
	# long (the size-5 ring).
	var coal_frame: Dictionary = {"items": {"coal": 3}}
	var coal_fill: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(game, deconstructor_cell, 5, coal_frame, item_order)
	var coal_accepts: Array = coal_fill.get("dump_neighbour_accepts", [])
	var coal_can_dump: Array = coal_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbour"] = ring.size() == 20 and melter_cell == Vector2i(25, 20) and press_cell == Vector2i(29, 18) and wall_cell == Vector2i(31, 23) and coal_accepts.size() == 20 and coal_can_dump.size() == 20 and bool(coal_accepts[4]) and bool(coal_accepts[5]) and bool(coal_accepts[6]) and not bool(coal_accepts[0]) and not bool(coal_accepts[11]) and not bool(coal_accepts[1])

	# The canDump array fills from the live neighbour
	# frames: every FRAMED neighbour reports true (the
	# canDump default is unconditional) -- the melter at
	# ring 0 (which rejects coal but still canDump) and the
	# press at 4, 5 and 6 -- while the frameless wall at
	# ring 11 and the empty ring cell at index 1 report
	# false (no building to dump to).
	proof["fill_can_dump_from_live_neighbour"] = bool(coal_can_dump[0]) and bool(coal_can_dump[4]) and bool(coal_can_dump[5]) and bool(coal_can_dump[6]) and not bool(coal_can_dump[11]) and not bool(coal_can_dump[1])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(game, deconstructor_cell, 5, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(game, deconstructor_cell, 5, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and not bool(copper_accepts[5]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[5])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(game, deconstructor_cell, 5, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = payload_deconstructor_build_state.source_payload_deconstructor_dump_neighbour_live_fill_state(game, deconstructor_cell, 5, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 11 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 1) report false / false --
	# nothing routes there (the N2353/N2371 no-frame
	# precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(coal_accepts[11]) and not bool(coal_can_dump[11]) and not bool(coal_accepts[1]) and not bool(coal_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the payload-deconstructor placed live
	# with NO deconstructing payload (the N2276 live setup:
	# the shouldConsume gate is false, so efficiency folds
	# to 0.0 -- and the dump STILL runs, because the dump
	# rows are unconditional, PayloadDeconstructor.java:
	# 111-115) and NO seeded dump arrays -- the tick fills
	# them live. The deconstructor holds 5 coal; the dump
	# fires 4 times (dump_accum 0.9 + 4 * 1.0, one attempt
	# per call) to the press at ring 4, then 5, then 6,
	# then 4 again (the cursor walks: 0 -> 5 -> 6 -> 7 ->
	# 5) -- all 4 land in the press frame through the N2353
	# helper. The melter takes nothing (it rejects coal).
	# The frame keeps the live-filled arrays and the
	# dump_neighbour_live flag.
	deconstructor_frame["power_status"] = 1.0
	deconstructor_frame["items"] = {"coal": 5}
	deconstructor_frame["dump_accum"] = 0.9

	payload_deconstructor_build_state.source_payload_deconstructor_tick_buildings_state(game, 1.0 / 60.0)
	deconstructor_frame = deconstructor.get_meta(payload_deconstructor_build_state.SOURCE_PAYLOAD_DECONSTRUCTOR_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = deconstructor_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = deconstructor_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = deconstructor_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(deconstructor_frame.get("efficiency", -1.0)), 0.0) and int(live_items.get("coal", -1)) == 1 and int(press_items.get("coal", -1)) == 4 and int(melter_items.get("coal", 0)) == 0 and int(deconstructor_frame.get("cdump", -1)) == 5 and is_equal_approx(float(deconstructor_frame.get("dump_accum", -1.0)), 0.9) and bool(deconstructor_frame.get("dump_neighbour_live", false)) and bool(live_accepts[4]) and bool(live_accepts[5]) and bool(live_accepts[6]) and not bool(live_accepts[0]) and bool(live_can_dump[0])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadDeconstructorDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
