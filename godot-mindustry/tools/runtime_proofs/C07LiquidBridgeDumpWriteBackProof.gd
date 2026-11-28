extends Node

const main_scene := preload("res://scenes/Main.tscn")
const liquid_bridge_build_state := preload("res://src/game/SourceLiquidBridgeBuildState.gd")
const building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))

	# --- The doDump pure exposes the handled neighbour +
	# the dumped liquid (N2379, the N2371 Fracker
	# precedent): dump_neighbour_index is the shared
	# routing's handled_index -- the FIRST eligible
	# neighbour whose transfer actually moved liquid
	# (handle_liquid_called AND flow > 0), -1 when nothing
	# moved -- and dumped_liquid_id is the module current
	# id (the dumped liquid is liquids.current(),
	# LiquidBridge.java:30). The pure has no catalog, so
	# it exposes the id and the tick resolves the name
	# through liquid_names_by_id (catalog order, index =
	# liquid id, the PayloadLoader precedent) before
	# calling the shared helper. Liquid stores are module
	# states (amounts array by liquid id + current id,
	# LiquidModule.java:24/81-83): liquid 0 is water, the
	# dumped liquid. liquidCapacity is the def constant
	# 100f (Blocks.java:2395), scaling 1f
	# (LiquidBridge.java:30).
	var frame_zero: Dictionary = {"cdump": 0}
	var one_neighbour: Dictionary = {"amounts": [20.0], "capacities": [100.0], "accepts": [true]}
	var transferred: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	var transferred_amounts: Array = (transferred.get("liquids_after", {}) as Dictionary).get("liquids", [])
	# A fuller neighbour (ofract above fract) takes
	# nothing; a refusing neighbour (acceptLiquid false)
	# takes nothing either -- and is NOT the handled index
	# even though it computes a flow, so a [refusing,
	# empty] pair reports index 1 and dumps 50 to the
	# second neighbour ((0.5 - 0.0) * 100 / 1).
	var fuller: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [80.0], "capacities": [100.0], "accepts": [true]})
	var refused: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [20.0], "capacities": [100.0], "accepts": [false]})
	var pair: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [20.0, 0.0], "capacities": [100.0, 100.0], "accepts": [false, true]})
	var pair_amounts: Array = (pair.get("liquids_after", {}) as Dictionary).get("liquids", [])
	# Two neighbours take 40 + 50 = 90 (the fraction
	# recomputes from the running amount) and report the
	# FIRST index only -- the multi-recipient split
	# defers (the N2371 follow-ups entry). With no
	# neighbours nothing moves and the cursor stays 0.
	var multi: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [90.0], "current": 0, "flow": null}, 100.0, {"amounts": [50.0, 0.0], "capacities": [100.0, 100.0], "accepts": [true, true]})
	var alone: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, {"amounts": [], "capacities": [], "accepts": []})
	# Linked, the same stores dump nothing and the cursor
	# is untouched even with a stale cdump -- but the
	# dumped liquid id is still the current id (the pure
	# reports what WOULD dump). At or below the 0.0001f
	# threshold nothing runs (BuildingComp.java:889). With
	# no current liquid there is no id to report (-1).
	var linked_frame: Dictionary = {"cdump": 2}
	var linked: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(linked_frame, true, {"liquids": [50.0], "current": 0, "flow": null}, 100.0, one_neighbour)
	var threshold_frame: Dictionary = {"cdump": 2}
	var threshold: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(threshold_frame, false, {"liquids": [0.0001], "current": 0, "flow": null}, 100.0, one_neighbour)
	var no_current: Dictionary = liquid_bridge_build_state.source_liquid_bridge_do_dump_state(frame_zero, false, {"liquids": [50.0], "current": -1, "flow": null}, 100.0, one_neighbour)
	proof["advance_exposes_dump_neighbour_index"] = water_id == 0 and is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 30.0) and is_equal_approx(float(transferred_amounts[0]), 20.0) and int(transferred.get("dump_neighbour_index", -9)) == 0 and int(transferred.get("dumped_liquid_id", -9)) == 0 and int(transferred.get("cursor_after", -1)) == 0 and is_equal_approx(float(fuller.get("dumped_amount", -1.0)), 0.0) and int(fuller.get("dump_neighbour_index", -9)) == -1 and int(fuller.get("dumped_liquid_id", -9)) == 0 and int(fuller.get("cursor_after", -1)) == 0 and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and int(refused.get("dump_neighbour_index", -9)) == -1 and int(refused.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_amount", -1.0)), 50.0) and is_equal_approx(float(pair_amounts[0]), 0.0) and int(pair.get("dump_neighbour_index", -9)) == 1 and int(pair.get("dumped_liquid_id", -9)) == 0 and int(pair.get("cursor_after", -1)) == 0 and is_equal_approx(float(multi.get("dumped_amount", -1.0)), 90.0) and int(multi.get("dump_neighbour_index", -9)) == 0 and int(multi.get("dumped_liquid_id", -9)) == 0 and int(multi.get("cursor_after", -1)) == 0 and is_equal_approx(float(alone.get("dumped_amount", -1.0)), 0.0) and int(alone.get("dump_neighbour_index", -9)) == -1 and int(alone.get("dumped_liquid_id", -9)) == 0 and int(alone.get("cursor_after", -1)) == 0 and is_equal_approx(float(linked.get("dumped_amount", -1.0)), 0.0) and int(linked.get("dump_neighbour_index", -9)) == -1 and int(linked.get("dumped_liquid_id", -9)) == 0 and int(linked.get("cursor_after", -1)) == 2 and is_equal_approx(float(threshold.get("dumped_amount", -1.0)), 0.0) and int(threshold.get("dump_neighbour_index", -9)) == -1 and int(threshold.get("cursor_after", -1)) == 2 and is_equal_approx(float(no_current.get("dumped_amount", -1.0)), 0.0) and int(no_current.get("dump_neighbour_index", -9)) == -1 and int(no_current.get("dumped_liquid_id", -9)) == -1

	# --- Live tick: two phase-conduits placed live and
	# unlinked (link -1, had_valid_link false), each with
	# 50 water in its liquids meta and one accepting
	# neighbour at 20/100 stamped as frame inputs (the
	# N2276 precedent). The tick driver is called directly
	# (as the N2287 proof does), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status. The size-1 ring 0 is the (0, -1)
	# offset (the angle-sorted ring), so the (28, 21)
	# offset (the angle-sorted ring), so the (28, 21)
	# bridge's ring 0 is (28, 20) and the (20, 10)
	# bridge's is (20, 9). The first dumps 30 to ring 0
	# -- the neighbour separator at (28, 20) -- and the
	# 30 dumped water lands in its frame liquids (the
	# separator frame starts empty, so it lands at 30).
	# The second dumps to ring 0 -- a copper wall with no
	# store -- and the water still leaves the bridge (50
	# -> 20, cursor advances), dropping with reason
	# no_frame. One 1/60s tick is one source tick: the
	# shouldConsume gate is closed while unlinked
	# (ItemBridge.java:495-496), so efficiency folds 0
	# and warmup is 0f (ItemBridge.java:337).
	var live_ring: Array = block_geometry.source_block_proximity_cells_state(1, 28, 21).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var liquid_bridge_cell := Vector2i(28, 21)
	var liquid_bridge := Sprite2D.new()
	game.add_child(liquid_bridge)
	game.call("record_placed_block", liquid_bridge, blocks_by_id["phase-conduit"], liquid_bridge_cell)
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(liquid_bridge, blocks_by_id["phase-conduit"])
	var liquid_bridge_frame: Dictionary = liquid_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	# Keep the contact cell on the ring while placing a non-overlapping neighbour footprint.
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell + Vector2i(0, -1))
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["liquids"] = live_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	liquid_bridge_frame["power_status"] = 0.5
	liquid_bridge_frame["dump_neighbour_amounts"] = [20.0]
	liquid_bridge_frame["dump_neighbour_capacities"] = [100.0]
	liquid_bridge_frame["dump_neighbour_accepts"] = [true]
	liquid_bridge.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {"liquids": [50.0], "current": 0, "flow": null})

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(1, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_bridge_cell := Vector2i(20, 10)
	var bare_bridge := Sprite2D.new()
	game.add_child(bare_bridge)
	game.call("record_placed_block", bare_bridge, blocks_by_id["phase-conduit"], bare_bridge_cell)
	liquid_bridge_build_state.source_liquid_bridge_bind_frame_state(bare_bridge, blocks_by_id["phase-conduit"])
	var bare_frame: Dictionary = bare_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 0.5
	bare_frame["dump_neighbour_amounts"] = [20.0]
	bare_frame["dump_neighbour_capacities"] = [100.0]
	bare_frame["dump_neighbour_accepts"] = [true]
	bare_bridge.set_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {"liquids": [50.0], "current": 0, "flow": null})

	liquid_bridge_build_state.source_liquid_bridge_tick_buildings_state(game, 1.0 / 60.0)
	liquid_bridge_frame = liquid_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_bridge.get_meta(liquid_bridge_build_state.SOURCE_LIQUID_BRIDGE_BUILDING_META_KEY, {})
	var live_liquids: Dictionary = liquid_bridge.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_amounts: Array = live_liquids.get("liquids", [])
	var bare_liquids: Dictionary = bare_bridge.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var bare_amounts: Array = bare_liquids.get("liquids", [])
	var live_neighbour_liquids: Dictionary = live_neighbour_frame.get("liquids", {})
	var live_neighbour_water: float = float(liquid_module_state.source_get_state(live_neighbour_liquids, water_id).get("amount", -1.0))
	proof["live_tick_writes_dumped_liquid_to_neighbour_frame"] = live_neighbour_cell == Vector2i(28, 20) and is_equal_approx(float(liquid_bridge_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(liquid_bridge_frame.get("warmup", -1.0)), 0.0) and bool(liquid_bridge_frame.get("had_valid_link", true)) == false and is_equal_approx(float(live_amounts[0]), 20.0) and int(liquid_bridge_frame.get("cdump", -1)) == 0 and is_equal_approx(live_neighbour_water, 30.0)
	proof["live_tick_dumped_liquid_leaves_bridge_without_frame"] = bare_cell == Vector2i(20, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(bare_frame.get("warmup", -1.0)), 0.0) and bool(bare_frame.get("had_valid_link", true)) == false and is_equal_approx(float(bare_amounts[0]), 20.0) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidBridgeDumpWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
