extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.isBanned(UnitType) (N2469):
	# Rules.isBanned(UnitType) (Rules.java:311-313):
	#     return unitWhitelist != bannedUnits.contains(unit);
	# TRAP: the whitelist INVERTS the answer -- with the
	# whitelist on, a unit IN the set is allowed (false)
	# and a unit NOT in the set is banned (true); with an
	# empty set and the whitelist on, EVERY unit is banned.
	# A port that reads isBanned as "is in the set" (==
	# instead of !=) is wrong in both whitelist cases.
	# TRAP: do not copy N2465's field names -- this method
	# reads unitWhitelist/bannedUnits, not blockWhitelist/
	# bannedBlocks. TRAP: unitWhitelist defaults to false
	# (:147) and bannedUnits defaults to empty (:183), so a
	# missing key means blacklist mode with nothing banned.
	# The unit travels as its String name (same precedent as
	# N2465 isBanned(Block)). The proof calls the pure
	# function with synthetic rules dicts (no live tick,
	# no game state).

	# Blacklist: a listed unit is banned.
	var blacklist_rules: Dictionary = {"unitWhitelist": false, "bannedUnits": ["dagger"]}
	proof["blacklist_bans_listed"] = rules_state.source_rules_is_banned_unit_state(blacklist_rules, "dagger").get("is_banned") == true

	# Blacklist: an unlisted unit is allowed.
	proof["blacklist_allows_unlisted"] = rules_state.source_rules_is_banned_unit_state(blacklist_rules, "flare").get("is_banned") == false

	# TRAP: whitelist on -- a unit IN the set is allowed,
	# not banned.
	var whitelist_rules: Dictionary = {"unitWhitelist": true, "bannedUnits": ["dagger"]}
	proof["whitelist_allows_listed"] = rules_state.source_rules_is_banned_unit_state(whitelist_rules, "dagger").get("is_banned") == false

	# TRAP: whitelist on + empty set -- EVERY unit is
	# banned, because nothing is whitelisted.
	var whitelist_empty_rules: Dictionary = {"unitWhitelist": true, "bannedUnits": []}
	proof["whitelist_bans_all_when_empty"] = rules_state.source_rules_is_banned_unit_state(whitelist_empty_rules, "dagger").get("is_banned") == true

	# Blacklist with an empty set bans nothing.
	var blacklist_empty_rules: Dictionary = {"unitWhitelist": false, "bannedUnits": []}
	proof["blacklist_empty_allows_all"] = rules_state.source_rules_is_banned_unit_state(blacklist_empty_rules, "dagger").get("is_banned") == false

	# Missing keys default to blacklist mode with an empty
	# set, so nothing is banned.
	var missing_rules: Dictionary = {}
	proof["missing_keys_default"] = rules_state.source_rules_is_banned_unit_state(missing_rules, "dagger").get("is_banned") == false

	# Multi-entry set: a listed unit is banned, an unlisted
	# one is allowed (blacklist mode).
	var multi_rules: Dictionary = {"unitWhitelist": false, "bannedUnits": ["dagger", "flare"]}
	proof["multiple_entries"] = rules_state.source_rules_is_banned_unit_state(multi_rules, "flare").get("is_banned") == true and rules_state.source_rules_is_banned_unit_state(multi_rules, "crawler").get("is_banned") == false

	# Whitelist with several entries: an unlisted unit is
	# banned, a listed one is allowed.
	var whitelist_multi_rules: Dictionary = {"unitWhitelist": true, "bannedUnits": ["dagger", "flare"]}
	proof["whitelist_multiple"] = rules_state.source_rules_is_banned_unit_state(whitelist_multi_rules, "crawler").get("is_banned") == true and rules_state.source_rules_is_banned_unit_state(whitelist_multi_rules, "flare").get("is_banned") == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesIsBannedUnitProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
