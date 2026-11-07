extends RefCounted
class_name SourceBlockPostInitState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_block_post_init_source_text_state := preload("res://src/game/SourceBlockPostInitSourceTextState.gd")

const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_POST_INIT_SOURCE := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SOURCE
const SOURCE_BLOCK_POST_INIT_METHOD := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_METHOD
const SOURCE_BLOCK_POST_INIT_JAVA_METHOD_POST_INIT_122 := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_JAVA_METHOD_POST_INIT_122
const SOURCE_BLOCK_POST_INIT_GENERATED_OWNER := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_GENERATED_OWNER
const SOURCE_BLOCK_POST_INIT_SUPER_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SUPER_EXPR
const SOURCE_BLOCK_POST_INIT_DATABASE_TAG_GUARD_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_DATABASE_TAG_GUARD_EXPR
const SOURCE_BLOCK_POST_INIT_DATABASE_TAG_ASSIGN_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_DATABASE_TAG_ASSIGN_EXPR
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_COMMENT := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_COMMENT
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_AUTO_ASSIGN_GUARD_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_AUTO_ASSIGN_GUARD_EXPR
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_CONTENT_PLANETS_LOOP_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_CONTENT_PLANETS_LOOP_EXPR
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_PLANET_LANDABLE_GUARD_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_PLANET_LANDABLE_GUARD_EXPR
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STRUCTS_CONTAINS_GUARD_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STRUCTS_CONTAINS_GUARD_EXPR
const SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_ADD_EXPR := source_block_post_init_source_text_state.SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_ADD_EXPR

static func _block_call(generated_method: String, generated_args: Array, metadata: Variant = null) -> Variant:
	if metadata == null:
		return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null, metadata)

static func database_tag_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	var database_tag_after: Variant = database_tag_before
	var database_tag_assigned: bool = database_tag_before == null or str(database_tag_before).is_empty()
	if database_tag_assigned:
		database_tag_after = category_name
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_DATABASE_TAG_STATE, "source": SOURCE_BLOCK_POST_INIT_SOURCE, "method": SOURCE_BLOCK_POST_INIT_METHOD, "database_tag_guard_expr": SOURCE_BLOCK_POST_INIT_DATABASE_TAG_GUARD_EXPR, "database_tag_assign_expr": SOURCE_BLOCK_POST_INIT_DATABASE_TAG_ASSIGN_EXPR, "super_post_init_expr": SOURCE_BLOCK_POST_INIT_SUPER_EXPR, "database_tag_before": database_tag_before, "category_name": category_name, "database_tag_after": database_tag_after, "database_tag_assigned": database_tag_assigned}

static func generated_database_tag_bridge_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_POST_INIT_JAVA_METHOD_POST_INIT_122, [database_tag_before, category_name])
	var canonical = database_tag_state(database_tag_before, category_name)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_DATABASE_TAG_STATE,
		"generated_owner": SOURCE_BLOCK_POST_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func shown_planets_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	var shown_planets_after: Array = shown_planets_before.duplicate()
	var auto_assign_guard_passed: bool = requirements.size() > 0 and shown_planets_before.is_empty()
	var evaluated_planets: Array = []
	var landable_planets: Array = []
	var added_planets: Array = []
	var blocked_planets: Array = []
	if auto_assign_guard_passed:
		for planet in content_planets:
			var planet_name: String = str(planet.get("name", ""))
			evaluated_planets.append(planet_name)
			if not bool(planet.get("is_landable", false)):
				continue
			landable_planets.append(planet_name)
			var blocking_requirement_indices: Array = []
			for i in range(requirements.size()):
				var stack: Dictionary = requirements[i]
				var is_on_planets: Array = stack.get("is_on_planets", [])
				if not is_on_planets.has(planet_name):
					blocking_requirement_indices.append(i)
			if blocking_requirement_indices.is_empty():
				shown_planets_after.append(planet_name)
				added_planets.append(planet_name)
			else:
				blocked_planets.append({"planet": planet_name, "blocking_requirement_indices": blocking_requirement_indices})
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STATE, "source": SOURCE_BLOCK_POST_INIT_SOURCE, "method": SOURCE_BLOCK_POST_INIT_METHOD, "shown_planets_comment": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_COMMENT, "auto_assign_guard_expr": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_AUTO_ASSIGN_GUARD_EXPR, "content_planets_loop_expr": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_CONTENT_PLANETS_LOOP_EXPR, "planet_landable_guard_expr": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_PLANET_LANDABLE_GUARD_EXPR, "structs_contains_guard_expr": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STRUCTS_CONTAINS_GUARD_EXPR, "shown_planets_add_expr": SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_ADD_EXPR, "requirements": requirements, "shown_planets_before": shown_planets_before, "content_planets": content_planets, "shown_planets_after": shown_planets_after, "auto_assign_guard_passed": auto_assign_guard_passed, "evaluated_planets": evaluated_planets, "landable_planets": landable_planets, "added_planets": added_planets, "blocked_planets": blocked_planets}

static func generated_shown_planets_bridge_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	var result = _block_call(SOURCE_BLOCK_POST_INIT_JAVA_METHOD_POST_INIT_122, [requirements, shown_planets_before, content_planets])
	var canonical = shown_planets_state(requirements, shown_planets_before, content_planets)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STATE,
		"generated_owner": SOURCE_BLOCK_POST_INIT_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
