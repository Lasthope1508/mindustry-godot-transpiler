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

	# --- Turret recoilOffset draw (N2258): N2250-N2257 never
	# stamped frame["recoil_offset"] on the new duo driver --
	# the formula was already proven once on the legacy
	# PortGame path (N742, `PortGame.source_turret_recoil_offset`,
	# MCP: recoil 0.5 / rotation 0 / curRecoil 1 ->
	# Vector2(-0.5, 0.0)), but the duo sprite never kicked
	# back live on the new frame driver. TurretBuild.updateTile()
	# (Turret.java:490-615) recomputes the draw offset every
	# tick, after the recoil/heat decay and before turnToTarget:
	# `recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow)
	# * recoil);` (Turret.java:532). The field is `public Vec2
	# recoilOffset = new Vec2();` (:280), the power curve is
	# `public float recoilPow = 1.8f;` (:146) and the class
	# default is `public float recoil = 1f;` (:140) -- duo
	# overrides it with `recoil = 0.5f;` (Blocks.java:3315).
	# Java order :519/:520-525 decay, :532 offset, :595-596
	# turnToTarget, :601/:609 updateShooting -- so the offset
	# uses the PREVIOUS tick's rotation and the cur_recoil
	# DECAYED this tick, and it lags a shot by one tick (the
	# tick that shoots still offsets from the pre-shot recoil;
	# the next tick kicks). Three segments, one shared driver
	# tick: segment 0 shoots north from rotation 0 with a
	# pre-shot recoil of 0.2 (its offset stays small that tick
	# and kicks the next); segment 1 sits at rotation 90 with
	# recoil 1.0 and no target (its offset is the decayed full
	# kick straight down); segment 2 sits at rotation 30 with
	# no recoil and a target north (its offset is zero that
	# tick, then a seeded 0.5 recoil shows the offset follows
	# the previous tick's rotation, not the fresh aim rotation).
	# The segments sit 48 tiles (384px) apart -- wider than
	# twice the 160 range -- so no segment can see another
	# segment's target.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(76, 21), Vector2i(124, 21)]
	var segments: Array[Sprite2D] = []
	for cell in cells:
		var segment := Sprite2D.new()
		game.add_child(segment)
		game.call("record_placed_block", segment, blocks_by_id["duo"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every segment sits at the origin (0, 0)
		# and the turret-centred query cannot be distinguished
		# from an origin-centred one. Seed the position exactly
		# the way the game does (the N2211 proof lesson).
		segment.position = game.source_block_sprite_base_position(blocks_by_id["duo"], cell)
		turret_build_state.source_turret_bind_frame_state(segment, blocks_by_id["duo"])
		segments.append(segment)
	var frames: Array[Dictionary] = []
	for segment in segments:
		frames.append(segment.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {}))
	var positions: Array[Vector2] = []
	for segment in segments:
		positions.append(segment.position)

	# One shared tick wires team_id / cheating / enabled onto
	# every frame (and charges each reload by 1/60, which the
	# pre-charge below overwrites where it matters).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# 0: shoots north this tick -- rotation 0 faces the target
	# (targetRot 0, angleTo is atan2(dx, dy), 0 degrees is +Y),
	# pre-shot recoil 0.2, so the tick's offset stays small.
	frames[0]["rotation"] = 0.0
	frames[0]["cur_recoil"] = 0.2
	frames[0]["target"] = {"x": positions[0].x, "y": positions[0].y + 100.0, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	frames[0]["reload_counter"] = 19.99
	frames[0]["barrel_counter"] = 0
	frames[0]["inaccuracy_draw"] = 0.0
	# 1: no target, no ammo -- control for the decayed full
	# kick: rotation 90, recoil 1.0, so the offset points
	# straight down with the decayed magnitude.
	frames[1]["rotation"] = 90.0
	frames[1]["cur_recoil"] = 1.0
	# 2: rotation 30, no recoil, target north -- the offset is
	# zero this tick even though the turret turns toward the
	# target; the second tick seeds a 0.5 recoil to show the
	# offset follows the previous tick's rotation.
	frames[2]["rotation"] = 30.0
	frames[2]["cur_recoil"] = 0.0
	frames[2]["target"] = {"x": positions[2].x, "y": positions[2].y + 100.0, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[2]["has_target"] = true
	frames[2]["reload_counter"] = 0.0
	frames[2]["barrel_counter"] = 0
	frames[2]["inaccuracy_draw"] = 0.0

	# Seed copper ammo for 0 and 2 (the stacks are the
	# {"item", "amount"} dicts of
	# SourceTurretAmmoState.selected_turret_ammo_entries).
	var stacks_map: Dictionary = game.get("turret_ammo_stacks")
	var totals_map: Dictionary = game.get("turret_total_ammo")
	for index in [0, 2]:
		var ammo_key: String = str(game.call("cell_key", cells[index]))
		stacks_map[ammo_key] = [{"item": "copper", "amount": 5}]
		totals_map[ammo_key] = 5

	# The shooting tick: 0 shoots (reload 19.99 + 1/60 caps
	# at 20, in cone, in range, not charging, warmed up); 1
	# does not (no target); 2 does not (angleDist 30 > cone 15).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var offset0_after1: Dictionary = frames[0].get("recoil_offset", {})
	var offset1_after1: Dictionary = frames[1].get("recoil_offset", {})
	var offset2_after1: Dictionary = frames[2].get("recoil_offset", {})
	var recoil0_after1: float = float(frames[0].get("cur_recoil", -1.0))
	var shot0_after1: bool = bool(frames[0].get("shot", false))
	var shot1_after1: bool = bool(frames[1].get("shot", true))
	var shot2_after1: bool = bool(frames[2].get("shot", true))
	var rotation2_after1: float = float(frames[2].get("rotation", -1.0))

	# The direct pure-function calls pin the formula behind
	# the driver observables below: no recoil leaves the offset
	# at zero, a fresh shot kicks -0.5 along rotation 0 and
	# straight down at rotation 90, and half recoil follows
	# the pow(0.5, 1.8) curve (-0.1436 along rotation 0).
	var direct_zero: Dictionary = turret_build_state.source_turret_recoil_offset_state(30.0, 0.0, 1.8, 0.5)
	var direct_rot0: Dictionary = turret_build_state.source_turret_recoil_offset_state(0.0, 1.0, 1.8, 0.5)
	var direct_rot90: Dictionary = turret_build_state.source_turret_recoil_offset_state(90.0, 1.0, 1.8, 0.5)
	var direct_pow: Dictionary = turret_build_state.source_turret_recoil_offset_state(0.0, 0.5, 1.8, 0.5)
	var direct_zero_off: Dictionary = direct_zero.get("recoil_offset", {})
	var direct_rot0_off: Dictionary = direct_rot0.get("recoil_offset", {})
	var direct_rot90_off: Dictionary = direct_rot90.get("recoil_offset", {})
	var direct_pow_off: Dictionary = direct_pow.get("recoil_offset", {})

	# 2: no recoil leaves the offset at zero -- directly
	# (30 degrees, recoil 0) and through the driver (segment
	# 2's tick-1 offset is exactly zero even though the turret
	# turns toward its target that tick).
	proof["recoil_offset_zero_when_no_recoil"] = absf(float(direct_zero_off.get("x", 9.9))) < 0.0001 and absf(float(direct_zero_off.get("y", 9.9))) < 0.0001 and absf(float(offset2_after1.get("x", 9.9))) < 0.0001 and absf(float(offset2_after1.get("y", 9.9))) < 0.0001
	# 0/1: a fresh shot kicks -0.5 along rotation 0 --
	# directly (exactly -0.5, 0.0) and through the driver
	# (segment 0's second tick, after the shot, offsets by
	# the decayed -0.49925 -- checked after tick 2 below).
	proof["recoil_offset_full_kick_at_rotation_0"] = absf(float(direct_rot0_off.get("x", 9.9)) + 0.5) < 0.0001 and absf(float(direct_rot0_off.get("y", 9.9))) < 0.0001
	# 1: a fresh shot kicks -0.5 straight down at rotation 90
	# -- directly (0.0, -0.5) and through the driver (segment
	# 1's tick-1 offset is the decayed -0.49925 on y, ~0 on x).
	proof["recoil_offset_full_kick_at_rotation_90"] = absf(float(direct_rot90_off.get("x", 9.9))) < 0.0001 and absf(float(direct_rot90_off.get("y", 9.9)) + 0.5) < 0.0001 and absf(float(offset1_after1.get("x", 9.9))) < 0.001 and absf(float(offset1_after1.get("y", 9.9)) + 0.49925) < 0.001
	# Half recoil follows the pow curve: -pow(0.5, 1.8) * 0.5
	# is -0.1436 along rotation 0, directly.
	proof["recoil_offset_pow_curve"] = absf(float(direct_pow_off.get("x", 9.9)) + 0.14359) < 0.001 and absf(float(direct_pow_off.get("y", 9.9))) < 0.0001
	# 1: the offset uses the decayed recoil, not the stamped
	# 1.0 -- segment 1's tick-1 magnitude is 0.49925 (1.0
	# decayed one tick: 1.0 - (1/60)/20, then pow 1.8),
	# strictly below the full 0.5 and above 0.499.
	var mag1_after1: float = Vector2(float(offset1_after1.get("x", 0.0)), float(offset1_after1.get("y", 0.0))).length()
	proof["recoil_offset_uses_decayed_recoil"] = mag1_after1 < 0.5 and mag1_after1 > 0.499
	# The offset is on the frame after the tick, as an
	# {"x", "y"} dict, on every segment -- including the
	# control that never shoots.
	proof["recoil_offset_stamped_to_frame"] = offset0_after1.has("x") and offset0_after1.has("y") and offset1_after1.has("x") and offset1_after1.has("y") and offset2_after1.has("x") and offset2_after1.has("y") and not shot1_after1 and not shot2_after1
	# 0: the offset lags the shot by one tick -- the shooting
	# tick still offsets from the pre-shot recoil (0.2 decayed
	# to 0.19917, pow curve -0.0274) while the frame already
	# stamps curRecoil 1.0; the kick itself lands next tick
	# (checked after tick 2 below).
	proof["recoil_offset_lags_shot_by_one_tick"] = shot0_after1 and absf(recoil0_after1 - 1.0) < 0.0001 and absf(float(offset0_after1.get("x", 9.9)) + 0.02743) < 0.001 and absf(float(offset0_after1.get("y", 9.9))) < 0.0001

	# A second tick for 0 and 2: 0 does not shoot again (its
	# reload reset to 0), so its offset now shows the kick
	# from the shot a tick ago (decayed 1.0 -> -0.49925 along
	# rotation 0). 2 gets a seeded 0.5 recoil; its offset must
	# follow the rotation it had BEFORE this tick's aim move
	# (read from the frame first), not the fresh aim rotation.
	var rotation2_before2: float = rotation2_after1
	frames[2]["cur_recoil"] = 0.5
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var offset0_after2: Dictionary = frames[0].get("recoil_offset", {})
	var offset2_after2: Dictionary = frames[2].get("recoil_offset", {})
	var shot0_after2: bool = bool(frames[0].get("shot", true))
	var rotation2_after2: float = float(frames[2].get("rotation", -1.0))

	# 0: the full kick at rotation 0 lands a tick after the
	# shot -- through the driver (decayed -0.49925 on x, ~0
	# on y) with no second shot this tick.
	proof["recoil_offset_full_kick_at_rotation_0"] = proof["recoil_offset_full_kick_at_rotation_0"] and not shot0_after2 and absf(float(offset0_after2.get("x", 9.9)) + 0.49925) < 0.001 and absf(float(offset0_after2.get("y", 9.9))) < 0.001
	# 2: the offset uses the previous tick's rotation -- its
	# direction matches tan(rotation_before2) and the aim
	# moved the rotation toward the target (0) this tick, so
	# the offset cannot be from the fresh rotation.
	var off2_x: float = float(offset2_after2.get("x", 0.0))
	var off2_y: float = float(offset2_after2.get("y", 0.0))
	proof["recoil_offset_uses_previous_rotation"] = absf(off2_x) > 0.1 and absf(off2_y / off2_x - tan(deg_to_rad(rotation2_before2))) < 0.001 and rotation2_after2 < rotation2_before2 and absf(rotation2_before2 - 30.0) > 0.01

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretRecoilOffsetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
