extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_base_turret_stats_bars_state := preload("res://src/game/SourceBaseTurretStatsBarsState.gd")
const source_specialized_turret_stats_state := preload("res://src/game/SourceSpecializedTurretStatsState.gd")
const source_turret_stats_bars_state := preload("res://src/game/SourceTurretStatsBarsState.gd")
const source_point_defense_turret_defaults := preload("res://src/game/SourcePointDefenseTurretDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var shoot_type := {"id": "laser", "damage": 12.0}
	var ammo_types := [{"liquid": "water", "bullet": {"id": "water-shot"}}]
	var base_stats_state := game.source_base_turret_set_stats_state(120.0, 8.0, 60.0)
	var base_stats_module_state := source_base_turret_stats_bars_state.base_turret_set_stats_state(120.0, 8.0, 60.0, source_time_defaults.TICK_RATE)
	var base_stats_bridge := game.generated_base_turret_set_stats_bridge_state(120.0, 8.0, 60.0)
	var base_stats_module_bridge := source_base_turret_stats_bars_state.generated_base_turret_set_stats_bridge_state(120.0, 8.0, 60.0, source_time_defaults.TICK_RATE)
	var base_bars_state := game.source_base_turret_set_bars_state(60.0, 30.0)
	var base_bars_module_state := source_base_turret_stats_bars_state.base_turret_set_bars_state(60.0, 30.0, source_time_defaults.TICK_RATE)
	var base_bars_bridge := game.generated_base_turret_set_bars_bridge_state(60.0, 30.0)
	var base_bars_module_bridge := source_base_turret_stats_bars_state.generated_base_turret_set_bars_bridge_state(60.0, 30.0, source_time_defaults.TICK_RATE)
	var specialized_states_match := [
		game.source_tractor_beam_turret_set_stats_state(true, false, 4.0) == source_specialized_turret_stats_state.tractor_beam_turret_set_stats_state(true, false, 4.0, source_time_defaults.TICK_RATE),
		game.source_reload_turret_set_stats_state(true, 45.0, 0.2, 1.5) == source_specialized_turret_stats_state.reload_turret_set_stats_state(true, 45.0, 0.2, 1.5),
		game.source_point_defense_turret_set_stats_state(source_point_defense_turret_defaults.BULLET_DAMAGE_DEFAULT, source_turret_defaults.RELOAD_DEFAULT) == source_specialized_turret_stats_state.point_defense_set_stats_state(source_point_defense_turret_defaults.BULLET_DAMAGE_DEFAULT, source_turret_defaults.RELOAD_DEFAULT, source_time_defaults.TICK_RATE),
		game.source_power_turret_set_stats_state(shoot_type) == source_specialized_turret_stats_state.power_turret_set_stats_state(shoot_type),
		game.source_continuous_turret_set_stats_state(shoot_type) == source_specialized_turret_stats_state.continuous_turret_set_stats_state(shoot_type),
	]
	var specialized_bridges_match := [
		game.generated_tractor_beam_turret_set_stats_bridge_state(true, false, 4.0) == source_specialized_turret_stats_state.generated_tractor_beam_turret_set_stats_bridge_state(true, false, 4.0, source_time_defaults.TICK_RATE),
		game.generated_reload_turret_set_stats_bridge_state(true, 45.0, 0.2, 1.5) == source_specialized_turret_stats_state.generated_reload_turret_set_stats_bridge_state(true, 45.0, 0.2, 1.5),
		game.generated_point_defense_turret_set_stats_default_bridge_state() == source_specialized_turret_stats_state.generated_point_defense_turret_set_stats_default_bridge_state(source_point_defense_turret_defaults.BULLET_DAMAGE_DEFAULT, source_turret_defaults.RELOAD_DEFAULT),
		game.generated_power_turret_set_stats_bridge_state(shoot_type) == source_specialized_turret_stats_state.generated_power_turret_set_stats_bridge_state(shoot_type),
		game.generated_continuous_turret_set_stats_bridge_state(shoot_type) == source_specialized_turret_stats_state.generated_continuous_turret_set_stats_bridge_state(shoot_type),
	]
	var turret_stats_bridge := game.generated_turret_set_stats_bridge_state(3.0, 45.0, false, 5.0, 2.0, true, false, 2, 10.0, 1.5)
	var item_bars_bridge := game.generated_item_turret_set_bars_bridge_state(12.0, 24.0)
	var continuous_liquid_bridge := game.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, 0.35)
	var proof := {
		"module": "SourceTurretStatsBarsState",
		"base_stats_module_matches": base_stats_state == base_stats_module_state and base_stats_bridge == base_stats_module_bridge,
		"base_stats_bridge_shoot_range_matches": base_stats_bridge.get("result", {}).get("shoot_range_stat_call", null) == base_stats_bridge.get("canonical", {}).get("shoot_range_stat_call", null),
		"base_stats_bridge_activation_time_matches": base_stats_bridge.get("result", {}).get("activation_time_stat_call", null) == base_stats_bridge.get("canonical", {}).get("activation_time_stat_call", null),
		"base_stats_bridge_super_matches": base_stats_bridge.get("result", {}).get("super_set_stats_called", null) == base_stats_bridge.get("canonical", {}).get("super_set_stats_called", null),
		"base_stats_bridge_matches": bool(base_stats_bridge.get("matches", false)) and base_stats_bridge.get("source_owner", "") == "source_turret_stats_bars_state.base_turret_set_stats_state" and base_stats_bridge.get("generated_owner", "") == "base_turret.java_method_setStats_4",
		"base_bars_module_matches": base_bars_state == base_bars_module_state and base_bars_bridge == base_bars_module_bridge,
		"base_bars_bridge_matches": bool(base_bars_bridge.get("matches", false)) and base_bars_bridge.get("source_owner", "") == "source_turret_stats_bars_state.base_turret_set_bars_state" and base_bars_bridge.get("generated_owner", "") == "base_turret.java_method_setBars_5",
		"specialized_stats_module_matches": not specialized_states_match.has(false),
		"specialized_stats_bridge_matches": not specialized_bridges_match.has(false),
		"turret_stats_bridge_matches": turret_stats_bridge == source_turret_stats_bars_state.generated_turret_set_stats_bridge_state(3.0, 45.0, false, 5.0, 2.0, true, false, 2, 10.0, 1.5) and bool(turret_stats_bridge.get("matches", false)),
		"item_bars_bridge_matches": item_bars_bridge == source_turret_stats_bars_state.generated_item_turret_set_bars_bridge_state(12.0, 24.0) and bool(item_bars_bridge.get("matches", false)),
		"continuous_liquid_bridge_matches": continuous_liquid_bridge == source_turret_stats_bars_state.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, 0.35) and bool(continuous_liquid_bridge.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"shoot_type": shoot_type,
	}
	proof["matches"] = proof["base_stats_module_matches"] and proof["base_stats_bridge_matches"] and proof["base_bars_module_matches"] and proof["base_bars_bridge_matches"] and proof["specialized_stats_module_matches"] and proof["specialized_stats_bridge_matches"] and proof["turret_stats_bridge_matches"] and proof["item_bars_bridge_matches"] and proof["continuous_liquid_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_STATS_BARS_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretStatsBarsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

