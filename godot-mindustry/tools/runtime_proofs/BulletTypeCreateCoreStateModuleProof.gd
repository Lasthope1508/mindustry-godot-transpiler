extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const PortGameScript := preload("res://src/game/PortGame.gd")
const source_bullet_type_create_state := preload("res://src/game/SourceBulletTypeCreateState.gd")
const source_bullet_type_create_core_state := preload("res://src/game/SourceBulletTypeCreateCoreState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var create_call_state := {
		"bulletContinues": true,
		"bulletCreateCall": {
			"angle": 15.0,
			"team": "sharded",
			"x": 32.0,
			"y": 48.0,
			"owner": "owner-1",
			"shooter": null,
		},
	}
	var bullet_type_state := {
		"id": "duo-basic",
		"createChance": 1.0,
		"angleOffset": 5.0,
		"randomAngleOffset": 0.0,
		"ignoreSpawnAngle": false,
		"spawnUnit": {},
	}
	var owner_health_state := {
		"isHealthc": true,
		"dead": false,
	}
	var shooter_state := {
		"kind": "Unit",
		"id": "shooter-1",
	}
	var wrapper_initial := game.source_bullet_type_create_initial_gate_state(create_call_state, bullet_type_state, 2.5, 0.0)
	var facade_initial := source_bullet_type_create_state.initial_gate_state(create_call_state, bullet_type_state, 2.5, 0.0)
	var core_initial := source_bullet_type_create_core_state.initial_gate_state(create_call_state, bullet_type_state, 2.5, 0.0)
	var wrapper_spawn := game.source_bullet_type_create_spawn_unit_state(wrapper_initial, bullet_type_state, false, owner_health_state, shooter_state)
	var facade_spawn := source_bullet_type_create_state.spawn_unit_state(facade_initial, bullet_type_state, false, owner_health_state, shooter_state)
	var core_spawn := source_bullet_type_create_core_state.spawn_unit_state(core_initial, bullet_type_state, false, owner_health_state, shooter_state)
	var wrapper_identity := game.source_bullet_type_create_bullet_identity_state(create_call_state, wrapper_initial, wrapper_spawn, bullet_type_state)
	var facade_identity := source_bullet_type_create_state.bullet_identity_state(create_call_state, facade_initial, facade_spawn, bullet_type_state)
	var core_identity := source_bullet_type_create_core_state.bullet_identity_state(create_call_state, core_initial, core_spawn, bullet_type_state)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBulletTypeCreateCoreState",
		"initial_wrapper_matches_core": wrapper_initial == core_initial,
		"initial_facade_matches_core": facade_initial == core_initial,
		"spawn_wrapper_matches_core": wrapper_spawn == core_spawn,
		"spawn_facade_matches_core": facade_spawn == core_spawn,
		"identity_wrapper_matches_core": wrapper_identity == core_identity,
		"identity_facade_matches_core": facade_identity == core_identity,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["initial_wrapper_matches_core"] and proof["initial_facade_matches_core"] and proof["spawn_wrapper_matches_core"] and proof["spawn_facade_matches_core"] and proof["identity_wrapper_matches_core"] and proof["identity_facade_matches_core"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BULLET_TYPE_CREATE_CORE_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BulletTypeCreateCoreStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

