extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_consume_liquid_state := preload("res://src/game/SourceConsumeLiquidState.gd")
const source_consume_liquid_generated_state := preload("res://src/game/SourceConsumeLiquidGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_consume_liquid_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY: Callable(game, source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_FALLBACK),
	}
	var default_callbacks_match: bool = callbacks == expected_callbacks
	var override_callbacks := source_consume_liquid_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY, Callable()) == Callable(self, "proof_base_apply_state")
	var wrapper := game.source_consume_liquid_apply_state(true, [false, false], 1)
	var module := source_consume_liquid_state.game_apply_state(game, true, [false, false], 1)
	var override_module := source_consume_liquid_state.game_apply_state(self, false, [false], 0)
	var bridge_wrapper := game.generated_consume_liquid_apply_bridge_state(true, [false, false], 1)
	var bridge_module := source_consume_liquid_generated_state.game_generated_apply_bridge_state(game, true, [false, false], 1)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConsumeLiquidState",
		"matches": wrapper == module,
		"game_apply_matches": wrapper == module,
		"game_generated_apply_matches": bridge_wrapper == bridge_module,
		"default_callbacks_match": default_callbacks_match,
		"override_callbacks_match": override_callbacks_match,
		"override_apply_matches": bool(override_module.get("base_apply_state", {}).get("proof_base_apply_state", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["game_apply_matches"] and proof["game_generated_apply_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_apply_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSUME_LIQUID_APPLY_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().process_frame
	get_tree().quit(0)

func proof_base_apply_state(block_has_liquids_before: bool) -> Dictionary:
	return {
		"proof_base_apply_state": true,
		"block_has_liquids_before": block_has_liquids_before,
		"block_has_liquids_after": true,
	}

func _consume_liquid_method_names() -> Dictionary:
	return {
		source_consume_liquid_state.SOURCE_CONSUME_LIQUID_BASE_APPLY_STATE_KEY: "proof_base_apply_state",
	}

