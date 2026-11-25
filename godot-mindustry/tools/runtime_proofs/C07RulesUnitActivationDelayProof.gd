extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.unitActivationDelay(Team) (N2466):
	# Rules.unitActivationDelay(Team) (Rules.java:315-317):
	#     return unitFactoryActivationDelay +
	#         teams.get(team).unitFactoryActivationDelay;
	# TRAP: this ADDS -- unlike the sibling Rules
	# multipliers (N2096 unitCost, N2462 unitDamage, N2464
	# unitBuildSpeed) which multiply, 2 + 3 is 5.0, not
	# 6.0. A port that copies the multiply pattern is
	# wrong. TRAP: there is no clamp here -- unlike N2459
	# unitHealth (Math.max), a negative team delay passes
	# through (5 + -2 = 3.0). TRAP: a missing team means
	# the Java fresh TeamRule, so its delay defaults to 0f
	# (:351) like the global default 0f (:93). The proof
	# calls the pure function with synthetic rules dicts
	# (no live tick, no game state). GDScript float is
	# 64-bit vs Java float 32-bit, so sums are asserted
	# with a tolerance on large values, never == on a
	# large float sum; the small sums here are exact.

	# 5 + 3 is 8.
	var adds_rules: Dictionary = {"unitFactoryActivationDelay": 5.0, "teams": {0: {"unitFactoryActivationDelay": 3.0}}}
	var adds_result: Dictionary = rules_state.source_rules_unit_activation_delay_state(adds_rules, 0)
	proof["adds_both"] = adds_result.get("unit_activation_delay") == 8.0 and adds_result.size() == 1

	# Both defaults are 0: 0 + 0 is 0.
	var defaults_rules: Dictionary = {"unitFactoryActivationDelay": 0.0, "teams": {0: {"unitFactoryActivationDelay": 0.0}}}
	proof["defaults_zero"] = rules_state.source_rules_unit_activation_delay_state(defaults_rules, 0).get("unit_activation_delay") == 0.0

	# TRAP: a team missing from the dict defaults to a 0
	# delay (no error, no NaN) -- global 2 + default 0 is 2.
	var missing_rules: Dictionary = {"unitFactoryActivationDelay": 2.0, "teams": {}}
	proof["missing_team_defaults_to_zero"] = rules_state.source_rules_unit_activation_delay_state(missing_rules, 7).get("unit_activation_delay") == 2.0

	# TRAP: this ADDS, not multiplies -- 2 + 3 is 5.0,
	# not 6.0.
	var add_rules: Dictionary = {"unitFactoryActivationDelay": 2.0, "teams": {0: {"unitFactoryActivationDelay": 3.0}}}
	proof["adds_not_multiplies"] = rules_state.source_rules_unit_activation_delay_state(add_rules, 0).get("unit_activation_delay") == 5.0

	# TRAP: a negative team delay passes through
	# unclamped, not floored at 0 -- 5 + -2 is 3.0.
	var negative_rules: Dictionary = {"unitFactoryActivationDelay": 5.0, "teams": {0: {"unitFactoryActivationDelay": -2.0}}}
	proof["negative_team_delay_passes_through"] = rules_state.source_rules_unit_activation_delay_state(negative_rules, 0).get("unit_activation_delay") == 3.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesUnitActivationDelayProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
