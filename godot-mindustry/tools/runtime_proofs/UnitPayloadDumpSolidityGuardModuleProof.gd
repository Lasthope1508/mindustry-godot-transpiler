extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_payload_dump_state := preload("res://src/game/SourceUnitPayloadDumpState.gd")
const source_unit_payload_dump_guard_state := preload("res://src/game/SourceUnitPayloadDumpGuardState.gd")
const source_unit_payload_dump_solidity_guard_state := preload("res://src/game/SourceUnitPayloadDumpSolidityGuardState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type_null := false
	var units_can_create := true
	var solid_present := true
	var unit_rotation := 90.0
	var unit_x := 16.0
	var unit_y := 24.0
	var solid_solid := false
	var trns_guard := source_unit_payload_dump_guard_state.trns_vec_state(unit_rotation, source_unit_payload_dump_solidity_guard_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD, 0.0)
	var trns_module := source_unit_payload_dump_solidity_guard_state.trns_vec_state(unit_rotation, source_unit_payload_dump_solidity_guard_state.SOURCE_UNIT_PAYLOAD_DUMP_SOLID_LOOKAHEAD, 0.0)
	var wrapper := game.source_unit_payload_dump_solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var facade := source_unit_payload_dump_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var guard_facade := source_unit_payload_dump_guard_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var module := source_unit_payload_dump_solidity_guard_state.solidity_guard_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var generated_bridge := source_unit_payload_dump_state.generated_solidity_guard_bridge_state(unit_type_null, units_can_create, solid_present, unit_rotation, unit_x, unit_y, solid_solid)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_DUMP_SOLIDITY_GUARD_MODULE_PROOF",
		"trns_vec_matches": trns_guard == trns_module,
		"solidity_matches": wrapper == facade and wrapper == guard_facade and wrapper == module,
		"generated_bridge_matches": bool(generated_bridge.get("matches", false)),
		"tile_lookahead_matches": int(module.get("tx", -1)) == int(generated_bridge.get("canonical", {}).get("tx", -2)) and int(module.get("ty", -1)) == int(generated_bridge.get("canonical", {}).get("ty", -2)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["trns_vec_matches"] and proof["solidity_matches"] and proof["generated_bridge_matches"] and proof["tile_lookahead_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitPayloadDumpSolidityGuardModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

