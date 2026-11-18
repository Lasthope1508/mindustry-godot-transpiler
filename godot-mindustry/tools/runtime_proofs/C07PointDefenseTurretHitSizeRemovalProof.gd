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


func _live_ids(game: Node) -> Array:
	var ids: Array = []
	for bullet in game.get("bullets"):
		if bullet is Dictionary:
			var sprite = bullet.get("sprite", null)
			if is_instance_valid(sprite) and sprite is Sprite2D:
				ids.append(sprite.get_instance_id())
	return ids


func _make_live_bullet(game: Node, position: Vector2, damage: float, team: Variant, hittable: Variant, hit_size: Variant) -> Sprite2D:
	# A live `game["bullets"]` dict exactly as the only writer
	# builds it (SourceBulletSpawnState.gd
	# spawn_turret_bullet_from_state: sprite / target / velocity /
	# speed / damage / hitSize / lifetime_remaining -- no team /
	# hittable / id / type); team, hittable and hitSize are added
	# only when the caller passes them, so the proof can seed a
	# bullet with no hitSize key (the BulletType 4f default) and a
	# bullet with an explicit hitSize.
	var sprite := Sprite2D.new()
	sprite.position = position
	game.add_child(sprite)
	var bullet := {"sprite": sprite, "target": null, "velocity": Vector2.ZERO, "speed": 0.0, "damage": damage, "lifetime_remaining": 10.0}
	if team != null:
		bullet["team"] = team
	if hittable != null:
		bullet["hittable"] = hittable
	if hit_size != null:
		bullet["hitSize"] = hit_size
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

	# --- PointDefenseTurret bullet hitSize + live bullet removal (N2247):
	# Java's retarget tests the bullet HITBOX against the range rect
	# (`target = Groups.bullet.intersect(x - range, y - range, range*2, range*2).min(b -> b.team != team && b.type().hittable, b -> b.dst2(this));`,
	# PointDefenseTurret.java:65-67; BulletComp implements Hitboxc,
	# BulletComp.java:28; hitSize is the BulletType hitbox size,
	# `public float hitSize = 4;`, BulletType.java:43, stamped onto
	# the live bullet at spawn, `bullet.hitSize = hitSize;`,
	# BulletType.java:970), so the N2242 wiring maps hitSize onto
	# the observed dicts and the acquire tests the hitbox overlap
	# (|bx - x| <= range + hitSize/2, |by - y| <= range +
	# hitSize/2). A lethally shot target is removed from the live
	# list (`if(target.damage() > realDamage){`,
	# PointDefenseTurret.java:94, else `target.remove();`,
	# PointDefenseTurret.java:96 -- which is what makes the next
	# tick's pooled check true, `if(target != null &&
	# !target.isAdded()){`, PointDefenseTurret.java:69-71), so the
	# driver filters it out of `game["bullets"]` on the shot tick
	# (source_point_defense_turret_bullet_removal_state). One
	# segment, sequential phases: 1 maps a live hitSize (6.0) and
	# defaults a bullet with no hitSize key to the BulletType 4f,
	# 2 acquires a bullet whose centre is just outside the range
	# rect but whose hitbox overlaps it (centre +181, hitSize 4),
	# 3 ignores a bullet fully outside by hitbox (centre +183,
	# hitSize 4), 4 lethally shoots the nearest bullet (damage 10
	# vs realDamage 30) and drops it from the live list while the
	# other bullet stays, 5 shoots a damaged bullet (damage 40)
	# and keeps it in the live list, 6 reports removed=false for
	# an absent id through the pure function directly.
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

	# Phase 1: one live enemy bullet with hitSize 6.0 and one with
	# no hitSize key -- the mapping carries the live hitSize and
	# defaults the missing one to the BulletType 4f.
	var b1 := _make_live_bullet(game, segment.position + Vector2(10, 0), 30.0, enemy_team, true, 6.0)
	var b2 := _make_live_bullet(game, segment.position + Vector2(20, 0), 30.0, enemy_team, true, null)
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var observed: Array = frame.get("observed_bullets", [])
	var entry1: Dictionary = _observed_entry(observed, b1.get_instance_id())
	var entry2: Dictionary = _observed_entry(observed, b2.get_instance_id())
	proof["hitsize_maps_live_bullet_hit_size"] = observed.size() == 2 and float(entry1.get("hit_size", 0.0)) == 6.0
	proof["hitsize_defaults_to_bullet_type_default"] = observed.size() == 2 and float(entry2.get("hit_size", 0.0)) == 4.0

	# Phase 2: a bullet whose centre is just outside the range
	# rect (+181 vs range 180) but whose hitbox overlaps it
	# (hitSize 4, half 2, 181 <= 182) -- the timer is seeded to
	# fire, so the acquire picks it up.
	var live_bullets: Array = game.get("bullets")
	live_bullets.clear()
	var b3 := _make_live_bullet(game, segment.position + Vector2(181, 0), 30.0, enemy_team, true, 4.0)
	frame["target_timer"] = 4.99
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var target_3: Variant = frame.get("target", null)
	proof["hitsize_acquires_bullet_touching_range_edge"] = target_3 is Dictionary and int(target_3.get("id", -1)) == b3.get_instance_id() and bool(frame.get("has_target", false))

	# Phase 3: a bullet fully outside the rect by hitbox (centre
	# +183, hitSize 4, 183 > 182) -- the acquire finds nothing and
	# the pooled previous target clears.
	live_bullets = game.get("bullets")
	live_bullets.clear()
	var b4 := _make_live_bullet(game, segment.position + Vector2(183, 0), 30.0, enemy_team, true, 4.0)
	frame["target_timer"] = 4.99
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	proof["hitsize_ignores_bullet_fully_outside_range"] = frame.get("target", null) == null and not bool(frame.get("has_target", true))

	# Phase 4: the nearest bullet (damage 10, +10) is lethally
	# shot (realDamage 30: bulletDamage 30f per-def, Blocks.java:3844,
	# times blockDamageMultiplier 1.0) -- rotation is already 90
	# (the class default, BaseTurret.java:114) and dest is
	# atan2(10, 0) = 90, so the shoot gate's angle check passes
	# with reloadCounter seeded to the per-def reload 8.0; the
	# driver drops it from the live list while the other bullet
	# (+20, damage 40) stays.
	live_bullets = game.get("bullets")
	live_bullets.clear()
	var b5 := _make_live_bullet(game, segment.position + Vector2(10, 0), 10.0, enemy_team, true, 4.0)
	var b6 := _make_live_bullet(game, segment.position + Vector2(20, 0), 40.0, enemy_team, true, 4.0)
	frame["target_timer"] = 4.99
	frame["reload_counter"] = 8.0
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	var live_ids: Array = _live_ids(game)
	proof["removal_drops_lethally_shot_bullet_from_live_list"] = bool(frame.get("shot", false)) and frame.get("target", null) == null and not live_ids.has(b5.get_instance_id())
	proof["removal_keeps_other_bullets"] = live_ids.has(b6.get_instance_id())

	# Phase 5: a bullet with damage 40 is shot but not lethally
	# (40 > realDamage 30) -- it keeps its live dict and stays
	# the frame target.
	live_bullets = game.get("bullets")
	live_bullets.clear()
	var b7 := _make_live_bullet(game, segment.position + Vector2(10, 0), 40.0, enemy_team, true, 4.0)
	frame["target_timer"] = 4.99
	frame["reload_counter"] = 8.0
	point_defense_turret_build_state.source_point_defense_turret_tick_buildings_state(game, 1.0 / 60.0)
	frame = segment.get_meta(point_defense_turret_build_state.SOURCE_POINT_DEFENSE_TURRET_BUILDING_META_KEY, {})
	live_ids = _live_ids(game)
	var target_7: Variant = frame.get("target", null)
	proof["removal_keeps_damaged_bullet_in_live_list"] = bool(frame.get("shot", false)) and live_ids.has(b7.get_instance_id()) and target_7 is Dictionary and int(target_7.get("id", -1)) == b7.get_instance_id()

	# Phase 6: the pure removal function reports removed=false
	# for an id that is not in the live list, and the list is
	# unchanged.
	var removal: Dictionary = point_defense_turret_build_state.source_point_defense_turret_bullet_removal_state(game.get("bullets"), 987654321)
	proof["removal_reports_removed_false_when_id_absent"] = not bool(removal.get("removed", true)) and (removal.get("remaining_bullets", []) as Array).size() == (game.get("bullets") as Array).size()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretHitSizeRemovalProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
