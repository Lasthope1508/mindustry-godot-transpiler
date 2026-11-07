extends RefCounted
class_name SourceConsumeItemExplodeState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func build_state(build: Variant, table: Variant) -> Dictionary:
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLODE_BUILD_STATE,
		"empty_body": true,
		"build": build,
		"table": table,
	}
