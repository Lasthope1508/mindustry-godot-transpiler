extends "res://src/game/SourceBuildingItemPayloadPortBridge.gd"

const source_building_core_state := preload("res://src/game/SourceBuildingCoreState.gd")

func source_block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	return source_building_core_state.block_can_replace_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func source_block_can_replace_result_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> Dictionary:
	return source_building_core_state.block_can_replace_result_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func generated_block_can_replace_bridge_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> Dictionary:
	return source_building_core_state.generated_block_can_replace_bridge_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)

func source_building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return source_building_core_state.building_can_be_replaced_state(other_can_replace_block)

func source_building_power_production_state() -> Dictionary:
	return source_building_core_state.power_production_state()

func generated_building_comp_power_production_bridge_state() -> Dictionary:
	return source_building_core_state.generated_power_production_bridge_state()

func generated_building_comp_check_solid_bridge_state() -> Dictionary:
	return source_building_core_state.generated_check_solid_bridge_state()

func generated_building_comp_absorb_lasers_bridge_state(block_absorb_lasers: bool) -> Dictionary:
	return source_building_core_state.generated_absorb_lasers_bridge_state(block_absorb_lasers)

func generated_building_comp_is_insulated_bridge_state(block_insulated: bool) -> Dictionary:
	return source_building_core_state.generated_is_insulated_bridge_state(block_insulated)

func generated_building_comp_collide_bridge_state(other: Variant) -> Dictionary:
	return source_building_core_state.generated_collide_bridge_state(other)

func source_building_check_solid_state() -> bool:
	return source_building_core_state.check_solid_state()

func source_building_absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return source_building_core_state.absorb_lasers_state(block_absorb_lasers)

func source_building_is_insulated_state(block_insulated: bool) -> bool:
	return source_building_core_state.is_insulated_state(block_insulated)

func source_building_collide_state(_other: Variant) -> bool:
	return source_building_core_state.collide_state(_other)
