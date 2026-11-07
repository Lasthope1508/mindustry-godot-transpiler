extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_core_damage_runtime_state := preload("res://src/game/SourceCoreDamageRuntimeState.gd")
const source_game_over_core_destroyed_state_script := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game_over_state := source_game_over_core_destroyed_state_script.core_destroyed_state(10.0, true, false)
	var module := source_core_damage_runtime_state.apply_state(15.0, 10.0, 2.0, true, game_over_state, "")
	var wrapper_game := PortGameScript.new()
	wrapper_game.load_content_registry()
	wrapper_game.core_health = 10.0
	wrapper_game.core_damage_taken_total = 2.0
	wrapper_game.game_over = true
	wrapper_game.last_game_over_winner = ""
	var wrapper := wrapper_game.apply_core_damage(15.0)
	var module_game := PortGameScript.new()
	module_game.load_content_registry()
	module_game.core_health = 10.0
	module_game.core_damage_taken_total = 2.0
	module_game.game_over = true
	module_game.last_game_over_winner = ""
	var module_wrapper := source_core_damage_runtime_state.game_apply_core_damage(module_game, 15.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "CORE_DAMAGE_RUNTIME_MODULE_PROOF",
		"wrapper_matches": wrapper == module,
		"module_wrapper_matches": module_wrapper == module,
		"applied": float(module.get("applied", 0.0)),
		"core_health_after": float(module.get("core_health", 0.0)),
		"core_damage_taken_total_after": float(module.get("core_damage_taken_total", 0.0)),
		"game_over": bool(module.get("game_over", false)),
		"winner": str(module.get("winner", "")),
		"game_over_triggered": bool(module.get("game_over_triggered", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	print("CORE_DAMAGE_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	wrapper_game.free()
	module_game.free()
	await get_tree().create_timer(20.0).timeout
	get_tree().quit(0)

