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

	# --- Turret rotate sync (N2262): N2250-N2261 never synced
	# the underlying building rotation on the new duo driver --
	# the frame had no building_rotation key at all.
	# TurretBuild.updateTile() (Turret.java:490-615) syncs it
	# every tick, after the logic-control decay and before the
	# heat-requirement fold:
	# `if(rotate){`
	# `((Building)this).rotation = Mathf.mod(Mathf.round(rotation / 90f), 4);`
	# (Turret.java:542-545). `rotate` is true for every turret
	# (Turret constructor, `rotate = true;`, :163) and duo never
	# overrides it (Blocks.java:3257-3331 sets only
	# `rotateSpeed = 10f;`). `rotation` is the turret's own float
	# aim rotation in degrees (frame["rotation"], default 90.0);
	# the synced field is the shadowed int 0-3 Building rotation
	# (`transient int rotation;`, BuildingComp.java:69, default 0).
	# arc `Mathf.round(float)` is
	# `return (int)(value + BIG_ENOUGH_ROUND) - BIG_ENOUGH_INT;`
	# (Mathf.java:500-502) -- round half UP toward +inf, like Java
	# Math.round, NOT half away from zero: -0.5 rounds to 0, -1.5
	# rounds to -1. arc `Mathf.mod(float, float)` is
	# `return ((f % n) + n) % n;` (Mathf.java:574-576) -- a proper
	# mod for negatives, so -1 maps to 3. Java order :534-536
	# decay, :538-540 heatReq, :542-545 rotate sync, :595-596
	# turnToTarget, :601/:609 updateShooting -- so the sync tick
	# runs AFTER the N2261 logicControlTime tick and BEFORE the
	# aim/shoot call. The direct pure-function calls pin the
	# formula behind the driver observables below: 0 degrees syncs
	# to 0 / 90 degrees syncs to 1 / 135 degrees rounds half-up to
	# 2 / 360 wraps to 0 and 405 wraps to 1 / -90 wraps to 3
	# through the proper mod / -45 rounds half-up to 0, pinning
	# arc round against half-away-from-zero / a non-rotating
	# turret keeps its building rotation.

	# The direct pure-function calls pin the formula behind the
	# driver observables below.
	var direct_zero: Dictionary = turret_build_state.source_turret_rotate_sync_state(0.0, true, 0)
	var direct_ninety: Dictionary = turret_build_state.source_turret_rotate_sync_state(90.0, true, 0)
	var direct_half_up: Dictionary = turret_build_state.source_turret_rotate_sync_state(135.0, true, 0)
	var direct_wrap_360: Dictionary = turret_build_state.source_turret_rotate_sync_state(360.0, true, 0)
	var direct_wrap_405: Dictionary = turret_build_state.source_turret_rotate_sync_state(405.0, true, 0)
	var direct_negative: Dictionary = turret_build_state.source_turret_rotate_sync_state(-90.0, true, 0)
	var direct_negative_half: Dictionary = turret_build_state.source_turret_rotate_sync_state(-45.0, true, 0)
	var direct_disabled: Dictionary = turret_build_state.source_turret_rotate_sync_state(135.0, false, 2)

	# 0 degrees syncs to 0 -- directly (0.0 / 90 = 0, round 0,
	# mod 0).
	proof["rotate_sync_zero_degrees"] = int(direct_zero.get("building_rotation", 9)) == 0
	# 90 degrees syncs to 1 -- directly (90.0 / 90 = 1, round 1,
	# mod 1).
	proof["rotate_sync_ninety_degrees"] = int(direct_ninety.get("building_rotation", 9)) == 1
	# 135 degrees rounds half-up to 2 -- directly (135.0 / 90 =
	# 1.5, round half-up 2, mod 2).
	proof["rotate_sync_rounds_half_up"] = int(direct_half_up.get("building_rotation", 9)) == 2
	# 360 wraps to 0 and 405 wraps to 1 -- directly (360.0 / 90
	# = 4, mod 0; 405.0 / 90 = 4.5, round half-up 5, mod 1).
	proof["rotate_sync_wraps_at_360"] = int(direct_wrap_360.get("building_rotation", 9)) == 0 and int(direct_wrap_405.get("building_rotation", 9)) == 1
	# -90 wraps to 3 through the proper mod -- directly (-90.0 /
	# 90 = -1, round -1, mod(-1, 4) = 3).
	proof["rotate_sync_negative_wraps"] = int(direct_negative.get("building_rotation", 9)) == 3
	# -45 rounds half-up to 0 -- directly (-45.0 / 90 = -0.5,
	# arc round half-up 0, mod 0). This pins arc round against
	# half-away-from-zero, which would give -1 and sync to 3.
	proof["rotate_sync_negative_half_rounds_up"] = int(direct_negative_half.get("building_rotation", 9)) == 0
	# A non-rotating turret keeps its building rotation --
	# directly (rotate=false, 135.0 in, building 2 in -> 2 out;
	# Java skips the assignment entirely).
	proof["rotate_sync_disabled_keeps_rotation"] = int(direct_disabled.get("building_rotation", 9)) == 2

	# One duo segment, live on the driver: the sync tick runs
	# after the logicControlTime tick and before the aim call, so
	# the frame carries a live building rotation after a single
	# tick.
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

	# Seed the float aim rotation the way the aim stamp would
	# (270.0 degrees -- the sync tick reads frame["rotation"]
	# before the aim call runs); the frame Dictionary is a
	# reference, so this stamp survives into the tick.
	var frame: Dictionary = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	frame["rotation"] = 270.0

	# One shared tick wires team_id / cheating / enabled onto
	# the frame (and charges the reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# The building rotation key is stamped on the frame after the
	# tick, as a live key -- not just computed by the pure
	# function.
	proof["rotate_sync_stamped_to_frame"] = frame.has("building_rotation")
	# The duo live tick syncs a seeded 270-degree rotation to 3:
	# the frame was seeded to 270.0 before the tick, so after one
	# tick it reads mod(round(270 / 90), 4) = 3 -- the stamp is
	# live, not a default left behind.
	proof["rotate_sync_duo_live"] = int(frame.get("building_rotation", 9)) == 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretRotateSyncProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
