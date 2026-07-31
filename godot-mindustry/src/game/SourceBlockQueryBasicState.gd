class_name SourceBlockQueryBasicState
extends RefCounted

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")

static func has_building_state(destructible_value: bool, update_value: bool) -> Dictionary:
	var has_building_value: bool = destructible_value or update_value
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_HAS_BUILDING_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean hasBuilding(){", "return_expr": "return destructible || update;", "destructible": destructible_value, "update": update_value, "has_building": has_building_value}

static func is_multiblock_state(size_value: int) -> Dictionary:
	var is_multiblock_value: bool = size_value > 1
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_MULTIBLOCK_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean isMultiblock(){", "return_expr": "return size > 1;", "size": size_value, "is_multiblock": is_multiblock_value}

static func is_air_state(id_value: int) -> Dictionary:
	var is_air_value: bool = id_value == 0
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_AIR_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean isAir(){", "return_expr": "return id == 0;", "id": id_value, "is_air": is_air_value}

static func can_be_built_state(build_visibility_value: String) -> Dictionary:
	var can_be_built_value: bool = build_visibility_value != "hidden" and build_visibility_value != "debugOnly"
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BE_BUILT_STATE, "source": "core/src/mindustry/world/Block.java", "method": "public boolean canBeBuilt(){", "return_expr": "return buildVisibility != BuildVisibility.hidden && buildVisibility != BuildVisibility.debugOnly;", "buildVisibility": build_visibility_value, "hidden_constant": "BuildVisibility.hidden", "debug_only_constant": "BuildVisibility.debugOnly", "can_be_built": can_be_built_value}

static func is_static_state(cache_layer_value: String) -> Dictionary:
	var is_static_value: bool = cache_layer_value == "walls"
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_STATIC_STATE, "source": "core/src/mindustry/world/Block.java", "cache_layer_source": "core/src/mindustry/graphics/CacheLayer.java", "method": "public boolean isStatic(){", "return_expr": "return cacheLayer == CacheLayer.walls;", "cacheLayer": cache_layer_value, "walls_constant": "CacheLayer.walls", "is_static": is_static_value}

static func generated_block_has_building_bridge_state(destructible_value: bool, update_value: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_hasBuilding_70", [destructible_value, update_value], null)
	var canonical = has_building_state(destructible_value, update_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_HAS_BUILDING_STATE, "generated_owner": "block.java_method_hasBuilding_70", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_is_multiblock_bridge_state(size_value: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_isMultiblock_74", [size_value], null)
	var canonical = is_multiblock_state(size_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_MULTIBLOCK_STATE, "generated_owner": "block.java_method_isMultiblock_74", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_is_air_bridge_state(id_value: int) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_isAir_91", [id_value], null)
	var canonical = is_air_state(id_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_AIR_STATE, "generated_owner": "block.java_method_isAir_91", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_can_be_built_bridge_state(build_visibility_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_canBeBuilt_92", [build_visibility_value], null)
	var canonical = can_be_built_state(build_visibility_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_BE_BUILT_STATE, "generated_owner": "block.java_method_canBeBuilt_92", "result": result, "canonical": canonical, "matches": matches}

static func generated_block_is_static_bridge_state(cache_layer_value: String) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/world/Block.gd", "java_method_isStatic_94", [cache_layer_value], null)
	var canonical = is_static_state(cache_layer_value)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_IS_STATIC_STATE, "generated_owner": "block.java_method_isStatic_94", "result": result, "canonical": canonical, "matches": matches}
