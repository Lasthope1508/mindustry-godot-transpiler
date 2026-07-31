extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_unit_payload_io_state := preload("res://src/game/SourceUnitPayloadIoState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var payload_unit := 12
	var unit_class_id := 34
	var x := 6.5
	var y := 9.25
	var rotation_value := 45.0
	var unit_x := 101.0
	var unit_y := 202.0
	var unit_rotation := 315.0
	var unit_hit_size := 8.0
	var write_bridge := game.generated_unit_payload_write_bridge_state(payload_unit, unit_class_id)
	var set_bridge := game.generated_unit_payload_set_bridge_state(x, y, rotation_value)
	var x_bridge := game.generated_unit_payload_x_bridge_state(unit_x)
	var y_bridge := game.generated_unit_payload_y_bridge_state(unit_y)
	var rotation_bridge := game.generated_unit_payload_rotation_bridge_state(unit_rotation)
	var size_bridge := game.generated_unit_payload_size_bridge_state(unit_hit_size)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_IO_MODULE_PROOF",
		"write_bridge": write_bridge,
		"set_bridge": set_bridge,
		"x_bridge": x_bridge,
		"y_bridge": y_bridge,
		"rotation_bridge": rotation_bridge,
		"size_bridge": size_bridge,
		"write_bridge_matches": write_bridge == source_unit_payload_io_state.generated_write_bridge_state(payload_unit, unit_class_id),
		"set_bridge_matches": set_bridge == source_unit_payload_io_state.generated_set_bridge_state(x, y, rotation_value),
		"x_bridge_matches": x_bridge == source_unit_payload_io_state.generated_x_bridge_state(unit_x),
		"y_bridge_matches": y_bridge == source_unit_payload_io_state.generated_y_bridge_state(unit_y),
		"rotation_bridge_matches": rotation_bridge == source_unit_payload_io_state.generated_rotation_bridge_state(unit_rotation),
		"size_bridge_matches": size_bridge == source_unit_payload_io_state.generated_size_bridge_state(unit_hit_size),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(write_bridge.get("matches", false)) and bool(set_bridge.get("matches", false)) and bool(x_bridge.get("matches", false)) and bool(y_bridge.get("matches", false)) and bool(rotation_bridge.get("matches", false)) and bool(size_bridge.get("matches", false)) and proof["write_bridge_matches"] and proof["set_bridge_matches"] and proof["x_bridge_matches"] and proof["y_bridge_matches"] and proof["rotation_bridge_matches"] and proof["size_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("UNIT_PAYLOAD_IO_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/UnitPayloadIoModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
