extends "res://src/game/SourceGameplayRuntimePortBridge.gd"

const source_core_inventory_port_bridge_runtime_state := preload("res://src/game/SourceCoreInventoryRuntimeState.gd")
const source_core_inventory_port_bridge_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")

func playable_core_item_id() -> String:
	return source_core_inventory_port_bridge_scenario_defaults.ITEM_COPPER

func playable_core_item_name() -> String:
	var runtime_content_catalog = get("content_catalog")
	var core_item = runtime_content_catalog.get_by_id(playable_core_item_id()) if runtime_content_catalog else null
	return core_item.display_name() if core_item else source_core_inventory_port_bridge_scenario_defaults.ITEM_COPPER.capitalize()

func sync_copper_inventory_alias() -> void:
	source_core_inventory_port_bridge_runtime_state.sync_copper_inventory_runtime_state(self)

func clamp_core_item_amount(amount: int) -> int:
	return source_core_inventory_port_bridge_runtime_state.clamp_item_amount(amount, int(get("core_item_capacity")))

func set_core_item_count(item_id: String, amount: int) -> void:
	source_core_inventory_port_bridge_runtime_state.set_item_count_runtime_state(self, item_id, amount)

func add_core_item(item_id: String, amount: int) -> void:
	source_core_inventory_port_bridge_runtime_state.add_item_runtime_state(self, item_id, amount)

func core_item_count(item_id: String) -> int:
	return source_core_inventory_port_bridge_runtime_state.item_count_runtime_state(self, item_id)

func source_core_accept_item(item_id: String) -> bool:
	var state := source_core_inventory_port_bridge_runtime_state.accept_item_state(bool(get("core_incinerates")), core_item_count(item_id), int(get("core_item_capacity")), item_id)
	return bool(state.get(source_core_inventory_port_bridge_runtime_state.SOURCE_CORE_INVENTORY_ACCEPT_ITEM_KEY, false))

func source_core_handle_item(item_id: String) -> bool:
	return source_core_inventory_port_bridge_runtime_state.game_handle_item(self, item_id)
