extends RefCounted
class_name SourceTurretAmmoManifestState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_turret_source_text_state := preload("res://src/game/SourceTurretSourceTextState.gd")
const SOURCE_TURRET_AMMO_DATA_AMMO_TYPES_FIELD := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_AMMO_TYPES_FIELD
const SOURCE_LIQUID_TURRET_AMMO_DATA_AMMO_TYPES_FIELD := source_turret_source_text_state.SOURCE_LIQUID_TURRET_AMMO_DATA_AMMO_TYPES_FIELD
const SOURCE_TURRET_AMMO_DATA_METHOD := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_METHOD
const SOURCE_TURRET_AMMO_DATA_ORDERED_MAP := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_ORDERED_MAP
const SOURCE_TURRET_AMMO_DATA_OBJECT_MAP := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_OBJECT_MAP
const SOURCE_TURRET_AMMO_DATA_ITEM_COMMENT := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_ITEM_COMMENT
const SOURCE_TURRET_AMMO_DATA_LIQUID_COMMENT := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_LIQUID_COMMENT
const SOURCE_TURRET_AMMO_DATA_DUO_AMMO_CALL := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_DUO_AMMO_CALL
const SOURCE_TURRET_AMMO_DATA_DUO_COPPER_ENTRY := source_turret_source_text_state.SOURCE_TURRET_AMMO_DATA_DUO_COPPER_ENTRY
const SOURCE_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_ITEM_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_ITEM_TURRET_GENERATED_CLASS
const SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS := source_turret_source_text_state.SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS
const SOURCE_TURRET_AMMO_GENERATED_METHOD := source_turret_source_text_state.SOURCE_TURRET_AMMO_GENERATED_METHOD
const SOURCE_TURRET_AMMO_GENERATED_OWNER := source_turret_source_text_state.SOURCE_TURRET_AMMO_GENERATED_OWNER

static func _continuous_liquid_turret_call(generated_method: String, generated_args: Array) -> Variant:
	return source_generated_class_runtime.call_java_method(SOURCE_CONTINUOUS_LIQUID_TURRET_GENERATED_CLASS, generated_method, generated_args, null)

static func _ammo_manifest_state(source_owner: String, field: String, comment: String, method: String, assignment_expr: String, objects: Array) -> Dictionary:
	return {
		"source_owner": source_owner,
		"field": field,
		"comment": comment,
		"method": method,
		"assignment_expr": assignment_expr,
		"objects": objects.duplicate(true),
		"ammo_types_after": objects.duplicate(true),
	}

static func liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return _ammo_manifest_state(source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_AMMO_STATE, SOURCE_LIQUID_TURRET_AMMO_DATA_AMMO_TYPES_FIELD, SOURCE_TURRET_AMMO_DATA_LIQUID_COMMENT, SOURCE_TURRET_AMMO_DATA_METHOD, SOURCE_TURRET_AMMO_DATA_OBJECT_MAP, objects)

static func generated_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_LIQUID_TURRET_GENERATED_CLASS, SOURCE_TURRET_AMMO_GENERATED_METHOD, [objects], null)
	var canonical = liquid_turret_ammo_state(objects)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_LIQUID_TURRET_AMMO_STATE, "generated_owner": "liquid_turret.ammo", "result": result, "canonical": canonical, "matches": matches}

static func item_turret_ammo_state(objects: Array) -> Dictionary:
	return _ammo_manifest_state(source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_AMMO_STATE, SOURCE_TURRET_AMMO_DATA_AMMO_TYPES_FIELD, SOURCE_TURRET_AMMO_DATA_ITEM_COMMENT, SOURCE_TURRET_AMMO_DATA_METHOD, SOURCE_TURRET_AMMO_DATA_ORDERED_MAP, objects)

static func generated_item_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_ITEM_TURRET_GENERATED_CLASS, SOURCE_TURRET_AMMO_GENERATED_METHOD, [objects], null)
	var canonical = item_turret_ammo_state(objects)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_ITEM_TURRET_AMMO_STATE, "generated_owner": "item_turret.ammo", "result": result, "canonical": canonical, "matches": matches}

static func continuous_liquid_turret_ammo_state(objects: Array) -> Dictionary:
	return _ammo_manifest_state(source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_AMMO_STATE, SOURCE_LIQUID_TURRET_AMMO_DATA_AMMO_TYPES_FIELD, SOURCE_TURRET_AMMO_DATA_LIQUID_COMMENT, SOURCE_TURRET_AMMO_DATA_METHOD, SOURCE_TURRET_AMMO_DATA_OBJECT_MAP, objects)

static func generated_continuous_liquid_turret_ammo_bridge_state(objects: Array) -> Dictionary:
	var result = _continuous_liquid_turret_call(SOURCE_TURRET_AMMO_GENERATED_METHOD, [objects])
	var canonical = continuous_liquid_turret_ammo_state(objects)
	var matches: bool = source_generated_class_runtime.generated_state_matches_generated_subset(result, canonical)
	return {"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_CONTINUOUS_LIQUID_TURRET_AMMO_STATE, "generated_owner": "continuous_liquid_turret.ammo", "result": result, "canonical": canonical, "matches": matches}
