extends Node

const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Rules.mode() (N2458):
	# Rules.mode() (Rules.java:249-261): the 5 branches in Java
	# order -- pvp > editor > attackMode > infiniteResources >
	# survival (default). TRAP: the priority order is the whole
	# slice -- pvp=true wins even when editor, attackMode and
	# infiniteResources are all true too, so the branches must
	# be checked in Java order and must not be reordered
	# (checking infiniteResources first would return "sandbox"
	# for an attack game). TRAP: a missing flag means the Java
	# field default (false) -- all four booleans default to
	# false (pvp :41, editor :51, attackMode :49,
	# infiniteResources :27) -- so an empty rules state is
	# survival. The Gamemode enum is returned as its String
	# name (precedent N2454: GameState `state` travels as
	# `state_name`). The proof calls the pure function with
	# synthetic rules dicts (no live tick, no game state).

	# All flags false is the default branch: survival.
	var all_false: Dictionary = {"pvp": false, "editor": false, "attackMode": false, "infiniteResources": false}
	var survival_result: Dictionary = rules_state.source_rules_mode_state(all_false)
	proof["all_flags_false_returns_survival"] = survival_result.get("mode") == "survival" and survival_result.size() == 1

	# TRAP: pvp beats every other flag, even all of them at once.
	var all_true: Dictionary = {"pvp": true, "editor": true, "attackMode": true, "infiniteResources": true}
	proof["pvp_beats_all_flags"] = rules_state.source_rules_mode_state(all_true).get("mode") == "pvp"

	# editor beats attack and sandbox (pvp false).
	var editor_rules: Dictionary = {"pvp": false, "editor": true, "attackMode": true, "infiniteResources": true}
	proof["editor_beats_attack_and_sandbox"] = rules_state.source_rules_mode_state(editor_rules).get("mode") == "editor"

	# attack beats sandbox (pvp and editor false).
	var attack_rules: Dictionary = {"pvp": false, "editor": false, "attackMode": true, "infiniteResources": true}
	proof["attack_beats_sandbox"] = rules_state.source_rules_mode_state(attack_rules).get("mode") == "attack"

	# Only infiniteResources set is sandbox.
	var sandbox_rules: Dictionary = {"pvp": false, "editor": false, "attackMode": false, "infiniteResources": true}
	proof["sandbox_only"] = rules_state.source_rules_mode_state(sandbox_rules).get("mode") == "sandbox"

	# TRAP: missing flags default to the Java false -- an empty
	# rules state is survival, not an error.
	proof["missing_keys_default_survival"] = rules_state.source_rules_mode_state({}).get("mode") == "survival"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RulesModeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
