extends Node

const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Team.coloredName() (N2488):
	# Team.coloredName() (Team.java:139-141):
	#     public String coloredName(){
	#         return emoji + "[#" + color + "]" + localized() + "[]";
	#     }
	# Plain string concatenation: no guard, no clamp, no
	# escaping. `emoji` is the `public String` field
	# (Team.java:23, default ""); `color` is the `public
	# final Color` field (Team.java:18) -- the "[#" +
	# color + "]" segment stringifies it via arc
	# Color.toString() (RRGGBBAA, 8 hex chars), so it
	# arrives as the precomputed color_hex string.
	# localized() (Team.java:135-137) is NOT ported here
	# (it needs Core.bundle) -- its value arrives as the
	# precomputed localized_name input. The proof calls
	# the pure function with synthetic string inputs (no
	# live tick, no game state).

	# Sharded with the default empty emoji: no glyph
	# prefix, just the color markup around "Sharded".
	proof["colored_name_sharded"] = teams_state.source_team_colored_name_state("", "ffd37fff", "Sharded").get("colored_name") == "[#ffd37fff]Sharded[]"

	# A team with an emoji glyph: the glyph leads, then
	# the color markup, then the localized name.
	proof["colored_name_with_emoji"] = teams_state.source_team_colored_name_state("★", "54d67dff", "Green").get("colored_name") == "★[#54d67dff]Green[]"

	# TRAP: an empty localized name leaves "[#...][]" --
	# the markup is still emitted, nothing is skipped.
	proof["colored_name_empty_localized"] = teams_state.source_team_colored_name_state("", "4d4e58ff", "").get("colored_name") == "[#4d4e58ff][]"

	# TRAP: the "[#", "]" and "[]" markup literals pass
	# through verbatim -- no escaping, no stripping.
	var markup_result: Dictionary = teams_state.source_team_colored_name_state("", "f25555ff", "Crux")
	var markup_name: String = markup_result.get("colored_name", "")
	proof["colored_name_markup_literals_verbatim"] = markup_name.contains("[#") and markup_name.contains("]") and markup_name.ends_with("[]")

	# The concat order is emoji, then the color markup,
	# then the localized name, then the closing "[]".
	var order_name: String = teams_state.source_team_colored_name_state("★", "f25555ff", "Crux").get("colored_name", "")
	proof["colored_name_concat_order"] = order_name.find("★") < order_name.find("[#") and order_name.find("[#") < order_name.find("f25555ff") and order_name.find("f25555ff") < order_name.find("]") and order_name.find("]") < order_name.find("Crux") and order_name.ends_with("[]")

	# TRAP: localized() is a PRECOMPUTED input -- the
	# function uses the given value verbatim and never
	# re-derives it from a bundle or a team name, so a
	# custom localized string passes through untouched.
	proof["colored_name_localized_is_precomputed_input"] = teams_state.source_team_colored_name_state("", "ffd37fff", "My Custom Team").get("colored_name") == "[#ffd37fff]My Custom Team[]"

	# Calling twice with the same inputs gives the same
	# result.
	proof["colored_name_idempotent"] = teams_state.source_team_colored_name_state("★", "54d67dff", "Green").get("colored_name") == teams_state.source_team_colored_name_state("★", "54d67dff", "Green").get("colored_name")

	# The result carries exactly the one key.
	var one_key_result: Dictionary = teams_state.source_team_colored_name_state("", "ffd37fff", "Sharded")
	proof["colored_name_returns_only_one_key"] = one_key_result.size() == 1 and one_key_result.has("colored_name")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamColoredNameProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
