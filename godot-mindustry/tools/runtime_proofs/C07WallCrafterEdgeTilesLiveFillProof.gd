extends Node

const main_scene := preload("res://scenes/Main.tscn")
const wall_crafter_build_state := preload("res://src/game/SourceWallCrafterBuildState.gd")
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

	# --- Pure fill (N2459): the live edge-tile scan that
	# fills frame["wall_edge_tiles"] (DEFERRED #210), which
	# the N2301 tick recomputes efficiency from each enabled
	# tick. getEfficiency (WallCrafter.java:141-180)
	# iterates `size` tiles along the FACING edge: cornerX =
	# tx - (size-1)/2, cornerY = ty - (size-1)/2 (INTEGER
	# division: size 3 -> 1, size 2 -> 0), s = size;
	# rotation 0 -> (cornerX+s, cornerY+i); 1 -> (cornerX+i,
	# cornerY+s); 2 -> (cornerX-1, cornerY+i); 3 ->
	# (cornerX+i, cornerY-1). Tile other = world.tile(rx,
	# ry); only `other != null && other.solid()` tiles
	# contribute, summing `other.block().attributes.get(
	# attribute)` -- BLOCK attributes, not floor attributes.
	# The cpos callback (:167-169) is a draw-plan hook with
	# no tick effect and the ctile callback (:175-177)
	# drives the updateEffect chance (:196-205, still
	# deferred); neither is ported here. Each entry is the
	# exact N2301 dict shape {solid, attribute_value} in
	# edge order (i = 0..size-1): a missing tile (no "x,y"
	# key) is a null tile (Java: other == null -> skipped,
	# contributes 0) and a non-solid tile is gated out the
	# same way. The tile map is frame["world_tiles"] (the
	# BeamDrill N2339 pattern, Dict keyed "x,y" to {solid,
	# wall_drop}) with the MINIMAL attribute extension
	# wall_attribute_by_tile (Dict "x,y" -> float, the WALL
	# BLOCK's attribute value per tile -- world_tiles
	# carries no block attribute; wall_drop is the drop
	# ITEM, not the attribute). Every pure case below uses
	# cell (10, 10): size 2 corners at (10, 10), size 3
	# corners at (9, 9).

	# Edge coordinates at rotation 0: a size-2 crusher at
	# (10, 10) faces (12, 10) and (12, 11) -- cornerX+s =
	# 12, cornerY+i = 10/11. Solid tiles there (0.5 + 0.25)
	# fill two solid entries and the N2301 pure sums 0.75.
	# The solid decoy at (11, 10) -- off the facing edge --
	# is never read (its 9.0 attribute would show in the
	# sum if the fill scanned the wrong edge).
	var rot0_map: Dictionary = {
		"12,10": {"solid": true, "wall_drop": ""},
		"12,11": {"solid": true, "wall_drop": ""},
		"11,10": {"solid": true, "wall_drop": ""},
	}
	var rot0_attrs: Dictionary = {"12,10": 0.5, "12,11": 0.25, "11,10": 9.0}
	var filled_rot0: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(rot0_map, rot0_attrs, Vector2i(10, 10), 2, 0).get("wall_edge_tiles", [])
	var eff_rot0: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_rot0, 0, 2, "sand")
	proof["edge_coords_rot0"] = filled_rot0.size() == 2 and filled_rot0[0].get("solid", false) == true and is_equal_approx(float(filled_rot0[0].get("attribute_value", -1.0)), 0.5) and filled_rot0[1].get("solid", false) == true and is_equal_approx(float(filled_rot0[1].get("attribute_value", -1.0)), 0.25) and is_equal_approx(float(eff_rot0.get("efficiency", -1.0)), 0.75)

	# Edge coordinates at rotation 1: the same size-2
	# crusher faces (10, 12) and (11, 12) -- cornerX+i =
	# 10/11, cornerY+s = 12. Solid tiles there (1.0 + 0.5)
	# fill two solid entries and the N2301 pure sums 1.5.
	# Rotations 2/3 fold into this key (size 3, the
	# large-cliff-crusher, corner (9, 9)): rotation 2 faces
	# (8, 9), (8, 10), (8, 11) -- cornerX-1 = 8 -- and
	# 1.0 + 0.5 + 0.25 sums 1.75; rotation 3 faces (9, 8),
	# (10, 8), (11, 8) -- cornerY-1 = 8 -- and 0.5 + 0.5 +
	# 0.5 sums 1.5.
	var rot1_map: Dictionary = {
		"10,12": {"solid": true, "wall_drop": ""},
		"11,12": {"solid": true, "wall_drop": ""},
	}
	var rot1_attrs: Dictionary = {"10,12": 1.0, "11,12": 0.5}
	var filled_rot1: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(rot1_map, rot1_attrs, Vector2i(10, 10), 2, 1).get("wall_edge_tiles", [])
	var eff_rot1: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_rot1, 1, 2, "sand")
	var rot2_map: Dictionary = {
		"8,9": {"solid": true, "wall_drop": ""},
		"8,10": {"solid": true, "wall_drop": ""},
		"8,11": {"solid": true, "wall_drop": ""},
	}
	var rot2_attrs: Dictionary = {"8,9": 1.0, "8,10": 0.5, "8,11": 0.25}
	var filled_rot2: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(rot2_map, rot2_attrs, Vector2i(10, 10), 3, 2).get("wall_edge_tiles", [])
	var eff_rot2: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_rot2, 2, 3, "sand")
	var rot3_map: Dictionary = {
		"9,8": {"solid": true, "wall_drop": ""},
		"10,8": {"solid": true, "wall_drop": ""},
		"11,8": {"solid": true, "wall_drop": ""},
	}
	var rot3_attrs: Dictionary = {"9,8": 0.5, "10,8": 0.5, "11,8": 0.5}
	var filled_rot3: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(rot3_map, rot3_attrs, Vector2i(10, 10), 3, 3).get("wall_edge_tiles", [])
	var eff_rot3: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_rot3, 3, 3, "sand")
	proof["edge_coords_rot1"] = filled_rot1.size() == 2 and is_equal_approx(float(eff_rot1.get("efficiency", -1.0)), 1.5) and filled_rot2.size() == 3 and is_equal_approx(float(eff_rot2.get("efficiency", -1.0)), 1.75) and int(eff_rot2.get("solid_tile_count", -1)) == 3 and filled_rot3.size() == 3 and is_equal_approx(float(eff_rot3.get("efficiency", -1.0)), 1.5)

	# The solid gate: a non-solid tile with attribute 1.0
	# fills {solid: false, attribute_value: 0.0} (Java
	# gates on `other != null && other.solid()`), so the
	# edge [non-solid 1.0, solid 0.5] gives efficiency 0.5
	# with 1 solid tile -- the non-solid attribute never
	# reaches the sum.
	var gate_map: Dictionary = {
		"12,10": {"solid": false, "wall_drop": ""},
		"12,11": {"solid": true, "wall_drop": ""},
	}
	var gate_attrs: Dictionary = {"12,10": 1.0, "12,11": 0.5}
	var filled_gate: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state(gate_map, gate_attrs, Vector2i(10, 10), 2, 0).get("wall_edge_tiles", [])
	var eff_gate: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_gate, 0, 2, "sand")
	proof["edge_solid_gate"] = filled_gate.size() == 2 and filled_gate[0].get("solid", true) == false and is_equal_approx(float(filled_gate[0].get("attribute_value", -1.0)), 0.0) and filled_gate[1].get("solid", false) == true and is_equal_approx(float(filled_gate[1].get("attribute_value", -1.0)), 0.5) and is_equal_approx(float(eff_gate.get("efficiency", -1.0)), 0.5) and int(eff_gate.get("solid_tile_count", -1)) == 1

	# Missing tiles: an empty map fills exactly `size`
	# non-solid entries (Java reads exactly `size` tiles;
	# a null tile contributes 0), so the N2301 pure reads
	# efficiency 0.0. A map with only out-of-edge keys
	# fills the same, and a null map entry at an edge
	# coordinate is a null tile too.
	var filled_empty: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state({}, {}, Vector2i(10, 10), 2, 0).get("wall_edge_tiles", [])
	var eff_empty: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(filled_empty, 0, 2, "sand")
	var filled_far: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state({"50,50": {"solid": true, "wall_drop": ""}}, {"50,50": 9.0}, Vector2i(10, 10), 2, 0).get("wall_edge_tiles", [])
	var filled_null: Array = wall_crafter_build_state.source_wall_crafter_edge_tiles_live_fill_state({"12,10": null}, {"12,10": 1.0}, Vector2i(10, 10), 2, 0).get("wall_edge_tiles", [])
	proof["edge_missing_tile"] = filled_empty.size() == 2 and filled_empty[0].get("solid", true) == false and is_equal_approx(float(filled_empty[0].get("attribute_value", -1.0)), 0.0) and is_equal_approx(float(eff_empty.get("efficiency", -1.0)), 0.0) and filled_far.size() == 2 and filled_far[0].get("solid", true) == false and filled_null.size() == 2 and filled_null[0].get("solid", true) == false and is_equal_approx(float(filled_null[0].get("attribute_value", -1.0)), 0.0)

	# --- Live ticks: two cliff-crushers placed live; the
	# tick driver is called directly (as the N2170/N2201/
	# N2223 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142.
	# One 1/60s tick is one source tick. Both crushers tick
	# in the same call; each has its own frame.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Supplied arrays WIN (the N2381 precedent): this
	# crusher seeds wall_edge_tiles by hand (two solid 0.5
	# tiles, efficiency 1.0 -- the N2301 proof seed) AND
	# carries a world_tiles map whose facing edge would fill
	# 0.0 (solid tiles with 0.0 attributes at its rotation-0
	# edge (30, 24), (30, 25)). After one tick the seeded
	# array is untouched, efficiency_factor is still 1.0,
	# and the live flag is NOT set -- the fill never ran.
	var seeded_cell := Vector2i(28, 24)
	var seeded := Sprite2D.new()
	game.add_child(seeded)
	game.call("record_placed_block", seeded, blocks_by_id["cliff-crusher"], seeded_cell)
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(seeded, blocks_by_id["cliff-crusher"])
	var seeded_frame: Dictionary = seeded.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	seeded_frame["items"] = {}
	seeded_frame["power_status"] = 0.5
	seeded_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]
	seeded_frame["world_tiles"] = {
		"30,24": {"solid": true, "wall_drop": ""},
		"30,25": {"solid": true, "wall_drop": ""},
	}
	seeded_frame["wall_attribute_by_tile"] = {"30,24": 0.0, "30,25": 0.0}

	# Live tick with the fill: this crusher seeds NO
	# wall_edge_tiles, so the fill runs -- its rotation-0
	# edge is (30, 21), (30, 22), both solid at 0.5, so the
	# N2301 recompute reads efficiency 1.0 and the advance
	# accumulates time (the N2301 live-tick numbers: power
	# min 0.5, warmup 1/40, eff 1.0, time 0.5,
	# lastEfficiency 0.5, totalTime 0.0125).
	var crusher_cell := Vector2i(28, 21)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# the tile-map inputs on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher, blocks_by_id["cliff-crusher"])
	var crusher_frame: Dictionary = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	crusher_frame["items"] = {}
	crusher_frame["power_status"] = 0.5
	crusher_frame["world_tiles"] = {
		"30,21": {"solid": true, "wall_drop": ""},
		"30,22": {"solid": true, "wall_drop": ""},
	}
	crusher_frame["wall_attribute_by_tile"] = {"30,21": 0.5, "30,22": 0.5}
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	seeded_frame = seeded.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	crusher_frame = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	var seeded_edge: Array = seeded_frame.get("wall_edge_tiles", [])
	proof["edge_supplied_wins"] = seeded_edge.size() == 2 and is_equal_approx(float(seeded_edge[0].get("attribute_value", -1.0)), 0.5) and is_equal_approx(float(seeded_edge[1].get("attribute_value", -1.0)), 0.5) and is_equal_approx(float(seeded_frame.get("efficiency_factor", -1.0)), 1.0) and bool(seeded_frame.get("wall_edge_tiles_live", false)) == false
	var live_filled: Array = crusher_frame.get("wall_edge_tiles", [])
	proof["edge_live_tick"] = bool(crusher_frame.get("wall_edge_tiles_live", false)) == true and live_filled.size() == 2 and live_filled[0].get("solid", false) == true and is_equal_approx(float(live_filled[0].get("attribute_value", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("efficiency_factor", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("warmup", -1.0)), 1.0 / 40.0) and is_equal_approx(float(crusher_frame.get("eff", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("time", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("last_efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("total_time", -1.0)), 0.0125) and bool(crusher_frame.get("offloaded", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterEdgeTilesLiveFillProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
