extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const SourceConstructBuildState := preload("res://src/game/SourceConstructBuildState.gd")
const SourceSsotCatalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var current_block := {
		"localizedName": "Copper Wall",
		"fullIcon": "copper-wall-icon",
	}
	var last_config := {"rotation": 1}
	var callbacks := SourceConstructBuildState.default_callbacks_state(game)
	var expected_callbacks := {
		"lerp_delta": Callable(game, "source_mathf_lerp_delta"),
	}
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
	var module := SourceConstructBuildState.inner_runtime_state(
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
		0.5,
		callbacks.get("lerp_delta", Callable())
	)
	var registry_state := SourceSsotCatalog.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConstructBuildState",
		"inner_runtime_matches": wrapper == module,
		"default_callbacks_match": callbacks == expected_callbacks,
		"module_matches": wrapper == module,
		"construct_color_after_matches": wrapper.get("construct_color_after", null) == module.get("construct_color_after", null),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	print("CONSTRUCT_BUILD_STATE_MODULE_PROOF " + JSON.stringify(proof))
	game.free()
	await get_tree().create_timer(2.0).timeout
	get_tree().quit(0)
