extends "res://src/game/SourceTurretAmmoPortBridge.gd"

const source_drill_inventory_port_bridge_runtime_state := preload("res://src/game/SourceDrillInventoryRuntimeState.gd")

func set_drill_dump_cursor(value: int) -> void:
	set("drill_dump_cursor", value)

func drill_item_count(item_id: String) -> int:
	return source_drill_inventory_port_bridge_runtime_state.item_count(get("drill_items"), item_id)

func drill_items_total() -> int:
	return source_drill_inventory_port_bridge_runtime_state.items_total(get("drill_items"))

func add_drill_item(item_id: String, amount: int) -> void:
	source_drill_inventory_port_bridge_runtime_state.add_item_runtime_state(self, item_id, amount)

func source_offload_to_inventory(item_id: String, amount: int, routing_context: Dictionary = {}) -> void:
	source_drill_inventory_port_bridge_runtime_state.offload_to_inventory_runtime_state(self, item_id, amount, routing_context)

func remove_drill_item(item_id: String, amount: int) -> int:
	return source_drill_inventory_port_bridge_runtime_state.remove_item_runtime_state(self, item_id, amount)

func source_dump_drill_item_to_core(item_id: String) -> bool:
	return bool(source_drill_inventory_port_bridge_runtime_state.game_dump_item_to_core_state(self, item_id).get("dump_success", false))
