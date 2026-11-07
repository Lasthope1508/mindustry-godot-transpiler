extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_turret_runtime_state := preload("res://src/game/SourceTurretRuntimeState.gd")
const source_playable_scenario_defaults := preload("res://src/game/SourcePlayableScenarioDefaults.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var callbacks := source_turret_runtime_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_WORLD_SPEED_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_DIMENSIONS_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_HIT_SIZE_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_DAMAGE_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_DAMAGE_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_AMMO_MULTIPLIER_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_RELOAD_MULTIPLIER_FALLBACK),
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_KEY: Callable(game, source_turret_runtime_state.SOURCE_TURRET_RUNTIME_RANGE_CHANGE_FALLBACK),
	}
	var override_callbacks := source_turret_runtime_state.default_callbacks_state(self)
	var override_lifetime_fn: Callable = override_callbacks.get(source_turret_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY, Callable())
	var override_lifetime_value := float(override_lifetime_fn.call({"proof_lifetime_seconds": 12.5})) if override_lifetime_fn.is_valid() else 0.0
	var override_callbacks_match := override_lifetime_fn == Callable(self, "_proof_lifetime_seconds") and override_lifetime_value == 12.5
	var selected_turret: Variant = game.selected_playable_turret()
	var lifetime_wrapper := game.selected_turret_ammo_lifetime_seconds()
	var lifetime_module := source_turret_runtime_state.selected_ammo_lifetime_seconds_for_game(game)
	var world_speed_wrapper := game.selected_turret_ammo_world_speed()
	var world_speed_module := source_turret_runtime_state.selected_ammo_world_speed_for_game(game)
	var dimensions_wrapper := game.selected_turret_ammo_dimensions()
	var dimensions_module := source_turret_runtime_state.selected_ammo_dimensions_for_game(game)
	var hit_size_wrapper := game.selected_turret_ammo_hit_size()
	var hit_size_module := source_turret_runtime_state.selected_ammo_hit_size_for_game(game)
	var damage_wrapper := game.selected_turret_ammo_damage()
	var damage_module := source_turret_runtime_state.selected_ammo_damage_for_game(game)
	var ammo_multiplier_wrapper := game.selected_turret_ammo_multiplier()
	var ammo_multiplier_module := source_turret_runtime_state.selected_ammo_multiplier_for_game(game)
	var reload_multiplier_wrapper := game.selected_turret_ammo_reload_multiplier()
	var reload_multiplier_module := source_turret_runtime_state.selected_ammo_reload_multiplier_for_game(game)
	var range_change_wrapper := game.selected_turret_ammo_range_change()
	var range_change_module := source_turret_runtime_state.selected_ammo_range_change_for_game(game)
	var selected_playable_turret_wrapper: Variant = game.selected_playable_turret()
	var selected_playable_turret_module: Variant = source_turret_runtime_state.selected_playable_turret(game.get("content_catalog"), source_playable_scenario_defaults.BLOCK_DUO)
	var selected_key := source_turret_runtime_state.selected_turret_cell_key(game)
	var total_ammo_by_key: Dictionary = game.get("turret_total_ammo")
	total_ammo_by_key[selected_key] = 7
	game.set("turret_total_ammo", total_ammo_by_key)
	var cooldowns_by_key: Dictionary = game.get("turret_cooldowns")
	cooldowns_by_key[selected_key] = 1.25
	game.set("turret_cooldowns", cooldowns_by_key)
	var stacks_by_key: Dictionary = game.get("turret_ammo_stacks")
	stacks_by_key[selected_key] = [{"item": "copper", "amount": 3}]
	game.set("turret_ammo_stacks", stacks_by_key)
	var selected_total_wrapper := game.selected_turret_total_ammo()
	var selected_total_module := source_turret_runtime_state.selected_total_ammo_for_game(game)
	var selected_cooldown_wrapper := game.selected_turret_cooldown_seconds()
	var selected_cooldown_module := source_turret_runtime_state.selected_cooldown_seconds_for_game(game)
	var selected_stack_count_wrapper := game.selected_turret_ammo_stack_count()
	var selected_stack_count_module := source_turret_runtime_state.selected_ammo_stack_count_for_game(game)
	var selected_loaded_item_wrapper := game.selected_turret_loaded_ammo_item()
	var selected_loaded_item_module := source_turret_runtime_state.selected_loaded_ammo_item_for_game(game)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceTurretRuntimeState",
		"selected_turret_ready": selected_turret != null,
		"lifetime_matches": lifetime_wrapper == lifetime_module,
		"world_speed_matches": world_speed_wrapper == world_speed_module,
		"dimensions_matches": dimensions_wrapper == dimensions_module,
		"hit_size_matches": hit_size_wrapper == hit_size_module,
		"damage_matches": damage_wrapper == damage_module,
		"ammo_multiplier_matches": ammo_multiplier_wrapper == ammo_multiplier_module,
		"reload_multiplier_matches": reload_multiplier_wrapper == reload_multiplier_module,
		"range_change_matches": range_change_wrapper == range_change_module,
		"selected_playable_turret_matches": selected_playable_turret_wrapper == selected_playable_turret_module,
		"selected_runtime_storage_matches": selected_total_wrapper == selected_total_module and selected_cooldown_wrapper == selected_cooldown_module and selected_stack_count_wrapper == selected_stack_count_module and selected_loaded_item_wrapper == selected_loaded_item_module,
		"selected_total_ammo": selected_total_wrapper,
		"selected_cooldown_seconds": selected_cooldown_wrapper,
		"selected_ammo_stack_count": selected_stack_count_wrapper,
		"selected_loaded_ammo_item": selected_loaded_item_wrapper,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["lifetime_matches"] and proof["world_speed_matches"] and proof["dimensions_matches"] and proof["hit_size_matches"] and proof["damage_matches"] and proof["ammo_multiplier_matches"] and proof["reload_multiplier_matches"] and proof["range_change_matches"]
	proof["selected_playable_turret_matches"] = selected_playable_turret_wrapper == selected_playable_turret_module
	proof["matches"] = proof["module_matches"] and proof["selected_playable_turret_matches"] and proof["selected_runtime_storage_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("TURRET_RUNTIME_CALLBACK_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("TurretRuntimeCallbackModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func _turret_runtime_method_names() -> Dictionary:
	return {
		source_turret_runtime_state.SOURCE_TURRET_RUNTIME_LIFETIME_SECONDS_KEY: "_proof_lifetime_seconds",
	}

func _proof_lifetime_seconds(data: Dictionary) -> float:
	return float(data.get("proof_lifetime_seconds", 0.0))

