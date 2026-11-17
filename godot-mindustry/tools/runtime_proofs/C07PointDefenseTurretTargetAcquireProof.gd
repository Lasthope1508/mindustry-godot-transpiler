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

	# --- PointDefenseTurret target acquisition (N2239):
	# PointDefenseBuild.updateTile re-acquires the nearest
	# enemy hittable bullet in the range rect every
	# retargetTime (`if(timer(timerTarget, retargetTime)){` /
	# `target = Groups.bullet.intersect(x - range, y -
	# range, range*2, range*2).min(b -> b.team != team &&
	# b.type().hittable, b -> b.dst2(this));`,
	# PointDefenseTurret.java:65-67), and a pooled bullet
	# is nulled (`if(target != null &&
	# !target.isAdded()){` / `target = null;`,
	# PointDefenseTurret.java:69-71). The timer slot is
	# `public final int timerTarget = timers++;`
	# (PointDefenseTurret.java:20) with `public float
	# retargetTime = 5f;` (PointDefenseTurret.java:21) on a
	# per-building Interval (`transient Interval timer = new
	# Interval(6);`, TimerComp.java:8); `timer()`
	# (TimerComp.java:10-12) delegates to `Interval.get`,
	# which fires on elapsed game time (`return Time.time
	# - times[id] >= time || Time.time < times[id];`,
	# Interval.java:29, times[] init 0, so the first fire
	# is at Time.time >= 5) and stamps the fire time
	# (`if(got) times[id] = Time.time;`, Interval.java:24).
	# RED decisions pinned here: the re-acquire is
	# timer-gated (no target before the first 5s fire --
	# the Interval.get model); the invalidation reads the
	# CURRENT bullet record (looked up by `id` -- a target
	# whose id is absent from the list is pooled); the
	# re-acquire replaces the target unconditionally on
	# fire, even a still-valid one; the driver stamps
	# target / has_target / target_timer on the frame every
	# tick, UNCONDITIONAL on power, but only once a caller
	# provides `observed_bullets` (the live game bullets
	# carry no team/hittable/id yet). Six segments, one
	# shared driver tick each phase: A picks the closest
	# enemy hittable, B proves the timer gate, C proves
	# same-team is ignored, D proves non-hittable is
	# ignored, E proves out-of-rect is ignored, F proves
	# the acquisition runs without power.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(30, 21), Vector2i(32, 21), Vector2i(34, 21), Vector2i(36, 21), Vector2i(38, 21)]
	var segments: Array[Sprite2D] = []
	for cell in cells:
		var segment := Sprite2D.new()
		game.add_child(segment)
		game.call("record_placed_block", segment, blocks_by_id["segment"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every segment sits at the origin (0, 0)
		# and the turret-centred query cannot be distinguished
		# from an origin-centred one. Seed the position exactly
		# the way the game does (the N2211 proof lesson).
		segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], cell)
		point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
		segments.append(segment)
	var frames: Array[Dictionary] = []
	for segment in segments:
		frames.append(segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {}))
	# Full power everywhere except F (index 5), which proves
	# the acquisition runs without power.
	for index in range(6):
		frames[index]["power_status"] = 0.0 if index == 5 else 1.0
	# One shared tick wires team_id onto every frame.
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var teams: Array[int] = []
	for frame in frames:
		teams.append(int(frame.get("team_id", 1)))
	var positions: Array[Vector2] = []
	for segment in segments:
		positions.append(segment.position)

	# A: two enemy hittable in range (ids 1, 2 at +10 and
	# +30) -- expect the closest, id 1.
	frames[0]["observed_bullets"] = [
		{"id": 1, "team": teams[0] + 1, "hittable": true, "x": positions[0].x + 10.0, "y": positions[0].y},
		{"id": 2, "team": teams[0] + 1, "hittable": true, "x": positions[0].x + 30.0, "y": positions[0].y},
	]
	# B: one enemy hittable in range (id 4) -- no target
	# before the timer fires, target id 4 after it fires.
	frames[1]["observed_bullets"] = [
		{"id": 4, "team": teams[1] + 1, "hittable": true, "x": positions[1].x + 10.0, "y": positions[1].y},
	]
	# C: one same-team hittable in range only (id 5) --
	# expect no target even after the timer fires.
	frames[2]["observed_bullets"] = [
		{"id": 5, "team": teams[2], "hittable": true, "x": positions[2].x + 10.0, "y": positions[2].y},
	]
	# D: one enemy non-hittable in range only (id 6) --
	# expect no target even after the timer fires.
	frames[3]["observed_bullets"] = [
		{"id": 6, "team": teams[3] + 1, "hittable": false, "x": positions[3].x + 10.0, "y": positions[3].y},
	]
	# E: one enemy hittable at +200 x from the segment --
	# outside the range rect (range 180f, Blocks.java:3838)
	# -- expect no target even after the timer fires.
	frames[4]["observed_bullets"] = [
		{"id": 7, "team": teams[4] + 1, "hittable": true, "x": positions[4].x + 200.0, "y": positions[4].y},
	]
	# F: one enemy hittable in range (id 8), but no power
	# -- expect target id 8 after the timer fires: the
	# acquisition is NOT gated on power (Java updateTile
	# runs regardless -- only the aim/shoot half needs
	# efficiency, PointDefenseTurret.java:76-101).
	frames[5]["observed_bullets"] = [
		{"id": 8, "team": teams[5] + 1, "hittable": true, "x": positions[5].x + 10.0, "y": positions[5].y},
	]

	# One shared tick at 1/60s: no timer has fired yet
	# (target_timer ~2/60), so B still has no target.
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["no_target_before_timer_fire"] = not bool(frames[1].get("has_target", false))

	# Seed the timers just below the 5s fire line, then one
	# more 1/60s tick fires every timer (5.0067 >= 5.0)
	# and re-acquires.
	for index in range(6):
		frames[index]["target_timer"] = 4.99
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var target_a: Variant = frames[0].get("target", null)
	proof["acquire_picks_closest_enemy_hittable"] = target_a is Dictionary and int(target_a.get("id", -1)) == 1
	var target_b: Variant = frames[1].get("target", null)
	var target_b_acquired: bool = target_b is Dictionary and int(target_b.get("id", -1)) == 4
	proof["acquire_ignores_same_team"] = not bool(frames[2].get("has_target", false))
	proof["acquire_ignores_non_hittable"] = not bool(frames[3].get("has_target", false))
	proof["acquire_ignores_out_of_rect"] = not bool(frames[4].get("has_target", false))
	var target_f: Variant = frames[5].get("target", null)
	var target_f_acquired: bool = target_f is Dictionary and int(target_f.get("id", -1)) == 8
	proof["acquire_runs_without_power"] = target_f_acquired

	# Phase 2: pool A's target without firing the timer
	# again, and re-acquire B onto a closer bullet on fire.
	# A drops id 1 from its observed list (id 2 stays): one
	# 1/60s tick must clear A's target (the invalidation
	# runs every tick, the re-acquire only on a timer fire,
	# so no target is re-picked). B gains a closer bullet
	# (id 9 at +5) and its timer is seeded to fire: the
	# re-acquire replaces even the still-valid id 4.
	frames[0]["observed_bullets"] = [
		{"id": 2, "team": teams[0] + 1, "hittable": true, "x": positions[0].x + 30.0, "y": positions[0].y},
	]
	frames[1]["observed_bullets"] = [
		{"id": 4, "team": teams[1] + 1, "hittable": true, "x": positions[1].x + 10.0, "y": positions[1].y},
		{"id": 9, "team": teams[1] + 1, "hittable": true, "x": positions[1].x + 5.0, "y": positions[1].y},
	]
	frames[1]["target_timer"] = 4.99
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var target_a_had: bool = target_a is Dictionary and int(target_a.get("id", -1)) == 1
	proof["target_cleared_when_pooled"] = target_a_had and not bool(frames[0].get("has_target", false))
	var target_b_now: Variant = frames[1].get("target", null)
	proof["reacquire_replaces_valid_target_on_fire"] = target_b_acquired and target_b_now is Dictionary and int(target_b_now.get("id", -1)) == 9

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretTargetAcquireProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
