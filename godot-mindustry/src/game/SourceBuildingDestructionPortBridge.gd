extends "res://src/game/SourceSsotAccessorPortBridge.gd"

const source_building_destruction_state := preload("res://src/game/SourceBuildingDestructionState.gd")

func generated_building_comp_after_destroyed_bridge_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	return source_building_destruction_state.generated_after_destroyed_bridge_state(has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id)

func generated_building_comp_explosion_item_cap_bridge_state(item_capacity: int) -> Dictionary:
	return source_building_destruction_state.generated_explosion_item_cap_bridge_state(item_capacity)

func generated_building_comp_splash_liquid_bridge_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return source_building_destruction_state.generated_splash_liquid_bridge_state(liquid, amount, source_block_size, source_tilesize)

func generated_building_comp_splash_liquid_source_tilesize_default_bridge_state(liquid: Variant, amount: float, source_block_size: int) -> Dictionary:
	return source_building_destruction_state.generated_splash_liquid_source_tilesize_default_bridge_state(liquid, amount, source_block_size)

func generated_building_comp_splash_liquid_source_block_size_default_bridge_state(liquid: Variant, amount: float) -> Dictionary:
	return source_building_destruction_state.generated_splash_liquid_source_block_size_default_bridge_state(liquid, amount)

func generated_building_comp_on_deconstructed_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_state.generated_on_deconstructed_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

func generated_building_comp_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool) -> Dictionary:
	return source_building_destruction_state.generated_on_deconstructed_source_block_size_default_bridge_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid)

func generated_building_comp_on_destroyed_item_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_item_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap)

func generated_building_comp_on_destroyed_liquid_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_liquid_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states)

func generated_building_comp_on_destroyed_buffered_power_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_buffered_power_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

func generated_building_comp_on_destroyed_splash_liquid_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_splash_liquid_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions)

func generated_building_comp_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_dynamic_explosion_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake)

func generated_building_comp_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_dynamic_explosion_source_tilesize_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale)

func generated_building_comp_on_destroyed_source_block_size_default_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_source_block_size_default_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize)

func generated_building_comp_on_destroyed_rubble_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_rubble_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid)

func generated_building_comp_on_destroyed_base_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_base_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_on_destroyed_reactive_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_reactive_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_on_destroyed_power_sound_bridge_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int, has_liquids: bool, liquid_states: Array, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float, damage_explosions: bool, source_x: float, source_y: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, destroy_effect: String, base_shake: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.generated_on_destroyed_power_sound_bridge_state(base_explosiveness, has_items, item_states, item_cap, has_liquids, liquid_states, has_cons_power, cons_power_buffered, power_status, cons_power_capacity, damage_explosions, source_x, source_y, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, destroy_effect, base_shake, create_rubble, floor_solid, floor_is_liquid, headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func generated_building_comp_play_destroy_sound_bridge_state(destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.generated_play_destroy_sound_bridge_state(destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_after_destroyed_state(has_destroy_bullet: bool, destroy_bullet_same_team: bool, team_id: String, source_x: float, source_y: float, building_id: int) -> Dictionary:
	return source_building_destruction_state.game_after_destroyed_state(self, has_destroy_bullet, destroy_bullet_same_team, team_id, source_x, source_y, building_id)

func source_building_explosion_item_cap_state(item_capacity: int) -> int:
	return source_building_destruction_state.explosion_item_cap_state(item_capacity)

func source_building_splash_liquid_state(liquid: Variant, amount: float, source_block_size: int, source_tilesize: float) -> Dictionary:
	return source_building_destruction_state.splash_liquid_state(liquid, amount, source_block_size, source_tilesize)

func build_begin_break_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	return source_building_destruction_state.begin_break_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)

func generated_build_begin_break_bridge_state(valid_break: bool, tile_has_building: bool, prev_healthf: float, previous_rotation: int, previous_instant_deconstruct: bool, previous_size: int, unit_has_controller_name: bool, controller_name: String) -> Dictionary:
	return source_building_destruction_state.generated_build_begin_break_bridge_state(valid_break, tile_has_building, prev_healthf, previous_rotation, previous_instant_deconstruct, previous_size, unit_has_controller_name, controller_name)

func construct_block_deconstruct_finish_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return source_building_destruction_state.construct_block_deconstruct_finish_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func generated_construct_block_deconstruct_finish_bridge_state(tile_present: bool, headless: bool, visible_tile: bool, should_play: bool, break_pitch_change: bool, calc_pitch_down: float, construct_block_size: int, block_map_color: Variant) -> Dictionary:
	return source_building_destruction_state.generated_construct_block_deconstruct_finish_bridge_state(tile_present, headless, visible_tile, should_play, break_pitch_change, calc_pitch_down, construct_block_size, block_map_color)

func construct_block_construct_finish_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return source_building_destruction_state.construct_block_construct_finish_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func generated_construct_block_construct_finish_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant) -> Dictionary:
	return source_building_destruction_state.generated_construct_block_construct_finish_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state)

func construct_block_constructed_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return source_building_destruction_state.construct_block_constructed_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func generated_construct_block_constructed_bridge_state(tile_present: bool, block_kind: String, tile_has_building: bool, tile_build_matches_block: bool, healthf: float, prev_build_count: int, floor_supports_overlay: bool, current_overlay_is_overlay_floor: bool, config_present: bool, builder_has_controller_name: bool, controller_name: String, headless: bool, builder_is_player_unit: bool, visible_tile: bool, should_play: bool, place_pitch_change: bool, calc_pitch_up: float, construct_block_size: int, block_health: float, rotation_value: int, config_state: Variant, tile_has_building_after_construct_finish: bool) -> Dictionary:
	return source_building_destruction_state.generated_construct_block_constructed_bridge_state(tile_present, block_kind, tile_has_building, tile_build_matches_block, healthf, prev_build_count, floor_supports_overlay, current_overlay_is_overlay_floor, config_present, builder_has_controller_name, controller_name, headless, builder_is_player_unit, visible_tile, should_play, place_pitch_change, calc_pitch_up, construct_block_size, block_health, rotation_value, config_state, tile_has_building_after_construct_finish)

func source_building_on_deconstructed_liquid_state(has_liquids_module: bool, current_amount: float, current_incinerable: bool, deconstruct_drop_all_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_state.on_deconstructed_liquid_state(has_liquids_module, current_amount, current_incinerable, deconstruct_drop_all_liquid, source_block_size)

func source_building_on_destroyed_item_explosion_state(base_explosiveness: float, has_items: bool, item_states: Array, item_cap: int) -> Dictionary:
	return source_building_destruction_state.on_destroyed_item_explosion_state(base_explosiveness, has_items, item_states, item_cap)

func source_building_on_destroyed_liquid_explosion_state(current_explosiveness: float, current_flammability: float, has_liquids: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_state.on_destroyed_liquid_explosion_state(current_explosiveness, current_flammability, has_liquids, liquid_states)

func source_building_on_destroyed_buffered_power_state(current_power: float, has_cons_power: bool, cons_power_buffered: bool, power_status: float, cons_power_capacity: float) -> Dictionary:
	return source_building_destruction_state.on_destroyed_buffered_power_state(current_power, has_cons_power, cons_power_buffered, power_status, cons_power_capacity)

func source_building_on_destroyed_splash_liquid_state(has_liquids: bool, damage_explosions: bool, liquid_states: Array) -> Dictionary:
	return source_building_destruction_state.on_destroyed_splash_liquid_state(has_liquids, damage_explosions, liquid_states)

func source_building_on_destroyed_dynamic_explosion_call_state(source_x: float, source_y: float, flammability: float, explosiveness: float, power: float, flammability_scale: float, explosiveness_scale: float, source_tilesize: float, source_block_size: int, damage_explosions: bool, destroy_effect: String, base_shake: float) -> Dictionary:
	return source_building_destruction_state.on_destroyed_dynamic_explosion_call_state(source_x, source_y, flammability, explosiveness, power, flammability_scale, explosiveness_scale, source_tilesize, source_block_size, damage_explosions, destroy_effect, base_shake)

func source_building_on_destroyed_rubble_state(source_x: float, source_y: float, create_rubble: bool, floor_solid: bool, floor_is_liquid: bool, source_block_size: int) -> Dictionary:
	return source_building_destruction_state.on_destroyed_rubble_state(source_x, source_y, create_rubble, floor_solid, floor_is_liquid, source_block_size)

func source_building_on_destroyed_base_sound_state(headless: bool, destroy_sound: String, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.on_destroyed_base_sound_state(headless, destroy_sound, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_on_destroyed_reactive_sound_state(headless: bool, explosiveness: float, flammability: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.on_destroyed_reactive_sound_state(headless, explosiveness, flammability, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)

func source_building_on_destroyed_power_sound_state(headless: bool, power: float, destroy_pitch_min: float, destroy_pitch_max: float, destroy_sound_volume: float) -> Dictionary:
	return source_building_destruction_state.on_destroyed_power_sound_state(headless, power, destroy_pitch_min, destroy_pitch_max, destroy_sound_volume)
