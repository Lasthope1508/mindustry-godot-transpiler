extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceConsumeLiquidState := preload("res://src/game/SourceConsumeLiquidState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceConsumeLiquidState.default_callbacks_state(game)
	var default_callbacks_match: bool = callbacks.get("base_apply_state", Callable()) == Callable(game, "source_consume_liquid_base_apply_state")
	var wrapper := game.source_consume_liquid_apply_state(true, [false, false], 1)
	var module := SourceConsumeLiquidState.apply_state(true, [false, false], 1, callbacks.get("base_apply_state", Callable()))
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidState",
		"matches": wrapper == module,
		"default_callbacks_match": default_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("CONSUME_LIQUID_APPLY_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
