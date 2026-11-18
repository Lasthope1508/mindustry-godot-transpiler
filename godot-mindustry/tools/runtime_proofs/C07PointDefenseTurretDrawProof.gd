extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- PointDefenseTurret draw() body (N2244):
	# PointDefenseBuild.draw() (`public void draw(){`,
	# PointDefenseTurret.java:110) draws the base rect at (x, y)
	# with no rotation (`Draw.rect(baseRegion, x, y);`,
	# PointDefenseTurret.java:111), draws the shadow and the
	# region rect at rotation - 90
	# (`Drawf.shadow(region, x - (size / 2f), y - (size / 2f),
	# rotation - 90);`, PointDefenseTurret.java:112, the overload
	# `public static void shadow(TextureRegion region, float x,
	# float y, float rotation){`, Drawf.java:366 -- and
	# `Draw.rect(region, x, y, rotation - 90);`,
	# PointDefenseTurret.java:113). There is NO Draw.z call
	# here, unlike RepairTurret.draw()
	# (RepairTurret.java:167, `Draw.z(Layer.turret);`) -- so
	# this slice has NO z_layer symbol, only the three draw
	# keys. The shadow offset quirk stays as Java wrote it:
	# `size / 2f` is subtracted directly on world coords, NOT
	# tilesize-scaled -- size is Block.size in tiles (class
	# default 1, Block.java:215, `public int size = 1;`;
	# segment 2, Blocks.java:3842, `size = 2;`, the only
	# PointDefenseTurret def), so segment offsets 1.0, the
	# class default offsets 0.5. rotation defaults to 90 (the
	# field init `public float rotation = 90;`,
	# BaseTurret.java:114). The proof calls the pure function
	# directly at the sample position x=100, y=200 (the
	# N2225/N2224 pattern) and through the driver tick, which
	# stamps the same three keys live every tick after the
	# aim/shoot block.

	# Draw rotation at the class-default rotation 90: 90 - 90
	# = 0.0.
	var rotation_default: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 90.0, 2.0)
	proof["draw_rotation_default"] = is_equal_approx(float(rotation_default.get("draw_rotation", -999.0)), 0.0)

	# Draw rotation at rotation 0: 0 - 90 = -90.0.
	var rotation_zero: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 0.0, 2.0)
	proof["draw_rotation_zero"] = is_equal_approx(float(rotation_zero.get("draw_rotation", -999.0)), -90.0)

	# Draw rotation at a half turn (rotation 180): 180 - 90
	# = 90.0.
	var rotation_half_turn: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 180.0, 2.0)
	proof["draw_rotation_half_turn"] = is_equal_approx(float(rotation_half_turn.get("draw_rotation", -999.0)), 90.0)

	# Shadow at the segment def (size 2): (100 - 1.0,
	# 200 - 1.0) = (99.0, 199.0).
	var shadow_segment: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 90.0, 2.0)
	proof["draw_shadow_segment"] = (shadow_segment.get("shadow_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(99.0, 199.0))

	# Shadow at the class-default size 1: (100 - 0.5,
	# 200 - 0.5) = (99.5, 199.5).
	var shadow_default: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 90.0, 1.0)
	proof["draw_shadow_default_size"] = (shadow_default.get("shadow_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(99.5, 199.5))

	# Base position stays (100, 200) with no rotation.
	var base_position: Dictionary = point_defense_turret_build_state.source_point_defense_turret_draw_state(100.0, 200.0, 90.0, 2.0)
	proof["draw_base_position"] = (base_position.get("base_position", Vector2.ZERO) as Vector2).is_equal_approx(Vector2(100, 200))

	# Driver tick: one placed segment, one tick -- the driver
	# stamps draw_rotation / shadow_position / base_position
	# live after the aim/shoot block (segment size 2.0, frame
	# rotation the 90 default, so draw_rotation 0.0 and the
	# shadow one unit below-left of the sprite position).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], Vector2i(28, 21))
	segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], Vector2i(28, 21))
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["draw_driver_stamps_live"] = is_equal_approx(float(frame.get("draw_rotation", -999.0)), 0.0) and (frame.get("shadow_position", Vector2.ZERO) as Vector2).is_equal_approx(segment.position - Vector2(1.0, 1.0)) and (frame.get("base_position", Vector2.ZERO) as Vector2).is_equal_approx(segment.position)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretDrawProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
