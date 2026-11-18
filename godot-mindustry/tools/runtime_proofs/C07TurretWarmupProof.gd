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

	# --- Turret warmup lerp advance (N2253): the driver read
	# frame["shoot_warmup"] (SourceTurretBuildState.gd:317,
	# default 0.0) as the aim/shoot gate input but NEVER stamped
	# it back -- warmup never advanced live. TurretBuild.updateTile()
	# (Turret.java:490-515) advances it before it aims or shoots:
	# `float warmupTarget = (isShooting && canConsume()) ||
	# charging() ? 1f : 0f;` (Turret.java:502), the hold
	# (`if(warmupTarget > 0 && !controlled()){ warmupHold = 1f; }` /
	# `if(warmupHold > 0f){ warmupHold -= Time.delta /
	# warmupMaintainTime; warmupTarget = 1f; }`, :503-509), then
	# the lerp (`if(linearWarmup){` /
	# `shootWarmup = Mathf.approachDelta(shootWarmup, warmupTarget,
	# shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));` /
	# `}else{` /
	# `shootWarmup = Mathf.lerpDelta(shootWarmup, warmupTarget,
	# shootWarmupSpeed * (warmupTarget > 0 ? efficiency : 1f));`,
	# :511-515 -- arc Mathf approach / approachDelta / lerp /
	# lerpDelta, Mathf.java:402-432). The duo def overrides NONE
	# of minWarmup 0f / warmupMaintainTime 0f / shootWarmupSpeed
	# 0.1f / linearWarmup false (Turret.java:76/:84/:136/:138), so
	# the driver passes 0.1 / false / 0.0. With maintainTime 0 the
	# hold division is +inf, so the hold ends on the very tick it
	# is set (the test pins warmup_hold <= 0.0 after that tick,
	# never exactly -inf). Two segments, one shared driver tick:
	# segment 0 shoots with a target and copper ammo, so its
	# warmup rises toward 1 and the duo minWarmup 0 gate still
	# passes; segment 1 has no target and a seeded warmup of
	# 0.5, so its warmup falls toward 0. The hold / linear /
	# efficiency branches are pinned by direct pure-function
	# calls (the driver only ever passes the duo defaults).
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
	var positions: Array[Vector2] = []
	for segment in segments:
		positions.append(segment.position)

	# One shared tick wires team_id / cheating / enabled onto
	# every frame (and charges each reload by 1/60, which the
	# pre-charge below overwrites where it matters).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# 0: target + copper ammo, reload pre-charged to 19.99 --
	# shoots on the first tick and keeps shooting warmup.
	frames[0]["target"] = {"x": positions[0].x + 100.0, "y": positions[0].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	frames[0]["reload_counter"] = 19.99
	frames[0]["barrel_counter"] = 0
	frames[0]["inaccuracy_draw"] = 0.0
	# 1: no target, warmup seeded at 0.5 -- falls toward 0.
	frames[1]["shoot_warmup"] = 0.5

	# Seed copper ammo for 0 (the stacks are the {"item",
	# "amount"} dicts of SourceTurretAmmoState; peek amount 5
	# >= ammoPerShot 1, so can_consume is true).
	var stacks_map: Dictionary = game.get("turret_ammo_stacks")
	var totals_map: Dictionary = game.get("turret_total_ammo")
	var ammo_key0: String = str(game.call("cell_key", cells[0]))
	stacks_map[ammo_key0] = [{"item": "copper", "amount": 5}]
	totals_map[ammo_key0] = 5

	# The first shooting tick: 0 shoots (reload 19.99 + 1/60
	# caps at 20, in cone, in range, not charging, warmed up
	# past minWarmup 0); 1 does not (no target).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var warmup0_after1: float = float(frames[0].get("shoot_warmup", 0.0))
	var warmup1_after1: float = float(frames[1].get("shoot_warmup", 0.5))
	var shot0: bool = bool(frames[0].get("shot", false))

	# 59 more ticks: 0 keeps its target and ammo, so its warmup
	# keeps rising; 1 keeps falling toward 0.
	for iteration in range(59):
		turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(2):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var warmup0_after60: float = float(frames[0].get("shoot_warmup", 0.0))
	var warmup1_after60: float = float(frames[1].get("shoot_warmup", 0.5))

	# The direct pure-function calls pin the hold / linear /
	# efficiency branches behind the driver observables below.
	# Rising while shooting (duo defaults, delta 1/60).
	var direct_rise: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.0, true, true, false, false, 1.0, 1.0 / 60.0, 0.1, false, 0.0)
	# Falling with no target (duo defaults, delta 1/60).
	var direct_fall: Dictionary = turret_build_state.source_turret_warmup_state(0.5, 0.0, false, true, false, false, 1.0, 1.0 / 60.0, 0.1, false, 0.0)
	# Hold with maintainTime 1.0: not shooting, hold 0.5 --
	# the hold decays by delta / 1.0 and keeps the target 1.
	var direct_hold: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.5, false, false, false, false, 1.0, 1.0 / 60.0, 0.1, false, 1.0)
	# Hold with maintainTime 0.0 (duo default): shooting sets
	# the hold, then delta / 0.0 = +inf ends it on the same
	# tick; the next tick, not shooting, targets 0.
	var direct_hold_zero_1: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.0, true, true, false, false, 1.0, 1.0 / 60.0, 0.1, false, 0.0)
	var direct_hold_zero_2: Dictionary = turret_build_state.source_turret_warmup_state(float(direct_hold_zero_1.get("shoot_warmup", 0.0)), float(direct_hold_zero_1.get("warmup_hold", 0.0)), false, true, false, false, 1.0, 1.0 / 60.0, 0.1, false, 0.0)
	# Linear branch: delta 1.0, rate 0.1 -- one fixed step of
	# 0.1 toward 1, then one fixed step of 0.1 toward 0.
	var direct_linear_up: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.0, true, true, false, false, 1.0, 1.0, 0.1, true, 0.0)
	var direct_linear_down: Dictionary = turret_build_state.source_turret_warmup_state(0.5, 0.0, false, true, false, false, 1.0, 1.0, 0.1, true, 0.0)
	# Efficiency: delta 1.0, target 1 -- eff 0.5 rises half as
	# fast as eff 1.0; target 0 -- the rate is unscaled even
	# at eff 0.5 (Turret.java:512-514, `warmupTarget > 0 ?
	# efficiency : 1f`).
	var direct_eff_half: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.0, true, true, false, false, 0.5, 1.0, 0.1, false, 0.0)
	var direct_eff_full: Dictionary = turret_build_state.source_turret_warmup_state(0.0, 0.0, true, true, false, false, 1.0, 1.0, 0.1, false, 0.0)
	var direct_eff_fall: Dictionary = turret_build_state.source_turret_warmup_state(0.5, 0.0, false, true, false, false, 0.5, 1.0, 0.1, false, 0.0)

	# 0: the warmup rises toward 1 while shooting -- through
	# the driver (60 ticks, still below 1) and directly (one
	# lerp step from 0 is 0.1 / 60).
	proof["warmup_rises_toward_1_while_shooting"] = warmup0_after1 > 0.0 and warmup0_after60 > warmup0_after1 and warmup0_after60 < 1.0 and absf(float(direct_rise.get("shoot_warmup", -1.0)) - 0.1 / 60.0) < 0.0001 and float(direct_rise.get("warmup_target", -1.0)) == 1.0
	# 1: the warmup falls toward 0 with no target -- through
	# the driver (60 ticks, still above 0) and directly.
	proof["warmup_falls_toward_0_when_no_target"] = warmup1_after1 < 0.5 and warmup1_after60 < warmup1_after1 and warmup1_after60 > 0.0 and float(direct_fall.get("shoot_warmup", -1.0)) < 0.5 and float(direct_fall.get("shoot_warmup", -1.0)) > 0.0 and float(direct_fall.get("warmup_target", -1.0)) == 0.0
	# Hold with maintainTime > 0: the hold decays slowly and
	# keeps the target at 1 while it lasts.
	proof["warmup_hold_keeps_target_1"] = float(direct_hold.get("warmup_target", -1.0)) == 1.0 and float(direct_hold.get("warmup_hold", -1.0)) > 0.0 and float(direct_hold.get("warmup_hold", -1.0)) < 0.5 and float(direct_hold.get("shoot_warmup", -1.0)) > 0.0
	# Hold with maintainTime 0 (duo default): the hold ends on
	# the tick it is set, so the next non-shooting tick targets 0.
	proof["warmup_hold_zero_maintain_no_extend"] = float(direct_hold_zero_1.get("warmup_hold", 1.0)) <= 0.0 and float(direct_hold_zero_2.get("warmup_target", -1.0)) == 0.0
	# Linear branch: fixed approach steps of rate * delta.
	proof["warmup_linear_approach_branch"] = absf(float(direct_linear_up.get("shoot_warmup", -1.0)) - 0.1) < 0.001 and absf(float(direct_linear_down.get("shoot_warmup", -1.0)) - 0.4) < 0.001
	# Efficiency scales the rise when the target is 1, and the
	# fall is unscaled when the target is 0.
	proof["warmup_efficiency_scales_rise"] = absf(float(direct_eff_half.get("shoot_warmup", -1.0)) - 0.05) < 0.001 and absf(float(direct_eff_full.get("shoot_warmup", -1.0)) - 0.1) < 0.001 and absf(float(direct_eff_fall.get("shoot_warmup", -1.0)) - 0.45) < 0.001
	# 0: the frame carries the advanced warmup after the first
	# tick -- the warmup tick runs BEFORE the aim/shoot call,
	# so aim reads the advanced value.
	proof["warmup_stamped_to_frame_before_aim"] = warmup0_after1 > 0.0 and float(frames[0].get("warmup_hold", 1.0)) <= 0.0 and shot0
	# 0: the duo minWarmup 0 gate still passes -- the segment
	# shot on the first tick with a warmup of only ~0.0017.
	proof["warmup_min_warmup_gate_still_passes_duo"] = shot0 and warmup0_after1 < 0.01

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretWarmupProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
