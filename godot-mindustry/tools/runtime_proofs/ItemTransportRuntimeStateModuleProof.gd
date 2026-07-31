extends Node

const source_item_transport_runtime_state_script := preload("res://src/game/SourceItemTransportRuntimeState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var path_points: Array[Vector2] = [Vector2(10.0, 20.0), Vector2(30.0, 20.0), Vector2(30.0, 40.0)]
	var bootstrap_state := source_item_transport_runtime_state_script.bootstrap_state(path_points, 2, source_item_transport_runtime_state_script.ITEM_SPRITE_KEY_DEFAULT)
	var transport_state := source_item_transport_runtime_state_script.transport_positions_state(path_points, 2, 0.25, 0.5)
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
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceItemTransportRuntimeState",
		"bootstrap_schema_constants_valid": bootstrap_schema_constants_valid,
		"transport_schema_constants_valid": transport_schema_constants_valid,
		"bootstrap_count_matches": int(bootstrap_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 2,
		"transport_count_matches": int(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_SPRITE_COUNT_KEY, 0)) == 2,
		"transport_progress_matches": is_equal_approx(float(transport_state.get(source_item_transport_runtime_state_script.SOURCE_ITEM_TRANSPORT_PROGRESS_KEY, 0.0)), 0.75),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	print("ITEM_TRANSPORT_RUNTIME_STATE_MODULE_PROOF " + JSON.stringify(proof))
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
