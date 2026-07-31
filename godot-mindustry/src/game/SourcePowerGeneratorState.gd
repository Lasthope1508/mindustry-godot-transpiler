extends RefCounted
class_name SourcePowerGeneratorState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_rules_defaults := preload("res://src/game/SourceRulesDefaults.gd")
const source_math_state := preload("res://src/game/SourceMathState.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")

const SOURCE_RULES_REACTOR_EXPLOSIONS_DEFAULT := source_rules_defaults.REACTOR_EXPLOSIONS_DEFAULT


static func get_power_production_state(enabled: bool, power_production: float, production_efficiency: float) -> Dictionary:
	var computed_power_production: float = power_production * production_efficiency if enabled else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_GET_POWER_PRODUCTION_STATE,
		"field": "public float powerProduction;",
		"method": "public float getPowerProduction(){",
		"return_power_production": "return enabled ? powerProduction * productionEfficiency : 0f;",
		"enabled": enabled,
		"power_production": power_production,
		"production_efficiency": production_efficiency,
		"computed_power_production": computed_power_production,
	}


static func displayed_power_production_state(power_production: float) -> Dictionary:
	var displayed_power_production: float = power_production
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_STATE,
		"source": "core/src/mindustry/world/blocks/power/PowerGenerator.java",
		"field": "public float powerProduction;",
		"method": "public float getDisplayedPowerProduction(){",
		"return_power_production": "return powerProduction;",
		"schematic_method": "public float powerProduction(){",
		"schematic_sum_source": "return tiles.sumf(s -> s.block instanceof PowerGenerator p ? p.getDisplayedPowerProduction() : 0f);",
		"power_production": power_production,
		"displayed_power_production": displayed_power_production,
	}


static func generated_displayed_power_production_bridge_state(power_production: float) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/blocks/power/PowerGenerator.gd")
	var instance = script.new()
	var result = instance.java_method_getDisplayedPowerProduction_0([power_production])
	var canonical = displayed_power_production_state(power_production)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_DISPLAYED_POWER_PRODUCTION_STATE,
		"generated_owner": "power_generator.getDisplayedPowerProduction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("displayed_power_production", null) == canonical.get("displayed_power_production", null) and result.get("power_production", null) == canonical.get("power_production", null) and result.get("return_power_production", null) == canonical.get("return_power_production", null),
	}


static func build_serialization_state(production_efficiency: float, generate_time: float, revision: int, read_production_efficiency_value: float, read_generate_time_value: float) -> Dictionary:
	var write_values := [production_efficiency, generate_time]
	var read_production_efficiency_applied: bool = revision >= 1
	var read_generate_time_applied: bool = revision >= 1
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_BUILD_SERIALIZATION_STATE,
		"version_method": "public byte version(){",
		"version_return": "return 1;",
		"write_method": "public void write(Writes write){",
		"write_super": "super.write(write);",
		"write_production_efficiency": "write.f(productionEfficiency);",
		"write_generate_time": "write.f(generateTime);",
		"write_values": write_values,
		"read_method": "public void read(Reads read, byte revision){",
		"read_super": "super.read(read, revision);",
		"read_revision_guard": "if(revision >= 1){",
		"read_production_efficiency_value": read_production_efficiency_value,
		"read_generate_time_value": read_generate_time_value,
		"read_production_efficiency_applied": read_production_efficiency_applied,
		"read_generate_time_applied": read_generate_time_applied,
	}


static func solar_update_tile_state(enabled: bool, solar_multiplier: float, light_env: float, lighting: bool, ambient_light_alpha: float) -> Dictionary:
	var max_zero_input: float = light_env * solar_multiplier
	var lighting_bonus: float = (1.0 - ambient_light_alpha) if lighting else 1.0
	var production_efficiency: float = maxf(max_zero_input, 0.0) * lighting_bonus if enabled else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_SOLAR_GENERATOR_UPDATE_TILE_STATE,
		"method": "public void updateTile(){",
		"assignment": "productionEfficiency = enabled ?",
		"enabled": enabled,
		"solar_multiplier": solar_multiplier,
		"light_env": light_env,
		"lighting": lighting,
		"ambient_light_alpha": ambient_light_alpha,
		"max_zero_input": max_zero_input,
		"production_efficiency": production_efficiency,
	}


static func warmup_state(enabled: bool, production_efficiency: float) -> Dictionary:
	var warmup: float = production_efficiency if enabled else 0.0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_WARMUP_STATE,
		"method": "public float warmup(){",
		"return_warmup": "return enabled ? productionEfficiency : 0f;",
		"enabled": enabled,
		"production_efficiency": production_efficiency,
		"warmup": warmup,
	}


static func should_explode_state(warmup_value: float, explosion_min_warmup: float) -> Dictionary:
	var should_explode: bool = warmup_value >= explosion_min_warmup
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_SHOULD_EXPLODE_STATE,
		"field": "public float explosionMinWarmup = 0f;",
		"method": "public boolean shouldExplode(){",
		"return_should_explode": "return warmup() >= explosionMinWarmup;",
		"warmup": warmup_value,
		"explosion_min_warmup": explosion_min_warmup,
		"should_explode": should_explode,
	}


static func ambient_volume_state(production_efficiency: float) -> Dictionary:
	var ambient_volume: float = clampf(production_efficiency, 0.0, 1.0)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_AMBIENT_VOLUME_STATE,
		"method": "public float ambientVolume(){",
		"return_clamp": "return Mathf.clamp(productionEfficiency);",
		"production_efficiency": production_efficiency,
		"ambient_volume": ambient_volume,
	}


static func create_explosion_gate_state(should_explode_value: bool) -> Dictionary:
	var branch_entered: bool = should_explode_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_GATE_STATE,
		"method": "public void createExplosion(){",
		"gate": "if(shouldExplode()){",
		"should_explode": should_explode_value,
		"branch_entered": branch_entered,
		"complete": false,
	}


static func create_explosion_damage_state(should_explode_value: bool, source_x: float, source_y: float, explosion_radius: int, explosion_damage: int, source_tilesize: int) -> Dictionary:
	var damage_radius: float = float(explosion_radius * source_tilesize)
	var damage_dispatched: bool = should_explode_value and explosion_damage > 0
	var damage_call: Dictionary = {}
	if damage_dispatched:
		damage_call = {"call": "Damage.damage(x, y, explosionRadius * tilesize, explosionDamage);", "x": source_x, "y": source_y, "radius": damage_radius, "damage": explosion_damage}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_DAMAGE_STATE,
		"method": "public void createExplosion(){",
		"damage_guard": "if(explosionDamage > 0){",
		"damage_dispatch": "Damage.damage(x, y, explosionRadius * tilesize, explosionDamage);",
		"should_explode": should_explode_value,
		"damage_dispatched": damage_dispatched,
		"damage_radius": damage_radius,
		"damage_call": damage_call,
		"complete": false,
	}


static func create_explosion_effect_sound_state(should_explode_value: bool, source_x: float, source_y: float, explode_effect_value: String, explode_sound_value: String) -> Dictionary:
	var effect_dispatched: bool = should_explode_value
	var sound_dispatched: bool = should_explode_value
	var effect_call: Dictionary = {}
	var sound_call: Dictionary = {}
	if effect_dispatched:
		effect_call = {"call": "explodeEffect.at(this);", "effect": explode_effect_value, "x": source_x, "y": source_y}
	if sound_dispatched:
		sound_call = {"call": "explodeSound.at(this);", "sound": explode_sound_value, "x": source_x, "y": source_y}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_EFFECT_SOUND_STATE,
		"method": "public void createExplosion(){",
		"effect_dispatch": "explodeEffect.at(this);",
		"sound_dispatch": "explodeSound.at(this);",
		"effect_dispatched": effect_dispatched,
		"sound_dispatched": sound_dispatched,
		"effect_call": effect_call,
		"sound_call": sound_call,
	}


static func create_explosion_puddle_loop_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int) -> Dictionary:
	var puddle_guard_entered: bool = should_explode_value and explosion_puddle_liquid_value != null
	var puddle_loop_count: int = explosion_puddles if puddle_guard_entered else 0
	var puddle_loop_indices: Array = []
	for i in range(puddle_loop_count):
		puddle_loop_indices.append(i)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_PUDDLE_LOOP_STATE,
		"method": "public void createExplosion(){",
		"puddle_guard": "if(explosionPuddleLiquid != null){",
		"puddle_loop": "for(int i = 0; i < explosionPuddles; i++){",
		"puddle_guard_entered": puddle_guard_entered,
		"puddle_loop_count": puddle_loop_count,
		"puddle_loop_indices": puddle_loop_indices,
	}


static func create_explosion_puddle_vector_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_range: float, random_angle_units: Array, random_range_units: Array) -> Dictionary:
	var tmp_v1_vectors: Array = []
	var puddle_guard_entered: bool = should_explode_value and explosion_puddle_liquid_value != null
	var puddle_loop_count: int = explosion_puddles if puddle_guard_entered else 0
	for i in range(puddle_loop_count):
		var angle_unit: float = float(random_angle_units[i] if i < random_angle_units.size() else 0.0)
		var range_unit: float = float(random_range_units[i] if i < random_range_units.size() else 0.0)
		var angle_degrees: float = angle_unit * source_math_defaults.FULL_CIRCLE_DEGREES
		var x_value: float = range_unit * explosion_puddle_range
		var y_value: float = 0.0
		var result := source_math_state.source_angles_trns_vec(angle_degrees, x_value, y_value)
		tmp_v1_vectors.append(result)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_PUDDLE_VECTOR_STATE,
		"method": "public void createExplosion(){",
		"puddle_range_field": "public float explosionPuddleRange = tilesize * 2f;",
		"random_vector": "Tmp.v1.trns(Mathf.random(360f), Mathf.random(explosionPuddleRange));",
		"random_angle_range": source_math_defaults.FULL_CIRCLE_DEGREES,
		"random_angle_units": random_angle_units,
		"random_range_units": random_range_units,
		"tmp_v1_vectors": tmp_v1_vectors,
		"tile_deposit_deferred": "Tile tile = world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y); Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
	}


static func create_explosion_puddle_tile_world_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, source_x: float, source_y: float, source_tilesize: int, tmp_v1_vectors: Array) -> Dictionary:
	var tile_world_calls: Array = []
	var missing_tmp_v1_count: int = 0
	var puddle_guard_entered: bool = should_explode_value and explosion_puddle_liquid_value != null
	var puddle_loop_count: int = explosion_puddles if puddle_guard_entered else 0
	for i in range(puddle_loop_count):
		if i >= tmp_v1_vectors.size():
			missing_tmp_v1_count += 1
			continue
		var vector: Dictionary = tmp_v1_vectors[i] if tmp_v1_vectors[i] is Dictionary else {}
		var world_x: float = source_x + float(vector.get("x", 0.0))
		var world_y: float = source_y + float(vector.get("y", 0.0))
		tile_world_calls.append({"call": "world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y);", "x": world_x, "y": world_y, "tile_x": roundi(world_x / source_tilesize), "tile_y": roundi(world_y / source_tilesize)})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_PUDDLE_TILE_WORLD_STATE,
		"method": "public void createExplosion(){",
		"tile_assignment": "Tile tile = world.tileWorld(x + Tmp.v1.x, y + Tmp.v1.y);",
		"world_tile_world_return": "return tile(Math.round(x / tilesize), Math.round(y / tilesize));",
		"tile_world_calls": tile_world_calls,
		"missing_tmp_v1_count": missing_tmp_v1_count,
		"deposit_deferred": "Puddles.deposit(tile, explosionPuddleLiquid, explosionPuddleAmount);",
	}


static func create_explosion_puddle_deposit_state(should_explode_value: bool, explosion_puddle_liquid_value: Variant, explosion_puddles: int, explosion_puddle_amount: float, tile_world_calls: Array) -> Dictionary:
	var deposit_calls: Array = []
	var missing_tile_world_call_count: int = 0
	var puddle_guard_entered: bool = should_explode_value and explosion_puddle_liquid_value != null
	var puddle_loop_count: int = explosion_puddles if puddle_guard_entered else 0
	for i in range(puddle_loop_count):
		if i >= tile_world_calls.size():
			missing_tile_world_call_count += 1
			continue
		var tile_world_call: Variant = tile_world_calls[i]
		deposit_calls.append({"call": "deposit(tile, tile, liquid, amount, true);", "tile": tile_world_call, "liquid": explosion_puddle_liquid_value, "amount": explosion_puddle_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_PUDDLE_DEPOSIT_STATE,
		"method": "public void createExplosion(){",
		"puddle_amount_field": "public float explosionPuddleAmount = 100f;",
		"puddles_deposit_tile_dispatch": "deposit(tile, tile, liquid, amount, true);",
		"puddles_null_guard": "if(tile == null) return;",
		"deposit_calls": deposit_calls,
		"missing_tile_world_call_count": missing_tile_world_call_count,
		"puddle_mutation_deferred": true,
	}


static func create_explosion_shake_state(should_explode_value: bool, source_x: float, source_y: float, explosion_shake: float, explosion_shake_duration: float) -> Dictionary:
	var shake_dispatched: bool = should_explode_value and explosion_shake > 0.0
	var shake_call: Dictionary = {}
	if shake_dispatched:
		shake_call = {"call": "Effect.shake(explosionShake, explosionShakeDuration, this);", "intensity": explosion_shake, "duration": explosion_shake_duration, "x": source_x, "y": source_y}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_CREATE_EXPLOSION_SHAKE_STATE,
		"method": "public void createExplosion(){",
		"shake_fields": "public float explosionShake = 0f, explosionShakeDuration = 6f;",
		"shake_guard": "if(explosionShake > 0){",
		"shake_call": "Effect.shake(explosionShake, explosionShakeDuration, this);",
		"effect_shake_position_dispatch": "shake(intensity, duration, loc.getX(), loc.getY());",
		"shake_dispatched": shake_dispatched,
		"shake_call_state": shake_call,
		"camera_falloff_deferred": true,
	}


static func on_destroyed_reactor_explosion_state(reactor_explosions: bool = source_rules_defaults.REACTOR_EXPLOSIONS_DEFAULT, create_explosion_state: Dictionary = {}) -> Dictionary:
	var create_explosion_called: bool = reactor_explosions
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_POWER_GENERATOR_ON_DESTROYED_REACTOR_EXPLOSION_STATE,
		"method": "public void onDestroyed(){",
		"super_call": "super.onDestroyed();",
		"reactor_explosions_field": "public boolean reactorExplosions = true;",
		"reactor_explosions_guard": "if(state.rules.reactorExplosions){",
		"create_explosion_call": "createExplosion();",
		"reactor_explosions": reactor_explosions,
		"create_explosion_state": create_explosion_state,
		"create_explosion_called": create_explosion_called,
		"super_on_destroyed_deferred": true,
	}
