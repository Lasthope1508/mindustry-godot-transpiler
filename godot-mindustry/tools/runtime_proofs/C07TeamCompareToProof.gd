extends Node

const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Team.compareTo(Team) (N2463):
	# Team.compareTo(Team) (Team.java:159-162):
	#     @Override
	#     public int compareTo(Team team){
	#         return Integer.compare(id, team.id);
	#     }
	# TRAP: Integer.compare returns exactly -1, 0 or 1 --
	# never the difference of the ids: 0 vs 255 is -1, not
	# -255. A port that returns id - other_id is wrong (and
	# risks int overflow in Java). GDScript ints are 64-bit
	# signed, so the ternary comparison reproduces
	# Integer.compare for every int, including negatives.
	# The proof calls the pure function with synthetic ids
	# (no live tick, no game state).

	# 0 < 1 is -1.
	proof["less_returns_minus_one"] = teams_state.source_team_compare_to_state(0, 1).get("comparison") == -1

	# 1 > 0 is 1.
	proof["greater_returns_one"] = teams_state.source_team_compare_to_state(1, 0).get("comparison") == 1

	# Equal ids are 0, and the result has exactly one key.
	var equal_result: Dictionary = teams_state.source_team_compare_to_state(2, 2)
	proof["equal_returns_zero"] = equal_result.get("comparison") == 0 and equal_result.size() == 1

	# TRAP: 0 vs 255 is -1, NOT -255 -- the result is a
	# sign, not a difference. The reverse is 1, not 255.
	proof["difference_is_not_returned"] = teams_state.source_team_compare_to_state(0, 255).get("comparison") == -1 and teams_state.source_team_compare_to_state(255, 0).get("comparison") == 1

	# TRAP: negative ids still compare correctly -- 5 > -3
	# is 1, -3 < 5 is -1 (Integer.compare handles negatives;
	# team ids in-game are 0..255 but the function is pure
	# over ints).
	proof["negative_ids_compare_correctly"] = teams_state.source_team_compare_to_state(5, -3).get("comparison") == 1 and teams_state.source_team_compare_to_state(-3, 5).get("comparison") == -1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamCompareToProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
