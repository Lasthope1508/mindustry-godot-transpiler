extends "res://src/game/SourceBuildPayloadPortBridge.gd"

const source_child_state := preload("res://src/game/SourceChildState.gd")
const source_basic_comp_state := preload("res://src/game/SourceBasicCompState.gd")
const source_unit_tether_state := preload("res://src/game/SourceUnitTetherState.gd")
const source_building_tether_state := preload("res://src/game/SourceBuildingTetherState.gd")

func source_building_tether_update_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return source_building_tether_state.update_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func generated_building_tether_comp_update_bridge_state(building_exists: bool, building_is_valid: bool, building_team_value: Variant, team_value: Variant, unit_id: int) -> Dictionary:
	return source_building_tether_state.generated_building_tether_update_bridge_state(building_exists, building_is_valid, building_team_value, team_value, unit_id)

func source_child_add_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.add_state(child_state)

func generated_child_comp_add_bridge_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.generated_child_add_bridge_state(child_state)

func source_child_update_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.game_update_state(self, child_state)

func generated_child_comp_update_bridge_state(child_state: Dictionary) -> Dictionary:
	return source_child_state.game_generated_child_update_bridge_state(self, child_state)

func source_pos_set_state(x_value: float, y_value: float) -> Dictionary:
	return source_basic_comp_state.pos_set_state(x_value, y_value)

func generated_pos_comp_set_bridge_state(x_value: float, y_value: float) -> Dictionary:
	return source_basic_comp_state.generated_pos_set_bridge_state(x_value, y_value)

func source_shielder_absorb_state() -> Dictionary:
	return source_basic_comp_state.shielder_absorb_state()

func generated_shielder_comp_absorb_bridge_state() -> Dictionary:
	return source_basic_comp_state.generated_shielder_absorb_bridge_state()

func source_unit_tether_after_read_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.after_read_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_after_read_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_after_sync_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.after_sync_state(spawner_unit_id, groups_unit_get_by_id_result)

func generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id: int, groups_unit_get_by_id_result: Variant) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_after_sync_bridge_state(spawner_unit_id, groups_unit_get_by_id_result)

func source_unit_tether_update_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return source_unit_tether_state.update_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)

func generated_unit_tether_comp_update_bridge_state(spawner_exists: bool, spawner_is_valid: bool, spawner_team_value: Variant, team_value: Variant, unit_id: int, spawner_id: int) -> Dictionary:
	return source_unit_tether_state.generated_unit_tether_comp_update_bridge_state(spawner_exists, spawner_is_valid, spawner_team_value, team_value, unit_id, spawner_id)
