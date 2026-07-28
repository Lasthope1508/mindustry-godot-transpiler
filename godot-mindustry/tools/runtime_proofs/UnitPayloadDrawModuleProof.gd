extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")
const SourceUnitPayloadDrawState := preload("res://src/game/SourceUnitPayloadDrawState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var unit_type_null := false
	var alpha := 0.7
	var unit_id := "flare-9"
	var unit_elevation := 1.25
	var overlay_time := 0.5
	var overlay_region := "warning-region"
	var unit_x := 12.0
	var unit_y := 18.0
	var time_delta := 1.0
	var draw_z_before := 25.0
	var interp_exp5_out_overlay_time := 0.875
	var unit_type_full_icon := "flare-icon"
	var shadow_bridge := game.generated_unit_payload_draw_shadow_type_null_bridge_state(unit_type_null, alpha, unit_id)
	var type_null_bridge := game.generated_unit_payload_draw_type_null_bridge_state(unit_type_null)
	var elevation_bridge := game.generated_unit_payload_draw_elevation_setup_bridge_state(unit_type_null, unit_elevation, unit_id)
	var overlay_bridge := game.generated_unit_payload_draw_overlay_warning_bridge_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time)
	var icon_bridge := game.generated_unit_payload_icon_bridge_state(unit_type_full_icon)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "UNIT_PAYLOAD_DRAW_MODULE_PROOF",
		"shadow_bridge": shadow_bridge,
		"type_null_bridge": type_null_bridge,
		"elevation_bridge": elevation_bridge,
		"overlay_bridge": overlay_bridge,
		"icon_bridge": icon_bridge,
		"shadow_bridge_matches": shadow_bridge == SourceUnitPayloadDrawState.generated_shadow_type_null_bridge_state(unit_type_null, alpha, unit_id),
		"type_null_bridge_matches": type_null_bridge == SourceUnitPayloadDrawState.generated_type_null_bridge_state(unit_type_null),
		"elevation_bridge_matches": elevation_bridge == SourceUnitPayloadDrawState.generated_elevation_setup_bridge_state(unit_type_null, unit_elevation, unit_id),
		"overlay_bridge_matches": overlay_bridge == SourceUnitPayloadDrawState.generated_overlay_warning_bridge_state(unit_type_null, unit_elevation, unit_id, overlay_time, overlay_region, unit_x, unit_y, time_delta, draw_z_before, interp_exp5_out_overlay_time),
		"icon_bridge_matches": icon_bridge == SourceUnitPayloadDrawState.generated_icon_bridge_state(unit_type_full_icon),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = bool(shadow_bridge.get("matches", false)) and bool(type_null_bridge.get("matches", false)) and bool(elevation_bridge.get("matches", false)) and bool(overlay_bridge.get("matches", false)) and bool(icon_bridge.get("matches", false)) and proof["shadow_bridge_matches"] and proof["type_null_bridge_matches"] and proof["elevation_bridge_matches"] and proof["overlay_bridge_matches"] and proof["icon_bridge_matches"] and proof["one_headquarter_per_ssot"]
	var proof_json := JSON.stringify(proof)
	print("UNIT_PAYLOAD_DRAW_MODULE_PROOF " + proof_json)
	var proof_file := FileAccess.open("C:/Users/Admin/Documents/Game/mindustry-godot-transpiler-copy-20260714-073528/godot-mindustry/tools/runtime_proofs/UnitPayloadDrawModuleProof.json", FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(6.0).timeout
	get_tree().quit(0)
