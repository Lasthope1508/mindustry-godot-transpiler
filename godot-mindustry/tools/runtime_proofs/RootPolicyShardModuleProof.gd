extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const port_game_script := preload("res://src/game/PortGame.gd")

func _ready() -> void:
	var game := port_game_script.new()
	var registry_policy: Dictionary = source_ssot_accessor_runtime_state.document_data("registry").get("policy", {})
	var audit_policy: Dictionary = source_ssot_accessor_runtime_state.document_data("audit_report").get("policy", {})
	var slice_policy: Dictionary = source_ssot_accessor_runtime_state.document_data("slice_ledger").get("policy", {})
	var state_policy: Dictionary = source_ssot_accessor_runtime_state.document_data("state_schema").get("policy", {})
	var module_manifest_policy: Dictionary = source_ssot_accessor_runtime_state.document_data("module_manifest").get("policy", {})
	var shard_registry: Dictionary = source_ssot_accessor_runtime_state.source_root_policy_state("registry")
	var game_shard_registry: Dictionary = game.source_root_policy_state("registry")
	var shard_audit: Dictionary = source_ssot_accessor_runtime_state.lookup_state("source_root_policies", "audit_report")
	var shard_slice: Dictionary = source_ssot_accessor_runtime_state.lookup_state("source_root_policies", "slice_ledger")
	var shard_state: Dictionary = source_ssot_accessor_runtime_state.lookup_state("source_root_policies", "state_schema")
	var shard_module_manifest: Dictionary = source_ssot_accessor_runtime_state.lookup_state("source_root_policies", "module_manifest")
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceRootPolicyShard",
		"registry_policy_matches": shard_registry.get("entry", {}) == registry_policy,
		"game_registry_policy_matches": game_shard_registry == shard_registry,
		"audit_policy_matches": shard_audit.get("entry", {}) == audit_policy,
		"slice_policy_matches": shard_slice.get("entry", {}) == slice_policy,
		"state_policy_matches": shard_state.get("entry", {}) == state_policy,
		"module_manifest_policy_matches": shard_module_manifest.get("entry", {}) == module_manifest_policy,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["registry_policy_matches"] and proof["game_registry_policy_matches"] and proof["audit_policy_matches"] and proof["slice_policy_matches"] and proof["state_policy_matches"] and proof["module_manifest_policy_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("ROOT_POLICY_SHARD_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("RootPolicyShardModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

