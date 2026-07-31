extends RefCounted
class_name SourceCoreDamageRuntimeState

const source_game_over_core_destroyed_state_script := preload("res://src/game/SourceGameOverCoreDestroyedState.gd")
const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func apply_state(amount: float, core_health: float, core_damage_taken_total: float, game_over: bool, game_over_state: Dictionary, last_game_over_winner: String) -> Dictionary:
	var applied: float = min(core_health, max(0.0, amount))
	var core_damage: float = applied
	var core_health_after: float = max(0.0, core_health - core_damage)
	var core_damage_taken_total_after: float = core_damage_taken_total + core_damage
	var game_over_after: bool = game_over
	var last_game_over_winner_after: String = last_game_over_winner
	var game_over_triggered: bool = bool(game_over_state.get("game_over", false))
	if game_over_triggered:
		game_over_after = true
		last_game_over_winner_after = str(game_over_state.get("winner", ""))
	return {
		"source_owner": source_runtime_owner_registry.PORT_GAME_APPLY_CORE_DAMAGE,
		"amount": amount,
		"applied": applied,
		"core_health_before": core_health,
		"core_health": core_health_after,
		"core_damage_taken_total_before": core_damage_taken_total,
		"core_damage_taken_total": core_damage_taken_total_after,
		"game_over_before": game_over,
		"game_over": game_over_after,
		"winner_before": last_game_over_winner,
		"winner": last_game_over_winner_after,
		"game_over_triggered": game_over_triggered,
		"game_over_state": game_over_state.duplicate(true) if game_over_state is Dictionary else {},
	}

static func game_apply_core_damage(game: Object, amount: float) -> Dictionary:
	var game_over_state: Dictionary = game.source_game_over_core_destroyed_state(game.core_health, game.game_over)
	var damage_state := apply_state(amount, game.core_health, game.core_damage_taken_total, game.game_over, game_over_state, game.last_game_over_winner)
	game.core_health = float(damage_state.get("core_health", game.core_health))
	game.core_damage_taken_total = float(damage_state.get("core_damage_taken_total", game.core_damage_taken_total))
	game.game_over = bool(damage_state.get("game_over", game.game_over))
	game.last_game_over_winner = str(damage_state.get("winner", game.last_game_over_winner))
	return damage_state
