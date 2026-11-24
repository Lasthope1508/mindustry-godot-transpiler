extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.unitDamage(Team) (N2462):
	# Rules.unitDamage(Team) (Rules.java:279-281):
	#     return unitDamageMultiplier *
	#         teams.get(team).unitDamageMultiplier;
	# TRAP: there is NO floor here -- unlike N2459 unitHealth,
	# which returns Math.max(product, 0.000001f), a product of
	# 0 returns 0.0 and a negative product passes through
	# negative. A port that copies the N2459 floor into this
	# function is wrong. TRAP: a missing team means the Java
	# fresh TeamRule, so its multiplier defaults to 1f (:355)
	# like the global default 1f (:85). The proof calls the
	# pure function with synthetic rules dicts (no live tick,
	# no game state). GDScript float is 64-bit vs Java float
	# 32-bit, so products are asserted with a tolerance,
	# never == on a large float product.

	# 1 x 1 is 1.
	var base_rules: Dictionary = {"unitDamageMultiplier": 1.0, "teams": {0: {"unitDamageMultiplier": 1.0}}}
	var base_result: Dictionary = rules_state.source_rules_unit_damage_state(base_rules, 0)
	proof["base_one_times_one"] = base_result.get("unit_damage") == 1.0 and base_result.size() == 1

	# The product scales: 2 x 0.5 is 1, 1.5 x 2 is 3.
	var scale_rules: Dictionary = {"unitDamageMultiplier": 2.0, "teams": {0: {"unitDamageMultiplier": 0.5}}}
	var scale_rules_b: Dictionary = {"unitDamageMultiplier": 1.5, "teams": {0: {"unitDamageMultiplier": 2.0}}}
	proof["product_scales"] = rules_state.source_rules_unit_damage_state(scale_rules, 0).get("unit_damage") == 1.0 and rules_state.source_rules_unit_damage_state(scale_rules_b, 0).get("unit_damage") == 3.0

	# TRAP: a zero product is 0.0 -- there is no floor here,
	# unlike N2459 unitHealth (0.000001).
	var zero_rules: Dictionary = {"unitDamageMultiplier": 0.0, "teams": {0: {"unitDamageMultiplier": 1.0}}}
	proof["zero_product_is_zero"] = rules_state.source_rules_unit_damage_state(zero_rules, 0).get("unit_damage") == 0.0

	# TRAP: a negative product passes through negative,
	# not clamped and not floored.
	var negative_rules: Dictionary = {"unitDamageMultiplier": -1.0, "teams": {0: {"unitDamageMultiplier": 1.0}}}
	proof["negative_product_passes_through"] = rules_state.source_rules_unit_damage_state(negative_rules, 0).get("unit_damage") == -1.0

	# TRAP: a team missing from the dict defaults to a 1x
	# multiplier (no error, no NaN) -- global 2 x default 1 is 2.
	var missing_rules: Dictionary = {"unitDamageMultiplier": 2.0, "teams": {}}
	proof["missing_team_defaults_to_one"] = rules_state.source_rules_unit_damage_state(missing_rules, 7).get("unit_damage") == 2.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesUnitDamageProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
