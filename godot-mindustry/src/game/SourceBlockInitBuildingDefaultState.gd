extends RefCounted
class_name SourceBlockInitBuildingDefaultState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func building_default_state(build_type_before: Variant) -> Dictionary:
	var default_assigned: bool = build_type_before == null
	var build_type_after: Variant = "Building::create" if default_assigned else build_type_before
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILDING_DEFAULT_STATE, "source": "core/src/mindustry/world/Block.java", "method": "protected void initBuilding(){", "default_guard_expr": "if(buildType == null){", "default_comment": "//assign default value", "default_assignment_expr": "buildType = Building::create;", "build_type_before": build_type_before, "build_type_after": build_type_after, "default_assigned": default_assigned}

static func generated_block_init_building_default_bridge_state(build_type_before: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_initBuilding_117", [build_type_before], null)
	var canonical = building_default_state(build_type_before)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_INIT_BUILDING_DEFAULT_STATE, "generated_owner": "block.java_method_initBuilding_117", "result": result, "canonical": canonical, "matches": matches}
