extends RefCounted
class_name SourceUnitPayloadDumpGeneratedBridgeState

const source_generated_class_runtime := preload("res://src/game/SourceGeneratedClassRuntime.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")
const source_payload_source_text_state := preload("res://src/game/SourcePayloadSourceTextState.gd")

const SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS := source_payload_source_text_state.SOURCE_UNIT_PAYLOAD_GENERATED_CLASS
const SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD := source_runtime_owner_registry.SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD
const SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER := source_runtime_owner_registry.SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER
const SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "guard_expr", "return_expr"]
const SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner"]
const SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]
const SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_BRIDGE_IGNORED_KEYS := ["source_owner", "returned", "dump", "deferred_remaining_dump", "trns_vec"]

static func generated_type_null_guard_bridge_state(unit_type_null: bool, canonical_type_null_guard: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null], null)
	var canonical: Dictionary = canonical_type_null_guard.call(unit_type_null)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_TYPE_NULL_GUARD_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_can_create_guard_bridge_state(unit_type_null: bool, units_can_create: bool, canonical_can_create_guard: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null, units_can_create], null)
	var canonical: Dictionary = canonical_can_create_guard.call(unit_type_null, units_can_create)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_CAN_CREATE_GUARD_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_solidity_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, canonical_solidity_guard: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid], null)
	var canonical: Dictionary = canonical_solidity_guard.call(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_overlap_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, canonical_overlap_guard: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count], null)
	var canonical: Dictionary = canonical_overlap_guard.call(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_no_client_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, canonical_no_client_guard: Callable) -> Dictionary:
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client], null)
	var canonical: Dictionary = canonical_no_client_guard.call(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_NO_CLIENT_GUARD_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}

static func generated_spawn_side_effects_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant, canonical_no_client_guard: Callable, canonical_spawn_side_effects: Callable) -> Dictionary:
	var state: Dictionary = canonical_no_client_guard.call(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var result = source_generated_class_runtime.call_java_method(SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_CLASS, SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_METHOD, [unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id], null)
	var canonical: Dictionary = canonical_spawn_side_effects.call(state, range_x, range_y, unit_id)
	var matches: bool = source_generated_class_runtime.generated_state_matches_canonical_subset(result, canonical, SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_BRIDGE_IGNORED_KEYS)
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_SOURCE_UNIT_PAYLOAD_DUMP_SPAWN_SIDE_EFFECTS_STATE,
		"generated_owner": SOURCE_UNIT_PAYLOAD_DUMP_GENERATED_OWNER,
		"result": result,
		"canonical": canonical,
		"matches": matches,
	}
