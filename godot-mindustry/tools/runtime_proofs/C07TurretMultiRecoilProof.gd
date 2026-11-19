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

	# --- Turret multi-recoil decay (N2256): N2254 only decayed
	# the singular curRecoil and N2255 only stamped the singular
	# curRecoil -- nobody ever decayed frame["cur_recoils"], so a
	# duo's barrel recoil never fell back toward 0 live.
	# TurretBuild.updateTile() (Turret.java:490-532) decays the
	# per-barrel counters right after the singular recoil decay:
	# `if(recoils > 0){` / `if(curRecoils == null) curRecoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` / `curRecoils[i] = Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` / `}`
	# (Turret.java:520-525). The field is `public @Nullable
	# float[] curRecoils;` (:285), null until the first
	# updateTile tick allocates it, and the class default is
	# `public int recoils = -1;` (:142) -- but duo overrides it:
	# `recoils = 2;` (Blocks.java:3301), so the loop DOES apply
	# to duo: its two drawer barrel parts carry recoilIndex 0 /
	# 1 (Blocks.java:3302-3311) and DrawTurret reads
	# `tb.curRecoils[part.recoilIndex]` (DrawTurret.java:104/115).
	# The init is `if(recoilTime < 0f) recoilTime = reload;`
	# (:208 -- duo reload is 20, N2250), so each entry steps
	# toward 0 by delta / 20, never past 0. Three segments, one
	# shared driver tick with delta 1.0 (a 0.05 step per entry):
	# segment 0 decays [0.5, 0.3] to [0.45, 0.25] and its
	# singular curRecoil 0.5 to 0.45 in the same tick; segment 1
	# decays [0.0, 0.5] to [0.0, 0.45], so the second entry
	# decays independently of the first; segment 2 has its
	# cur_recoils key erased before the tick, so it inits to
	# [0.0, 0.0]. The segments sit 48 tiles (384px) apart --
	# wider than twice the 160 range -- so no segment can see
	# another segment's target. No segment shoots (no target,
	# no ammo), so the decay runs on its own.
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

	# One shared tick wires team_id / cheating / enabled onto
	# every frame -- and stamps cur_recoils [0.0, 0.0] on each,
	# since the decay tick builds a fresh length-2 array even
	# from an absent key.
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# 0: decays [0.5, 0.3] -> [0.45, 0.25]; singular
	# curRecoil 0.5 -> 0.45 in the same tick.
	frames[0]["cur_recoils"] = [0.5, 0.3]
	frames[0]["cur_recoil"] = 0.5
	# 1: decays [0.0, 0.5] -> [0.0, 0.45]; the first entry
	# stays 0 while the second decays on its own.
	frames[1]["cur_recoils"] = [0.0, 0.5]
	frames[1]["cur_recoil"] = 0.0
	# 2: the key is erased, so the tick must init it to
	# [0.0, 0.0] -- the null-until-first-tick Java field.
	frames[2].erase("cur_recoils")

	# The decay tick with delta 1.0: a 0.05 step per entry
	# (delta / recoilTime, recoilTime 20).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0)
	for index in range(3):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var multi0_after: Array = frames[0].get("cur_recoils", [])
	var multi1_after: Array = frames[1].get("cur_recoils", [])
	var multi2_after: Array = frames[2].get("cur_recoils", [])
	var recoil0_after: float = float(frames[0].get("cur_recoil", -1.0))

	# The direct pure-function calls pin the decay behind the
	# driver observables below: the step matches delta /
	# recoilTime, a huge delta never passes 0, and an absent
	# key inits to zeros.
	var direct_rate: Dictionary = turret_build_state.source_turret_multi_recoil_state([1.0, 0.8], 2, 20.0, 1.0)
	var direct_never_past: Dictionary = turret_build_state.source_turret_multi_recoil_state([0.01, 0.0], 2, 20.0, 60.0)
	var direct_absent: Dictionary = turret_build_state.source_turret_multi_recoil_state([], 2, 20.0, 1.0)
	var direct_rate_arr: Array = direct_rate.get("cur_recoils", [])
	var direct_never_past_arr: Array = direct_never_past.get("cur_recoils", [])
	var direct_absent_arr: Array = direct_absent.get("cur_recoils", [])

	# 0: the first entry decays toward 0 through the driver
	# (0.5 -> 0.45, still above 0).
	proof["multi_recoil_decays_toward_zero"] = multi0_after.size() == 2 and float(multi0_after[0]) > 0.0 and float(multi0_after[0]) < 0.5
	# 0: both entries decay through the driver (0.5 -> 0.45
	# and 0.3 -> 0.25).
	proof["multi_recoil_both_entries_decay"] = multi0_after.size() == 2 and float(multi0_after[0]) < 0.5 and float(multi0_after[1]) < 0.3
	# A huge delta never passes 0: directly ([0.01, 0.0] with
	# delta 60.0 -> [0.0, 0.0]) and through the driver (1's
	# first entry stays 0.0).
	proof["multi_recoil_never_past_zero"] = direct_never_past_arr.size() == 2 and absf(float(direct_never_past_arr[0])) < 0.0001 and absf(float(direct_never_past_arr[1])) < 0.0001 and multi1_after.size() == 2 and absf(float(multi1_after[0])) < 0.0001
	# 2: an absent key inits to zeros through the driver
	# ([0.0, 0.0]) and directly ([] -> [0.0, 0.0]).
	proof["multi_recoil_init_zeros_when_absent"] = multi2_after.size() == 2 and absf(float(multi2_after[0])) < 0.0001 and absf(float(multi2_after[1])) < 0.0001 and direct_absent_arr.size() == 2 and absf(float(direct_absent_arr[0])) < 0.0001 and absf(float(direct_absent_arr[1])) < 0.0001
	# The step matches delta / recoilTime: directly ([1.0,
	# 0.8] with delta 1.0 -> [0.95, 0.75]) and through the
	# driver (0.5 -> 0.45 and 0.3 -> 0.25, a 0.05 step).
	proof["multi_recoil_rate_matches_recoil_time"] = direct_rate_arr.size() == 2 and absf(float(direct_rate_arr[0]) - 0.95) < 0.0001 and absf(float(direct_rate_arr[1]) - 0.75) < 0.0001 and multi0_after.size() == 2 and absf(float(multi0_after[0]) - 0.45) < 0.0001 and absf(float(multi0_after[1]) - 0.25) < 0.0001
	# 0: the decayed array is stamped on the frame after the
	# tick (a length-2 array, not a stale or absent key).
	proof["multi_recoil_stamped_to_frame_after_decay"] = multi0_after.size() == 2 and absf(float(multi0_after[0]) - 0.45) < 0.0001 and absf(float(multi0_after[1]) - 0.25) < 0.0001
	# 0: the multi-recoil decay runs in the same tick as the
	# singular recoil decay -- the singular curRecoil 0.5 ->
	# 0.45 and the multi entries [0.5, 0.3] -> [0.45, 0.25]
	# together (Java order :519 then :520-525).
	proof["multi_recoil_decay_runs_after_singular_decay"] = absf(recoil0_after - 0.45) < 0.0001 and multi0_after.size() == 2 and absf(float(multi0_after[0]) - 0.45) < 0.0001 and absf(float(multi0_after[1]) - 0.25) < 0.0001
	# 1: the second entry decays independently of the first
	# ([0.0, 0.5] -> [0.0, 0.45]: the first stays 0.0 while
	# the second steps by exactly 0.05).
	proof["multi_recoil_second_entry_decays_independently"] = multi1_after.size() == 2 and absf(float(multi1_after[0])) < 0.0001 and absf(float(multi1_after[1]) - 0.45) < 0.0001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretMultiRecoilProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
