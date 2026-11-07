extends RefCounted
class_name SourceUnitEnvironmentState

const source_unit_defaults := preload("res://src/game/SourceUnitDefaults.gd")
const source_world_defaults := preload("res://src/game/SourceWorldDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_unit_motion_state := preload("res://src/game/SourceUnitMotionState.gd")
const source_unit_falling_state := preload("res://src/game/SourceUnitFallingState.gd")

const SOURCE_UNIT_TRAIL_SCALE_DEFAULT := source_unit_defaults.TRAIL_SCALE_DEFAULT
const SOURCE_UNIT_DRAG_FLOOR_FACTOR_DEFAULT := source_unit_defaults.DRAG_FLOOR_FACTOR_DEFAULT
const SOURCE_UNIT_FALLING_DRAG_MIN := source_unit_defaults.FALLING_DRAG_MIN
const SOURCE_UNIT_FALL_SMOKE_CHANCE := source_unit_defaults.FALL_SMOKE_CHANCE
const SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR := source_unit_defaults.FALL_ENGINE_OFFSET_DIVISOR
const SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET := source_unit_defaults.FALL_ENGINE_ROTATION_OFFSET
const SOURCE_UNIT_FALL_ENGINE_TRAIL_CHANCE := source_unit_defaults.FALL_ENGINE_TRAIL_CHANCE
const SOURCE_UNIT_SOLID_TILE_BOOST_ELEVATION := source_unit_defaults.SOLID_TILE_BOOST_ELEVATION
const SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET := source_unit_defaults.SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_STRENGTH_OFFSET := source_unit_defaults.SPAWN_KNOCKBACK_STRENGTH_OFFSET
const SOURCE_UNIT_SPAWN_KNOCKBACK_SCALE := source_unit_defaults.SPAWN_KNOCKBACK_SCALE
const SOURCE_UNIT_SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR := source_unit_defaults.SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION := source_unit_defaults.FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION
const SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION := source_unit_defaults.FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_BASE := source_unit_defaults.WALK_EFFECT_THRESHOLD_BASE
const SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR := source_unit_defaults.WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR
const SOURCE_UNIT_WARP_DST := source_world_defaults.UNIT_WARP_DST
const SOURCE_FINAL_WORLD_BOUNDS := source_world_defaults.FINAL_WORLD_BOUNDS

static func trail_position_state(trail_exists: bool, type_trail_length: int, type_use_engine_elevation: bool, elevation_value: float, type_engine_offset: float, x_value: float, y_value: float, source_rotation_degrees: float) -> Dictionary:
	var trail_scale := elevation_value if type_use_engine_elevation else SOURCE_UNIT_TRAIL_SCALE_DEFAULT
	var offset := type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR + type_engine_offset / SOURCE_UNIT_FALL_ENGINE_OFFSET_DIVISOR * trail_scale
	var angle := source_rotation_degrees + SOURCE_UNIT_FALL_ENGINE_ROTATION_OFFSET
	var position_state := source_math_state.source_angles_trns_vec(angle, offset, 0.0)
	var cx := x_value + float(position_state.get("x", 0.0))
	var cy := y_value + float(position_state.get("y", 0.0))
	if not trail_exists:
		return {
			"trailExists": false,
			"scale": trail_scale,
			"offset": offset,
			"position": {"x": cx, "y": cy},
			"lengthSet": null,
			"trailUpdate": null,
		}
	return {
		"trailExists": true,
		"scale": trail_scale,
		"offset": offset,
		"position": {"x": cx, "y": cy},
		"lengthSet": {"call": "trail.length = type.trailLength", "length": type_trail_length},
		"trailUpdate": {"call": "trail.update(cx, cy)", "x": cx, "y": cy},
	}

static func drag_formula_state(type_drag: float, grounded_value: bool, floor_drag_multiplier: float, unit_drag_multiplier: float, rules_drag_multiplier: float) -> Dictionary:
	var floor_factor := floor_drag_multiplier if grounded_value else SOURCE_UNIT_DRAG_FLOOR_FACTOR_DEFAULT
	var unit_drag := type_drag * floor_factor * unit_drag_multiplier * rules_drag_multiplier
	return {
		"drag": unit_drag,
		"floorFactor": floor_factor,
		"grounded": grounded_value,
		"formula": "type.drag * (isGrounded() ? floorOn().dragMultiplier : 1f) * dragMultiplier * state.rules.dragMultiplier",
		"inputs": {
			"type.drag": type_drag,
			"floorOn().dragMultiplier": floor_drag_multiplier,
			"dragMultiplier": unit_drag_multiplier,
			"state.rules.dragMultiplier": rules_drag_multiplier,
		},
	}

static func falling_drag_state(dead_value: bool, health_value: float, current_drag: float) -> Dictionary:
	return source_unit_falling_state.falling_drag_state(dead_value, health_value, current_drag)

static func falling_smoke_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, hit_size: float, tmp_v1_x: float, tmp_v1_y: float) -> Dictionary:
	return source_unit_falling_state.falling_smoke_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, hit_size, tmp_v1_x, tmp_v1_y)

static func falling_engine_trail_state(dead_value: bool, health_value: float, chance_delta_result: bool, unit_x: float, unit_y: float, source_rotation_degrees: float, elevation_value: float, type_engine_offset: float, type_engine_size: float, engine_range_value: float, x_range_value: float, y_range_value: float, random_rotation_value: float) -> Dictionary:
	return source_unit_falling_state.falling_engine_trail_state(dead_value, health_value, chance_delta_result, unit_x, unit_y, source_rotation_degrees, elevation_value, type_engine_offset, type_engine_size, engine_range_value, x_range_value, y_range_value, random_rotation_value)

static func falling_descent_state(dead_value: bool, health_value: float, elevation_value: float, type_fall_speed: float, source_delta: float, is_grounded_value: bool, max_health: float, type_wreck_health_multiplier: float, unit_id: int) -> Dictionary:
	return source_unit_falling_state.falling_descent_state(dead_value, health_value, elevation_value, type_fall_speed, source_delta, is_grounded_value, max_health, type_wreck_health_multiplier, unit_id)

static func tile_unit_on_any_state(tile_exists: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and tile_build_exists
	var callback: Variant = null
	if guard:
		callback = {
			"call": "tile.build.unitOnAny(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"tileBuildExists": tile_build_exists,
		"unitOnAny": callback,
	}

static func tile_unit_on_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, tile_build_exists: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var callback: Variant = null
	if guard and tile_build_exists:
		callback = {
			"call": "tile.build.unitOn(self())",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"tileBuildExists": tile_build_exists,
		"unitOn": callback,
	}

static func floor_damage_state(tile_exists: bool, is_grounded_value: bool, type_hovering: bool, floor_damage_taken: float, source_delta: float, hit_time: float, hit_duration: float) -> Dictionary:
	var guard := tile_exists and is_grounded_value and not type_hovering
	var damage_call: Variant = null
	if guard and floor_damage_taken > 0.0:
		var scaled_damage := floor_damage_taken * source_delta
		var with_effect := hit_time <= -10.0 + hit_duration
		damage_call = {
			"call": "damageContinuous(floor.damageTaken)",
			"floor.damageTaken": floor_damage_taken,
			"Time.delta": source_delta,
			"scaledDamage": scaled_damage,
			"withEffect": with_effect,
		}
	return {
		"guard": guard,
		"tileExists": tile_exists,
		"isGrounded": is_grounded_value,
		"typeHovering": type_hovering,
		"damage": damage_call,
	}

static func solid_tile_response_state(tile_exists: bool, can_pass_on_value: bool, type_can_boost: bool, current_elevation: float, net_client_value: bool, headless_value: bool, is_remote_value: bool, unit_id: int) -> Dictionary:
	var guard := tile_exists and not can_pass_on_value
	var next_elevation := current_elevation
	var kill_call: Variant = null
	if guard and type_can_boost:
		next_elevation = SOURCE_UNIT_SOLID_TILE_BOOST_ELEVATION
	elif guard and (not net_client_value) and not ((not headless_value) and is_remote_value):
		kill_call = {
			"call": "kill()",
			"unit": unit_id,
		}
	return {
		"guard": guard,
		"canPassOn": can_pass_on_value,
		"typeCanBoost": type_can_boost,
		"elevation": next_elevation,
		"netClient": net_client_value,
		"headless": headless_value,
		"isRemote": is_remote_value,
		"kill": kill_call,
	}

static func spawn_knockback_state(team_is_wave_team: bool, state_has_spawns_value: bool, net_client_value: bool, is_local_value: bool, hittable_value: bool, drop_zone_radius: float, hit_size: float, unit_x: float, unit_y: float, spawns: Array, source_delta: float) -> Dictionary:
	var guard := (not team_is_wave_team) and state_has_spawns_value and ((not net_client_value) or is_local_value) and hittable_value
	var relative_size := drop_zone_radius + hit_size / SOURCE_UNIT_SPAWN_KNOCKBACK_HIT_SIZE_DIVISOR + SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET
	var knockbacks := []
	if guard:
		for spawn in spawns:
			var spawn_x := float(spawn.get("x", 0.0))
			var spawn_y := float(spawn.get("y", 0.0))
			var dx := unit_x - spawn_x
			var dy := unit_y - spawn_y
			var distance := sqrt(dx * dx + dy * dy)
			var within_spawn := distance * distance < relative_size * relative_size
			if within_spawn:
				var strength := SOURCE_UNIT_SPAWN_KNOCKBACK_STRENGTH_OFFSET + SOURCE_UNIT_SPAWN_KNOCKBACK_RELATIVE_SIZE_OFFSET - distance / relative_size
				var knockback_scale := SOURCE_UNIT_SPAWN_KNOCKBACK_SCALE * source_delta
				var length_factor := strength / distance if distance != 0.0 else 0.0
				knockbacks.append({
					"call": "velAddNet(Tmp.v1.set(this).sub(spawn.worldx(), spawn.worldy()).setLength(0.1f + 1f - dst(spawn) / relativeSize).scl(0.45f * Time.delta))",
					"spawn": {"x": spawn_x, "y": spawn_y},
					"distance": distance,
					"strength": strength,
					"velocity": {"x": dx * length_factor * knockback_scale, "y": dy * length_factor * knockback_scale},
				})
	return {
		"guard": guard,
		"relativeSize": relative_size,
		"knockbacks": knockbacks,
	}

static func bounds_state(type_bounded: bool, world_unit_height: float, world_unit_width: float, rules_limit_map_area: bool, team_is_ai: bool, rules_limit_x: int, rules_limit_y: int, rules_limit_width: int, rules_limit_height: int, current_x: float, current_y: float, elevation_value: float, net_client: bool, is_local: bool, source_delta: float) -> Dictionary:
	var next_x := current_x
	var next_y := current_y
	var bot := 0.0
	var left := 0.0
	var top := world_unit_height
	var right := world_unit_width
	var dx := 0.0
	var dy := 0.0
	var vel_add_net: Variant = null
	var can_apply_net_local := false
	var grounded: bool = source_unit_motion_state.is_grounded(elevation_value)
	var use_limited_area := rules_limit_map_area and not team_is_ai
	if not type_bounded:
		return {
			"bounded": false,
			"x": next_x,
			"y": next_y,
			"velAddNet": vel_add_net,
			"grounded": grounded,
			"kill": false,
		}
	if use_limited_area:
		bot = float(rules_limit_y) * source_world_defaults.TILESIZE
		left = float(rules_limit_x) * source_world_defaults.TILESIZE
		top = float(rules_limit_height) * source_world_defaults.TILESIZE + bot
		right = float(rules_limit_width) * source_world_defaults.TILESIZE + left
	if (not net_client) or is_local:
		can_apply_net_local = true
		if next_x < left:
			dx += (-(next_x - left) / SOURCE_UNIT_WARP_DST)
		if next_y < bot:
			dy += (-(next_y - bot) / SOURCE_UNIT_WARP_DST)
		if next_x > right - source_world_defaults.TILESIZE:
			dx -= (next_x - (right - source_world_defaults.TILESIZE)) / SOURCE_UNIT_WARP_DST
		if next_y > top - source_world_defaults.TILESIZE:
			dy -= (next_y - (top - source_world_defaults.TILESIZE)) / SOURCE_UNIT_WARP_DST
		vel_add_net = {"x": dx * source_delta, "y": dy * source_delta}
		var margin := source_world_defaults.TILESIZE * 1.0
		next_x = clampf(next_x, left - margin, right - source_world_defaults.TILESIZE + margin)
		next_y = clampf(next_y, bot - margin, top - source_world_defaults.TILESIZE + margin)
	if grounded:
		next_x = clampf(next_x, left, right - source_world_defaults.TILESIZE)
		next_y = clampf(next_y, bot, top - source_world_defaults.TILESIZE)
	var kill_unit := next_x < -SOURCE_FINAL_WORLD_BOUNDS + left or next_y < -SOURCE_FINAL_WORLD_BOUNDS + bot or next_x >= right + SOURCE_FINAL_WORLD_BOUNDS or next_y >= top + SOURCE_FINAL_WORLD_BOUNDS
	return {
		"bounded": true,
		"limits": {"bot": bot, "left": left, "top": top, "right": right, "limitedArea": use_limited_area},
		"canApplyNetLocal": can_apply_net_local,
		"dx": dx,
		"dy": dy,
		"velAddNet": vel_add_net,
		"grounded": grounded,
		"x": next_x,
		"y": next_y,
		"kill": kill_unit,
	}

static func nan_health_state(current_health: float) -> Dictionary:
	var health_is_nan := is_nan(current_health)
	return {
		"guard": "Float.isNaN(health)",
		"health": 0.0 if health_is_nan else current_health,
		"kill": health_is_nan,
	}

static func flying_transition_state(is_flying_value: bool, was_flying_value: bool, tile_exists: bool, floor_is_liquid: bool, tile_floor_color: String) -> Dictionary:
	var changed := is_flying_value != was_flying_value
	var land_effect: Variant = null
	if changed and was_flying_value and tile_exists:
		land_effect = {
			"call": "Fx.unitLand.at(x, y, floor.isLiquid ? 1f : 0.5f, tile.getFloorColor())",
			"rotation": SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_LIQUID_ROTATION if floor_is_liquid else SOURCE_UNIT_FLYING_TRANSITION_LAND_EFFECT_SOLID_ROTATION,
			"color": tile_floor_color,
		}
	return {
		"changed": changed,
		"landEffect": land_effect,
		"wasFlying": is_flying_value,
	}

static func walk_effect_state(type_hovering: bool, elevation_value: float, type_emit_walk_effect: bool, type_emit_walk_sound: bool, current_splash_timer: float, delta_x: float, delta_y: float, hit_size_value: float, tile_exists: bool, tile_floor_color: String, floor_map_color: String, floor_walk_sound_pitch_min: float, floor_walk_sound_pitch_max: float, floor_walk_sound_volume: float, random_pitch_value: float) -> Dictionary:
	var grounded := source_unit_motion_state.is_grounded(elevation_value)
	var gate := (not type_hovering) and grounded and type_emit_walk_effect
	var distance := sqrt(delta_x * delta_x + delta_y * delta_y)
	var threshold := SOURCE_UNIT_WALK_EFFECT_THRESHOLD_BASE + hit_size_value / SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR
	var splash_timer := current_splash_timer
	var walk_effect: Variant = null
	var walk_sound: Variant = null
	if gate:
		splash_timer += distance
		if splash_timer >= threshold:
			walk_effect = {
				"call": "floor.walkEffect.at(x, y, hitSize() / 8f, tile != null ? tile.getFloorColor() : floor.mapColor)",
				"rotation": hit_size_value / SOURCE_UNIT_WALK_EFFECT_THRESHOLD_HIT_SIZE_DIVISOR,
				"color": tile_floor_color if tile_exists else floor_map_color,
			}
			splash_timer = 0.0
			if type_emit_walk_sound:
				walk_sound = {
					"call": "floor.walkSound.at(x, y, Mathf.random(floor.walkSoundPitchMin, floor.walkSoundPitchMax), floor.walkSoundVolume)",
					"pitch": random_pitch_value,
					"pitchMin": floor_walk_sound_pitch_min,
					"pitchMax": floor_walk_sound_pitch_max,
					"volume": floor_walk_sound_volume,
				}
	return {
		"grounded": grounded,
		"gate": gate,
		"distance": distance,
		"threshold": threshold,
		"splashTimer": splash_timer,
		"walkEffect": walk_effect,
		"walkSound": walk_sound,
	}
