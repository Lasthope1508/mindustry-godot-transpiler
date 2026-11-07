extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_icon_state := preload("res://src/game/SourceBlockIconState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var super_state := {"source_owner": "super.create_icons"}
	var teams := [
		{"id": 0, "name": "derelict", "has_palette": false},
		{"id": 1, "name": "sharded", "has_palette": true},
		{"id": 2, "name": "crux", "has_palette": true},
	]
	var team_regions := ["base-team", "old-sharded", "old-crux"]
	var generated_icons := ["duo1", "duo2"]
	var wrapper := game.generated_block_create_icons_bridge_state(super_state, false, 64, 64, "center-color", "old-map-color", "duo", true, teams, "team-region", team_regions, ["duo-team-crux"], true, -1, 2, generated_icons, ["special-region"])
	var module := source_block_icon_state.generated_block_create_icons_bridge_state(super_state, false, 64, 64, "center-color", "old-map-color", "duo", true, teams, "team-region", team_regions, ["duo-team-crux"], true, -1, 2, generated_icons, ["special-region"])
	var result: Dictionary = wrapper.get("result", {})
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_CREATE_ICONS_MODULE_PROOF",
		"wrapper_matches_module": wrapper == module,
		"generated_matches": bool(wrapper.get("matches", false)),
		"map_color_uses_center_pixel": result.get("map_color_after", "") == "center-color",
		"team_palette_generation_is_tracked": result.get("team_assignments", []).size() == 3 and bool(result.get("team_assignments", [])[1].get("generated", false)),
		"team_override_is_respected": not bool(result.get("team_assignments", [])[2].get("generated", true)) and bool(result.get("team_assignments", [])[2].get("overridden", false)),
		"outline_is_selected": int(result.get("outline_operation", {}).get("index", -1)) == 1,
		"composite_is_created": result.get("composite", {}).get("mode", "") == "composite" and result.get("composite", {}).get("output_name", "") == "block-duo-full",
		"dispose_is_recorded": bool(result.get("disposed", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["wrapper_matches_module"] and proof["generated_matches"] and proof["map_color_uses_center_pixel"] and proof["team_palette_generation_is_tracked"] and proof["team_override_is_respected"] and proof["outline_is_selected"] and proof["composite_is_created"] and proof["dispose_is_recorded"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockCreateIconsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
