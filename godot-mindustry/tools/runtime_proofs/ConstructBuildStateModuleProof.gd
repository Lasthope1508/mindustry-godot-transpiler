extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_construct_build_state := preload("res://src/game/SourceConstructBuildState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var current_block := {
		"localizedName": "Copper Wall",
		"fullIcon": "copper-wall-icon",
	}
	var last_config := {"rotation": 1}
	var callbacks := source_construct_build_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_construct_build_state.SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY: Callable(game, source_construct_build_state.SOURCE_CONSTRUCT_BUILD_LERP_DELTA_FALLBACK),
	}
	var override_callbacks := source_construct_build_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_construct_build_state.SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY, Callable()) == Callable(self, "proof_lerp_delta")
	var wrapper := game.construct_build_inner_runtime_state(
		true,
		false,
		true,
		true,
		true,
		true,
		false,
		4,
		7,
		1,
		current_block,
		last_config,
		"building",
		0.4,
		true,
		0.25,
		"fallback-object",
		false,
		true,
		32.0,
		48.0,
		2,
		false,
		0.3,
		0.5
	)
	var module := source_construct_build_state.game_inner_runtime_state(
		game,
		true,
		false,
		true,
		true,
		true,
		true,
		false,
		4,
		7,
		1,
		current_block,
		last_config,
		"building",
		0.4,
		true,
		0.25,
		"fallback-object",
		false,
		true,
		32.0,
		48.0,
		2,
		false,
		0.3,
		0.5
	)
	var override_module := source_construct_build_state.game_inner_runtime_state(
		self,
		true,
		false,
		true,
		true,
		true,
		true,
		false,
		4,
		7,
		1,
		current_block,
		last_config,
		"building",
		0.4,
		true,
		0.25,
		"fallback-object",
		false,
		true,
		32.0,
		48.0,
		2,
		false,
		0.3,
		0.5
	)
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConstructBuildState",
		"inner_runtime_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_lerp_delta_matches": is_equal_approx(float(override_module.get("construct_color_after", 0.0)), 0.875),
		"module_matches": wrapper == module,
		"construct_color_after_matches": wrapper.get("construct_color_after", null) == module.get("construct_color_after", null),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_lerp_delta_matches"] and proof["construct_color_after_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("CONSTRUCT_BUILD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_lerp_delta(_from_value: float, _to_value: float, _progress: float, _source_delta: float) -> float:
	return 0.875

func _construct_build_method_names() -> Dictionary:
	return {
		source_construct_build_state.SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY: "proof_lerp_delta",
	}
