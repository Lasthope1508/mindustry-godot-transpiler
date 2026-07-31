class_name SourceBlockQueryPlacementState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func can_place_on_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_PLACE_ON_STATE, "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be placed on the specified tile. */", "method": "public boolean canPlaceOn(Tile tile, Team team, int rotation){", "return_expr": "return true;", "tile": tile, "team": team, "rotation": rotation_value, "can_place": true}

static func can_break_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BREAK_STATE, "source": "core/src/mindustry/world/Block.java", "comment": "/** @return whether this block can be broken on the specified tile. */", "method": "public boolean canBreak(Tile tile){", "return_expr": "return true;", "tile": tile, "can_break": true}

static func rotated_output_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_STATE, "source": "core/src/mindustry/world/Block.java", "field_comment": "/** whether this is rotatable */", "field_expr": "public boolean rotate;", "method": "public boolean rotatedOutput(int x, int y){", "return_expr": "return rotate;", "rotate": rotate_value, "x": x_value, "y": y_value, "rotated_output": rotate_value}

static func rotated_output_tile_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var base_state := rotated_output_state(rotate_value, from_x, from_y)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_TILE_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean rotatedOutput(int fromX, int fromY, Tile destination){", "delegate_call": "rotatedOutput(fromX, fromY)", "return_expr": "return rotatedOutput(fromX, fromY);", "rotate": rotate_value, "fromX": from_x, "fromY": from_y, "destination": destination, "base_state": base_state, "rotated_output": base_state["rotated_output"]}

static func generated_block_can_place_on_bridge_state(tile: Variant, team: Variant, rotation_value: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_canPlaceOn_18", [tile, team, rotation_value], null)
	var canonical = can_place_on_state(tile, team, rotation_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_PLACE_ON_STATE, "generated_owner": "block.java_method_canPlaceOn_18", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_can_break_bridge_state(tile: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_canBreak_19", [tile], null)
	var canonical = can_break_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BREAK_STATE, "generated_owner": "block.java_method_canBreak_19", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_rotated_output_bridge_state(rotate_value: bool, x_value: int, y_value: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_rotatedOutput_20", [rotate_value, x_value, y_value], null)
	var canonical = rotated_output_state(rotate_value, x_value, y_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_STATE, "generated_owner": "block.java_method_rotatedOutput_20", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_rotated_output_tile_bridge_state(rotate_value: bool, from_x: int, from_y: int, destination: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_rotatedOutput_21", [rotate_value, from_x, from_y, destination], null)
	var canonical = rotated_output_tile_state(rotate_value, from_x, from_y, destination)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ROTATED_OUTPUT_TILE_STATE, "generated_owner": "block.java_method_rotatedOutput_21", "result": result, "canonical": canonical, "matches": matches}
