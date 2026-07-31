class_name SourceBlockQueryDarknessState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func synthetic_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var synthetic_value: bool = update_value or destructible_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SYNTHETIC_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean synthetic(){", "return_expr": "return update || destructible;", "update": update_value, "destructible": destructible_value, "synthetic": synthetic_value}

static func check_force_dark_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_FORCE_DARK_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean checkForceDark(Tile tile){", "return_expr": "return forceDark;", "force_dark": force_dark_value, "tile": tile, "check_force_dark": force_dark_value}

static func is_darkened_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var synthetic_state_result := synthetic_state(update_value, destructible_value)
	var check_force_dark_state_result := check_force_dark_state(force_dark_value, tile)
	var is_darkened_value: bool = solid_value and ((not bool(synthetic_state_result["synthetic"]) and fills_tile_value) or bool(check_force_dark_state_result["check_force_dark"]))
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_DARKENED_STATE, "source": "core/src/mindustry/world/Block.java", "comment": "/** If true, the 'map edge' darkness will be applied to this block. */", "method": "public boolean isDarkened(Tile tile){", "return_expr": "return solid && ((!synthetic() && fillsTile) || checkForceDark(tile));", "solid": solid_value, "fillsTile": fills_tile_value, "synthetic_state": synthetic_state_result, "check_force_dark_state": check_force_dark_state_result, "tile": tile, "is_darkened": is_darkened_value}

static func generated_block_synthetic_bridge_state(update_value: bool, destructible_value: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_synthetic_22", [update_value, destructible_value], null)
	var canonical = synthetic_state(update_value, destructible_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_SYNTHETIC_STATE, "generated_owner": "block.java_method_synthetic_22", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_check_force_dark_bridge_state(force_dark_value: bool, tile: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_checkForceDark_23", [force_dark_value, tile], null)
	var canonical = check_force_dark_state(force_dark_value, tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHECK_FORCE_DARK_STATE, "generated_owner": "block.java_method_checkForceDark_23", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_is_darkened_bridge_state(solid_value: bool, update_value: bool, destructible_value: bool, fills_tile_value: bool, force_dark_value: bool, tile: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_isDarkened_24", [solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile], null)
	var canonical = is_darkened_state(solid_value, update_value, destructible_value, fills_tile_value, force_dark_value, tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_DARKENED_STATE, "generated_owner": "block.java_method_isDarkened_24", "result": result, "canonical": canonical, "matches": matches}
