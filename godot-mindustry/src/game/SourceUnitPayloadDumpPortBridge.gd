extends "res://src/game/SourceContinuousLiquidTurretBuildPortBridge.gd"

const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")

func source_unit_payload_dump_type_null_guard_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_dump_state.type_null_guard_state(unit_type_null)

func generated_unit_payload_dump_type_null_guard_bridge_state(unit_type_null: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_type_null_guard_bridge_state(unit_type_null)

func source_unit_payload_dump_can_create_guard_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	return source_unit_payload_dump_state.can_create_guard_state(unit_type_null, units_can_create)

func generated_unit_payload_dump_can_create_guard_bridge_state(unit_type_null: bool, units_can_create: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_can_create_guard_bridge_state(unit_type_null, units_can_create)

func source_unit_payload_dump_solidity_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	return source_unit_payload_dump_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)

func generated_unit_payload_dump_solidity_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_solidity_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)

func source_unit_payload_dump_overlap_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	return source_unit_payload_dump_state.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)

func generated_unit_payload_dump_overlap_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int) -> Dictionary:
	return source_unit_payload_dump_state.generated_overlap_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)

func source_unit_payload_dump_no_client_guard_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	return source_unit_payload_dump_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)

func generated_unit_payload_dump_no_client_guard_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool) -> Dictionary:
	return source_unit_payload_dump_state.generated_no_client_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)

func source_unit_payload_dump_spawn_side_effects_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_dump_state.spawn_side_effects_runtime_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)

func generated_unit_payload_dump_spawn_side_effects_bridge_state(unit_type_null: bool, units_can_create: bool, solid_present: bool, unit_rotation: float, unit_x: float, unit_y: float, solid_solid: bool, unit_type_flying: bool, unit_physic_size: float, units_count: int, net_client: bool, range_x: float, range_y: float, unit_id: Variant) -> Dictionary:
	return source_unit_payload_dump_state.generated_spawn_side_effects_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)
