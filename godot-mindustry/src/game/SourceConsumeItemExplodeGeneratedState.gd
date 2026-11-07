extends RefCounted
class_name SourceConsumeItemExplodeGeneratedState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_consume_item_explode_state := preload("res://src/game/SourceConsumeItemExplodeState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")

const SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_CLASS := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_CLASS
const SOURCE_CONSUME_ITEM_EXPLODE_JAVA_METHOD_BUILD_1 := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EXPLODE_JAVA_METHOD_BUILD_1
const SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_OWNER := source_consume_source_text_state.SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_OWNER

static func generated_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_CLASS, SOURCE_CONSUME_ITEM_EXPLODE_JAVA_METHOD_BUILD_1, [build, table], null)
	var canonical = source_consume_item_explode_state.build_state(build, table)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLODE_BUILD_STATE, "generated_owner": SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}
