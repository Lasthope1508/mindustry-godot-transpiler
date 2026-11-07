extends RefCounted
class_name SourceItemTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_item_turret_build_io_state := preload("res://src/game/SourceItemTurretBuildIoState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")

const SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO := source_turret_source_text_state.SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR := source_turret_source_text_state.SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR
const SOURCE_ITEM_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_INNER_CLASS
const SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR := source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR
const SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR
const SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD
const SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN
const SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE
const SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE := source_turret_source_text_state.SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE
const SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD
const SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR
const SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD
const SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR
const SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD
const SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP
const SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD
const SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR
const SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD
const SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR
const SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR
const SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD
const SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT
const SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0
	var handle_item_call: Dictionary = {}
	if should_handle_first_ammo:
		handle_item_call = {"call": SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO, "source": "this", "item": first_ammo_item}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ON_PROXIMITY_ADDED_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_on_proximity_added_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_SUPER_EXPR,
		"comment": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_COMMENT,
		"guard_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_GUARD_EXPR,
		"handle_item_expr": SOURCE_ITEM_TURRET_ON_PROXIMITY_ADDED_HANDLE_ITEM_EXPR,
		"has_ammo": has_ammo,
		"cheating": cheating,
		"ammo_types_size": ammo_types_size,
		"first_ammo_item": first_ammo_item,
		"should_handle_first_ammo": should_handle_first_ammo,
		"handle_item_call": handle_item_call,
		"super_on_proximity_added_called": true,
	}

static func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_onProximityAdded_0", [has_ammo, cheating, ammo_types_size, first_ammo_item])
	var canonical = on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ON_PROXIMITY_ADDED_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.onProximityAdded",
		"result": result,
		"canonical": canonical,
		"matches": result.get("handle_item_call", null) == canonical.get("handle_item_call", null) and result.get("should_handle_first_ammo", null) == canonical.get("should_handle_first_ammo", null),
	}

static func sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	var sense_object_value: Variant = null
	if sensor == SOURCE_ITEM_TURRET_CURRENT_AMMO_TYPE_SENSOR:
		sense_object_value = peek_item if ammo_size > 0 else null
	else:
		sense_object_value = super_sense_object_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_SENSE_OBJECT_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_SENSE_OBJECT_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"switch_return_expr": SOURCE_ITEM_TURRET_SENSE_OBJECT_SWITCH_RETURN,
		"current_ammo_type_case": SOURCE_ITEM_TURRET_SENSE_OBJECT_CURRENT_AMMO_TYPE_CASE,
		"default_case": SOURCE_ITEM_TURRET_SENSE_OBJECT_DEFAULT_CASE,
		"sensor": sensor,
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"super_sense_object_value": super_sense_object_value,
		"sense_object_value": sense_object_value,
	}

static func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_senseObject_1", [sensor, ammo_size, peek_item, super_sense_object_value])
	var canonical = sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_SENSE_OBJECT_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.senseObject",
		"result": result,
		"canonical": canonical,
		"matches": result.get("sense_object_value", null) == canonical.get("sense_object_value", null),
	}

static func get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	var ammo_content: Variant = peek_item if ammo_size > 0 else null
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_CONTENT_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_GET_AMMO_CONTENT_RETURN_EXPR,
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"ammo_content": ammo_content,
	}

static func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoContent_2", [ammo_size, peek_item])
	var canonical = get_ammo_content_state(ammo_size, peek_item)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_CONTENT_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoContent",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_content", null) == canonical.get("ammo_content", null),
	}

static func get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var ammo_fraction: float = total_ammo / max_ammo
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_GET_AMMO_FRACTION_RETURN_EXPR,
		"total_ammo": total_ammo,
		"max_ammo": max_ammo,
		"ammo_fraction": ammo_fraction,
	}

static func accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_ACCEPT_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"type_lookup": SOURCE_ITEM_TURRET_ACCEPT_STACK_TYPE_LOOKUP,
		"null_guard": SOURCE_ITEM_TURRET_ACCEPT_STACK_NULL_GUARD,
		"return_expr": SOURCE_ITEM_TURRET_ACCEPT_STACK_RETURN_EXPR,
		"item": item,
		"amount": amount,
		"max_ammo": max_ammo,
		"total_ammo": total_ammo,
		"ammo_multiplier": ammo_multiplier,
		"ammo_type_null": ammo_type_null,
		"accept_stack": accept_stack,
	}

static func handle_stack_state(item: Variant, amount: int) -> Dictionary:
	var handle_item_calls: Array = []
	for _i in range(amount):
		handle_item_calls.append({"call": SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR, "source": null, "item": item})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_HANDLE_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"loop_expr": SOURCE_ITEM_TURRET_HANDLE_STACK_LOOP_EXPR,
		"handle_item_expr": SOURCE_ITEM_TURRET_HANDLE_STACK_HANDLE_ITEM_EXPR,
		"item": item,
		"amount": amount,
		"handle_item_calls": handle_item_calls,
		"handle_item_call_count": handle_item_calls.size(),
	}

static func remove_stack_state(item: Variant, amount: int) -> Dictionary:
	var removed_stack: int = 0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"comment": SOURCE_ITEM_TURRET_REMOVE_STACK_COMMENT,
		"method": SOURCE_ITEM_TURRET_REMOVE_STACK_METHOD,
		"override_expr": SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_REMOVE_STACK_RETURN_EXPR,
		"item": item,
		"amount": amount,
		"removed_stack": removed_stack,
	}

static func handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo_value, ammo_multiplier, ammo_type_null)

static func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo, max_ammo])
	var canonical = get_ammo_fraction_state(total_ammo, max_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}

static func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo])
	var canonical = get_ammo_fraction_state(total_ammo, source_turret_defaults.MAX_AMMO_DEFAULT)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"ammo_fraction": total_ammo / source_turret_defaults.MAX_AMMO_DEFAULT,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}

static func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null])
	var canonical = accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_stack", null) == canonical.get("accept_stack", null),
	}

static func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount])
	var canonical = accept_stack_state(item, amount, source_turret_defaults.MAX_AMMO_DEFAULT, 0.0, 1.0, false)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptStack",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["max_ammo", "total_ammo", "ammo_multiplier", "ammo_type_null"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"accept_stack": min(int(source_turret_defaults.MAX_AMMO_DEFAULT), amount),
		"matches": result.get("accept_stack", null) == canonical.get("accept_stack", null),
	}

static func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_handleStack_5", [item, amount])
	var canonical = handle_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.handleStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("handle_item_calls", []) == canonical.get("handle_item_calls", []),
	}

static func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_removeStack_6", [item, amount])
	var canonical = remove_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.removeStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("removed_stack", null) == canonical.get("removed_stack", null),
	}

static func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_handleItem_7", [item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries])
	var canonical = handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.handleItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("total_ammo_after", null) == canonical.get("total_ammo_after", null)
			and result.get("ammo_entries_after", []) == canonical.get("ammo_entries_after", [])
			and result.get("flame_ammo_event_fired", null) == canonical.get("flame_ammo_event_fired", null)
			and result.get("resupply_turret_event_fired", null) == canonical.get("resupply_turret_event_fired", null)
			and result.get("type_null_returned", null) == canonical.get("type_null_returned", null)
			and result.get("entry_found", null) == canonical.get("entry_found", null)
			and result.get("entry_added", null) == canonical.get("entry_added", null)
			and result.get("swapped", null) == canonical.get("swapped", null),
	}

static func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptItem_8", [item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null])
	var canonical = accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

static func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_acceptItem_8", [item])
	var canonical = accept_item_state(item, 0, source_turret_defaults.MAX_AMMO_DEFAULT, 0.0, false)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"defaulted_args": ["total_ammo", "max_ammo", "ammo_multiplier", "ammo_type_null"],
		"max_ammo": source_turret_defaults.MAX_AMMO_DEFAULT,
		"accept_item": result.get("accept_item", null),
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

static func version_state() -> Dictionary:
	return source_item_turret_build_io_state.version_state()

static func write_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.write_state(ammo_entries)

static func read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.read_state(revision, max_ammo, read_entries)

static func generated_version_bridge_state() -> Dictionary:
	return source_item_turret_build_io_state.generated_version_bridge_state()

static func generated_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.generated_write_bridge_state(ammo_entries)

static func generated_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_io_state.generated_read_bridge_state(revision, max_ammo, read_entries)
