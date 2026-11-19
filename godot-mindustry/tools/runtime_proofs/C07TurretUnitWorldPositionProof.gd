extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret unit world position (N2274): N2260 stamped the
	# cell (`unit_tile`) but the frame still had no world
	# position, so controlled()/unit.controller() reads that need
	# world coordinates had nothing live. TurretBuild.updateTile()
	# (Turret.java:490-615) syncs its block unit every tick:
	# `unit.tile(this);`
	# (Turret.java:529) -- and tile() positions the unit in world
	# coordinates:
	# `set(tile);`
	# (BlockUnitComp.java:24) ->
	# `set(pos.getX(), pos.getY());`
	# (PosComp.java:24) -> Tile.getX()/getY() are drawx()/drawy()
	# (Tile.java:727-734), drawx() is
	# `block().offset + worldx()` (:175-177), worldx() is
	# `x * tilesize` (:166-168), and Block.offset is
	# `offset = ((size + 1) % 2) * tilesize / 2f;`
	# (Block.java:761) -- 0 for odd sizes, tilesize/2 for even
	# sizes. The port already has drawx/drawy as
	# SourceBlockGeometry.tile_drawx_state / tile_drawy_state.
	# The pure function takes the building cell, the block size
	# and tilesize, and returns unit_world_x / unit_world_y /
	# unit_tile. Java order :529-531 sync, :532 offset -- so the
	# world position tick runs AFTER the N2260 unit sync tick and
	# BEFORE the N2258 recoilOffset tick, and BEFORE the aim/shoot
	# call, so aim reads a live unit mirror. With duo, size is 1
	# (Block.java:215 default, never overridden) and tilesize is
	# 8 (Vars.tilesize), so the live duo world position at cell
	# (28, 21) is (28 * 8, 21 * 8) = (224.0, 168.0). The direct
	# pure-function calls pin the formula behind the driver
	# observables below: the duo world x/y at cell (28, 21) are
	# 224.0 / 168.0 / an even size 2 offsets both by tilesize/2 =
	# 4.0 / an odd size 3 offsets by 0 / the origin cell maps to
	# (0.0, 0.0) / the tile link is re-asserted.

	# The direct pure-function calls pin the formula behind the
	# driver observables below.
	var direct_x: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(28, 21), 1.0, 8.0)
	var direct_y: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(28, 21), 1.0, 8.0)
	var direct_even: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(28, 21), 2.0, 8.0)
	var direct_odd3: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(28, 21), 3.0, 8.0)
	var direct_origin: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(0, 0), 1.0, 8.0)
	var direct_tile: Dictionary = turret_build_state.source_turret_unit_world_position_state(Vector2i(28, 21), 1.0, 8.0)

	# The duo world x at cell (28, 21) is 28 * 8 = 224.0 --
	# directly (size 1, offset 0).
	proof["unit_world_x_duo_size1"] = absf(float(direct_x.get("unit_world_x", 9.9)) - 224.0) < 0.0001
	# The duo world y at cell (28, 21) is 21 * 8 = 168.0 --
	# directly (size 1, offset 0).
	proof["unit_world_y_duo_size1"] = absf(float(direct_y.get("unit_world_y", 9.9)) - 168.0) < 0.0001
	# An even size 2 offsets both by tilesize/2 = 4.0 --
	# directly (224.0 + 4.0, 168.0 + 4.0).
	proof["unit_world_offset_even_size2"] = absf(float(direct_even.get("unit_world_x", 9.9)) - 228.0) < 0.0001 and absf(float(direct_even.get("unit_world_y", 9.9)) - 172.0) < 0.0001
	# An odd size 3 offsets by 0 -- directly (224.0, 168.0).
	proof["unit_world_offset_odd_size3"] = absf(float(direct_odd3.get("unit_world_x", 9.9)) - 224.0) < 0.0001 and absf(float(direct_odd3.get("unit_world_y", 9.9)) - 168.0) < 0.0001
	# The origin cell maps to (0.0, 0.0) -- directly.
	proof["unit_world_origin_cell"] = absf(float(direct_origin.get("unit_world_x", 9.9)) - 0.0) < 0.0001 and absf(float(direct_origin.get("unit_world_y", 9.9)) - 0.0) < 0.0001
	# The tile link is re-asserted every tick -- directly (the
	# unit tile is the building cell passed in, (28, 21)).
	proof["unit_tile_reasserted"] = direct_tile.get("unit_tile", Vector2i.ZERO) == Vector2i(28, 21)

	# One duo segment, live on the driver: the world position
	# tick runs before the aim call, so the frame carries a live
	# unit world position after a single tick.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
	# The raw Sprite2D node never passes through the texture
	# path (SourceTextureRuntimeState.configure_block_sprite),
	# which is what assigns a placed block its world position
	# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
	# so without this the segment sits at the origin (0, 0)
	# and the turret-centred query cannot be distinguished
	# from an origin-centred one. Seed the position exactly
	# the way the game does (the N2211 proof lesson).
	segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
	turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# All three unit world position keys are stamped on the
	# frame after the tick, as live keys -- not just computed by
	# the pure function.
	proof["unit_world_stamped_to_frame"] = frame.has("unit_world_x") and frame.has("unit_world_y") and frame.has("unit_tile")
	# The duo live tick stamps 224.0 / 168.0: the cell (28, 21),
	# size 1 (offset 0), tilesize 8 -- the stamp is live, not a
	# default left behind.
	proof["unit_world_duo_live"] = absf(float(frame.get("unit_world_x", 9.9)) - 224.0) < 0.0001 and absf(float(frame.get("unit_world_y", 9.9)) - 168.0) < 0.0001 and frame.get("unit_tile", Vector2i.ZERO) == Vector2i(28, 21)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretUnitWorldPositionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
