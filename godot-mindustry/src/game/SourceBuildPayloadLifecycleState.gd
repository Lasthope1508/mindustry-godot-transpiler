class_name SourceBuildPayloadLifecycleState
extends RefCounted

const source_build_payload_source_text_state := preload("res://src/game/SourceBuildPayloadSourceTextState.gd")
const source_build_payload_state := preload("res://src/game/SourceBuildPayloadState.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_ROTATION := 0
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR
const SOURCE_BUILD_PAYLOAD_PLACE_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_METHOD
const SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR
const SOURCE_BUILD_PAYLOAD_PLACE_BUILD_SUPPLIER_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_BUILD_SUPPLIER_EXPR
const SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR
const SOURCE_BUILD_PAYLOAD_UPDATE_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_UPDATE_METHOD
const SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR
const SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR
const SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD
const SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR
const SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR
const SOURCE_BUILD_PAYLOAD_REMOVE_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_REMOVE_METHOD
const SOURCE_BUILD_PAYLOAD_REMOVE_EXPR := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_REMOVE_EXPR
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_JAVA_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_PLACE_JAVA_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_UPDATE_JAVA_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_UPDATE_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_DESTROYED_JAVA_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DESTROYED_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_REMOVE_JAVA_METHOD := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_REMOVE_JAVA_METHOD
const SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_GENERATED_OWNER := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_PLACE_GENERATED_OWNER := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_PLACE_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_UPDATE_GENERATED_OWNER := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_UPDATE_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_DESTROYED_GENERATED_OWNER := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_DESTROYED_GENERATED_OWNER
const SOURCE_BUILD_PAYLOAD_REMOVE_GENERATED_OWNER := source_build_payload_source_text_state.SOURCE_BUILD_PAYLOAD_REMOVE_GENERATED_OWNER

static func place_default_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	var rotation_value: int = SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_ROTATION
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "method": SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_METHOD, "delegate_expr": SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_DELEGATE_EXPR, "tile": tile, "build_block": build_block, "build_team": build_team, "delegated_rotation": rotation_value}

static func place_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	var set_block_call: Dictionary = {"call": SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR, "tile": tile, "block": build_block, "team": build_team, "rotation": rotation_value, "build_supplier": SOURCE_BUILD_PAYLOAD_PLACE_BUILD_SUPPLIER_EXPR}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_PLACE_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "method": SOURCE_BUILD_PAYLOAD_PLACE_METHOD, "set_block_expr": SOURCE_BUILD_PAYLOAD_PLACE_SET_BLOCK_EXPR, "dropped_expr": SOURCE_BUILD_PAYLOAD_PLACE_DROPPED_EXPR, "tile": tile, "build_block": build_block, "build_team": build_team, "rotation": rotation_value, "set_block_call": set_block_call, "dropped_called": true}

static func update_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var returned: bool = unit_holder_present and ((not build_block_update_in_units) or ((not unit_payload_update) and (not build_block_always_update_in_units)))
	var tile_after: Variant = null
	var update_payload_called: bool = false
	var update_payload_call: Variant = null
	if not returned:
		tile_after = source_build_payload_state.SOURCE_BUILD_PAYLOAD_EMPTY_TILE_EXPR
		update_payload_called = true
		update_payload_call = {"call": SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unitHolder": unit_holder, "buildingHolder": building_holder}
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_UPDATE_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "import_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_IMPORT_STATIC_VARS_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_UPDATE_METHOD, "guard_expr": SOURCE_BUILD_PAYLOAD_UPDATE_GUARD_EXPR, "tile_assign_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_TILE_EMPTY_ASSIGN_EXPR, "update_payload_expr": SOURCE_BUILD_PAYLOAD_UPDATE_PAYLOAD_EXPR, "unit_holder_present": unit_holder_present, "build_block_update_in_units": build_block_update_in_units, "unit_payload_update": unit_payload_update, "build_block_always_update_in_units": build_block_always_update_in_units, "unitHolder": unit_holder, "buildingHolder": building_holder, "returned": returned, "tile_after": tile_after, "update_payload_called": update_payload_called, "update_payload_call": update_payload_call}

static func destroyed_state() -> Dictionary:
	var dead_after: bool = true
	var on_destroyed_called: bool = true
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DESTROYED_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_DESTROYED_METHOD, "dead_assign_expr": SOURCE_BUILD_PAYLOAD_DESTROYED_DEAD_ASSIGN_EXPR, "on_destroyed_expr": SOURCE_BUILD_PAYLOAD_DESTROYED_ON_DESTROYED_EXPR, "dead_after": dead_after, "on_destroyed_called": on_destroyed_called}

static func remove_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_REMOVE_STATE, "source": source_build_payload_state.SOURCE_BUILD_PAYLOAD_SOURCE, "class_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_CLASS_EXPR, "field_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_BUILD_FIELD_EXPR, "override_expr": source_build_payload_state.SOURCE_BUILD_PAYLOAD_OVERRIDE_EXPR, "method": SOURCE_BUILD_PAYLOAD_REMOVE_METHOD, "remove_expr": SOURCE_BUILD_PAYLOAD_REMOVE_EXPR, "remove_called": true}

static func generated_build_payload_place_default_bridge_state(tile: Variant, build_block: Variant, build_team: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_JAVA_METHOD, [tile, build_block, build_team], null)
	var canonical = place_default_state(tile, build_block, build_team)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_PLACE_DEFAULT_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_place_bridge_state(tile: Variant, build_block: Variant, build_team: Variant, rotation_value: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_PLACE_JAVA_METHOD, [tile, build_block, build_team, rotation_value], null)
	var canonical = place_state(tile, build_block, build_team, rotation_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_PLACE_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_PLACE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_update_bridge_state(unit_holder_present: bool, build_block_update_in_units: bool, unit_payload_update: bool, build_block_always_update_in_units: bool, unit_holder: Variant, building_holder: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_UPDATE_JAVA_METHOD, [unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder], null)
	var canonical = update_state(unit_holder_present, build_block_update_in_units, unit_payload_update, build_block_always_update_in_units, unit_holder, building_holder)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_UPDATE_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_UPDATE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_destroyed_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_DESTROYED_JAVA_METHOD, [], null)
	var canonical = destroyed_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_DESTROYED_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_DESTROYED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_build_payload_remove_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(source_build_payload_state.BUILD_PAYLOAD_GENERATED_CLASS, SOURCE_BUILD_PAYLOAD_REMOVE_JAVA_METHOD, [], null)
	var canonical = remove_state()
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILD_PAYLOAD_REMOVE_STATE, "generated_owner": SOURCE_BUILD_PAYLOAD_REMOVE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
