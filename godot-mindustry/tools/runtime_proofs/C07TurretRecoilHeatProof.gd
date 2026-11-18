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

	# --- Turret recoil + heat decay (N2254): the driver never
	# read frame["cur_recoil"] or frame["heat"] -- there is no
	# such key in SourceTurretBuildState.gd at all -- so recoil
	# and heat never decayed live. TurretBuild.updateTile()
	# (Turret.java:490-532) decays them after the warmup advance
	# and before it aims or shoots:
	# `curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);`
	# (Turret.java:519) and `heat = Mathf.approachDelta(heat, 0, 1 /
	# cooldownTime);` (:526). approachDelta is
	# `public static float approachDelta(float from, float to, float speed){` /
	# `return approach(from, to, Time.delta * speed);` (arc
	# Mathf.java:420-422) with approach
	# `public static float approach(float from, float to, float speed){` /
	# `return from + Mathf.clamp(to - from, -speed, speed);`
	# (:415-417), so each tick moves the value toward 0 by delta /
	# recoilTime (resp. delta / cooldownTime), never past 0. The
	# class defaults are `public float recoil = 1f;` (:140),
	# `public int recoils = -1;` (:142),
	# `public float recoilTime = -1f;` (:144),
	# `public float recoilPow = 1.8f;` (:146),
	# `public float cooldownTime = 20f;` (:148); the init is
	# `if(recoilTime < 0f) recoilTime = reload;` /
	# `if(cooldownTime < 0f) cooldownTime = reload;` (:208-209 --
	# duo reload is 20, N2250, so recoilTime is 20 and
	# cooldownTime stays 20, a 0.05-per-tick rate). The
	# multi-recoil loop (`if(recoils > 0){` / `if(curRecoils ==
	# null) curRecoils = new float[recoils];` / `for(int i = 0; i
	# < recoils; i++){` / `curRecoils[i] =
	# Mathf.approachDelta(curRecoils[i], 0, 1 / recoilTime);` /
	# `}`, :520-525) is NOT this slice: duo recoils is -1, so
	# the loop is skipped. The shoot stamp (`curRecoil = 1f;` /
	# `heat = 1f;`, :807-810) and the draw offset
	# (`recoilOffset.trns(rotation, -Mathf.pow(curRecoil,
	# recoilPow) * recoil);`, :532) are NOT this slice either.
	# Two segments, one shared driver tick: segment 0 is seeded
	# with cur_recoil 1.0 / heat 1.0 (as just after a shot), so
	# its recoil and heat decay toward 0 through the driver;
	# segment 1 is seeded 0.0 / 0.0, so it stays at 0. The
	# rate / reach-0 branches are pinned by direct pure-function
	# calls (the driver only ever passes the duo 20.0 / 20.0).
	# The segments sit 48 tiles (384px) apart -- wider than
	# twice the 160 range -- so no segment can see another
	# segment's target.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(76, 21)]
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
	# every frame (and charges each reload by 1/60).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# 0: seeded as just after a shot -- recoil and heat 1.0,
	# no target (the decay runs regardless of target: Java
	# order :519/:526 is unconditional in updateTile).
	frames[0]["cur_recoil"] = 1.0
	frames[0]["heat"] = 1.0
	# 1: already decayed -- stays at 0.0.
	frames[1]["cur_recoil"] = 0.0
	frames[1]["heat"] = 0.0

	# The first tick: 0 decays by delta / 20 = (1/60) / 20 =
	# 1/1200; 1 stays at 0.
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var recoil0_after1: float = float(frames[0].get("cur_recoil", -1.0))
	var heat0_after1: float = float(frames[0].get("heat", -1.0))
	var recoil1_after1: float = float(frames[1].get("cur_recoil", -1.0))
	var heat1_after1: float = float(frames[1].get("heat", -1.0))

	# 59 more ticks: 0 keeps decaying (60 ticks total, 1.0 -
	# 60/1200 = 0.95); 1 stays at 0.
	for iteration in range(59):
		turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var recoil0_after60: float = float(frames[0].get("cur_recoil", -1.0))
	var heat0_after60: float = float(frames[0].get("heat", -1.0))

	# The direct pure-function calls pin the rate / reach-0 /
	# never-past-0 branches behind the driver observables below.
	# One tick at delta 1.0, duo rates: step 1/20 = 0.05.
	var direct_step: Dictionary = turret_build_state.source_turret_recoil_heat_state(1.0, 1.0, 20.0, 20.0, 1.0)
	# Split rates: recoil_time 10.0 steps 0.1, cooldown_time
	# 40.0 steps 0.025 -- the two rates are independent.
	var direct_split: Dictionary = turret_build_state.source_turret_recoil_heat_state(1.0, 1.0, 10.0, 40.0, 1.0)
	# 20 ticks at delta 1.0 from 1.0: reaches exactly 0.0;
	# after 19 ticks it is still above 0.
	var direct_recoil: float = 1.0
	var direct_heat: float = 1.0
	var direct_recoil_19: float = 1.0
	var direct_heat_19: float = 1.0
	for iteration in range(20):
		var step: Dictionary = turret_build_state.source_turret_recoil_heat_state(direct_recoil, direct_heat, 20.0, 20.0, 1.0)
		direct_recoil = float(step.get("cur_recoil", -1.0))
		direct_heat = float(step.get("heat", -1.0))
		if iteration == 18:
			direct_recoil_19 = direct_recoil
			direct_heat_19 = direct_heat
	# Small value: 0.03 with a 0.05 step clamps to exactly 0,
	# never past it; zero stays zero.
	var direct_small: Dictionary = turret_build_state.source_turret_recoil_heat_state(0.03, 0.03, 20.0, 20.0, 1.0)
	var direct_zero: Dictionary = turret_build_state.source_turret_recoil_heat_state(0.0, 0.0, 20.0, 20.0, 1.0)

	# 0: the recoil decays toward 0 after a shot -- through
	# the driver (60 ticks, still above 0) and directly (one
	# step from 1.0 is 0.95).
	proof["recoil_decays_toward_0_after_shot"] = recoil0_after1 < 1.0 and recoil0_after60 < recoil0_after1 and recoil0_after60 > 0.0 and absf(float(direct_step.get("cur_recoil", -1.0)) - 0.95) < 0.0001
	# Direct 20-tick loop: 1.0 reaches 0.0 within recoil_time
	# 20 ticks (still above 0 after 19), and the small value
	# clamps to exactly 0 instead of going past it.
	proof["recoil_reaches_0_within_recoil_time"] = absf(direct_recoil) < 0.0001 and direct_recoil_19 > 0.0 and absf(float(direct_small.get("cur_recoil", -1.0))) < 0.0001 and absf(float(direct_zero.get("cur_recoil", -1.0))) < 0.0001
	# 0: the heat decays toward 0 after a shot -- through the
	# driver (60 ticks, still above 0) and directly.
	proof["heat_decays_toward_0_after_shot"] = heat0_after1 < 1.0 and heat0_after60 < heat0_after1 and heat0_after60 > 0.0 and absf(float(direct_step.get("heat", -1.0)) - 0.95) < 0.0001
	# Direct 20-tick loop: 1.0 reaches 0.0 within cooldown_time
	# 20 ticks (still above 0 after 19), and the small value
	# clamps to exactly 0 instead of going past it.
	proof["heat_reaches_0_within_cooldown_time"] = absf(direct_heat) < 0.0001 and direct_heat_19 > 0.0 and absf(float(direct_small.get("heat", -1.0))) < 0.0001 and absf(float(direct_zero.get("heat", -1.0))) < 0.0001
	# 0: the frame carries the decayed recoil after the first
	# tick -- the decay tick runs BEFORE the aim/shoot call, so
	# aim reads the decayed value; 1 stays at exactly 0.
	proof["recoil_stamped_to_frame_before_aim"] = absf(recoil0_after1 - (1.0 - 1.0 / 1200.0)) < 0.0001 and absf(recoil1_after1) < 0.0001
	# 0: the frame carries the decayed heat after the first
	# tick -- the decay tick runs BEFORE the aim/shoot call, so
	# aim reads the decayed value; 1 stays at exactly 0.
	proof["heat_stamped_to_frame_before_aim"] = absf(heat0_after1 - (1.0 - 1.0 / 1200.0)) < 0.0001 and absf(heat1_after1) < 0.0001
	# The recoil step is exactly delta / recoil_time: 0.05 at
	# delta 1.0 / recoil_time 20, 0.1 at recoil_time 10, and
	# the driver agrees after 60 ticks at delta 1/60 (0.95).
	proof["recoil_decay_rate_is_one_over_recoil_time"] = absf(float(direct_step.get("cur_recoil", -1.0)) - 0.95) < 0.0001 and absf(float(direct_split.get("cur_recoil", -1.0)) - 0.9) < 0.0001 and absf(recoil0_after60 - 0.95) < 0.001
	# The heat step is exactly delta / cooldown_time: 0.05 at
	# delta 1.0 / cooldown_time 20, 0.025 at cooldown_time 40,
	# and the driver agrees after 60 ticks at delta 1/60 (0.95).
	proof["heat_decay_rate_is_one_over_cooldown_time"] = absf(float(direct_step.get("heat", -1.0)) - 0.95) < 0.0001 and absf(float(direct_split.get("heat", -1.0)) - 0.975) < 0.0001 and absf(heat0_after60 - 0.95) < 0.001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretRecoilHeatProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
