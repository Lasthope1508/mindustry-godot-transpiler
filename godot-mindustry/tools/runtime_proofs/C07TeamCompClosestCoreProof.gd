extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- TeamComp.closestCore() (N2489):
	# TeamComp.closestCore() (TeamComp.java:31-34):
	#     @Nullable
	#     public CoreBuild closestCore(){
	#         return state.teams.closestCore(x, y, team);
	#     }
	# A pure delegate: the callee Teams.closestCore
	# (Teams.java:56-58) is already ported (N2392), so
	# its result arrives as the precomputed closest_core
	# input and passes through whole. The @Nullable
	# return passes through too: null when no core is
	# near. The proof calls the pure function with
	# synthetic inputs (no live tick, no game state);
	# core refs are plain Dictionaries here because the
	# function never inspects the ref -- it only passes
	# the Variant through.

	# A core dict passes through verbatim.
	var core_a: Dictionary = {"id": 7, "team": 1, "x": 100.0, "y": 200.0}
	proof["closest_core_passthrough"] = rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, core_a).get("closest_core") == core_a

	# TRAP: null passes through (the @Nullable return)
	# -- no default core, no empty-dict fallback.
	var null_result: Dictionary = rules_state.source_team_comp_closest_core_state(0.0, 0.0, 1, null)
	proof["closest_core_null_passthrough"] = null_result.has("closest_core") and null_result["closest_core"] == null

	# TRAP: the closest_core value is a PRECOMPUTED
	# input -- the function uses the given value verbatim
	# and never re-derives it from x/y/team, so an
	# arbitrary core passes through untouched.
	var custom_core: Dictionary = {"id": 99, "team": 2, "label": "custom"}
	proof["closest_core_precomputed_input"] = rules_state.source_team_comp_closest_core_state(5.0, 5.0, 2, custom_core).get("closest_core") == custom_core

	# The result does not depend on the query position
	# or team: the same precomputed core with different
	# x/y/team_id gives the same result -- the search is
	# the N2392 callee's job, not this delegate's.
	proof["closest_core_ignores_position"] = rules_state.source_team_comp_closest_core_state(0.0, 0.0, 1, core_a).get("closest_core") == rules_state.source_team_comp_closest_core_state(999.0, -50.0, 4, core_a).get("closest_core")

	# Distinct cores stay distinct: A maps to A, B maps
	# to B, and A is not B.
	var core_b: Dictionary = {"id": 12, "team": 1, "x": 300.0, "y": 400.0}
	proof["closest_core_distinct_cores"] = rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, core_a).get("closest_core") == core_a and rules_state.source_team_comp_closest_core_state(300.0, 400.0, 1, core_b).get("closest_core") == core_b and core_a != core_b

	# CROSS-PIN with the N2392 callee: the value this
	# delegate returns equals what
	# source_teams_closest_core_state returns for the
	# same core -- the delegate wires to the actual
	# callee, it does not invent its own nearest core.
	var cores: Array = [core_a, core_b]
	var find_closest := func(_px: float, _py: float, _pcores: Array):
		return _pcores[0]
	var callee_result: Dictionary = teams_state.source_teams_closest_core_state(100.0, 200.0, cores, find_closest)
	proof["closest_core_matches_callee_result"] = rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, callee_result.get("core")).get("closest_core") == callee_result.get("core") and callee_result.get("core") == core_a

	# Calling twice with the same inputs gives the same
	# result.
	proof["closest_core_idempotent"] = rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, core_a).get("closest_core") == rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, core_a).get("closest_core")

	# The result carries exactly the one key.
	var one_key_result: Dictionary = rules_state.source_team_comp_closest_core_state(100.0, 200.0, 1, core_a)
	proof["closest_core_returns_only_one_key"] = one_key_result.size() == 1 and one_key_result.has("closest_core")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamCompClosestCoreProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
