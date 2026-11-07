extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const source_unit_payload_dump_guard_state := preload("res://src/game/SourceUnitPayloadDumpGuardState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type_null := false
	var units_can_create := true
	var solid_present := true
	var unit_rotation := 90.0
	var unit_x := 16.0
	var unit_y := 24.0
	var solid_solid := false
	var unit_type_flying := false
	var unit_physic_size := 8.0
	var units_count := 0
	var net_client := false
	var range_x := 0.25
	var range_y := -0.25
	var unit_id := "flare-7"
	var type_null_bridge := game.generated_unit_payload_dump_type_null_guard_bridge_state(true)
	var can_create_bridge := game.generated_unit_payload_dump_can_create_guard_bridge_state(unit_type_null, false)
	var solidity_bridge := game.generated_unit_payload_dump_solidity_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var overlap_bridge := game.generated_unit_payload_dump_overlap_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var no_client_bridge := game.generated_unit_payload_dump_no_client_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var spawn_bridge := game.generated_unit_payload_dump_spawn_side_effects_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)
	var spawn_runtime := source_unit_payload_dump_state.spawn_side_effects_runtime_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id)
	var guard_runtime := source_unit_payload_dump_guard_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_DUMP_MODULE_PROOF",
		"type_null_bridge": type_null_bridge,
		"can_create_bridge": can_create_bridge,
		"solidity_bridge": solidity_bridge,
		"overlap_bridge": overlap_bridge,
		"no_client_bridge": no_client_bridge,
		"spawn_bridge": spawn_bridge,
		"spawn_runtime": spawn_runtime,
		"type_null_bridge_matches": type_null_bridge == source_unit_payload_dump_state.generated_type_null_guard_bridge_state(true),
		"can_create_bridge_matches": can_create_bridge == source_unit_payload_dump_state.generated_can_create_guard_bridge_state(unit_type_null, false),
		"solidity_bridge_matches": solidity_bridge == source_unit_payload_dump_state.generated_solidity_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid),
		"overlap_bridge_matches": overlap_bridge == source_unit_payload_dump_state.generated_overlap_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count),
		"no_client_bridge_matches": no_client_bridge == source_unit_payload_dump_state.generated_no_client_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client),
		"spawn_bridge_matches": spawn_bridge == source_unit_payload_dump_state.generated_spawn_side_effects_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id),
		"spawn_runtime_matches": spawn_runtime == source_unit_payload_dump_state.spawn_side_effects_runtime_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client, range_x, range_y, unit_id),
		"guard_runtime_direct_matches": guard_runtime == source_unit_payload_dump_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(type_null_bridge.get("matches", false)) and bool(can_create_bridge.get("matches", false)) and bool(solidity_bridge.get("matches", false)) and bool(overlap_bridge.get("matches", false)) and bool(no_client_bridge.get("matches", false)) and bool(spawn_bridge.get("matches", false)) and bool(spawn_runtime.get("spawn_evaluated", false)) and proof["type_null_bridge_matches"] and proof["can_create_bridge_matches"] and proof["solidity_bridge_matches"] and proof["overlap_bridge_matches"] and proof["no_client_bridge_matches"] and proof["spawn_bridge_matches"] and proof["spawn_runtime_matches"] and proof["guard_runtime_direct_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitPayloadDumpModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

