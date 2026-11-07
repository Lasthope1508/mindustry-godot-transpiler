extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_math_defaults := preload("res://src/game/SourceMathDefaults.gd")
const source_bullet_type_hit_state := preload("res://src/game/SourceBulletTypeHitState.gd")
const source_bullet_type_hit_entity_state := preload("res://src/game/SourceBulletTypeHitEntityState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_bullet_type_hit_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_bullet_type_hit_state.SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY: Callable(game, source_bullet_type_hit_state.SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_FALLBACK),
	}
	var override_callbacks := source_bullet_type_hit_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_bullet_type_hit_state.SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY, Callable()) == Callable(self, "proof_handle_pierce_state")
	var wrapper := game.source_bullet_type_hit_entity_handle_pierce_state({}, {}, {}, {}, {})
	var module := source_bullet_type_hit_state.game_entity_handle_pierce_state(game, {}, {}, {}, {}, {})
	var override_module := source_bullet_type_hit_state.game_entity_handle_pierce_state(self, {}, {"damage": 3.0}, {"x": 1.0, "y": 2.0}, {"effectiveHealth": 5.0}, {})
	var impact_module := source_bullet_type_hit_entity_state.entity_unit_effects_state({"impact": true, "knockback": -1.0}, {"rotation": 0.0, "x": 0.0, "y": 0.0}, {"isUnit": true, "x": 1.0, "y": 0.0}, {})
	var impact_expected := source_math_defaults.HALF_CIRCLE_DEGREES
	var impact_vector_x := float(impact_module.get("impulseVector", {}).get("x", 0.0))
	var impact_vector_y := float(impact_module.get("impulseVector", {}).get("y", 0.0))
	var impact_half_circle_matches := impact_vector_x < 0.0 and absf(impact_vector_y) < 0.001 and float(impact_module.get("bulletRotation", 0.0)) == 0.0 and impact_expected == source_math_defaults.HALF_CIRCLE_DEGREES
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBulletTypeHitState",
		"game_entity_handle_pierce_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_handle_pierce_matches": bool(override_module.get("removeCalled", false)) and is_equal_approx(float(override_module.get("damage", 0.0)), 44.0),
		"impact_half_circle_matches": impact_half_circle_matches,
		"impact_vector_x": impact_vector_x,
		"impact_vector_y": impact_vector_y,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
	}
	proof["matches"] = proof["game_entity_handle_pierce_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_handle_pierce_matches"] and proof["impact_half_circle_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BULLET_TYPE_HIT_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().process_frame
	get_tree().quit(0)

func proof_handle_pierce_state(_bullet_type_state: Dictionary, bullet_state: Dictionary, pierce_state: Dictionary) -> Dictionary:
	var bullet_after := bullet_state.duplicate(true)
	bullet_after["proof_pierce"] = pierce_state
	return {
		"bullet": bullet_after,
		"damage": 44.0,
		"removeCalled": true,
	}

func _bullet_type_hit_method_names() -> Dictionary:
	return {
		source_bullet_type_hit_state.SOURCE_BULLET_TYPE_HIT_HANDLE_PIERCE_KEY: "proof_handle_pierce_state",
	}

