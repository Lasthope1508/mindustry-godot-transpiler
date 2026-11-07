extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_unit_metadata_state := preload("res://src/game/SourceUnitMetadataState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	var callbacks := source_unit_metadata_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_unit_metadata_state.SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY: Callable(game, source_unit_metadata_state.SOURCE_UNIT_METADATA_BULLET_DAMAGE_FALLBACK),
	}
	var override_callbacks := source_unit_metadata_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_unit_metadata_state.SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY, Callable()) == Callable(self, "proof_bullet_damage")
	var unit_type: Variant = game.selected_enemy_unit()
	var wrapper := game.source_unit_weapon_damage(unit_type)
	var module := source_unit_metadata_state.game_unit_weapon_damage_state(game, unit_type)
	var wrapper_speed := game.source_unit_world_speed(unit_type)
	var module_speed := source_unit_metadata_state.game_unit_world_speed(game, unit_type)
	var override_unit_type := {"properties": {"weapons": [{"bullet": {"damage": 12.0}}]}}
	var override_module := source_unit_metadata_state.game_unit_weapon_damage_state(self, override_unit_type)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceUnitMetadataState",
		"wrapper_matches": is_equal_approx(float(wrapper), float(module)),
		"world_speed_matches": is_equal_approx(float(wrapper_speed), float(module_speed)),
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_bullet_damage_matches": is_equal_approx(float(override_module), 42.5),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["module_matches"] = proof["wrapper_matches"] and proof["world_speed_matches"]
	proof["matches"] = proof["module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_bullet_damage_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("UnitMetadataCallbackModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_bullet_damage(_bullet: Dictionary) -> float:
	return 42.5

func _unit_metadata_method_names() -> Dictionary:
	return {
		source_unit_metadata_state.SOURCE_UNIT_METADATA_BULLET_DAMAGE_KEY: "proof_bullet_damage",
	}

