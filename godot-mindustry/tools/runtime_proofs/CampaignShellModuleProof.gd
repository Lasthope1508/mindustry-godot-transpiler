extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_campaign_shell_state := preload("res://src/game/SourceCampaignShellState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var bundle_text := FileAccess.get_file_as_string(source_campaign_shell_state.SOURCE_BUNDLE_PATH)
	var module_state := source_campaign_shell_state.campaign_shell_state(bundle_text)
	var bridge_state := game.source_campaign_shell_state()
	var planets: Array = bridge_state.get("planets", [])
	var proof := {
		"module": "SourceCampaignShellState",
		"bridge_state": bridge_state,
		"module_state": module_state,
		"title": bridge_state.get("title", ""),
		"planet_map_label": bridge_state.get("planet_map_label", ""),
		"launch_core_label": bridge_state.get("launch_core_label", ""),
		"planet_count": planets.size(),
		"serpulo_sprite_exists": FileAccess.file_exists(source_campaign_shell_state.SOURCE_SERPULO_PLANET_SPRITE),
		"erekir_sprite_exists": FileAccess.file_exists(source_campaign_shell_state.SOURCE_EREKIR_PLANET_SPRITE),
		"serpulo_map_root_exists": DirAccess.dir_exists_absolute(source_campaign_shell_state.SOURCE_SERPULO_MAP_ROOT),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bridge_state == module_state and proof["title"] != "" and proof["planet_map_label"] != "" and proof["launch_core_label"] != "" and proof["planet_count"] == 2 and proof["serpulo_sprite_exists"] and proof["erekir_sprite_exists"] and proof["serpulo_map_root_exists"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CAMPAIGN_SHELL_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("CampaignShellModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

