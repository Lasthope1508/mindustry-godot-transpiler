extends RefCounted
class_name SourceBuildingCoreState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")

const SOURCE_BUILDING_COMP_GENERATED_CLASS := source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS
const SOURCE_BUILDING_CORE_CHECK_SOLID_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CORE_CHECK_SOLID_JAVA_METHOD
const SOURCE_BUILDING_CORE_CHECK_SOLID_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CORE_CHECK_SOLID_GENERATED_OWNER
const SOURCE_BUILDING_CORE_ABSORB_LASERS_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CORE_ABSORB_LASERS_JAVA_METHOD
const SOURCE_BUILDING_CORE_ABSORB_LASERS_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CORE_ABSORB_LASERS_GENERATED_OWNER
const SOURCE_BUILDING_CORE_IS_INSULATED_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CORE_IS_INSULATED_JAVA_METHOD
const SOURCE_BUILDING_CORE_IS_INSULATED_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CORE_IS_INSULATED_GENERATED_OWNER
const SOURCE_BUILDING_CORE_COLLIDE_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_CORE_COLLIDE_JAVA_METHOD
const SOURCE_BUILDING_CORE_COLLIDE_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_CORE_COLLIDE_GENERATED_OWNER
const SOURCE_BUILDING_POWER_PRODUCTION_JAVA_METHOD := source_building_source_text_state.SOURCE_BUILDING_POWER_PRODUCTION_JAVA_METHOD
const SOURCE_BUILDING_POWER_PRODUCTION_GENERATED_OWNER := source_building_source_text_state.SOURCE_BUILDING_POWER_PRODUCTION_GENERATED_OWNER
const SOURCE_BLOCK_GENERATED_CLASS := source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS
const SOURCE_BLOCK_CAN_REPLACE_METHOD := source_block_source_text_state.SOURCE_BLOCK_CAN_REPLACE_METHOD
const SOURCE_BLOCK_CAN_REPLACE_JAVA_METHOD_CAN_REPLACE_35 := source_block_source_text_state.SOURCE_BLOCK_CAN_REPLACE_JAVA_METHOD_CAN_REPLACE_35
const SOURCE_BLOCK_CAN_REPLACE_GENERATED_OWNER := source_block_source_text_state.SOURCE_BLOCK_CAN_REPLACE_GENERATED_OWNER

static func _building_comp_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BUILDING_COMP_GENERATED_CLASS, generated_method, generated_args, null)

static func _block_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_BLOCK_GENERATED_CLASS, generated_method, generated_args, null)

static func block_can_replace_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> bool:
	if existing_always_replace:
		return true
	if existing_privileged:
		return false
	return existing_replaceable and (not same_block or (new_rotate and new_quick_rotate)) and ((not new_group_is_none and same_group) or same_block) and (new_size == existing_size or (new_size >= existing_size and (same_subclass or group_any_replace)))

static func block_can_replace_result_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> Dictionary:
	var replacement_gate: bool = existing_replaceable and ((not same_block) or (new_rotate and new_quick_rotate)) and (((not new_group_is_none) and same_group) or same_block)
	var size_gate: bool = new_size == existing_size or (new_size >= existing_size and (same_subclass or group_any_replace))
	var can_replace: bool = block_can_replace_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_REPLACE_STATE, "source": "core/src/mindustry/world/Block.java", "method": SOURCE_BLOCK_CAN_REPLACE_METHOD, "always_replace_expr": "if(other.alwaysReplace) return true;", "privileged_expr": "if(other.privileged) return false;", "return_expr": "return other.replaceable && (other != this || (rotate && quickRotate)) && ((this.group != BlockGroup.none && other.group == this.group) || other == this) && (size == other.size || (size >= other.size && ((subclass != null && subclass == other.subclass) || group.anyReplace)));", "otherAlwaysReplace": existing_always_replace, "otherPrivileged": existing_privileged, "otherReplaceable": existing_replaceable, "sameBlock": same_block, "rotate": new_rotate, "quickRotate": new_quick_rotate, "groupIsNone": new_group_is_none, "sameGroup": same_group, "size": new_size, "otherSize": existing_size, "sameSubclass": same_subclass, "groupAnyReplace": group_any_replace, "replacementGate": replacement_gate, "sizeGate": size_gate, "canReplace": can_replace}

static func generated_block_can_replace_bridge_state(existing_always_replace: bool, existing_privileged: bool, existing_replaceable: bool, same_block: bool, new_rotate: bool, new_quick_rotate: bool, new_group_is_none: bool, same_group: bool, new_size: int, existing_size: int, same_subclass: bool, group_any_replace: bool) -> Dictionary:
	var args := [existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace]
	var result = _block_call(SOURCE_BLOCK_CAN_REPLACE_JAVA_METHOD_CAN_REPLACE_35, args)
	var canonical = block_can_replace_result_state(existing_always_replace, existing_privileged, existing_replaceable, same_block, new_rotate, new_quick_rotate, new_group_is_none, same_group, new_size, existing_size, same_subclass, group_any_replace)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BLOCK_CAN_REPLACE_STATE, "generated_owner": SOURCE_BLOCK_CAN_REPLACE_GENERATED_OWNER, "result": result, "canonical": canonical, "matches": matches}

static func building_can_be_replaced_state(other_can_replace_block: bool) -> bool:
	return other_can_replace_block

static func power_production_state() -> Dictionary:
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_PRODUCTION_STATE, "method": "public float getPowerProduction(){", "return_expr": "return 0f;", "default_return": 0.0, "power_production": 0.0}

static func generated_power_production_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_POWER_PRODUCTION_JAVA_METHOD, [])
	var canonical = power_production_state()
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_POWER_PRODUCTION_STATE,
		"generated_owner": SOURCE_BUILDING_POWER_PRODUCTION_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": float(result) == float(canonical.get("power_production", 0.0)),
	}

static func check_solid_state() -> bool:
	return false

static func absorb_lasers_state(block_absorb_lasers: bool) -> bool:
	return block_absorb_lasers

static func is_insulated_state(block_insulated: bool) -> bool:
	return block_insulated

static func collide_state(_other: Variant) -> bool:
	return true

static func generated_check_solid_bridge_state() -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CORE_CHECK_SOLID_JAVA_METHOD, [])
	if result is bool:
		result = {
			"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHECK_SOLID_STATE,
			"method": "public boolean checkSolid(){",
			"checkSolid": result,
		}
	var canonical = {
		"method": "public boolean checkSolid(){",
		"checkSolid": check_solid_state(),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_CHECK_SOLID_STATE,
		"generated_owner": SOURCE_BUILDING_CORE_CHECK_SOLID_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_absorb_lasers_bridge_state(block_absorb_lasers: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CORE_ABSORB_LASERS_JAVA_METHOD, [block_absorb_lasers])
	var canonical = {
		"blockAbsorbLasers": block_absorb_lasers,
		"defaultAbsorbLasers": false,
		"absorbLasers": absorb_lasers_state(block_absorb_lasers),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_ABSORB_LASERS_STATE,
		"generated_owner": SOURCE_BUILDING_CORE_ABSORB_LASERS_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_is_insulated_bridge_state(block_insulated: bool) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CORE_IS_INSULATED_JAVA_METHOD, [block_insulated])
	var canonical = {
		"method": "public boolean isInsulated(){",
		"block_insulated": block_insulated,
		"insulated": is_insulated_state(block_insulated),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_IS_INSULATED_STATE,
		"generated_owner": SOURCE_BUILDING_CORE_IS_INSULATED_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}

static func generated_collide_bridge_state(other: Variant) -> Dictionary:
	var result = _building_comp_call(SOURCE_BUILDING_CORE_COLLIDE_JAVA_METHOD, [other])
	var canonical = {
		"method": "public boolean collide(Bullet other){",
		"other": other,
		"collide": collide_state(other),
	}
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_BUILDING_COLLIDE_STATE,
		"generated_owner": SOURCE_BUILDING_CORE_COLLIDE_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
	}
