extends Node

const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Team.localized() (N2494):
	# Team.localized() (Team.java:135-137):
	#     public String localized(){
	#         return Core.bundle.get("team." + name + ".name", name);
	#     }
	# Core.bundle.get(key, def) is I18NBundle.get (arc-core
	# I18NBundle.java:412-414): `has(key) ? get(key) : def`
	# for the key "team." + name + ".name". Core.bundle is
	# NOT ported here, so the raw lookup result arrives as
	# the precomputed bundle_value input (the
	# getOrNull-equivalent: null when the key is absent;
	# N1271 ability_localized.bundle_get precedent). Only
	# a missing key falls back to the name. The proof
	# calls the pure function with synthetic inputs (no
	# live tick, no game state).

	# Bundle hit: the key exists, the bundle value wins
	# over the raw team name.
	proof["localized_bundle_hit"] = teams_state.source_team_localized_state("sharded", "Sharded").get("localized") == "Sharded"

	# Bundle miss: a null bundle value falls back to the
	# team name itself.
	proof["localized_bundle_missing_falls_back_to_name"] = teams_state.source_team_localized_state("sharded", null).get("localized") == "sharded"

	# TRAP: an empty bundle value is a real value, not a
	# miss -- it passes through, the name is NOT used.
	proof["localized_empty_bundle_value_is_not_missing"] = teams_state.source_team_localized_state("crux", "").get("localized") == ""

	# TRAP: the bundle value is a PRECOMPUTED input -- the
	# function uses the given value verbatim and never
	# re-derives it from the team name, so a custom
	# localized string passes through untouched.
	proof["localized_custom_bundle_value_verbatim"] = teams_state.source_team_localized_state("green", "My Custom Team").get("localized") == "My Custom Team"

	# A dotted name falls back verbatim on a miss -- the
	# fallback does not mangle the name (the key would
	# have been "team.a.b.name", the lookup simply missed).
	proof["localized_missing_with_dotted_name"] = teams_state.source_team_localized_state("a.b", null).get("localized") == "a.b"

	# A non-ASCII bundle value passes through untouched.
	proof["localized_hit_with_unicode_value"] = teams_state.source_team_localized_state("sharded", "Đội Sharded").get("localized") == "Đội Sharded"

	# Calling twice with the same inputs gives the same
	# result.
	proof["localized_idempotent"] = teams_state.source_team_localized_state("sharded", "Sharded").get("localized") == teams_state.source_team_localized_state("sharded", "Sharded").get("localized")

	# The result carries exactly the one key.
	var one_key_result: Dictionary = teams_state.source_team_localized_state("sharded", "Sharded")
	proof["localized_returns_only_one_key"] = one_key_result.size() == 1 and one_key_result.has("localized")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamLocalizedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
