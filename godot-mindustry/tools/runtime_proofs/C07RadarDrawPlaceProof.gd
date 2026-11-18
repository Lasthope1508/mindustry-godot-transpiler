extends Node

const main_scene := preload("res://scenes/Main.tscn")
const radar_build_state := preload("res://src/game/SourceRadarBuildState.gd")
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

	# --- Pure drawPlace() row (N2284): Radar.drawPlace()
	# (Radar.java:42-47) draws one dash circle at the ghost
	# position: `Drawf.dashCircle(x * tilesize + offset, y *
	# tilesize + offset, fogRadius * tilesize, Pal.accent);`
	# (Radar.java:46) after `super.drawPlace(x, y, rotation,
	# valid);` (Radar.java:43). The center converts tile coords
	# to world coords with tilesize (8, Vars.java:135) plus the
	# block offset (radar size 1, so 0.0); the radius is the DEF
	# fogRadius -- 34 (Blocks.java:1991), class default 10
	# (Radar.java:33) -- times tilesize, NOT the live
	# fogRadius() (N2275): drawPlace is Block-level and reads
	# the def field, unlike drawSelect (N2281) which reads the
	# live fogRadius(). The color is Pal.accent. The proof calls
	# the pure function
	# source_radar_draw_place_state(tile_x, tile_y, rotation,
	# valid, fog_radius, tilesize, block_offset) directly with
	# synthetic tile coords and def fog radii; the caller
	# supplies the def fogRadius and the tilesize. There are no
	# driver-tick keys: drawPlace() is placement UI. Float
	# comparisons use is_equal_approx (the N2267 write/read
	# precedent for inexact float32 values).

	# The class-default def fog radius reads 10.0 * 8.0 = 80.0.
	var default: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 10.0, 8.0, 0.0)
	proof["draw_place_radius_def_default"] = is_equal_approx(float(default.get("radius", -1.0)), 80.0)

	# The radar def fog radius reads 34.0 * 8.0 = 272.0.
	var radar: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 34.0, 8.0, 0.0)
	proof["draw_place_radius_def_radar"] = is_equal_approx(float(radar.get("radius", -1.0)), 272.0)

	# Tilesize 1.0 reads the raw fog radius: 34.0 * 1.0 = 34.0
	# -- the tilesize is a real factor, not hardcoded to 8.
	var unit: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 34.0, 1.0, 0.0)
	proof["draw_place_radius_tilesize_one"] = is_equal_approx(float(unit.get("radius", -1.0)), 34.0)

	# A zero def fog radius draws a zero circle.
	var zero: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 0.0, 8.0, 0.0)
	proof["draw_place_radius_zero_fog"] = is_equal_approx(float(zero.get("radius", -1.0)), 0.0)

	# The circle is centered on the tile position in world
	# units: tile (100, 200) at tilesize 8 with the real zero
	# offset reads (800.0, 1600.0).
	var centered: Dictionary = radar_build_state.source_radar_draw_place_state(100, 200, 0, true, 34.0, 8.0, 0.0)
	proof["draw_place_center"] = Vector2(centered.get("center", Vector2(-1.0, -1.0))) == Vector2(800.0, 1600.0)

	# A nonzero block offset shifts the center by the offset:
	# tile (100, 200) with offset 4.0 reads (804.0, 1604.0).
	var offset: Dictionary = radar_build_state.source_radar_draw_place_state(100, 200, 0, true, 34.0, 8.0, 4.0)
	proof["draw_place_center_offset"] = Vector2(offset.get("center", Vector2(-1.0, -1.0))) == Vector2(804.0, 1604.0)

	# The circle color is Pal.accent.
	var colored: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 34.0, 8.0, 0.0)
	proof["draw_place_color_accent"] = str(colored.get("color", "")) == "Pal.accent"

	# The rotation is echoed: rotation 2 reads back 2.
	var rotated: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 2, true, 34.0, 8.0, 0.0)
	proof["draw_place_rotation_echo"] = int(rotated.get("rotation", -1)) == 2

	# The validity flag is echoed, not hardcoded: valid false
	# reads back false.
	var invalid: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, false, 34.0, 8.0, 0.0)
	proof["draw_place_valid_echo"] = bool(invalid.get("valid", true)) == false

	# The super leg is recorded as called.
	var super_called: Dictionary = radar_build_state.source_radar_draw_place_state(0, 0, 0, true, 34.0, 8.0, 0.0)
	proof["draw_place_super_called"] = bool(super_called.get("super_draw_place_called", false)) == true

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RadarDrawPlaceProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
