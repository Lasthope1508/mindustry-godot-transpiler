extends RefCounted
class_name SourceTurretRuntimeState

const SourceGeneratedClassRuntime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const SourceMathState := preload("res://src/game/SourceMathState.gd")
const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceTurretPropertyState := preload("res://src/game/SourceTurretPropertyState.gd")

const SOURCE_TURRET_LIMIT_RANGE_MARGIN_DEFAULT := SourceTurretDefaults.LIMIT_RANGE_MARGIN_DEFAULT
const SOURCE_TURRET_CONSUME_AMMO_ONCE_DEFAULT := SourceTurretDefaults.CONSUME_AMMO_ONCE_DEFAULT
const SOURCE_TURRET_UPDATE_TILE_METHOD := "public void updateTile(){"
const SOURCE_TURRET_UPDATE_RELOAD_EXPR := "reloadCounter += delta() * ammoReloadMultiplier() * baseReloadSpeed();"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_METHOD := "protected float ammoReloadMultiplier(){"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_RETURN := "return hasAmmo() ? peekAmmo().reloadMultiplier : 1f;"
const SOURCE_TURRET_RELOAD_SECONDS_FOR_AMMO_FORMULA := "source_turret_reload_seconds(turret) / source_bullet_reload_multiplier(data)"
const SOURCE_TURRET_RELOAD_CAP_EXPR := "reloadCounter = Math.min(reloadCounter, reload);"
const SOURCE_TURRET_TURN_TO_TARGET_EXPR := "rotation = Angles.moveToward(rotation, targetRot, rotateSpeed * delta() * potentialEfficiency);"
const SOURCE_TURRET_SHOOT_GATE_EXPR := "if(!alwaysShooting && Angles.angleDist(rotation, targetRot) < shootCone && canShoot){"
const SOURCE_TURRET_UPDATE_SHOOTING_METHOD := "protected void updateShooting(){"
const SOURCE_TURRET_RELOAD_MOD_EXPR := "reloadCounter %= reload;"
const SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT := "curRecoil = 1f;"
const SOURCE_TURRET_USE_AMMO_METHOD := "public BulletType useAmmo(){"
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := "if(cheating()) return peekAmmo();"
const SOURCE_TURRET_USE_AMMO_ENTRY := "AmmoEntry entry = ammo.peek();"
const SOURCE_TURRET_USE_AMMO_SUBTRACT := "entry.amount -= ammoPerShot;"
const SOURCE_TURRET_USE_AMMO_POP_EMPTY := "if(entry.amount <= 0) ammo.pop();"
const SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT := "totalAmmo -= ammoPerShot;"
const SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP := "totalAmmo = Math.max(totalAmmo, 0);"
const SOURCE_TURRET_USE_AMMO_RETURN := "return entry.type();"
const SOURCE_TURRET_PEEK_AMMO_METHOD := "public @Nullable BulletType peekAmmo(){"
const SOURCE_TURRET_PEEK_AMMO_RETURN := "return ammo.size == 0 ? null : ammo.peek().type();"
const SOURCE_TURRET_HAS_AMMO_METHOD := "public boolean hasAmmo(){"
const SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT := "//skip first entry if it has less than the required amount of ammo"
const SOURCE_TURRET_HAS_AMMO_SWAP_EXPR := "ammo.swap(ammo.size - 1, i);"
const SOURCE_TURRET_OUTPUTS_ITEMS_METHOD := "public boolean outputsItems(){"
const SOURCE_TURRET_OUTPUTS_ITEMS_OVERRIDE := "@Override"
const SOURCE_TURRET_OUTPUTS_ITEMS_RETURN := "return false;"
const SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK := "if(recoilTime < 0f) recoilTime = reload;"
const SOURCE_TURRET_RECOIL_TIME_DECAY_USE := "curRecoil = Mathf.approachDelta(curRecoil, 0, 1 / recoilTime);"
const SOURCE_TURRET_RECOIL_OFFSET_FORMULA := "recoilOffset.trns(rotation, -Mathf.pow(curRecoil, recoilPow) * recoil);"
const SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA := "float index = ((totalShots + i + barrelOffset) % barrels) - (barrels-1)/2f;"
const SOURCE_SHOOT_ALTERNATE_HANDLER_CALL := "handler.shoot(index * spread * -Mathf.sign(mirror), 0, 0f, firstShotDelay + shotDelay * i);"
const SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER := "if(barrelIncrementer != null) barrelIncrementer.run();"
const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_POINT_FIELD := "public float shootX = 0f, shootY = Float.NEGATIVE_INFINITY;"
const SOURCE_TURRET_BULLET_ORIGIN_SHOOT_Y_DEFAULT := "if(shootY == Float.NEGATIVE_INFINITY) shootY = size * tilesize / 2f;"
const SOURCE_TURRET_BULLET_ORIGIN_X_SPREAD := "xSpread = Mathf.range(xRand)"
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_X := "bulletX = x + Angles.trnsx(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)"
const SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y := "bulletY = y + Angles.trnsy(rotation - 90, shootX + xOffset + xSpread, shootY + yOffset)"
const SOURCE_TURRET_BULLET_ORIGIN_ROTATION_OFFSET_DEGREES := SourceTurretDefaults.BULLET_ORIGIN_ROTATION_OFFSET_DEGREES
const SOURCE_TURRET_RANGE_FOR_AMMO_METHOD := "public float range(){\n            if(peekAmmo() != null){\n                return range + peekAmmo().rangeChange;\n            }\n            return range;\n        }"
const SOURCE_TURRET_RANGE_FOR_AMMO_GATE := "if(peekAmmo() != null){"
const SOURCE_TURRET_RANGE_FOR_AMMO_AMMO_RESULT := "return range + peekAmmo().rangeChange;"
const SOURCE_TURRET_RANGE_FOR_AMMO_FALLBACK_RESULT := "return range;"
const SOURCE_TURRET_FIND_TARGET_METHOD := "protected void findTarget(){"
const SOURCE_TURRET_FIND_TARGET_RANGE_EXPR := "float trackRange = trackingRange(), range = range();"
const SOURCE_TURRET_FIND_TARGET_ASSIGN_EXPR := "target = findEnemy(range);"
const SOURCE_UNITS_BEST_ENEMY_RANGE_GUARD := "if(e.dead() || !predicate.get(e) || e.team == Team.derelict || !e.within(x, y, range + e.hitSize/2f) || !e.targetable(team) || e.inFogTo(team)) return;"

static func default_callbacks_state(game: Object) -> Dictionary:
	return {
		"lifetime_seconds": Callable(game, "source_bullet_lifetime_seconds"),
		"world_speed": Callable(game, "source_bullet_world_speed"),
		"dimensions": Callable(game, "source_bullet_dimensions"),
		"hit_size": Callable(game, "source_bullet_hit_size"),
		"damage": Callable(game, "source_bullet_damage"),
		"ammo_multiplier": Callable(game, "source_bullet_ammo_multiplier"),
		"reload_multiplier": Callable(game, "source_bullet_reload_multiplier"),
		"range_change": Callable(game, "source_bullet_range_change"),
	}

static func read_turret_properties(turret) -> Dictionary:
	if turret == null:
		return {}
	var properties = turret.get("properties") if turret is Object else turret.get("properties", {})
	return properties if typeof(properties) == TYPE_DICTIONARY else {}

static func outputs_items_state() -> Dictionary:
	return {
		"source_owner": "PortGame.source_turret_outputs_items_state",
		"method": SOURCE_TURRET_OUTPUTS_ITEMS_METHOD,
		"override_expr": SOURCE_TURRET_OUTPUTS_ITEMS_OVERRIDE,
		"return_expr": SOURCE_TURRET_OUTPUTS_ITEMS_RETURN,
		"outputs_items": false,
	}

static func generated_outputs_items_bridge_state() -> Dictionary:
	var result = SourceGeneratedClassRuntime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/Turret.gd", "java_method_outputsItems_0", [], null)
	var canonical = outputs_items_state()
	return {
		"source_owner": "PortGame.source_turret_outputs_items_state",
		"generated_owner": "Turret.java_method_outputsItems_0",
		"result": result,
		"canonical": canonical,
		"matches": result.get("outputs_items", null) == canonical.get("outputs_items", null),
	}

static func turret_reload_seconds(turret, reload_key: String, reload_default: float, tick_rate: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var reload_state := SourceTurretPropertyState.reload_seconds_state(turret_property_map, reload_key, reload_default, tick_rate)
	return float(reload_state.get("reload_seconds", 0.0))

static func turret_reload_seconds_for_ammo(base_reload_seconds: float, data: Dictionary, reload_multiplier: float) -> float:
	if data.is_empty():
		return base_reload_seconds
	return base_reload_seconds / reload_multiplier

static func turret_range(turret, range_key: String, range_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var range_state := SourceTurretPropertyState.range_state(turret_property_map, range_key, range_default)
	return float(range_state.get("range", 0.0))

static func turret_range_for_ammo(base_range: float, data: Dictionary, range_change: float) -> float:
	if data.is_empty():
		return base_range
	return base_range + range_change

static func turret_shoot_y(turret, shoot_y_key: String, shoot_y_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var shoot_y_state := SourceTurretPropertyState.shoot_y_state(turret_property_map, shoot_y_key, shoot_y_default)
	return float(shoot_y_state.get("shoot_y", 0.0))

static func turret_inaccuracy(turret, inaccuracy_key: String, inaccuracy_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var inaccuracy_state := SourceTurretPropertyState.inaccuracy_state(turret_property_map, inaccuracy_key, inaccuracy_default)
	return float(inaccuracy_state.get("inaccuracy", 0.0))

static func turret_rotate_speed(turret, rotate_speed_key: String, rotate_speed_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var rotate_speed_state := SourceTurretPropertyState.rotate_speed_state(turret_property_map, rotate_speed_key, rotate_speed_default)
	return float(rotate_speed_state.get("rotate_speed", 0.0))

static func turret_shoot_cone(turret, shoot_cone_key: String, shoot_cone_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var shoot_cone_state := SourceTurretPropertyState.shoot_cone_state(turret_property_map, shoot_cone_key, shoot_cone_default)
	return float(shoot_cone_state.get("shoot_cone", 0.0))

static func turret_recoil(turret, recoil_key: String, recoil_default: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	var recoil_state := SourceTurretPropertyState.recoil_state(turret_property_map, recoil_key, recoil_default)
	return float(recoil_state.get("recoil", 0.0))

static func turret_recoils(turret, recoils_key: String, recoils_default: int) -> int:
	if turret == null:
		return 0
	var turret_property_map := read_turret_properties(turret)
	var recoils_state := SourceTurretPropertyState.recoils_state(turret_property_map, recoils_key, recoils_default)
	return int(recoils_state.get("recoils", 0))

static func turret_recoil_time(turret, recoil_time_key: String, recoil_time_default: float, reload_key: String, reload_default: float, tick_rate: float) -> float:
	if turret == null:
		return 1.0
	var turret_property_map := read_turret_properties(turret)
	var reload_seconds := turret_reload_seconds(turret, reload_key, reload_default, tick_rate)
	var recoil_time_state := SourceTurretPropertyState.recoil_time_state(turret_property_map, recoil_time_key, recoil_time_default, reload_seconds, tick_rate)
	return float(recoil_time_state.get("recoil_time", 1.0))

static func turret_shoot_pattern(turret, shoot_pattern_key: String) -> Dictionary:
	if turret == null:
		return {}
	var turret_property_map := read_turret_properties(turret)
	var shoot_pattern_state := SourceTurretPropertyState.shoot_pattern_state(turret_property_map, shoot_pattern_key)
	return shoot_pattern_state.get("shoot_pattern", {})

static func selected_ammo_payload(turret) -> Dictionary:
	var properties := read_turret_properties(turret)
	var ammo_value = properties.get("ammo", [])
	var ammo: Array = ammo_value if typeof(ammo_value) == TYPE_ARRAY else []
	if ammo.is_empty():
		return {}
	var data = ammo[0]
	return data if typeof(data) == TYPE_DICTIONARY else {}

static func selected_turret_float_stat(game: Object, source_method: String) -> float:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return 0.0
	return float(game.call(source_method, turret))

static func selected_turret_dict_stat(game: Object, source_method: String) -> Dictionary:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return {}
	var stat = game.call(source_method, turret)
	return stat if stat is Dictionary else {}

static func selected_turret_int_stat(game: Object, source_method: String) -> int:
	var turret = game.call("selected_playable_turret")
	if turret == null:
		return 0
	return int(game.call(source_method, turret))

static func selected_ammo_sprite(turret, default_sprite: String) -> String:
	var data := selected_ammo_payload(turret)
	if data.is_empty():
		return ""
	return str(data.get("sprite", default_sprite))

static func selected_ammo_lifetime_seconds(turret, lifetime_seconds_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(lifetime_seconds_fn.call(data)) if not data.is_empty() and lifetime_seconds_fn.is_valid() else 0.0

static func selected_ammo_world_speed(turret, world_speed_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(world_speed_fn.call(data)) if not data.is_empty() and world_speed_fn.is_valid() else 0.0

static func selected_ammo_dimensions(turret, dimensions_fn: Callable) -> Dictionary:
	var data := selected_ammo_payload(turret)
	return dimensions_fn.call(data) if not data.is_empty() and dimensions_fn.is_valid() else {}

static func selected_ammo_hit_size(turret, hit_size_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(hit_size_fn.call(data)) if not data.is_empty() and hit_size_fn.is_valid() else 0.0

static func selected_ammo_damage(turret, damage_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(damage_fn.call(data)) if not data.is_empty() and damage_fn.is_valid() else 0.0

static func selected_ammo_multiplier(turret, ammo_multiplier_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(ammo_multiplier_fn.call(data)) if not data.is_empty() and ammo_multiplier_fn.is_valid() else 0.0

static func selected_ammo_reload_multiplier(turret, reload_multiplier_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(reload_multiplier_fn.call(data)) if not data.is_empty() and reload_multiplier_fn.is_valid() else 0.0

static func selected_ammo_range_change(turret, range_change_fn: Callable) -> float:
	var data := selected_ammo_payload(turret)
	return float(range_change_fn.call(data)) if not data.is_empty() and range_change_fn.is_valid() else 0.0

static func selected_limit_range_margin(turret, default_limit_range_margin: float) -> float:
	if turret == null:
		return 0.0
	var turret_property_map := read_turret_properties(turret)
	return float(turret_property_map.get("limitRangeMargin", default_limit_range_margin))

static func selected_ammo_count(turret) -> int:
	var ammo_value = read_turret_properties(turret).get("ammo", [])
	var ammo: Array = ammo_value if typeof(ammo_value) == TYPE_ARRAY else []
	return ammo.size()

static func selected_max_ammo(turret, default_max_ammo: int) -> int:
	return int(read_turret_properties(turret).get("maxAmmo", default_max_ammo))

static func selected_ammo_per_shot(turret, default_ammo_per_shot: int) -> int:
	return int(read_turret_properties(turret).get("ammoPerShot", default_ammo_per_shot))

static func selected_consume_ammo_once(turret, default_consume_ammo_once: bool) -> bool:
	return bool(read_turret_properties(turret).get("consumeAmmoOnce", default_consume_ammo_once))

static func selected_total_ammo(total_ammo_by_key: Dictionary, key: String) -> int:
	return int(total_ammo_by_key.get(key, 0))

static func selected_cooldown_seconds(cooldowns_by_key: Dictionary, key: String) -> float:
	return float(cooldowns_by_key.get(key, 0.0))

static func selected_ammo_stacks(stacks_by_key: Dictionary, key: String) -> Array:
	var stacks_value = stacks_by_key.get(key, [])
	return stacks_value if typeof(stacks_value) == TYPE_ARRAY else []

static func selected_ammo_stack_count(stacks_by_key: Dictionary, key: String) -> int:
	return selected_ammo_stacks(stacks_by_key, key).size()

static func selected_loaded_ammo_item(stacks_by_key: Dictionary, key: String) -> String:
	var stacks := selected_ammo_stacks(stacks_by_key, key)
	if stacks.is_empty():
		return ""
	var stack = stacks[stacks.size() - 1]
	return str(stack.get("item", "")) if typeof(stack) == TYPE_DICTIONARY else ""

static func ammo_data(turret_property_map: Dictionary, item_id: String) -> Dictionary:
	for data in turret_property_map.get("ammo", []):
		if data is Dictionary and str(data.get("item", "")) == item_id:
			return data
	return {}

static func peek_ammo_stack_state(stacks: Array, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	var selected_item_id := ""
	var selected_stack_index := -1
	var has_ammo := false
	if not stacks.is_empty():
		var active_stack: Dictionary = stacks[stacks.size() - 1] if stacks[stacks.size() - 1] is Dictionary else {}
		if int(active_stack.get("amount", 0)) >= ammo_per_shot:
			selected_item_id = str(active_stack.get("item", ""))
			selected_stack_index = stacks.size() - 1
			has_ammo = true
		elif stacks.size() >= 2:
			for index in stacks.size():
				var stack: Dictionary = stacks[index] if stacks[index] is Dictionary else {}
				if int(stack.get("amount", 0)) >= ammo_per_shot:
					selected_item_id = str(stack.get("item", ""))
					selected_stack_index = index
					has_ammo = true
					break
	return {
		"peek_ammo_method": SOURCE_TURRET_PEEK_AMMO_METHOD,
		"peek_ammo_return": SOURCE_TURRET_PEEK_AMMO_RETURN,
		"has_ammo_method": SOURCE_TURRET_HAS_AMMO_METHOD,
		"has_ammo_skip_comment": SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT,
		"has_ammo_swap_expr": SOURCE_TURRET_HAS_AMMO_SWAP_EXPR,
		"item_id": selected_item_id,
		"stack_index": selected_stack_index,
		"has_ammo": has_ammo,
		"ammo_data": ammo_data({"ammo": ammo_entries}, selected_item_id) if has_ammo else {},
	}

static func use_ammo_stack_state(stacks: Array, total_ammo: int, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	var ammo_entries_after: Array = stacks.duplicate(true)
	if ammo_entries_after.size() >= 2:
		var top_stack: Dictionary = ammo_entries_after[ammo_entries_after.size() - 1] if ammo_entries_after[ammo_entries_after.size() - 1] is Dictionary else {}
		if int(top_stack.get("amount", 0)) < ammo_per_shot:
			for index in ammo_entries_after.size():
				var candidate_stack: Dictionary = ammo_entries_after[index] if ammo_entries_after[index] is Dictionary else {}
				if int(candidate_stack.get("amount", 0)) >= ammo_per_shot:
					var last_stack: Variant = ammo_entries_after[ammo_entries_after.size() - 1]
					ammo_entries_after[ammo_entries_after.size() - 1] = ammo_entries_after[index]
					ammo_entries_after[index] = last_stack
					break
	if ammo_entries_after.is_empty():
		return {
			"use_ammo_method": SOURCE_TURRET_USE_AMMO_METHOD,
			"use_ammo_entry": SOURCE_TURRET_USE_AMMO_ENTRY,
			"ammo_entries_after": ammo_entries_after,
			"total_ammo_after": total_ammo,
			"ammo_data": {},
			"used": false,
			"persist_stacks": false,
		}
	var active_stack: Dictionary = ammo_entries_after[ammo_entries_after.size() - 1] if ammo_entries_after[ammo_entries_after.size() - 1] is Dictionary else {}
	if int(active_stack.get("amount", 0)) < ammo_per_shot:
		return {
			"use_ammo_method": SOURCE_TURRET_USE_AMMO_METHOD,
			"use_ammo_entry": SOURCE_TURRET_USE_AMMO_ENTRY,
			"ammo_entries_after": ammo_entries_after,
			"total_ammo_after": total_ammo,
			"ammo_data": {},
			"used": false,
			"persist_stacks": true,
		}
	var selected_item_id := str(active_stack.get("item", ""))
	var resolved_ammo_payload: Dictionary = ammo_data({"ammo": ammo_entries}, selected_item_id)
	if resolved_ammo_payload.is_empty():
		return {
			"use_ammo_method": SOURCE_TURRET_USE_AMMO_METHOD,
			"use_ammo_entry": SOURCE_TURRET_USE_AMMO_ENTRY,
			"ammo_entries_after": stacks.duplicate(true),
			"total_ammo_after": total_ammo,
			"ammo_data": {},
			"used": false,
			"persist_stacks": false,
		}
	active_stack["amount"] = int(active_stack.get("amount", 0)) - ammo_per_shot
	if int(active_stack.get("amount", 0)) <= 0:
		ammo_entries_after.pop_back()
	else:
		ammo_entries_after[ammo_entries_after.size() - 1] = active_stack
	return {
		"use_ammo_method": SOURCE_TURRET_USE_AMMO_METHOD,
		"use_ammo_cheating_guard": SOURCE_TURRET_USE_AMMO_CHEATING_GUARD,
		"use_ammo_entry": SOURCE_TURRET_USE_AMMO_ENTRY,
		"use_ammo_subtract": SOURCE_TURRET_USE_AMMO_SUBTRACT,
		"use_ammo_pop_empty": SOURCE_TURRET_USE_AMMO_POP_EMPTY,
		"use_ammo_total_subtract": SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT,
		"use_ammo_total_clamp": SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP,
		"use_ammo_return": SOURCE_TURRET_USE_AMMO_RETURN,
		"ammo_entries_after": ammo_entries_after,
		"total_ammo_after": maxi(0, total_ammo - ammo_per_shot),
		"item_id": selected_item_id,
		"ammo_data": resolved_ammo_payload,
		"used": true,
		"persist_stacks": true,
	}

static func item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	var ammo_entries_after: Array = ammo_entries.duplicate(true)
	var flame_ammo_event_fired: bool = item_is_pyratite
	var resupply_turret_event_fired: bool = total_ammo == 0
	var total_ammo_after: int = total_ammo
	var type_null_returned: bool = ammo_type_null
	var entry_found: bool = false
	var entry_added: bool = false
	var swapped: bool = false
	if not ammo_type_null:
		total_ammo_after = int(total_ammo + ammo_multiplier)
		for i in ammo_entries_after.size():
			var entry_copy: Dictionary = ammo_entries_after[i] if ammo_entries_after[i] is Dictionary else {}
			if entry_copy.get("item", null) == item:
				entry_copy["amount"] = int(entry_copy.get("amount", 0)) + int(ammo_multiplier)
				ammo_entries_after[i] = entry_copy
				var last_index: int = ammo_entries_after.size() - 1
				var last_entry: Variant = ammo_entries_after[last_index]
				ammo_entries_after[last_index] = ammo_entries_after[i]
				ammo_entries_after[i] = last_entry
				entry_found = true
				swapped = true
				break
		if not entry_found:
			ammo_entries_after.append({"item": item, "amount": int(ammo_multiplier)})
			entry_added = true
	return {
		"source_owner": "PortGame.source_item_turret_build_handle_item_state",
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public void handleItem(Building source, Item item){",
		"override_expr": "@Override",
		"todo_comment": "//TODO instead of all this \"entry\" crap, turrets could just accept only one type of ammo at a time - simpler for both users and the code",
		"pyratite_guard": "if(item == Items.pyratite){",
		"flame_event_expr": "Events.fire(Trigger.flameAmmo);",
		"resupply_guard": "if(totalAmmo == 0){",
		"resupply_event_expr": "Events.fire(Trigger.resupplyTurret);",
		"type_lookup": "BulletType type = ammoTypes.get(item);",
		"type_null_guard": "if(type == null) return;",
		"total_ammo_update_expr": "totalAmmo += type.ammoMultiplier;",
		"loop_expr": "for(int i = 0; i < ammo.size; i++){",
		"entry_cast": "ItemEntry entry = (ItemEntry)ammo.get(i);",
		"found_guard": "if(entry.item == item){",
		"entry_update_expr": "entry.amount += type.ammoMultiplier;",
		"swap_expr": "ammo.swap(i, ammo.size - 1);",
		"add_expr": "ammo.add(new ItemEntry(item, (int)type.ammoMultiplier));",
		"item": item,
		"item_is_pyratite": item_is_pyratite,
		"total_ammo": total_ammo,
		"ammo_multiplier": ammo_multiplier,
		"ammo_type_null": ammo_type_null,
		"flame_ammo_event_fired": flame_ammo_event_fired,
		"resupply_turret_event_fired": resupply_turret_event_fired,
		"type_null_returned": type_null_returned,
		"total_ammo_after": total_ammo_after,
		"ammo_entries_after": ammo_entries_after,
		"entry_found": entry_found,
		"entry_added": entry_added,
		"swapped": swapped,
	}

static func item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var accept_item: bool = not ammo_type_null and total_ammo + ammo_multiplier <= max_ammo_value
	return {
		"source_owner": "PortGame.source_item_turret_build_accept_item_state",
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public boolean acceptItem(Building source, Item item){",
		"override_expr": "@Override",
		"return_expr": "return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;",
		"item": item,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo_value,
		"ammo_multiplier": ammo_multiplier,
		"ammo_type_null": ammo_type_null,
		"accept_item": accept_item,
	}

static func cooldown_state(cooldown_seconds: float, seconds: float) -> Dictionary:
	var cooldown_after_tick: float = max(0.0, cooldown_seconds - seconds)
	return {
		"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
		"reload_cap_expr": SOURCE_TURRET_RELOAD_CAP_EXPR,
		"cooldown_after_tick": cooldown_after_tick,
		"ready": cooldown_after_tick <= 0.0,
	}

static func fire_cycle_state(current_rotation: float, target_rotation: float, seconds: float, rotate_speed: float, shoot_cone: float, cooldown_seconds: float, reload_seconds: float, tick_rate: float, move_angle_toward: Callable, angle_distance: Callable) -> Dictionary:
	var cooldown_tick: Dictionary = cooldown_state(cooldown_seconds, seconds)
	var cooldown_after_tick: float = float(cooldown_tick.get("cooldown_after_tick", 0.0))
	if cooldown_after_tick > 0.0:
		var cooling_angle_delta: float = float(angle_distance.call(current_rotation, target_rotation))
		return {
			"update_tile_method": SOURCE_TURRET_UPDATE_TILE_METHOD,
			"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
			"turn_to_target_expr": SOURCE_TURRET_TURN_TO_TARGET_EXPR,
			"shoot_gate_expr": SOURCE_TURRET_SHOOT_GATE_EXPR,
			"reload_mod_expr": SOURCE_TURRET_RELOAD_MOD_EXPR,
			"cur_recoil_assignment": SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT,
			"cooldown_after_tick": cooldown_after_tick,
			"cooldown_after_fire": cooldown_after_tick,
			"next_rotation": current_rotation,
			"angle_delta": cooling_angle_delta,
			"within_shoot_cone": false,
			"should_fire": false,
		}
	var max_rotation_delta: float = rotate_speed * seconds * tick_rate
	var next_rotation: float = float(move_angle_toward.call(current_rotation, target_rotation, max_rotation_delta))
	var angle_delta: float = float(angle_distance.call(next_rotation, target_rotation))
	var within_shoot_cone: bool = angle_delta < shoot_cone
	return {
		"update_tile_method": SOURCE_TURRET_UPDATE_TILE_METHOD,
		"update_reload_expr": SOURCE_TURRET_UPDATE_RELOAD_EXPR,
		"turn_to_target_expr": SOURCE_TURRET_TURN_TO_TARGET_EXPR,
		"shoot_gate_expr": SOURCE_TURRET_SHOOT_GATE_EXPR,
		"reload_mod_expr": SOURCE_TURRET_RELOAD_MOD_EXPR,
		"cur_recoil_assignment": SOURCE_TURRET_CUR_RECOIL_ASSIGNMENT,
		"cooldown_after_tick": cooldown_after_tick,
		"cooldown_after_fire": reload_seconds if within_shoot_cone else cooldown_after_tick,
		"next_rotation": next_rotation,
		"angle_delta": angle_delta,
		"within_shoot_cone": within_shoot_cone,
		"should_fire": within_shoot_cone,
	}

static func total_inaccuracy(base_turret_inaccuracy: float, bullet_inaccuracy: float) -> float:
	return base_turret_inaccuracy + bullet_inaccuracy

static func recoil_offset(recoil_rotation_degrees: float, cur_recoil: float, recoil_pow: float, recoil: float) -> Vector2:
	var offset_state := SourceMathState.source_angles_trns_vec(recoil_rotation_degrees, -pow(cur_recoil, recoil_pow) * recoil, 0.0)
	return Vector2(float(offset_state.get("x", 0.0)), float(offset_state.get("y", 0.0)))

static func recoil_step_state(cur_recoil: float, seconds: float, tick_rate: float, recoil_time: float) -> Dictionary:
	var cur_recoil_after := cur_recoil
	if recoil_time > 0.0:
		cur_recoil_after = max(0.0, cur_recoil - seconds * tick_rate / recoil_time)
	return {
		"source_owner": "PortGame.update_turret_recoil",
		"recoil_time_init_fallback": SOURCE_TURRET_RECOIL_TIME_INIT_FALLBACK,
		"recoil_time_decay_use": SOURCE_TURRET_RECOIL_TIME_DECAY_USE,
		"cur_recoil_before": cur_recoil,
		"seconds": seconds,
		"tick_rate": tick_rate,
		"recoil_time": recoil_time,
		"cur_recoil_after": cur_recoil_after,
	}

static func shoot_x_offset_state(pattern: Dictionary, counter: int) -> Dictionary:
	if str(pattern.get("type", "")) != "ShootAlternate":
		return {
			"shoot_alternate_index_formula": SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA,
			"shoot_alternate_handler_call": SOURCE_SHOOT_ALTERNATE_HANDLER_CALL,
			"shoot_alternate_barrel_incrementer": SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER,
			"counter": counter,
			"next_counter": counter,
			"spread": 0.0,
			"index": 0,
			"offset": 0.0,
			"used": false,
		}
	var spread := float(pattern.get("spread", 0.0))
	var index := counter % 2
	return {
		"shoot_alternate_index_formula": SOURCE_SHOOT_ALTERNATE_INDEX_FORMULA,
		"shoot_alternate_handler_call": SOURCE_SHOOT_ALTERNATE_HANDLER_CALL,
		"shoot_alternate_barrel_incrementer": SOURCE_SHOOT_ALTERNATE_BARREL_INCREMENTER,
		"counter": counter,
		"next_counter": counter + 1,
		"spread": spread,
		"index": index,
		"offset": (float(index) - 0.5) * spread,
		"used": true,
	}

static func bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret_property_map: Dictionary, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	var shoot_x := float(turret_property_map.get("shootX", shoot_x_default))
	var shoot_y := float(turret_property_map.get("shootY", float(turret_property_map.get("size", block_size_default)) * tilesize / 2.0))
	var rotation_minus_90 := turret_rotation_degrees - SOURCE_TURRET_BULLET_ORIGIN_ROTATION_OFFSET_DEGREES
	var trns: Dictionary = trns_vec.call(rotation_minus_90, shoot_x + shoot_x_offset + x_spread, shoot_y + y_offset)
	var trnsx := float(trns.get("x", 0.0))
	var trnsy := float(trns.get("y", 0.0))
	return {
		"originX": origin_x,
		"originY": origin_y,
		"rotationDegrees": turret_rotation_degrees,
		"rotationMinus90": rotation_minus_90,
		"shootX": shoot_x,
		"shootY": shoot_y,
		"shootXOffset": shoot_x_offset,
		"yOffset": y_offset,
		"xSpread": x_spread,
		"trnsx": trnsx,
		"trnsy": trnsy,
		"bulletX": origin_x + trnsx,
		"bulletY": origin_y + trnsy,
		"bulletXSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_X,
		"bulletYSource": SOURCE_TURRET_BULLET_ORIGIN_BULLET_Y,
	}

static func turret_bullet_origin_state(origin_x: float, origin_y: float, turret_rotation_degrees: float, turret, shoot_x_offset: float, y_offset: float, x_spread: float, shoot_x_default: float, block_size_default: int, tilesize: int, trns_vec: Callable) -> Dictionary:
	var turret_property_map := read_turret_properties(turret)
	return bullet_origin_state(origin_x, origin_y, turret_rotation_degrees, turret_property_map, shoot_x_offset, y_offset, x_spread, shoot_x_default, block_size_default, tilesize, trns_vec)

static func target_selection_state(origin: Vector2, range_pixels: float, candidates: Array) -> Dictionary:
	var selected_target: Variant = null
	var selected_index := -1
	var selected_distance := range_pixels
	for index in candidates.size():
		var candidate: Dictionary = candidates[index] if candidates[index] is Dictionary else {}
		var position: Vector2 = candidate.get("position", origin) as Vector2
		var distance := origin.distance_to(position)
		if distance <= selected_distance:
			selected_target = candidate.get("target", null)
			selected_index = index
			selected_distance = distance
	return {
		"source_owner": "SourceTurretRuntimeState.target_selection_state",
		"find_target_method": SOURCE_TURRET_FIND_TARGET_METHOD,
		"find_target_range_expr": SOURCE_TURRET_FIND_TARGET_RANGE_EXPR,
		"find_target_assign_expr": SOURCE_TURRET_FIND_TARGET_ASSIGN_EXPR,
		"best_enemy_range_guard": SOURCE_UNITS_BEST_ENEMY_RANGE_GUARD,
		"origin": origin,
		"range_pixels": range_pixels,
		"candidate_count": candidates.size(),
		"selected_index": selected_index,
		"selected_distance": selected_distance,
		"target": selected_target,
		"has_target": selected_target != null,
	}
