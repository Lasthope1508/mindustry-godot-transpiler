extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_weapon_bullet_effects_state := preload("res://src/game/SourceWeaponBulletEffectsState.gd")
const source_weapons_state := preload("res://src/game/SourceWeaponsState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_weapons_state.default_callbacks_state(game)
	var create_call_state := {
		"bulletContinues": true,
		"mountX": 12.0,
		"mountY": -4.0,
		"angleLifeState": {
			"shootAngle": 30.0,
		},
		"bulletCreateCall": {
			"x": 16.0,
			"y": -2.0,
			"angle": 30.0,
		},
	}
	var mount_state := {
		"allowShootEffects": true,
		"barrelCounter": 5,
		"recoil": 0.25,
		"recoils": [0.0, 0.0, 0.0],
		"heat": 0.125,
	}
	var weapon_state := {
		"continuous": false,
		"shootSound": "shoot",
		"initialShootSound": "initialShoot",
		"shootSoundVolume": 0.8,
		"soundPitchMin": 0.7,
		"soundPitchMax": 1.1,
		"ejectEffect": "casing",
		"x": -2.0,
		"shake": 2.5,
		"recoils": 3,
	}
	var bullet_state := {
		"hitColor": "scarlet",
		"shootEffect": "shootSmall",
		"smokeEffect": "shootSmallSmoke",
		"recoil": 4.0,
	}
	var unit_state := {
		"id": 77,
		"vel": {"x": 1.0, "y": -1.0},
	}
	var sound_wrapper := game.source_weapon_bullet_sound_state(create_call_state, weapon_state, 0.95)
	var sound_facade := source_weapons_state.bullet_sound_state(create_call_state, weapon_state, 0.95)
	var sound_module := source_weapon_bullet_effects_state.bullet_sound_state(create_call_state, weapon_state, 0.95)
	var effects_wrapper := game.source_weapon_bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)
	var effects_facade := source_weapons_state.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)
	var effects_module := source_weapon_bullet_effects_state.bullet_effects_state(create_call_state, mount_state, weapon_state, bullet_state, unit_state)
	var recoil_wrapper := game.source_weapon_bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state)
	var recoil_facade := source_weapons_state.game_bullet_recoil_velocity_state(game, create_call_state, unit_state, bullet_state)
	var recoil_module := source_weapon_bullet_effects_state.bullet_recoil_velocity_state(create_call_state, unit_state, bullet_state, callbacks.get(source_weapons_state.SOURCE_WEAPONS_TRNS_VEC_KEY, Callable()))
	var shake_wrapper := game.source_weapon_bullet_shake_state(create_call_state, weapon_state)
	var shake_facade := source_weapons_state.bullet_shake_state(create_call_state, weapon_state)
	var shake_module := source_weapon_bullet_effects_state.bullet_shake_state(create_call_state, weapon_state)
	var mount_recoil_wrapper := game.source_weapon_bullet_mount_recoil_state(create_call_state, mount_state)
	var mount_recoil_facade := source_weapons_state.bullet_mount_recoil_state(create_call_state, mount_state)
	var mount_recoil_module := source_weapon_bullet_effects_state.bullet_mount_recoil_state(create_call_state, mount_state)
	var recoil_slots_wrapper := game.source_weapon_bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)
	var recoil_slots_facade := source_weapons_state.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)
	var recoil_slots_module := source_weapon_bullet_effects_state.bullet_recoil_slots_state(create_call_state, mount_state, weapon_state)
	var heat_wrapper := game.source_weapon_bullet_heat_state(create_call_state, mount_state)
	var heat_facade := source_weapons_state.bullet_heat_state(create_call_state, mount_state)
	var heat_module := source_weapon_bullet_effects_state.bullet_heat_state(create_call_state, mount_state)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "WEAPON_BULLET_EFFECTS_MODULE_PROOF",
		"sound_matches": sound_wrapper == sound_facade and sound_wrapper == sound_module,
		"effects_matches": effects_wrapper == effects_facade and effects_wrapper == effects_module,
		"recoil_velocity_matches": recoil_wrapper == recoil_facade and recoil_wrapper == recoil_module,
		"shake_matches": shake_wrapper == shake_facade and shake_wrapper == shake_module,
		"mount_recoil_matches": mount_recoil_wrapper == mount_recoil_facade and mount_recoil_wrapper == mount_recoil_module,
		"recoil_slots_matches": recoil_slots_wrapper == recoil_slots_facade and recoil_slots_wrapper == recoil_slots_module,
		"heat_matches": heat_wrapper == heat_facade and heat_wrapper == heat_module,
		"negative_weapon_x_flips_eject_angle": float(effects_module.get("effectCalls", [])[0].get("angle", 0.0)) == -30.0,
		"recoil_uses_headquarter_trns_vec": float(recoil_module.get("recoilVector", {}).get("angle_degrees", 0.0)) == 210.0,
		"recoil_slot_index_matches_barrel_counter": int(recoil_slots_module.get("recoilIndex", -1)) == 2,
		"mount_heat_applies": bool(heat_module.get("mountHeatApplied", false)) and float(heat_module.get("mountHeat", 0.0)) == 1.0,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["sound_matches"] and proof["effects_matches"] and proof["recoil_velocity_matches"] and proof["shake_matches"] and proof["mount_recoil_matches"] and proof["recoil_slots_matches"] and proof["heat_matches"] and proof["negative_weapon_x_flips_eject_angle"] and proof["recoil_uses_headquarter_trns_vec"] and proof["recoil_slot_index_matches_barrel_counter"] and proof["mount_heat_applies"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("WEAPON_BULLET_EFFECTS_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("WeaponBulletEffectsModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

