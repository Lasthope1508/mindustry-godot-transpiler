extends "res://src/game/SourceBuilderRuntimePortBridge.gd"

const source_sync_state := preload("res://src/game/SourceSyncState.gd")

func source_sync_snap_sync_state() -> Dictionary:
	return source_sync_state.snap_sync_state()

func generated_sync_comp_snap_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_snap_sync_bridge_state()

func source_sync_snap_interpolation_state() -> Dictionary:
	return source_sync_state.snap_interpolation_state()

func generated_sync_comp_snap_interpolation_bridge_state() -> Dictionary:
	return source_sync_state.generated_snap_interpolation_bridge_state()

func source_sync_read_sync_state() -> Dictionary:
	return source_sync_state.read_sync_state()

func generated_sync_comp_read_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_read_sync_bridge_state()

func source_sync_write_sync_state() -> Dictionary:
	return source_sync_state.write_sync_state()

func generated_sync_comp_write_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_write_sync_bridge_state()

func source_sync_read_sync_manual_state() -> Dictionary:
	return source_sync_state.read_sync_manual_state()

func generated_sync_comp_read_sync_manual_bridge_state() -> Dictionary:
	return source_sync_state.generated_read_sync_manual_bridge_state()

func source_sync_write_sync_manual_state() -> Dictionary:
	return source_sync_state.write_sync_manual_state()

func generated_sync_comp_write_sync_manual_bridge_state() -> Dictionary:
	return source_sync_state.generated_write_sync_manual_bridge_state()

func source_sync_after_sync_state() -> Dictionary:
	return source_sync_state.after_sync_state()

func generated_sync_comp_after_sync_bridge_state() -> Dictionary:
	return source_sync_state.generated_after_sync_bridge_state()

func source_sync_interpolate_state() -> Dictionary:
	return source_sync_state.interpolate_state()

func generated_sync_comp_interpolate_bridge_state() -> Dictionary:
	return source_sync_state.generated_interpolate_bridge_state()

func source_sync_is_sync_hidden_state(player: Variant = null) -> Dictionary:
	return source_sync_state.is_sync_hidden_state(player)

func generated_sync_comp_is_sync_hidden_bridge_state(player: Variant = null) -> Dictionary:
	return source_sync_state.generated_is_sync_hidden_bridge_state(player)

func source_sync_handle_sync_hidden_state() -> Dictionary:
	return source_sync_state.handle_sync_hidden_state()

func generated_sync_comp_handle_sync_hidden_bridge_state() -> Dictionary:
	return source_sync_state.generated_handle_sync_hidden_bridge_state()

func source_sync_update_interpolate_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return source_sync_state.update_interpolate_state(net_client, is_local, is_remote)

func generated_sync_comp_update_interpolate_bridge_state(net_client: bool, is_local: bool, is_remote: bool) -> Dictionary:
	return source_sync_state.generated_update_interpolate_bridge_state(net_client, is_local, is_remote)

func source_sync_remove_client_removed_entity_state(net_client: bool, entity_id: int) -> Dictionary:
	return source_sync_state.remove_client_removed_entity_state(net_client, entity_id)

func generated_sync_comp_remove_client_removed_entity_bridge_state(net_client: bool, entity_id: int) -> Dictionary:
	return source_sync_state.generated_remove_client_removed_entity_bridge_state(net_client, entity_id)
