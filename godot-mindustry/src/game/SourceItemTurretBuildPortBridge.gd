extends "res://src/game/SourceBaseTurretDrawPortBridge.gd"

const source_item_turret_build_state := preload("res://src/game/SourceItemTurretBuildState.gd")

func source_item_turret_build_on_proximity_added_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.on_proximity_added_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func generated_item_turret_build_on_proximity_added_bridge_state(has_ammo: bool, cheating: bool, ammo_types_size: int, first_ammo_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_on_proximity_added_bridge_state(has_ammo, cheating, ammo_types_size, first_ammo_item)

func source_item_turret_build_sense_object_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.sense_object_state(sensor, ammo_size, peek_item, super_sense_object_value)

func generated_item_turret_build_sense_object_bridge_state(sensor: String, ammo_size: int, peek_item: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_sense_object_bridge_state(sensor, ammo_size, peek_item, super_sense_object_value)

func source_item_turret_build_get_ammo_content_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.get_ammo_content_state(ammo_size, peek_item)

func generated_item_turret_build_get_ammo_content_bridge_state(ammo_size: int, peek_item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_content_bridge_state(ammo_size, peek_item)

func source_item_turret_build_get_ammo_fraction_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.get_ammo_fraction_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_bridge_state(total_ammo, max_ammo)

func generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo: float) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_get_ammo_fraction_default_bridge_state(total_ammo)

func source_item_turret_build_accept_stack_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.accept_stack_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_bridge_state(item: Variant, amount: int, max_ammo: float, total_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_bridge_state(item, amount, max_ammo, total_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_stack_default_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_stack_default_bridge_state(item, amount)

func source_item_turret_build_handle_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.handle_stack_state(item, amount)

func generated_item_turret_build_handle_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_stack_bridge_state(item, amount)

func source_item_turret_build_remove_stack_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.remove_stack_state(item, amount)

func generated_item_turret_build_remove_stack_bridge_state(item: Variant, amount: int) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_remove_stack_bridge_state(item, amount)

func generated_item_turret_build_handle_item_bridge_state(item: Variant, item_is_pyratite: bool, total_ammo: int, ammo_multiplier: float, ammo_type_null: bool, ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_handle_item_bridge_state(item, item_is_pyratite, total_ammo, ammo_multiplier, ammo_type_null, ammo_entries)

func generated_item_turret_build_accept_item_bridge_state(item: Variant, total_ammo: int, max_ammo: float, ammo_multiplier: float, ammo_type_null: bool) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_bridge_state(item, total_ammo, max_ammo, ammo_multiplier, ammo_type_null)

func generated_item_turret_build_accept_item_default_bridge_state(item: Variant) -> Dictionary:
	return source_item_turret_build_state.generated_item_turret_build_accept_item_default_bridge_state(item)

func source_item_turret_build_version_state() -> Dictionary:
	return source_item_turret_build_state.version_state()

func generated_item_turret_build_version_bridge_state() -> Dictionary:
	return source_item_turret_build_state.generated_version_bridge_state()

func source_item_turret_build_write_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.write_state(ammo_entries)

func generated_item_turret_build_write_bridge_state(ammo_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_write_bridge_state(ammo_entries)

func source_item_turret_build_read_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.read_state(revision, max_ammo, read_entries)

func generated_item_turret_build_read_bridge_state(revision: int, max_ammo: int, read_entries: Array) -> Dictionary:
	return source_item_turret_build_state.generated_read_bridge_state(revision, max_ammo, read_entries)
