extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var registry_state: Dictionary = game.ssot_headquarter_registry_state()
	var source_symbols_lookup: Dictionary = game.ssot_headquarter_lookup_state("source symbols")
	var source_symbol_registry_lookup: Dictionary = game.ssot_headquarter_lookup_state("source.symbol.registry")
	var block_content_registry_lookup: Dictionary = game.ssot_headquarter_lookup_state("block content registry")
	var proof := {
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"canonical_key_count": int(registry_state.get("canonical_key_count", 0)),
		"headquarter_count": int(registry_state.get("headquarter_count", 0)),
		"headquarter_count_matches_canonical_keys": bool(registry_state.get("headquarter_count_matches_canonical_keys", false)),
		"module_registry_count": int(registry_state.get("module_registry_count", 0)),
		"duplicate_headquarters": registry_state.get("duplicate_headquarters", []),
		"duplicate_features": registry_state.get("duplicate_features", []),
		"duplicate_aliases": registry_state.get("duplicate_aliases", []),
		"source_symbols_lookup": source_symbols_lookup,
		"source_symbol_registry_lookup": source_symbol_registry_lookup,
		"block_content_registry_lookup": block_content_registry_lookup,
		"source_symbols_matches": str(source_symbols_lookup.get("canonical_key", "")) == "registry",
		"source_symbol_registry_matches": str(source_symbol_registry_lookup.get("canonical_key", "")) == "registry",
	}
	proof["registry_valid"] = bool(registry_state.get("valid", false))
	proof["matches"] = proof["one_headquarter_per_ssot"] and proof["headquarter_count_matches_canonical_keys"] and proof["source_symbols_matches"] and proof["source_symbol_registry_matches"] and bool(block_content_registry_lookup.get("valid", false)) and proof["registry_valid"]
	print("SSOT_HEADQUARTER_REGISTRY_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("SsotHeadquarterRegistryProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
