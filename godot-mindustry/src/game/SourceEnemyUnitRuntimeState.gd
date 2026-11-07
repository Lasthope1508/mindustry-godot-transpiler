extends RefCounted
class_name SourceEnemyUnitRuntimeState

const source_content_registry_source_text_state := preload("res://src/game/SourceContentRegistrySourceTextState.gd")
static var ContentRegistry := load(source_content_registry_source_text_state.CONTENT_REGISTRY)
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_wave_spawn_runtime_state := preload("res://src/game/SourceWaveSpawnRuntimeState.gd")

const SOURCE_SUICIDE_AI_TARGET_RADIUS_EXPR := "(target instanceof Building b ? b.block.size * Vars.tilesize / 2f : ((Hitboxc)target).hitSize() / 2f)"
const SOURCE_SUICIDE_AI_MOVE_PREF_EXPR := "unit.movePref(vec.set(target).sub(unit).limit(unit.speed()));"
const SOURCE_UNIT_MOVE_AT_ACCEL_EXPR := "moveAt(vector, type.accel);"
const SOURCE_UNIT_VELOCITY_APPROACH_EXPR := "vel.approachDelta(vector, type.accel * speed());"

static func core_impact_radius(tile_size: float, radius_fraction: float) -> float:
	return tile_size * radius_fraction

static func enemy_step_state(position: Vector2, target: Vector2, seconds: float, world_speed: float, impact_radius: float, weapon_damage: float, core_health: float) -> Dictionary:
	var direction := target - position
	var distance := direction.length()
	var hit_core := distance <= impact_radius
	var next_position := position
	if not hit_core and distance > 0.0:
		next_position = position + direction.normalized() * world_speed * seconds
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ENEMY_UNIT_RUNTIME_ENEMY_STEP_STATE,
		"distance": distance,
		"impact_radius": impact_radius,
		"world_speed": world_speed,
		"hit_core": hit_core,
		"core_damage": min(core_health, max(0.0, weapon_damage)) if hit_core else 0.0,
		"next_position": next_position,
		"suicide_ai_target_radius_expr": SOURCE_SUICIDE_AI_TARGET_RADIUS_EXPR,
		"suicide_ai_move_pref_expr": SOURCE_SUICIDE_AI_MOVE_PREF_EXPR,
		"unit_move_at_accel_expr": SOURCE_UNIT_MOVE_AT_ACCEL_EXPR,
		"unit_velocity_approach_expr": SOURCE_UNIT_VELOCITY_APPROACH_EXPR,
	}

static func enemy_step_context(game, enemy: Dictionary, target: Vector2, seconds: float) -> Dictionary:
	var sprite = enemy.get("sprite")
	var unit_type = enemy.get("type")
	var position: Vector2 = sprite.position if is_instance_valid(sprite) else target
	return {
		"position": position,
		"target": target,
		"seconds": seconds,
		"world_speed": float(game.call("source_unit_world_speed", unit_type)),
		"impact_radius": core_impact_radius(float(game.get("tile_size")), source_playable_scenario_defaults.ENEMY_CORE_IMPACT_RADIUS_TILE_FRACTION),
		"weapon_damage": float(game.call("source_unit_weapon_damage", unit_type)),
		"core_health": float(game.get("core_health")),
	}

static func enemy_step_from_context(context: Dictionary) -> Dictionary:
	return enemy_step_state(
		context.get("position", Vector2.ZERO),
		context.get("target", Vector2.ZERO),
		float(context.get("seconds", 0.0)),
		float(context.get("world_speed", 0.0)),
		float(context.get("impact_radius", 0.0)),
		float(context.get("weapon_damage", 0.0)),
		float(context.get("core_health", 0.0))
	)

static func spawn_unit_state(unit_id: String, spawn_position: Vector2, texture_size: Vector2, hit_size: float, health: float) -> Dictionary:
	var sprite_scale := Vector2.ONE
	if texture_size.x > 0.0 and texture_size.y > 0.0:
		sprite_scale = Vector2(hit_size / texture_size.x, hit_size / texture_size.y)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ENEMY_UNIT_RUNTIME_SPAWN_UNIT_STATE,
		"unit_id": unit_id,
		"spawn_position": spawn_position,
		"texture_size": texture_size,
		"hit_size": hit_size,
		"sprite_scale": sprite_scale,
		"health": health,
	}

static func spawn_unit(game: Object, unit_type, index: int) -> Dictionary:
	if game == null or unit_type == null:
		return {}
	var unit_id := str(unit_type.id)
	var textures: Dictionary = game.get("textures")
	var texture: Texture2D = textures.get("unit:" + unit_id, null) as Texture2D
	var texture_size: Vector2 = texture.get_size() if texture else Vector2.ZERO
	var spawn_position: Vector2 = game.call("grid_to_world", source_playable_scenario_defaults.enemy_spawn_cell(index))
	var hit_size := float(game.call("source_unit_hit_size", unit_type))
	var health := float(game.call("source_unit_health", unit_type))
	var spawn_state := spawn_unit_state(unit_id, spawn_position, texture_size, hit_size, health)
	var units_layer: Node = game.get_node("World/UnitLayer")
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = spawn_position
	if sprite.texture and texture_size.x > 0.0 and texture_size.y > 0.0:
		sprite.scale = spawn_state.get("sprite_scale", Vector2.ONE) as Vector2
	units_layer.add_child(sprite)
	var enemy_units: Array = game.get("enemy_units")
	enemy_units.append({"sprite": sprite, "type": unit_type, "health": health})
	game.set("enemy_units", enemy_units)
	spawn_state["sprite"] = sprite
	return spawn_state

static func selected_enemy_unit(game: Object):
	if game == null:
		return null
	var content_catalog = game.get("content_catalog")
	if content_catalog == null:
		return null
	var dagger = content_catalog.get_by_id("dagger")
	if dagger != null:
		return dagger
	var units: Array = content_catalog.get_many("unit")
	return units[0] if not units.is_empty() else null

static func spawn_wave_state(wave_index: int, fallback_unit_id: String) -> Dictionary:
	var wave_state := source_wave_spawn_runtime_state.wave_spawn_state(ContentRegistry.WAVES.get("groups", []), wave_index, fallback_unit_id)
	wave_state["source_owner"] = source_runtime_owner_registry.PORT_GAME_SOURCE_ENEMY_UNIT_RUNTIME_SPAWN_WAVE_STATE
	return wave_state

static func spawn_wave(game: Object) -> void:
	if game == null:
		return
	var spawned := 0
	var wave_index := int(game.get("wave_index"))
	game.set("last_spawned_wave_index", wave_index)
	game.set("last_spawned_wave_count", 0)
	var fallback_unit = selected_enemy_unit(game)
	var fallback_unit_id := str(fallback_unit.id) if fallback_unit != null else ""
	var wave_state := spawn_wave_state(wave_index, fallback_unit_id)
	game.set("last_spawned_wave_groups", wave_state.get("groups", []))
	var content_catalog = game.get("content_catalog")
	for request in wave_state.get("spawn_requests", []):
		var unit_type = content_catalog.get_by_id(str(request.get("unit", ""))) if content_catalog != null else null
		if unit_type == null:
			continue
		game.call("spawn_enemy_unit", unit_type, int(request.get("index", spawned)))
		spawned += 1
	game.set("last_spawned_wave_count", spawned)

static func simulate_units(game, delta: float) -> void:
	if game == null:
		return
	if float(game.get("core_health")) <= 0.0:
		return
	var enemy_units: Array = game.get("enemy_units")
	var alive: Array = []
	var target: Vector2 = game.call("grid_to_world", game.get("core_pos"))
	for enemy in enemy_units:
		var sprite = enemy.get("sprite")
		if not is_instance_valid(sprite):
			continue
		var enemy_context := enemy_step_context(game, enemy, target, delta)
		var enemy_step := enemy_step_from_context(enemy_context)
		if bool(enemy_step.get("hit_core", false)):
			var core_damage: float = float(enemy_step.get("core_damage", 0.0))
			game.call("apply_core_damage", core_damage)
			sprite.queue_free()
			continue
		var next_position: Vector2 = enemy_step.get("next_position", sprite.position)
		sprite.position = next_position
		alive.append(enemy)
	game.set("enemy_units", alive)
	var wave_timing: Dictionary = game.call("source_wave_timing_runtime_state", delta)
	game.set("wave_cooldown", float(wave_timing.get("wavetime", game.get("wave_cooldown"))))
	if bool(wave_timing.get("should_spawn", false)):
		game.set("wave_index", int(game.get("wave_index")) + 1)
		game.call("spawn_enemy_wave")

static func runtime_summary_state(game: Object) -> Dictionary:
	var unit_type = game.call("selected_enemy_unit")
	var enemy_units: Array = game.get("enemy_units")
	var first_enemy: Dictionary = enemy_units[0] if not enemy_units.is_empty() else {}
	var first_enemy_sprite = first_enemy.get("sprite", null)
	var first_enemy_position := {}
	if is_instance_valid(first_enemy_sprite):
		first_enemy_position = {"x": first_enemy_sprite.position.x, "y": first_enemy_sprite.position.y}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ENEMY_UNIT_RUNTIME_RUNTIME_SUMMARY_STATE,
		"enemy_count": enemy_units.size(),
		"wave_index": int(game.get("wave_index")),
		"last_spawned_wave_index": int(game.get("last_spawned_wave_index")),
		"last_spawned_wave_count": int(game.get("last_spawned_wave_count")),
		"selected_enemy_weapon_damage": game.call("source_unit_weapon_damage", unit_type),
		"selected_enemy_world_speed": game.call("source_unit_world_speed", unit_type),
		"selected_enemy_hit_size": game.call("source_unit_hit_size", unit_type),
		"selected_enemy_health": game.call("source_unit_health", unit_type),
		"first_enemy_health": float(first_enemy.get("health", 0.0)),
		"first_enemy_position": first_enemy_position,
		"core_health": float(game.get("core_health")),
		"core_damage_taken_total": float(game.get("core_damage_taken_total")),
	}
