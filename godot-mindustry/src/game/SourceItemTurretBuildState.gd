extends RefCounted
class_name SourceItemTurretBuildState

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO := "handleItem(this, ammoTypes.keys().next());"

static func on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var should_handle_first_ammo: bool = (not has_ammo) and cheating and ammo_types_size > 0
	var handle_item_call: Dictionary = {}
	if should_handle_first_ammo:
		handle_item_call = {"call": SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO, "source": "this", "item": first_ammo_item}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ON_PROXIMITY_ADDED_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public void onProximityAdded(){",
		"override_expr": "@Override",
		"super_on_proximity_added_expr": "super.onProximityAdded();",
		"comment": "//add first ammo item to cheaty blocks so they can shoot properly",
		"guard_expr": "if(!hasAmmo() && cheating() && ammoTypes.size > 0){",
		"handle_item_expr": SOURCE_ITEM_TURRET_BOOTSTRAP_FIRST_AMMO,
		"has_ammo": has_ammo,
		"cheating": cheating,
		"ammo_types_size": ammo_types_size,
		"first_ammo_item": first_ammo_item,
		"should_handle_first_ammo": should_handle_first_ammo,
		"handle_item_call": handle_item_call,
		"super_on_proximity_added_called": true,
	}

static func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_onProximityAdded_0", [has_ammo, cheating, ammo_types_size, first_ammo_item], null)
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
	if sensor == "currentAmmoType":
		sense_object_value = peek_item if ammo_size > 0 else null
	else:
		sense_object_value = super_sense_object_value
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_SENSE_OBJECT_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public Object senseObject(LAccess sensor){",
		"override_expr": "@Override",
		"switch_return_expr": "return switch(sensor){",
		"current_ammo_type_case": "case currentAmmoType -> ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;",
		"default_case": "default -> super.senseObject(sensor);",
		"sensor": sensor,
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"super_sense_object_value": super_sense_object_value,
		"sense_object_value": sense_object_value,
	}

static func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_senseObject_1", [sensor, ammo_size, peek_item, super_sense_object_value], null)
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
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public UnlockableContent getAmmoContent(){",
		"override_expr": "@Override",
		"return_expr": "return ammo.size > 0 ? ((ItemEntry)ammo.peek()).item : null;",
		"ammo_size": ammo_size,
		"peek_item": peek_item,
		"ammo_content": ammo_content,
	}

static func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_getAmmoContent_2", [ammo_size, peek_item], null)
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
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public float getAmmoFraction(){",
		"override_expr": "@Override",
		"return_expr": "return (float)totalAmmo / maxAmmo;",
		"total_ammo": total_ammo,
		"max_ammo": max_ammo,
		"ammo_fraction": ammo_fraction,
	}

static func accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	var accept_stack: int = 0 if ammo_type_null else min(int((max_ammo - total_ammo) / ammo_multiplier), amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public int acceptStack(Item item, int amount, Teamc source){",
		"override_expr": "@Override",
		"type_lookup": "BulletType type = ammoTypes.get(item);",
		"null_guard": "if(type == null) return 0;",
		"return_expr": "return Math.min((int)((maxAmmo - totalAmmo) / ammoTypes.get(item).ammoMultiplier), amount);",
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
		handle_item_calls.append({"call": "handleItem(null, item);", "source": null, "item": item})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public void handleStack(Item item, int amount, Teamc source){",
		"override_expr": "@Override",
		"loop_expr": "for(int i = 0; i < amount; i++){",
		"handle_item_expr": "handleItem(null, item);",
		"item": item,
		"amount": amount,
		"handle_item_calls": handle_item_calls,
		"handle_item_call_count": handle_item_calls.size(),
	}

static func remove_stack_state(item: Variant, amount: int) -> Dictionary:
	var removed_stack: int = 0
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"comment": "//currently can't remove items from turrets.",
		"method": "public int removeStack(Item item, int amount){",
		"override_expr": "@Override",
		"return_expr": "return 0;",
		"item": item,
		"amount": amount,
		"removed_stack": removed_stack,
	}

static func handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

static func accept_item_state(item: Variant, total_ammo: int, max_ammo_value: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo_value, ammo_multiplier, ammo_type_null)

static func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo, max_ammo], null)
	var canonical = get_ammo_fraction_state(total_ammo, max_ammo)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_GET_AMMO_FRACTION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.getAmmoFraction",
		"result": result,
		"canonical": canonical,
		"matches": result.get("ammo_fraction", null) == canonical.get("ammo_fraction", null),
	}

static func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_getAmmoFraction_3", [total_ammo], null)
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null], null)
	var canonical = accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_stack", null) == canonical.get("accept_stack", null),
	}

static func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_acceptStack_4", [item, amount], null)
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_handleStack_5", [item, amount], null)
	var canonical = handle_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_HANDLE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.handleStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("handle_item_calls", []) == canonical.get("handle_item_calls", []),
	}

static func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_removeStack_6", [item, amount], null)
	var canonical = remove_stack_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_REMOVE_STACK_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.removeStack",
		"result": result,
		"canonical": canonical,
		"matches": result.get("removed_stack", null) == canonical.get("removed_stack", null),
	}

static func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_handleItem_7", [item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries], null)
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
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_acceptItem_8", [item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null], null)
	var canonical = accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_ACCEPT_ITEM_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.acceptItem",
		"result": result,
		"canonical": canonical,
		"matches": result.get("accept_item", null) == canonical.get("accept_item", null),
	}

static func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_acceptItem_8", [item], null)
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
	var version_value: int = 2
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_VERSION_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public byte version(){",
		"override_expr": "@Override",
		"return_expr": "return 2;",
		"version": version_value,
	}

static func write_state(ammo_entries: Array) -> Dictionary:
	var write_calls: Array = []
	var entry_writes: Array = []
	write_calls.append({"call": "super.write(write);"})
	write_calls.append({"call": "write.b(ammo.size);", "value": ammo_entries.size()})
	for entry in ammo_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		entry_writes.append({"item_id": int(entry_copy.get("item_id", 0)), "amount": int(entry_copy.get("amount", 0))})
		write_calls.append({"call": "write.s(i.item.id);", "value": int(entry_copy.get("item_id", 0))})
		write_calls.append({"call": "write.s(i.amount);", "value": int(entry_copy.get("amount", 0))})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_WRITE_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public void write(Writes write){",
		"override_expr": "@Override",
		"super_write_expr": "super.write(write);",
		"write_size_expr": "write.b(ammo.size);",
		"loop_expr": "for(AmmoEntry entry : ammo){",
		"entry_cast": "ItemEntry i = (ItemEntry)entry;",
		"write_item_id_expr": "write.s(i.item.id);",
		"write_amount_expr": "write.s(i.amount);",
		"ammo_size": ammo_entries.size(),
		"entry_writes": entry_writes,
		"write_calls": write_calls,
	}

static func read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	var read_calls: Array = []
	var ammo_entries_after: Array = []
	var total_ammo_after: int = 0
	read_calls.append({"call": "super.read(read, revision);", "revision": revision})
	read_calls.append({"call": "ammo.clear();"})
	read_calls.append({"call": "totalAmmo = 0;", "value": 0})
	read_calls.append({"call": "read.ub();", "target": "amount", "value": read_entries.size()})
	for entry in read_entries:
		var entry_copy: Dictionary = entry.duplicate(true) if entry is Dictionary else {}
		var item: Variant = entry_copy.get("item", null)
		var ammo_type_valid: bool = bool(entry_copy.get("ammo_type_valid", false))
		var item_read_call: String = "read.ub();" if revision < 2 else "read.s();"
		read_calls.append({"call": item_read_call, "target": "item", "item": item})
		var item_amount: int = min(int(entry_copy.get("amount", 0)), max_ammo)
		read_calls.append({"call": "read.s();", "target": "itemAmount", "value": item_amount})
		if item != null and ammo_type_valid:
			total_ammo_after += item_amount
			ammo_entries_after.append({"item": item, "amount": item_amount})
			read_calls.append({"call": "totalAmmo += itemAmount;", "value": total_ammo_after})
			read_calls.append({"call": "ammo.add(new ItemEntry(item, itemAmount));", "item": item, "amount": item_amount})
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_READ_STATE,
		"inner_class": "public class ItemTurretBuild extends TurretBuild{",
		"method": "public void read(Reads read, byte revision){",
		"override_expr": "@Override",
		"super_read_expr": "super.read(read, revision);",
		"clear_expr": "ammo.clear();",
		"total_reset_expr": "totalAmmo = 0;",
		"amount_expr": "int amount = read.ub();",
		"loop_expr": "for(int i = 0; i < amount; i++){",
		"item_lookup_expr": "Item item = Vars.content.item(revision < 2 ? read.ub() : read.s());",
		"item_amount_expr": "int itemAmount = Math.min(read.s(), maxAmmo);",
		"valid_comment": "//only add ammo if this is a valid ammo type",
		"valid_ammo_guard": "if(item != null && ammoTypes.containsKey(item)){",
		"total_add_expr": "totalAmmo += itemAmount;",
		"ammo_add_expr": "ammo.add(new ItemEntry(item, itemAmount));",
		"read_count": read_entries.size(),
		"total_ammo_after": total_ammo_after,
		"ammo_entries_after": ammo_entries_after,
		"read_calls": read_calls,
	}

static func generated_version_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_version_9", [], null)
	var canonical = version_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_VERSION_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.version",
		"result": result,
		"canonical": canonical,
		"matches": result.get("version", null) == canonical.get("version", null),
	}

static func generated_write_bridge_state(ammo_entries: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_write_10", [ammo_entries], null)
	var canonical = write_state(ammo_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_WRITE_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.write",
		"result": result,
		"canonical": canonical,
		"matches": result.get("write_calls", []) == canonical.get("write_calls", []),
	}

static func generated_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemTurretBuild_method_read_11", [revision, max_ammo, read_entries], null)
	var canonical = read_state(revision, max_ammo, read_entries)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_BUILD_READ_STATE,
		"generated_owner": "item_turret.ItemTurretBuild.read",
		"result": result,
		"canonical": canonical,
		"matches": result.get("read_calls", []) == canonical.get("read_calls", []),
	}
