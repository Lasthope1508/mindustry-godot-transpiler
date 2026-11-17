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

	# --- PointDefenseTurret aim + reload + shoot (N2240):
	# the second half of PointDefenseBuild.updateTile()
	# (PointDefenseTurret.java:76-101, the "look at target"
	# half; N2239 did the retarget half, :62-71). The gate
	# (`if(target != null && target.within(this, range) &&
	# target.team != team && target.type() != null &&
	# target.type().hittable){`, PointDefenseTurret.java:76)
	# requires all five conditions -- a null target, an
	# out-of-range target (Position.within is dst2 < range*range,
	# STRICT <, Position.java:40-46 `return Mathf.dst2(getX(),
	# getY(), x, y) < dst*dst;`), a same-team target, a typeless
	# target, or a non-hittable target leaves rotation and
	# reloadCounter untouched and shoots nothing. Inside the gate
	# the build turns toward the target (`float dest =
	# angleTo(target);` / `rotation = Angles.moveToward(rotation,
	# dest, rotateSpeed * edelta());`,
	# PointDefenseTurret.java:77-78) and charges the reload
	# (`reloadCounter += edelta();`,
	# PointDefenseTurret.java:79). `angleTo` is
	# Position.angleTo -> Angles.angle(x, y, tx, ty)
	# (Position.java:12-14), i.e. `Mathf.atan2(x2 - x, y2 - y) *
	# Mathf.radDeg` normalized to [0, 360) -- atan2(dx, dy), 0
	# degrees is +Y, the opposite of GDScript's `atan2(y, x)`.
	# `edelta()` is `efficiency * delta()`
	# (BuildingComp.java:1927-1929, `return efficiency *
	# delta();`). `rotation` is the float turret rotation,
	# default 90 (`public float rotation = 90;`,
	# BaseTurret.java:114), and `reloadCounter` is the float on
	# ReloadTurretBuild (`public float reloadCounter;`,
	# ReloadTurret.java:26). Java does NOT clamp reloadCounter
	# here (the clamp lives on the plain TurretBuild,
	# Turret.java:723, which PointDefenseBuild does not extend).
	# The shoot gate (`if(Angles.within(rotation, dest,
	# shootCone) && reloadCounter >= reload){`,
	# PointDefenseTurret.java:82) uses `Angles.within(a, b,
	# margin)` = `angleDist(a, b) <= margin`
	# (Angles.java:19-21, `return angleDist(a, b) <= margin;`),
	# i.e. `<=` shootCone. The damage is `float realDamage =
	# bulletDamage * state.rules.blockDamage(team);`
	# (PointDefenseTurret.java:83) with `blockDamage(team)` =
	# `return blockDamageMultiplier *
	# teams.get(team).blockDamageMultiplier;`
	# (Rules.java:299-300); the comparison is STRICT `>`
	# (`if(target.damage() > realDamage){`,
	# PointDefenseTurret.java:84) so a target whose damage
	# equals realDamage is removed, not left at 0
	# (`target.damage(target.damage() - realDamage);`,
	# PointDefenseTurret.java:85, vs `target.remove();`,
	# PointDefenseTurret.java:87). The reset is
	# `reloadCounter = 0;` (PointDefenseTurret.java:97) --
	# reset-to-0, NOT `%= reload` (that is the plain Turret,
	# Turret.java:738). The effects and sound (`Tmp.v1.trns(
	# rotation, shootLength);` / `beamEffect.at(x + Tmp.v1.x,
	# y + Tmp.v1.y, rotation, color, new Vec2().set(target));`
	# / `shootEffect.at(x + Tmp.v1.x, y + Tmp.v1.y, rotation,
	# color);` / `hitEffect.at(target.x, target.y, color);` /
	# `shootSound.at(x + Tmp.v1.x, y + Tmp.v1.y,
	# Mathf.random(0.9f, 1.1f));`, PointDefenseTurret.java:90-95)
	# are side effects: the pure function spawns nothing and
	# instead returns a shoot_event dict (beam origin + rotation
	# + target position) for the driver / proof to verify; the
	# sound pitch is random (0.9-1.1) so it is NOT in the event.
	# The beam origin is Tmp.v1.trns(rotation, shootLength) =
	# (cos, sin) of rotation times the per-def shootLength 5f
	# (Blocks.java:3843, `shootLength = 5f;`). Class defaults are
	# shootCone 5f, bulletDamage 10f, shootLength 3f
	# (`public float shootCone = 5f;` / `public float
	# bulletDamage = 10f;` / `public float shootLength = 3f;`,
	# PointDefenseTurret.java:31-33) with rotateSpeed 20f and
	# reload 30f from the ctor (`rotateSpeed = 20f;` /
	# `reload = 30f;`, PointDefenseTurret.java:38-39); the segment
	# per-def overrides are range 180f, shootLength 5f,
	# bulletDamage 30f, reload 8f (`range = 180f;` /
	# `shootLength = 5f;` / `bulletDamage = 30f;` /
	# `reload = 8f;`, Blocks.java:3838-3846) -- the driver passes
	# the per-def values. Six segments, one shared driver tick
	# each phase: A rotates toward a north target, B has no
	# target, C has a target inside the acquire rect but beyond
	# range^2 (acquired, never aimed at), D has a same-team
	# target only, E shoots a 100-damage bullet (30 damage
	# dealt), F shoots a 30-damage bullet (lethal -- damage
	# equals realDamage, so the target is removed).
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
	# Full power everywhere: the aim/shoot half needs efficiency
	# (edelta = efficiency * delta), unlike the N2239 retarget
	# which runs without power.
	for index in range(6):
		frames[index]["power_status"] = 1.0
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

	# A: one enemy hittable due north (+10 y, dest 0 deg) --
	# rotation starts at the 90 default and must turn toward 0.
	frames[0]["observed_bullets"] = [
		{"id": 1, "team": teams[0] + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": positions[0].x, "y": positions[0].y + 10.0},
	]
	# B: no bullets at all -- no target, no rotation, no reload.
	frames[1]["observed_bullets"] = []
	# C: one enemy hittable at (+170, +100) -- inside the acquire
	# rect (x +/- 180, y +/- 180) so it IS acquired, but
	# dst2 = 170^2 + 100^2 = 38900 >= 180^2 = 32400, so the aim
	# gate (Position.within, STRICT <) never passes.
	frames[2]["observed_bullets"] = [
		{"id": 3, "team": teams[2] + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": positions[2].x + 170.0, "y": positions[2].y + 100.0},
	]
	# D: one same-team hittable in range only (id 4) --
	# expect no target even after the timer fires.
	frames[3]["observed_bullets"] = [
		{"id": 4, "team": teams[3], "hittable": true, "has_type": true, "damage": 100.0, "x": positions[3].x + 10.0, "y": positions[3].y},
	]
	# E: one enemy hittable due east (+10 x, dest 90 deg, the
	# rotation default -- already inside the 5 deg shoot cone)
	# with damage 100.0 and the reload pre-charged to 7.99 --
	# one tick must shoot (reload 7.99 + 1/60 >= 8.0), deal
	# 30.0 * 1.0 block damage, and reset the reload to 0.
	frames[4]["observed_bullets"] = [
		{"id": 5, "team": teams[4] + 1, "hittable": true, "has_type": true, "damage": 100.0, "x": positions[4].x + 10.0, "y": positions[4].y},
	]
	# F: one enemy hittable due east with damage exactly 30.0
	# (= realDamage 30.0 * 1.0) and the reload pre-charged --
	# the STRICT > comparison must remove the target instead
	# of leaving it at 0.
	frames[5]["observed_bullets"] = [
		{"id": 6, "team": teams[5] + 1, "hittable": true, "has_type": true, "damage": 30.0, "x": positions[5].x + 10.0, "y": positions[5].y},
	]
	# Seed the acquire timers just below the 5s fire line so
	# the next tick acquires, and pre-charge the reload on E
	# and F so the tick after that shoots.
	for index in [0, 2, 3, 4, 5]:
		frames[index]["target_timer"] = 4.99
	frames[4]["reload_counter"] = 7.99
	frames[5]["reload_counter"] = 7.99

	# Tick A at 1/60s: every seeded timer fires and
	# re-acquires, but the aim/shoot half still sees edelta 0:
	# since N2241 the consumption branch gates on
	# shouldConsume() (`enabled && target != null`,
	# PointDefenseTurret.java:105-107) and runs BEFORE the
	# retarget, so on the acquire tick the frame still has
	# target == null from the previous tick and efficiency
	# folds to 0 -- the Java order (Building.update() calls
	# updateConsumption() before updateTile(),
	# BuildingComp.java:2274-2277), not a driver bug. The
	# reload stays 7.99 and nothing shoots on tick A.
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})

	# Tick B at 1/60s: the target is stamped now, so
	# should_consume is true, efficiency is 1, edelta is
	# 1/60, and E/F shoot (reload 7.99 + 1/60 >= 8.0).
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var rotation_b: float = float(frames[1].get("rotation", 90.0))
	var reload_b: float = float(frames[1].get("reload_counter", 0.0))
	proof["aim_no_rotation_without_target"] = absf(rotation_b - 90.0) < 0.001 and absf(reload_b) < 0.001
	var rotation_c: float = float(frames[2].get("rotation", 90.0))
	proof["aim_ignores_out_of_range_target"] = bool(frames[2].get("has_target", false)) and absf(rotation_c - 90.0) < 0.001
	var rotation_d: float = float(frames[3].get("rotation", 90.0))
	proof["aim_ignores_same_team_target"] = not bool(frames[3].get("has_target", false)) and absf(rotation_d - 90.0) < 0.001
	var shot_e: bool = bool(frames[4].get("shot", false))
	var reload_e: float = float(frames[4].get("reload_counter", 0.0))
	proof["reload_accumulates_and_shoots_at_cone"] = shot_e and absf(reload_e) < 0.001
	var target_e: Variant = frames[4].get("target", null)
	var damage_e: float = float(target_e.get("damage", -1.0)) if target_e is Dictionary else -1.0
	proof["shoot_deals_block_damage"] = shot_e and absf(damage_e - 70.0) < 0.001
	var shot_f: bool = bool(frames[5].get("shot", false))
	var reload_f: float = float(frames[5].get("reload_counter", 0.0))
	proof["shoot_removes_target_when_lethal"] = shot_f and absf(reload_f) < 0.001 and frames[5].get("target", null) == null
	var shoot_event_e: Variant = frames[4].get("shoot_event", null)
	var beam_ok: bool = false
	if shoot_event_e is Dictionary:
		# The beam origin is Tmp.v1.trns(rotation, shootLength):
		# rotation 90 deg, per-def shootLength 5f, so the origin
		# is (x + cos(90) * 5, y + sin(90) * 5) = (x, y + 5).
		beam_ok = absf(float(shoot_event_e.get("beam_x", -999.0)) - positions[4].x) < 0.001 and absf(float(shoot_event_e.get("beam_y", -999.0)) - (positions[4].y + 5.0)) < 0.001 and absf(float(shoot_event_e.get("rotation", -1.0)) - 90.0) < 0.001 and absf(float(shoot_event_e.get("target_x", -999.0)) - (positions[4].x + 10.0)) < 0.001 and absf(float(shoot_event_e.get("target_y", -999.0)) - positions[4].y) < 0.001
	proof["shoot_event_carries_beam_origin"] = shot_e and beam_ok

	# Phase 2: 29 more 1/60s ticks -- with tick A (edelta 0)
	# and tick B, A has 30 effective ticks toward the north
	# target: 30 ticks * rotateSpeed 20 * edelta (1/60 at full
	# efficiency) = 10 deg, so rotation lands at 80. The check
	# is a band (70, 90), not the exact 80, so a small
	# efficiency difference cannot flake it. B, C and D must
	# still sit at the 90 default.
	for tick in range(29):
		point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	for index in range(6):
		frames[index] = segments[index].get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var rotation_a: float = float(frames[0].get("rotation", 90.0))
	proof["aim_rotates_toward_target"] = rotation_a < 90.0 and rotation_a > 70.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretAimShootProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
