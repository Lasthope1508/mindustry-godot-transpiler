extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceBaseTurretDrawState := preload("res://src/game/SourceBaseTurretDrawState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var source_state := game.source_base_turret_draw_place_state(4, 5, 1, true, 8.0, 4.0, 80.0, 0.5, true)
	var module_state := SourceBaseTurretDrawState.draw_place_state(4, 5, 1, true, 8.0, 4.0, 80.0, 0.5, true)
	var bridge_state := game.generated_base_turret_draw_place_bridge_state(4, 5, 1, true, 8.0, 4.0, 80.0, 0.5, true)
	var proof := {
		"module": "SourceBaseTurretDrawState",
		"source_matches_module": source_state == module_state,
		"bridge_matches": bool(bridge_state.get("matches", false)),
		"dash_circle_call": module_state.get("dash_circle_call", {}),
		"fog_dash_circle_called": bool(module_state.get("fog_dash_circle_called", false)),
	}
	print("BASE_TURRET_DRAW_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(10.0).timeout
	get_tree().quit(0)
