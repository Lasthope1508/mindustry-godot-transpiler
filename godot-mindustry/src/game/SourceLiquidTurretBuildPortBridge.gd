extends "res://src/game/SourceMendProjectorPortBridge.gd"

const source_liquid_turret_build_state := preload("res://src/game/SourceLiquidTurretBuildState.gd")

func source_liquid_turret_build_should_active_sound_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_liquid_turret_build_state.should_active_sound_state(was_shooting, enabled)

func generated_liquid_turret_build_should_active_sound_bridge_state(was_shooting: bool, enabled: bool) -> Dictionary:
	return source_liquid_turret_build_state.generated_should_active_sound_bridge_state(was_shooting, enabled)

func source_liquid_turret_build_get_ammo_content_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_liquid_turret_build_state.get_ammo_content_state(liquids_null, current_amount, current_liquid)

func generated_liquid_turret_build_get_ammo_content_bridge_state(liquids_null: bool, current_amount: float, current_liquid: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_get_ammo_content_bridge_state(liquids_null, current_amount, current_liquid)

func source_liquid_turret_build_get_ammo_fraction_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_liquid_turret_build_state.get_ammo_fraction_state(current_amount, liquid_capacity)

func generated_liquid_turret_build_get_ammo_fraction_bridge_state(current_amount: float, liquid_capacity: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_get_ammo_fraction_bridge_state(current_amount, liquid_capacity)

func source_liquid_turret_build_sense_object_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_liquid_turret_build_state.sense_object_state(sensor, current_liquid, super_sense_object_value)

func generated_liquid_turret_build_sense_object_bridge_state(sensor: String, current_liquid: Variant, super_sense_object_value: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_sense_object_bridge_state(sensor, current_liquid, super_sense_object_value)

func source_liquid_turret_build_find_target_extinguish_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	return source_liquid_turret_build_state.find_target_extinguish_state(extinguish, current_liquid_can_extinguish, fire_result)

func generated_liquid_turret_build_find_target_extinguish_bridge_state(extinguish: bool, current_liquid_can_extinguish: bool, fire_result: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_find_target_extinguish_bridge_state(extinguish, current_liquid_can_extinguish, fire_result)

func source_liquid_turret_build_use_ammo_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.use_ammo_state(cheating, current_liquid, ammo_type, ammo_multiplier)

func generated_liquid_turret_build_use_ammo_bridge_state(cheating: bool, current_liquid: Variant, ammo_type: Variant, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_use_ammo_bridge_state(cheating, current_liquid, ammo_type, ammo_multiplier)

func source_liquid_turret_build_peek_ammo_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_liquid_turret_build_state.peek_ammo_state(current_liquid, ammo_type)

func generated_liquid_turret_build_peek_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_peek_ammo_bridge_state(current_liquid, ammo_type)

func source_liquid_turret_build_has_ammo_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.has_ammo_state(current_liquid, ammo_type, current_amount, ammo_multiplier)

func generated_liquid_turret_build_has_ammo_bridge_state(current_liquid: Variant, ammo_type: Variant, current_amount: float, ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_has_ammo_bridge_state(current_liquid, ammo_type, current_amount, ammo_multiplier)

func source_liquid_turret_build_accept_item_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_liquid_turret_build_state.accept_item_state(source_building, item)

func generated_liquid_turret_build_accept_item_bridge_state(source_building: Variant, item: Variant) -> Dictionary:
	return source_liquid_turret_build_state.generated_accept_item_bridge_state(source_building, item)

func source_liquid_turret_build_accept_liquid_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.accept_liquid_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)

func generated_liquid_turret_build_accept_liquid_bridge_state(source_building: Variant, liquid: Variant, ammo_type: Variant, current_liquid: Variant, current_liquid_ammo_type_present: bool, current_liquid_amount: float, current_ammo_multiplier: float) -> Dictionary:
	return source_liquid_turret_build_state.generated_accept_liquid_bridge_state(source_building, liquid, ammo_type, current_liquid, current_liquid_ammo_type_present, current_liquid_amount, current_ammo_multiplier)
