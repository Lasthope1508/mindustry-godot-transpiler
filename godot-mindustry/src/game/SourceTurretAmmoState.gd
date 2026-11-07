extends RefCounted
class_name SourceTurretAmmoState

const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_bullet_defaults := preload("res://src/game/SourceBulletDefaults.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_turret_ammo_manifest_state := preload("res://src/game/SourceTurretAmmoManifestState.gd")
const source_turret_ammo_stack_state := preload("res://src/game/SourceTurretAmmoStackState.gd")

const SOURCE_TURRET_MAX_AMMO_FIELD := source_turret_source_text_state.SOURCE_TURRET_MAX_AMMO_FIELD
const SOURCE_TURRET_AMMO_PER_SHOT_FIELD := source_turret_source_text_state.SOURCE_TURRET_AMMO_PER_SHOT_FIELD
const SOURCE_TURRET_CONSUME_AMMO_ONCE_FIELD := source_turret_source_text_state.SOURCE_TURRET_CONSUME_AMMO_ONCE_FIELD
const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD
const SOURCE_TURRET_USE_AMMO_ENTRY := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_ENTRY
const SOURCE_TURRET_USE_AMMO_SUBTRACT := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_SUBTRACT
const SOURCE_TURRET_USE_AMMO_POP_EMPTY := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_POP_EMPTY
const SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT
const SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP
const SOURCE_TURRET_USE_AMMO_RETURN := source_turret_ammo_stack_state.SOURCE_TURRET_USE_AMMO_RETURN
const SOURCE_TURRET_PEEK_AMMO_METHOD := source_turret_ammo_stack_state.SOURCE_TURRET_PEEK_AMMO_METHOD
const SOURCE_TURRET_PEEK_AMMO_RETURN := source_turret_ammo_stack_state.SOURCE_TURRET_PEEK_AMMO_RETURN
const SOURCE_TURRET_HAS_AMMO_METHOD := source_turret_ammo_stack_state.SOURCE_TURRET_HAS_AMMO_METHOD
const SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT := source_turret_ammo_stack_state.SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT
const SOURCE_TURRET_HAS_AMMO_SWAP_EXPR := source_turret_ammo_stack_state.SOURCE_TURRET_HAS_AMMO_SWAP_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD := source_turret_ammo_stack_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD
const SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR := source_turret_ammo_stack_state.SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR
const SOURCE_TURRET_AMMO_GAME_CONTENT_CATALOG_KEY := "content_catalog"
const SOURCE_TURRET_AMMO_GAME_DUO_POS_KEY := "duo_pos"

static func _properties(turret) -> Dictionary:
	if turret == null:
		return {}
	var properties = turret.get("properties") if turret is Object else turret.get("properties", {})
	return properties if typeof(properties) == TYPE_DICTIONARY else {}

static func _bullet_ammo_multiplier(data: Dictionary) -> int:
	return int(float(data.get("ammoMultiplier", source_bullet_defaults.new(source_ssot_accessor_runtime_state).ammo_multiplier_default())))

static func max_ammo_default(turret) -> int:
	return int(_properties(turret).get("maxAmmo", source_turret_defaults.new(source_ssot_accessor_runtime_state).max_ammo_default()))

static func ammo_per_shot(turret) -> int:
	return int(_properties(turret).get("ammoPerShot", source_turret_defaults.new(source_ssot_accessor_runtime_state).ammo_per_shot_default()))

static func consume_ammo_once(turret) -> bool:
	return bool(_properties(turret).get("consumeAmmoOnce", source_turret_defaults.new(source_ssot_accessor_runtime_state).consume_ammo_once_default()))

static func item_turret_ammo_data(turret_properties: Dictionary, item_id: String) -> Dictionary:
	return source_turret_ammo_stack_state.item_turret_ammo_data(turret_properties, item_id)

static func ammo_data(turret_property_map: Dictionary, item_id: String) -> Dictionary:
	return item_turret_ammo_data(turret_property_map, item_id)

static func turret_item_turret_ammo_data(turret, item_id: String) -> Dictionary:
	if turret == null:
		return {}
	return item_turret_ammo_data(_properties(turret), item_id)

static func turret_ammo_data(turret, item_id: String) -> Dictionary:
	return turret_item_turret_ammo_data(turret, item_id)

static func selected_turret_ammo_entries(turret) -> Array:
	if turret == null:
		return []
	return _properties(turret).get("ammo", [])

@warning_ignore("shadowed_variable")
static func peek_ammo_stack_state(stacks: Array, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_stack_state.peek_ammo_stack_state(stacks, ammo_per_shot, ammo_entries)

@warning_ignore("shadowed_variable")
static func use_ammo_stack_state(stacks: Array, total_ammo: int, ammo_per_shot: int, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_stack_state.use_ammo_stack_state(stacks, total_ammo, ammo_per_shot, ammo_entries)

static func peek_turret_ammo_state(turret_properties: Dictionary, stacks: Array) -> Dictionary:
	return peek_ammo_stack_state(stacks, int(turret_properties.get("ammoPerShot", source_turret_defaults.new(source_ssot_accessor_runtime_state).ammo_per_shot_default())), turret_properties.get("ammo", []))

static func use_turret_ammo_state(turret_properties: Dictionary, stacks: Array, total_ammo: int) -> Dictionary:
	return use_ammo_stack_state(stacks, total_ammo, int(turret_properties.get("ammoPerShot", source_turret_defaults.new(source_ssot_accessor_runtime_state).ammo_per_shot_default())), turret_properties.get("ammo", []))

static func handle_turret_item_state(_turret_properties: Dictionary, item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_stack_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func peek_turret_ammo_state_for_turret(turret, stacks: Array) -> Dictionary:
	return peek_turret_ammo_state(_properties(turret), stacks)

static func use_turret_ammo_state_for_turret(turret, stacks: Array, total_ammo: int) -> Dictionary:
	return use_turret_ammo_state(_properties(turret), stacks, total_ammo)

static func handle_turret_item_state_for_turret(turret, item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return handle_turret_item_state(_properties(turret), item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func max_ammo(turret, default_max_ammo: int) -> int:
	if turret == null:
		return default_max_ammo
	return int(_properties(turret).get("maxAmmo", default_max_ammo))

static func item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_stack_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo_value, ammo_multiplier, ammo_type_null)

static func peek_turret_ammo(game, cell: Vector2i, turret) -> Dictionary:
	if turret == null:
		return {}
	var key := str(game.call("cell_key", cell))
	var turret_ammo_stacks: Dictionary = game.get("turret_ammo_stacks")
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var peek_state := peek_turret_ammo_state_for_turret(turret, stacks)
	var data = peek_state.get("ammo_data", {})
	return data if data is Dictionary else {}

static func handle_turret_item(game, cell: Vector2i, turret, item_id: String) -> bool:
	var data := turret_ammo_data(turret, item_id)
	if data.is_empty():
		return false
	var key := str(game.call("cell_key", cell))
	var turret_ammo_stacks: Dictionary = game.get("turret_ammo_stacks")
	var turret_total_ammo: Dictionary = game.get("turret_total_ammo")
	var amount := _bullet_ammo_multiplier(data)
	var total := int(turret_total_ammo.get(key, 0))
	var max_ammo_value := max_ammo_default(turret)
	var accept_state := item_turret_build_accept_item_state(item_id, total, max_ammo_value, amount, data.is_empty())
	if not bool(accept_state.get("accept_item", false)):
		return false
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var handle_state := handle_turret_item_state_for_turret(turret, item_id, item_id == "pyratite", total, amount, data.is_empty(), stacks)
	turret_ammo_stacks[key] = handle_state.get("ammo_entries_after", stacks)
	turret_total_ammo[key] = int(handle_state.get("total_ammo_after", total))
	return true

static func use_turret_ammo(game, cell: Vector2i, turret) -> Dictionary:
	if turret == null:
		return {}
	var key := str(game.call("cell_key", cell))
	var turret_ammo_stacks: Dictionary = game.get("turret_ammo_stacks")
	var turret_total_ammo: Dictionary = game.get("turret_total_ammo")
	var stacks: Array = turret_ammo_stacks.get(key, [])
	var total := int(turret_total_ammo.get(key, 0))
	var use_state := use_turret_ammo_state_for_turret(turret, stacks, total)
	if bool(use_state.get("persist_stacks", false)):
		turret_ammo_stacks[key] = use_state.get("ammo_entries_after", stacks)
		turret_total_ammo[key] = int(use_state.get("total_ammo_after", total))
	var data = use_state.get("ammo_data", {})
	return data if data is Dictionary else {}

static func bootstrap_selected_turret_ammo(game) -> int:
	if game.get(SOURCE_TURRET_AMMO_GAME_CONTENT_CATALOG_KEY) == null:
		return 0
	var duo = game.call("selected_playable_turret")
	if duo == null:
		return 0
	var ammo_entries: Array = selected_turret_ammo_entries(duo)
	if ammo_entries.is_empty():
		return 0
	var first_ammo: Dictionary = ammo_entries[0]
	if _bullet_ammo_multiplier(first_ammo) <= 0:
		return 0
	var item_id := str(first_ammo.get("item", ""))
	if item_id.is_empty():
		return 0
	var loaded := 0
	while handle_turret_item(game, game.get(SOURCE_TURRET_AMMO_GAME_DUO_POS_KEY), duo, item_id):
		loaded += 1
	return loaded

static func load_selected_turret_ammo(game, item_id: String, amount: int) -> int:
	if game.get(SOURCE_TURRET_AMMO_GAME_CONTENT_CATALOG_KEY) == null:
		return 0
	var duo = game.call("selected_playable_turret")
	if duo == null:
		return 0
	var loaded := 0
	for _i in amount:
		if handle_turret_item(game, game.get(SOURCE_TURRET_AMMO_GAME_DUO_POS_KEY), duo, item_id):
			loaded += 1
		else:
			break
	return loaded

static func use_selected_turret_ammo_once(game) -> Dictionary:
	if game.get(SOURCE_TURRET_AMMO_GAME_CONTENT_CATALOG_KEY) == null:
		return {}
	var duo = game.call("selected_playable_turret")
	if duo == null:
		return {}
	return use_turret_ammo(game, game.get(SOURCE_TURRET_AMMO_GAME_DUO_POS_KEY), duo)

static func _peek_turret_ammo_state_impl(turret, stacks: Array) -> Dictionary:
	var ammo_per_shot_value := ammo_per_shot(turret)
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_AMMO_PEEK_STATE,
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

static func _handle_turret_item_state_impl(turret, item_id: String, total_ammo: int, stacks: Array) -> Dictionary:
	var stacks_after := stacks.duplicate(true)
	var data := turret_ammo_data(turret, item_id)
	var amount := _bullet_ammo_multiplier(data)
	var max_ammo_value := max_ammo_default(turret)
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_AMMO_HANDLE_ITEM_STATE,
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

static func _use_turret_ammo_state_impl(turret, stacks: Array, total_ammo: int) -> Dictionary:
	var stacks_after := stacks.duplicate(true)
	var ammo_per_shot_value := ammo_per_shot(turret)
	var result := {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_TURRET_AMMO_USE_STATE,
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

static func liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.liquid_turret_ammo_state(objects)

static func generated_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.generated_liquid_turret_ammo_bridge_state(objects)

static func item_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.item_turret_ammo_state(objects)

static func generated_item_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.generated_item_turret_ammo_bridge_state(objects)

static func continuous_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.continuous_liquid_turret_ammo_state(objects)

static func generated_continuous_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_manifest_state.generated_continuous_liquid_turret_ammo_bridge_state(objects)
