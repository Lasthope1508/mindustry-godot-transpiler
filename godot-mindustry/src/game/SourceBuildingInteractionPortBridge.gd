extends "res://src/game/SourceBuildingDamagePortBridge.gd"

const source_building_interaction_state := preload("res://src/game/SourceBuildingInteractionState.gd")

func generated_building_comp_is_commandable_bridge_state(block_commandable: bool) -> Dictionary:
	return source_building_interaction_state.generated_is_commandable_bridge_state(block_commandable)

func generated_building_comp_is_payload_bridge_state(tile_is_empty_tile: bool) -> Dictionary:
	return source_building_interaction_state.generated_is_payload_bridge_state(tile_is_empty_tile)

func generated_building_comp_overwrote_bridge_state(previous_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_overwrote_bridge_state(previous_state)

func generated_building_comp_on_removed_bridge_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_on_removed_bridge_state(current_state)

func generated_building_comp_unit_on_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_on_bridge_state(unit_state)

func generated_building_comp_unit_on_any_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_on_any_bridge_state(unit_state)

func generated_building_comp_unit_removed_bridge_state(unit_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_unit_removed_bridge_state(unit_state)

func generated_building_comp_puddle_on_bridge_state(puddle_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_puddle_on_bridge_state(puddle_state)

func generated_building_comp_tapped_bridge_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.generated_tapped_bridge_state(current_state)

func source_building_is_commandable_state(block_commandable: bool) -> bool:
	return source_building_interaction_state.is_commandable_state(block_commandable)

func source_building_is_payload_state(tile_is_empty_tile: bool) -> bool:
	return source_building_interaction_state.is_payload_state(tile_is_empty_tile)

func source_building_overwrote_state(previous_state: Variant) -> Dictionary:
	return source_building_interaction_state.overwrote_state(previous_state)

func source_building_on_removed_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.on_removed_state(current_state)

func source_building_unit_on_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_on_state(unit_state)

func source_building_unit_on_any_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_on_any_state(unit_state)

func source_building_unit_removed_state(unit_state: Variant) -> Variant:
	return source_building_interaction_state.unit_removed_state(unit_state)

func source_building_puddle_on_state(puddle_state: Variant) -> Dictionary:
	return source_building_interaction_state.puddle_on_state(puddle_state)

func source_building_tapped_state(current_state: Variant) -> Dictionary:
	return source_building_interaction_state.tapped_state(current_state)
