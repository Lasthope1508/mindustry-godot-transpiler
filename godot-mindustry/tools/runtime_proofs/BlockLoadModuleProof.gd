extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_load_state := preload("res://src/game/SourceBlockLoadState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var base_name := "block-core"
	var team_name := "block-team"
	var team_region := "team-region"
	var teams := [
		{"id": 0, "name": "alpha", "hasPalette": true},
		{"id": 1, "name": "beta", "hasPalette": false},
		{"id": 2, "name": "gamma", "hasPalette": true},
	]
	var variant_name := "variant-block"
	var shadow_name := "shadow-block"
	var base_bridge := game.generated_block_load_base_regions_bridge_state(base_name)
	var team_bridge := game.generated_block_load_team_regions_bridge_state(team_name, true, team_region, teams)
	var variant_bridge := game.generated_block_load_variant_regions_bridge_state(variant_name, 3)
	var shadow_bridge := game.generated_block_load_variant_shadow_regions_bridge_state(shadow_name, 2, true)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_LOAD_MODULE_PROOF",
		"base_bridge": base_bridge,
		"team_bridge": team_bridge,
		"variant_bridge": variant_bridge,
		"shadow_bridge": shadow_bridge,
		"base_bridge_matches": base_bridge == source_block_load_state.generated_block_load_base_regions_bridge_state(base_name),
		"team_bridge_matches": team_bridge == source_block_load_state.generated_block_load_team_regions_bridge_state(team_name, true, team_region, teams),
		"variant_bridge_matches": variant_bridge == source_block_load_state.generated_block_load_variant_regions_bridge_state(variant_name, 3),
		"shadow_bridge_matches": shadow_bridge == source_block_load_state.generated_block_load_variant_shadow_regions_bridge_state(shadow_name, 2, true),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(base_bridge.get("matches", false)) and bool(team_bridge.get("matches", false)) and bool(variant_bridge.get("matches", false)) and bool(shadow_bridge.get("matches", false)) and proof["base_bridge_matches"] and proof["team_bridge_matches"] and proof["variant_bridge_matches"] and proof["shadow_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_LOAD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockLoadModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

