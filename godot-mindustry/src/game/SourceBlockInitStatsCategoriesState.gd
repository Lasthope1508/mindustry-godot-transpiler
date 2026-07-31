extends RefCounted
class_name SourceBlockInitStatsCategoriesState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func stats_categories_state(stats_use_categories_before: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_STATS_CATEGORIES_STATE, "source": "core/src/mindustry/world/Block.java", "stats_source": "core/src/mindustry/world/meta/Stats.java", "method": "public void init(){", "super_init_expr": "super.init();", "stats_use_categories_expr": "stats.useCategories = true;", "stats_use_categories_field_expr": "public boolean useCategories = false;", "stats_use_categories_before": stats_use_categories_before, "stats_use_categories_after": true}

static func generated_block_init_stats_categories_bridge_state(stats_use_categories_before: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_init_123", [stats_use_categories_before], null, {"mindustry_init_bridge_mode": "stats_categories"})
	var canonical = stats_categories_state(stats_use_categories_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_STATS_CATEGORIES_STATE, "generated_owner": "block.java_method_init_123", "result": result, "canonical": canonical, "matches": matches}
