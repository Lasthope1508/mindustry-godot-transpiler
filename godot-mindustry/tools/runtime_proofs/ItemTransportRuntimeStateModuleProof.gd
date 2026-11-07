extends Node

const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

class FakeItemTransportGame extends RefCounted:
	var path_points: Array[Vector2] = [Vector2(10.0, 20.0), Vector2(30.0, 20.0), Vector2(30.0, 40.0)]
	var item_sprites: Array = [null, null]

func _ready() -> void:
	var fake_game := FakeItemTransportGame.new()
	var path_points := fake_game.path_points
	var bootstrap_game_state := source_item_transport_runtime_state_script.game_bootstrap_state(fake_game)
	var transport_game_state := source_item_transport_runtime_state_script.game_transport_positions_state(fake_game, 0.25, 0.5)
	var bootstrap_state := source_item_transport_runtime_state_script.bootstrap_state(path_points, 2, source_item_transport_runtime_state_script.ITEM_SPRITE_KEY_DEFAULT)
	var transport_state := source_item_transport_runtime_state_script.transport_positions_state(path_points, 2, 0.25, 0.5)
	var bootstrap_game_sprites: Array = bootstrap_game_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY, [])
	var transport_game_sprites: Array = transport_game_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY, [])
	var bootstrap_sprites: Array = bootstrap_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY, [])
	var transport_sprites: Array = transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY, [])
	var first_bootstrap_sprite: Dictionary = bootstrap_sprites[0] if not bootstrap_sprites.is_empty() else {}
	var first_transport_sprite: Dictionary = transport_sprites[0] if not transport_sprites.is_empty() else {}
	var bootstrap_schema_constants_valid := (
		bootstrap_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY)
		and bootstrap_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY)
		and bootstrap_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY)
		and first_bootstrap_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY)
		and first_bootstrap_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_KEY_KEY)
		and first_bootstrap_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY)
		and first_bootstrap_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY)
		and first_bootstrap_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY)
	)
	var transport_schema_constants_valid := (
		transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY)
		and transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITES_KEY)
		and transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY)
		and transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_BEFORE_KEY)
		and transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_DELTA_KEY)
		and transport_state.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SOURCE_OWNER_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_INDEX_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_X_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_Y_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_VISIBLE_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_PHASE_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_PATH_INDEX_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_NEXT_PATH_INDEX_KEY)
		and first_transport_sprite.has(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_LOCAL_T_KEY)
	)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceItemTransportRuntimeState",
		"game_bootstrap_matches": int(bootstrap_game_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 3 and bootstrap_game_sprites.size() == 3,
		"game_transport_matches": int(transport_game_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 2 and transport_game_sprites.size() == 2,
		"bootstrap_schema_constants_valid": bootstrap_schema_constants_valid,
		"transport_schema_constants_valid": transport_schema_constants_valid,
		"bootstrap_count_matches": int(bootstrap_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 2,
		"transport_count_matches": int(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 2,
		"transport_progress_matches": is_equal_approx(float(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY, 0.0)), 0.75),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["game_bootstrap_matches"] and proof["game_transport_matches"] and proof["bootstrap_schema_constants_valid"] and proof["transport_schema_constants_valid"] and proof["bootstrap_count_matches"] and proof["transport_count_matches"] and proof["transport_progress_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("ITEM_TRANSPORT_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("ItemTransportRuntimeStateModuleProof", proof)
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

