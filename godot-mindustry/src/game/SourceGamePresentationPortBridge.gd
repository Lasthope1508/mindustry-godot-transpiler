extends "res://src/game/SourceCampaignShellPortBridge.gd"

const source_game_runtime_summary_state := preload("res://src/game/SourceGameRuntimeSummaryState.gd")
const source_hud_runtime_state := preload("res://src/game/SourceHudRuntimeState.gd")

func playthrough_runtime_state() -> Dictionary:
	return source_game_runtime_summary_state.playthrough_state(self)

func game_over_runtime_state() -> Dictionary:
	return source_game_runtime_summary_state.game_over_runtime_state(self)

func get_runtime_summary() -> Dictionary:
	return source_game_runtime_summary_state.summary_state(self)

func update_hud() -> void:
	var hud_label := get("hud_label") as Label
	if hud_label == null:
		return
	hud_label.text = source_hud_runtime_state.game_hud_text(self)
