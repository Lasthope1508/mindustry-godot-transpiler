extends "res://src/game/SourceMathPortBridge.gd"

const source_turret_stats_bars_state := preload("res://src/game/SourceTurretStatsBarsState.gd")
const source_time_defaults := preload("res://src/game/SourceTimeDefaults.gd")
const source_turret_defaults := preload("res://src/game/SourceTurretDefaults.gd")
const source_point_defense_turret_defaults := preload("res://src/game/SourcePointDefenseTurretDefaults.gd")

func source_base_turret_set_stats_state(range_value: float, source_tilesize: float, activation_time: float) -> Dictionary:
	return source_turret_stats_bars_state.base_turret_set_stats_state(range_value, source_tilesize, activation_time, source_time_defaults.TICK_RATE)

func generated_base_turret_set_stats_bridge_state(range_value: float, source_tilesize: float, activation_time: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_base_turret_set_stats_bridge_state(range_value, source_tilesize, activation_time, source_time_defaults.TICK_RATE)

func source_base_turret_set_bars_state(activation_time: float, entity_activation_timer: float) -> Dictionary:
	return source_turret_stats_bars_state.base_turret_set_bars_state(activation_time, entity_activation_timer, source_time_defaults.TICK_RATE)

func generated_base_turret_set_bars_bridge_state(activation_time: float, entity_activation_timer: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_base_turret_set_bars_bridge_state(activation_time, entity_activation_timer, source_time_defaults.TICK_RATE)

func source_turret_set_stats_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	return source_turret_stats_bars_state.set_stats_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency, source_time_defaults.TICK_RATE)

func generated_turret_set_stats_bridge_state(inaccuracy_value: float, reload_value: float, reload_while_charging: bool, shoot_first_shot_delay: float, shoot_shots: float, target_air: bool, target_ground: bool, ammo_per_shot: int, heat_requirement: float, max_heat_efficiency: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_turret_set_stats_bridge_state(inaccuracy_value, reload_value, reload_while_charging, shoot_first_shot_delay, shoot_shots, target_air, target_ground, ammo_per_shot, heat_requirement, max_heat_efficiency)

func source_point_defense_turret_set_stats_state(bullet_damage: float, reload_value: float) -> Dictionary:
	return source_turret_stats_bars_state.point_defense_set_stats_state(bullet_damage, reload_value, source_time_defaults.TICK_RATE)

func generated_point_defense_turret_set_stats_default_bridge_state() -> Dictionary:
	return source_turret_stats_bars_state.generated_point_defense_turret_set_stats_default_bridge_state(source_point_defense_turret_defaults.BULLET_DAMAGE_DEFAULT, source_turret_defaults.RELOAD_DEFAULT)

func source_turret_set_bars_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	return source_turret_stats_bars_state.set_bars_state(heat_requirement, entity_heat_req, max_heat_efficiency)

func generated_turret_set_bars_bridge_state(heat_requirement: float, entity_heat_req: float, max_heat_efficiency: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_turret_set_bars_bridge_state(heat_requirement, entity_heat_req, max_heat_efficiency)

func source_tractor_beam_turret_set_stats_state(target_air: bool, target_ground: bool, damage: float) -> Dictionary:
	return source_turret_stats_bars_state.tractor_beam_turret_set_stats_state(target_air, target_ground, damage, source_time_defaults.TICK_RATE)

func generated_tractor_beam_turret_set_stats_bridge_state(target_air: bool, target_ground: bool, damage: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_tractor_beam_turret_set_stats_bridge_state(target_air, target_ground, damage, source_time_defaults.TICK_RATE)

func source_reload_turret_set_stats_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return source_turret_stats_bars_state.reload_turret_set_stats_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)

func generated_reload_turret_set_stats_bridge_state(coolant_present: bool, reload_value: float, coolant_amount: float, coolant_multiplier: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_reload_turret_set_stats_bridge_state(coolant_present, reload_value, coolant_amount, coolant_multiplier)

func source_power_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return source_turret_stats_bars_state.power_turret_set_stats_state(shoot_type)

func generated_power_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_turret_stats_bars_state.generated_power_turret_set_stats_bridge_state(shoot_type)

func source_continuous_turret_set_stats_state(shoot_type: Variant) -> Dictionary:
	return source_turret_stats_bars_state.continuous_turret_set_stats_state(shoot_type)

func generated_continuous_turret_set_stats_bridge_state(shoot_type: Variant) -> Dictionary:
	return source_turret_stats_bars_state.generated_continuous_turret_set_stats_bridge_state(shoot_type)

func source_item_turret_set_stats_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return source_turret_stats_bars_state.item_turret_set_stats_state(ammo_types, name_value, max_ammo, ammo_per_shot)

func generated_item_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String, max_ammo: float, ammo_per_shot: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_item_turret_set_stats_bridge_state(ammo_types, name_value, max_ammo, ammo_per_shot)

func generated_item_turret_set_stats_default_bridge_state() -> Dictionary:
	return source_turret_stats_bars_state.generated_item_turret_set_stats_default_bridge_state(source_turret_defaults.MAX_AMMO_DEFAULT, source_turret_defaults.AMMO_PER_SHOT_DEFAULT)

func source_item_turret_set_bars_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_turret_stats_bars_state.item_turret_set_bars_state(total_ammo, max_ammo)

func generated_item_turret_set_bars_bridge_state(total_ammo: float, max_ammo: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_item_turret_set_bars_bridge_state(total_ammo, max_ammo)

func generated_item_turret_set_bars_default_bridge_state(total_ammo: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_item_turret_set_bars_default_bridge_state(total_ammo, source_turret_defaults.MAX_AMMO_DEFAULT)

func source_continuous_liquid_turret_set_stats_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return source_turret_stats_bars_state.continuous_liquid_turret_set_stats_state(ammo_types, liquid_consumed)

func generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types: Array, liquid_consumed: float) -> Dictionary:
	return source_turret_stats_bars_state.generated_continuous_liquid_turret_set_stats_bridge_state(ammo_types, liquid_consumed)

func source_liquid_turret_set_stats_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return source_turret_stats_bars_state.liquid_turret_set_stats_state(ammo_types, name_value)

func generated_liquid_turret_set_stats_bridge_state(ammo_types: Variant, name_value: String) -> Dictionary:
	return source_turret_stats_bars_state.generated_liquid_turret_set_stats_bridge_state(ammo_types, name_value)
