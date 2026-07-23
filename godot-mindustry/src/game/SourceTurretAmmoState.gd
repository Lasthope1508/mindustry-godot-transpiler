extends RefCounted
class_name SourceTurretAmmoState

const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceTurretDefaults := preload("res://src/game/SourceTurretDefaults.gd")
const SourceBulletDefaults := preload("res://src/game/SourceBulletDefaults.gd")

const SOURCE_TURRET_MAX_AMMO_FIELD := "public int maxAmmo = 30;"
const SOURCE_TURRET_AMMO_PER_SHOT_FIELD := "public int ammoPerShot = 1;"
const SOURCE_TURRET_CONSUME_AMMO_ONCE_FIELD := "public boolean consumeAmmoOnce = true;"
const SOURCE_TURRET_USE_AMMO_METHOD := "public BulletType useAmmo(){"
const SOURCE_TURRET_PEEK_AMMO_METHOD := "public @Nullable BulletType peekAmmo(){"
const SOURCE_TURRET_HAS_AMMO_SWAP_EXPR := "ammo.swap(ammo.size - 1, i);"
const SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD := "public void handleItem(Building source, Item item){"
const SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR := "return ammoTypes.get(item) != null && totalAmmo + ammoTypes.get(item).ammoMultiplier <= maxAmmo;"

static func _properties(turret) -> Dictionary:
	if turret == null:
		return {}
	if turret is Dictionary:
		return turret.get("properties", {})
	return turret.properties

static func _bullet_ammo_multiplier(data: Dictionary) -> int:
	return int(float(data.get("ammoMultiplier", SourceBulletDefaults.new(SourceSsotCatalog).ammo_multiplier_default())))

static func max_ammo(turret) -> int:
	return int(_properties(turret).get("maxAmmo", SourceTurretDefaults.new(SourceSsotCatalog).max_ammo_default()))

static func ammo_per_shot(turret) -> int:
	return int(_properties(turret).get("ammoPerShot", SourceTurretDefaults.new(SourceSsotCatalog).ammo_per_shot_default()))

static func consume_ammo_once(turret) -> bool:
	return bool(_properties(turret).get("consumeAmmoOnce", SourceTurretDefaults.new(SourceSsotCatalog).consume_ammo_once_default()))

static func turret_ammo_data(turret, item_id: String) -> Dictionary:
	if turret == null:
		return {}
	for data in _properties(turret).get("ammo", []):
		if data is Dictionary and str(data.get("item", "")) == item_id:
			return data
	return {}

static func peek_turret_ammo_state(turret, stacks: Array) -> Dictionary:
	var ammo_per_shot_value := ammo_per_shot(turret)
	var result := {
		"source_owner": "SourceTurretAmmoState.peek_turret_ammo_state",
		"method": SOURCE_TURRET_PEEK_AMMO_METHOD,
		"ammo_per_shot": ammo_per_shot_value,
		"stacks_after": stacks,
		"ammo_data": {},
	}
	if turret == null or stacks.is_empty():
		return result
	var active_stack: Dictionary = stacks[stacks.size() - 1]
	if int(active_stack.get("amount", 0)) >= ammo_per_shot_value:
		result["ammo_data"] = turret_ammo_data(turret, str(active_stack.get("item", "")))
		return result
	if stacks.size() >= 2:
		for index in stacks.size():
			var stack: Dictionary = stacks[index]
			if int(stack.get("amount", 0)) >= ammo_per_shot_value:
				result["ammo_data"] = turret_ammo_data(turret, str(stack.get("item", "")))
				return result
	return result

static func handle_turret_item_state(turret, item_id: String, total_ammo: int, stacks: Array) -> Dictionary:
	var stacks_after := stacks.duplicate(true)
	var data := turret_ammo_data(turret, item_id)
	var amount := _bullet_ammo_multiplier(data)
	var max_ammo_value := max_ammo(turret)
	var result := {
		"source_owner": "SourceTurretAmmoState.handle_turret_item_state",
		"method": SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD,
		"accept_expr": SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR,
		"item": item_id,
		"ammo_data": data,
		"ammo_multiplier": amount,
		"max_ammo": max_ammo_value,
		"total_ammo_before": total_ammo,
		"total_ammo_after": total_ammo,
		"stacks_after": stacks_after,
		"accepted": false,
	}
	if data.is_empty() or total_ammo + amount > max_ammo_value:
		return result
	var found := -1
	for index in stacks_after.size():
		var stack: Dictionary = stacks_after[index]
		if str(stack.get("item", "")) == item_id:
			found = index
			break
	if found >= 0:
		var stack: Dictionary = stacks_after[found]
		stack["amount"] = int(stack.get("amount", 0)) + amount
		stacks_after[found] = stack
		if found != stacks_after.size() - 1:
			var last_stack = stacks_after[stacks_after.size() - 1]
			stacks_after[stacks_after.size() - 1] = stacks_after[found]
			stacks_after[found] = last_stack
	else:
		stacks_after.append({"item": item_id, "amount": amount})
	result["stacks_after"] = stacks_after
	result["total_ammo_after"] = total_ammo + amount
	result["accepted"] = true
	return result

static func use_turret_ammo_state(turret, stacks: Array, total_ammo: int) -> Dictionary:
	var stacks_after := stacks.duplicate(true)
	var ammo_per_shot_value := ammo_per_shot(turret)
	var result := {
		"source_owner": "SourceTurretAmmoState.use_turret_ammo_state",
		"method": SOURCE_TURRET_USE_AMMO_METHOD,
		"swap_expr": SOURCE_TURRET_HAS_AMMO_SWAP_EXPR,
		"ammo_per_shot": ammo_per_shot_value,
		"total_ammo_before": total_ammo,
		"total_ammo_after": total_ammo,
		"stacks_after": stacks_after,
		"ammo_data": {},
		"used": false,
	}
	if turret == null:
		return result
	if stacks_after.size() >= 2 and int((stacks_after[stacks_after.size() - 1] as Dictionary).get("amount", 0)) < ammo_per_shot_value:
		for index in stacks_after.size():
			var stack: Dictionary = stacks_after[index]
			if int(stack.get("amount", 0)) >= ammo_per_shot_value:
				var last_stack = stacks_after[stacks_after.size() - 1]
				stacks_after[stacks_after.size() - 1] = stacks_after[index]
				stacks_after[index] = last_stack
				break
	if stacks_after.is_empty():
		result["stacks_after"] = stacks_after
		return result
	var active_stack: Dictionary = stacks_after[stacks_after.size() - 1]
	if int(active_stack.get("amount", 0)) < ammo_per_shot_value:
		result["stacks_after"] = stacks_after
		return result
	var data := turret_ammo_data(turret, str(active_stack.get("item", "")))
	if data.is_empty():
		result["stacks_after"] = stacks_after
		return result
	active_stack["amount"] = int(active_stack.get("amount", 0)) - ammo_per_shot_value
	if int(active_stack.get("amount", 0)) <= 0:
		stacks_after.pop_back()
	else:
		stacks_after[stacks_after.size() - 1] = active_stack
	result["ammo_data"] = data
	result["stacks_after"] = stacks_after
	result["total_ammo_after"] = maxi(0, total_ammo - ammo_per_shot_value)
	result["used"] = true
	return result
