extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_unloader_build_state := preload("res://src/game/SourcePayloadUnloaderBuildState.gd")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
const building_liquid_state := preload("res://src/game/SourceBuildingLiquidState.gd")
const block_geometry := preload("res://src/game/SourceBlockGeometry.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _liquid_module(amounts: Array, current: int) -> Dictionary:
	return {"liquids": amounts, "current": current, "flow": null}


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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))
	var item_order: Array = ["copper", "lead"]

	# --- The dump advance exposes the liquid write-back keys
	# (N2380, the liquid half of DEFERRED #258): N2293
	# ported the dump rows (dumpLiquid(current) 2f +
	# offloadSpeed x dumpAccumulate() at the end of
	# updateTile, PayloadUnloader.java:105-108) -- but the
	# dumped liquid left the store without landing in any
	# neighbour store. Java hands it over for real
	# (`next.handleLiquid(self(), liquid, flow);`,
	# BuildingComp.java:918), and handleLiquid is
	# `liquids.add(liquid, amount);` (BuildingComp.java:
	# 872-874). The advance now exposes dump_neighbour_index
	# (the shared routing's handled_index, the FIRST eligible
	# neighbour whose transfer actually moved liquid --
	# handle_liquid_called AND flow > 0, the N2371 rule --
	# -1 when nothing moved) + dumped_liquid_name (the dumped
	# liquid's catalog name). KEY COLLISION: the advance
	# ALREADY returns `dumped_liquid` -- but as the FLOAT
	# amount dumped (BuildingComp.java:905), NOT a name -- so
	# the name rides the separate dumped_liquid_name String
	# key and the old key's meaning does NOT change. The name
	# resolves the current liquid id through the
	# liquid_names_by_id frame input (the PayloadLoader
	# precedent: the tick builds the names-by-id array from
	# catalog.get_many("liquid"), index == id, and stamps it
	# on the frame); the fixtures below carry ["water"] so id
	# 0 resolves to "water". The name is set whenever a
	# current liquid resolves, even when nothing moved (the
	# Fracker dumped_liquid precedent). The ITEM half is NOT
	# exposed here -- it waits for its own follow-through
	# slice.

	# Transfers liquid to neighbour 0: self 50/100 (fract
	# 0.5) against an empty 100-capacity neighbour (ofract 0)
	# transfers (0.5 - 0) * 100 / 2 = 25, so the store drops
	# 50 -> 25, the handled index is 0, the dumped name is
	# "water", and the cursor ends where it started (a full
	# scan over 1 neighbour advances it once: (0 + 1) % 1 =
	# 0). The dumped_liquid FLOAT key still reads 25.0.
	var transfer: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0, "liquid_names_by_id": ["water"]}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [true], [], [])
	var transfer_liquids: Dictionary = transfer.get("liquids_after", {})
	var transfer_amount: float = float(liquid_module_state.source_get_state(transfer_liquids, 0).get("amount", -1.0))

	# The second neighbour takes the transfer when the first
	# refuses: accepts [false, true] routes to index 1 (the
	# refusing neighbour computes a flow but never handles,
	# so it is NOT the handled index) and dumps 25.0.
	var pair: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0, "liquid_names_by_id": ["water"]}, 1.0, 1.0, item_order, [0.0, 0.0], [100.0, 100.0], [false, true], [true, true], [], [])
	var pair_liquids: Dictionary = pair.get("liquids_after", {})
	var pair_amount: float = float(liquid_module_state.source_get_state(pair_liquids, 0).get("amount", -1.0))

	# Two empty neighbours take 25 + 12.5 = 37.5 (the
	# fraction recomputes from the running amount: 0.5 then
	# 0.25) and report the FIRST index only -- the
	# multi-recipient split defers.
	var multi: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0, "liquid_names_by_id": ["water"]}, 1.0, 1.0, item_order, [0.0, 0.0], [100.0, 100.0], [true, true], [true, true], [], [])
	var multi_liquids: Dictionary = multi.get("liquids_after", {})
	var multi_amount: float = float(liquid_module_state.source_get_state(multi_liquids, 0).get("amount", -1.0))

	# No transfer when the neighbour is fuller: self 10/100
	# (fract 0.1) against a neighbour at 20/100 (ofract 0.2)
	# dumps nothing (the guard is ofract < fract), the index
	# is -1 -- but the name still resolves to "water", because
	# the current liquid exists even when nothing moved.
	var fuller: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([10.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0, "liquid_names_by_id": ["water"]}, 1.0, 1.0, item_order, [20.0], [100.0], [true], [true], [], [])
	var fuller_liquids: Dictionary = fuller.get("liquids_after", {})
	var fuller_amount: float = float(liquid_module_state.source_get_state(fuller_liquids, 0).get("amount", -1.0))

	# No names input, no name: the same transfer without a
	# liquid_names_by_id frame input still dumps 25.0 to
	# neighbour 0, but the name reads "" (a partial fixture).
	var no_names: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": _liquid_module([50.0], 0), "items": {}, "cdump": 0, "dump_accum": 0.0}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [true], [], [])

	# No current liquid, no name and no index: an empty
	# liquids store dumps nothing, reports -1, and the name
	# reads "".
	var no_current: Dictionary = payload_unloader_build_state.source_payload_unloader_dump_state({"liquids": {}, "items": {}, "cdump": 0, "dump_accum": 0.0, "liquid_names_by_id": ["water"]}, 1.0, 1.0, item_order, [0.0], [100.0], [true], [true], [], [])
	proof["advance_exposes_dump_neighbour_index_and_liquid_name"] = is_equal_approx(float(transfer.get("dumped_liquid", -1.0)), 25.0) and is_equal_approx(transfer_amount, 25.0) and int(transfer.get("dump_neighbour_index", -9)) == 0 and str(transfer.get("dumped_liquid_name", "missing")) == "water" and int(transfer.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_liquid", -1.0)), 25.0) and is_equal_approx(pair_amount, 25.0) and int(pair.get("dump_neighbour_index", -9)) == 1 and str(pair.get("dumped_liquid_name", "missing")) == "water" and int(pair.get("cursor_after", -1)) == 0 and is_equal_approx(float(multi.get("dumped_liquid", -1.0)), 37.5) and is_equal_approx(multi_amount, 12.5) and int(multi.get("dump_neighbour_index", -9)) == 0 and str(multi.get("dumped_liquid_name", "missing")) == "water" and int(multi.get("cursor_after", -1)) == 0 and is_equal_approx(float(fuller.get("dumped_liquid", -1.0)), 0.0) and is_equal_approx(fuller_amount, 10.0) and int(fuller.get("dump_neighbour_index", -9)) == -1 and str(fuller.get("dumped_liquid_name", "missing")) == "water" and is_equal_approx(float(no_names.get("dumped_liquid", -1.0)), 25.0) and int(no_names.get("dump_neighbour_index", -9)) == 0 and str(no_names.get("dumped_liquid_name", "missing")) == "" and is_equal_approx(float(no_current.get("dumped_liquid", -1.0)), 0.0) and int(no_current.get("dump_neighbour_index", -9)) == -1 and str(no_current.get("dumped_liquid_name", "missing")) == ""

	# --- Live tick: two payload-unloaders placed live with
	# NO payload (the N2293 live setup: the shouldConsume
	# gate is false, so efficiency folds to 0.0 -- and the
	# dump STILL runs, because the dump rows are
	# unconditional, PayloadUnloader.java:105-108). The first
	# dumps to ring 0 -- the neighbour separator at (26, 19)
	# -- and the 25 dumped water lands in its frame liquids.
	# The second dumps to ring 0 -- a copper wall with no
	# store -- and the water still leaves the unloader
	# (50 -> 25), dropping with reason no_frame. The size-3
	# ring 0 is the (-2, -1) offset (the angle-sorted ring),
	# so the (28, 20) unloader's ring 0 is (26, 19) and the
	# (20, 10) unloader's is (18, 9) (the N2371 precedent).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var live_ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var unloader_cell := Vector2i(28, 20)
	var unloader := Sprite2D.new()
	game.add_child(unloader)
	game.call("record_placed_block", unloader, blocks_by_id["payload-unloader"], unloader_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(unloader, blocks_by_id["payload-unloader"])
	var unloader_frame: Dictionary = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(unloader, true, game.get("content_catalog"))
	var unloader_liquids: Dictionary = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(unloader_liquids, water_id, 50.0)
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell)
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["liquids"] = live_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	unloader_frame["power_status"] = 1.0
	unloader_frame["items"] = {}
	unloader_frame["dump_neighbour_liquid_amounts"] = [0.0]
	unloader_frame["dump_neighbour_liquid_capacities"] = [100.0]
	unloader_frame["dump_neighbour_accepts_liquid"] = [true]
	unloader_frame["dump_neighbour_can_dump_liquid"] = [true]

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(3, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_unloader_cell := Vector2i(20, 10)
	var bare_unloader := Sprite2D.new()
	game.add_child(bare_unloader)
	game.call("record_placed_block", bare_unloader, blocks_by_id["payload-unloader"], bare_unloader_cell)
	payload_unloader_build_state.source_payload_unloader_bind_frame_state(bare_unloader, blocks_by_id["payload-unloader"])
	var bare_frame: Dictionary = bare_unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	placed_block_state.source_initialize_building_liquids_state(bare_unloader, true, game.get("content_catalog"))
	var bare_liquids: Dictionary = bare_unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bare_liquids, water_id, 50.0)
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["power_status"] = 1.0
	bare_frame["items"] = {}
	bare_frame["dump_neighbour_liquid_amounts"] = [0.0]
	bare_frame["dump_neighbour_liquid_capacities"] = [100.0]
	bare_frame["dump_neighbour_accepts_liquid"] = [true]
	bare_frame["dump_neighbour_can_dump_liquid"] = [true]

	payload_unloader_build_state.source_payload_unloader_tick_buildings_state(game, 1.0 / 60.0)
	unloader_frame = unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_unloader.get_meta(payload_unloader_build_state.SOURCE_PAYLOAD_UNLOADER_BUILDING_META_KEY, {})
	unloader_liquids = unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	bare_liquids = bare_unloader.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var live_amount: float = float(liquid_module_state.source_get_state(unloader_liquids, water_id).get("amount", -1.0))
	var bare_amount: float = float(liquid_module_state.source_get_state(bare_liquids, water_id).get("amount", -1.0))
	var live_neighbour_liquids: Dictionary = live_neighbour_frame.get("liquids", {})
	var live_neighbour_water: float = float(liquid_module_state.source_get_state(live_neighbour_liquids, water_id).get("amount", -1.0))
	proof["live_tick_writes_dumped_liquid_to_neighbour_frame"] = live_neighbour_cell == Vector2i(26, 19) and is_equal_approx(float(unloader_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(live_amount, 25.0) and is_equal_approx(float(unloader_frame.get("dumped_liquid", -1.0)), 25.0) and int(unloader_frame.get("cdump", -1)) == 0 and is_equal_approx(float(unloader_frame.get("dump_accum", -1.0)), 0.0) and is_equal_approx(live_neighbour_water, 25.0)
	proof["live_tick_dumped_liquid_leaves_unloader_without_frame"] = bare_cell == Vector2i(18, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(bare_amount, 25.0) and is_equal_approx(float(bare_frame.get("dumped_liquid", -1.0)), 25.0) and int(bare_frame.get("cdump", -1)) == 0 and is_equal_approx(float(bare_frame.get("dump_accum", -1.0)), 0.0) and not bare_wall.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadUnloaderDumpLiquidWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
