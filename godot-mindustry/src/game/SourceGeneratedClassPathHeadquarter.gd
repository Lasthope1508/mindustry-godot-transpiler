extends RefCounted
class_name SourceGeneratedClassPathHeadquarter

const source_ability_source_text_state := preload("res://src/game/SourceAbilitySourceTextState.gd")
const source_attribute_source_text_state := preload("res://src/game/SourceAttributeSourceTextState.gd")
const source_attributes_source_text_state := preload("res://src/game/SourceAttributesSourceTextState.gd")
const source_block_producer_source_text_state := preload("res://src/game/SourceBlockProducerSourceTextState.gd")
const source_block_source_text_state := preload("res://src/game/SourceBlockSourceTextState.gd")
const source_building_source_text_state := preload("res://src/game/SourceBuildingSourceTextState.gd")
const source_consume_base_source_text_state := preload("res://src/game/SourceConsumeBaseSourceTextState.gd")
const source_consume_source_text_state := preload("res://src/game/SourceConsumeSourceTextState.gd")
const source_drill_runtime_source_text_state := preload("res://src/game/SourceDrillRuntimeSourceTextState.gd")
const source_entity_comp_source_text_state := preload("res://src/game/SourceEntityCompSourceTextState.gd")
const source_floor_source_text_state := preload("res://src/game/SourceFloorSourceTextState.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")
const source_power_source_text_state := preload("res://src/game/SourcePowerSourceTextState.gd")
const source_shoot_pattern_source_text_state := preload("res://src/game/SourceShootPatternSourceTextState.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")


static func entries() -> Array:
	return [
		{"owner": "SourceAbilitySourceTextState", "owner_path": "res://src/game/SourceAbilitySourceTextState.gd", "constant": "SOURCE_ABILITY_GENERATED_CLASS", "generated_path": source_ability_source_text_state.SOURCE_ABILITY_GENERATED_CLASS},
		{"owner": "SourceAttributeSourceTextState", "owner_path": "res://src/game/SourceAttributeSourceTextState.gd", "constant": "GENERATED_SCRIPT", "generated_path": source_attribute_source_text_state.GENERATED_SCRIPT},
		{"owner": "SourceAttributesSourceTextState", "owner_path": "res://src/game/SourceAttributesSourceTextState.gd", "constant": "GENERATED_SCRIPT", "generated_path": source_attributes_source_text_state.GENERATED_SCRIPT},
		{"owner": "SourceBlockProducerSourceTextState", "owner_path": "res://src/game/SourceBlockProducerSourceTextState.gd", "constant": "SOURCE_BLOCK_PRODUCER_GENERATED_CLASS", "generated_path": source_block_producer_source_text_state.SOURCE_BLOCK_PRODUCER_GENERATED_CLASS},
		{"owner": "SourceBlockSourceTextState", "owner_path": "res://src/game/SourceBlockSourceTextState.gd", "constant": "SOURCE_BLOCK_GENERATED_CLASS", "generated_path": source_block_source_text_state.SOURCE_BLOCK_GENERATED_CLASS},
		{"owner": "SourceBlockSourceTextState", "owner_path": "res://src/game/SourceBlockSourceTextState.gd", "constant": "SOURCE_BUILD_GENERATED_CLASS", "generated_path": source_block_source_text_state.SOURCE_BUILD_GENERATED_CLASS},
		{"owner": "SourceBlockSourceTextState", "owner_path": "res://src/game/SourceBlockSourceTextState.gd", "constant": "SOURCE_CONSTRUCT_BLOCK_GENERATED_CLASS", "generated_path": source_block_source_text_state.SOURCE_CONSTRUCT_BLOCK_GENERATED_CLASS},
		{"owner": "SourceBuildingSourceTextState", "owner_path": "res://src/game/SourceBuildingSourceTextState.gd", "constant": "SOURCE_BUILDING_COMP_GENERATED_CLASS", "generated_path": source_building_source_text_state.SOURCE_BUILDING_COMP_GENERATED_CLASS},
		{"owner": "SourceConsumeBaseSourceTextState", "owner_path": "res://src/game/SourceConsumeBaseSourceTextState.gd", "constant": "SOURCE_CONSUME_GENERATED_CLASS", "generated_path": source_consume_base_source_text_state.SOURCE_CONSUME_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_POWER_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_POWER_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_POWER_CONDITION_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_POWER_CONDITION_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_POWER_DYNAMIC_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_POWER_DYNAMIC_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_CHARGED_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_CHARGED_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_DYNAMIC_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_EFFICIENCY_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_EXPLODE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_EXPLOSIVE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_EXPLOSIVE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_FILTER_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_FLAMMABLE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_FLAMMABLE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_LIST_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEM_RADIOACTIVE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEM_RADIOACTIVE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_ITEMS_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_ITEMS_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUID_BASE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FILTER_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUID_FLAMMABLE_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUID_FLAMMABLE_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUID_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUID_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_DYNAMIC_GENERATED_CLASS},
		{"owner": "SourceConsumeSourceTextState", "owner_path": "res://src/game/SourceConsumeSourceTextState.gd", "constant": "SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS", "generated_path": source_consume_source_text_state.SOURCE_CONSUME_LIQUIDS_GENERATED_CLASS},
		{"owner": "SourceDrillRuntimeSourceTextState", "owner_path": "res://src/game/SourceDrillRuntimeSourceTextState.gd", "constant": "SOURCE_DRILL_GENERATED_CLASS", "generated_path": source_drill_runtime_source_text_state.SOURCE_DRILL_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_SYNC_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_SYNC_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_POS_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_POS_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_SHIELDER_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_SHIELDER_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_BLOCK_UNIT_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_BLOCK_UNIT_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_BUILDER_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_BUILDER_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_CHILD_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_CHILD_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_UNIT_TETHER_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_UNIT_TETHER_COMP_GENERATED_CLASS},
		{"owner": "SourceEntityCompSourceTextState", "owner_path": "res://src/game/SourceEntityCompSourceTextState.gd", "constant": "SOURCE_BUILDING_TETHER_COMP_GENERATED_CLASS", "generated_path": source_entity_comp_source_text_state.SOURCE_BUILDING_TETHER_COMP_GENERATED_CLASS},
		{"owner": "SourceFloorSourceTextState", "owner_path": "res://src/game/SourceFloorSourceTextState.gd", "constant": "GENERATED_SCRIPT", "generated_path": source_floor_source_text_state.GENERATED_SCRIPT},
		{"owner": "SourcePayloadSourceTextState", "owner_path": "res://src/game/SourcePayloadSourceTextState.gd", "constant": "SOURCE_BUILD_PAYLOAD_GENERATED_CLASS", "generated_path": source_payload_source_text_state.SOURCE_BUILD_PAYLOAD_GENERATED_CLASS},
		{"owner": "SourcePayloadSourceTextState", "owner_path": "res://src/game/SourcePayloadSourceTextState.gd", "constant": "SOURCE_UNIT_PAYLOAD_GENERATED_CLASS", "generated_path": source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS},
		{"owner": "SourcePowerSourceTextState", "owner_path": "res://src/game/SourcePowerSourceTextState.gd", "constant": "SOURCE_POWER_GENERATOR_GENERATED_CLASS", "generated_path": source_power_source_text_state.SOURCE_POWER_GENERATOR_GENERATED_CLASS},
		{"owner": "SourcePowerSourceTextState", "owner_path": "res://src/game/SourcePowerSourceTextState.gd", "constant": "SOURCE_POWER_GRAPH_GENERATED_CLASS", "generated_path": source_power_source_text_state.SOURCE_POWER_GRAPH_GENERATED_CLASS},
		{"owner": "SourceShootPatternSourceTextState", "owner_path": "res://src/game/SourceShootPatternSourceTextState.gd", "constant": "SOURCE_SHOOT_PATTERN_GENERATED_CLASS", "generated_path": source_shoot_pattern_source_text_state.SOURCE_SHOOT_PATTERN_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_BASE_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_BASE_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_LIQUID_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_LIQUID_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_ITEM_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_TRACTOR_BEAM_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_POWER_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_POWER_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_RELOAD_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_RELOAD_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_POINT_DEFENSE_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_POINT_DEFENSE_TURRET_GENERATED_CLASS},
		{"owner": "SourceTurretSourceTextState", "owner_path": "res://src/game/SourceTurretSourceTextState.gd", "constant": "SOURCE_CONTINUOUS_TURRET_GENERATED_CLASS", "generated_path": source_turret_source_text_state.SOURCE_CONTINUOUS_TURRET_GENERATED_CLASS},
		{"owner": "SourceUnitUpdateSourceTextState", "owner_path": "res://src/game/SourceUnitUpdateSourceTextState.gd", "constant": "SOURCE_UNIT_COMP_GENERATED_CLASS", "generated_path": source_unit_update_source_text_state.SOURCE_UNIT_COMP_GENERATED_CLASS},
	]


static func registry_state() -> Dictionary:
	var registered_entries := entries()
	var generated_paths := {}
	var owner_constants := {}
	var owner_paths := {}
	var duplicate_generated_paths: Array = []
	var duplicate_owner_constants: Array = []
	for entry in registered_entries:
		var generated_path := str(entry.get("generated_path", ""))
		var owner_path := str(entry.get("owner_path", ""))
		var constant := str(entry.get("constant", ""))
		var owner_constant_key := owner_path + "::" + constant
		owner_paths[owner_path] = true
		if generated_paths.has(generated_path):
			duplicate_generated_paths.append({"generated_path": generated_path, "first": generated_paths[generated_path], "duplicate": entry})
		else:
			generated_paths[generated_path] = entry
		if owner_constants.has(owner_constant_key):
			duplicate_owner_constants.append({"owner_constant": owner_constant_key, "first": owner_constants[owner_constant_key], "duplicate": entry})
		else:
			owner_constants[owner_constant_key] = entry
	return {
		"valid": duplicate_generated_paths.is_empty() and duplicate_owner_constants.is_empty(),
		"entry_count": registered_entries.size(),
		"owner_count": owner_paths.size(),
		"generated_path_count": generated_paths.size(),
		"owner_constant_count": owner_constants.size(),
		"duplicate_generated_paths": duplicate_generated_paths,
		"duplicate_owner_constants": duplicate_owner_constants,
	}


static func lookup_by_generated_path(generated_path: String) -> Dictionary:
	for entry in entries():
		if str(entry.get("generated_path", "")) == generated_path:
			return entry.duplicate(true)
	return {}


static func lookup_by_constant(constant_name: String) -> Dictionary:
	for entry in entries():
		if str(entry.get("constant", "")) == constant_name:
			return entry.duplicate(true)
	return {}
