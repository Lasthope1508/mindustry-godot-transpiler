extends RefCounted
class_name SourceItemTurretBuildIoState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_BUILD_INNER_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_INNER_CLASS
const SOURCE_ITEM_TURRET_BUILD_VERSION_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_VERSION_METHOD
const SOURCE_ITEM_TURRET_BUILD_VERSION_RETURN_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_VERSION_RETURN_EXPR
const SOURCE_ITEM_TURRET_BUILD_WRITE_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_METHOD
const SOURCE_ITEM_TURRET_BUILD_WRITE_SUPER_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_SUPER_EXPR
const SOURCE_ITEM_TURRET_BUILD_WRITE_SIZE_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_SIZE_EXPR
const SOURCE_ITEM_TURRET_BUILD_WRITE_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_LOOP_EXPR
const SOURCE_ITEM_TURRET_BUILD_WRITE_ENTRY_CAST := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_ENTRY_CAST
const SOURCE_ITEM_TURRET_BUILD_WRITE_ITEM_ID_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_ITEM_ID_EXPR
const SOURCE_ITEM_TURRET_BUILD_WRITE_AMOUNT_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_WRITE_AMOUNT_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_METHOD := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_METHOD
const SOURCE_ITEM_TURRET_BUILD_READ_SUPER_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_SUPER_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_CLEAR_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_CLEAR_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_RESET_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_RESET_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_AMOUNT_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_AMOUNT_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_LOOP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_LOOP_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_ITEM_LOOKUP_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_ITEM_LOOKUP_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_ITEM_AMOUNT_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_ITEM_AMOUNT_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_VALID_COMMENT := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_VALID_COMMENT
const SOURCE_ITEM_TURRET_BUILD_READ_VALID_AMMO_GUARD := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_VALID_AMMO_GUARD
const SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_ADD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_ADD_EXPR
const SOURCE_ITEM_TURRET_BUILD_READ_AMMO_ADD_EXPR := source_turret_source_text_state.SOURCE_ITEM_TURRET_BUILD_READ_AMMO_ADD_EXPR

static func _item_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func version_state() -> Dictionary:
	var version_value: int = 2
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_VERSION_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_BUILD_VERSION_METHOD,
		"override_expr": source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"return_expr": SOURCE_ITEM_TURRET_BUILD_VERSION_RETURN_EXPR,
		"version": version_value,
	}

static func write_state(ammo_entries: Array) -> Dictionary:
	var write_calls: Array = []
	var entry_writes: Array = []
	write_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_WRITE_SUPER_EXPR})
	write_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_WRITE_SIZE_EXPR, "value": ammo_entries.size()})
	for entry in ammo_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		entry_writes.append({"item_id": int(entry_copy.get("item_id", 0)), "amount": int(entry_copy.get("amount", 0))})
		write_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_WRITE_ITEM_ID_EXPR, "value": int(entry_copy.get("item_id", 0))})
		write_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_WRITE_AMOUNT_EXPR, "value": int(entry_copy.get("amount", 0))})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_WRITE_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_BUILD_WRITE_METHOD,
		"override_expr": source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_write_expr": SOURCE_ITEM_TURRET_BUILD_WRITE_SUPER_EXPR,
		"write_size_expr": SOURCE_ITEM_TURRET_BUILD_WRITE_SIZE_EXPR,
		"loop_expr": SOURCE_ITEM_TURRET_BUILD_WRITE_LOOP_EXPR,
		"entry_cast": SOURCE_ITEM_TURRET_BUILD_WRITE_ENTRY_CAST,
		"write_item_id_expr": SOURCE_ITEM_TURRET_BUILD_WRITE_ITEM_ID_EXPR,
		"write_amount_expr": SOURCE_ITEM_TURRET_BUILD_WRITE_AMOUNT_EXPR,
		"ammo_size": ammo_entries.size(),
		"entry_writes": entry_writes,
		"write_calls": write_calls,
	}

static func read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	var read_calls: Array = []
	var ammo_entries_after: Array = []
	var total_ammo_after: int = 0
	read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_SUPER_EXPR, "revision": revision})
	read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_CLEAR_EXPR})
	read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_RESET_EXPR, "value": 0})
	read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_AMOUNT_EXPR, "target": "amount", "value": read_entries.size()})
	for entry in read_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		var item: Variant = entry_copy.get("item", null)
		var ammo_type_valid: bool = bool(entry_copy.get("ammo_type_valid", false))
		var item_read_call: String = "read.ub();" if revision < 2 else "read.s();"
		read_calls.append({"call": item_read_call, "target": "item", "item": item})
		var item_amount: int = min(int(entry_copy.get("amount", 0)), max_ammo)
		read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_ITEM_AMOUNT_EXPR, "target": "itemAmount", "value": item_amount})
		if item != null and ammo_type_valid:
			total_ammo_after += item_amount
			ammo_entries_after.append({"item": item, "amount": item_amount})
			read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_ADD_EXPR, "value": total_ammo_after})
			read_calls.append({"call": SOURCE_ITEM_TURRET_BUILD_READ_AMMO_ADD_EXPR, "item": item, "amount": item_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_READ_STATE,
		"inner_class": SOURCE_ITEM_TURRET_BUILD_INNER_CLASS,
		"method": SOURCE_ITEM_TURRET_BUILD_READ_METHOD,
		"override_expr": source_turret_source_text_state.SOURCE_TURRET_PRESENTATION_OVERRIDE_EXPR,
		"super_read_expr": SOURCE_ITEM_TURRET_BUILD_READ_SUPER_EXPR,
		"clear_expr": SOURCE_ITEM_TURRET_BUILD_READ_CLEAR_EXPR,
		"total_reset_expr": SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_RESET_EXPR,
		"amount_expr": SOURCE_ITEM_TURRET_BUILD_READ_AMOUNT_EXPR,
		"loop_expr": SOURCE_ITEM_TURRET_BUILD_READ_LOOP_EXPR,
		"item_lookup_expr": SOURCE_ITEM_TURRET_BUILD_READ_ITEM_LOOKUP_EXPR,
		"item_amount_expr": SOURCE_ITEM_TURRET_BUILD_READ_ITEM_AMOUNT_EXPR,
		"valid_comment": SOURCE_ITEM_TURRET_BUILD_READ_VALID_COMMENT,
		"valid_ammo_guard": SOURCE_ITEM_TURRET_BUILD_READ_VALID_AMMO_GUARD,
		"total_add_expr": SOURCE_ITEM_TURRET_BUILD_READ_TOTAL_ADD_EXPR,
		"ammo_add_expr": SOURCE_ITEM_TURRET_BUILD_READ_AMMO_ADD_EXPR,
		"read_count": read_entries.size(),
		"total_ammo_after": total_ammo_after,
		"ammo_entries_after": ammo_entries_after,
		"read_calls": read_calls,
	}

static func generated_version_bridge_state() -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_version_9", [])
	var canonical = version_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_VERSION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.version",
		"result": result,
		"canonical": canonical,
		"matches": result.get("version", null) == canonical.get("version", null),
	}

static func generated_write_bridge_state(ammo_entries: Array) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_write_10", [ammo_entries])
	var canonical = write_state(ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_WRITE_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.write",
		"result": result,
		"canonical": canonical,
		"matches": result.get("write_calls", []) == canonical.get("write_calls", []),
	}

static func generated_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	var result = _item_turret_call("java_inner_class_ItemTurretBuild_method_read_11", [revision, max_ammo, read_entries])
	var canonical = read_state(revision, max_ammo, read_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_READ_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.read",
		"result": result,
		"canonical": canonical,
		"matches": result.get("read_calls", []) == canonical.get("read_calls", []),
	}
