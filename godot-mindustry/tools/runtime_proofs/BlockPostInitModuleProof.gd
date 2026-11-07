extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_post_init_state := preload("res://src/game/SourceBlockPostInitState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var requirements := [{"is_on_planets": ["serpulo"]}]
	var content_planets := [{"name": "serpulo", "is_landable": true}, {"name": "erekir", "is_landable": true}]
	var database_tag_bridge := game.generated_block_post_init_database_tag_bridge_state("", "turret")
	var shown_planets_bridge := game.generated_block_post_init_shown_planets_bridge_state(requirements, [], content_planets)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "BLOCK_POST_INIT_MODULE_PROOF",
		"database_tag_bridge": database_tag_bridge,
		"shown_planets_bridge": shown_planets_bridge,
		"database_tag_bridge_matches": database_tag_bridge == source_block_post_init_state.generated_database_tag_bridge_state("", "turret"),
		"shown_planets_bridge_matches": shown_planets_bridge == source_block_post_init_state.generated_shown_planets_bridge_state(requirements, [], content_planets),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = bool(database_tag_bridge.get("matches", false)) and bool(shown_planets_bridge.get("matches", false)) and proof["database_tag_bridge_matches"] and proof["shown_planets_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BLOCK_POST_INIT_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BlockPostInitModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

