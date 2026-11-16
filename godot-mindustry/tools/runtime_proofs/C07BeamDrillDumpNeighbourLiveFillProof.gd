extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- The dump neighbour live fill (N2405, DEFERRED #240):
	# N2289 ported the timerDump dump (dumpTime 5f /
	# timeScale, BeamDrill.java:264-266, dump(null) through
	# the shared dump_item_state routing) -- but the
	# neighbour accept/canDump arrays stayed frame inputs
	# (default []), so a live beam drill with no fill read
	# an empty proximity and never dumped. N2363 wired the
	# neighbour write-back (the N2353 helper lands the
	# routed dump in the neighbour store) -- but with no
	# fill the routing never ran. This slice fills the two
	# arrays from the live proximity BEFORE the dump pure,
	# in ring order (index i is ring cell i, the N2353
	# convention), the N2394 pattern: accepts from the
	# DEFAULT BuildingComp acceptItem gate (acceptItem
	# REQUIRES consumesItem, :864-866), canDump from the
	# default true (:1124-1126). Per-block overrides are OUT
	# of scope. The item gate answers for the FIRST held
	# item in content order -- the item the dump pure
	# offers. A neighbour with no frame reports the
	# no-frame outcome (false / false). The size-2 ring has
	# 8 cells (angle-sorted): ring 0 is the (0, -1) offset,
	# so the (28, 20) drill's ring 0 is (28, 19) and its
	# ring 2 is (30, 20). The neighbours here are a size-1
	# melter at ring 0 (consumes scrap, itemCapacity 10 --
	# the catalog carries its consumeItem row) and a size-3
	# multi-press at ring 2 (consumes coal, itemCapacity 20
	# -- the catalog carries its consumeItem row). The
	# multi-press footprint (30..32, 20..22) also covers
	# ring 3 (30, 21), so the ring reports it at BOTH
	# indices 2 and 3 (Java updateProximity dedupes
	# multi-cell neighbours, but the ring convention this
	# fill mirrors does not -- a delivery to either index
	# lands in the same frame). A copper wall at ring 7
	# (27, 20) is the frameless neighbour; the other ring
	# cells are empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var drill_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var press_cell: Vector2i = ring[2]
	var wall_cell: Vector2i = ring[7]
	var drill := Sprite2D.new()
	game.add_child(drill)
	game.call("record_placed_block", drill, blocks_by_id["plasma-bore"], drill_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
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
	# frames: the drill holds coal only, so the offered item
	# is coal -- the multi-press consumes coal with room
	# (0 < 20), so it accepts at both indices 2 and 3, and
	# the melter (which consumes scrap, not coal) rejects.
	# Both arrays are 8 long (the size-2 ring).
	var coal_frame: Dictionary = {"items": {"coal": 3}}
	var coal_fill: Dictionary = beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(game, drill_cell, 2, coal_frame, item_order)
	var coal_accepts: Array = coal_fill.get("dump_neighbour_accepts", [])
	var coal_can_dump: Array = coal_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbours"] = ring.size() == 8 and melter_cell == Vector2i(28, 19) and press_cell == Vector2i(30, 20) and wall_cell == Vector2i(27, 20) and coal_accepts.size() == 8 and coal_can_dump.size() == 8 and bool(coal_accepts[2]) and bool(coal_accepts[3]) and not bool(coal_accepts[0])

	# The canDump array fills from the DEFAULT true: every
	# framed neighbour reports true -- the melter at ring 0
	# (it rejects coal, but canDump is unconditional) and
	# the press at rings 2 and 3 -- while the empty ring 1
	# and the frameless wall at ring 7 report false.
	proof["fill_can_dump_from_live_neighbours"] = bool(coal_can_dump[0]) and bool(coal_can_dump[2]) and bool(coal_can_dump[3]) and not bool(coal_can_dump[1]) and not bool(coal_can_dump[7])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(game, drill_cell, 2, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(game, drill_cell, 2, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and not bool(copper_accepts[2]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[2])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(game, drill_cell, 2, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = beam_drill_build_state.source_beam_drill_dump_neighbour_live_fill_state(game, drill_cell, 2, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 7 (no
	# frame on its sprite) and the empty ring cells (no
	# sprite at all, e.g. index 1) report false / false --
	# nothing routes there (the N2353/N2371 no-frame
	# precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(coal_accepts[7]) and not bool(coal_can_dump[7]) and not bool(coal_accepts[1]) and not bool(coal_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the plasma-bore placed live with NO
	# seeded dump arrays -- the tick fills them live. The
	# drill holds 5 coal; the timer clock at 4.0 fires
	# (4 + 1 = 5), so one coal leaves the store (5 -> 4) to
	# the first accepting neighbour: the melter at ring 0
	# rejects coal (cursor 0 -> 1), the empty ring 1
	# rejects (cursor 1 -> 2), the press at ring 2 accepts
	# (cursor 2 -> 3) and the coal lands in the press frame
	# through the N2363 write-back. The melter takes
	# nothing. The frame keeps the live-filled arrays and
	# the dump_neighbour_live flag. The efficiency fold
	# reads the seeded facing_amount 1 (the scan recomputes
	# it after the fold, the N2339 order), so efficiency
	# folds 1.0 like the N2289 live tick.
	drill_frame["items"] = {"coal": 5}
	drill_frame["facing_amount"] = 1
	drill_frame["timer_dump_elapsed"] = 4.0
	drill_frame["power_status"] = 1.0

	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = drill_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = drill_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = drill_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(drill_frame.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("time", -1.0)), 1.0) and int(live_items.get("coal", -1)) == 4 and int(drill_frame.get("cdump", -1)) == 3 and is_equal_approx(float(drill_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(press_items.get("coal", -1)) == 1 and int(melter_items.get("coal", 0)) == 0 and bool(drill_frame.get("dump_neighbour_live", false)) and bool(live_accepts[2]) and not bool(live_accepts[0]) and bool(live_can_dump[2]) and not bool(live_can_dump[1])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
