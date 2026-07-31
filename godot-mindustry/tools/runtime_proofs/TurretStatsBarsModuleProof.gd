extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_stats_bars_state := preload("res://src/game/SourceTurretStatsBarsState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var shoot_type := {"id": "laser", "damage": 12.0}
	var ammo_types := [{"liquid": "water", "bullet": {"id": "water-shot"}}]
	var base_stats_bridge := game.generated_base_turret_set_stats_bridge_state(120.0, 8.0, 60.0)
	var turret_stats_bridge := game.generated_turret_set_stats_bridge_state(3.0, 45.0, false, 5.0, 2.0, true, false, 2, 10.0, 1.5)
	var item_bars_bridge := game.generated_item_turret_set_bars_bridge_state(12.0, 24.0)
	var continuous_liquid_bridge := game.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, 0.35)
	var proof := {
		"module": "SourceTurretStatsBarsState",
		"base_stats_bridge_shoot_range_matches": base_stats_bridge.get("result", {}).get("shoot_range_stat_call", null) == base_stats_bridge.get("canonical", {}).get("shoot_range_stat_call", null),
		"base_stats_bridge_activation_time_matches": base_stats_bridge.get("result", {}).get("activation_time_stat_call", null) == base_stats_bridge.get("canonical", {}).get("activation_time_stat_call", null),
		"base_stats_bridge_super_matches": base_stats_bridge.get("result", {}).get("super_set_stats_called", null) == base_stats_bridge.get("canonical", {}).get("super_set_stats_called", null),
		"base_stats_bridge_matches": bool(base_stats_bridge.get("matches", false)) and base_stats_bridge.get("source_owner", "") == "source_turret_stats_bars_state.base_turret_set_stats_state" and base_stats_bridge.get("generated_owner", "") == "base_turret.java_method_setStats_4",
		"turret_stats_bridge_matches": turret_stats_bridge == source_turret_stats_bars_state.generated_turret_set_stats_bridge_state(3.0, 45.0, false, 5.0, 2.0, true, false, 2, 10.0, 1.5) and bool(turret_stats_bridge.get("matches", false)),
		"item_bars_bridge_matches": item_bars_bridge == source_turret_stats_bars_state.generated_item_turret_set_bars_bridge_state(12.0, 24.0) and bool(item_bars_bridge.get("matches", false)),
		"continuous_liquid_bridge_matches": continuous_liquid_bridge == source_turret_stats_bars_state.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, 0.35) and bool(continuous_liquid_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"shoot_type": shoot_type,
	}
	proof["matches"] = proof["base_stats_bridge_matches"] and proof["turret_stats_bridge_matches"] and proof["item_bars_bridge_matches"] and proof["continuous_liquid_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("TURRET_STATS_BARS_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/TurretStatsBarsModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
