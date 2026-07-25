extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceWeaponsState := preload("res://src/game/SourceWeaponsState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := SourceWeaponsState.default_callbacks_state(game)
	var expected_callbacks := {
		"approach_delta": Callable(game, "source_mathf_approach_delta"),
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
		"trns_vec": Callable(game, "source_arc_angles_trns_vec"),
		"angles_angle": Callable(game, "source_arc_angles_angle"),
		"move_toward_angle": Callable(game, "source_arc_angles_move_toward"),
		"angle_dist": Callable(game, "source_arc_angles_angle_dist"),
		"mathf_dst": Callable(game, "source_mathf_dst"),
		"status_apply_result": Callable(game, "source_status_apply_result"),
		"bullet_origin_state": Callable(game, "source_weapon_update_bullet_origin_state"),
	}
	var mount_state := {
		"charging": false,
		"totalShots": 4,
		"barrelCounter": 2,
	}
	var weapon_state := {
		"shootStatus": "burning",
		"shootStatusDuration": 99.0,
		"firstShotDelay": 1.25,
		"chargeSound": "charge",
		"soundPitchMin": 0.7,
		"soundPitchMax": 1.1,
		"parentizeEffects": false,
	}
	var bullet_state := {
		"keepVelocity": true,
		"chargeEffect": "chargeEffect",
	}
	var unit_state := {
		"id": 42,
		"statusImmune": false,
	}
	var shoot_state := {
		"shots": 2,
		"firstShotDelay": 0.25,
		"shotDelay": 0.5,
	}
	var charge_wrapper := game.source_weapon_shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, 8.0, 9.0, 45.0)
	var charge_module := SourceWeaponsState.shoot_charge_start_state(mount_state, weapon_state, bullet_state, unit_state, 8.0, 9.0, 45.0, callbacks.get("status_apply_result", Callable()))
	var events_wrapper := game.source_shoot_pattern_default_events(shoot_state)
	var events_module := SourceWeaponsState.shoot_pattern_default_events(shoot_state)
	var dispatch_wrapper := game.source_weapon_shoot_default_pattern_dispatch_state(mount_state, shoot_state)
	var dispatch_module := SourceWeaponsState.shoot_default_pattern_dispatch_state(mount_state, shoot_state)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceWeaponsState",
		"charge_start_matches": charge_wrapper == charge_module,
		"default_events_matches": events_wrapper == events_module,
		"default_dispatch_matches": dispatch_wrapper == dispatch_module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"module_matches": charge_wrapper == charge_module and events_wrapper == events_module and dispatch_wrapper == dispatch_module,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("WEAPON_SHOOT_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
