extends "res://src/game/SourceBuildingEfficiencyPortBridge.gd"

const source_continuous_liquid_turret_build_state := preload("res://src/game/SourceContinuousLiquidTurretBuildState.gd")

func source_continuous_liquid_turret_build_should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.should_active_sound_state(was_shooting, enabled)

func generated_continuous_liquid_turret_build_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_should_active_sound_bridge_state(was_shooting, enabled)

func source_continuous_liquid_turret_build_get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.get_ammo_content_state(liquids_null, current_amount, current_liquid)

func generated_continuous_liquid_turret_build_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid)

func source_continuous_liquid_turret_build_get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_continuous_liquid_turret_build_state.get_ammo_fraction_state(current_amount, liquid_capacity)

func generated_continuous_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_get_ammo_fraction_bridge_state(current_amount, liquid_capacity)

func source_continuous_liquid_turret_build_update_tile_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.update_tile_state(current_amount, liquid_consumed, activated_before)

func generated_continuous_liquid_turret_build_update_tile_bridge_state(current_amount: float, liquid_consumed: float, activated_before: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_update_tile_bridge_state(current_amount, liquid_consumed, activated_before)

func source_continuous_liquid_turret_build_sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.sense_object_state(sensor, current_liquid, super_sense_object_value)

func generated_continuous_liquid_turret_build_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value)

func source_continuous_liquid_turret_build_can_consume_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.can_consume_state(has_correct_ammo, super_can_consume)

func generated_continuous_liquid_turret_build_can_consume_bridge_state(has_correct_ammo: bool, super_can_consume: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_can_consume_bridge_state(has_correct_ammo, super_can_consume)

func source_continuous_liquid_turret_build_should_consume_state(super_should_consume: bool, activated: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.should_consume_state(super_should_consume, activated)

func generated_continuous_liquid_turret_build_should_consume_bridge_state(super_should_consume: bool, activated: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_should_consume_bridge_state(super_should_consume, activated)

func source_continuous_liquid_turret_build_use_ammo_state(peek_ammo: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.use_ammo_state(peek_ammo)

func generated_continuous_liquid_turret_build_use_ammo_bridge_state(peek_ammo: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_use_ammo_bridge_state(peek_ammo)

func source_continuous_liquid_turret_build_peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.peek_ammo_state(current_liquid, ammo_type)

func generated_continuous_liquid_turret_build_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_peek_ammo_bridge_state(current_liquid, ammo_type)

func source_continuous_liquid_turret_build_has_ammo_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.has_ammo_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)

func generated_continuous_liquid_turret_build_has_ammo_bridge_state(has_correct_ammo: bool, current_liquid: Variant, ammo_type: Variant, current_amount: float, activated: bool) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_has_ammo_bridge_state(has_correct_ammo, current_liquid, ammo_type, current_amount, activated)

func source_continuous_liquid_turret_build_has_correct_ammo_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.has_correct_ammo_state(bullets_any, first_bullet_type, peek_ammo)

func generated_continuous_liquid_turret_build_has_correct_ammo_bridge_state(bullets_any: bool, first_bullet_type: Variant, peek_ammo: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_has_correct_ammo_bridge_state(bullets_any, first_bullet_type, peek_ammo)

func source_continuous_liquid_turret_build_accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.accept_item_state(source_building, item)

func generated_continuous_liquid_turret_build_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_accept_item_bridge_state(source_building, item)

func source_continuous_liquid_turret_build_accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_continuous_liquid_turret_build_state.accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func generated_continuous_liquid_turret_build_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_continuous_liquid_turret_build_state.generated_accept_liquid_bridge_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
