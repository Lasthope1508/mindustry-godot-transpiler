extends Node

const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Team.get(int) (N2456):
	# Team.get(int) (Team.java:58-60): the 2 distinct body
	# exprs only -- `public static Team get(int id){` (:58)
	# and `return all[((byte)id) & 0xff];` (:59). TRAP: the
	# (byte) cast keeps only the low 8 bits, then & 0xff makes
	# the index unsigned, so the id wraps modulo 256: 256 -> 0,
	# -1 -> 255, -256 -> 0, 257 -> 1. GD takes the already-built
	# 256-entry Team.all array as an Array input (option (A)
	# data-driven, precedent N2453/N2455) and does not build the
	# teams itself: the static init at Team.java:43-56 belongs to
	# a later slice. The proof calls the pure function with a
	# synthetic 256-team array (no live tick, no Teams state,
	# no static init). Team dicts are compared by their id/name
	# fields (the data the proof itself built).

	var all_teams: Array = []
	for i in range(256):
		all_teams.append({"id": i, "name": "team#" + str(i)})
	# The 7 named teams (Team.java:31-41): derelict 0, sharded 1,
	# crux 2, malis 3, green 4, blue 5, neoplastic 6. The
	# placeholder name team#255 is the static init's own naming
	# (Team.java:51, `new Team(i, "team#" + i, ...)`).
	all_teams[0] = {"id": 0, "name": "derelict"}
	all_teams[1] = {"id": 1, "name": "sharded"}
	all_teams[2] = {"id": 2, "name": "crux"}
	all_teams[3] = {"id": 3, "name": "malis"}
	all_teams[4] = {"id": 4, "name": "green"}
	all_teams[5] = {"id": 5, "name": "blue"}
	all_teams[6] = {"id": 6, "name": "neoplastic"}

	# Base ids hit directly: 1 -> sharded, 6 -> neoplastic.
	var base_one: Dictionary = teams_state.source_team_get_state(all_teams, 1)
	var base_six: Dictionary = teams_state.source_team_get_state(all_teams, 6)
	proof["base_id_direct"] = base_one.get("team", {}).get("name") == "sharded" and base_one.get("wrapped_id") == 1 and base_six.get("team", {}).get("name") == "neoplastic" and base_six.get("wrapped_id") == 6

	# TRAP: 256 wraps to 0 (derelict) -- NOT an out-of-bounds
	# error, NOT clamped to 255.
	var wrap_256: Dictionary = teams_state.source_team_get_state(all_teams, 256)
	proof["wrap_256_to_zero"] = wrap_256.get("team", {}).get("name") == "derelict" and wrap_256.get("wrapped_id") == 0

	# TRAP: negative ids wrap too: -1 -> 255 (the last
	# placeholder), -256 -> 0.
	var neg_one: Dictionary = teams_state.source_team_get_state(all_teams, -1)
	var neg_256: Dictionary = teams_state.source_team_get_state(all_teams, -256)
	proof["negative_id_wraps"] = neg_one.get("team", {}).get("name") == "team#255" and neg_one.get("wrapped_id") == 255 and neg_256.get("team", {}).get("name") == "derelict" and neg_256.get("wrapped_id") == 0

	# 257 -> 1 and 514 -> 2: the wrap is a true modulo, not a
	# single subtract-256 (which would fail for 514).
	var wrap_257: Dictionary = teams_state.source_team_get_state(all_teams, 257)
	var wrap_514: Dictionary = teams_state.source_team_get_state(all_teams, 514)
	proof["wrap_plus_one"] = wrap_257.get("team", {}).get("name") == "sharded" and wrap_257.get("wrapped_id") == 1 and wrap_514.get("team", {}).get("name") == "crux" and wrap_514.get("wrapped_id") == 2

	# Exactly 2 result keys: team, wrapped_id.
	proof["team_get_returns_two_keys"] = teams_state.source_team_get_state(all_teams, 1).size() == 2

	# A second call on the same inputs yields the same value:
	# get is a pure function of its inputs, with no hidden state
	# (no Team.all is kept between calls).
	var second: Dictionary = teams_state.source_team_get_state(all_teams, 257)
	proof["team_get_idempotent_second_call"] = second.get("team", {}).get("name") == "sharded" and second.get("wrapped_id") == 1 and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamGetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
