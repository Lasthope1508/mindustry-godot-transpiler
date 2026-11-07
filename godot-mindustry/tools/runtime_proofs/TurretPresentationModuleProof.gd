extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_presentation_state := preload("res://src/game/SourceTurretPresentationState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var load_state := game.source_turret_load_state()
	var draw_plan := game.source_turret_draw_plan_region_state([], [])
	var icons := game.source_turret_icons_state()
	var outline := game.source_turret_get_regions_to_outline_state([])
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var module_load := source_turret_presentation_state.generated_turret_load_bridge_state()
	var module_draw_plan := source_turret_presentation_state.generated_turret_draw_plan_region_bridge_state([], [])
	var module_icons := source_turret_presentation_state.generated_turret_icons_bridge_state()
	var module_outline := source_turret_presentation_state.generated_get_regions_to_outline_bridge_state([])
	var proof := {
		"module": "SourceTurretPresentationState",
		"load_matches": load_state.get("drawer_load_called", false),
		"draw_plan_matches": draw_plan.get("drawer_draw_plan_called", false),
		"icons_matches": icons.get("drawer_final_icons_called", false),
		"outline_matches": outline.get("drawer_get_regions_to_outline_called", false),
		"module_load_bridge_matches": bool(module_load.get("matches", false)),
		"module_draw_plan_matches": bool(module_draw_plan.get("matches", false)),
		"module_icons_matches": bool(module_icons.get("matches", false)),
		"module_outline_bridge_matches": bool(module_outline.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["load_matches"] and proof["draw_plan_matches"] and proof["icons_matches"] and proof["outline_matches"] and proof["module_load_bridge_matches"] and proof["module_draw_plan_matches"] and proof["module_icons_matches"] and proof["module_outline_bridge_matches"]
	proof["matches"] = proof["module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_PRESENTATION_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretPresentationModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

