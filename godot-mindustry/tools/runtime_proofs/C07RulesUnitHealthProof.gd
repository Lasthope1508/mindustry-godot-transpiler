extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.unitHealth(Team) (N2459):
	# Rules.unitHealth(Team) (Rules.java:283-286):
	#     return Math.max(unitHealthMultiplier *
	#         teams.get(team).unitHealthMultiplier, 0.000001f);
	# TRAP: the floor is 0.000001, not 0 -- a product of 0 (or
	# negative) still returns 0.000001, exactly as the Java
	# comment :284 says ("a 0 here would be a very bad idea").
	# A port that clamps to 0 is wrong. TRAP: a missing team
	# means the Java fresh TeamRule, so its multiplier defaults
	# to 1f (:363) like the global default 1f (:87). The proof
	# calls the pure function with synthetic rules dicts (no
	# live tick, no game state). GDScript float is 64-bit vs
	# Java float 32-bit, so the floor is asserted with a
	# tolerance, never == on a large float product.

	# 1 x 1 is 1.
	var base_rules: Dictionary = {"unitHealthMultiplier": 1.0, "teams": {0: {"unitHealthMultiplier": 1.0}}}
	var base_result: Dictionary = rules_state.source_rules_unit_health_state(base_rules, 0)
	proof["base_one_times_one"] = base_result.get("unit_health") == 1.0 and base_result.size() == 1

	# The product scales: 2 x 0.5 is 1, 1.5 x 2 is 3.
	var scale_rules: Dictionary = {"unitHealthMultiplier": 2.0, "teams": {0: {"unitHealthMultiplier": 0.5}}}
	var scale_rules_b: Dictionary = {"unitHealthMultiplier": 1.5, "teams": {0: {"unitHealthMultiplier": 2.0}}}
	proof["product_scales"] = rules_state.source_rules_unit_health_state(scale_rules, 0).get("unit_health") == 1.0 and rules_state.source_rules_unit_health_state(scale_rules_b, 0).get("unit_health") == 3.0

	# TRAP: a zero product is floored to 0.000001, not 0.
	var zero_rules: Dictionary = {"unitHealthMultiplier": 0.0, "teams": {0: {"unitHealthMultiplier": 1.0}}}
	proof["floor_not_zero"] = absf(float(rules_state.source_rules_unit_health_state(zero_rules, 0).get("unit_health")) - 0.000001) < 0.00000001

	# TRAP: a negative product is floored too, not just zero.
	var negative_rules: Dictionary = {"unitHealthMultiplier": -1.0, "teams": {0: {"unitHealthMultiplier": 1.0}}}
	proof["negative_product_floored"] = absf(float(rules_state.source_rules_unit_health_state(negative_rules, 0).get("unit_health")) - 0.000001) < 0.00000001

	# TRAP: a team missing from the dict defaults to a 1x
	# multiplier (no error, no NaN) -- global 2 x default 1 is 2.
	var missing_rules: Dictionary = {"unitHealthMultiplier": 2.0, "teams": {}}
	proof["missing_team_defaults_to_one"] = rules_state.source_rules_unit_health_state(missing_rules, 7).get("unit_health") == 2.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesUnitHealthProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
