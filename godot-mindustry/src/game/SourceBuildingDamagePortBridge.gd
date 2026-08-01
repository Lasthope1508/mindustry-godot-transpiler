extends "res://src/game/SourceLiquidTurretBuildPortBridge.gd"

const source_building_damage_state := preload("res://src/game/SourceBuildingDamageState.gd")

func generated_building_comp_handle_damage_bridge_state(amount: float) -> Dictionary:
	return source_building_damage_state.generated_handle_damage_bridge_state(amount)

func generated_building_comp_collision_bridge_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return source_building_damage_state.generated_collision_bridge_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func generated_building_comp_damage_delegate_bridge_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.generated_damage_delegate_bridge_state(source_team, damage_amount)

func generated_building_comp_bullet_damage_bridge_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.generated_bullet_damage_bridge_state(bullet, source_team, damage_amount)

func generated_building_comp_damage_dead_guard_bridge_state(damage_amount: float, dead_state: bool) -> Dictionary:
	return source_building_damage_state.generated_damage_dead_guard_bridge_state(damage_amount, dead_state)

func generated_building_comp_damage_block_health_scale_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return source_building_damage_state.generated_damage_block_health_scale_bridge_state(damage_amount, health, block_health_multiplier, source_time)

func generated_building_comp_damage_handle_damage_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return source_building_damage_state.generated_damage_handle_damage_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_health_changed_call_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float) -> Dictionary:
	return source_building_damage_state.generated_damage_health_changed_call_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage)

func generated_building_comp_damage_destroy_gate_bridge_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float, net_client: bool, handled_damage: float, self_state := {}) -> Dictionary:
	return source_building_damage_state.generated_damage_destroy_gate_bridge_state(damage_amount, health, block_health_multiplier, source_time, net_client, handled_damage, self_state)

func source_building_handle_damage_state(amount: float) -> float:
	return source_building_damage_state.handle_damage_state(amount)

func source_building_collision_damage_state(current_health: float, bullet_building_damage: float, block_armor: float, bullet_pierce_armor: bool, bullet_armor_multiplier: float, bullet_block_armor_multiplier: float) -> Dictionary:
	return source_building_damage_state.collision_damage_state(current_health, bullet_building_damage, block_armor, bullet_pierce_armor, bullet_armor_multiplier, bullet_block_armor_multiplier)

func source_building_damage_delegate_state(source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.damage_delegate_state(source_team, damage_amount)

func source_building_bullet_damage_state(bullet: Variant, source_team: Variant, damage_amount: float) -> Dictionary:
	return source_building_damage_state.bullet_damage_state(bullet, source_team, damage_amount)

func source_building_damage_dead_guard_state(dead_state: bool) -> Dictionary:
	return source_building_damage_state.dead_guard_state(dead_state)

func source_building_damage_block_health_scale_state(damage_amount: float, health: float, block_health_multiplier: float, source_time: float) -> Dictionary:
	return source_building_damage_state.block_health_scale_state(damage_amount, health, block_health_multiplier, source_time)

func source_building_damage_handle_damage_gate_state(net_client: bool, health: float, damage_amount: float, handled_damage: float) -> Dictionary:
	return source_building_damage_state.handle_damage_gate_state(net_client, health, damage_amount, handled_damage)

func source_building_damage_health_changed_call_state() -> Dictionary:
	return source_building_damage_state.health_changed_call_state()

func source_building_damage_destroy_gate_state(health: float, self_state := {}) -> Dictionary:
	return source_building_damage_state.destroy_gate_state(health, self_state)
