extends RefCounted
class_name SourceItemEntryState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func constructor_state(item: Variant, amount: int) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_CONSTRUCTOR_STATE,
		"inner_class": "public class ItemEntry extends AmmoEntry{",
		"field": "public Item item;",
		"constructor": "ItemEntry(Item item, int amount){",
		"item_assign_expr": "this.item = item;",
		"amount_assign_expr": "this.amount = amount;",
		"item": item,
		"amount": amount,
		"item_after": item,
		"amount_after": amount,
	}

static func type_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_TYPE_STATE,
		"inner_class": "public class ItemEntry extends AmmoEntry{",
		"override_expr": "@Override",
		"method": "public BulletType type(){",
		"return_expr": "return ammoTypes.get(item);",
		"item": item,
		"ammo_type": ammo_type,
		"type": ammo_type,
	}

static func to_string_state(item_string: String, amount: int) -> Dictionary:
	var to_string_value: String = "ItemEntry{item=" + item_string + ", amount=" + str(amount) + "}"
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_TO_STRING_STATE,
		"inner_class": "public class ItemEntry extends AmmoEntry{",
		"override_expr": "@Override",
		"method": "public String toString(){",
		"return_start_expr": "return \"ItemEntry{\" +",
		"item_concat_expr": "\"item=\" + item +",
		"amount_concat_expr": "\", amount=\" + amount +",
		"return_end_expr": "'}';",
		"item_string": item_string,
		"amount": amount,
		"to_string": to_string_value,
	}

static func generated_constructor_bridge_state(item: Variant, amount: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemEntry_constructor_ItemEntry_0", [item, amount], null)
	var canonical = constructor_state(item, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_CONSTRUCTOR_STATE,
		"generated_owner": "item_turret.ItemEntry.constructor",
		"result": result,
		"canonical": canonical,
		"matches": result.get("item_after", null) == canonical.get("item_after", null),
	}

static func generated_type_bridge_state(item: Variant, ammo_type: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemEntry_method_type_0", [item, ammo_type], null)
	var canonical = type_state(item, ammo_type)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_TYPE_STATE,
		"generated_owner": "item_turret.ItemEntry.type",
		"result": result,
		"canonical": canonical,
		"matches": result.get("type", null) == canonical.get("type", null),
	}

static func generated_to_string_bridge_state(item_string: String, amount: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/blocks/defense/turrets/ItemTurret.gd", "java_inner_class_ItemEntry_method_toString_1", [item_string, amount], null)
	var canonical = to_string_state(item_string, amount)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_ENTRY_TO_STRING_STATE,
		"generated_owner": "item_turret.ItemEntry.toString",
		"result": result,
		"canonical": canonical,
		"matches": result.get("to_string", null) == canonical.get("to_string", null),
	}
