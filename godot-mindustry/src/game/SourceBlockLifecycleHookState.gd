extends RefCounted
class_name SourceBlockLifecycleHookState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_lifecycle_hook_source_text_state := preload("res://src/game/SourceBlockLifecycleHookSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE

const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_RETURN_EXPR := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_RETURN_EXPR
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_DELEGATE_EXPR := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_DELEGATE_EXPR
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_GENERATED_OWNER
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_COMMENT := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_COMMENT
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_JAVA_METHOD := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_JAVA_METHOD
const SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_GENERATED_OWNER := source_block_lifecycle_hook_source_text_state.SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_GENERATED_OWNER

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func build_editor_config_state(table: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BUILD_EDITOR_CONFIG_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_METHOD, "table": table, "noop": true}

static func on_picked_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ON_PICKED_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_METHOD, "tile": tile, "noop": true}

static func get_config_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_CONFIG_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_METHOD, "return_expr": SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_RETURN_EXPR, "tile": tile, "config": null}

static func block_changed_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHANGED_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_METHOD, "tile": tile, "noop": true}

static func place_began_state(tile: Variant, previous: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_BEGAN_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_METHOD, "tile": tile, "previous": previous, "noop": true}

static func place_began_builder_state(tile: Variant, previous: Variant, builder: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_BEGAN_BUILDER_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_METHOD, "delegate_call": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_DELEGATE_EXPR, "tile": tile, "previous": previous, "builder": builder, "delegates_to_two_arg": true}

static func place_ended_state(tile: Variant, builder: Variant, rotation_value: int, config: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_ENDED_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_METHOD, "tile": tile, "builder": builder, "rotation": rotation_value, "config": config, "noop": true}

static func before_place_began_state(tile: Variant, previous: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BEFORE_PLACE_BEGAN_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_METHOD, "tile": tile, "previous": previous, "noop": true}

static func editor_picked_state(tile: Variant) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_EDITOR_PICKED_STATE, "source": SOURCE_BLOCK_LIFECYCLE_HOOK_SOURCE, "comment": SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_COMMENT, "method": SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_METHOD, "tile": tile, "noop": true}

static func generated_block_build_editor_config_bridge_state(table: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_JAVA_METHOD, [table])
	var canonical = build_editor_config_state(table)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BUILD_EDITOR_CONFIG_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_BUILD_EDITOR_CONFIG_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_on_picked_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_JAVA_METHOD, [tile])
	var canonical = on_picked_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_ON_PICKED_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_ON_PICKED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_get_config_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_JAVA_METHOD, [tile])
	var canonical = get_config_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_GET_CONFIG_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_GET_CONFIG_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_changed_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_JAVA_METHOD, [tile])
	var canonical = block_changed_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CHANGED_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_BLOCK_CHANGED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_place_began_bridge_state(tile: Variant, previous: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_JAVA_METHOD, [tile, previous])
	var canonical = place_began_state(tile, previous)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_BEGAN_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_place_began_builder_bridge_state(tile: Variant, previous: Variant, builder: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_JAVA_METHOD, [tile, previous, builder])
	var canonical = place_began_builder_state(tile, previous, builder)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_BEGAN_BUILDER_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_BEGAN_BUILDER_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_place_ended_bridge_state(tile: Variant, builder: Variant, rotation_value: int, config: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_JAVA_METHOD, [tile, builder, rotation_value, config])
	var canonical = place_ended_state(tile, builder, rotation_value, config)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_PLACE_ENDED_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_PLACE_ENDED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_before_place_began_bridge_state(tile: Variant, previous: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_JAVA_METHOD, [tile, previous])
	var canonical = before_place_began_state(tile, previous)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_BEFORE_PLACE_BEGAN_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_BEFORE_PLACE_BEGAN_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func generated_block_editor_picked_bridge_state(tile: Variant) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_JAVA_METHOD, [tile])
	var canonical = editor_picked_state(tile)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_EDITOR_PICKED_STATE, "generated_owner": SOURCE_BLOCK_LIFECYCLE_HOOK_EDITOR_PICKED_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
