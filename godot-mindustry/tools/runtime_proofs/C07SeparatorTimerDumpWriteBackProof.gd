extends Node

const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const conveyor_runtime_state := preload("res://src/game/SourceConveyorRuntimeState.gd")
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

	# --- The timerDump advance exposes the routing outcome
	# (N2361): N2281 ran dump(null)
	# (BuildingComp.java:1072-1113) through the shared
	# dump_item_state routing but swallowed the outcome (only
	# items/cdump came back), so the dumped item left the
	# separator without landing in any neighbour store. Java
	# hands the item over for real: `other.handleItem(self(),
	# item);` (BuildingComp.java:1089), and handleItem is
	# `items.add(item, 1);` (BuildingComp.java:860-862). The
	# advance now exposes dump_neighbour_index (the handled
	# neighbour from dump_item_state, -1 when nothing dumped)
	# + dumped_item (the handed item, "" when nothing dumped),
	# the N2353 offload_neighbour_index precedent. The content
	# item order here is [copper, lead], the catalog order
	# Java iterates (content.items()).
	var content_item_ids: Array = ["copper", "lead"]

	# Routed: with 3 neighbours where only neighbour 1
	# accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2) and
	# hands over the first held item in content order
	# (copper 5 -> 4, lead untouched at 2).
	var routed_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var routed: Dictionary = separator_build_state.source_separator_timer_dump_state(routed_frame, 1.0, 1.0, content_item_ids, [false, true, false], [true, true, true])
	var routed_items: Dictionary = routed.get("items_after", {})
	# Refused: no neighbour accepts, so nothing dumps, the
	# index stays -1, the item stays "", and the cursor
	# full-cycles back to 0 over the 3-neighbour proximity
	# (the N2286 invariant).
	var refused: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}, 1.0, 1.0, content_item_ids, [false, false, false], [true, true, true])
	var refused_items: Dictionary = refused.get("items_after", {})
	# Not fired: the clock at 0.0 + 1.0 never reaches the
	# 5-tick threshold, so nothing dumps even with an
	# accepting neighbour.
	var not_fired: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 0.0, "cdump": 0}, 1.0, 1.0, content_item_ids, [true], [true])
	var not_fired_items: Dictionary = not_fired.get("items_after", {})
	# Empty store: the timer still fires (timer() is called
	# unconditionally in Java) and the clock resets, but
	# dump() guards on the empty store and dumps nothing.
	var emptied: Dictionary = separator_build_state.source_separator_timer_dump_state({"items": {}, "timer_dump_elapsed": 4.0, "cdump": 2}, 1.0, 1.0, content_item_ids, [true], [true])
	proof["advance_exposes_dumped_neighbour_index"] = bool(routed.get("dumped", false)) and int(routed.get("dump_neighbour_index", -9)) == 1 and str(routed.get("dumped_item", "")) == "copper" and int(routed_items.get("copper", -1)) == 4 and int(routed_items.get("lead", -1)) == 2 and int(routed.get("cursor_after", -1)) == 2 and bool(refused.get("dumped", true)) == false and int(refused.get("dump_neighbour_index", -9)) == -1 and str(refused.get("dumped_item", "x")) == "" and int(refused_items.get("copper", -1)) == 5 and int(refused.get("cursor_after", -1)) == 0 and bool(not_fired.get("fired", true)) == false and bool(not_fired.get("dumped", true)) == false and int(not_fired.get("dump_neighbour_index", -9)) == -1 and str(not_fired.get("dumped_item", "x")) == "" and int(not_fired_items.get("copper", -1)) == 5 and bool(emptied.get("fired", false)) and bool(emptied.get("dumped", true)) == false and int(emptied.get("dump_neighbour_index", -9)) == -1 and str(emptied.get("dumped_item", "x")) == "" and int(emptied.get("cursor_after", -1)) == 2

	# --- Live tick: two source separators dump in one tick
	# (the N2281 live setup: clock 4.0 at full efficiency
	# with slag-full so the liquid row folds 1.0, progress
	# 0.0 so the advance crafts nothing and the offload
	# never runs -- the timerDump path is the only item
	# movement this tick). The first dumps to ring 2 -- the
	# neighbour separator at (30, 21) -- and the copper lands
	# in its frame items (+1). The second dumps to ring 0 --
	# a copper wall with no store -- and the copper still
	# leaves the separator (own store 2 -> 1, cursor
	# advances), dropping with reason no_frame. Index i is
	# ring cell i (the N2353 convention).
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[2]
	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var separator_liquids: Dictionary = separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(separator_liquids, slag_id, 1.0)
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	separator_frame["items"] = {"copper": 2}
	separator_frame["progress"] = 0.0
	separator_frame["cdump"] = 0
	separator_frame["timer_dump_elapsed"] = 4.0
	separator_frame["dump_neighbour_accepts"] = [false, false, true, false, false, false, false, false]
	separator_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	separator_frame["power_status"] = 1.0

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_separator_cell := Vector2i(50, 30)
	var bare_separator := Sprite2D.new()
	game.add_child(bare_separator)
	game.call("record_placed_block", bare_separator, blocks_by_id["separator"], bare_separator_cell)
	separator_build_state.source_separator_bind_frame_state(bare_separator, blocks_by_id["separator"])
	var bare_frame: Dictionary = bare_separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var bare_liquids: Dictionary = bare_separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bare_liquids, slag_id, 1.0)
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["items"] = {"copper": 2}
	bare_frame["progress"] = 0.0
	bare_frame["cdump"] = 0
	bare_frame["timer_dump_elapsed"] = 4.0
	bare_frame["dump_neighbour_accepts"] = [true, false, false, false, false, false, false, false]
	bare_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	bare_frame["power_status"] = 1.0

	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = separator_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(30, 21) and is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(separator_frame.get("progress", -1.0)), 1.0 / 35.0) and int(live_items.get("copper", -1)) == 1 and int(separator_frame.get("cdump", -1)) == 3 and is_equal_approx(float(separator_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(live_neighbour_items.get("copper", -1)) == 1
	proof["live_tick_dumped_item_leaves_separator_without_frame"] = bare_cell == Vector2i(50, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and int(bare_items.get("copper", -1)) == 1 and int(bare_frame.get("cdump", -1)) == 1 and is_equal_approx(float(bare_frame.get("timer_dump_elapsed", -1.0)), 0.0) and not bare_wall.has_meta(conveyor_runtime_state.SOURCE_CONVEYOR_QUEUE_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorTimerDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
