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

	# --- Pure fill (N2301): WallCrafter.getEfficiency()
	# (WallCrafter.java:141-180). `float getEfficiency(int
	# tx, int ty, int rotation, @Nullable Cons<Tile> ctile,
	# @Nullable Intc2 cpos){` iterates `size` tiles along
	# the FACING edge (the rotation 0-3 switch picks the
	# edge from cornerX / cornerY) and sums
	# `other.block().attributes.get(attribute)` for SOLID
	# tiles only (`other != null && other.solid()`). The
	# attribute is sand for both defs (`public Attribute
	# attribute = Attribute.sand;`, WallCrafter.java:41).
	# These are BLOCK attributes, not the floor attributes
	# of the SolidPump scan (N2292). The port has no live
	# world, so the pure takes the facing edge tiles as
	# given, in edge order (i = 0..size-1), one Dict per
	# tile {solid, attribute_value}; rotation is carried
	# through for the proof + future live-world wiring.
	# Every case below uses attribute "sand".

	# Sums solid-tile attributes: a size-2 edge with two
	# solid tiles (0.5 + 0.25) gives efficiency 0.75, with
	# per-tile contributions [0.5, 0.25] and 2 solid tiles.
	# A size-3 edge (the large-cliff-crusher) with three
	# solid tiles (1.0 + 0.5 + 0.25) gives 1.75 and 3
	# solid tiles.
	var two_tiles: Array = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.25},
	]
	var two: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(two_tiles, 0, 2, "sand")
	var three_tiles: Array = [
		{"solid": true, "attribute_value": 1.0},
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.25},
	]
	var three: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(three_tiles, 1, 3, "sand")
	proof["sums_solid_tile_attributes"] = is_equal_approx(float(two.get("efficiency", -1.0)), 0.75) and is_equal_approx(float((two.get("edge_efficiencies", [-1.0, -1.0]) as Array)[0]), 0.5) and is_equal_approx(float((two.get("edge_efficiencies", [-1.0, -1.0]) as Array)[1]), 0.25) and int(two.get("solid_tile_count", -1)) == 2 and is_equal_approx(float(three.get("efficiency", -1.0)), 1.75) and int(three.get("solid_tile_count", -1)) == 3

	# Non-solid tiles are ignored: a non-solid tile with
	# attribute 1.0 contributes 0 even though its value is
	# nonzero (Java gates on `other != null &&
	# other.solid()`), so the edge [non-solid 1.0, solid
	# 0.5] gives efficiency 0.5 with contributions [0.0,
	# 0.5] and 1 solid tile. A null tile entry contributes
	# 0 the same way. A short edge array contributes 0 for
	# the missing tiles (one solid 0.75 tile in a size-2
	# edge gives 0.75 with contributions [0.75, 0.0]),
	# and tiles past `size` are ignored (Java reads exactly
	# `size` tiles: a 3-tile array in a size-2 edge counts
	# only the first two).
	var mixed_tiles: Array = [
		{"solid": false, "attribute_value": 1.0},
		{"solid": true, "attribute_value": 0.5},
	]
	var mixed: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(mixed_tiles, 0, 2, "sand")
	var null_tiles: Array = [
		null,
		{"solid": true, "attribute_value": 0.5},
	]
	var nulled: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(null_tiles, 0, 2, "sand")
	var short_tiles: Array = [
		{"solid": true, "attribute_value": 0.75},
	]
	var short: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(short_tiles, 0, 2, "sand")
	var long_tiles: Array = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.25},
		{"solid": true, "attribute_value": 10.0},
	]
	var long: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(long_tiles, 0, 2, "sand")
	proof["ignores_non_solid_tiles"] = is_equal_approx(float(mixed.get("efficiency", -1.0)), 0.5) and is_equal_approx(float((mixed.get("edge_efficiencies", [-1.0, -1.0]) as Array)[0]), 0.0) and int(mixed.get("solid_tile_count", -1)) == 1 and is_equal_approx(float(nulled.get("efficiency", -1.0)), 0.5) and int(nulled.get("solid_tile_count", -1)) == 1 and is_equal_approx(float(short.get("efficiency", -1.0)), 0.75) and is_equal_approx(float((short.get("edge_efficiencies", [-1.0, -1.0]) as Array)[1]), 0.0) and is_equal_approx(float(long.get("efficiency", -1.0)), 0.75) and int(long.get("solid_tile_count", -1)) == 2

	# An empty edge gives zero efficiency: no edge tiles
	# means no adjacent solid tiles, so efficiency is 0.0,
	# the contributions are [0.0, 0.0], no tile is solid,
	# and the placement gate is closed.
	var empty: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state([], 0, 2, "sand")
	proof["empty_edge_zero_efficiency"] = is_equal_approx(float(empty.get("efficiency", -1.0)), 0.0) and is_equal_approx(float((empty.get("edge_efficiencies", [-1.0, -1.0]) as Array)[0]), 0.0) and is_equal_approx(float((empty.get("edge_efficiencies", [-1.0, -1.0]) as Array)[1]), 0.0) and int(empty.get("solid_tile_count", -1)) == 0 and bool(empty.get("can_place_on", true)) == false

	# The placement gate is efficiency > 0 (canPlaceOn,
	# WallCrafter.java:137-139, `return getEfficiency(
	# tile.x, tile.y, rotation, null, null) > 0;`): the
	# 0.75-efficiency edge places, the empty edge does not.
	proof["placement_gate_efficiency_positive"] = bool(two.get("can_place_on", false)) == true and bool(empty.get("can_place_on", true)) == false and bool(three.get("can_place_on", false)) == true

	# Rotation is carried through: the pure echoes the
	# input rotation (3 in, 3 out) for the proof + future
	# live-world wiring, and the efficiency is the same for
	# the same edge tiles at rotation 0 and rotation 3 --
	# the caller supplies the facing edge, so rotation
	# selects nothing here yet.
	var rotated: Dictionary = wall_crafter_build_state.source_wall_crafter_get_efficiency_state(two_tiles, 3, 2, "sand")
	proof["rotation_carried_through"] = int(rotated.get("rotation", -1)) == 3 and int(two.get("rotation", -1)) == 0 and int(three.get("rotation", -1)) == 1 and is_equal_approx(float(rotated.get("efficiency", -1.0)), float(two.get("efficiency", -1.0)))

	# --- Live tick: a cliff-crusher placed live; the tick
	# driver is called directly (as the N2170/N2201/N2223
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The
	# edge tiles are frame inputs, stamped here like the
	# N2228 targets precedent: two solid tiles at 0.5 each
	# give efficiency 1.0, so the fill stamps
	# efficiency_factor 1.0 BEFORE the advance (Java order:
	# getEfficiency is computed inside updateTile,
	# WallCrafter.java:196). One 1/60s tick is one source
	# tick: efficiency folds the power min 0.5, warmup
	# rises 1/40 toward 1, eff is 1.0 (no liquid/item
	# booster live), time rises 0.5 * 1.0 * 1.0 * 1.0 =
	# 0.5, lastEfficiency is 0.5, and totalTime rises 0.5
	# * 0.025 * 1 = 0.0125 -- the N2223 live-tick numbers,
	# now from a live fill instead of a seeded
	# efficiency_factor.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var crusher_cell := Vector2i(28, 21)
	var crusher := Sprite2D.new()
	game.add_child(crusher)
	game.call("record_placed_block", crusher, blocks_by_id["cliff-crusher"], crusher_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# the edge tiles on it).
	wall_crafter_build_state.source_wall_crafter_bind_frame_state(crusher, blocks_by_id["cliff-crusher"])
	var crusher_frame: Dictionary = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})

	crusher_frame["items"] = {}
	crusher_frame["power_status"] = 0.5
	crusher_frame["wall_edge_tiles"] = [
		{"solid": true, "attribute_value": 0.5},
		{"solid": true, "attribute_value": 0.5},
	]
	wall_crafter_build_state.source_wall_crafter_tick_buildings_state(game, 1.0 / 60.0)
	crusher_frame = crusher.get_meta(wall_crafter_build_state.SOURCE_WALL_CRAFTER_BUILDING_META_KEY, {})
	proof["live_tick_fills_efficiency_factor"] = is_equal_approx(float(crusher_frame.get("efficiency_factor", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("warmup", -1.0)), 1.0 / 40.0) and is_equal_approx(float(crusher_frame.get("eff", -1.0)), 1.0) and is_equal_approx(float(crusher_frame.get("time", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("last_efficiency", -1.0)), 0.5) and is_equal_approx(float(crusher_frame.get("total_time", -1.0)), 0.0125) and bool(crusher_frame.get("offloaded", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WallCrafterGetEfficiencyProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
