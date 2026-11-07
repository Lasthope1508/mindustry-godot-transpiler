extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const source_unit_payload_dump_guard_state := preload("res://src/game/SourceUnitPayloadDumpGuardState.gd")
const source_unit_payload_dump_overlap_guard_state := preload("res://src/game/SourceUnitPayloadDumpOverlapGuardState.gd")

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
	var overlap_wrapper := game.source_unit_payload_dump_overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var overlap_facade := source_unit_payload_dump_state.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var overlap_guard_facade := source_unit_payload_dump_guard_state.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var overlap_module := source_unit_payload_dump_overlap_guard_state.overlap_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var no_client_wrapper := game.source_unit_payload_dump_no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var no_client_facade := source_unit_payload_dump_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var no_client_guard_facade := source_unit_payload_dump_guard_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var no_client_module := source_unit_payload_dump_overlap_guard_state.no_client_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var generated_overlap_bridge := source_unit_payload_dump_state.generated_overlap_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count)
	var generated_no_client_bridge := source_unit_payload_dump_state.generated_no_client_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid, unit_type_flying, unit_physic_size, units_count, net_client)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_DUMP_OVERLAP_GUARD_MODULE_PROOF",
		"overlap_matches": overlap_wrapper == overlap_facade and overlap_wrapper == overlap_guard_facade and overlap_wrapper == overlap_module,
		"no_client_matches": no_client_wrapper == no_client_facade and no_client_wrapper == no_client_guard_facade and no_client_wrapper == no_client_module,
		"generated_overlap_bridge_matches": bool(generated_overlap_bridge.get("matches", false)),
		"generated_no_client_bridge_matches": bool(generated_no_client_bridge.get("matches", false)),
		"overlap_owner_matches": overlap_module.get("source_owner", "") == "port_game.source_unit_payload_dump_overlap_guard_state",
		"no_client_owner_matches": no_client_module.get("source_owner", "") == "port_game.source_unit_payload_dump_no_client_guard_state",
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["overlap_matches"] and proof["no_client_matches"] and proof["generated_overlap_bridge_matches"] and proof["generated_no_client_bridge_matches"] and proof["overlap_owner_matches"] and proof["no_client_owner_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitPayloadDumpOverlapGuardModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

