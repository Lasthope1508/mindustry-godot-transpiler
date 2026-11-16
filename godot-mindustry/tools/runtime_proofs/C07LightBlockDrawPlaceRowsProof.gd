extends Node

const main_scene := preload("res://scenes/Main.tscn")
const light_block_build_state := preload("res://src/game/SourceLightBlockBuildState.gd")
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

	# --- Draw-place rows (N2439): LightBlock.drawPlace()
	# (LightBlock.java:48-53), changePlacementPath()
	# (LightBlock.java:55-59) and minimapColor()
	# (LightBlock.java:61-66). draw() is live since
	# N2374 and is untouched here. drawPlace() is
	# super.drawPlace(x, y, rotation, valid) (:50) +
	# the dash circle (`Drawf.dashCircle(x * tilesize +
	# offset, y * tilesize + offset, radius * 0.75f,
	# Pal.placing);`, :52 -- WITH the Block offset,
	# unlike the MassDriver dash circle). offset is the
	# Block offset (`offset = ((size + 1) % 2) *
	# tilesize / 2f;`, Block.java:761 -- 0 for the
	# size-1 LightBlock, `public int size = 1;`,
	# Block.java:215); tilesize is the Java constant 8
	# (`public static final int tilesize = 8;`,
	# Vars.java:135); Pal.placing IS the accent color
	# (`placing = accent,`, Pal.java:95). radius is the
	# class default 200f (`public float radius =
	# 200f;`, LightBlock.java:23), overridden by the
	# illuminator def to 140f (`radius = 140f;`,
	# Blocks.java:6766). changePlacementPath() is the
	# placeRadius2 math (`var placeRadius2 =
	# Mathf.pow(radius * 0.7f / tilesize, 2f) * 3;`,
	# :57) + the calculateNodes call
	# (`Placement.calculateNodes(points, this,
	# rotation, (point, other) -> point.dst2(other) <=
	# placeRadius2);`, :58). minimapColor() is the null
	# guard (`var build = (LightBuild)tile.build;`,
	# :63) + the fold (`return build == null ? 0 :
	# build.color | 0xff;`, :65 -- the color is `public
	# int color = Pal.accent.rgba();`,
	# LightBlock.java:68). The pure returns draw-call
	# dicts; it never draws for real (the N2356 /
	# N2396 pattern). The super call and the
	# calculateNodes call are recorded, not modeled.
	var tile_x := 10
	var tile_y := 20
	var rotation := 1
	var valid := true
	# The illuminator def radius (Blocks.java:6766) with
	# the size-1 offset 0 (Block.java:761).
	var def_radius := 140.0
	var size1_offset := 0.0
	# A fixture color whose low byte is NOT 0xff, so the
	# minimap | 0xff fold is observable (the pure echoes
	# the caller's color; the config itself waits for
	# its own slice -- this value makes no claim about
	# Pal.accent).
	var fixture_color := 0xFFAA3300

	# --- Dash circle: Drawf.dashCircle(x * tilesize +
	# offset, y * tilesize + offset, radius * 0.75f,
	# Pal.placing) -- center (80, 160) for tile (10,
	# 20) at offset 0, radius 140 * 0.75 = 105.0,
	# color the Pal.placing token. With offset 4.0 (the
	# size-2 value) the center shifts to (84, 164),
	# proving the offset flows through; with the class
	# default radius 200f the radius is 150.0.
	var placed: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, def_radius, size1_offset, null)
	var dash_call: Dictionary = placed.get("dash_call", {})
	proof["draw_place_dash_circle"] = dash_call.get("call", "") == "Drawf.dashCircle(x * tilesize + offset, y * tilesize + offset, radius * 0.75f, Pal.placing);" and is_equal_approx(float(dash_call.get("x", -1.0)), 80.0) and is_equal_approx(float(dash_call.get("y", -1.0)), 160.0) and is_equal_approx(float(dash_call.get("radius", -1.0)), 105.0) and dash_call.get("color", "") == "Pal.placing"
	var placed_offset: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, def_radius, 4.0, null)
	var offset_call: Dictionary = placed_offset.get("dash_call", {})
	var placed_default: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, 200.0, size1_offset, null)
	var default_call: Dictionary = placed_default.get("dash_call", {})
	proof["draw_place_dash_circle"] = bool(proof["draw_place_dash_circle"]) and is_equal_approx(float(offset_call.get("x", -1.0)), 84.0) and is_equal_approx(float(offset_call.get("y", -1.0)), 164.0) and is_equal_approx(float(default_call.get("radius", -1.0)), 150.0)

	# --- Super recorded: super.drawPlace(x, y,
	# rotation, valid) is recorded with its args, not
	# modeled (the BaseTurret draw_place precedent --
	# Block.drawPlace is drawPotentialLinks +
	# drawOverlay, SourceBlockDrawState).
	var super_call: Dictionary = placed.get("super_place_call", {})
	proof["draw_place_super_recorded"] = super_call.get("call", "") == "super.drawPlace(x, y, rotation, valid);" and int(super_call.get("tile_x", -1)) == tile_x and int(super_call.get("tile_y", -1)) == tile_y and int(super_call.get("rotation", -1)) == rotation and bool(super_call.get("valid", false)) == valid

	# --- placeRadius2 math: pow(radius * 0.7f /
	# tilesize, 2f) * 3 -- 450.1875 for the illuminator
	# def radius 140f (12.25^2 * 3), 918.75 for the
	# class default 200f (17.5^2 * 3). The illuminator
	# def in the catalog pins the 140f value (its
	# consumePower is 0.05f, Blocks.java:6767).
	proof["draw_place_radius2_math"] = is_equal_approx(float(placed.get("place_radius2", -1.0)), 450.1875) and is_equal_approx(float(placed_default.get("place_radius2", -1.0)), 918.75) and is_equal_approx(float(blocks_by_id["illuminator"].properties.get("consumePower", -1.0)), 0.05)

	# --- calculateNodes call: Placement.calculateNodes
	# (points, this, rotation, (point, other) ->
	# point.dst2(other) <= placeRadius2) is recorded as
	# a CALL (callee + rotation + predicate threshold),
	# the N2396 precedent -- the node algorithm itself
	# is NOT ported. The threshold is the placeRadius2
	# value 450.1875 from the same call.
	var nodes_call: Dictionary = placed.get("calculate_nodes_call", {})
	proof["draw_place_calculate_nodes"] = nodes_call.get("call", "") == "Placement.calculateNodes(points, this, rotation, (point, other) -> point.dst2(other) <= placeRadius2);" and nodes_call.get("callee", "") == "Placement.calculateNodes" and int(nodes_call.get("rotation", -1)) == rotation and nodes_call.get("predicate", "") == "point.dst2(other) <= placeRadius2" and is_equal_approx(float(nodes_call.get("predicate_threshold", -1.0)), 450.1875)

	# --- Minimap null: no build on the tile (null
	# build_color) -> minimap color 0.
	proof["minimap_color_null"] = int(placed.get("minimap_color", -1)) == 0

	# --- Minimap color | 0xff: a build color whose low
	# byte is 0x00 gets it forced to 0xff ("make sure A
	# is 255", LightBlock.java:64) -- 0xFFAA3300 ->
	# 0xFFAA33FF, 0x11223300 -> 0x112233FF -- while a
	# color already ending in 0xff is unchanged.
	var placed_color: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, def_radius, size1_offset, fixture_color)
	var placed_color2: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, def_radius, size1_offset, 0x11223300)
	var placed_color_ff: Dictionary = light_block_build_state.source_light_block_draw_place_state(tile_x, tile_y, rotation, valid, def_radius, size1_offset, 0xFFAA33FF)
	proof["minimap_color_or_ff"] = int(placed_color.get("minimap_color", -1)) == 0xFFAA33FF and int(placed_color2.get("minimap_color", -1)) == 0x112233FF and int(placed_color_ff.get("minimap_color", -1)) == 0xFFAA33FF

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LightBlockDrawPlaceRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
