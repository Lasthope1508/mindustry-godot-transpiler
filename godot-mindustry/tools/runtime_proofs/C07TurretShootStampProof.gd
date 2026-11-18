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

	# --- Turret shoot stamp (N2255): N2252 only stamped
	# frame["bullet_spawn"] on a shot and N2254 only decayed
	# the recoil / heat toward 0 -- nobody ever stamped
	# frame["cur_recoil"] / frame["heat"] /
	# frame["total_shots"] after a shot, so a duo that shoots
	# keeps cur_recoil 0 / heat 0 / total_shots 0 live.
	# TurretBuild.bullet() (Turret.java:779-812) stamps them
	# after the bullet is created and handled:
	# `curRecoil = 1f;` (Turret.java:806), `heat = 1f;`
	# (:810) and `totalShots++;` (:811). The fields are
	# `public float curRecoil, heat, logicControlTime = -1;`
	# (:284) and `public int totalShots, barrelCounter;`
	# (:287), both default 0. The multi-recoil stamp
	# (`if(recoils > 0){` / `curRecoils[barrelCounter %
	# recoils] = 1f;` / `}`, :807-809) is NOT this slice:
	# duo recoils is -1 (`public int recoils = -1;`, :142),
	# so the branch is skipped. The effects / sound / shake
	# lines (:799-805) are NOT this slice either. Three
	# segments, one shared driver tick: segment 0 shoots from
	# a clean frame (recoil / heat 0, no total_shots key), so
	# its stamp is 1.0 / 1.0 / 1 and a second shot counts it
	# to 2; segment 1 shoots from a decayed frame (recoil
	# 0.5 / heat 0.3 / total_shots 7), so its stamp is still
	# 1.0 / 1.0 / 8; segment 2 has no target and no ammo, so
	# it shoots nothing and stamps nothing. The segments sit
	# 48 tiles (384px) apart -- wider than twice the 160
	# range -- so no segment can see another segment's
	# target.
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
	var bullets_before: int = int((game.get("bullets") as Array).size())

	# 0: clean frame -- shoots, stamps 1.0 / 1.0 / 1.
	frames[0]["target"] = {"x": positions[0].x + 100.0, "y": positions[0].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	frames[0]["reload_counter"] = 19.99
	frames[0]["barrel_counter"] = 0
	frames[0]["inaccuracy_draw"] = 0.0
	frames[0]["cur_recoil"] = 0.0
	frames[0]["heat"] = 0.0
	# 1: decayed frame -- shoots, stamps 1.0 / 1.0 / 8
	# (total_shots 7 + 1).
	frames[1]["target"] = {"x": positions[1].x + 100.0, "y": positions[1].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[1]["has_target"] = true
	frames[1]["reload_counter"] = 19.99
	frames[1]["barrel_counter"] = 0
	frames[1]["inaccuracy_draw"] = 0.0
	frames[1]["cur_recoil"] = 0.5
	frames[1]["heat"] = 0.3
	frames[1]["total_shots"] = 7
	# 2: no target, no ammo -- control: no shot, no spawn,
	# no stamp.

	# Seed copper ammo for 0-1 (the stacks are the
	# {"item", "amount"} dicts of
	# SourceTurretAmmoState.selected_turret_ammo_entries).
	var stacks_map: Dictionary = game.get("turret_ammo_stacks")
	var totals_map: Dictionary = game.get("turret_total_ammo")
	for index in range(2):
		var ammo_key: String = str(game.call("cell_key", cells[index]))
		stacks_map[ammo_key] = [{"item": "copper", "amount": 5}]
		totals_map[ammo_key] = 5

	# The shooting tick: 0-1 shoot (reload 19.99 + 1/60 caps
	# at 20, in cone, in range, not charging, warmed up); 2
	# does not (no target).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var recoil0_after1: float = float(frames[0].get("cur_recoil", -1.0))
	var heat0_after1: float = float(frames[0].get("heat", -1.0))
	var total0_after1: int = int(frames[0].get("total_shots", -1))
	var recoil1_after1: float = float(frames[1].get("cur_recoil", -1.0))
	var heat1_after1: float = float(frames[1].get("heat", -1.0))
	var total1_after1: int = int(frames[1].get("total_shots", -1))
	var shot0_after1: bool = bool(frames[0].get("shot", false))
	var shot1_after1: bool = bool(frames[1].get("shot", false))
	var spawn0_after1: Variant = frames[0].get("bullet_spawn", null)
	var spawn1_after1: Variant = frames[1].get("bullet_spawn", null)
	var shot2_after1: bool = bool(frames[2].get("shot", true))
	var spawn2_after1: Variant = frames[2].get("bullet_spawn", null)
	var recoil2_after1: float = float(frames[2].get("cur_recoil", -1.0))
	# Segment 2 never shoots, so no total_shots key is ever
	# stamped on its frame -- absence counts as 0.
	var total2_after1: int = int(frames[2].get("total_shots", 0))

	# The direct pure-function calls pin the stamp behind
	# the driver observables below: any decayed recoil /
	# heat maps to 1.0 and any count maps to count + 1.
	var direct_zero: Dictionary = turret_build_state.source_turret_shoot_stamp_state(0.0, 0.0, 0)
	var direct_decayed: Dictionary = turret_build_state.source_turret_shoot_stamp_state(0.5, 0.3, 7)
	var direct_counted: Dictionary = turret_build_state.source_turret_shoot_stamp_state(1.0, 1.0, 41)

	# 0: the recoil is stamped to 1.0 after the shot --
	# through the driver (clean frame) and directly (zero
	# and decayed inputs both map to 1.0).
	proof["recoil_stamped_to_1_after_shot"] = shot0_after1 and absf(recoil0_after1 - 1.0) < 0.0001 and absf(float(direct_zero.get("cur_recoil", -1.0)) - 1.0) < 0.0001 and absf(float(direct_decayed.get("cur_recoil", -1.0)) - 1.0) < 0.0001
	# 0: the heat is stamped to 1.0 after the shot --
	# through the driver (clean frame) and directly.
	proof["heat_stamped_to_1_after_shot"] = shot0_after1 and absf(heat0_after1 - 1.0) < 0.0001 and absf(float(direct_zero.get("heat", -1.0)) - 1.0) < 0.0001 and absf(float(direct_decayed.get("heat", -1.0)) - 1.0) < 0.0001
	# 0 counts 0 -> 1 and 1 counts 7 -> 8, through the
	# driver and directly (zero -> 1, decayed 7 -> 8,
	# counted 41 -> 42).
	proof["total_shots_increments_after_shot"] = shot0_after1 and shot1_after1 and total0_after1 == 1 and total1_after1 == 8 and int(direct_zero.get("total_shots", -1)) == 1 and int(direct_decayed.get("total_shots", -1)) == 8 and int(direct_counted.get("total_shots", -1)) == 42
	# 0: the frame carries the stamped recoil after the
	# shot -- the stamp runs after the bullet_spawn stamp,
	# so the same tick carries both.
	proof["recoil_stamped_to_frame_after_spawn"] = spawn0_after1 is Dictionary and absf(recoil0_after1 - 1.0) < 0.0001
	# 0: the frame carries the stamped heat after the shot
	# -- the same tick carries the spawn and the stamp.
	proof["heat_stamped_to_frame_after_spawn"] = spawn0_after1 is Dictionary and absf(heat0_after1 - 1.0) < 0.0001
	# 0: the frame carries the counted total_shots after
	# the shot -- the same tick carries the spawn and the
	# stamp.
	proof["total_shots_stamped_to_frame_after_spawn"] = spawn0_after1 is Dictionary and total0_after1 == 1
	# 0 shot and spawned a bullet, and all three values are
	# stamped on the frame in that same tick; the control
	# segment shot nothing, spawned nothing, and stamped
	# nothing (recoil stays 0, total_shots stays 0).
	proof["stamp_runs_after_bullet_spawn"] = shot0_after1 and spawn0_after1 is Dictionary and absf(recoil0_after1 - 1.0) < 0.0001 and absf(heat0_after1 - 1.0) < 0.0001 and total0_after1 == 1 and not shot2_after1 and spawn2_after1 == null and absf(recoil2_after1) < 0.0001 and total2_after1 == 0

	# A second shooting tick for segment 0: the reload is
	# re-charged to 19.99 (the first shot reset it to 0),
	# the target is still there, and the ammo (5 - 1) still
	# covers the shot. Segment 1 does not shoot again (its
	# reload is still 0 + 1/60), so it stays counted at 8.
	frames[0]["reload_counter"] = 19.99
	frames[0]["inaccuracy_draw"] = 0.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var total0_after2: int = int(frames[0].get("total_shots", -1))
	var total1_after2: int = int(frames[1].get("total_shots", -1))
	var recoil0_after2: float = float(frames[0].get("cur_recoil", -1.0))
	var heat0_after2: float = float(frames[0].get("heat", -1.0))
	var bullets: Array = game.get("bullets")

	# 0: consecutive shots count up -- 1 after the first
	# shot, 2 after the second -- and the recoil / heat are
	# stamped to 1.0 again; exactly three live bullets landed
	# (two from 0, one from 1).
	proof["total_shots_counts_consecutive_shots"] = bool(frames[0].get("shot", false)) and total0_after2 == 2 and total1_after2 == 8 and absf(recoil0_after2 - 1.0) < 0.0001 and absf(heat0_after2 - 1.0) < 0.0001 and bullets.size() == bullets_before + 3

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShootStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
