extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- GameState 9 accessors (N2454):
	# GameState 9 accessors (GameState.java:56-117). One grouped
	# slice (batch 43 slot 3): exactly the 9 body exprs
	# `return teams.bosses.firstOpt();` (:57),
	# `return rules.sector;` (:82),
	# `return rules.sector != null ? rules.sector.planet : rules.planet;` (:86),
	# `return rules.editor;` (:90),
	# `return state == State.playing;` (:99),
	# `return state != State.menu;` (:104),
	# `return state == State.menu;` (:108),
	# `return state == astate;` (:112),
	# `return state;` (:116).
	# Pure accessors: boss is the first boss or null when the
	# bosses seq is empty; sector passes through; planet comes
	# from the sector when present, else rules.planet; is_editor
	# passes through; the four state predicates read state_name
	# ("paused"/"playing"/"menu"); is_state compares state_name
	# with astate_name; state returns state_name. The proof
	# calls the pure function with synthetic frame inputs (no
	# live tick, no game).

	# boss() is the first boss when the bosses seq is non-empty.
	proof["boss_first_when_bosses_nonempty"] = String(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, ["boss-a", "boss-b"]).get("boss", "")) == "boss-a"

	# boss() is null when the bosses seq is empty (firstOpt()).
	proof["boss_null_when_bosses_empty"] = game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("boss", "not-null") == null

	# getSector() passes rules.sector through.
	proof["sector_returns_rules_sector"] = game_loop_state.source_game_loop_state_accessors_state("playing", "playing", {"name": "sector-x"}, "erekir", false, []).get("sector", {}) == {"name": "sector-x"}

	# getSector() is null when there is no sector.
	proof["sector_null_when_no_sector"] = game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("sector", "not-null") == null

	# getPlanet() reads sector.planet when there is a sector.
	proof["planet_from_sector_when_sector_present"] = String(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", {"planet": "serpulo"}, "erekir", false, []).get("planet", "")) == "serpulo"

	# getPlanet() falls back to rules.planet when there is no sector.
	proof["planet_falls_back_to_rules_planet_when_no_sector"] = String(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("planet", "")) == "erekir"

	# isEditor() passes rules.editor through (true).
	proof["is_editor_true_when_rules_editor"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", true, []).get("is_editor", false)) == true

	# isEditor() passes rules.editor through (false).
	proof["is_editor_false_when_not_editor"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("is_editor", true)) == false

	# isPlaying() is true when the state is playing.
	proof["is_playing_true_when_playing"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("is_playing", false)) == true

	# isPlaying() is false when the state is paused.
	proof["is_playing_false_when_paused"] = bool(game_loop_state.source_game_loop_state_accessors_state("paused", "paused", null, "erekir", false, []).get("is_playing", true)) == false

	# isGame() is true when the state is playing (not the menu).
	proof["is_game_true_when_playing"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("is_game", false)) == true

	# isGame() is false when the state is the menu.
	proof["is_game_false_when_menu"] = bool(game_loop_state.source_game_loop_state_accessors_state("menu", "menu", null, "erekir", false, []).get("is_game", true)) == false

	# isMenu() is true when the state is the menu.
	proof["is_menu_true_when_menu"] = bool(game_loop_state.source_game_loop_state_accessors_state("menu", "menu", null, "erekir", false, []).get("is_menu", false)) == true

	# isMenu() is false when the state is playing.
	proof["is_menu_false_when_playing"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("is_menu", true)) == false

	# is(State) is true when state_name equals astate_name.
	proof["is_state_true_when_equal"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "playing", null, "erekir", false, []).get("is_state", false)) == true

	# is(State) is false when state_name differs from astate_name.
	proof["is_state_false_when_different"] = bool(game_loop_state.source_game_loop_state_accessors_state("playing", "menu", null, "erekir", false, []).get("is_state", true)) == false

	# getState() returns state_name as-is.
	proof["state_returns_state_name"] = String(game_loop_state.source_game_loop_state_accessors_state("paused", "menu", null, "erekir", false, []).get("state", "")) == "paused"

	# Exactly the 9 payload keys plus the source_owner envelope key.
	var one_call: Dictionary = game_loop_state.source_game_loop_state_accessors_state("playing", "playing", {"planet": "serpulo"}, "erekir", true, ["boss-a"])
	proof["returns_owner_plus_nine_keys"] = one_call.size() == 10 and one_call.has("source_owner") and one_call.has("boss") and one_call.has("sector") and one_call.has("planet") and one_call.has("is_editor") and one_call.has("is_playing") and one_call.has("is_game") and one_call.has("is_menu") and one_call.has("is_state") and one_call.has("state")

	# A second call on the same inputs yields the same value:
	# the accessors are pure functions of their inputs, with no
	# hidden state.
	var second: Dictionary = game_loop_state.source_game_loop_state_accessors_state("playing", "playing", {"planet": "serpulo"}, "erekir", true, ["boss-a"])
	proof["idempotent_second_call"] = second == one_call and second.size() == 10

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07GameLoopStateAccessorsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
