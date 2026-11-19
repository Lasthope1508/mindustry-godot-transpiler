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

	# --- Turret unit sync (N2260): N2250-N2259 never stamped
	# the unit mirror on the new duo driver -- the
	# controlled()/unit.controller() reads had no live unit
	# frame keys. TurretBuild.updateTile() (Turret.java:490-615)
	# syncs its block unit every tick, after the charge advance
	# and before the recoilOffset draw:
	# `unit.tile(this);`
	# `unit.rotation(rotation);`
	# `unit.team(team);`
	# (Turret.java:529-531). The unit is the per-building
	# BlockUnitc,
	# `public BlockUnitc unit = (BlockUnitc)UnitTypes.block.create(team);`
	# (:291), created on the building team. tile() re-asserts the
	# tile link (`this.tile = tile;`, BlockUnitComp.java:18) and
	# re-derives the hit size
	# (`hitSize(tile.block.size * tilesize * 0.7f);`, :23 -- the
	# port already has it as
	# SourceBlockGeometry.block_unit_tile_hit_size, scale 0.7);
	# rotation is the plain RotComp field assignment; team()
	# re-syncs the unit team and only calls back into the
	# building when the teams drifted
	# (`if(tile != null && this.team != team){` /
	# `tile.changeTeam(team);`, BlockUnitComp.java:79/:83 -- tile
	# is `this` at this call site, so the null guard is always
	# true). The post-sync unit team is always the building team
	# (team() sets this.team = team when the guard passes, and
	# keeps it when already synced); changeTeam is called only
	# when BOTH guards pass -- the unit team drifted from the
	# building team AND the tile team drifted too. Java order
	# :527 charge, :529-531 unit sync, :532 offset -- so the
	# unit sync tick runs AFTER the N2259 charge tick and BEFORE
	# the N2258 recoilOffset tick, and BEFORE the aim/shoot call,
	# so aim reads a live unit mirror. With duo, size is 1
	# (Block.java:215 default, never overridden) and tilesize is
	# 8 (Vars.tilesize), so the live duo hit size is
	# 1 * 8 * 0.7 = 5.6. The direct pure-function calls pin the
	# sync behind the driver observables below: the tile link is
	# re-asserted every tick / the unit rotation follows the
	# building rotation / the unit team follows the building team
	# / the duo hit size is 1 * 8 * 0.7 = 5.6 / a synced team
	# never calls changeTeam / a drifted team calls changeTeam
	# once and the unit team lands on the building team.

	# The direct pure-function calls pin the formula behind the
	# driver observables below.
	var direct_tile: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 90.0, 1, 1, 1, 1.0, 8.0)
	var direct_rotation: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 135.0, 1, 1, 1, 1.0, 8.0)
	var direct_team: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 90.0, 0, 1, 1, 1.0, 8.0)
	var direct_hit_size: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 90.0, 1, 1, 1, 1.0, 8.0)
	var direct_synced: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 90.0, 1, 1, 1, 1.0, 8.0)
	var direct_drifted: Dictionary = turret_build_state.source_turret_unit_sync_state(Vector2i(28, 21), 90.0, 0, 1, 0, 1.0, 8.0)

	# The tile link is re-asserted every tick -- directly (the
	# unit tile is the building cell passed in, (28, 21)).
	proof["unit_tile_reasserted"] = direct_tile.get("unit_tile", Vector2i.ZERO) == Vector2i(28, 21)
	# The unit rotation follows the building rotation -- directly
	# (135.0 in -> 135.0 out, a plain field assignment).
	proof["unit_rotation_follows_building"] = absf(float(direct_rotation.get("unit_rotation", 9.9)) - 135.0) < 0.0001
	# The unit team follows the building team -- directly (unit
	# team 0, building team 1 -> unit team 1).
	proof["unit_team_follows_building"] = int(direct_team.get("unit_team", 9)) == 1
	# The duo hit size is 1 * 8 * 0.7 = 5.6 -- directly (size
	# 1.0, tilesize 8.0 -> 5.6).
	proof["unit_hit_size_duo"] = absf(float(direct_hit_size.get("unit_hit_size", 9.9)) - 5.6) < 0.0001
	# A synced team never calls changeTeam -- directly (unit
	# team 1, building team 1, tile team 1 -> false).
	proof["unit_team_no_change_team_when_synced"] = not bool(direct_synced.get("tile_change_team_called", true))
	# A drifted team calls changeTeam once and the unit team
	# lands on the building team -- directly (unit team 0,
	# building team 1, tile team 0 -> true, unit team 1).
	proof["unit_team_change_team_when_drifted"] = bool(direct_drifted.get("tile_change_team_called", false)) and int(direct_drifted.get("unit_team", 9)) == 1

	# One duo segment, live on the driver: the unit sync tick
	# runs before the aim call, so the frame carries a live unit
	# mirror after a single tick.
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

	# All five unit sync keys are stamped on the frame after the
	# tick, as live keys -- not just computed by the pure
	# function.
	proof["unit_sync_stamped_to_frame"] = frame.has("unit_tile") and frame.has("unit_rotation") and frame.has("unit_team") and frame.has("unit_hit_size") and frame.has("tile_change_team_called")
	# The duo live tick stamps tile + rotation + team + hit size
	# 5.6: the cell (28, 21), the pre-aim rotation 90.0, the
	# placed team 1 (record_placed_block defaults team_id to 1
	# when the proof passes no team), hit size 5.6, and no
	# changeTeam call (the unit was created on the building team,
	# so nothing drifted) -- the stamp is live, not a default
	# left behind.
	proof["unit_sync_duo_live"] = frame.get("unit_tile", Vector2i.ZERO) == Vector2i(28, 21) and absf(float(frame.get("unit_rotation", 9.9)) - 90.0) < 0.0001 and int(frame.get("unit_team", 9)) == 1 and absf(float(frame.get("unit_hit_size", 9.9)) - 5.6) < 0.0001 and not bool(frame.get("tile_change_team_called", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretUnitSyncProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
