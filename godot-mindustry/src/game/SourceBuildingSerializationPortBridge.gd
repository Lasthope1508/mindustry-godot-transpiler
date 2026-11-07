extends "res://src/game/SourceBuildingTimePortBridge.gd"

const source_building_serialization_state := preload("res://src/game/SourceBuildingSerializationState.gd")

func source_building_write_hook_noop_state(write_value: Variant = null) -> Dictionary:
	return source_building_serialization_state.write_hook_noop_state(write_value)

func source_building_read_hook_noop_state(read_value: Variant = null, revision: int = 0) -> Dictionary:
	return source_building_serialization_state.read_hook_noop_state(read_value, revision)

func source_building_write_all_state() -> Dictionary:
	return source_building_serialization_state.write_all_state()

func source_building_read_all_state() -> Dictionary:
	return source_building_serialization_state.read_all_state()

func source_building_write_sync_state() -> Dictionary:
	return source_building_serialization_state.write_sync_state()

func source_building_read_sync_state() -> Dictionary:
	return source_building_serialization_state.read_sync_state()

func source_building_version_state() -> Dictionary:
	return source_building_serialization_state.version_state()

func generated_building_comp_write_all_bridge_state() -> Dictionary:
	return source_building_serialization_state.generated_write_all_bridge_state()

func generated_building_comp_write_hook_bridge_state(write_value: Variant = null) -> Dictionary:
	return source_building_serialization_state.generated_write_hook_bridge_state(write_value)

func generated_building_comp_read_hook_bridge_state(read_value: Variant = null, revision: int = 0) -> Dictionary:
	return source_building_serialization_state.generated_read_hook_bridge_state(read_value, revision)

func generated_building_comp_read_all_bridge_state() -> Dictionary:
	return source_building_serialization_state.generated_read_all_bridge_state()

func generated_building_comp_write_sync_bridge_state() -> Dictionary:
	return source_building_serialization_state.generated_write_sync_bridge_state()

func generated_building_comp_read_sync_bridge_state() -> Dictionary:
	return source_building_serialization_state.generated_read_sync_bridge_state()


func generated_building_comp_version_bridge_state() -> Dictionary:
	return source_building_serialization_state.generated_version_bridge_state()
