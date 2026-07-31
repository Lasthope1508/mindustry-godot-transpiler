extends RefCounted
class_name SourceBuildingCoreState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	if existing_always_replace:
		return true
	if existing_privileged:
		return false
	return existing_replaceable and (not same_block or (new_rotate and new_quick_rotate)) and ((not new_group_is_none and same_group) or same_block) and (new_size == existing_size or (new_size >= existing_size and (same_subclass or group_any_replace)))

static func building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return other_can_replace_block

static func should_consume_state(enabled_state: bool) -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_SHOULD_CONSUME_STATE, "method": "public boolean shouldConsume(){", "return_expr": "return enabled;", "enabled_state": enabled_state, "should_consume": enabled_state}

static func production_valid_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_PRODUCTION_VALID_STATE, "method": "public boolean productionValid(){", "return_expr": "return true;", "production_valid": true}

static func consume_trigger_valid_state() -> bool:
	return true

static func power_production_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_PRODUCTION_STATE, "method": "public float getPowerProduction(){", "return_expr": "return 0f;", "power_production": 0.0}

static func check_solid_state() -> bool:
	return false

static func absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return block_absorb_lasers

static func is_insulated_state(block_insulated: bool) -> bool:
	return block_insulated

static func collide_state(_other: Variant) -> bool:
	return true

static func generated_check_solid_bridge_state() -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_checkSolid_172", [], null)
	var canonical = {
		"method": "public boolean checkSolid(){",
		"checkSolid": check_solid_state(),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHECK_SOLID_STATE,
		"generated_owner": "building_comp.java_method_checkSolid_172",
		"result": result,
		"canonical": canonical,
	}

static func generated_absorb_lasers_bridge_state(block_absorb_lasers: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_absorbLasers_174", [block_absorb_lasers], null)
	var canonical = {
		"blockAbsorbLasers": block_absorb_lasers,
		"defaultAbsorbLasers": false,
		"absorbLasers": absorb_lasers_state(block_absorb_lasers),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ABSORB_LASERS_STATE,
		"generated_owner": "building_comp.java_method_absorbLasers_174",
		"result": result,
		"canonical": canonical,
	}

static func generated_is_insulated_bridge_state(block_insulated: bool) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_isInsulated_175", [block_insulated], null)
	var canonical = {
		"method": "public boolean isInsulated(){",
		"block_insulated": block_insulated,
		"insulated": is_insulated_state(block_insulated),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_INSULATED_STATE,
		"generated_owner": "building_comp.java_method_isInsulated_175",
		"result": result,
		"canonical": canonical,
	}

static func generated_collide_bridge_state(other: Variant) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method("res://src/generated/classes/mindustry/entities/comp/BuildingComp.gd", "java_method_collide_176", [other], null)
	var canonical = {
		"method": "public boolean collide(Bullet other){",
		"other": other,
		"collide": collide_state(other),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_COLLIDE_STATE,
		"generated_owner": "building_comp.java_method_collide_176",
		"result": result,
		"canonical": canonical,
	}
