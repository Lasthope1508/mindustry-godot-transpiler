extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mechanical_pump_build_state := preload("res://src/game/SourceMechanicalPumpBuildState.gd")
const building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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

	# --- The advance exposes the handled neighbour (N2378,
	# the N2371 Fracker precedent): dump_neighbour_index is
	# the shared routing's handled_index -- the FIRST
	# eligible neighbour whose transfer actually moved
	# liquid (handle_liquid_called AND flow > 0), -1 when
	# nothing moved -- and dumped_liquid is the pumped
	# liquid's name. Unlike the Fracker's def constant
	# "oil", the pumped liquid VARIES BY TILE: liquidDrop
	# is the floor drop's name (water / oil / cryofluid /
	# slag / arkycite), so dumped_liquid is str(liquid_drop)
	# and "" on the null-drop path. The N2285 values: 40
	# water in an 80f store (fract 0.5) against an empty
	# 20-cap neighbour (ofract 0) transfers (0.5 - 0.0) *
	# 80 / 2 = 20, flow min(20 - 0, 20) = 20. A fuller
	# neighbour (ofract 1.0) takes nothing; a refusing
	# neighbour (accepts false) takes nothing either -- and
	# is NOT the handled index even though it computes a
	# flow, so a [refusing, empty] pair reports index 1.
	# Two empty neighbours take 20 + 10 = 30 (the fraction
	# recomputes from the running amount) and report the
	# FIRST index only -- the multi-recipient split defers.
	# With no neighbours nothing moves. The cursor wraps
	# back to 0 after a full loop (incrementDump runs once
	# per iteration); the null-drop path never calls
	# dumpLiquid, so the cursor does not move.
	var single: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [true], [true])
	var fuller: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [20.0], [20.0], [true], [true])
	var refused: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0], [20.0], [false], [true])
	var pair: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [false, true], [true, true])
	var multi: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [true, true], [true, true])
	var dry: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 1}, null, {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [0.0, 0.0], [20.0, 20.0], [true, true], [true, true])
	var alone: Dictionary = mechanical_pump_build_state.source_mechanical_pump_dump_liquid_state({"cdump": 0}, "water", {"liquids": [40.0], "current": 0, "flow": null}, 80.0, {"water": 0}, [], [], [], [])
	proof["advance_exposes_dump_neighbour_index"] = is_equal_approx(float(single.get("dumped_amount", -1.0)), 20.0) and int(single.get("dump_neighbour_index", -9)) == 0 and str(single.get("dumped_liquid", "?")) == "water" and int(single.get("cursor_after", -1)) == 0 and is_equal_approx(float(fuller.get("dumped_amount", -1.0)), 0.0) and int(fuller.get("dump_neighbour_index", -9)) == -1 and str(fuller.get("dumped_liquid", "?")) == "water" and int(fuller.get("cursor_after", -1)) == 0 and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and int(refused.get("dump_neighbour_index", -9)) == -1 and int(refused.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_amount", -1.0)), 20.0) and int(pair.get("dump_neighbour_index", -9)) == 1 and int(pair.get("cursor_after", -1)) == 0 and is_equal_approx(float(multi.get("dumped_amount", -1.0)), 30.0) and int(multi.get("dump_neighbour_index", -9)) == 0 and int(multi.get("cursor_after", -1)) == 0 and is_equal_approx(float(dry.get("dumped_amount", -1.0)), 0.0) and int(dry.get("dump_neighbour_index", -9)) == -1 and str(dry.get("dumped_liquid", "?")) == "" and int(dry.get("cursor_after", -1)) == 1 and is_equal_approx(float(alone.get("dumped_amount", -1.0)), 0.0) and int(alone.get("dump_neighbour_index", -9)) == -1 and str(alone.get("dumped_liquid", "?")) == "water" and int(alone.get("cursor_after", -1)) == 0

	# --- Live tick: two rotary-pumps placed live (the N2285
	# live setup: shallow-water floor so the per-tick
	# proximity scan finds liquidDrop water with amount 4.0;
	# the tick driver is called directly, so the graph update
	# does not overwrite the stamped power_status). One
	# 1/60s tick is one source tick: efficiency folds the
	# power min 0.5, edelta is 0.5, maxPump is min(80 - 0,
	# 4.0 * 0.2 * 0.5) = 0.4, and then the dump runs (Java
	# order: Pump.java:178-180 after :176) against the
	# stamped neighbour inputs: fract 0.4/80 = 0.005,
	# transfer 0.005 * 80 / 2 = 0.2, so the store holds 0.2
	# after the tick. The first pump dumps to ring 0 -- the
	# neighbour separator at (28, 19) -- and the 0.2 dumped
	# water lands in its frame liquids (the N2371 live-tick
	# shape). The second dumps to ring 0 -- a copper wall
	# with no store -- and the water still leaves the pump
	# (0.4 pumped, 0.2 kept), dropping with reason no_frame.
	# The size-2 ring 0 is the (0, -1) offset (the
	# angle-sorted ring, the N2371 pin), so the (28, 20)
	# pump's ring 0 is (28, 19) and the (20, 10) pump's is
	# (20, 9).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_id_by_name: Dictionary = content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var shallow_water = catalog.get_by_id("shallow-water")

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(2, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var pump_cell := Vector2i(28, 20)
	for occupied in game.call("occupied_cells", pump_cell, blocks_by_id["rotary-pump"]):
		terrain_state.source_set_world_floor_state(game, occupied.x, occupied.y, shallow_water)
	var pump := Sprite2D.new()
	game.add_child(pump)
	game.call("record_placed_block", pump, blocks_by_id["rotary-pump"], pump_cell)
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(pump, blocks_by_id["rotary-pump"])
	var pump_frame: Dictionary = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	# Keep the contact cell on the ring while placing a non-overlapping neighbour footprint.
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell + Vector2i(0, -1))
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["liquids"] = live_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	pump_frame["power_status"] = 0.5
	pump_frame["dump_neighbour_amounts"] = [0.0]
	pump_frame["dump_neighbour_capacities"] = [20.0]
	pump_frame["dump_neighbour_accepts"] = [true]
	pump_frame["dump_neighbour_can_dump"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(2, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_pump_cell := Vector2i(20, 10)
	for occupied in game.call("occupied_cells", bare_pump_cell, blocks_by_id["rotary-pump"]):
		terrain_state.source_set_world_floor_state(game, occupied.x, occupied.y, shallow_water)
	var bare_pump := Sprite2D.new()
	game.add_child(bare_pump)
	game.call("record_placed_block", bare_pump, blocks_by_id["rotary-pump"], bare_pump_cell)
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(bare_pump, blocks_by_id["rotary-pump"])
	var bare_frame: Dictionary = bare_pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 0.5
	bare_frame["dump_neighbour_amounts"] = [0.0]
	bare_frame["dump_neighbour_capacities"] = [20.0]
	bare_frame["dump_neighbour_accepts"] = [true]
	bare_frame["dump_neighbour_can_dump"] = [true]

	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	var bare_liquids: Dictionary = bare_pump.get_meta("source_building_liquids", {})
	var stored_water: float = 0.0
	var bare_water: float = 0.0
	if water_id >= 0 and water_id < pump_liquids.get("liquids", []).size():
		stored_water = float(pump_liquids["liquids"][water_id])
	if water_id >= 0 and water_id < bare_liquids.get("liquids", []).size():
		bare_water = float(bare_liquids["liquids"][water_id])
	var live_neighbour_liquids: Dictionary = live_neighbour_frame.get("liquids", {})
	var live_neighbour_water: float = float(liquid_module_state.source_get_state(live_neighbour_liquids, water_id).get("amount", -1.0))
	proof["live_tick_writes_dumped_water_to_neighbour_frame"] = live_neighbour_cell == Vector2i(28, 19) and is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(stored_water, 0.2) and int(pump_frame.get("cdump", -1)) == 0 and is_equal_approx(live_neighbour_water, 0.2)
	proof["live_tick_dumped_water_leaves_pump_without_frame"] = bare_cell == Vector2i(20, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(bare_water, 0.2) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PumpLiquidNeighbourWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
