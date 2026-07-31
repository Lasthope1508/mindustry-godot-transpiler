extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_unit_payload_basic_state := preload("res://src/game/SourceUnitPayloadBasicState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var unit := {"type": "flare"}
	var icon := "region-icon"
	var region := "drawable-region"
	var constructor_bridge := game.generated_unit_payload_constructor_bridge_state(unit)
	var texture_bridge := game.generated_unit_payload_show_overlay_texture_region_bridge_state(icon)
	var drawable_bridge := game.generated_unit_payload_show_overlay_drawable_bridge_state(false, false, region)
	var proof := {
		"module": "UNIT_PAYLOAD_BASIC_MODULE_PROOF",
		"constructor_bridge": constructor_bridge,
		"texture_bridge": texture_bridge,
		"drawable_bridge": drawable_bridge,
		"constructor_bridge_matches": constructor_bridge == source_unit_payload_basic_state.generated_constructor_bridge_state(unit),
		"texture_bridge_matches": texture_bridge == source_unit_payload_basic_state.generated_show_overlay_texture_region_bridge_state(icon),
		"drawable_bridge_matches": drawable_bridge == source_unit_payload_basic_state.generated_show_overlay_drawable_bridge_state(false, false, region),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(constructor_bridge.get("matches", false)) and bool(texture_bridge.get("matches", false)) and bool(drawable_bridge.get("matches", false)) and proof["constructor_bridge_matches"] and proof["texture_bridge_matches"] and proof["drawable_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("UNIT_PAYLOAD_BASIC_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/UnitPayloadBasicModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
