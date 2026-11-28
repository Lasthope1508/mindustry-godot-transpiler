extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
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
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- The shared neighbour liquid write-back helper (N2371):
	# dumpLiquid (BuildingComp.java:886-908) routes over
	# proximity and transfers to each eligible neighbour
	# through transferLiquid, which hands the liquid over
	# for real via `next.handleLiquid(self(), liquid, flow);`
	# (:918); handleLiquid is `liquids.add(liquid, amount);`
	# (BuildingComp.java:872-874). N2284 routed the Fracker
	# dump but only reported the amounts after; the helper
	# lands the liquid for real. Index i is ring cell i (the
	# source_block_proximity_cells_state ring, angle-sorted):
	# for a size-2 source at (60, 40) ring 0 is (60, 39) --
	# the live fill must fill the frame neighbour inputs in
	# ring order.
	var direct_ring: Array = block_geometry.source_block_proximity_cells_state(2, 60, 40).get("cells", [])
	var direct_cell: Vector2i = direct_ring[0]

	# Frame neighbour: a separator at ring 0 with a bound
	# frame takes 5.0 oil, then 2.5 more -- the frame
	# liquids land through the shared liquid module add and
	# the frame is written back with set_meta (the N2142
	# precedent). The frame liquids are the sprite-meta
	# module (what the separator tick syncs into the frame
	# each tick); the bound frame starts with an empty {}
	# liquids key, so the proof wires the meta store in.
	var frame_neighbour := Sprite2D.new()
	game.add_child(frame_neighbour)
	game.call("record_placed_block", frame_neighbour, blocks_by_id["separator"], direct_cell)
	separator_build_state.source_separator_bind_frame_state(frame_neighbour, blocks_by_id["separator"])
	var frame_neighbour_frame: Dictionary = frame_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	frame_neighbour_frame["liquids"] = frame_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var frame_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(60, 40), 2, 0, "oil", 5.0)
	var frame_write_two: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(60, 40), 2, 0, "oil", 2.5)
	frame_neighbour_frame = frame_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	var frame_neighbour_liquids: Dictionary = frame_neighbour_frame.get("liquids", {})
	var frame_neighbour_oil: float = float(liquid_module_state.source_get_state(frame_neighbour_liquids, oil_id).get("amount", -1.0))
	proof["write_back_frame_neighbour_lands_liquid"] = direct_cell == Vector2i(60, 39) and bool(frame_write.get("written", false)) and str(frame_write.get("reason", "")) == "live_frame" and frame_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(60, 39) and bool(frame_write_two.get("written", false)) and is_equal_approx(frame_neighbour_oil, 7.5)

	# Conduit neighbour: a conduit at ring 0 takes 4.0 oil
	# into its sprite-meta LiquidModule -- Conduit never
	# overrides handleLiquid, so the default liquids.add
	# lands there (the N2090 pump-dump precedent), NOT in a
	# queue and NOT in a frame (a conduit has no frame in
	# SOURCE_CONSUMER_FRAME_META_KEYS). The first conduit is
	# told by its block id alone (placement never binds the
	# conduit frame -- only the conduit tick does); the
	# second carries the conduit frame meta too (a ticked
	# conduit). Both resolve to the same meta-store write.
	# The meta store is lazily initialized when placement
	# left none (the LiquidBridge precedent).
	var conduit_ring: Array = block_geometry.source_block_proximity_cells_state(2, 70, 40).get("cells", [])
	var conduit_cell: Vector2i = conduit_ring[0]
	var conduit_sprite := Sprite2D.new()
	game.add_child(conduit_sprite)
	game.call("record_placed_block", conduit_sprite, blocks_by_id["conduit"], conduit_cell)
	if conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null) == null:
		placed_block_state.source_initialize_building_liquids_state(conduit_sprite, true, catalog)
	var conduit_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(70, 40), 2, 0, "oil", 4.0)
	var conduit_liquids: Dictionary = conduit_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var conduit_oil: float = float(liquid_module_state.source_get_state(conduit_liquids, oil_id).get("amount", -1.0))
	var ticked_ring: Array = block_geometry.source_block_proximity_cells_state(2, 72, 40).get("cells", [])
	var ticked_cell: Vector2i = ticked_ring[0]
	var ticked_sprite := Sprite2D.new()
	game.add_child(ticked_sprite)
	game.call("record_placed_block", ticked_sprite, blocks_by_id["conduit"], ticked_cell)
	if ticked_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, null) == null:
		placed_block_state.source_initialize_building_liquids_state(ticked_sprite, true, catalog)
	ticked_sprite.set_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY, {})
	var ticked_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(72, 40), 2, 0, "oil", 3.0)
	var ticked_liquids: Dictionary = ticked_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var ticked_oil: float = float(liquid_module_state.source_get_state(ticked_liquids, oil_id).get("amount", -1.0))
	proof["write_back_conduit_neighbour_lands_liquid"] = conduit_cell == Vector2i(70, 39) and bool(conduit_write.get("written", false)) and str(conduit_write.get("reason", "")) == "conduit" and conduit_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(70, 39) and is_equal_approx(conduit_oil, 4.0) and ticked_cell == Vector2i(72, 39) and bool(ticked_write.get("written", false)) and str(ticked_write.get("reason", "")) == "conduit" and ticked_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(72, 39) and is_equal_approx(ticked_oil, 3.0)

	# Storeless neighbour: a copper wall at ring 0 carries
	# neither a conduit store nor a family frame, so the
	# write reports no_frame -- the liquid is already routed
	# away, so there is no fallback to the source store.
	# (A core neighbour is the same shape: no frame in
	# SOURCE_CONSUMER_FRAME_META_KEYS.)
	var wall_ring: Array = block_geometry.source_block_proximity_cells_state(2, 80, 40).get("cells", [])
	var wall_cell: Vector2i = wall_ring[0]
	var wall_sprite := Sprite2D.new()
	game.add_child(wall_sprite)
	game.call("record_placed_block", wall_sprite, blocks_by_id["copper-wall"], wall_cell)
	var wall_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(80, 40), 2, 0, "oil", 1.0)
	proof["write_back_no_frame_reports_no_frame"] = wall_cell == Vector2i(80, 39) and bool(wall_write.get("written", true)) == false and str(wall_write.get("reason", "")) == "no_frame" and wall_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(80, 39) and not wall_sprite.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not wall_sprite.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	# Empty cell: no sprite at ring 0 reports no_sprite.
	# Guards: an out-of-range index reports invalid_index
	# (the size-2 ring has 8 cells, so index 8 is out), a
	# non-positive amount reports invalid_amount, an empty
	# liquid name reports invalid_liquid, and an unknown
	# liquid name reports unknown_liquid.
	var empty_ring: Array = block_geometry.source_block_proximity_cells_state(2, 90, 40).get("cells", [])
	var empty_cell: Vector2i = empty_ring[0]
	var empty_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(90, 40), 2, 0, "oil", 1.0)
	var index_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(90, 40), 2, 8, "oil", 1.0)
	var amount_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(90, 40), 2, 0, "oil", 0.0)
	var empty_liquid_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(90, 40), 2, 0, "", 1.0)
	var unknown_write: Dictionary = building_liquid_state.source_neighbour_liquid_write_back_state(game, Vector2i(90, 40), 2, 0, "not-a-liquid", 1.0)
	proof["write_back_no_sprite_reports_no_sprite"] = empty_cell == Vector2i(90, 39) and bool(empty_write.get("written", true)) == false and str(empty_write.get("reason", "")) == "no_sprite" and empty_write.get("neighbour_cell", Vector2i(-1, -1)) == Vector2i(90, 39) and bool(index_write.get("written", true)) == false and str(index_write.get("reason", "")) == "invalid_index" and bool(amount_write.get("written", true)) == false and str(amount_write.get("reason", "")) == "invalid_amount" and bool(empty_liquid_write.get("written", true)) == false and str(empty_liquid_write.get("reason", "")) == "invalid_liquid" and bool(unknown_write.get("written", true)) == false and str(unknown_write.get("reason", "")) == "unknown_liquid"

	# --- The advance exposes the handled neighbour: the
	# dumped liquid name is the def constant "oil"
	# (Blocks.java:2966) and dump_neighbour_index is the
	# FIRST eligible neighbour whose transfer actually moved
	# liquid (handle_liquid_called AND flow > 0), -1 when
	# nothing moved. The N2284 values: 20 oil in a 40f store
	# (fract 0.5) against an empty 40f neighbour (ofract 0)
	# transfers (0.5 - 0.0) * 40 / 2 = 10. A fuller neighbour
	# (ofract 0.75) takes nothing and the cursor stays 0
	# (N2385: the full-cycle scan wraps (0+1)%1 back to 0);
	# a refusing neighbour (accepts false) takes
	# nothing either -- and is NOT the handled index even
	# though it computes a flow, so a [refusing, empty] pair
	# reports index 1. Two empty neighbours take 10 + 5 = 15
	# (the fraction recomputes from the running amount) and
	# report the FIRST index only -- the multi-recipient
	# split defers. With no neighbours nothing moves and the
	# cursor stays 0.
	var empty_neighbour: Dictionary = {"amount": 0.0, "capacity": 40.0, "accepts": true, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var transfer_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(transfer_liquids, oil_id, 20.0)
	var transferred: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": transfer_liquids, "cdump": 0}, oil_id, 40.0, [empty_neighbour])
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, oil_id, 20.0)
	var full_neighbour: Dictionary = {"amount": 30.0, "capacity": 40.0, "accepts": true, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var full: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": full_liquids, "cdump": 0}, oil_id, 40.0, [full_neighbour])
	var refusing_neighbour: Dictionary = {"amount": 0.0, "capacity": 40.0, "accepts": false, "has_liquids": true, "can_dump": true, "liquids_present": true, "destination_present": true, "relative_to": 0}
	var refused: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": full_liquids, "cdump": 0}, oil_id, 40.0, [refusing_neighbour])
	var pair_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(pair_liquids, oil_id, 20.0)
	var pair: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": pair_liquids, "cdump": 0}, oil_id, 40.0, [refusing_neighbour, empty_neighbour])
	var multi_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(multi_liquids, oil_id, 20.0)
	var multi: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": multi_liquids, "cdump": 0}, oil_id, 40.0, [empty_neighbour, empty_neighbour])
	var alone_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(alone_liquids, oil_id, 20.0)
	var alone: Dictionary = fracker_build_state.source_fracker_dump_liquid_state({"liquids": alone_liquids, "cdump": 0}, oil_id, 40.0, [])
	proof["advance_exposes_dump_neighbour_index"] = is_equal_approx(float(transferred.get("dumped_amount", -1.0)), 10.0) and int(transferred.get("dump_neighbour_index", -9)) == 0 and str(transferred.get("dumped_liquid", "")) == "oil" and int(transferred.get("cursor_after", -1)) == 0 and is_equal_approx(float(full.get("dumped_amount", -1.0)), 0.0) and int(full.get("dump_neighbour_index", -9)) == -1 and int(full.get("cursor_after", -1)) == 0 and is_equal_approx(float(refused.get("dumped_amount", -1.0)), 0.0) and int(refused.get("dump_neighbour_index", -9)) == -1 and int(refused.get("cursor_after", -1)) == 0 and is_equal_approx(float(pair.get("dumped_amount", -1.0)), 10.0) and int(pair.get("dump_neighbour_index", -9)) == 1 and int(pair.get("cursor_after", -1)) == 0 and is_equal_approx(float(multi.get("dumped_amount", -1.0)), 15.0) and int(multi.get("dump_neighbour_index", -9)) == 0 and int(multi.get("cursor_after", -1)) == 0 and is_equal_approx(float(alone.get("dumped_amount", -1.0)), 0.0) and int(alone.get("dump_neighbour_index", -9)) == -1 and int(alone.get("cursor_after", -1)) == 0

	# --- Live tick: two oil-extractors placed live (the
	# N2284 live setup: full power, water + sand seeded so
	# the folded efficiency is 1.0; the fraction inputs are
	# 0, so the pump adds nothing and the dump sees the
	# seeded 20 oil). The first dumps to ring 0 -- the
	# neighbour separator at (26, 19) -- and the 10 dumped
	# oil lands in its frame liquids. The second dumps to
	# ring 0 -- a copper wall with no store -- and the oil
	# still leaves the fracker (20 -> 10, cursor advances),
	# dropping with reason no_frame. The size-3 ring 0 is
	# the (-2, -1) offset (the angle-sorted ring), so the
	# (28, 20) fracker's ring 0 is (26, 19) and the (20, 10)
	# fracker's is (18, 9).
	var live_ring: Array = block_geometry.source_block_proximity_cells_state(3, 28, 20).get("cells", [])
	var live_neighbour_cell: Vector2i = live_ring[0]
	var extractor_cell := Vector2i(28, 20)
	var extractor := Sprite2D.new()
	game.add_child(extractor)
	game.call("record_placed_block", extractor, blocks_by_id["oil-extractor"], extractor_cell)
	fracker_build_state.source_fracker_bind_frame_state(extractor, blocks_by_id["oil-extractor"])
	var extractor_frame: Dictionary = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var extractor_liquids: Dictionary = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(extractor_liquids, oil_id, 20.0)
	liquid_module_state.source_set_state(extractor_liquids, water_id, 0.3)
	var live_neighbour := Sprite2D.new()
	game.add_child(live_neighbour)
	# Keep the contact cell on the ring while placing a non-overlapping neighbour footprint.
	game.call("record_placed_block", live_neighbour, blocks_by_id["separator"], live_neighbour_cell + Vector2i(-1, 0))
	separator_build_state.source_separator_bind_frame_state(live_neighbour, blocks_by_id["separator"])
	var live_neighbour_frame: Dictionary = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	live_neighbour_frame["liquids"] = live_neighbour.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	extractor_frame["items"] = {"sand": 1}
	extractor_frame["dump_liquid_neighbours"] = [empty_neighbour]
	extractor_frame["power_status"] = 1.0

	var bare_ring: Array = block_geometry.source_block_proximity_cells_state(3, 20, 10).get("cells", [])
	var bare_cell: Vector2i = bare_ring[0]
	var bare_extractor_cell := Vector2i(20, 10)
	var bare_extractor := Sprite2D.new()
	game.add_child(bare_extractor)
	game.call("record_placed_block", bare_extractor, blocks_by_id["oil-extractor"], bare_extractor_cell)
	fracker_build_state.source_fracker_bind_frame_state(bare_extractor, blocks_by_id["oil-extractor"])
	var bare_frame: Dictionary = bare_extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	var bare_liquids: Dictionary = bare_extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(bare_liquids, oil_id, 20.0)
	liquid_module_state.source_set_state(bare_liquids, water_id, 0.3)
	var bare_wall := Sprite2D.new()
	game.add_child(bare_wall)
	game.call("record_placed_block", bare_wall, blocks_by_id["copper-wall"], bare_cell)

	bare_frame["items"] = {"sand": 1}
	bare_frame["dump_liquid_neighbours"] = [empty_neighbour]
	bare_frame["power_status"] = 1.0

	fracker_build_state.source_fracker_tick_buildings_state(game, 1.0 / 60.0)
	extractor_frame = extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	live_neighbour_frame = live_neighbour.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	bare_frame = bare_extractor.get_meta(fracker_build_state.SOURCE_FRACKER_BUILDING_META_KEY, {})
	extractor_liquids = extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	bare_liquids = bare_extractor.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var extractor_oil: float = float(liquid_module_state.source_get_state(extractor_liquids, oil_id).get("amount", -1.0))
	var bare_oil: float = float(liquid_module_state.source_get_state(bare_liquids, oil_id).get("amount", -1.0))
	var live_neighbour_liquids: Dictionary = live_neighbour_frame.get("liquids", {})
	var live_neighbour_oil: float = float(liquid_module_state.source_get_state(live_neighbour_liquids, oil_id).get("amount", -1.0))
	proof["live_tick_writes_dumped_liquid_to_neighbour_frame"] = live_neighbour_cell == Vector2i(26, 19) and is_equal_approx(float(extractor_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(extractor_oil, 10.0) and int(extractor_frame.get("cdump", -1)) == 0 and is_equal_approx(live_neighbour_oil, 10.0)
	proof["live_tick_dumped_liquid_leaves_fracker_without_frame"] = bare_cell == Vector2i(18, 9) and is_equal_approx(float(bare_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(bare_oil, 10.0) and int(bare_frame.get("cdump", -1)) == 0 and not bare_wall.has_meta(building_liquid_state.SOURCE_NEIGHBOUR_CONDUIT_FRAME_META_KEY) and not bare_wall.has_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LiquidNeighbourWriteBackProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
