extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_hud_runtime_state := preload("res://src/game/SourceHudRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_hud_runtime_state.default_callbacks_state(game)
	var expected_callbacks := {
		"requirements_text": Callable(game, "requirements_text"),
	}
	var wrapper := source_hud_runtime_state.game_hud_text(game)
	var module := source_hud_runtime_state.hud_text(game, callbacks.get("requirements_text", Callable()))
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceHudRuntimeState",
		"game_hud_text_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["game_hud_text_matches"] and proof["default_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("HUD_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("HudRuntimeStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

