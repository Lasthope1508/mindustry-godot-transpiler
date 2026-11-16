extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
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

	# --- The timerDump advance exposes the routed neighbour
	# (N2363): the N2289 dump runs dump(null)
	# (BuildingComp.java:1072-1113) through the shared
	# dump_item_state routing, which reports the handled
	# neighbour index + item (handled_index / handled_item)
	# -- but the advance swallowed both, so the dumped item
	# left the drill without landing in any neighbour store.
	# Java hands the item over for real:
	# `other.handleItem(self(), item);` (:1089). The advance
	# now exposes them as dump_neighbour_index / dumped_item
	# (-1 / "" when nothing dumps), and the tick wires the
	# shared neighbour write-back helper after the advance
	# (the N2353 precedent). Index i is ring cell i (the
	# source_block_proximity_cells_state ring, angle-sorted):
	# for a size-2 source at (28, 20) ring 0 is (28, 19) and
	# ring 1 is (29, 19). The content item order here is
	# [copper, lead], the catalog order Java iterates
	# (content.items()).
	var content_item_ids: Array = ["copper", "lead"]

	# Routed: with 3 neighbours where only neighbour 1
	# accepts, the dump checks neighbour 0 (refused, cursor
	# 0 -> 1) then neighbour 1 (dumped, cursor 1 -> 2) and
	# exposes index 1 + the first held item in content order
	# (copper, 5 -> 4, lead untouched).
	var routed_frame: Dictionary = {"items": {"copper": 5, "lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}
	var routed: Dictionary = beam_drill_build_state.source_beam_drill_timer_dump_state(routed_frame, 1.0, 1.0, content_item_ids, [false, true, false], [true, true, true])
	var routed_items: Dictionary = routed.get("items_after", {})
	# Single neighbour: the dump takes the only held item
	# (lead, 2 -> 1) to neighbour 0; the cursor wraps
	# ((0 + 1) % 1 == 0).
	var single: Dictionary = beam_drill_build_state.source_beam_drill_timer_dump_state({"items": {"lead": 2}, "timer_dump_elapsed": 4.0, "cdump": 0}, 1.0, 1.0, content_item_ids, [true], [true])
	var single_items: Dictionary = single.get("items_after", {})
	# Not fired: below the threshold nothing dumps and
	# nothing is exposed, even with an accepting neighbour.
	var not_fired: Dictionary = beam_drill_build_state.source_beam_drill_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 0.0, "cdump": 0}, 1.0, 1.0, content_item_ids, [true], [true])
	# No accepting neighbour: the timer fires and resets but
	# nothing dumps (the cursor walks both neighbours, 0 -> 1
	# -> 0) and nothing is exposed.
	var no_accept: Dictionary = beam_drill_build_state.source_beam_drill_timer_dump_state({"items": {"copper": 5}, "timer_dump_elapsed": 4.0, "cdump": 0}, 1.0, 1.0, content_item_ids, [false, false], [true, true])
	# Empty store: the timer fires and resets, dump() guards
	# on the empty store, and the cursor stays 2.
	var empty: Dictionary = beam_drill_build_state.source_beam_drill_timer_dump_state({"items": {}, "timer_dump_elapsed": 4.0, "cdump": 2}, 1.0, 1.0, content_item_ids, [true], [true])
	proof["advance_exposes_routed_neighbour_index"] = bool(routed.get("fired", false)) and bool(routed.get("dumped", false)) and int(routed.get("dump_neighbour_index", -9)) == 1 and str(routed.get("dumped_item", "?")) == "copper" and int(routed_items.get("copper", -1)) == 4 and int(routed_items.get("lead", -1)) == 2 and int(routed.get("cursor_after", -1)) == 2 and bool(single.get("dumped", false)) and int(single.get("dump_neighbour_index", -9)) == 0 and str(single.get("dumped_item", "?")) == "lead" and int(single_items.get("lead", -1)) == 1 and int(single.get("cursor_after", -1)) == 0 and bool(not_fired.get("fired", true)) == false and bool(not_fired.get("dumped", true)) == false and int(not_fired.get("dump_neighbour_index", -9)) == -1 and str(not_fired.get("dumped_item", "?")) == "" and bool(no_accept.get("fired", false)) and bool(no_accept.get("dumped", true)) == false and int(no_accept.get("dump_neighbour_index", -9)) == -1 and str(no_accept.get("dumped_item", "?")) == "" and int(no_accept.get("cursor_after", -1)) == 0 and bool(empty.get("fired", false)) and bool(empty.get("dumped", true)) == false and int(empty.get("dump_neighbour_index", -9)) == -1 and str(empty.get("dumped_item", "?")) == "" and int(empty.get("cursor_after", -1)) == 2

	# --- Live tick: two placed plasma-bores dump in one tick
	# (the N2289 live setup: facing_amount 1 opens the
	# shouldConsume gate, power_status 1.0 folds efficiency
	# 1.0, the clock at 4.0 fires at 4 + 1 = 5). The first
	# routes to ring 1 -- the neighbour separator at (29, 19)
	# -- and the dumped copper lands in its frame items (+1).
	# The second routes to ring 0 -- a copper wall with no
	# store -- and the copper still leaves the drill (own
	# store 5 -> 4, cursor advances), dropping with reason
	# no_frame. The tick driver is called directly (as the
	# N2289 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[1]
	var drill_cell := Vector2i(28, 20)
	var drill := Sprite2D.new()
	game.add_child(drill)
	game.call("record_placed_block", drill, blocks_by_id["plasma-bore"], drill_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(drill, blocks_by_id["plasma-bore"])
	var drill_frame: Dictionary = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["items"] = {}

	drill_frame["items"] = {"copper": 5}
	drill_frame["facing_amount"] = 1
	drill_frame["timer_dump_elapsed"] = 4.0
	drill_frame["dump_neighbour_accepts"] = [false, true, false, false, false, false, false, false]
	drill_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	drill_frame["power_status"] = 1.0

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 50, 30).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_drill_cell := Vector2i(50, 30)
	var bare_drill := Sprite2D.new()
	game.add_child(bare_drill)
	game.call("record_placed_block", bare_drill, blocks_by_id["plasma-bore"], bare_drill_cell)
	beam_drill_build_state.source_beam_drill_bind_frame_state(bare_drill, blocks_by_id["plasma-bore"])
	var bare_frame: Dictionary = bare_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["items"] = {"copper": 5}
	bare_frame["facing_amount"] = 1
	bare_frame["timer_dump_elapsed"] = 4.0
	bare_frame["dump_neighbour_accepts"] = [true, false, false, false, false, false, false, false]
	bare_frame["dump_neighbour_can_dump"] = [true, true, true, true, true, true, true, true]
	bare_frame["power_status"] = 1.0

	beam_drill_build_state.source_beam_drill_tick_buildings_state(game, 1.0 / 60.0)
	drill_frame = drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_drill.get_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY, {})
	var live_items: Dictionary = drill_frame.get("items", {})
	var live_neighbour_items: Dictionary = live_neighbour_frame.get("items", {})
	var bare_items: Dictionary = bare_frame.get("items", {})
	proof["live_tick_writes_dumped_item_to_neighbour_frame"] = live_neighbour_cell == Vector2i(29, 19) and is_equal_approx(float(drill_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("optional_efficiency", -1.0)), 0.0) and is_equal_approx(float(drill_frame.get("warmup", -1.0)), 1.0 / 60.0) and is_equal_approx(float(drill_frame.get("multiplier", -1.0)), 1.0) and is_equal_approx(float(drill_frame.get("time", -1.0)), 1.0) and int(live_items.get("copper", -1)) == 4 and int(drill_frame.get("cdump", -1)) == 2 and is_equal_approx(float(drill_frame.get("timer_dump_elapsed", -1.0)), 0.0) and int(live_neighbour_items.get("copper", -1)) == 1
	proof["live_tick_dumped_item_leaves_drill_without_frame"] = bare_cell == Vector2i(50, 29) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and int(bare_items.get("copper", -1)) == 4 and int(bare_frame.get("cdump", -1)) == 1 and is_equal_approx(float(bare_frame.get("timer_dump_elapsed", -1.0)), 0.0) and not bare_wall.has_meta(beam_drill_build_state.SOURCE_BEAM_DRILL_BUILDING_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillTimerDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
