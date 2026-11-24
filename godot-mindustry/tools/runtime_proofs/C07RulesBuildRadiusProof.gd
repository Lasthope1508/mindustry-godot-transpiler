extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.buildRadius(Team) (N2461):
	# Rules.buildRadius(Team) (Rules.java:267-269):
	#     return !teams.get(team).protectCores ? 0f :
	#         enemyCoreBuildRadius +
	#         teams.get(team).extraCoreBuildRadius;
	# TRAP: protectCores=false blocks everything -- the ternary
	# returns 0f without adding anything, however large the extra
	# is. A port that adds first and checks protect later is wrong.
	# TRAP: no clamp -- unlike N2459 unitHealth there is no
	# Math.max here, so a negative extra passes through (400 +
	# -50 = 350). TRAP: a missing team means the Java fresh
	# TeamRule, so protectCores defaults to true (:324) and
	# extraCoreBuildRadius defaults to 0f (:371), and the answer
	# is the global enemyCoreBuildRadius (400f :123). The proof
	# calls the pure function with synthetic rules dicts (no
	# live tick, no game state).

	# Protect true adds the extra: 400 + 50 is 450.
	var protect_rules: Dictionary = {"enemyCoreBuildRadius": 400.0, "teams": {0: {"protectCores": true, "extraCoreBuildRadius": 50.0}}}
	proof["protect_true_adds_extra"] = rules_state.source_rules_build_radius_state(protect_rules, 0).get("build_radius") == 450.0

	# TRAP: protect false blocks everything to 0, even with a
	# huge extra -- 400 + 1000 is NOT the answer.
	var blocked_rules: Dictionary = {"enemyCoreBuildRadius": 400.0, "teams": {0: {"protectCores": false, "extraCoreBuildRadius": 1000.0}}}
	proof["protect_false_blocks_all"] = rules_state.source_rules_build_radius_state(blocked_rules, 0).get("build_radius") == 0.0

	# TRAP: a team missing from the dict defaults to protect
	# true, extra 0 -- the global radius 400, no error, no NaN.
	var missing_rules: Dictionary = {"enemyCoreBuildRadius": 400.0, "teams": {}}
	proof["missing_team_defaults_to_400"] = rules_state.source_rules_build_radius_state(missing_rules, 7).get("build_radius") == 400.0

	# Protect true with zero extra is the global radius.
	var zero_extra_rules: Dictionary = {"enemyCoreBuildRadius": 400.0, "teams": {0: {"protectCores": true, "extraCoreBuildRadius": 0.0}}}
	proof["protect_true_zero_extra"] = rules_state.source_rules_build_radius_state(zero_extra_rules, 0).get("build_radius") == 400.0

	# TRAP: a negative extra is not clamped -- 400 + -50 is 350,
	# not 0 and not 400.
	var negative_rules: Dictionary = {"enemyCoreBuildRadius": 400.0, "teams": {0: {"protectCores": true, "extraCoreBuildRadius": -50.0}}}
	proof["negative_extra_not_clamped"] = rules_state.source_rules_build_radius_state(negative_rules, 0).get("build_radius") == 350.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesBuildRadiusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
