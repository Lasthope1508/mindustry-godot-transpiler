extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_item_turret_init_state := preload("res://src/game/SourceItemTurretInitState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_turret_range_state := preload("res://src/game/SourceTurretRangeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var game := PortGameScript.new()
	var range_state := game.source_turret_limit_range_state({"rangeChange": 16.0, "extraRangeMargin": 4.0, "speed": 2.0}, 5.0, 80.0)
	var game_limit_range_state := source_turret_range_state.game_limit_range_state(game, {"rangeChange": 16.0, "extraRangeMargin": 4.0, "speed": 2.0}, 5.0, 80.0)
	var game_generated_bridge := source_turret_range_state.game_generated_limit_range_bridge_state(game, {"rangeChange": 16.0, "extraRangeMargin": 4.0, "speed": 2.0}, 5.0, 80.0)
	var power_state := game.source_power_turret_limit_range_state({"id": "lancer"}, 8.0)
	var item_default := game.source_item_turret_limit_range_default_state()
	var item_entries := game.source_item_turret_limit_range_entries_state(7.0, [{"value": {"id": "copper"}}])
	var item_default_bridge := game.generated_item_turret_limit_range_default_bridge_state()
	var item_entries_bridge := game.generated_item_turret_limit_range_entries_bridge_state(7.0, [{"value": {"id": "copper"}}])
	var item_init_bridge := game.generated_item_turret_init_ground_overlap_bridge_state(true, 0.0, 70.0, 3.0, [{"value": {"id": "graphite", "rangeChange": 8.0}}])
	var item_init_default_bridge := game.generated_item_turret_init_ground_overlap_default_bridge_state()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTurretRangeState",
		"range_matches": range_state.get("bullet_lifetime", null) == 57.5,
		"game_limit_range_matches": game_limit_range_state.get("bullet_lifetime", null) == range_state.get("bullet_lifetime", null),
		"game_generated_bridge_matches": bool(game_generated_bridge.get("matches", false)),
		"power_matches": power_state.get("limit_range_called", false),
		"item_default_matches": item_default.get("margin", null) == 9.0,
		"item_entries_matches": item_entries.get("limit_range_call_count", null) == 1,
		"item_default_bridge_matches": item_default_bridge == source_turret_range_state.generated_item_turret_limit_range_default_bridge_state(),
		"item_entries_bridge_matches": item_entries_bridge == source_turret_range_state.generated_item_turret_limit_range_entries_bridge_state(7.0, [{"value": {"id": "copper"}}]),
		"item_init_bridge_matches": item_init_bridge == source_item_turret_init_state.generated_item_turret_init_ground_overlap_bridge_state(true, 0.0, 70.0, 3.0, [{"value": {"id": "graphite", "rangeChange": 8.0}}]),
		"item_init_default_bridge_matches": item_init_default_bridge == source_item_turret_init_state.generated_item_turret_init_ground_overlap_default_bridge_state(),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["range_matches"] and proof["game_limit_range_matches"] and proof["game_generated_bridge_matches"] and proof["power_matches"] and proof["item_default_matches"] and proof["item_entries_matches"] and proof["item_default_bridge_matches"] and proof["item_entries_bridge_matches"] and proof["item_init_bridge_matches"] and proof["item_init_default_bridge_matches"]
	proof["matches"] = proof["module_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_RANGE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretRangeModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

