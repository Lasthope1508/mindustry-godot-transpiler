extends "res://src/game/SourceBlockRequirementsPortBridge.gd"

const source_turret_ammo_state := preload("res://src/game/SourceTurretAmmoState.gd")
const source_item_entry_state := preload("res://src/game/SourceItemEntryState.gd")
const source_liquid_turret_init_state_script := preload("res://src/game/SourceLiquidTurretInitState.gd")
const source_continuous_liquid_turret_init_state_script := preload("res://src/game/SourceContinuousLiquidTurretInitState.gd")

func source_item_turret_build_handle_item_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_handle_item_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func source_item_turret_build_accept_item_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_turret_ammo_state.item_turret_build_accept_item_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func source_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.liquid_turret_ammo_state(objects)

func generated_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_liquid_turret_ammo_bridge_state(objects)

func source_item_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.item_turret_ammo_state(objects)

func generated_item_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_item_turret_ammo_bridge_state(objects)

func source_continuous_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.continuous_liquid_turret_ammo_state(objects)

func generated_continuous_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	return source_turret_ammo_state.generated_continuous_liquid_turret_ammo_bridge_state(objects)

func source_turret_ammo_data(turret, item_id: String) -> Dictionary:
	return source_turret_ammo_state.turret_ammo_data(turret, item_id)

func peek_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return source_turret_ammo_state.peek_turret_ammo(self, cell, turret)

func handle_turret_item(cell: Vector2i, turret, item_id: String) -> bool:
	return source_turret_ammo_state.handle_turret_item(self, cell, turret, item_id)

func use_turret_ammo(cell: Vector2i, turret) -> Dictionary:
	return source_turret_ammo_state.use_turret_ammo(self, cell, turret)

func bootstrap_selected_turret_ammo() -> int:
	return source_turret_ammo_state.bootstrap_selected_turret_ammo(self)

func load_selected_turret_ammo(item_id: String, amount: int) -> int:
	return source_turret_ammo_state.load_selected_turret_ammo(self, item_id, amount)

func use_selected_turret_ammo_once() -> Dictionary:
	return source_turret_ammo_state.use_selected_turret_ammo_once(self)

func source_item_entry_constructor_state(item: Variant, amount: int) -> Dictionary:
	return source_item_entry_state.constructor_state(item, amount)

func generated_item_entry_constructor_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_entry_state.generated_constructor_bridge_state(item, amount)

func source_item_entry_type_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return source_item_entry_state.type_state(item, ammo_type)

func generated_item_entry_type_bridge_state(item: Variant, ammo_type: Variant) -> Dictionary:
	return source_item_entry_state.generated_type_bridge_state(item, ammo_type)

func source_item_entry_to_string_state(item_string: String, amount: int) -> Dictionary:
	return source_item_entry_state.to_string_state(item_string, amount)

func generated_item_entry_to_string_bridge_state(item_string: String, amount: int) -> Dictionary:
	return source_item_entry_state.generated_to_string_bridge_state(item_string, amount)

func source_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	return source_liquid_turret_init_state_script.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)

func generated_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float) -> Dictionary:
	return source_liquid_turret_init_state_script.generated_init_bridge_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin)

func generated_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	return source_liquid_turret_init_state_script.generated_init_range_margin_default_bridge_state(ammo_entries, target_ground, place_overlap_range)

func source_continuous_liquid_turret_init_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.init_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)

func generated_continuous_liquid_turret_init_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float, range_value: float, place_overlap_margin: float, liquid_consumed: float, current_liquid: Variant, current_ammo_multiplier: Variant) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.generated_init_bridge_state(ammo_entries, target_ground, place_overlap_range, range_value, place_overlap_margin, liquid_consumed, current_liquid, current_ammo_multiplier)

func generated_continuous_liquid_turret_init_range_margin_default_bridge_state(ammo_entries: Array, target_ground: bool, place_overlap_range: float) -> Dictionary:
	return source_continuous_liquid_turret_init_state_script.generated_init_range_margin_default_bridge_state(ammo_entries, target_ground, place_overlap_range)
