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

	# --- Turret multi-recoil stamp (N2257): N2255 only stamped
	# the singular curRecoil / heat / totalShots after a shot
	# and N2256 only decayed the cur_recoils array -- nobody
	# ever stamped frame["cur_recoils"] after a shot, so a
	# duo's fired barrel never kicked back to 1.0 live.
	# TurretBuild.bullet() (Turret.java:779-812) stamps the
	# per-barrel counter of the barrel that just fired after
	# the bullet is created and handled: `curRecoil = 1f;` /
	# `if(recoils > 0){` / `curRecoils[barrelCounter % recoils]
	# = 1f;` / `}` / `heat = 1f;` / `totalShots++;`
	# (Turret.java:806-811). The field is `public @Nullable
	# float[] curRecoils;` (:285), null until the first
	# updateTile tick allocates it (N2256 decay), and the class
	# default is `public int recoils = -1;` (:142) -- but duo
	# overrides it: `recoils = 2;` (Blocks.java:3301), so the
	# branch DOES apply to duo: its two drawer barrel parts
	# carry recoilIndex 0 / 1 (Blocks.java:3302-3311) and
	# DrawTurret reads `tb.curRecoils[part.recoilIndex]`
	# (DrawTurret.java:104/115). The barrel is the
	# pre-increment barrelCounter -- pattern.shoot runs before
	# the `}, () -> barrelCounter++);` incrementer
	# (Turret.java:770) -- so the first shot stamps entry 0
	# and the second shot stamps entry 1. Three segments, one
	# shared driver tick: segment 0 shoots from a clean frame
	# (its cur_recoils key erased, so it inits to zeros), so
	# its stamp is [1.0, 0.0] and a second shot stamps the
	# other barrel; segment 1 shoots from a decayed frame
	# (cur_recoils [0.5, 0.3]), so its stamp is [1.0, ~0.299]
	# -- the fired entry kicks to 1.0 while the other entry
	# keeps its decayed value; segment 2 has no target and no
	# ammo, so it shoots nothing and stamps nothing (its
	# cur_recoils stays [0.0, 0.0] from the decay init only).
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

	# 0: clean frame -- shoots barrel 0, stamps [1.0, 0.0]
	# (its cur_recoils key is erased, so it inits to zeros).
	frames[0].erase("cur_recoils")
	frames[0]["target"] = {"x": positions[0].x + 100.0, "y": positions[0].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	frames[0]["reload_counter"] = 19.99
	frames[0]["barrel_counter"] = 0
	frames[0]["inaccuracy_draw"] = 0.0
	# 1: decayed frame -- shoots barrel 0, stamps [1.0,
	# ~0.299] (entry 0 kicks to 1.0, entry 1 keeps its
	# decayed value 0.3 - (1/60)/20).
	frames[1]["cur_recoils"] = [0.5, 0.3]
	frames[1]["target"] = {"x": positions[1].x + 100.0, "y": positions[1].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[1]["has_target"] = true
	frames[1]["reload_counter"] = 19.99
	frames[1]["barrel_counter"] = 0
	frames[1]["inaccuracy_draw"] = 0.0
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
	var multi0_after1: Array = frames[0].get("cur_recoils", [])
	var multi1_after1: Array = frames[1].get("cur_recoils", [])
	var multi2_after1: Array = frames[2].get("cur_recoils", [])
	var recoil0_after1: float = float(frames[0].get("cur_recoil", -1.0))
	var shot0_after1: bool = bool(frames[0].get("shot", false))
	var shot1_after1: bool = bool(frames[1].get("shot", false))
	var spawn0_after1: Variant = frames[0].get("bullet_spawn", null)
	var shot2_after1: bool = bool(frames[2].get("shot", true))
	var spawn2_after1: Variant = frames[2].get("bullet_spawn", null)

	# The direct pure-function calls pin the stamp behind the
	# driver observables below: an absent key inits to zeros
	# and stamps the fired barrel, a decayed frame keeps its
	# other entry, barrel 2 wraps to entry 0 (barrel % recoils),
	# and recoils <= 0 returns the input unchanged.
	var direct_zero: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([], 0, 2)
	var direct_decayed: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([0.5, 0.3], 0, 2)
	var direct_wrap: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([0.0, 0.0], 2, 2)
	var direct_wrap3: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([0.0, 0.0], 3, 2)
	var direct_guard: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([0.5, 0.3], 0, 0)
	var direct_guard_neg: Dictionary = turret_build_state.source_turret_multi_recoil_stamp_state([0.5, 0.3], 1, -1)
	var direct_zero_arr: Array = direct_zero.get("cur_recoils", [])
	var direct_decayed_arr: Array = direct_decayed.get("cur_recoils", [])
	var direct_wrap_arr: Array = direct_wrap.get("cur_recoils", [])
	var direct_wrap3_arr: Array = direct_wrap3.get("cur_recoils", [])
	var direct_guard_arr: Array = direct_guard.get("cur_recoils", [])
	var direct_guard_neg_arr: Array = direct_guard_neg.get("cur_recoils", [])
	# The pure function never mutates its input: the array
	# passed in keeps its entries after the call.
	var input_arr: Array = [0.5, 0.3]
	turret_build_state.source_turret_multi_recoil_stamp_state(input_arr, 0, 2)

	# 0: the fired barrel stamps to 1.0 after the shot --
	# through the driver (clean frame, barrel 0) and directly
	# (an absent key inits to zeros and stamps entry 0).
	proof["multi_recoil_stamp_sets_fired_barrel"] = shot0_after1 and multi0_after1.size() == 2 and absf(float(multi0_after1[0]) - 1.0) < 0.0001 and direct_zero_arr.size() == 2 and absf(float(direct_zero_arr[0]) - 1.0) < 0.0001
	# 0: the other barrel stays untouched after the shot --
	# through the driver (entry 1 stays 0.0) and directly
	# (the absent-key call leaves entry 1 at 0.0).
	proof["multi_recoil_stamp_other_barrel_untouched"] = shot0_after1 and multi0_after1.size() == 2 and absf(float(multi0_after1[1])) < 0.0001 and direct_zero_arr.size() == 2 and absf(float(direct_zero_arr[1])) < 0.0001
	# 1: the fired entry kicks to 1.0 while the other entry
	# keeps its decayed value -- through the driver (entry 1
	# is 0.3 - (1/60)/20 after the decay tick that runs before
	# the shot) and directly ([0.5, 0.3] -> [1.0, 0.3], the
	# pure function itself never decays).
	proof["multi_recoil_stamp_preserves_other_entries"] = shot1_after1 and multi1_after1.size() == 2 and absf(float(multi1_after1[0]) - 1.0) < 0.0001 and absf(float(multi1_after1[1]) - 0.2991667) < 0.001 and direct_decayed_arr.size() == 2 and absf(float(direct_decayed_arr[0]) - 1.0) < 0.0001 and absf(float(direct_decayed_arr[1]) - 0.3) < 0.0001
	# 0: an absent key inits to zeros and stamps the fired
	# barrel -- through the driver (the erased key becomes
	# [1.0, 0.0] after the shot) and directly ([] -> [1.0, 0.0]).
	proof["multi_recoil_stamp_init_zeros_when_absent"] = shot0_after1 and multi0_after1.size() == 2 and absf(float(multi0_after1[0]) - 1.0) < 0.0001 and absf(float(multi0_after1[1])) < 0.0001 and direct_zero_arr.size() == 2 and absf(float(direct_zero_arr[0]) - 1.0) < 0.0001 and absf(float(direct_zero_arr[1])) < 0.0001
	# 0: the stamped array is on the frame after the shot --
	# a length-2 array with the fired entry at 1.0.
	proof["multi_recoil_stamp_stamped_to_frame_after_shoot"] = shot0_after1 and multi0_after1.size() == 2 and absf(float(multi0_after1[0]) - 1.0) < 0.0001
	# 0 shot and spawned a bullet, and the singular stamp and
	# the multi-recoil stamp land on the frame in that same
	# tick (curRecoil 1.0 and cur_recoils[0] 1.0 together);
	# the control segment shot nothing, spawned nothing, and
	# stamped nothing (its cur_recoils stays [0.0, 0.0] from
	# the decay init only).
	proof["multi_recoil_stamp_runs_after_singular_stamp"] = shot0_after1 and spawn0_after1 is Dictionary and absf(recoil0_after1 - 1.0) < 0.0001 and multi0_after1.size() == 2 and absf(float(multi0_after1[0]) - 1.0) < 0.0001 and not shot2_after1 and spawn2_after1 == null and multi2_after1.size() == 2 and absf(float(multi2_after1[0])) < 0.0001 and absf(float(multi2_after1[1])) < 0.0001
	# Barrel 2 wraps to entry 0 and barrel 3 wraps to entry 1
	# (barrel % recoils, recoils 2), directly.
	proof["multi_recoil_stamp_wraps_modulo"] = direct_wrap_arr.size() == 2 and absf(float(direct_wrap_arr[0]) - 1.0) < 0.0001 and absf(float(direct_wrap_arr[1])) < 0.0001 and direct_wrap3_arr.size() == 2 and absf(float(direct_wrap3_arr[0])) < 0.0001 and absf(float(direct_wrap3_arr[1]) - 1.0) < 0.0001
	# When recoils <= 0 the Java guard does nothing: the
	# function returns the input unchanged (recoils 0 and -1
	# both keep [0.5, 0.3]), and the input array is never
	# mutated by a stamping call.
	proof["multi_recoil_stamp_guard_returns_input_unchanged"] = direct_guard_arr.size() == 2 and absf(float(direct_guard_arr[0]) - 0.5) < 0.0001 and absf(float(direct_guard_arr[1]) - 0.3) < 0.0001 and direct_guard_neg_arr.size() == 2 and absf(float(direct_guard_neg_arr[0]) - 0.5) < 0.0001 and absf(float(direct_guard_neg_arr[1]) - 0.3) < 0.0001 and input_arr.size() == 2 and absf(float(input_arr[0]) - 0.5) < 0.0001 and absf(float(input_arr[1]) - 0.3) < 0.0001

	# A second shooting tick for segment 0: the reload is
	# re-charged to 19.99 (the first shot reset it to 0),
	# the target is still there, and the ammo (5 - 1) still
	# covers the shot. Segment 1 does not shoot again (its
	# reload is still 0 + 1/60), so its stamp stays at [1.0,
	# ~0.299]. Segment 0's barrel_counter is now 1, so the
	# second shot stamps the OTHER barrel (entry 1) while
	# entry 0 only decays a tick (1.0 - (1/60)/20).
	frames[0]["reload_counter"] = 19.99
	frames[0]["inaccuracy_draw"] = 0.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var multi0_after2: Array = frames[0].get("cur_recoils", [])
	var shot0_after2: bool = bool(frames[0].get("shot", false))

	# 0: consecutive shots alternate barrels -- the second
	# shot stamps entry 1 to 1.0 while entry 0 only decays
	# a tick (still above 0.99, below 1.0).
	proof["multi_recoil_stamp_alternates_barrels"] = shot0_after2 and multi0_after2.size() == 2 and absf(float(multi0_after2[1]) - 1.0) < 0.0001 and float(multi0_after2[0]) < 1.0 and float(multi0_after2[0]) > 0.99

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretMultiRecoilStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
