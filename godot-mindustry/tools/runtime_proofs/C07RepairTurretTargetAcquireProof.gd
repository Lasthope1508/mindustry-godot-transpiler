extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret target acquisition (N2212):
	# RepairPointBuild.updateTile nulls the target when it
	# dies, walks out of range, or is fully healed
	# (`if(target != null && (target.dead() ||
	# target.dst(this) - target.hitSize/2f > repairRadius ||
	# target.health() >= target.maxHealth())){` /
	# `target = null;`, RepairTurret.java:193-195), zeroes
	# the beam offset when there is no target
	# (`if(target == null){` / `offset.setZero();`,
	# RepairTurret.java:197-199), and re-acquires every 20s
	# through the closest damaged ally in range
	# (`if(timer(timerTarget, 20)){` /
	# `rect.setSize(repairRadius * 2).setCenter(x, y);` /
	# `target = Units.closest(team, x, y, repairRadius,
	# Unit::damaged);`, RepairTurret.java:214-217).
	# Units.closest (the range overload, Units.java:358)
	# runs the circle nearby, keeps only valid damaged
	# units (`if(!e.isValid() || !predicate.get(e))
	# return;`, Units.java:364), and takes the minimum
	# squared distance. RED decisions pinned here: the
	# re-acquire is timer-gated (no target before the first
	# 20s fire -- the Interval.get model, times[] init 0,
	# first fire at Time.time >= 20); the invalidation
	# reads the CURRENT unit record (looked up by `id` --
	# a target whose id is absent from the list is gone);
	# the health check is PLAIN `health >= maxHealth`
	# (no 0.001 epsilon, unlike damaged()); the driver
	# stamps target / has_target / target_timer / offset
	# on the frame every tick, UNCONDITIONAL on power
	# (Java updateTile runs regardless -- only the heal
	# needs efficiency > 0); the radius is per-def
	# (repair-turret 145f, Blocks.java:6400; class
	# default 50f, RepairTurret.java:31). Six turrets,
	# one shared driver tick each phase: A picks the
	# closest damaged, B proves the timer gate, C proves
	# undamaged is ignored, D proves other-team is
	# ignored, E proves the per-def radius, F proves the
	# acquisition runs without power.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(30, 21), Vector2i(32, 21), Vector2i(34, 21), Vector2i(36, 21), Vector2i(38, 21)]
	var turrets: Array[Sprite2D] = []
	for cell in cells:
		var turret := Sprite2D.new()
		game.add_child(turret)
		game.call("record_placed_block", turret, blocks_by_id["repair-turret"], cell)
		# The raw Sprite2D nodes never pass through the texture
		# path (SourceTextureRuntimeState.configure_block_sprite),
		# which is what assigns a placed block its world position
		# (`sprite.position = game.source_block_sprite_base_position(block, cell)`),
		# so without this every turret sits at the origin (0, 0)
		# and the turret-centred query cannot be distinguished
		# from an origin-centred one. Seed the position exactly
		# the way the game does (the N2211 proof lesson).
		turret.position = game.source_block_sprite_base_position(blocks_by_id["repair-turret"], cell)
		repair_turret_build_state.source_repair_turret_bind_frame_state(turret, blocks_by_id["repair-turret"])
		turrets.append(turret)
	var frames: Array[Dictionary] = []
	for turret in turrets:
		frames.append(turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {}))
	# Full power everywhere except F (index 5), which proves
	# the acquisition runs without power.
	for index in range(6):
		frames[index]["power_status"] = 0.0 if index == 5 else 1.0
	# One shared tick wires team_id onto every frame.
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = turrets[index].get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	var teams: Array[int] = []
	for frame in frames:
		teams.append(int(frame.get("team_id", 1)))
	var positions: Array[Vector2] = []
	for turret in turrets:
		positions.append(turret.position)

	# A: two damaged same-team in range (ids 1, 2 at +10 and
	# +30) plus one undamaged in range (id 3) -- expect the
	# closest damaged, id 1.
	frames[0]["units"] = [
		{"id": 1, "team_id": teams[0], "x": positions[0].x + 10.0, "y": positions[0].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"id": 2, "team_id": teams[0], "x": positions[0].x + 30.0, "y": positions[0].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
		{"id": 3, "team_id": teams[0], "x": positions[0].x + 10.0, "y": positions[0].y + 10.0, "hit_size": 6.0, "health": 100.0, "max_health": 100.0},
	]
	# B: one damaged same-team in range (id 4) -- no target
	# before the timer fires, target id 4 after it fires.
	frames[1]["units"] = [
		{"id": 4, "team_id": teams[1], "x": positions[1].x + 10.0, "y": positions[1].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# C: one undamaged same-team in range only (id 5) --
	# expect no target even after the timer fires.
	frames[2]["units"] = [
		{"id": 5, "team_id": teams[2], "x": positions[2].x + 10.0, "y": positions[2].y, "hit_size": 6.0, "health": 100.0, "max_health": 100.0},
	]
	# D: one damaged other-team in range only (id 6) --
	# expect no target even after the timer fires.
	frames[3]["units"] = [
		{"id": 6, "team_id": teams[3] + 1, "x": positions[3].x + 10.0, "y": positions[3].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# E: one damaged same-team at 100 from the turret --
	# inside the per-def radius 145 (effective radius 148)
	# but outside the class default 50 (effective radius
	# 53). Expect target id 7: the driver reads the
	# per-def radius, not the default.
	frames[4]["units"] = [
		{"id": 7, "team_id": teams[4], "x": positions[4].x + 100.0, "y": positions[4].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]
	# F: one damaged same-team in range (id 8), but no power
	# -- expect target id 8 after the timer fires: the
	# acquisition is NOT gated on power (unlike the
	# RepairTower refresh, RepairTower.java:59).
	frames[5]["units"] = [
		{"id": 8, "team_id": teams[5], "x": positions[5].x + 10.0, "y": positions[5].y, "hit_size": 6.0, "health": 50.0, "max_health": 100.0},
	]

	# One shared tick at 1/60s: no timer has fired yet
	# (target_timer ~2/60), so B still has no target.
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = turrets[index].get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["no_target_before_timer_fire"] = not bool(frames[1].get("has_target", false))

	# Seed the timers just below the 20s fire line, then one
	# more 1/60s tick fires every timer (20.0067 >= 20.0)
	# and re-acquires.
	for index in range(6):
		frames[index]["target_timer"] = 19.99
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = turrets[index].get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	var target_a: Variant = frames[0].get("target", null)
	proof["acquire_picks_closest_damaged"] = target_a is Dictionary and int(target_a.get("id", -1)) == 1
	var target_b: Variant = frames[1].get("target", null)
	var target_b_acquired: bool = target_b is Dictionary and int(target_b.get("id", -1)) == 4
	proof["acquire_ignores_undamaged"] = not bool(frames[2].get("has_target", false))
	proof["acquire_ignores_other_team"] = not bool(frames[3].get("has_target", false))
	var target_e: Variant = frames[4].get("target", null)
	proof["acquire_uses_per_def_radius"] = target_e is Dictionary and int(target_e.get("id", -1)) == 7
	var target_f: Variant = frames[5].get("target", null)
	var target_f_acquired: bool = target_f is Dictionary and int(target_f.get("id", -1)) == 8
	proof["acquire_runs_without_power"] = target_f_acquired

	# Phase 2: invalidate the acquired targets without
	# firing the timer again -- A heals to full, B walks
	# out of range, F dies. One 1/60s tick must clear all
	# three (the invalidation runs every tick, the
	# re-acquire only on a timer fire, so no target is
	# re-picked even though A still has a damaged unit in
	# range, id 2).
	var units_a: Array = frames[0].get("units", [])
	units_a[0]["health"] = 100.0
	var units_b: Array = frames[1].get("units", [])
	units_b[0]["x"] = positions[1].x + 500.0
	var units_f: Array = frames[5].get("units", [])
	units_f[0]["dead"] = true
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = turrets[index].get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	var target_a_had: bool = target_a is Dictionary and int(target_a.get("id", -1)) == 1
	proof["target_cleared_when_fully_healed"] = target_a_had and not bool(frames[0].get("has_target", false))
	proof["target_cleared_when_out_of_range_or_dead"] = target_b_acquired and target_f_acquired and not bool(frames[1].get("has_target", false)) and not bool(frames[5].get("has_target", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretTargetAcquireProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
