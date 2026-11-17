extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _observed_entry(observed: Array, bullet_id: int) -> Dictionary:
	for entry in observed:
		if entry is Dictionary and int(entry.get("id", -1)) == bullet_id:
			return entry
	return {}


func _make_live_bullet(game: Node, position: Vector2, damage: float, team: Variant, hittable: Variant) -> Sprite2D:
	# A live `game["bullets"]` dict exactly as the only writer
	# builds it (SourceBulletSpawnState.gd
	# spawn_turret_bullet_from_state: sprite / target / velocity /
	# speed / damage / hitSize / lifetime_remaining -- no team /
	# hittable / id / type); team and hittable are added only when
	# the caller passes them, so the proof can seed a team-less
	# bullet and a bullet with no hittable key.
	var sprite := Sprite2D.new()
	sprite.position = position
	game.add_child(sprite)
	var bullet := {"sprite": sprite, "target": null, "velocity": Vector2.ZERO, "speed": 0.0, "damage": damage, "hitSize": 1.0, "lifetime_remaining": 10.0}
	if team != null:
		bullet["team"] = team
	if hittable != null:
		bullet["hittable"] = hittable
	var live_bullets: Array = game.get("bullets")
	live_bullets.append(bullet)
	return sprite


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

	# --- PointDefenseTurret live-bullets wiring (N2242):
	# PointDefenseBuild.updateTile re-acquires from the live
	# bullet group (`target = Groups.bullet.intersect(x - range,
	# y - range, range*2, range*2).min(b -> b.team != team &&
	# b.type().hittable, b -> b.dst2(this));`,
	# PointDefenseTurret.java:65-67), and a pooled bullet is
	# nulled (`if(target != null && !target.isAdded()){` /
	# `target = null;`, PointDefenseTurret.java:69-71). The
	# driver maps the live `game["bullets"]` dicts to the
	# observed dicts the N2239 acquire consumes and stamps
	# `frame["observed_bullets"]` every tick
	# (source_point_defense_turret_live_bullets_state). One
	# segment, sequential phases: 1 maps a live enemy bullet
	# (position from sprite / stable id from sprite / team and
	# hittable read when present / has_type true), 2 adds a
	# team-less bullet (excluded, never defaulted to -1 -- the
	# acquire reads `int(bullet.get("team", -1))` and -1 !=
	# team_id for every real team, derelict is 0,
	# SourceBlockGeometry.gd:159) and a bullet with no hittable
	# key (defaults to the BulletType class default true,
	# `public boolean hittable = true;`, BulletType.java:143),
	# 3 clears the live list (an empty list is still stamped
	# every tick, the N2190/N2195 present-but-empty precedent),
	# 4 acquires a live enemy bullet, then removes it from the
	# live list (the target clears, the Java :69-71 pooled
	# invalidation).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var cell := Vector2i(28, 21)
	var segment := Sprite2D.new()
	game.add_child(segment)
	game.call("record_placed_block", segment, blocks_by_id["segment"], cell)
	segment.position = game.source_block_sprite_base_position(blocks_by_id["segment"], cell)
	point_defense_turret_build_state.source_point_defense_turret_bind_frame_state(segment, blocks_by_id["segment"])
	var frame: Dictionary = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	frame["power_status"] = 1.0
	var team_id: int = int(frame.get("team_id", 1))
	var enemy_team: int = team_id + 1
	var live_bullets: Array = game.get("bullets")

	# Phase 1: one live enemy bullet at +10 -- the mapping
	# reads position and id from its sprite, team and hittable
	# from the dict, and marks has_type true.
	var b1 := _make_live_bullet(game, segment.position + Vector2(10, 0), 30.0, enemy_team, true)
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var observed: Array = frame.get("observed_bullets", [])
	var entry1: Dictionary = _observed_entry(observed, b1.get_instance_id())
	proof["wiring_maps_live_bullet_position_from_sprite"] = observed.size() == 1 and float(entry1.get("x", 0.0)) == b1.position.x and float(entry1.get("y", 0.0)) == b1.position.y
	proof["wiring_assigns_stable_id_from_sprite"] = observed.size() == 1 and int(entry1.get("id", -1)) == b1.get_instance_id()
	proof["wiring_reads_team_and_hittable_when_present"] = observed.size() == 1 and int(entry1.get("team", -1)) == enemy_team and bool(entry1.get("hittable", false)) == true
	proof["wiring_marks_has_type_true"] = observed.size() == 1 and bool(entry1.get("has_type", false)) == true

	# Phase 2: a team-less bullet and a bullet with no hittable
	# key join the live list -- the team-less one is excluded
	# (never defaulted to -1), the other defaults hittable
	# true, and the first bullet keeps its stable id.
	var b2 := _make_live_bullet(game, segment.position + Vector2(20, 0), 10.0, null, true)
	var b3 := _make_live_bullet(game, segment.position + Vector2(30, 0), 5.0, enemy_team, null)
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	observed = frame.get("observed_bullets", [])
	var entry3: Dictionary = _observed_entry(observed, b3.get_instance_id())
	proof["wiring_excludes_bullet_without_team"] = observed.size() == 2 and _observed_entry(observed, b2.get_instance_id()).is_empty()
	proof["wiring_defaults_hittable_true"] = bool(entry3.get("hittable", false)) == true
	proof["wiring_assigns_stable_id_from_sprite"] = bool(proof.get("wiring_assigns_stable_id_from_sprite", false)) and not _observed_entry(observed, b1.get_instance_id()).is_empty()

	# Phase 3: the live list empties -- the driver still stamps
	# `observed_bullets` (present but empty) on every tick.
	live_bullets.clear()
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var stamped_once: bool = frame.has("observed_bullets") and (frame.get("observed_bullets", [1]) as Array).is_empty()
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var stamped_twice: bool = frame.has("observed_bullets") and (frame.get("observed_bullets", [1]) as Array).is_empty()
	proof["wiring_stamps_observed_bullets_every_tick"] = stamped_once and stamped_twice

	# Phase 4: a live enemy bullet acquires a target (the timer
	# is seeded to fire), then leaves the live list -- the next
	# tick clears the pooled target.
	var b4 := _make_live_bullet(game, segment.position + Vector2(10, 0), 30.0, enemy_team, true)
	frame["target_timer"] = 4.99
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var target_4: Variant = frame.get("target", null)
	var acquired: bool = target_4 is Dictionary and int(target_4.get("id", -1)) == b4.get_instance_id() and bool(frame.get("has_target", false))
	live_bullets.clear()
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["wiring_clears_pooled_target_when_bullet_leaves_live_list"] = acquired and not bool(frame.get("has_target", true)) and frame.get("target", null) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretLiveBulletsWiringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
