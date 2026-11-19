extends Node

const main_scene := preload("res://scenes/Main.tscn")
const item_bridge_build_state := preload("res://src/game/SourceItemBridgeBuildState.gd")
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

	# --- The dump neighbour live fill (N2404, DEFERRED #238):
	# N2288 ported the unlinked-branch doDump
	# (dumpAccumulate(), ItemBridge.java:350-353) -- but the
	# neighbour acceptItem/canDump arrays stayed frame inputs
	# (default []), so a live bridge with no fill read an
	# empty proximity and never dumped. N2362 wired the
	# neighbour write-back (the N2353 helper lands the routed
	# dump in the neighbour store) -- but with no fill the
	# routing never ran. This slice fills the two arrays from
	# the live proximity BEFORE the doDump pure, in ring order
	# (index i is ring cell i, the N2353 convention): accepts /
	# canDump from the DEFAULT BuildingComp gates (acceptItem
	# REQUIRES consumesItem, :864-866; the canDump default is
	# true, :1124-1126). Per-block overrides are OUT of scope.
	# The item gate answers for the FIRST held item in content
	# order -- the item the dump pure offers. A neighbour with
	# no frame reports the no-frame outcome (false / false).
	# The size-1 ring has 4 cells (angle-sorted, edges only):
	# ring 0 is the (0, -1) offset, so the (28, 20) bridge's
	# ring 0 is (28, 19), ring 1 is (29, 20), ring 2 is
	# (28, 21), and ring 3 is (27, 20). The neighbours here
	# are a size-1 melter at ring 0 (consumes scrap,
	# itemCapacity 10 -- the catalog carries its consumeItem
	# row) and a multi-press at ring 2 (consumes coal,
	# itemCapacity 20 -- the catalog carries its consumeItem
	# row). A copper wall at ring 3 is the frameless
	# neighbour; ring 1 is empty.
	var ring: Array = block_geometry.source_block_proximity_cells_state(1, 28, 20).get("cells", [])
	var bridge_cell := Vector2i(28, 20)
	var melter_cell: Vector2i = ring[0]
	var press_cell: Vector2i = ring[2]
	var wall_cell: Vector2i = ring[3]
	var bridge := Sprite2D.new()
	game.add_child(bridge)
	game.call("record_placed_block", bridge, blocks_by_id["phase-conveyor"], bridge_cell)
	item_bridge_build_state.source_item_bridge_bind_frame_state(bridge, blocks_by_id["phase-conveyor"])
	var bridge_frame: Dictionary = bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	var melter := Sprite2D.new()
	game.add_child(melter)
	game.call("record_placed_block", melter, blocks_by_id["melter"], melter_cell)
	factory_build_state.source_factory_bind_frame_state(melter, blocks_by_id["melter"])
	var melter_frame: Dictionary = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame["items"] = {}
	var press := Sprite2D.new()
	game.add_child(press)
	# The ring variable denotes the contact; move the size-3 origin outside the source footprint.
	game.call("record_placed_block", press, blocks_by_id["multi-press"], press_cell + Vector2i(0, 1))
	factory_build_state.source_factory_bind_frame_state(press, blocks_by_id["multi-press"])
	var press_frame: Dictionary = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	press_frame["items"] = {}
	var wall := Sprite2D.new()
	game.add_child(wall)
	game.call("record_placed_block", wall, blocks_by_id["copper-wall"], wall_cell)

	# The accepts array fills from the live neighbour frames:
	# the bridge holds coal only, so the offered item is coal
	# -- the multi-press consumes coal with room (0 < 20), so
	# it accepts at ring 2, and the melter (which consumes
	# scrap, not coal) rejects at ring 0. Both arrays are 4
	# long (the size-1 ring).
	var coal_frame: Dictionary = {"items": {"coal": 3}}
	var coal_fill: Dictionary = item_bridge_build_state.source_item_bridge_dump_neighbour_live_fill_state(game, bridge_cell, 1, coal_frame, item_order)
	var coal_accepts: Array = coal_fill.get("dump_neighbour_accepts", [])
	var coal_can_dump: Array = coal_fill.get("dump_neighbour_can_dump", [])
	proof["fill_accepts_from_live_neighbour"] = ring.size() == 4 and melter_cell == Vector2i(28, 19) and press_cell == Vector2i(28, 21) and wall_cell == Vector2i(27, 20) and coal_accepts.size() == 4 and coal_can_dump.size() == 4 and bool(coal_accepts[2]) and not bool(coal_accepts[0])

	# The canDump array fills from the DEFAULT gate (true for
	# every framed neighbour): the melter and the press both
	# report true even though the melter rejects coal -- the
	# canDump default is unconditional. The empty ring cell
	# (ring 1) and the frameless wall (ring 3) report false.
	proof["fill_can_dump_from_live_neighbour"] = bool(coal_can_dump[0]) and bool(coal_can_dump[2]) and not bool(coal_can_dump[1]) and not bool(coal_can_dump[3])

	# The accepts gate REQUIRES consumesItem, not just
	# capacity: with copper held, neither neighbour accepts
	# (the melter consumes scrap, the press consumes coal --
	# both have room, but neither consumes copper); with
	# scrap held, the melter accepts (0 < 10) and the press
	# rejects (it consumes coal, not scrap).
	var copper_frame: Dictionary = {"items": {"copper": 3}}
	var copper_fill: Dictionary = item_bridge_build_state.source_item_bridge_dump_neighbour_live_fill_state(game, bridge_cell, 1, copper_frame, item_order)
	var copper_accepts: Array = copper_fill.get("dump_neighbour_accepts", [])
	var scrap_frame: Dictionary = {"items": {"scrap": 3}}
	var scrap_fill: Dictionary = item_bridge_build_state.source_item_bridge_dump_neighbour_live_fill_state(game, bridge_cell, 1, scrap_frame, item_order)
	var scrap_accepts: Array = scrap_fill.get("dump_neighbour_accepts", [])
	proof["fill_accepts_gate_requires_consumes_item"] = not bool(copper_accepts[0]) and not bool(copper_accepts[2]) and bool(scrap_accepts[0]) and not bool(scrap_accepts[2])

	# The accepts gate REQUIRES room: the melter consumes
	# scrap, but at 10 scrap (its itemCapacity) it is full
	# (10 < 10 is false), so it rejects; at 9 it accepts.
	# The melter frame is restored to empty afterwards so
	# the live tick below starts clean.
	melter_frame["items"] = {"scrap": 10}
	var full_fill: Dictionary = item_bridge_build_state.source_item_bridge_dump_neighbour_live_fill_state(game, bridge_cell, 1, scrap_frame, item_order)
	var full_accepts: Array = full_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {"scrap": 9}
	var room_fill: Dictionary = item_bridge_build_state.source_item_bridge_dump_neighbour_live_fill_state(game, bridge_cell, 1, scrap_frame, item_order)
	var room_accepts: Array = room_fill.get("dump_neighbour_accepts", [])
	melter_frame["items"] = {}
	proof["fill_accepts_gate_requires_capacity"] = not bool(full_accepts[0]) and bool(room_accepts[0])

	# The no-frame outcome: the copper wall at ring 3 (no
	# frame on its sprite) and the empty ring cell (no sprite
	# at all, ring 1) report false / false -- nothing routes
	# there (the N2353/N2371 no-frame precedent).
	proof["fill_no_frame_neighbour_reports_empty"] = not bool(coal_accepts[3]) and not bool(coal_can_dump[3]) and not bool(coal_accepts[1]) and not bool(coal_can_dump[1]) and not wall.has_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY)

	# --- Live tick: the phase-conveyor is placed live and
	# unlinked (link -1, had_valid_link false), with 5 coal
	# in its frame items and NO seeded dump arrays -- the
	# tick fills them live. One 1/60s tick is one source
	# tick: the shouldConsume gate is closed while unlinked
	# (ItemBridge.java:495-496), so efficiency folds 0
	# (potential 0.5, the power min); warmup is 0f
	# (ItemBridge.java:337); and the unlinked branch dumps
	# 1 coal to the press at ring 2 (5 -> 4), spending the
	# accumulator (0.9 + 1.0 -> 0.9 after the one attempt)
	# with the cursor walking 0 -> 3 (the scan checks ring
	# 0, which rejects coal, then ring 1, which is empty,
	# then ring 2, which accepts). The dumped coal lands in
	# the press frame through the N2353 helper; the melter
	# takes nothing (it rejects coal). The frame keeps the
	# live-filled arrays and the dump_neighbour_live flag.
	bridge_frame["power_status"] = 0.5
	bridge_frame["items"] = {"coal": 5}
	bridge_frame["dump_accum"] = 0.9

	item_bridge_build_state.source_item_bridge_tick_buildings_state(game, 1.0 / 60.0)
	bridge_frame = bridge.get_meta(item_bridge_build_state.SOURCE_ITEM_BRIDGE_BUILDING_META_KEY, {})
	press_frame = press.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	melter_frame = melter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	var live_items: Dictionary = bridge_frame.get("items", {})
	var press_items: Dictionary = press_frame.get("items", {})
	var melter_items: Dictionary = melter_frame.get("items", {})
	var live_accepts: Array = bridge_frame.get("dump_neighbour_accepts", [])
	var live_can_dump: Array = bridge_frame.get("dump_neighbour_can_dump", [])
	proof["live_tick_dumps_with_live_fill"] = is_equal_approx(float(bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(bridge_frame.get("potential_efficiency", -1.0)), 0.5) and is_equal_approx(float(bridge_frame.get("warmup", -1.0)), 0.0) and bool(bridge_frame.get("had_valid_link", true)) == false and int(live_items.get("coal", -1)) == 4 and int(press_items.get("coal", -1)) == 1 and int(melter_items.get("coal", 0)) == 0 and int(bridge_frame.get("cdump", -1)) == 3 and is_equal_approx(float(bridge_frame.get("dump_accum", -1.0)), 0.9) and bool(bridge_frame.get("dump_neighbour_live", false)) and bool(live_accepts[2]) and not bool(live_accepts[0]) and bool(live_can_dump[2]) and not bool(live_can_dump[1])

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemBridgeDumpNeighbourLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
