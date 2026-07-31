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

static func generated_build_bridge_state(build: Variant, table: Variant) -> Dictionary:
	var script = load("res://src/generated/classes/mindustry/world/consumers/ConsumeItemExplode.gd")
	var instance = script.new()
	var result = instance.java_method_build_1([build, table])
	var canonical = build_state(build, table)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONSUME_ITEM_EXPLODE_BUILD_STATE, "generated_owner": "consume_item_explode.build", "result": result, "canonical": canonical, "matches": result.get("empty_body", null) == canonical.get("empty_body", null) and result.get("build", null) == canonical.get("build", null) and result.get("table", null) == canonical.get("table", null)}
