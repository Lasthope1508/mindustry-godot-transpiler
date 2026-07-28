extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceUnitPayloadContentState := preload("res://src/game/SourceUnitPayloadContentState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type := "flare"
	var other_unit_type := "flare"
	var unit := {"id": 7, "type": unit_type}
	var unit_holder := {"id": 1}
	var building_holder := {"id": 2}
	var content_equals_bridge := game.generated_unit_payload_content_equals_bridge_state(true, other_unit_type, unit_type)
	var update_bridge := game.generated_unit_payload_update_bridge_state(unit_type, unit, unit_holder, building_holder)
	var content_bridge := game.generated_unit_payload_content_bridge_state(unit_type)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_CONTENT_MODULE_PROOF",
		"content_equals_bridge": content_equals_bridge,
		"update_bridge": update_bridge,
		"content_bridge": content_bridge,
		"content_equals_bridge_matches": content_equals_bridge == SourceUnitPayloadContentState.generated_content_equals_bridge_state(true, other_unit_type, unit_type),
		"update_bridge_matches": update_bridge == SourceUnitPayloadContentState.generated_update_bridge_state(unit_type, unit, unit_holder, building_holder),
		"content_bridge_matches": content_bridge == SourceUnitPayloadContentState.generated_content_bridge_state(unit_type),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(content_equals_bridge.get("matches", false)) and bool(update_bridge.get("matches", false)) and bool(content_bridge.get("matches", false)) and proof["content_equals_bridge_matches"] and proof["update_bridge_matches"] and proof["content_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("UNIT_PAYLOAD_CONTENT_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/UnitPayloadContentModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
