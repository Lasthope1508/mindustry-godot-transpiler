extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_stats_bars_state := preload("res://src/game/SourceBlockStatsBarsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var consumers := [{"id": "power"}, {"id": "items"}]
	var bar_map := {"health": "health-supplier", "power": "power-supplier"}
	var set_stats_bridge := game.generated_block_set_stats_bridge_state(2, true, 100.0, 4.0, true, 3, 120.0, true, consumers, true, 40.0, true, 50)
	var add_bar_bridge := game.generated_block_add_bar_bridge_state("items", "items-supplier", bar_map)
	var remove_bar_bridge := game.generated_block_remove_bar_bridge_state("power", bar_map)
	var list_bars_bridge := game.generated_block_list_bars_bridge_state(bar_map)
	var static_liquid_bridge := game.generated_block_add_liquid_bar_static_bridge_state("water", true, 12.0, 40.0, "Water", "water-color")
	var dynamic_liquid_bridge := game.generated_block_add_liquid_bar_dynamic_bridge_state("water", 12.0, 40.0, "Water", "water-color")
	var set_bars_bridge := game.generated_block_set_bars_bridge_state(true, true, true, 25, 50, 2, true, false)
	var after_patch_consumers := [{"id": "power"}, {"id": "items"}]
	var after_patch_bridge := game.generated_block_after_patch_stats_bars_bridge_state(2, 8.0, 3, 2, after_patch_consumers)
	var proof := {
		"module": "SourceBlockStatsBarsState",
		"set_stats_bridge_matches": set_stats_bridge == source_block_stats_bars_state.generated_block_set_stats_bridge_state(2, true, 100.0, 4.0, true, 3, 120.0, true, consumers, true, 40.0, true, 50) and bool(set_stats_bridge.get("matches", false)),
		"add_bar_bridge_matches": add_bar_bridge == source_block_stats_bars_state.generated_block_add_bar_bridge_state("items", "items-supplier", bar_map) and bool(add_bar_bridge.get("matches", false)),
		"remove_bar_bridge_matches": remove_bar_bridge == source_block_stats_bars_state.generated_block_remove_bar_bridge_state("power", bar_map) and bool(remove_bar_bridge.get("matches", false)),
		"list_bars_bridge_matches": list_bars_bridge == source_block_stats_bars_state.generated_block_list_bars_bridge_state(bar_map) and bool(list_bars_bridge.get("matches", false)),
		"static_liquid_bridge_matches": static_liquid_bridge == source_block_stats_bars_state.generated_block_add_liquid_bar_static_bridge_state("water", true, 12.0, 40.0, "Water", "water-color") and bool(static_liquid_bridge.get("matches", false)),
		"dynamic_liquid_bridge_matches": dynamic_liquid_bridge == source_block_stats_bars_state.generated_block_add_liquid_bar_dynamic_bridge_state("water", 12.0, 40.0, "Water", "water-color") and bool(dynamic_liquid_bridge.get("matches", false)),
		"set_bars_bridge_matches": set_bars_bridge == source_block_stats_bars_state.generated_block_set_bars_bridge_state(true, true, true, 25, 50, 2, true, false) and bool(set_bars_bridge.get("matches", false)),
		"after_patch_bridge_matches": after_patch_bridge == source_block_stats_bars_state.generated_block_after_patch_stats_bars_bridge_state(2, 8.0, 3, 2, after_patch_consumers) and bool(after_patch_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["set_stats_bridge_matches"] and proof["add_bar_bridge_matches"] and proof["remove_bar_bridge_matches"] and proof["list_bars_bridge_matches"] and proof["static_liquid_bridge_matches"] and proof["dynamic_liquid_bridge_matches"] and proof["set_bars_bridge_matches"] and proof["after_patch_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("BlockStatsBarsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
