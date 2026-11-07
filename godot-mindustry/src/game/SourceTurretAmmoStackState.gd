extends RefCounted
class_name SourceTurretAmmoStackState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_TURRET_USE_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_METHOD
const SOURCE_TURRET_USE_AMMO_CHEATING_GUARD := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_CHEATING_GUARD
const SOURCE_TURRET_USE_AMMO_ENTRY := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_ENTRY
const SOURCE_TURRET_USE_AMMO_SUBTRACT := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_SUBTRACT
const SOURCE_TURRET_USE_AMMO_POP_EMPTY := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_POP_EMPTY
const SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_TOTAL_SUBTRACT
const SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_TOTAL_CLAMP
const SOURCE_TURRET_USE_AMMO_RETURN := source_turret_source_text_state.SOURCE_TURRET_USE_AMMO_RETURN
const SOURCE_TURRET_PEEK_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_PEEK_AMMO_METHOD
const SOURCE_TURRET_PEEK_AMMO_RETURN := source_turret_source_text_state.SOURCE_TURRET_PEEK_AMMO_RETURN
const SOURCE_TURRET_HAS_AMMO_METHOD := source_turret_source_text_state.SOURCE_TURRET_HAS_AMMO_METHOD
const SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT := source_turret_source_text_state.SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT
const SOURCE_TURRET_HAS_AMMO_SWAP_EXPR := source_turret_source_text_state.SOURCE_TURRET_HAS_AMMO_SWAP_EXPR
const SOURCE_ITEM_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_INNER_CLASS
const SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD
const SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_TODO_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_TODO_COMMENT
const SOURCE_ITEM_TURRET_HANDLE_ITEM_PYRATITE_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_PYRATITE_GUARD
const SOURCE_ITEM_TURRET_HANDLE_ITEM_FLAME_EVENT_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_FLAME_EVENT_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_GUARD
const SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_EVENT_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_EVENT_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_LOOKUP := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_LOOKUP
const SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_NULL_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_NULL_GUARD
const SOURCE_ITEM_TURRET_HANDLE_ITEM_TOTAL_AMMO_UPDATE_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_TOTAL_AMMO_UPDATE_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_LOOP_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_CAST := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_CAST
const SOURCE_ITEM_TURRET_HANDLE_ITEM_FOUND_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_FOUND_GUARD
const SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_UPDATE_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_UPDATE_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_SWAP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_SWAP_EXPR
const SOURCE_ITEM_TURRET_HANDLE_ITEM_ADD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_ITEM_ADD_EXPR
const SOURCE_ITEM_TURRET_ACCEPT_ITEM_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_ITEM_METHOD

static func item_turret_ammo_data(turret_properties: Dictionary, item_id: String) -> Dictionary:
	for data in turret_properties.get("ammo", []):
		if data is Dictionary and str(data.get("item", "")) == item_id:
			return data
	return {}

static func ammo_data(turret_property_map: Dictionary, item_id: String) -> Dictionary:
	return item_turret_ammo_data(turret_property_map, item_id)

@warning_ignore("shadowed_variable")
static func peek_ammo_stack_state(stacks: Array, ammo_per_shot: int, ammo_entries: Array, ammo_data_callable: Callable = Callable()) -> Dictionary:
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
	var resolved_ammo_data := {}
	if has_ammo:
		resolved_ammo_data = ammo_data_callable.call({"ammo": ammo_entries}, selected_item_id) if ammo_data_callable.is_valid() else ammo_data({"ammo": ammo_entries}, selected_item_id)
	return {
		"peek_ammo_method": SOURCE_TURRET_PEEK_AMMO_METHOD,
		"peek_ammo_return": SOURCE_TURRET_PEEK_AMMO_RETURN,
		"has_ammo_method": SOURCE_TURRET_HAS_AMMO_METHOD,
		"has_ammo_skip_comment": SOURCE_TURRET_HAS_AMMO_SKIP_COMMENT,
		"has_ammo_swap_expr": SOURCE_TURRET_HAS_AMMO_SWAP_EXPR,
		"item_id": selected_item_id,
		"stack_index": selected_stack_index,
		"has_ammo": has_ammo,
		"ammo_data": resolved_ammo_data,
	}

@warning_ignore("shadowed_variable")
static func use_ammo_stack_state(stacks: Array, total_ammo: int, ammo_per_shot: int, ammo_entries: Array, ammo_data_callable: Callable = Callable()) -> Dictionary:
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
	var resolved_ammo_payload: Dictionary = ammo_data_callable.call({"ammo": ammo_entries}, selected_item_id) if ammo_data_callable.is_valid() else ammo_data({"ammo": ammo_entries}, selected_item_id)
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_ITEM_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_HANDLE_ITEM_METHOD,
		"override_expr": source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"todo_comment": SOURCE_ITEM_TURRET_HANDLE_ITEM_TODO_COMMENT,
		"pyratite_guard": SOURCE_ITEM_TURRET_HANDLE_ITEM_PYRATITE_GUARD,
		"flame_event_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_FLAME_EVENT_EXPR,
		"resupply_guard": SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_GUARD,
		"resupply_event_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_RESUPPLY_EVENT_EXPR,
		"type_lookup": SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_LOOKUP,
		"type_null_guard": SOURCE_ITEM_TURRET_HANDLE_ITEM_TYPE_NULL_GUARD,
		"total_ammo_update_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_TOTAL_AMMO_UPDATE_EXPR,
		"loop_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_LOOP_EXPR,
		"entry_cast": SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_CAST,
		"found_guard": SOURCE_ITEM_TURRET_HANDLE_ITEM_FOUND_GUARD,
		"entry_update_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_ENTRY_UPDATE_EXPR,
		"swap_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_SWAP_EXPR,
		"add_expr": SOURCE_ITEM_TURRET_HANDLE_ITEM_ADD_EXPR,
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
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_ACCEPT_ITEM_METHOD,
		"override_expr": source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_ACCEPT_ITEM_EXPR,
		"item": item,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo_value,
		"ammo_multiplier": ammo_multiplier,
		"ammo_type_null": ammo_type_null,
		"accept_item": accept_item,
	}
