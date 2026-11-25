extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.hasEnv(int) (N2467):
	# Rules.hasEnv(int) (Rules.java:263-265):
	#     return (this.env & env) != 0;
	# The env field defaults to Vars.defaultEnv
	# (Rules.java:163; Vars.java:65) = terrestrial(1) |
	# spores(8) | groundOil(32) | groundWater(64) |
	# oxygen(128) = 233 -- space(2) is NOT in it.
	# TRAP: this is an ANY-overlap check, not ALL-bits --
	# a combined flag is true when ANY of its bits is
	# set. A port that checks (env & flag) == flag is
	# wrong. TRAP: flag 0 is always false -- 0 & anything
	# is 0. The proof calls the pure function with
	# synthetic rules dicts (no live tick, no game
	# state).

	# Default env 233 has terrestrial (1).
	var default_rules: Dictionary = {"env": 233}
	var terrestrial_result: Dictionary = rules_state.source_rules_has_env_state(default_rules, 1)
	proof["default_has_terrestrial"] = terrestrial_result.get("has_env") == true and terrestrial_result.size() == 1

	# Default env 233 has spores (8).
	proof["default_has_spores"] = rules_state.source_rules_has_env_state(default_rules, 8).get("has_env") == true

	# TRAP: default env 233 does NOT have space (2) --
	# Vars.defaultEnv omits it.
	proof["default_lacks_space"] = rules_state.source_rules_has_env_state(default_rules, 2).get("has_env") == false

	# TRAP: flag 0 is always false, whatever the env --
	# 0 & anything is 0, on the default env and on an
	# all-bits env alike.
	proof["zero_flag_always_false"] = rules_state.source_rules_has_env_state(default_rules, 0).get("has_env") == false and rules_state.source_rules_has_env_state({"env": 255}, 0).get("has_env") == false

	# TRAP: ANY-overlap, not ALL-bits -- flag 2|8=10 is
	# true on the default env because spores (8) alone
	# overlaps, even though space (2) is absent. A port
	# checking (env & flag) == flag returns false here.
	proof["any_overlap_not_all_bits"] = rules_state.source_rules_has_env_state(default_rules, 10).get("has_env") == true

	# A custom env matches exactly its own bits: env=2
	# (space only) has space but not terrestrial.
	var space_rules: Dictionary = {"env": 2}
	proof["custom_env_exact"] = rules_state.source_rules_has_env_state(space_rules, 2).get("has_env") == true and rules_state.source_rules_has_env_state(space_rules, 1).get("has_env") == false

	# A combined flag with both bits present in the
	# default env: 1|128=129 (terrestrial + oxygen).
	proof["combined_flag_both_present"] = rules_state.source_rules_has_env_state(default_rules, 129).get("has_env") == true

	# A missing "env" key means the Java field default
	# Vars.defaultEnv (233): terrestrial yes, space no.
	var empty_rules: Dictionary = {}
	proof["missing_env_key_defaults"] = rules_state.source_rules_has_env_state(empty_rules, 1).get("has_env") == true and rules_state.source_rules_has_env_state(empty_rules, 2).get("has_env") == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesHasEnvProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
