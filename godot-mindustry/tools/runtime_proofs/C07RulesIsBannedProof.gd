extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.isBanned(Block) (N2465):
	# Rules.isBanned(Block) (Rules.java:307-309):
	#     return blockWhitelist != bannedBlocks.contains(block);
	# TRAP: the whitelist INVERTS the answer -- with the
	# whitelist on, a block IN the set is allowed (false)
	# and a block NOT in the set is banned (true); with an
	# empty set and the whitelist on, EVERY block is banned.
	# A port that reads isBanned as "is in the set" (==
	# instead of !=) is wrong in both whitelist cases.
	# TRAP: blockWhitelist defaults to false (:145) and
	# bannedBlocks defaults to empty (:181), so a missing
	# key means blacklist mode with nothing banned. The
	# block travels as its String name (precedent N2460
	# GameStats.getPlaced). The proof calls the pure
	# function with synthetic rules dicts (no live tick,
	# no game state).

	# Blacklist: a listed block is banned.
	var blacklist_rules: Dictionary = {"blockWhitelist": false, "bannedBlocks": ["copper-wall"]}
	proof["blacklist_bans_listed"] = rules_state.source_rules_is_banned_state(blacklist_rules, "copper-wall").get("is_banned") == true

	# Blacklist: an unlisted block is allowed.
	proof["blacklist_allows_unlisted"] = rules_state.source_rules_is_banned_state(blacklist_rules, "duo").get("is_banned") == false

	# TRAP: whitelist on -- a block IN the set is allowed,
	# not banned.
	var whitelist_rules: Dictionary = {"blockWhitelist": true, "bannedBlocks": ["copper-wall"]}
	proof["whitelist_allows_listed"] = rules_state.source_rules_is_banned_state(whitelist_rules, "copper-wall").get("is_banned") == false

	# TRAP: whitelist on + empty set -- EVERY block is
	# banned, because nothing is whitelisted.
	var whitelist_empty_rules: Dictionary = {"blockWhitelist": true, "bannedBlocks": []}
	proof["whitelist_bans_all_when_empty"] = rules_state.source_rules_is_banned_state(whitelist_empty_rules, "duo").get("is_banned") == true

	# Blacklist with an empty set bans nothing.
	var blacklist_empty_rules: Dictionary = {"blockWhitelist": false, "bannedBlocks": []}
	proof["blacklist_empty_allows_all"] = rules_state.source_rules_is_banned_state(blacklist_empty_rules, "duo").get("is_banned") == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesIsBannedProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
