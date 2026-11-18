extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
const turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	# The duo's per-shot inaccuracy draws randf_range(-2, +2) from
	# Godot's auto-seeded global RNG; pinning the seed makes this
	# proof deterministic. This only affects the proof harness:
	# the game code and its randomness are untouched, faithful to
	# Java's Mathf.range inaccuracy. Gameplay is not changed.
	seed(12345)
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

	# --- the setup frames run the live loop with real deltas, and the
	# wave timer starts at 0 with no enemies, so a wave may already
	# have spawned: clear the board and pin the wave timer far out,
	# so this session has exactly one enemy, placed by the proof.
	game.set("wave_cooldown", 100000.0)
	for enemy in game.get("enemy_units"):
		var enemy_dict: Dictionary = enemy
		var sprite = enemy_dict.get("sprite", null)
		if is_instance_valid(sprite):
			sprite.queue_free()
	game.set("enemy_units", [])
	game.set("bullet_hit_count", 0)

	# --- PointDefenseTurret spawn-side team stamp (N2243):
	# live `game["bullets"]` dicts carried no team before this
	# slice, so the N2242 wiring excluded every live bullet and
	# should_consume stayed false in live play. Java gives every
	# live Bullet a team: the firing building passes its own team
	# into the create chain (`handleBullet(type.create(this, team,
	# bulletX, bulletY, shootAngle, -1f, (1f - velocityRnd) +
	# Mathf.random(velocityRnd), lifeScl, null, mover,
	# targetPos.x, targetPos.y), xOffset, yOffset, shootAngle -
	# rotation);`, Turret.java:790; `bullet.team = team;`,
	# BulletType.java:954; `@Import Team team;`,
	# BulletComp.java:29). The port stamps the firing turret's
	# team onto each live bullet dict at spawn, threading it
	# turret-sim -> bridge -> runtime -> spawn state (the sim
	# loop reads the firing cell's team from the placed sprite
	# that owns the cell -- placed sprites carry `origin_cell`
	# meta, SourcePlacedBlockState.gd:90, and the team meta key,
	# SourceBlockGeometry.gd:161, derelict default 0, the
	# SourceTurretBuildState.gd:199 precedent). Two duos fire
	# through the real `simulate_turrets` loop at one dagger:
	# the bootstrap duo (sharded, team 1) and a second duo
	# placed by the proof on the crux team (team 2 -- Team ids:
	# derelict 0, sharded 1, crux 2, neoplastic 6,
	# Team.java:41). The dagger's health is pinned high so it
	# survives both duos' fire; the bullets are snapshotted
	# right after each `simulate_turrets` tick, before
	# `simulate_bullets` ever moves them, so each bullet's
	# sprite still sits at its spawn origin and is attributed
	# to its firing turret by distance. A segment then ticks
	# once so the N2242 wiring maps the live list, and the
	# observed dicts must carry both teams.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var duo = game.call("selected_playable_turret")

	var duo1_cell: Vector2i = game.get("duo_pos")
	var duo1_world: Vector2 = game.call("grid_to_world", duo1_cell)
	var duo1_key := str(game.call("cell_key", duo1_cell))
	var duo2_cell := Vector2i(15, 9)
	var duo2_world: Vector2 = game.call("grid_to_world", duo2_cell)
	var duo2_key := str(game.call("cell_key", duo2_cell))

	# The second duo is a crux turret: its team meta is 2, and
	# the sim must read exactly that team off its placed sprite.
	var duo2_sprite := Sprite2D.new()
	game.add_child(duo2_sprite)
	game.call("record_placed_block", duo2_sprite, blocks_by_id["duo"], duo2_cell, 2)
	duo2_sprite.position = game.source_block_sprite_base_position(blocks_by_id["duo"], duo2_cell)
	game.call("register_turret_cell", duo2_cell, blocks_by_id["duo"])
	proof["spawn_team_stamp_second_turret_placed"] = duo2_sprite.get_meta("origin_cell", Vector2i.ZERO) == duo2_cell and int(duo2_sprite.get_meta("team_id", -1)) == 2 and duo2_cell in (game.get("turret_cells") as Array)
	# The bootstrap duo's placed sprite must carry the same
	# metas, or the sim lookup would fall back to derelict 0
	# for the first turret too.
	var duo1_placed_ok := false
	for placed in game.get("placed_blocks").values():
		if placed is Sprite2D and placed.get_meta("origin_cell", Vector2i.ZERO) == duo1_cell:
			duo1_placed_ok = int(placed.get_meta("team_id", -1)) == 1
			break
	proof["spawn_team_stamp_first_turret_placed"] = duo1_placed_ok

	# Both duos load copper: the bootstrap already fills the
	# first duo to maxAmmo 30; the second loads 30 calls at
	# ammoMultiplier 2 -- 15 items land (30 ammo).
	var loaded2 := 0
	for load_call in range(30):
		if turret_ammo_state.handle_turret_item(game, duo2_cell, duo, "copper"):
			loaded2 += 1
	var total_ammo: Dictionary = game.get("turret_total_ammo")
	proof["spawn_team_stamp_both_turrets_loaded"] = int(total_ammo.get(duo1_key, -1)) == 30 and loaded2 == 15 and int(total_ammo.get(duo2_key, -1)) == 30

	# --- the live leg: one dagger, placed 250px out from the
	# first duo on the line through the duo and the core, on
	# the far side of the core (the approach point is 250px
	# from the duo toward the core, so it lies ~178px past
	# the core). The dagger walks to the core and stops
	# there to attack it, so its path is the approach->core
	# segment. The second duo sits ON that segment at
	# (15, 9) -- 107px from the approach point, 71px from
	# the core, clear of the drill (7, 8), the conveyor
	# row y=8 and the size-3 core footprint x=16..18 --
	# so the dagger is inside its 160px range from the
	# first tick and stays in range once it reaches the
	# core; the first duo's range is entered after ~90px
	# of walking. (An earlier (23, 8) placement never
	# fired: that cell is east of the core, 192px from the
	# closest point of the dagger's path, outside the
	# 160px range for the whole walk.)
	var dagger_type = game.call("selected_enemy_unit")
	game.call("spawn_enemy_unit", dagger_type, 0)
	var dagger: Dictionary = Array(game.get("enemy_units"))[0]
	dagger["health"] = 100000.0
	var dagger_sprite = dagger.get("sprite", null)
	var core_world: Vector2 = game.call("grid_to_world", game.get("core_pos"))
	var approach: Vector2 = duo1_world - (duo1_world - core_world).normalized() * 250.0
	dagger_sprite.position = approach

	# Snapshot every live bullet at its spawn origin, before
	# `simulate_bullets` moves it: the sprite position is the
	# spawn origin, so the firing turret is the nearest duo.
	var seen_bullets: Dictionary = {}
	var team1_seen := false
	var team2_seen := false
	for tick in range(700):
		game.call("simulate_turrets", 1.0 / 60.0)
		for bullet in game.get("bullets"):
			var bullet_dict: Dictionary = bullet
			var bullet_sprite = bullet_dict.get("sprite", null)
			if not is_instance_valid(bullet_sprite):
				continue
			var bullet_id: int = bullet_sprite.get_instance_id()
			if not seen_bullets.has(bullet_id):
				seen_bullets[bullet_id] = {"team": int(bullet_dict.get("team", -1)), "pos": bullet_sprite.position}
			var seen: Dictionary = seen_bullets[bullet_id]
			if int(seen.get("team", -1)) == 1 and (seen.get("pos", Vector2.INF) as Vector2).distance_to(duo1_world) < 48.0:
				team1_seen = true
			if int(seen.get("team", -1)) == 2 and (seen.get("pos", Vector2.INF) as Vector2).distance_to(duo2_world) < 48.0:
				team2_seen = true
		if team1_seen and team2_seen:
			break
		game.call("simulate_enemy_units", 1.0 / 60.0)
	proof["spawn_team_stamp_carries_firing_turret_team"] = team1_seen
	proof["spawn_team_stamp_second_team_carries_other_team"] = team2_seen

	# --- the N2242 wiring then maps the live list: a segment
	# ticks once and its observed dicts must carry both teams.
	var segment_cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], segment_cell)
	segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], segment_cell)
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	frame["power_status"] = 1.0
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var observed: Array = frame.get("observed_bullets", [])
	var observed_team1 := false
	var observed_team2 := false
	for entry in observed:
		if entry is Dictionary:
			if int(entry.get("team", -1)) == 1:
				observed_team1 = true
			if int(entry.get("team", -1)) == 2:
				observed_team2 = true
	proof["spawn_team_stamp_wiring_includes_both_with_correct_teams"] = observed_team1 and observed_team2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretSpawnTeamStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
