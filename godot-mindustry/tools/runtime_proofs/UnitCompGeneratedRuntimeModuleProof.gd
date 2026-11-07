extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const UnitCompScript := preload("res://src/generated/classes/mindustry/entities/comp/UnitComp.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_unit_update_state := preload("res://src/game/SourceUnitUpdateState.gd")
const source_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_unit_destroy_state := preload("res://src/game/SourceUnitDestroyState.gd")
const source_unit_destroy_source_text_state := preload("res://src/game/SourceUnitDestroySourceTextState.gd")
const source_unit_update_source_text_state := preload("res://src/game/SourceUnitUpdateSourceTextState.gd")
const source_unit_sensor_source_text_state := preload("res://src/game/SourceUnitSensorSourceTextState.gd")
const source_unit_set_prop_source_text_state := preload("res://src/game/SourceUnitSetPropSourceTextState.gd")
const source_unit_combat_metadata_source_text_state := preload("res://src/game/SourceUnitCombatMetadataSourceTextState.gd")
const source_unit_controller_source_text_state := preload("res://src/game/SourceUnitControllerSourceTextState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const source_generated_class_path_headquarter := preload("res://src/game/SourceGeneratedClassPathHeadquarter.gd")


func _ready() -> void:
	var generated := UnitCompScript.new()
	var game := PortGameScript.new()
	var check_target: Dictionary = generated.java_method_checkTarget_0([0.0, false, true])
	var grounded: Dictionary = generated.java_method_isGrounded_1([0.0])
	var flying: Dictionary = generated.java_method_isFlying_2([0.09])
	var can_drown: Dictionary = generated.java_method_canDrown_3([0.0, true])
	var floor_value: Dictionary = generated.java_method_drownFloor_4(["floor-on"])
	var wobble: Dictionary = generated.java_method_wobble_5([12.0, 24.0, 30.0, 0.5, 0.75, 17, game])
	var move_at: Dictionary = generated.java_method_moveAt_6([1.0, 2.0, 4.0, 8.0, 0.6, 0.5, game])
	var floor_speed: Dictionary = generated.java_method_floorSpeedMultiplier_7([0.0, false, 0.8, 2.0, 1.5])
	var move_pref: Dictionary = generated.java_method_movePref_11([true, 4.0, 8.0])
	var move_at_default: Dictionary = generated.java_method_moveAt_12([4.0, 8.0, 0.6])
	var approach: Dictionary = generated.java_method_approach_13([1.0, 2.0, 4.0, 8.0, 0.6, 1.5, 0.5])
	var rotate_move: Dictionary = generated.java_method_rotateMove_14([20.0, 3.0, 4.0, 5.0, 1.25, 0.5, game])
	var unloaded: Dictionary = generated.java_method_unloaded_8(["unit-state"])
	var boosting_default: Dictionary = generated.java_method_updateBoosting_9([true])
	var boosting: Dictionary = generated.java_method_updateBoosting_10([true, true, true, false, 0.1, false, true, 0.8, 0.4, 0.5])
	var boosting_guard: Dictionary = generated.java_method_updateBoosting_10([true, true, false, false, 0.1, false, true, 0.8, 0.4, 0.5])
	var aim_position: Dictionary = generated.java_method_aimLook_15([10.0, 20.0])
	var aim_xy: Dictionary = generated.java_method_aimLook_16([30.0, 40.0])
	var physic_size: Dictionary = generated.java_method_physicSize_18([8.0])
	var in_range: Dictionary = generated.java_method_inRange_20([0.0, 0.0, 3.0, 4.0, 5.0])
	var has_weapons: Dictionary = generated.java_method_hasWeapons_21([[{"name": "weapon"}]])
	var speed: Dictionary = generated.java_method_speed_22([0.5, false, true, 0.0, 90.0, 0.5, true, 1.5, 2.0, 0.8])
	var ammof: Dictionary = generated.java_method_ammof_24()
	var displayable: Dictionary = generated.java_method_displayable_25([true])
	var sync_hidden: Dictionary = generated.java_method_isSyncHidden_26([false, true])
	var sync_revealed: Dictionary = generated.java_method_isSyncHidden_26([true, true])
	var handle_sync_hidden: Dictionary = generated.java_method_handleSyncHidden_27([73])
	var in_fog_same_team: Dictionary = generated.java_method_inFogTo_28([true, true, 20.0, 100.0, 200.0, false, [false, false, false, false, false, false, false, false]])
	var in_fog_small_hidden: Dictionary = generated.java_method_inFogTo_28([false, true, 12.0, 100.0, 200.0, false, [true, true, true, true, true, true, true, true]])
	var in_fog_large_visible: Dictionary = generated.java_method_inFogTo_28([false, true, 20.0, 100.0, 200.0, false, [false, false, true, false, false, false, false, false]])
	var in_fog_large_hidden: Dictionary = generated.java_method_inFogTo_28([false, true, 20.0, 100.0, 200.0, false, [false, false, false, false, false, false, false, false]])
	var unit_range: Dictionary = generated.java_method_range_29([156.0])
	var clip_size_building: Dictionary = generated.java_method_clipSize_30([true, false, 10.0, 24.0, 40.0, 8.0, false, 0.0])
	var clip_size_building_infinite: Dictionary = generated.java_method_clipSize_30([true, true, 10.0, 24.0, 40.0, 8.0, false, 0.0])
	var clip_size_mining: Dictionary = generated.java_method_clipSize_30([false, false, 10.0, 24.0, 40.0, 8.0, true, 6.0])
	var clip_size_default: Dictionary = generated.java_method_clipSize_30([false, false, 10.0, 24.0, 40.0, 8.0, false, 6.0])
	var sensor_unit_state := {"stack_amount": 14.0, "controller_kind": "Player", "is_valid": true, "ctrl_player": 2.0, "is_pinging": false, "ping_x": 24.0}
	var sense_total_items: Dictionary = generated.java_method_sense_31(["totalItems", sensor_unit_state, 8.0])
	var sense_controlled: Dictionary = generated.java_method_sense_31(["controlled", sensor_unit_state, 8.0])
	var sense_ping_x: Dictionary = generated.java_method_sense_31(["pingX", sensor_unit_state, 8.0])
	var sense_object_type: Dictionary = generated.java_method_senseObject_32(["type", {"type": "alpha"}, "no-sensed"])
	var sense_object_controller: Dictionary = generated.java_method_senseObject_32(["controller", {"controller_kind": "LogicAI", "logic_controller": "logic", "is_valid": true}, "no-sensed"])
	var sense_object_default: Dictionary = generated.java_method_senseObject_32(["unknown", {}, "no-sensed"])
	var sense_content_item: Dictionary = generated.java_method_sense_33([{"kind": "Item", "id": "copper"}, {"stack_item_id": "copper", "stack_amount": 7.0}, 8.0])
	var sense_content_unit: Dictionary = generated.java_method_sense_33([{"kind": "UnitType", "id": "flare"}, {"payloads": [{"kind": "UnitPayload", "unit_type_id": "flare"}, {"kind": "UnitPayload", "unit_type_id": "dagger"}]}, 8.0])
	var sense_content_block: Dictionary = generated.java_method_sense_33([{"kind": "Block", "id": "router"}, {"payloads": [{"kind": "BuildPayload", "block_id": "router"}]}, 8.0])
	var sense_content_default: Dictionary = generated.java_method_sense_33([{"kind": "Liquid", "id": "water"}, {}, 8.0])
	var set_prop_health: Dictionary = generated.java_method_setProp_34(["health", -4.0, {"max_health": 100.0, "dead": false}, 8.0])
	var set_prop_velocity: Dictionary = generated.java_method_setProp_34(["velocityX", 15.0, {}, 8.0])
	var set_prop_object: Dictionary = generated.java_method_setProp_35(["payloadType", null, {"is_payload": true, "net_client": false}])
	var set_prop_content: Dictionary = generated.java_method_setProp_36([{"kind": "Item"}, 27.8, {"type_item_capacity": 20}])
	var can_shoot: Dictionary = generated.java_method_canShoot_37([{"disarmed": false, "type_can_boost": true, "is_flying": true}])
	var cannot_shoot_disarmed: Dictionary = generated.java_method_canShoot_37([{"disarmed": true, "type_can_boost": false, "is_flying": false}])
	var is_enemy: Dictionary = generated.java_method_isEnemy_38([true])
	var collides: Dictionary = generated.java_method_collides_39([true])
	var item_capacity: Dictionary = generated.java_method_itemCapacity_41([40])
	var bounds: Dictionary = generated.java_method_bounds_42([8.0])
	var collision: Dictionary = generated.java_method_collision_40([true, "bullet"])
	var controller_set: Dictionary = generated.java_method_controller_43(["next", "old-unit", "self-unit"])
	var controller_get: Dictionary = generated.java_method_controller_44(["current"])
	var reset_controller: Dictionary = generated.java_method_resetController_45(["created"])
	var set_controller: Dictionary = generated.java_method_set_46(["old-type", "new-type", "next", "old-unit", "self-unit"])
	var collision_layer_legs: Dictionary = generated.java_method_collisionLayer_47([true, true, false, 1, 0, 2])
	var collision_layer_ground: Dictionary = generated.java_method_collisionLayer_47([false, false, true, 1, 0, 2])
	var collision_layer_flying: Dictionary = generated.java_method_collisionLayer_47([false, false, false, 1, 0, 2])
	var is_ai: Dictionary = generated.java_method_isAI_51([true])
	var allow_command: Dictionary = generated.java_method_allowCommand_52([true])
	var is_commandable: Dictionary = generated.java_method_isCommandable_53([false])
	var can_target_null: Dictionary = generated.java_method_canTarget_54([false, false, false, false, false, false])
	var can_target_unit: Dictionary = generated.java_method_canTarget_54([true, true, true, false, true, false])
	var can_target_building: Dictionary = generated.java_method_canTarget_54([true, false, false, true, false, true])
	var command_ok: Dictionary = generated.java_method_command_55([true])
	var command_bad: Dictionary = generated.java_method_command_55([false])
	var is_missile: Dictionary = generated.java_method_isMissile_56([true])
	var unit_count: Dictionary = generated.java_method_count_57([17, 4])
	var unit_cap_uncapped: Dictionary = generated.java_method_cap_58([true, false, false, false, false, true, 100, 5])
	var unit_cap_variable: Dictionary = generated.java_method_cap_58([false, false, false, false, false, true, 100, 5])
	var set_type: Dictionary = generated.java_method_setType_59([3, 200.0, 0.3, 0.0, 6.0, 1, 2, 0, 0, false, true])
	var player_controllable_normal: Dictionary = generated.java_method_playerControllable_60([true, false, false, false])
	var player_controllable_privileged: Dictionary = generated.java_method_playerControllable_60([true, true, true, true])
	var player_controllable_disabled: Dictionary = generated.java_method_playerControllable_60([false, false, false, false])
	var targetable_direct: Dictionary = generated.java_method_targetable_61([true, false, false, false, 42])
	var targetable_payload: Dictionary = generated.java_method_targetable_61([false, true, true, true, 42])
	var targetable_non_payload: Dictionary = generated.java_method_targetable_61([false, true, false, true, 42])
	var killable_true: Dictionary = generated.java_method_killable_62([true])
	var killable_false: Dictionary = generated.java_method_killable_62([false])
	var hittable_direct: Dictionary = generated.java_method_hittable_63([true, false, false, false])
	var hittable_payload: Dictionary = generated.java_method_hittable_63([false, true, true, true])
	var hittable_non_payload: Dictionary = generated.java_method_hittable_63([false, true, false, true])
	var after_sync: Dictionary = generated.java_method_afterSync_64([3, true])
	var after_read_reset: Dictionary = generated.java_method_afterRead_65([3, false, false, true])
	var after_read_keep: Dictionary = generated.java_method_afterRead_65([3, true, true, true])
	var after_read_all: Dictionary = generated.java_method_afterReadAll_66([true])
	var add_over_cap: Dictionary = generated.java_method_add_67([true, 11, 10, false, false, false])
	var add_guard_false: Dictionary = generated.java_method_add_67([true, 10, 10, false, false, false])
	var remove_with_trail: Dictionary = generated.java_method_remove_68([true, 3, 2.5, false, "team-blue", "type-red"])
	var remove_without_trail: Dictionary = generated.java_method_remove_68([true, 0, 2.5, true, "team-blue", "type-red"])
	var landed_shake: Dictionary = generated.java_method_landed_69([4.0])
	var landed_no_shake: Dictionary = generated.java_method_landed_69([0.0])
	var heal_partial: Dictionary = generated.java_method_heal_70([20.0, 100.0, 10.0, false])
	var heal_full: Dictionary = generated.java_method_heal_70([95.0, 100.0, 10.0, false])
	var drowning_liquid: Dictionary = generated.java_method_updateDrowning_71([true, true, 10.0, true, 0.8, 1.0, 8.0, 1.0, true, false])
	var drowning_net_client: Dictionary = generated.java_method_updateDrowning_71([true, true, 10.0, true, 1.0, 1.0, 8.0, 1.0, false, true])
	var drowning_dry: Dictionary = generated.java_method_updateDrowning_71([false, false, 0.0, false, 0.8, 1.0, 8.0, 1.0, false, false])
	var update_context: Dictionary = {}
	for key in source_unit_update_state.SOURCE_UNIT_UPDATE_REQUIRED_KEYS:
		update_context[key] = 0.0
	for key in ["type_bounded", "rules_limit_map_area", "team_is_ai", "net_client", "is_local", "is_flying_value", "was_flying_value", "tile_exists", "floor_is_liquid", "type_hovering", "type_emit_walk_effect", "type_emit_walk_sound", "floor_exists", "can_drown_value", "was_healed_value", "team_is_only_ai", "state_is_campaign", "sector_is_captured", "headless_value", "type_supports_env", "dead_value", "trail_exists", "type_use_engine_elevation", "team_is_wave_team", "state_has_spawns_value", "is_local_value", "hittable_value", "tile_build_exists", "type_hovering_value", "is_grounded_value", "can_pass_on_value", "type_can_boost", "headless_state", "is_remote_value", "should_update_controller_value", "controller_is_valid_value", "spawned_by_core_value", "is_player_value"]:
		update_context[key] = false
	for key in ["tile_floor_color", "floor_map_color", "type_loop_sound", "type_move_sound"]:
		update_context[key] = ""
	for key in ["ability_ids", "spawns"]:
		update_context[key] = []
	var update_orchestration: Dictionary = generated.java_method_update_72([update_context])
	var canonical_update_orchestration: Dictionary = source_unit_update_state.update_state(update_context)
	var should_update_controller: Dictionary = generated.java_method_shouldUpdateController_73([])
	var unit_icon: Dictionary = generated.java_method_icon_74(["dagger-ui"])
	var unit_destroy: Dictionary = generated.java_method_destroy_75([{"is_added": true, "killable": true, "item_explosiveness": 0.2, "item_flammability": 0.3, "item_charge": 0.1, "stack_amount": 4, "unit_id": 12, "death_shake": -1.0, "create_scorch": true, "death_sound_volume": 1.0, "type_flying": true, "create_wreck": true, "rules_unit_crash_damage": 1.0, "crash_damage_multiplier": 1.0, "shields_empty": true, "spawned_by_core": false, "mounts": [], "abilities": [], "wreck_regions": [], "tmp_offsets": []}])
	var controller_name_player: Dictionary = generated.java_method_getControllerName_76([true, "[blue]player", false, false, ""])
	var controller_name_logic: Dictionary = generated.java_method_getControllerName_76([false, "", true, true, "logic-player"])
	var controller_name_none: Dictionary = generated.java_method_getControllerName_76([false, "", false, false, ""])
	var unit_display: Dictionary = generated.java_method_display_77(["table"])
	var unit_draw: Dictionary = generated.java_method_draw_78([])
	var unit_is_player: Dictionary = generated.java_method_isPlayer_79([true])
	var unit_is_not_player: Dictionary = generated.java_method_isPlayer_79([false])
	var unit_get_player: Dictionary = generated.java_method_getPlayer_80([true, "player-controller"])
	var unit_get_no_player: Dictionary = generated.java_method_getPlayer_80([false, "ai-controller"])
	var unit_killed_destroy: Dictionary = generated.java_method_killed_81([true, 5.0, false, true, "wreck", 0.7, 42])
	var unit_killed_wreck: Dictionary = generated.java_method_killed_81([false, 5.0, true, true, "wreck", 0.7, 42])
	var unit_kill_dispatch: Dictionary = generated.java_method_kill_82([false, false, true, 42])
	var unit_kill_guard: Dictionary = generated.java_method_kill_82([true, false, true, 42])
	var unit_to_string: Dictionary = generated.java_method_toString_83([42, "dagger", 10.5, -2.25])
	var look_at_angle: Dictionary = generated.java_method_lookAt_48([10.0, 90.0, 5.0, 1.0, 0.5, game])
	var look_at_position: Dictionary = generated.java_method_lookAt_49([10.0, 0.0, 0.0, 10.0, 0.0, 5.0, 1.0, 0.5, game])
	var look_at_xy: Dictionary = generated.java_method_lookAt_50([10.0, 0.0, 0.0, 10.0, 0.0, 5.0, 1.0, 0.5, game])
	var path_impassable: Dictionary = generated.java_method_isPathImpassable_17([false, 4, 5, true, -1])
	var path_passable_flying: Dictionary = generated.java_method_isPathImpassable_17([true, 4, 5, true, -1])
	var can_land: Dictionary = generated.java_method_canLand_19([12.0, 24.0, 5.6, false, 0])
	var can_not_land_overlap: Dictionary = generated.java_method_canLand_19([12.0, 24.0, 5.6, false, 1])
	var pref_build: Dictionary = generated.java_method_prefRotation_23([true, true, 15.0, true, 25.0, true, true, 35.0, 45.0])
	var pref_mine: Dictionary = generated.java_method_prefRotation_23([false, true, 15.0, true, 25.0, true, true, 35.0, 45.0])
	var pref_velocity: Dictionary = generated.java_method_prefRotation_23([false, false, 15.0, false, 25.0, true, true, 35.0, 45.0])
	var pref_rotation: Dictionary = generated.java_method_prefRotation_23([false, false, 15.0, false, 25.0, false, true, 35.0, 45.0])
	var canonical_check_target: Dictionary = source_unit_update_state.check_target_state(0.0, false, true)
	var canonical_grounded: bool = source_unit_update_state.is_grounded(0.0)
	var canonical_flying: bool = source_unit_update_state.is_flying(0.09)
	var canonical_can_drown: Dictionary = source_unit_update_state.can_drown_state(0.0, true)
	var canonical_floor: Variant = source_unit_update_state.drown_floor_state("floor-on")
	var canonical_wobble: Dictionary = source_unit_update_state.game_wobble_state(game, 12.0, 24.0, 30.0, 0.5, 0.75, 17)
	var canonical_move_at: Dictionary = source_unit_update_state.game_move_at_state(game, 1.0, 2.0, 4.0, 8.0, 0.6, 0.5)
	var canonical_floor_speed: Dictionary = source_unit_update_state.floor_speed_multiplier_state(0.0, false, 0.8, 2.0, 1.5)
	var canonical_move_pref: Dictionary = source_unit_update_state.move_pref_state(true, 4.0, 8.0)
	var canonical_move_at_default: Dictionary = source_unit_update_state.move_at_default_accel_state(4.0, 8.0, 0.6)
	var canonical_approach: Dictionary = source_unit_update_state.approach_state(1.0, 2.0, 4.0, 8.0, 0.6, 1.5, 0.5)
	var canonical_rotate_motion: Dictionary = source_unit_update_state.rotate_move_motion_state(20.0, 3.0, 4.0)
	var canonical_rotate_rotation: Dictionary = source_unit_update_state.game_rotate_move_rotation_state(game, 20.0, 3.0, 4.0, 5.0, 1.25, 0.5)
	var canonical_unloaded: Variant = source_unit_update_state.unloaded_state("unit-state")
	var canonical_boosting_default: Dictionary = source_unit_update_state.boosting_default_event_state(true)
	var canonical_boosting_guard: Dictionary = source_unit_update_state.boosting_guard_state(false, false, 0.1)
	var canonical_aim_position: Dictionary = source_unit_update_state.aim_look_position_state(10.0, 20.0)
	var canonical_aim_xy: Dictionary = source_unit_update_state.aim_look_xy_state(30.0, 40.0)
	var canonical_physic_size: float = source_unit_update_state.physic_size(8.0)
	var canonical_in_range: bool = source_unit_update_state.in_range(0.0, 0.0, 3.0, 4.0, 5.0)
	var canonical_has_weapons: bool = source_unit_update_state.has_weapons([{"name": "weapon"}])
	var canonical_speed: float = source_unit_update_state.speed(0.5, false, true, 0.0, 90.0, 0.5, true, 1.5, 2.0, 0.8)
	var canonical_ammof: Dictionary = source_unit_update_state.ammof_state()
	var canonical_displayable: Dictionary = source_unit_update_state.displayable_state(true)
	var canonical_sync_hidden: Dictionary = source_unit_update_state.is_sync_hidden_state(false, true)
	var canonical_sync_revealed: Dictionary = source_unit_update_state.is_sync_hidden_state(true, true)
	var canonical_handle_sync_hidden: Dictionary = source_unit_update_state.handle_sync_hidden_state(73)
	var canonical_in_fog_same_team: Dictionary = source_unit_update_state.in_fog_to_state(true, true, 20.0, 100.0, 200.0, false, [false, false, false, false, false, false, false, false])
	var canonical_in_fog_small_hidden: Dictionary = source_unit_update_state.in_fog_to_state(false, true, 12.0, 100.0, 200.0, false, [true, true, true, true, true, true, true, true])
	var canonical_in_fog_large_visible: Dictionary = source_unit_update_state.in_fog_to_state(false, true, 20.0, 100.0, 200.0, false, [false, false, true, false, false, false, false, false])
	var canonical_in_fog_large_hidden: Dictionary = source_unit_update_state.in_fog_to_state(false, true, 20.0, 100.0, 200.0, false, [false, false, false, false, false, false, false, false])
	var canonical_unit_range: Dictionary = source_unit_update_state.range_state(156.0)
	var canonical_clip_size_building: Dictionary = source_unit_update_state.clip_size_state(true, false, 10.0, 24.0, 40.0, 8.0, false, 0.0)
	var canonical_clip_size_building_infinite: Dictionary = source_unit_update_state.clip_size_state(true, true, 10.0, 24.0, 40.0, 8.0, false, 0.0)
	var canonical_clip_size_mining: Dictionary = source_unit_update_state.clip_size_state(false, false, 10.0, 24.0, 40.0, 8.0, true, 6.0)
	var canonical_clip_size_default: Dictionary = source_unit_update_state.clip_size_state(false, false, 10.0, 24.0, 40.0, 8.0, false, 6.0)
	var canonical_sense_total_items: Dictionary = source_unit_update_state.laccess_state("totalItems", sensor_unit_state, 8.0)
	var canonical_sense_controlled: Dictionary = source_unit_update_state.laccess_state("controlled", sensor_unit_state, 8.0)
	var canonical_sense_ping_x: Dictionary = source_unit_update_state.laccess_state("pingX", sensor_unit_state, 8.0)
	var canonical_sense_object_type: Dictionary = source_unit_update_state.sense_object_state("type", {"type": "alpha"}, "no-sensed")
	var canonical_sense_object_controller: Dictionary = source_unit_update_state.sense_object_state("controller", {"controller_kind": "LogicAI", "logic_controller": "logic", "is_valid": true}, "no-sensed")
	var canonical_sense_object_default: Dictionary = source_unit_update_state.sense_object_state("unknown", {}, "no-sensed")
	var canonical_sense_content_item: Dictionary = source_unit_update_state.sense_content_state({"kind": "Item", "id": "copper"}, {"stack_item_id": "copper", "stack_amount": 7.0}, 8.0)
	var canonical_sense_content_unit: Dictionary = source_unit_update_state.sense_content_state({"kind": "UnitType", "id": "flare"}, {"payloads": [{"kind": "UnitPayload", "unit_type_id": "flare"}, {"kind": "UnitPayload", "unit_type_id": "dagger"}]}, 8.0)
	var canonical_sense_content_block: Dictionary = source_unit_update_state.sense_content_state({"kind": "Block", "id": "router"}, {"payloads": [{"kind": "BuildPayload", "block_id": "router"}]}, 8.0)
	var canonical_sense_content_default: Dictionary = source_unit_update_state.sense_content_state({"kind": "Liquid", "id": "water"}, {}, 8.0)
	var canonical_set_prop_health: Dictionary = source_unit_update_state.set_prop_laccess_double_state("health", -4.0, {"max_health": 100.0, "dead": false}, 8.0)
	var canonical_set_prop_velocity: Dictionary = source_unit_update_state.set_prop_laccess_double_state("velocityX", 15.0, {}, 8.0)
	var canonical_set_prop_object: Dictionary = source_unit_update_state.set_prop_laccess_object_state("payloadType", null, {"is_payload": true, "net_client": false})
	var canonical_set_prop_content: Dictionary = source_unit_update_state.set_prop_content_state({"kind": "Item"}, 27.8, {"type_item_capacity": 20})
	var canonical_can_shoot: Dictionary = source_unit_update_state.can_shoot_state({"disarmed": false, "type_can_boost": true, "is_flying": true})
	var canonical_cannot_shoot_disarmed: Dictionary = source_unit_update_state.can_shoot_state({"disarmed": true, "type_can_boost": false, "is_flying": false})
	var canonical_is_enemy: Dictionary = source_unit_update_state.is_enemy_state(true)
	var canonical_collides: Dictionary = source_unit_update_state.collides_state(true)
	var canonical_item_capacity: Dictionary = source_unit_update_state.item_capacity_state(40)
	var canonical_bounds: Dictionary = source_unit_update_state.unit_bounds_metric_state(8.0)
	var canonical_collision: Dictionary = source_unit_update_state.collision_state(true, "bullet")
	var canonical_controller_set: Dictionary = source_unit_update_state.controller_set_state("next", "old-unit", "self-unit")
	var canonical_controller_get: Dictionary = source_unit_update_state.controller_get_state("current")
	var canonical_reset_controller: Dictionary = source_unit_update_state.reset_controller_state("created")
	var canonical_set_controller: Dictionary = source_unit_update_state.set_controller_state("old-type", "new-type", "next", "old-unit", "self-unit")
	var canonical_collision_layer_legs: Dictionary = source_unit_update_state.collision_layer_state(true, true, false, 1, 0, 2)
	var canonical_collision_layer_ground: Dictionary = source_unit_update_state.collision_layer_state(false, false, true, 1, 0, 2)
	var canonical_collision_layer_flying: Dictionary = source_unit_update_state.collision_layer_state(false, false, false, 1, 0, 2)
	var canonical_is_ai: Dictionary = source_unit_update_state.controller_predicates_state(true, false)
	var canonical_allow_command: Dictionary = source_unit_update_state.controller_predicates_state(false, true)
	var canonical_is_commandable: Dictionary = source_unit_update_state.controller_predicates_state(false, false)
	var canonical_can_target_null: Dictionary = source_unit_update_state.can_target_state(false, false, false, false, false, false)
	var canonical_can_target_unit: Dictionary = source_unit_update_state.can_target_state(true, true, true, false, true, false)
	var canonical_can_target_building: Dictionary = source_unit_update_state.can_target_state(true, false, false, true, false, true)
	var canonical_command_ok: Dictionary = source_unit_update_state.command_state(true)
	var canonical_command_bad: Dictionary = source_unit_update_state.command_state(false)
	var canonical_is_missile: Dictionary = source_unit_update_state.is_missile_state(true)
	var canonical_unit_count: Dictionary = source_unit_update_state.count_state(17, 4)
	var canonical_unit_cap_uncapped: Dictionary = source_unit_update_state.cap_state(true, false, false, false, false, true, 100, 5)
	var canonical_unit_cap_variable: Dictionary = source_unit_update_state.cap_state(false, false, false, false, false, true, 100, 5)
	var canonical_set_type: Dictionary = source_unit_update_state.set_type_state(3, 200.0, 0.3, 0.0, 6.0, 1, 2, 0, 0, false, true)
	var canonical_player_controllable_normal: Dictionary = source_unit_update_state.player_controllable_state(true, false, false, false)
	var canonical_player_controllable_privileged: Dictionary = source_unit_update_state.player_controllable_state(true, true, true, true)
	var canonical_player_controllable_disabled: Dictionary = source_unit_update_state.player_controllable_state(false, false, false, false)
	var canonical_targetable_direct: Dictionary = source_unit_update_state.targetable_state(true, false, false, false, 42)
	var canonical_targetable_payload: Dictionary = source_unit_update_state.targetable_state(false, true, true, true, 42)
	var canonical_targetable_non_payload: Dictionary = source_unit_update_state.targetable_state(false, true, false, true, 42)
	var canonical_killable_true: Dictionary = source_unit_update_state.killable_state(true)
	var canonical_killable_false: Dictionary = source_unit_update_state.killable_state(false)
	var canonical_hittable_direct: Dictionary = source_unit_update_state.hittable_state(true, false, false, false)
	var canonical_hittable_payload: Dictionary = source_unit_update_state.hittable_state(false, true, true, true)
	var canonical_hittable_non_payload: Dictionary = source_unit_update_state.hittable_state(false, true, false, true)
	var canonical_after_sync: Dictionary = source_unit_update_state.after_sync_state(3, true)
	var canonical_after_read_reset: Dictionary = source_unit_update_state.after_read_state(3, false, false, true)
	var canonical_after_read_keep: Dictionary = source_unit_update_state.after_read_state(3, true, true, true)
	var canonical_after_read_all: Dictionary = source_unit_update_state.after_read_all_state(true)
	var canonical_remove_with_trail: Dictionary = source_unit_destroy_state.remove_state(true, 3, 2.5, false, "team-blue", "type-red")
	var canonical_remove_without_trail: Dictionary = source_unit_destroy_state.remove_state(true, 0, 2.5, true, "team-blue", "type-red")
	var canonical_landed_shake: Dictionary = source_unit_update_state.landed_state(4.0)
	var canonical_landed_no_shake: Dictionary = source_unit_update_state.landed_state(0.0)
	var canonical_heal_partial: Dictionary = source_unit_update_state.heal_state(20.0, 100.0, 10.0, false)
	var canonical_heal_full: Dictionary = source_unit_update_state.heal_state(95.0, 100.0, 10.0, false)
	var canonical_drowning_liquid: Dictionary = source_unit_update_state.drowning_state(true, true, 10.0, true, 0.8, 1.0, 8.0, 1.0, true, false)
	var canonical_drowning_net_client: Dictionary = source_unit_update_state.drowning_state(true, true, 10.0, true, 1.0, 1.0, 8.0, 1.0, false, true)
	var canonical_drowning_dry: Dictionary = source_unit_update_state.drowning_state(false, false, 0.0, false, 0.8, 1.0, 8.0, 1.0, false, false)
	var canonical_should_update_controller: Dictionary = source_unit_update_state.ai_controller_server_gate_state(false, false, true, 0)
	var canonical_unit_icon: Dictionary = source_unit_metadata_state.unit_icon_state("dagger-ui")
	var canonical_controller_name_player: Dictionary = source_unit_update_state.get_controller_name_state(true, "[blue]player", false, false, "")
	var canonical_controller_name_logic: Dictionary = source_unit_update_state.get_controller_name_state(false, "", true, true, "logic-player")
	var canonical_controller_name_none: Dictionary = source_unit_update_state.get_controller_name_state(false, "", false, false, "")
	var canonical_unit_display: Dictionary = source_unit_update_state.display_state("table")
	var canonical_unit_draw: Dictionary = source_unit_update_state.draw_state()
	var canonical_unit_is_player: Dictionary = source_unit_update_state.is_player_state(true)
	var canonical_unit_is_not_player: Dictionary = source_unit_update_state.is_player_state(false)
	var canonical_unit_get_player: Dictionary = source_unit_update_state.get_player_state(true, "player-controller")
	var canonical_unit_get_no_player: Dictionary = source_unit_update_state.get_player_state(false, "ai-controller")
	var canonical_unit_killed_destroy: Dictionary = source_unit_destroy_state.killed_state(true, 5.0, false, true, "wreck", 0.7, 42)
	var canonical_unit_killed_wreck: Dictionary = source_unit_destroy_state.killed_state(false, 5.0, true, true, "wreck", 0.7, 42)
	var canonical_unit_kill_dispatch: Dictionary = source_unit_destroy_state.kill_sync_state(false, false, true, 42)
	var canonical_unit_kill_guard: Dictionary = source_unit_destroy_state.kill_sync_state(true, false, true, 42)
	var canonical_unit_to_string: Dictionary = source_unit_update_state.to_string_state(42, "dagger", 10.5, -2.25)
	var canonical_add_over_cap: Dictionary = source_unit_update_state.add_state(true, 11, 10, false, false, false)
	var canonical_add_guard_false: Dictionary = source_unit_update_state.add_state(true, 10, 10, false, false, false)
	var canonical_path_impassable: Dictionary = source_unit_update_state.is_path_impassable_state(false, 4, 5, true, -1)
	var canonical_path_passable_flying: Dictionary = source_unit_update_state.is_path_impassable_state(true, 4, 5, true, -1)
	var canonical_can_land: Dictionary = source_unit_update_state.can_land_state(12.0, 24.0, 5.6, false, 0)
	var canonical_can_not_land_overlap: Dictionary = source_unit_update_state.can_land_state(12.0, 24.0, 5.6, false, 1)
	var canonical_pref_build: Dictionary = source_unit_update_state.pref_rotation_state(true, true, 15.0, true, 25.0, true, true, 35.0, 45.0)
	var canonical_pref_mine: Dictionary = source_unit_update_state.pref_rotation_state(false, true, 15.0, true, 25.0, true, true, 35.0, 45.0)
	var canonical_pref_velocity: Dictionary = source_unit_update_state.pref_rotation_state(false, false, 15.0, false, 25.0, true, true, 35.0, 45.0)
	var canonical_pref_rotation: Dictionary = source_unit_update_state.pref_rotation_state(false, false, 15.0, false, 25.0, false, true, 35.0, 45.0)
	var registry_state: Dictionary = source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var generated_registry_state: Dictionary = source_generated_class_path_headquarter.registry_state()
	var proof := {
		"module": "UnitCompGeneratedRuntimeModuleProof",
		"check_target_matches": check_target.get("grounded", false) == canonical_check_target.get("grounded", false) and check_target.get("flying", false) == canonical_check_target.get("flying", false) and check_target.get("targetable", false) == canonical_check_target.get("targetable", false),
		"grounded_matches": grounded.get("grounded", false) == canonical_grounded,
		"flying_matches": flying.get("flying", false) == canonical_flying,
		"can_drown_matches": can_drown.get("can_drown", false) == canonical_can_drown.get("can_drown", false),
		"drown_floor_matches": floor_value.get("floor", null) == canonical_floor,
		"wobble_matches": wobble.get("x", null) == canonical_wobble.get("x", null) and wobble.get("y", null) == canonical_wobble.get("y", null),
		"move_at_matches": move_at.get("vel_x", null) == canonical_move_at.get("vel_x", null) and move_at.get("vel_y", null) == canonical_move_at.get("vel_y", null),
		"floor_speed_matches": floor_speed.get("speed_multiplier", null) == canonical_floor_speed.get("speed_multiplier", null),
		"move_pref_matches": move_pref.get("call", "") == canonical_move_pref.get("call", ""),
		"move_at_default_matches": move_at_default.get("acceleration", null) == canonical_move_at_default.get("acceleration", null),
		"approach_matches": approach.get("vel_x", null) == canonical_approach.get("vel_x", null) and approach.get("vel_y", null) == canonical_approach.get("vel_y", null),
		"rotate_move_matches": rotate_move.get("movement", {}) == canonical_rotate_motion.get("movement", {}) and rotate_move.get("rotation", null) == canonical_rotate_rotation.get("rotation", null),
		"unloaded_matches": unloaded.get("result", null) == canonical_unloaded,
		"boosting_default_matches": boosting_default.get("boost", false) == canonical_boosting_default.get("boost", false) and boosting_default.get("event", true) == canonical_boosting_default.get("event", true),
		"boosting_matches": boosting.get("should_boost", null) == true and boosting.get("event_fired", null) == true,
		"boosting_guard_matches": boosting_guard.get("returned", false) == canonical_boosting_guard.get("returned", false) and boosting_guard.get("should_boost", null) == null and boosting_guard.get("event_fired", null) == null,
		"aim_position_matches": aim_position.get("target", {}) == canonical_aim_position.get("target", {}) and aim_position.get("call_order", []) == canonical_aim_position.get("call_order", []),
		"aim_xy_matches": aim_xy.get("target", {}) == canonical_aim_xy.get("target", {}) and aim_xy.get("call_order", []) == canonical_aim_xy.get("call_order", []),
		"physic_size_matches": physic_size.get("size", 0.0) == canonical_physic_size,
		"in_range_matches": in_range.get("in_range", false) == canonical_in_range,
		"has_weapons_matches": has_weapons.get("has_weapons", false) == canonical_has_weapons,
		"speed_matches": speed.get("speed", 0.0) == canonical_speed,
		"ammof_matches": ammof.get("ammof", 0.0) == canonical_ammof.get("ammof", 0.0),
		"displayable_matches": displayable.get("displayable", false) == canonical_displayable.get("displayable", false),
		"sync_hidden_matches": sync_hidden.get("is_sync_hidden", false) == canonical_sync_hidden.get("is_sync_hidden", false),
		"sync_revealed_matches": sync_revealed.get("is_sync_hidden", true) == canonical_sync_revealed.get("is_sync_hidden", true),
		"handle_sync_hidden_matches": handle_sync_hidden.get("remove", {}) == canonical_handle_sync_hidden.get("remove", {}) and handle_sync_hidden.get("clear_removed_entity", {}) == canonical_handle_sync_hidden.get("clear_removed_entity", {}),
		"in_fog_same_team_matches": in_fog_same_team.get("in_fog", true) == canonical_in_fog_same_team.get("in_fog", true),
		"in_fog_small_hidden_matches": in_fog_small_hidden.get("in_fog", false) == canonical_in_fog_small_hidden.get("in_fog", false),
		"in_fog_large_visible_matches": in_fog_large_visible.get("in_fog", true) == canonical_in_fog_large_visible.get("in_fog", true) and in_fog_large_visible.get("checked_probes", []).size() == 3,
		"in_fog_large_hidden_matches": in_fog_large_hidden.get("in_fog", false) == canonical_in_fog_large_hidden.get("in_fog", false),
		"range_matches": unit_range.get("range", 0.0) == canonical_unit_range.get("range", 0.0),
		"clip_size_building_matches": clip_size_building.get("clip_size", 0.0) == canonical_clip_size_building.get("clip_size", 0.0) and clip_size_building.get("branch", "") == "building",
		"clip_size_building_infinite_matches": clip_size_building_infinite.get("clip_size", 0.0) == canonical_clip_size_building_infinite.get("clip_size", 0.0),
		"clip_size_mining_matches": clip_size_mining.get("clip_size", 0.0) == canonical_clip_size_mining.get("clip_size", 0.0) and clip_size_mining.get("branch", "") == "mining",
		"clip_size_default_matches": clip_size_default.get("clip_size", 0.0) == canonical_clip_size_default.get("clip_size", 0.0) and clip_size_default.get("branch", "") == "default",
		"sense_total_items_matches": sense_total_items.get("value", null) == canonical_sense_total_items.get("value", null),
		"sense_controlled_matches": sense_controlled.get("value", null) == canonical_sense_controlled.get("value", null),
		"sense_ping_x_matches": sense_ping_x.get("value_is_nan", false) == canonical_sense_ping_x.get("value_is_nan", false),
		"sense_object_type_matches": sense_object_type.get("value", null) == canonical_sense_object_type.get("value", null),
		"sense_object_controller_matches": sense_object_controller.get("value", null) == canonical_sense_object_controller.get("value", null),
		"sense_object_default_matches": sense_object_default.get("value", null) == canonical_sense_object_default.get("value", null),
		"sense_content_item_matches": sense_content_item.get("value", null) == canonical_sense_content_item.get("value", null),
		"sense_content_unit_matches": sense_content_unit.get("value", null) == canonical_sense_content_unit.get("value", null),
		"sense_content_block_matches": sense_content_block.get("value", null) == canonical_sense_content_block.get("value", null),
		"sense_content_default_matches": sense_content_default.get("value_is_nan", false) == canonical_sense_content_default.get("value_is_nan", false),
		"set_prop_health_matches": set_prop_health.get("action", "") == canonical_set_prop_health.get("action", "") and set_prop_health.get("next_value", null) == canonical_set_prop_health.get("next_value", null),
		"set_prop_velocity_matches": set_prop_velocity.get("next_value", null) == canonical_set_prop_velocity.get("next_value", null),
		"set_prop_object_matches": set_prop_object.get("action", "") == canonical_set_prop_object.get("action", ""),
		"set_prop_content_matches": set_prop_content.get("amount", 0) == canonical_set_prop_content.get("amount", 0),
		"can_shoot_matches": can_shoot.get("can_shoot", false) == canonical_can_shoot.get("can_shoot", false),
		"cannot_shoot_disarmed_matches": cannot_shoot_disarmed.get("can_shoot", true) == canonical_cannot_shoot_disarmed.get("can_shoot", true),
		"is_enemy_matches": is_enemy.get("is_enemy", false) == canonical_is_enemy.get("is_enemy", false),
		"collides_matches": collides.get("collides", false) == canonical_collides.get("collides", false),
		"item_capacity_matches": item_capacity.get("item_capacity", 0) == canonical_item_capacity.get("item_capacity", 0),
		"bounds_matches": bounds.get("bounds", 0.0) == canonical_bounds.get("bounds", 0.0),
		"collision_matches": collision.get("controller_hit_called", false) == canonical_collision.get("controller_hit_called", false) and collision.get("controller_hit", {}).get("bullet", null) == canonical_collision.get("controller_hit", {}).get("bullet", null),
		"controller_set_matches": controller_set.get("call_order", []) == canonical_controller_set.get("call_order", []) and controller_set.get("controller_unit", null) == canonical_controller_set.get("controller_unit", null),
		"controller_get_matches": controller_get.get("controller", null) == canonical_controller_get.get("controller", null),
		"reset_controller_matches": reset_controller.get("controller", null) == canonical_reset_controller.get("controller", null),
		"set_controller_matches": set_controller.get("call_order", []) == canonical_set_controller.get("call_order", []) and set_controller.get("type_changed", false) == canonical_set_controller.get("type_changed", false),
		"collision_layer_legs_matches": collision_layer_legs.get("collision_layer", -1) == canonical_collision_layer_legs.get("collision_layer", -1),
		"collision_layer_ground_matches": collision_layer_ground.get("collision_layer", -1) == canonical_collision_layer_ground.get("collision_layer", -1),
		"collision_layer_flying_matches": collision_layer_flying.get("collision_layer", -1) == canonical_collision_layer_flying.get("collision_layer", -1),
		"is_ai_matches": is_ai.get("is_ai", false) == canonical_is_ai.get("is_ai", false),
		"allow_command_matches": allow_command.get("allow_command", false) == canonical_allow_command.get("allow_command", false),
		"is_commandable_matches": is_commandable.get("is_commandable", true) == canonical_is_commandable.get("is_commandable", true),
		"can_target_null_matches": can_target_null.get("can_target", true) == canonical_can_target_null.get("can_target", true) and can_target_null.get("branch", "") == canonical_can_target_null.get("branch", ""),
		"can_target_unit_matches": can_target_unit.get("can_target", false) == canonical_can_target_unit.get("can_target", false) and can_target_unit.get("branch", "") == canonical_can_target_unit.get("branch", ""),
		"can_target_building_matches": can_target_building.get("can_target", false) == canonical_can_target_building.get("can_target", false) and can_target_building.get("branch", "") == canonical_can_target_building.get("branch", ""),
		"command_ok_matches": command_ok.get("returned_command_ai", false) == canonical_command_ok.get("returned_command_ai", false) and not bool(command_ok.get("throws", true)),
		"command_bad_matches": command_bad.get("throws", false) == canonical_command_bad.get("throws", false) and command_bad.get("exception_type", "") == canonical_command_bad.get("exception_type", ""),
		"is_missile_matches": is_missile.get("is_missile", false) == canonical_is_missile.get("is_missile", false),
		"count_matches": unit_count.get("count", -1) == canonical_unit_count.get("count", -1) and unit_count.get("type_id", -1) == canonical_unit_count.get("type_id", -1),
		"cap_uncapped_matches": unit_cap_uncapped.get("cap", 0) == canonical_unit_cap_uncapped.get("cap", 0) and unit_cap_uncapped.get("uncapped", false) == canonical_unit_cap_uncapped.get("uncapped", false),
		"cap_variable_matches": unit_cap_variable.get("cap", 0) == canonical_unit_cap_variable.get("cap", 0) and unit_cap_variable.get("uncapped", true) == canonical_unit_cap_variable.get("uncapped", true),
		"set_type_matches": set_type.get("assigned_type_id", -1) == canonical_set_type.get("assigned_type_id", -1) and set_type.get("setupWeapons", false) == canonical_set_type.get("setupWeapons", false) and set_type.get("createController", false) == canonical_set_type.get("createController", false),
		"player_controllable_normal_matches": player_controllable_normal.get("playerControllable", false) == canonical_player_controllable_normal.get("playerControllable", false) and not player_controllable_normal.get("logicPrivilegedBlocked", true),
		"player_controllable_privileged_matches": player_controllable_privileged.get("playerControllable", true) == canonical_player_controllable_privileged.get("playerControllable", true) and player_controllable_privileged.get("logicPrivilegedBlocked", false),
		"player_controllable_disabled_matches": player_controllable_disabled.get("playerControllable", true) == canonical_player_controllable_disabled.get("playerControllable", true),
		"targetable_direct_matches": targetable_direct.get("targetable", false) == canonical_targetable_direct.get("targetable", false) and not targetable_direct.get("payloadTargetable", true) and targetable_direct.get("targeter_id", -1) == 42,
		"targetable_payload_matches": targetable_payload.get("targetable", false) == canonical_targetable_payload.get("targetable", false) and targetable_payload.get("payloadTargetable", false) == canonical_targetable_payload.get("payloadTargetable", false),
		"targetable_non_payload_matches": targetable_non_payload.get("targetable", true) == canonical_targetable_non_payload.get("targetable", true) and not targetable_non_payload.get("payloadTargetable", true),
		"killable_true_matches": killable_true.get("killable", false) == canonical_killable_true.get("killable", false),
		"killable_false_matches": killable_false.get("killable", true) == canonical_killable_false.get("killable", true),
		"hittable_direct_matches": hittable_direct.get("hittable", false) == canonical_hittable_direct.get("hittable", false) and not hittable_direct.get("payloadHittable", true),
		"hittable_payload_matches": hittable_payload.get("hittable", false) == canonical_hittable_payload.get("hittable", false) and hittable_payload.get("payloadHittable", false) == canonical_hittable_payload.get("payloadHittable", false),
		"hittable_non_payload_matches": hittable_non_payload.get("hittable", true) == canonical_hittable_non_payload.get("hittable", true) and not hittable_non_payload.get("payloadHittable", true),
		"after_sync_matches": after_sync.get("type_id", -1) == canonical_after_sync.get("type_id", -1) and after_sync.get("controller_exists", false) == canonical_after_sync.get("controller_exists", false) and after_sync.get("call_order", []) == canonical_after_sync.get("call_order", []),
		"after_read_reset_matches": after_read_reset.get("resetController", false) == canonical_after_read_reset.get("resetController", false) and after_read_reset.get("call_order", []) == canonical_after_read_reset.get("call_order", []),
		"after_read_keep_matches": after_read_keep.get("resetController", true) == canonical_after_read_keep.get("resetController", true) and after_read_keep.get("call_order", []) == canonical_after_read_keep.get("call_order", []),
		"after_read_all_matches": after_read_all.get("controller_exists", false) == canonical_after_read_all.get("controller_exists", false) and after_read_all.get("call", "") == canonical_after_read_all.get("call", "") and after_read_all.get("afterReadArg", "") == canonical_after_read_all.get("afterReadArg", ""),
		"add_over_cap_matches": add_over_cap.get("unitCapDeath", false) == canonical_add_over_cap.get("unitCapDeath", false) and add_over_cap.get("rollbackUpdateCount", {}) == canonical_add_over_cap.get("rollbackUpdateCount", {}) and add_over_cap.get("call_order", []) == canonical_add_over_cap.get("call_order", []),
		"add_guard_false_matches": add_guard_false.get("unitCapDeath", true) == canonical_add_guard_false.get("unitCapDeath", true) and add_guard_false.get("rollbackUpdateCount", null) == canonical_add_guard_false.get("rollbackUpdateCount", null) and add_guard_false.get("call_order", []) == canonical_add_guard_false.get("call_order", []),
		"remove_with_trail_matches": remove_with_trail.get("trailFade", false) == canonical_remove_with_trail.get("trailFade", false) and remove_with_trail.get("trailFadeCall", {}) == canonical_remove_with_trail.get("trailFadeCall", {}) and remove_with_trail.get("call_order", []) == canonical_remove_with_trail.get("call_order", []),
		"remove_without_trail_matches": remove_without_trail.get("trailFade", true) == canonical_remove_without_trail.get("trailFade", true) and remove_without_trail.get("trailFadeCall", "unexpected") == canonical_remove_without_trail.get("trailFadeCall", "unexpected") and remove_without_trail.get("call_order", []) == canonical_remove_without_trail.get("call_order", []),
		"landed_shake_matches": landed_shake.get("shake", false) == canonical_landed_shake.get("shake", false) and landed_shake.get("call_order", []) == canonical_landed_shake.get("call_order", []),
		"landed_no_shake_matches": landed_no_shake.get("shake", true) == canonical_landed_no_shake.get("shake", true) and landed_no_shake.get("call_order", []) == canonical_landed_no_shake.get("call_order", []),
		"heal_partial_matches": heal_partial.get("health", -1.0) == canonical_heal_partial.get("health", -1.0) and heal_partial.get("wasHealed", false) == canonical_heal_partial.get("wasHealed", false),
		"heal_full_matches": heal_full.get("health", -1.0) == canonical_heal_full.get("health", -1.0) and heal_full.get("setWasHealed", true) == canonical_heal_full.get("setWasHealed", true),
		"drowning_liquid_matches": drowning_liquid.get("drownTime", -1.0) == canonical_drowning_liquid.get("drownTime", -1.0) and drowning_liquid.get("effectCall", null) == canonical_drowning_liquid.get("effectCall", null),
		"drowning_net_client_matches": drowning_net_client.get("kill", true) == canonical_drowning_net_client.get("kill", true) and drowning_net_client.get("eventCall", "unexpected") == canonical_drowning_net_client.get("eventCall", "unexpected"),
		"drowning_dry_matches": drowning_dry.get("drownTime", -1.0) == canonical_drowning_dry.get("drownTime", -1.0) and drowning_dry.get("canDrownOnFloor", true) == canonical_drowning_dry.get("canDrownOnFloor", true),
		"update_orchestration_matches": update_orchestration.get("deferred", true) == canonical_update_orchestration.get("deferred", true) and update_orchestration.get("stages", {}) == canonical_update_orchestration.get("stages", {}),
		"update_orchestration_order_matches": update_orchestration.get("call_order", []) == canonical_update_orchestration.get("call_order", []) and update_orchestration.get("call_order", []) == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_CALL_ORDER,
		"update_orchestration_owner_matches": update_orchestration.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_GENERATED_OWNER,
		"look_at_angle_matches": look_at_angle.get("rotation", null) == source_unit_update_state.game_look_at_angle_state(game, 10.0, 90.0, 5.0, 1.0, 0.5).get("rotation", null),
		"look_at_position_matches": look_at_position.get("rotation", null) == source_unit_update_state.game_look_at_position_state(game, 10.0, 0.0, 0.0, 10.0, 0.0, 5.0, 1.0, 0.5).get("rotation", null),
		"look_at_xy_matches": look_at_xy.get("rotation", null) == source_unit_update_state.game_look_at_xy_state(game, 10.0, 0.0, 0.0, 10.0, 0.0, 5.0, 1.0, 0.5).get("rotation", null),
		"path_impassable_matches": path_impassable.get("impassable", false) == canonical_path_impassable.get("impassable", false),
		"path_passable_flying_matches": path_passable_flying.get("impassable", true) == canonical_path_passable_flying.get("impassable", true),
		"can_land_matches": can_land.get("can_land", false) == canonical_can_land.get("can_land", false),
		"can_not_land_overlap_matches": can_not_land_overlap.get("can_land", true) == canonical_can_not_land_overlap.get("can_land", true),
		"pref_build_matches": pref_build.get("rotation", 0.0) == canonical_pref_build.get("rotation", 0.0) and pref_build.get("branch", "") == "build_plan",
		"pref_mine_matches": pref_mine.get("rotation", 0.0) == canonical_pref_mine.get("rotation", 0.0) and pref_mine.get("branch", "") == "mine_tile",
		"pref_velocity_matches": pref_velocity.get("rotation", 0.0) == canonical_pref_velocity.get("rotation", 0.0) and pref_velocity.get("branch", "") == "velocity",
		"pref_rotation_matches": pref_rotation.get("rotation", 0.0) == canonical_pref_rotation.get("rotation", 0.0) and pref_rotation.get("branch", "") == "rotation",
		"check_target_owner_matches": check_target.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CHECK_TARGET_GENERATED_OWNER,
		"grounded_owner_matches": grounded.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_GROUNDED_GENERATED_OWNER,
		"flying_owner_matches": flying.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_FLYING_GENERATED_OWNER,
		"can_drown_owner_matches": can_drown.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CAN_DROWN_GENERATED_OWNER,
		"drown_floor_owner_matches": floor_value.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_DROWN_FLOOR_GENERATED_OWNER,
		"wobble_owner_matches": wobble.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_WOBBLE_GENERATED_OWNER,
		"move_at_owner_matches": move_at.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_GENERATED_OWNER,
		"floor_speed_owner_matches": floor_speed.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_FLOOR_SPEED_MULTIPLIER_GENERATED_OWNER,
		"move_pref_owner_matches": move_pref.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_MOVE_PREF_GENERATED_OWNER,
		"move_at_default_owner_matches": move_at_default.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_MOVE_AT_DEFAULT_ACCEL_GENERATED_OWNER,
		"approach_owner_matches": approach.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_APPROACH_GENERATED_OWNER,
		"rotate_move_owner_matches": rotate_move.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_ROTATE_MOVE_GENERATED_OWNER,
		"unloaded_owner_matches": unloaded.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UNLOADED_GENERATED_OWNER,
		"boosting_default_owner_matches": boosting_default.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_DEFAULT_GENERATED_OWNER,
		"boosting_owner_matches": boosting.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_OWNER,
		"boosting_guard_owner_matches": boosting_guard.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_BOOSTING_GENERATED_OWNER,
		"aim_position_owner_matches": aim_position.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_POSITION_GENERATED_OWNER,
		"aim_xy_owner_matches": aim_xy.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AIM_LOOK_XY_GENERATED_OWNER,
		"physic_size_owner_matches": physic_size.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_PHYSIC_SIZE_GENERATED_OWNER,
		"in_range_owner_matches": in_range.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IN_RANGE_GENERATED_OWNER,
		"has_weapons_owner_matches": has_weapons.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_HAS_WEAPONS_GENERATED_OWNER,
		"speed_owner_matches": speed.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_SPEED_GENERATED_OWNER,
		"ammof_owner_matches": ammof.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AMMOF_GENERATED_OWNER,
		"displayable_owner_matches": displayable.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_DISPLAYABLE_GENERATED_OWNER,
		"sync_hidden_owner_matches": sync_hidden.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_SYNC_HIDDEN_GENERATED_OWNER,
		"handle_sync_hidden_owner_matches": handle_sync_hidden.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_HANDLE_SYNC_HIDDEN_GENERATED_OWNER,
		"in_fog_to_owner_matches": in_fog_large_hidden.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IN_FOG_TO_GENERATED_OWNER,
		"range_owner_matches": unit_range.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_RANGE_GENERATED_OWNER,
		"clip_size_owner_matches": clip_size_building.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CLIP_SIZE_GENERATED_OWNER,
		"sense_owner_matches": sense_total_items.get("source_owner", "") == source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_LACCESS_GENERATED_OWNER,
		"sense_object_owner_matches": sense_object_type.get("source_owner", "") == source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_OBJECT_GENERATED_OWNER,
		"sense_content_owner_matches": sense_content_item.get("source_owner", "") == source_unit_sensor_source_text_state.SOURCE_UNIT_SENSE_CONTENT_GENERATED_OWNER,
		"set_prop_double_owner_matches": set_prop_health.get("source_owner", "") == source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_DOUBLE_GENERATED_OWNER,
		"set_prop_object_owner_matches": set_prop_object.get("source_owner", "") == source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_LACCESS_OBJECT_GENERATED_OWNER,
		"set_prop_content_owner_matches": set_prop_content.get("source_owner", "") == source_unit_set_prop_source_text_state.SOURCE_UNIT_SET_PROP_CONTENT_GENERATED_OWNER,
		"can_shoot_owner_matches": can_shoot.get("source_owner", "") == source_unit_combat_metadata_source_text_state.SOURCE_UNIT_CAN_SHOOT_GENERATED_OWNER,
		"is_enemy_owner_matches": is_enemy.get("source_owner", "") == source_unit_combat_metadata_source_text_state.SOURCE_UNIT_IS_ENEMY_GENERATED_OWNER,
		"collides_owner_matches": collides.get("source_owner", "") == source_unit_combat_metadata_source_text_state.SOURCE_UNIT_COLLIDES_GENERATED_OWNER,
		"item_capacity_owner_matches": item_capacity.get("source_owner", "") == source_unit_combat_metadata_source_text_state.SOURCE_UNIT_ITEM_CAPACITY_GENERATED_OWNER,
		"bounds_owner_matches": bounds.get("source_owner", "") == source_unit_combat_metadata_source_text_state.SOURCE_UNIT_BOUNDS_GENERATED_OWNER,
		"collision_owner_matches": collision.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_GENERATED_OWNER,
		"controller_set_owner_matches": controller_set.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_SET_GENERATED_OWNER,
		"controller_get_owner_matches": controller_get.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_CONTROLLER_GET_GENERATED_OWNER,
		"reset_controller_owner_matches": reset_controller.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_RESET_CONTROLLER_GENERATED_OWNER,
		"set_controller_owner_matches": set_controller.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_SET_GENERATED_OWNER,
		"collision_layer_owner_matches": collision_layer_legs.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_COLLISION_LAYER_GENERATED_OWNER,
		"is_ai_owner_matches": is_ai.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_AI_GENERATED_OWNER,
		"allow_command_owner_matches": allow_command.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_ALLOW_COMMAND_GENERATED_OWNER,
		"is_commandable_owner_matches": is_commandable.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_COMMANDABLE_GENERATED_OWNER,
		"can_target_owner_matches": can_target_unit.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CAN_TARGET_GENERATED_OWNER,
		"command_owner_matches": command_ok.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_COMMAND_GENERATED_OWNER,
		"is_missile_owner_matches": is_missile.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_MISSILE_GENERATED_OWNER,
		"count_owner_matches": unit_count.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_COUNT_GENERATED_OWNER,
		"cap_owner_matches": unit_cap_variable.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CAP_GENERATED_OWNER,
		"set_type_owner_matches": set_type.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_SET_TYPE_GENERATED_OWNER,
		"player_controllable_owner_matches": player_controllable_normal.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_PLAYER_CONTROLLABLE_GENERATED_OWNER,
		"targetable_owner_matches": targetable_direct.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_TARGETABLE_GENERATED_OWNER,
		"killable_owner_matches": killable_true.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_KILLABLE_GENERATED_OWNER,
		"hittable_owner_matches": hittable_direct.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_HITTABLE_GENERATED_OWNER,
		"after_sync_owner_matches": after_sync.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AFTER_SYNC_GENERATED_OWNER,
		"after_read_owner_matches": after_read_reset.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_GENERATED_OWNER,
		"after_read_all_owner_matches": after_read_all.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_AFTER_READ_ALL_GENERATED_OWNER,
		"add_owner_matches": add_over_cap.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_ADD_GENERATED_OWNER,
		"remove_owner_matches": remove_with_trail.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_REMOVE_GENERATED_OWNER,
		"landed_owner_matches": landed_shake.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_LANDED_GENERATED_OWNER,
		"heal_owner_matches": heal_partial.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_HEAL_GENERATED_OWNER,
		"drowning_owner_matches": drowning_liquid.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_UPDATE_DROWNING_GENERATED_OWNER,
		"should_update_controller_matches": should_update_controller.get("shouldUpdateDefault", "") == canonical_should_update_controller.get("shouldUpdateDefault", "") and should_update_controller.get("shouldUpdateController", false) == canonical_should_update_controller.get("shouldUpdateController", false),
		"should_update_controller_owner_matches": should_update_controller.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_SHOULD_UPDATE_CONTROLLER_GENERATED_OWNER,
		"icon_matches": unit_icon.get("call", "") == canonical_unit_icon.get("call", "") and unit_icon.get("return", "") == canonical_unit_icon.get("return", "") and unit_icon.get("uiIcon", "") == canonical_unit_icon.get("uiIcon", ""),
		"icon_owner_matches": unit_icon.get("source_owner", "") == source_unit_metadata_state.SOURCE_UNIT_ICON_GENERATED_OWNER,
		"destroy_matches": unit_destroy.get("phases", []) == ["initial_payload", "explosion_dispatch", "visual_effects", "sound_and_event", "suicide_bomb_trigger", "shoot_on_death_mounts", "crash_landing_damage", "wreck_decal", "ability_death", "type_killed_remove"] and not bool(unit_destroy.get("guard_returned", true)),
		"destroy_owner_matches": unit_destroy.get("source_owner", "") == source_unit_destroy_source_text_state.SOURCE_UNIT_DESTROY_GENERATED_OWNER,
		"controller_name_player_matches": controller_name_player.get("controller_name", null) == canonical_controller_name_player.get("controller_name", null) and controller_name_player.get("branch", "") == "player",
		"controller_name_logic_matches": controller_name_logic.get("controller_name", null) == canonical_controller_name_logic.get("controller_name", null) and controller_name_logic.get("branch", "") == "logic_ai",
		"controller_name_none_matches": controller_name_none.get("controller_name", "not-null") == canonical_controller_name_none.get("controller_name", "not-null") and controller_name_none.get("branch", "") == "none",
		"controller_name_owner_matches": controller_name_player.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_GET_CONTROLLER_NAME_GENERATED_OWNER,
		"display_matches": unit_display.get("call", "") == canonical_unit_display.get("call", "") and unit_display.get("table", null) == canonical_unit_display.get("table", null),
		"draw_matches": unit_draw.get("call", "") == canonical_unit_draw.get("call", ""),
		"display_owner_matches": unit_display.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_DISPLAY_GENERATED_OWNER,
		"draw_owner_matches": unit_draw.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_DRAW_GENERATED_OWNER,
		"is_player_matches": unit_is_player.get("is_player", false) == canonical_unit_is_player.get("is_player", false) and unit_is_not_player.get("is_player", true) == canonical_unit_is_not_player.get("is_player", true),
		"get_player_matches": unit_get_player.get("player", null) == canonical_unit_get_player.get("player", null) and unit_get_no_player.get("player", "not-null") == canonical_unit_get_no_player.get("player", "not-null"),
		"is_player_owner_matches": unit_is_player.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_IS_PLAYER_GENERATED_OWNER,
		"get_player_owner_matches": unit_get_player.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_GET_PLAYER_GENERATED_OWNER,
		"killed_destroy_matches": unit_killed_destroy.get("destroyCall", null) == canonical_unit_killed_destroy.get("destroyCall", null) and unit_killed_destroy.get("dead", false) == canonical_unit_killed_destroy.get("dead", false),
		"killed_wreck_matches": unit_killed_wreck.get("wreckSound", null) == canonical_unit_killed_wreck.get("wreckSound", null) and unit_killed_wreck.get("health", 1.0) == canonical_unit_killed_wreck.get("health", 1.0),
		"kill_dispatch_matches": unit_kill_dispatch.get("returnGuard", true) == canonical_unit_kill_dispatch.get("returnGuard", true) and unit_kill_dispatch.get("call", "") == canonical_unit_kill_dispatch.get("call", ""),
		"kill_guard_matches": unit_kill_guard.get("returnGuard", false) == canonical_unit_kill_guard.get("returnGuard", false),
		"killed_owner_matches": unit_killed_destroy.get("source_owner", "") == source_unit_destroy_source_text_state.SOURCE_UNIT_KILLED_GENERATED_OWNER,
		"kill_owner_matches": unit_kill_dispatch.get("source_owner", "") == source_unit_destroy_source_text_state.SOURCE_UNIT_KILL_SYNC_GENERATED_OWNER,
		"to_string_matches": unit_to_string.get("to_string", "") == canonical_unit_to_string.get("to_string", "") and unit_to_string.get("return", "") == canonical_unit_to_string.get("return", ""),
		"to_string_owner_matches": unit_to_string.get("source_owner", "") == source_unit_controller_source_text_state.SOURCE_UNIT_TO_STRING_GENERATED_OWNER,
		"path_impassable_owner_matches": path_impassable.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_IS_PATH_IMPASSABLE_GENERATED_OWNER,
		"can_land_owner_matches": can_land.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_CAN_LAND_GENERATED_OWNER,
		"pref_rotation_owner_matches": pref_build.get("source_owner", "") == source_unit_update_source_text_state.SOURCE_UNIT_PREF_ROTATION_GENERATED_OWNER,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"generated_registry_valid": bool(generated_registry_state.get("valid", false)),
	}
	proof["matches"] = true
	for key in proof.keys():
		if key.ends_with("_matches") and not bool(proof[key]):
			proof["matches"] = false
	proof["matches"] = proof["matches"] and proof["registry_valid"] and proof["one_headquarter_per_ssot"] and proof["generated_registry_valid"]
	print("UNIT_COMP_GENERATED_RUNTIME_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("UnitCompGeneratedRuntimeModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))
