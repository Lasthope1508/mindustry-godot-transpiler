extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")
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

	# --- ItemTurret bullet() spawn (N2252): N2250 only computed
	# the shoot_event (the bullet origin dict -- `bulletX = x +
	# Angles.trnsx(rotation - 90, shootX, shootY),`,
	# Turret.java:744 -- plus rotation and the barrel) and stamped
	# it on the frame; nobody consumed it. This slice wires the
	# shoot_event into a live bullet, following TurretBuild.bullet()
	# (Turret.java:779-801): shoot() hands the pattern the handler
	# (`pattern.shoot(barrelCounter, (xOffset, yOffset, angle,
	# delay, mover) -> {`, Turret.java:754), ShootAlternate picks
	# one barrel per shot (`float index = ((totalShots + i +
	# barrelOffset) % barrels) - (barrels-1)/2f;` /
	# `handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f,
	# firstShotDelay + shotDelay * i);`, ShootAlternate.java:31-37
	# -- duo barrels 2, spread 3.5, barrelOffset 0, mirror false,
	# Blocks.java:3293; `Mathf.sign(boolean b)` is
	# `return b ? 1 : -1;`, Mathf.java:203-205, so sign(false) is
	# -1 and -sign(false) is +1: xOffset is index * 3.5, barrel 0
	# (index -0.5) gives -1.75 and barrel 1 (index +0.5) gives
	# +1.75), and delay 0 calls bullet() at once
	# (`if(delay > 0f){` queues, `else{` calls `bullet(type,
	# xOffset, yOffset, angle, mover);`, Turret.java:759-768 --
	# duo firstShotDelay 0 and shotDelay 0, so the queue is empty
	# here). bullet() recomputes the origin with the offset
	# (`bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset
	# + xSpread, shootY + yOffset),` / `bulletY = y +
	# Angles.trnsy(rotation - 90, shootX + xOffset + xSpread,
	# shootY + yOffset),`, Turret.java:783-784 -- xSpread is
	# `Mathf.range(xRand),` Turret.java:782, and xRand defaults
	# 0f, Turret.java:68, so xSpread is 0 for duo), the angle
	# with the inaccuracy draw (`shootAngle = rotation +
	# angleOffset + Mathf.range(inaccuracy + type.inaccuracy);`,
	# Turret.java:786 -- duo inaccuracy 2f, Blocks.java:3320,
	# type inaccuracy 0f, BulletType.java:93, so the draw is +-2
	# degrees), and lifeScl 1 (`float lifeScl = type.scaleLife ?
	# Mathf.clamp((1 + scaleLifetimeOffset) * Mathf.dst(bulletX,
	# bulletY, targetPos.x, targetPos.y) / type.range,
	# minRange() / type.range, range() / type.range) : 1f;`,
	# Turret.java:787 -- scaleLife defaults false,
	# BulletType.java:141, so the clamp branch is dead for duo),
	# then `handleBullet(type.create(this, team, bulletX,
	# bulletY, shootAngle, -1f, (1f - velocityRnd) +
	# Mathf.random(velocityRnd), lifeScl, null, mover,
	# targetPos.x, targetPos.y), xOffset, yOffset, shootAngle -
	# rotation);` (Turret.java:790 -- velocityRnd defaults 0f,
	# Turret.java:60, so the velocity factor is 1.0;
	# handleBullet is a no-op on TurretBuild,
	# Turret.java:818-820). type.create stamps the live bullet
	# (`bullet.initVel(angle, speed * velocityScl * ...);`,
	# BulletType.java:964 -- initVel is `vel.trns(angle,
	# amount);`, BulletComp.java:329-331, i.e. Vec2.trns is
	# `return set(amount, 0).rotate(angle);`, Vec2.java:40-42,
	# so the velocity is dir(angle) * speed;
	# `bullet.lifetime = lifetime * lifetimeScl * ...;`,
	# BulletType.java:968; `bullet.damage = (damage < 0 ?
	# this.damage : damage) * bullet.damageMultiplier();`,
	# BulletType.java:972; `bullet.hitSize = hitSize;`,
	# BulletType.java:971). The driver calls the new pure
	# function on a shot, stamps the spawn dict on the frame,
	# and hands the origin + shoot_angle + the peeked ammo_data
	# to the existing runtime spawn bridge
	# (SourceBulletRuntimeState.spawn_turret_bullet -- the
	# single writer of game["bullets"], N2242/N2243: it
	# converts speed to per-second (x60) and lifetime to
	# seconds (/60) and appends the live dict with the team
	# stamp). The random draws are params: x_spread defaults
	# 0.0 and inaccuracy_draw defaults to a live
	# randf_range(-2, 2) draw, while the proof seeds fixed
	# draws through the frame key, so the pure function itself
	# never calls randf. Five segments, one shared driver tick:
	# barrel 0 shoots with x offset -1.75, barrel 1 with
	# +1.75, a seeded inaccuracy draw of 1.5 lands in the
	# shoot angle, the spawn origin sits shootY 3 ahead of the
	# turret, and the copper live bullet carries the catalog
	# lifetime (70 ticks -> 70/60 s), damage 9, velocity 2.5
	# per tick (150 per second after the bridge), and the
	# turret team -- while a segment with no target shoots
	# nothing. The segments sit 48 tiles (384px) apart --
	# wider than twice the 160 range -- so no segment can see
	# another segment's target.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cells: Array[Vector2i] = [Vector2i(28, 21), Vector2i(76, 21), Vector2i(124, 21), Vector2i(172, 21), Vector2i(220, 21)]
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
	for index in range(5):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var bullets_before: int = int((game.get("bullets") as Array).size())

	# 0: barrel 0, copper, inaccuracy draw seeded 0.0 -- shoots
	# with x offset -1.75 at shoot angle 90.
	frames[0]["target"] = {"x": positions[0].x + 100.0, "y": positions[0].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[0]["has_target"] = true
	frames[0]["reload_counter"] = 19.99
	frames[0]["barrel_counter"] = 0
	frames[0]["inaccuracy_draw"] = 0.0
	# 1: barrel 1, copper, inaccuracy draw seeded 0.0 -- shoots
	# with x offset +1.75 at shoot angle 90.
	frames[1]["target"] = {"x": positions[1].x + 100.0, "y": positions[1].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[1]["has_target"] = true
	frames[1]["reload_counter"] = 19.99
	frames[1]["barrel_counter"] = 1
	frames[1]["inaccuracy_draw"] = 0.0
	# 2: barrel 0, copper, inaccuracy draw seeded 1.5 -- the
	# shoot angle must be 90 + 1.5 = 91.5.
	frames[2]["target"] = {"x": positions[2].x + 100.0, "y": positions[2].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[2]["has_target"] = true
	frames[2]["reload_counter"] = 19.99
	frames[2]["barrel_counter"] = 0
	frames[2]["inaccuracy_draw"] = 1.5
	# 3: barrel 0, copper, inaccuracy draw seeded 0.0 -- the
	# live bullet is checked for lifetime / damage / velocity
	# / team.
	frames[3]["target"] = {"x": positions[3].x + 100.0, "y": positions[3].y, "vx": 0.0, "vy": 0.0, "hit_size": 0.0}
	frames[3]["has_target"] = true
	frames[3]["reload_counter"] = 19.99
	frames[3]["barrel_counter"] = 0
	frames[3]["inaccuracy_draw"] = 0.0
	# 4: no target, no ammo -- control: no shot, no spawn,
	# no live bullet.

	# Seed copper ammo for 0-3 (the stacks are the
	# {"item", "amount"} dicts of
	# SourceTurretAmmoState.selected_turret_ammo_entries;
	# copper damage 9 / speed 2.5 / lifetime 70.0).
	var stacks_map: Dictionary = game.get("turret_ammo_stacks")
	var totals_map: Dictionary = game.get("turret_total_ammo")
	for index in range(4):
		var ammo_key: String = str(game.call("cell_key", cells[index]))
		stacks_map[ammo_key] = [{"item": "copper", "amount": 5}]
		totals_map[ammo_key] = 5

	# The shooting tick: 0-3 shoot (reload 19.99 + 1/60 caps
	# at 20, in cone, in range, not charging, warmed up); 4
	# does not (no target).
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(5):
		frames[index] = segments[index].get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	var bullets: Array = game.get("bullets")

	# The direct pure-function calls pin the barrel alternation
	# behind the driver observables below.
	var direct_event: Dictionary = {"bullet_x": positions[0].x, "bullet_y": positions[0].y + 3.0, "rotation": 90.0, "barrel": 0}
	var direct_barrel0: Dictionary = item_turret_build_state.source_item_turret_bullet_spawn_state(direct_event, positions[0].x, positions[0].y, null, 0, 0.0, 3.0, 3.5, 2, 0, false, 0.0, 0.0, 2.5, 9.0, 70.0, 4.0, 160.0)
	var direct_barrel1: Dictionary = item_turret_build_state.source_item_turret_bullet_spawn_state(direct_event, positions[0].x, positions[0].y, null, 1, 0.0, 3.0, 3.5, 2, 0, false, 0.0, 0.0, 2.5, 9.0, 70.0, 4.0, 160.0)

	# 0 vs 1: the alternate barrel flips the x offset -1.75 /
	# +1.75, both through the driver and directly.
	var spawn0: Variant = frames[0].get("bullet_spawn", null)
	var spawn1: Variant = frames[1].get("bullet_spawn", null)
	var offsets_ok: bool = false
	if spawn0 is Dictionary and spawn1 is Dictionary:
		offsets_ok = absf(float(spawn0.get("x_offset", 999.0)) - (-1.75)) < 0.001 and absf(float(spawn1.get("x_offset", 999.0)) - 1.75) < 0.001 and int(spawn0.get("barrel", -1)) == 0 and int(spawn1.get("barrel", -1)) == 1
	proof["spawn_barrel_alternates_x_offset"] = bool(frames[0].get("shot", false)) and bool(frames[1].get("shot", false)) and offsets_ok and absf(float(direct_barrel0.get("x_offset", 999.0)) - (-1.75)) < 0.001 and absf(float(direct_barrel1.get("x_offset", 999.0)) - 1.75) < 0.001
	# 2: the shoot angle carries the seeded inaccuracy draw
	# (rotation 90 + draw 1.5 = 91.5).
	var spawn2: Variant = frames[2].get("bullet_spawn", null)
	var angle_ok: bool = false
	if spawn2 is Dictionary:
		angle_ok = absf(float(spawn2.get("shoot_angle", -999.0)) - 91.5) < 0.001
	proof["spawn_angle_includes_inaccuracy_draw"] = bool(frames[2].get("shot", false)) and angle_ok
	# 0: the spawn origin sits shootY 3 ahead of the turret --
	# rotation 90, barrel 0: (x - 1.75, y + 3).
	var origin_ok: bool = false
	if spawn0 is Dictionary:
		origin_ok = absf(float(spawn0.get("bullet_x", -999.0)) - (positions[0].x - 1.75)) < 0.001 and absf(float(spawn0.get("bullet_y", -999.0)) - (positions[0].y + 3.0)) < 0.001
	proof["spawn_position_uses_shoot_y_3"] = bool(frames[0].get("shot", false)) and origin_ok

	# The live bullet for segment 3, matched by its sprite
	# position (the bridge stamps the spawn origin on the
	# bullet sprite): segment 3 shot with barrel 0, so its
	# origin is (x - 1.75, y + 3).
	var live3: Dictionary = {}
	for bullet in bullets:
		if bullet is Dictionary:
			var sprite: Variant = bullet.get("sprite", null)
			if sprite is Sprite2D:
				if absf(float(sprite.position.x) - (positions[3].x - 1.75)) < 0.001 and absf(float(sprite.position.y) - (positions[3].y + 3.0)) < 0.001:
					live3 = bullet
					break
	# 3: the live lifetime comes from the catalog ammo entry --
	# copper 70.0 ticks, /60 by the bridge = 70/60 seconds.
	proof["spawn_lifetime_from_ammo_catalog"] = not live3.is_empty() and absf(float(live3.get("lifetime_remaining", -1.0)) - 70.0 / 60.0) < 0.001
	# 3: the live damage is the copper 9.
	proof["spawn_damage_copper_9"] = not live3.is_empty() and absf(float(live3.get("damage", -1.0)) - 9.0) < 0.001
	# 3: the live velocity length is the copper speed 2.5 per
	# tick, i.e. 150 per second after the bridge conversion.
	var velocity3: Vector2 = live3.get("velocity", Vector2.ZERO) as Vector2 if not live3.is_empty() else Vector2.ZERO
	proof["spawn_velocity_matches_speed_2_5"] = not live3.is_empty() and absf(velocity3.length() - 150.0) < 0.01
	# Exactly four live bullets landed in game["bullets"] --
	# one per shooting segment -- and the control segment
	# spawned nothing.
	proof["spawn_live_bullet_in_game_bullets"] = bullets.size() == bullets_before + 4 and bool(frames[3].get("shot", false)) and frames[4].get("bullet_spawn", null) == null and not bool(frames[4].get("shot", true))
	# 3: the live bullet carries the turret team.
	proof["spawn_team_stamp"] = not live3.is_empty() and int(live3.get("team", -1)) == int(frames[3].get("team_id", -2))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ItemTurretBulletSpawnProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
