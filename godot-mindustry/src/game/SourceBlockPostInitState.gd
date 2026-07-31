extends RefCounted
class_name SourceBlockPostInitState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func database_tag_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	var database_tag_after: Variant = database_tag_before
	var database_tag_assigned: bool = database_tag_before == null or str(database_tag_before).is_empty()
	if database_tag_assigned:
		database_tag_after = category_name
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_DATABASE_TAG_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "database_tag_guard_expr": "if(databaseTag == null || databaseTag.isEmpty()){", "database_tag_assign_expr": "databaseTag = category.name();", "super_post_init_expr": "super.postInit();", "database_tag_before": database_tag_before, "category_name": category_name, "database_tag_after": database_tag_after, "database_tag_assigned": database_tag_assigned}

static func generated_database_tag_bridge_state(database_tag_before: Variant, category_name: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_postInit_122", [database_tag_before, category_name], null)
	var canonical = database_tag_state(database_tag_before, category_name)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_DATABASE_TAG_STATE,
		"generated_owner": "block.java_method_postInit_122",
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
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public void postInit(){", "shown_planets_comment": "//usually, an empty set of planets is a configuration error. auto-assign based on requirements", "auto_assign_guard_expr": "if(requirements.length > 0 && shownPlanets.isEmpty()){", "content_planets_loop_expr": "for(Planet planet : content.planets()){", "planet_landable_guard_expr": "if(planet.isLandable()){", "structs_contains_guard_expr": "if(!Structs.contains(requirements, s -> !s.item.isOnPlanet(planet))){", "shown_planets_add_expr": "shownPlanets.add(planet);", "requirements": requirements, "shown_planets_before": shown_planets_before, "content_planets": content_planets, "shown_planets_after": shown_planets_after, "auto_assign_guard_passed": auto_assign_guard_passed, "evaluated_planets": evaluated_planets, "landable_planets": landable_planets, "added_planets": added_planets, "blocked_planets": blocked_planets}

static func generated_shown_planets_bridge_state(requirements: Array, shown_planets_before: Array, content_planets: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_postInit_122", [requirements, shown_planets_before, content_planets], null)
	var canonical = shown_planets_state(requirements, shown_planets_before, content_planets)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_POST_INIT_SHOWN_PLANETS_STATE,
		"generated_owner": "block.java_method_postInit_122",
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
