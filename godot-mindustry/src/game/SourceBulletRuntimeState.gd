extends RefCounted
class_name SourceBulletRuntimeState

const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_bullet_spawn_state := preload("res://src/game/SourceBulletSpawnState.gd")
const source_bullet_target_runtime_state := preload("res://src/game/SourceBulletTargetRuntimeState.gd")
const source_bullet_source_text_state := preload("res://src/game/SourceBulletSourceTextState.gd")

const SOURCE_BULLET_TEXTURE_SPRITE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_SPRITE_FIELD
const SOURCE_BULLET_TEXTURE_BACK_SPRITE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_BACK_SPRITE_FIELD
const SOURCE_BULLET_TEXTURE_DEFAULT_SPRITE_CTOR := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_DEFAULT_SPRITE_CTOR
const SOURCE_BULLET_TEXTURE_FRONT_REGION_LOAD := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_FRONT_REGION_LOAD
const SOURCE_BULLET_TEXTURE_DEFAULT := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_DEFAULT
const SOURCE_BULLET_TEXTURE_ASSET_ROOT := source_bullet_source_text_state.SOURCE_BULLET_TEXTURE_ASSET_ROOT
const SOURCE_BULLET_RANGE_CHANGE_DEFAULT := source_bullet_defaults.RANGE_CHANGE_DEFAULT
const SOURCE_BULLET_RANGE_CHANGE_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_RANGE_CHANGE_COMMENT
const SOURCE_BULLET_RANGE_CHANGE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_RANGE_CHANGE_FIELD
const SOURCE_BULLET_RANGE_CHANGE_KEY := source_bullet_source_text_state.SOURCE_BULLET_RANGE_CHANGE_KEY
const SOURCE_BULLET_EXTRA_RANGE_MARGIN_DEFAULT := source_bullet_defaults.EXTRA_RANGE_MARGIN_DEFAULT
const SOURCE_BULLET_EXTRA_RANGE_MARGIN_KEY := source_bullet_source_text_state.SOURCE_BULLET_EXTRA_RANGE_MARGIN_KEY
const SOURCE_BULLET_INACCURACY_DEFAULT := source_bullet_defaults.INACCURACY_DEFAULT
const SOURCE_BULLET_INACCURACY_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_INACCURACY_COMMENT
const SOURCE_BULLET_INACCURACY_FIELD := source_bullet_source_text_state.SOURCE_BULLET_INACCURACY_FIELD
const SOURCE_BULLET_INACCURACY_KEY := source_bullet_source_text_state.SOURCE_BULLET_INACCURACY_KEY
const SOURCE_BULLET_LIFETIME_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_LIFETIME_COMMENT
const SOURCE_BULLET_LIFETIME_FIELD := source_bullet_source_text_state.SOURCE_BULLET_LIFETIME_FIELD
const SOURCE_BULLET_LIFETIME_KEY := source_bullet_source_text_state.SOURCE_BULLET_LIFETIME_KEY
const SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND := source_bullet_defaults.TICKS_PER_SECOND
const SOURCE_BULLET_WORLD_SPEED_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_WORLD_SPEED_COMMENT
const SOURCE_BULLET_WORLD_SPEED_FIELD := source_bullet_source_text_state.SOURCE_BULLET_WORLD_SPEED_FIELD
const SOURCE_BULLET_WORLD_SPEED_KEY := source_bullet_source_text_state.SOURCE_BULLET_WORLD_SPEED_KEY
const SOURCE_BULLET_WORLD_SPEED_STAT_CASE := source_bullet_source_text_state.SOURCE_BULLET_WORLD_SPEED_STAT_CASE
const SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND := source_bullet_defaults.TICKS_PER_SECOND
const SOURCE_BULLET_VELOCITY_SPEED_FIELD := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_SPEED_FIELD
const SOURCE_BULLET_VELOCITY_INIT_VEL_CALL := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_INIT_VEL_CALL
const SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_COMP_INIT_VEL_METHOD
const SOURCE_BULLET_VELOCITY_COMP_TRNS := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_COMP_TRNS
const SOURCE_BULLET_VELOCITY_COMP_ROTATION := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_COMP_ROTATION
const SOURCE_BULLET_VELOCITY_VECTOR_FIELD := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_FIELD
const SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_INIT_TRNS
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_METHOD
const SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_VEC2_TRNS_RETURN
const SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE
const SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE := source_bullet_source_text_state.SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE
const SOURCE_BULLET_HIT_SIZE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_HIT_SIZE_FIELD
const SOURCE_BULLET_HIT_SIZE_KEY := source_bullet_source_text_state.SOURCE_BULLET_HIT_SIZE_KEY
const SOURCE_BULLET_HIT_METHOD := source_bullet_source_text_state.SOURCE_BULLET_HIT_METHOD
const SOURCE_BULLET_HIT_CALL := source_bullet_source_text_state.SOURCE_BULLET_HIT_CALL
const SOURCE_BULLET_DAMAGE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_DAMAGE_FIELD
const SOURCE_BULLET_DAMAGE_KEY := source_bullet_source_text_state.SOURCE_BULLET_DAMAGE_KEY
const SOURCE_BULLET_DAMAGE_DEFAULT := source_bullet_defaults.DAMAGE_DEFAULT
const SOURCE_BULLET_AMMO_MULTIPLIER_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_AMMO_MULTIPLIER_COMMENT
const SOURCE_BULLET_AMMO_MULTIPLIER_FIELD := source_bullet_source_text_state.SOURCE_BULLET_AMMO_MULTIPLIER_FIELD
const SOURCE_BULLET_AMMO_MULTIPLIER_DEFAULT := source_bullet_defaults.AMMO_MULTIPLIER_DEFAULT
const SOURCE_BULLET_AMMO_MULTIPLIER_KEY := source_bullet_source_text_state.SOURCE_BULLET_AMMO_MULTIPLIER_KEY
const SOURCE_BULLET_RELOAD_MULTIPLIER_COMMENT := source_bullet_source_text_state.SOURCE_BULLET_RELOAD_MULTIPLIER_COMMENT
const SOURCE_BULLET_RELOAD_MULTIPLIER_FIELD := source_bullet_source_text_state.SOURCE_BULLET_RELOAD_MULTIPLIER_FIELD
const SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT := source_bullet_defaults.RELOAD_MULTIPLIER_DEFAULT
const SOURCE_BULLET_RELOAD_MULTIPLIER_KEY := source_bullet_source_text_state.SOURCE_BULLET_RELOAD_MULTIPLIER_KEY
const SOURCE_BULLET_SCALE_FIELD := source_bullet_source_text_state.SOURCE_BULLET_SCALE_FIELD
const SOURCE_BULLET_SCALE_WIDTH_DEFAULT := source_bullet_defaults.SCALE_WIDTH_DEFAULT
const SOURCE_BULLET_SCALE_WIDTH_KEY := source_bullet_source_text_state.SOURCE_BULLET_SCALE_WIDTH_KEY
const SOURCE_BULLET_SCALE_HEIGHT_DEFAULT := source_bullet_defaults.SCALE_HEIGHT_DEFAULT
const SOURCE_BULLET_SCALE_HEIGHT_KEY := source_bullet_source_text_state.SOURCE_BULLET_SCALE_HEIGHT_KEY
const SOURCE_BULLET_DESPAWNED_METHOD := source_bullet_source_text_state.SOURCE_BULLET_DESPAWNED_METHOD
const SOURCE_BULLET_DESPAWNED_HIT_GATE := source_bullet_source_text_state.SOURCE_BULLET_DESPAWNED_HIT_GATE

static func range_change(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RANGE_CHANGE_KEY, SOURCE_BULLET_RANGE_CHANGE_DEFAULT))

static func texture_path(sprite_id: String) -> String:
	var resolved_sprite := sprite_id if sprite_id != "" else SOURCE_BULLET_TEXTURE_DEFAULT
	return "%s/%s.png" % [SOURCE_BULLET_TEXTURE_ASSET_ROOT, resolved_sprite]

static func extra_range_margin(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_EXTRA_RANGE_MARGIN_KEY, SOURCE_BULLET_EXTRA_RANGE_MARGIN_DEFAULT))

static func inaccuracy(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_INACCURACY_KEY, SOURCE_BULLET_INACCURACY_DEFAULT))

static func lifetime_seconds(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_LIFETIME_KEY, source_bullet_defaults.LIFETIME_DEFAULT)) / SOURCE_BULLET_LIFETIME_TICKS_PER_SECOND

static func world_speed_per_tick(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_WORLD_SPEED_KEY, source_bullet_defaults.WORLD_SPEED_DEFAULT))

static func world_speed(data: Dictionary) -> float:
	return world_speed_per_tick(data) * SOURCE_BULLET_WORLD_SPEED_TICKS_PER_SECOND

static func velocity(data: Dictionary, shoot_angle_degrees: float) -> Vector2:
	var velocity_state := source_math_state.source_angles_trns_vec(shoot_angle_degrees, world_speed(data), 0.0)
	return Vector2(float(velocity_state.get("x", 0.0)), float(velocity_state.get("y", 0.0)))

static func source_bullet_velocity_vector_state(velocity_state: Dictionary) -> Dictionary:
	return {
		"source": SOURCE_BULLET_VELOCITY_VECTOR_EXISTING_SOURCE if bool(velocity_state.get("existing", false)) else SOURCE_BULLET_VELOCITY_VECTOR_TRNS_SOURCE,
		"velocity_state": velocity_state,
	}

static func hit_size(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_HIT_SIZE_KEY, source_bullet_defaults.HIT_SIZE_DEFAULT))

static func damage(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_DAMAGE_KEY, SOURCE_BULLET_DAMAGE_DEFAULT))

static func ammo_multiplier(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_AMMO_MULTIPLIER_KEY, SOURCE_BULLET_AMMO_MULTIPLIER_DEFAULT))

static func reload_multiplier(data: Dictionary) -> float:
	return float(data.get(SOURCE_BULLET_RELOAD_MULTIPLIER_KEY, SOURCE_BULLET_RELOAD_MULTIPLIER_DEFAULT))

static func dimensions(data: Dictionary) -> Dictionary:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, SOURCE_BULLET_SCALE_WIDTH_DEFAULT))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, SOURCE_BULLET_SCALE_HEIGHT_DEFAULT))
	return {"width": width, "height": height}

static func scale(data: Dictionary, texture_size: Vector2) -> Vector2:
	var width := float(data.get(SOURCE_BULLET_SCALE_WIDTH_KEY, SOURCE_BULLET_SCALE_WIDTH_DEFAULT))
	var height := float(data.get(SOURCE_BULLET_SCALE_HEIGHT_KEY, SOURCE_BULLET_SCALE_HEIGHT_DEFAULT))
	if texture_size.x <= 0.0 or texture_size.y <= 0.0:
		return Vector2.ONE
	return Vector2(width / texture_size.x, height / texture_size.y)

static func target_step_state(position: Vector2, target_position: Vector2, seconds: float, bullet_velocity: Vector2, lifetime_remaining: float, bullet_hit_size: float, bullet_damage: float, target_health: float) -> Dictionary:
	return source_bullet_target_runtime_state.target_step_state(position, target_position, seconds, bullet_velocity, lifetime_remaining, bullet_hit_size, bullet_damage, target_health)

static func spawn_state(data: Dictionary, shoot_angle_degrees: float, texture_size: Vector2) -> Dictionary:
	var bullet_damage := damage(data)
	var bullet_hit_size := hit_size(data)
	var bullet_speed := world_speed(data)
	return source_bullet_spawn_state.spawn_state_from_values(str(data.get("ammo_item", data.get("item", ""))), bullet_damage, reload_multiplier(data), velocity(data, shoot_angle_degrees), bullet_speed, bullet_hit_size, lifetime_seconds(data), str(data.get("sprite", SOURCE_BULLET_TEXTURE_DEFAULT)), scale(data, texture_size))

static func spawn_turret_bullet(game, origin: Vector2, target, data: Dictionary, shoot_angle_degrees := 0.0) -> void:
	if data.is_empty():
		return
	var spawn_texture: Texture2D = game.call("source_bullet_texture", str(data.get("sprite", SOURCE_BULLET_TEXTURE_DEFAULT))) as Texture2D
	var texture_size: Vector2 = spawn_texture.get_size() if spawn_texture else Vector2.ZERO
	var bullet_spawn_state := spawn_state(data, shoot_angle_degrees, texture_size)
	var bullet_texture := game.call("source_bullet_texture", str(bullet_spawn_state.get("sprite_id", SOURCE_BULLET_TEXTURE_DEFAULT))) as Texture2D
	source_bullet_spawn_state.spawn_turret_bullet_from_state(game, origin, target, bullet_spawn_state, bullet_texture)

static func target_step_context(game, bullet: Dictionary, seconds: float) -> Dictionary:
	return source_bullet_target_runtime_state.target_step_context(game, bullet, seconds)

static func target_step_from_context(context: Dictionary) -> Dictionary:
	return source_bullet_target_runtime_state.target_step_from_context(context, source_bullet_defaults.HIT_SIZE_DEFAULT)

static func runtime_step_context(game, bullet: Dictionary, seconds: float) -> Dictionary:
	return source_bullet_target_runtime_state.runtime_step_context(game, bullet, seconds)

static func runtime_step_from_context(context: Dictionary) -> Dictionary:
	return source_bullet_target_runtime_state.runtime_step_from_context(context, source_bullet_defaults.HIT_SIZE_DEFAULT)

static func runtime_hit_application_state(runtime_context: Dictionary, runtime_step: Dictionary, current_hit_count: int) -> Dictionary:
	return source_bullet_target_runtime_state.runtime_hit_application_state(runtime_context, runtime_step, current_hit_count)

static func simulate_bullets(game, delta: float) -> void:
	source_bullet_target_runtime_state.simulate_bullets(game, delta, source_bullet_defaults.HIT_SIZE_DEFAULT)
