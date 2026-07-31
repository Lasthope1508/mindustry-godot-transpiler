extends Node

const port_game := preload("res://src/game/PortGame.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := port_game.new()
	var source_symbol_state := game.source_symbol_registry_state()
	var module_symbol_state := source_ssot_accessor_runtime_state.source_symbol_registry_state()
	var asset_state := game.asset_manifest_state()
	var module_asset_state := source_ssot_accessor_runtime_state.asset_manifest_state()
	var registry_state := game.ssot_headquarter_registry_state()
	var proof := {
		"module": "SourceSsotAccessorRuntimeState",
		"source_matches_module": source_symbol_state == module_symbol_state and asset_state == module_asset_state,
		"source_symbol_loaded": bool(source_symbol_state.get("loaded", false)),
		"asset_manifest_loaded": bool(asset_state.get("loaded", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("SSOT_ACCESSOR_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(20.0).timeout
