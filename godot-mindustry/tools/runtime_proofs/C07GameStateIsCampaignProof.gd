extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- GameState.isCampaign() (N2474):
	# GameState.isCampaign() (GameState.java:72-75):
	#     return rules.sector != null;
	# TRAP: NO fallback to rules.planet -- unlike getPlanet()
	# (N2454: `return rules.sector != null ?
	# rules.sector.planet : rules.planet;`), sector null is
	# false even when rules.planet is non-null. The proof
	# calls the pure function with synthetic sector/planet
	# pairs (no live tick, no game state); the sector arrives
	# as a Variant (null when absent, a Dictionary carrying
	# "planet" when present -- the N2454 precedent).
	# TWIN-REGISTER (main thread approved explicitly): the
	# literal `return rules.sector != null;` is also an
	# exact_expr of N2124, cited there only as dependency
	# evidence for unlockedNowHost() -- N2124 ports no
	# isCampaign function.

	# TRAP: sector null + planet present is false -- a port
	# that falls back to rules.planet (like getPlanet()) is
	# wrong.
	proof["sector_null_planet_present_is_false"] = game_loop_state.source_game_state_is_campaign_state(null, "erekir").get("is_campaign") == false

	# Sector present + planet null is true -- the planet is
	# never consulted.
	proof["sector_present_planet_null_is_true"] = game_loop_state.source_game_state_is_campaign_state({"name": "sector-x"}, null).get("is_campaign") == true

	# Both null is false.
	proof["both_null_is_false"] = game_loop_state.source_game_state_is_campaign_state(null, null).get("is_campaign") == false

	# Both present is true.
	proof["both_present_is_true"] = game_loop_state.source_game_state_is_campaign_state({"planet": "serpulo"}, "erekir").get("is_campaign") == true

	# A sector Dictionary without a "planet" key is still a
	# sector -- presence, not contents, decides.
	proof["sector_dict_without_planet_is_true"] = game_loop_state.source_game_state_is_campaign_state({"name": "sector-x"}, "erekir").get("is_campaign") == true

	# The same (null, "erekir") inputs give planet "erekir"
	# through getPlanet() (N2454) while isCampaign is false
	# -- the two methods diverge exactly on the fallback.
	proof["get_planet_fallback_contrast"] = game_loop_state.source_game_state_is_campaign_state(null, "erekir").get("is_campaign") == false and String(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("planet", "")) == "erekir"

	# Exactly the 1 payload key plus the source_owner envelope key.
	var one_call: Dictionary = game_loop_state.source_game_state_is_campaign_state({"planet": "serpulo"}, "erekir")
	proof["returns_owner_plus_one_key"] = one_call.size() == 2 and one_call.has("source_owner") and one_call.has("is_campaign")

	# A second call on the same inputs yields the same value:
	# the predicate is a pure function of its inputs, with no
	# hidden state.
	var second: Dictionary = game_loop_state.source_game_state_is_campaign_state({"planet": "serpulo"}, "erekir")
	proof["idempotent_second_call"] = second == one_call and second.size() == 2

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07GameStateIsCampaignProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
