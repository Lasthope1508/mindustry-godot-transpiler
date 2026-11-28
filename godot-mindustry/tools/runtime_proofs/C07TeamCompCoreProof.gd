extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- TeamComp.core() (N2491):
	# TeamComp.core() (TeamComp.java:27-29):
	#     @Nullable
	#     public CoreBuild core(){
	#         return team.core();
	#     }
	# A pure delegate: the callee Team.core()
	# (Team.java:88-90, `return data().core();`) is
	# already ported (N2450), so its result arrives
	# as the precomputed core input and passes
	# through whole. The @Nullable return passes
	# through too: null when the team has no core.
	# The proof calls the pure function with
	# synthetic inputs (no live tick, no game state);
	# core refs are plain Dictionaries here because
	# the function never inspects the ref -- it only
	# passes the Variant through.

	# A core dict passes through verbatim.
	var core_a: Dictionary = {"id": 7, "team": 1, "x": 100.0, "y": 200.0}
	proof["core_passthrough"] = rules_state.source_team_comp_core_state(100.0, 200.0, 1, core_a).get("core") == core_a

	# TRAP: null passes through (the @Nullable return)
	# -- no default core, no empty-dict fallback.
	var null_result: Dictionary = rules_state.source_team_comp_core_state(0.0, 0.0, 1, null)
	proof["core_null_passthrough"] = null_result.has("core") and null_result["core"] == null

	# TRAP: the core value is a PRECOMPUTED input --
	# the function uses the given value verbatim and
	# never re-derives it from x/y/team, so an
	# arbitrary core passes through untouched.
	var custom_core: Dictionary = {"id": 99, "team": 1, "label": "custom"}
	proof["core_precomputed_input"] = rules_state.source_team_comp_core_state(5.0, 5.0, 1, custom_core).get("core") == custom_core

	# The result does not depend on the query position
	# or team: the same precomputed core with different
	# x/y/team_id gives the same result -- the
	# data().core() lookup is the N2450 callee's job,
	# not this delegate's.
	proof["core_ignores_position"] = rules_state.source_team_comp_core_state(0.0, 0.0, 1, core_a).get("core") == rules_state.source_team_comp_core_state(999.0, -50.0, 4, core_a).get("core")

	# Distinct cores stay distinct: A maps to A, B maps
	# to B, and A is not B.
	var core_b: Dictionary = {"id": 12, "team": 1, "x": 300.0, "y": 400.0}
	proof["core_distinct_cores"] = rules_state.source_team_comp_core_state(100.0, 200.0, 1, core_a).get("core") == core_a and rules_state.source_team_comp_core_state(300.0, 400.0, 1, core_b).get("core") == core_b and core_a != core_b

	# CROSS-PIN with the N2450 callee: the value this
	# delegate returns equals what source_team_state
	# returns for the same team -- the delegate wires
	# to the actual callee, it does not invent its own
	# core. Team 1 has two cores; the callee returns
	# the FIRST core (the N2374 liveness rule), so the
	# delegate returns the first core too.
	var full_state: Dictionary = {"teams": {1: {"cores": [{"items": {"copper": 5}}, {"items": {"lead": 3}}], "players": [], "buildings": []}}, "rules": {"waves": false, "wave_team": -1}, "active": []}
	var callee_result: Dictionary = teams_state.source_team_state(full_state, 1, true, false)
	proof["core_matches_callee_result"] = rules_state.source_team_comp_core_state(100.0, 200.0, 1, callee_result.get("core")).get("core") == callee_result.get("core") and callee_result.get("core") == {"items": {"copper": 5}}

	# Calling twice with the same inputs gives the same
	# result.
	proof["core_idempotent"] = rules_state.source_team_comp_core_state(100.0, 200.0, 1, core_a).get("core") == rules_state.source_team_comp_core_state(100.0, 200.0, 1, core_a).get("core")

	# The result carries exactly the one key.
	var one_key_result: Dictionary = rules_state.source_team_comp_core_state(100.0, 200.0, 1, core_a)
	proof["core_returns_only_one_key"] = one_key_result.size() == 1 and one_key_result.has("core")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamCompCoreProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
