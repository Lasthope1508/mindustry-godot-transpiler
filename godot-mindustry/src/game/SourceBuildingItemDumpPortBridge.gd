extends "res://src/game/SourceBuildingConfigurePortBridge.gd"

const source_building_item_dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")

func source_building_can_dump_item_default_state(to_state: Variant, item: Variant) -> Dictionary:
	return source_building_item_dump_state.can_dump_item_default_state(to_state, item)

func source_building_put_item_state(item: Variant, proximity_size: int, dump_cursor: int, accepts_item_by_index: Array, can_dump_by_index: Array) -> Dictionary:
	return source_building_item_dump_state.game_put_item_state(self, item, proximity_size, dump_cursor, accepts_item_by_index, can_dump_by_index)

func source_building_produced_item_default_state(item: Variant) -> Dictionary:
	return source_building_item_dump_state.produced_item_default_state(item)

func source_building_produced_item_amount_state(item: Variant, amount: int, sector_present: bool, team_is_default_team: bool, net_client: bool) -> Dictionary:
	return source_building_item_dump_state.produced_item_amount_state(item, amount, sector_present, team_is_default_team, net_client)

func source_increment_dump_cursor(current_dump: int, proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_state(current_dump, proximity_size)

func increment_drill_dump(proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_runtime_state(self, proximity_size)

static func increment_drill_dump_game(game, proximity_size: int) -> int:
	return source_building_item_dump_state.increment_dump_cursor_runtime_state(game, proximity_size)

func source_building_dump_accumulate_default_state() -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_default_state()

func source_building_dump_default_state() -> Dictionary:
	return source_building_item_dump_state.dump_default_state()

func source_building_dump_null_item_scan_state(item_ids: Array, item_present_by_index: Array) -> Dictionary:
	return source_building_item_dump_state.dump_null_item_scan_state(item_ids, item_present_by_index)

func source_building_dump_null_proximity_scan_state(proximity_size: int, dump_cursor: int) -> Dictionary:
	return source_building_item_dump_state.game_dump_null_proximity_scan_state(self, proximity_size, dump_cursor)

func source_building_dump_null_remove_item_state(item: Variant, item_amount_before: int) -> Dictionary:
	return source_building_item_dump_state.dump_null_remove_item_state(item, item_amount_before)

func source_building_dump_null_success_handoff_state(item: Variant, accepts_item: bool, can_dump: bool) -> Dictionary:
	return source_building_item_dump_state.dump_null_success_handoff_state(item, accepts_item, can_dump)

func source_building_dump_specific_proximity_scan_state(todump: Variant, proximity_size: int, dump_cursor: int) -> Dictionary:
	return source_building_item_dump_state.dump_specific_proximity_scan_state(todump, proximity_size, dump_cursor)

func source_building_dump_terminal_failure_state() -> Dictionary:
	return source_building_item_dump_state.dump_terminal_failure_state()


func source_dump_accumulate_attempt_state(current_accum: float, source_delta: float) -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_state(current_accum, source_delta)

func step_building_dump_accum(source_delta: float) -> Dictionary:
	return source_building_item_dump_state.dump_accumulate_runtime_state(self, source_delta)
