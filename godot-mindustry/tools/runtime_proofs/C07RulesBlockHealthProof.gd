extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.blockHealth(Team) (N2470):
	# Rules.blockHealth(Team) (Rules.java:296-298):
	#     return blockHealthMultiplier *
	#         teams.get(team).blockHealthMultiplier;
	# TRAP: there is NO floor here -- unlike N2459 unitHealth,
	# which returns Math.max(product, 0.000001f), a product of
	# 0 returns 0.0 and a negative product passes through
	# negative. A port that copies the N2459 floor into this
	# function is wrong. TRAP: a missing team means the Java
	# fresh TeamRule, so its multiplier defaults to 1f (:365)
	# like the global default 1f (:111). The proof calls the
	# pure function with synthetic rules dicts (no live tick,
	# no game state). GDScript float is 64-bit vs Java float
	# 32-bit, so products are asserted with a tolerance,
	# never == on a large float product -- the values here
	# are exact binary fractions, so == is exact.

	# 1 x 1 is 1.
	var base_rules: Dictionary = {"blockHealthMultiplier": 1.0, "teams": {0: {"blockHealthMultiplier": 1.0}}}
	var base_result: Dictionary = rules_state.source_rules_block_health_state(base_rules, 0)
	proof["base_one_times_one"] = base_result.get("block_health") == 1.0 and base_result.size() == 1

	# The product scales: 2 x 0.5 is 1, 1.5 x 2 is 3.
	var scale_rules: Dictionary = {"blockHealthMultiplier": 2.0, "teams": {0: {"blockHealthMultiplier": 0.5}}}
	var scale_rules_b: Dictionary = {"blockHealthMultiplier": 1.5, "teams": {0: {"blockHealthMultiplier": 2.0}}}
	proof["product_scales"] = rules_state.source_rules_block_health_state(scale_rules, 0).get("block_health") == 1.0 and rules_state.source_rules_block_health_state(scale_rules_b, 0).get("block_health") == 3.0

	# TRAP: a zero product is 0.0 -- there is no floor here,
	# unlike N2459 unitHealth (0.000001).
	var zero_rules: Dictionary = {"blockHealthMultiplier": 0.0, "teams": {0: {"blockHealthMultiplier": 1.0}}}
	proof["zero_product_is_zero"] = rules_state.source_rules_block_health_state(zero_rules, 0).get("block_health") == 0.0

	# TRAP: a negative product passes through negative,
	# not clamped and not floored.
	var negative_rules: Dictionary = {"blockHealthMultiplier": -1.0, "teams": {0: {"blockHealthMultiplier": 1.0}}}
	proof["negative_product_passes_through"] = rules_state.source_rules_block_health_state(negative_rules, 0).get("block_health") == -1.0

	# TRAP: a team missing from the dict defaults to a 1x
	# multiplier (no error, no NaN) -- global 2 x default 1 is 2.
	var missing_rules: Dictionary = {"blockHealthMultiplier": 2.0, "teams": {}}
	proof["missing_team_defaults_to_one"] = rules_state.source_rules_block_health_state(missing_rules, 7).get("block_health") == 2.0

	# A missing global key defaults to 1x -- 1 x team 3 is 3.
	var missing_global_rules: Dictionary = {"teams": {0: {"blockHealthMultiplier": 3.0}}}
	proof["missing_global_defaults_to_one"] = rules_state.source_rules_block_health_state(missing_global_rules, 0).get("block_health") == 3.0

	# Team keys may be strings (from JSON) as well as ints --
	# the same team read by its string key gives the same product.
	var string_key_rules: Dictionary = {"blockHealthMultiplier": 2.0, "teams": {"0": {"blockHealthMultiplier": 0.5}}}
	proof["string_team_key"] = rules_state.source_rules_block_health_state(string_key_rules, 0).get("block_health") == 1.0

	# A fractional product: 0.25 x 0.5 is 0.125 -- exact in
	# binary, so == is exact; the draft asks for a tolerance
	# comparison and 0.125 is within any sane tolerance.
	var fractional_rules: Dictionary = {"blockHealthMultiplier": 0.25, "teams": {0: {"blockHealthMultiplier": 0.5}}}
	proof["fractional_product"] = absf(rules_state.source_rules_block_health_state(fractional_rules, 0).get("block_health") - 0.125) < 0.000001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesBlockHealthProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
