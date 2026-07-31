extends RefCounted
class_name SourceGameOverCoreDestroyedState

const source_runtime_owner_registry := preload("res://src/game/SourceRuntimeOwnerRegistry.gd")

static func core_destroyed_state(core_health_value: float, game_over_value: bool, attack_mode := false) -> Dictionary:
	var core_destroyed := core_health_value <= 0.0
	var game_over_after := game_over_value or core_destroyed
	var winner := "crux" if attack_mode and core_destroyed else "waveTeam" if core_destroyed else ""
	return {"source_owner": source_runtime_owner_registry.SOURCE_GAME_OVER_CORE_DESTROYED_STATE, "method": "private void checkGameState(){", "core_destroyed_expr": "state.teams.playerCores().size == 0", "game_over_expr": "state.gameOver = true;", "event_expr": "Events.fire(new GameOverEvent(state.rules.waveTeam));", "core_health": core_health_value, "game_over_before": game_over_value, "attack_mode": attack_mode, "core_destroyed": core_destroyed, "game_over": game_over_after, "winner": winner}
