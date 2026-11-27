extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- GameState.hasSector() (N2483):
	# GameState.hasSector() (GameState.java:77-79):
	#     return rules.sector != null;
	# Body IDENTICAL to isCampaign() (:73-75, N2474) -- the
	# two methods sit next to each other in the real Java.
	# TRAP: NO fallback to rules.planet -- unlike getPlanet()
	# (N2454: `return rules.sector != null ?
	# rules.sector.planet : rules.planet;`), sector null is
	# false even when rules.planet is non-null. The proof
	# calls the pure function with synthetic sector/planet
	# pairs (no live tick, no game state); the sector arrives
	# as a Variant (null when absent, a Dictionary carrying
	# "planet" when present -- the N2454 precedent). It
	# cross-pins hasSector against isCampaign (N2474): the
	# same inputs give the same result on all 4 combinations.
	# TWIN-REGISTER (main thread approved explicitly
	# 2026-11-27): the literal `return rules.sector !=
	# null;` is also an exact_expr of N2124 (original
	# owner, cited only as dependency evidence for
	# unlockedNowHost()) and of N2474 (isCampaign, twin
	# sibling).

	# TRAP: sector null + planet present is false -- a port
	# that falls back to rules.planet (like getPlanet()) is
	# wrong.
	proof["sector_null_planet_present_is_false"] = game_loop_state.source_game_state_has_sector_state(null, "erekir").get("has_sector") == false

	# Sector present + planet null is true -- the planet is
	# never consulted.
	proof["sector_present_planet_null_is_true"] = game_loop_state.source_game_state_has_sector_state({"name": "sector-x"}, null).get("has_sector") == true

	# Both null is false.
	proof["both_null_is_false"] = game_loop_state.source_game_state_has_sector_state(null, null).get("has_sector") == false

	# Both present is true.
	proof["both_present_is_true"] = game_loop_state.source_game_state_has_sector_state({"planet": "serpulo"}, "erekir").get("has_sector") == true

	# A sector Dictionary without a "planet" key is still a
	# sector -- presence, not contents, decides.
	proof["sector_dict_without_planet_is_true"] = game_loop_state.source_game_state_has_sector_state({"name": "sector-x"}, "erekir").get("has_sector") == true

	# Cross-pin with isCampaign (N2474): the two Java bodies
	# are identical, so the same inputs must give the same
	# result on all 4 sector/planet combinations.
	proof["cross_pin_is_campaign_all_four"] = game_loop_state.source_game_state_has_sector_state(null, null).get("has_sector") == game_loop_state.source_game_state_is_campaign_state(null, null).get("is_campaign") and game_loop_state.source_game_state_has_sector_state(null, "erekir").get("has_sector") == game_loop_state.source_game_state_is_campaign_state(null, "erekir").get("is_campaign") and game_loop_state.source_game_state_has_sector_state({"name": "sector-x"}, null).get("has_sector") == game_loop_state.source_game_state_is_campaign_state({"name": "sector-x"}, null).get("is_campaign") and game_loop_state.source_game_state_has_sector_state({"planet": "serpulo"}, "erekir").get("has_sector") == game_loop_state.source_game_state_is_campaign_state({"planet": "serpulo"}, "erekir").get("is_campaign")

	# Exactly the 1 payload key plus the source_owner envelope key.
	var one_call: Dictionary = game_loop_state.source_game_state_has_sector_state({"planet": "serpulo"}, "erekir")
	proof["returns_owner_plus_one_key"] = one_call.size() == 2 and one_call.has("source_owner") and one_call.has("has_sector")

	# A second call on the same inputs yields the same value:
	# the predicate is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = game_loop_state.source_game_state_has_sector_state({"planet": "serpulo"}, "erekir")
	proof["idempotent_second_call"] = second == one_call and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07GameStateHasSectorProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
