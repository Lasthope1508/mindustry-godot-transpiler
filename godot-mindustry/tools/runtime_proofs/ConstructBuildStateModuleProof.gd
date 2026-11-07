extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const source_construct_build_state := preload("res://src/game/SourceConstructBuildState.gd")
const source_construct_build_io_state := preload("res://src/game/SourceConstructBuildIoState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

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
	var io_write_facade := source_construct_build_state.write_state(0.45, 1, 2, [0.25, 0.75], [1.0, 1.5], [3, 5])
	var io_write_direct := source_construct_build_io_state.write_state(0.45, 1, 2, [0.25, 0.75], [1.0, 1.5], [3, 5])
	var content_blocks := {
		1: {"id": 1, "buildTime": 4.0},
		"2": {"id": 2, "buildTime": 8.0},
	}
	var air_block := {"id": -1, "name": "air", "buildTime": 0.0}
	var io_read_facade := source_construct_build_state.read_state(0.45, 1, 2, 2, [0.25, 0.75], [1.0, 1.5], [3, 5], 1, content_blocks, air_block, 2.0)
	var io_read_direct := source_construct_build_io_state.read_state(0.45, 1, 2, 2, [0.25, 0.75], [1.0, 1.5], [3, 5], 1, content_blocks, air_block, 2.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceConstructBuildState",
		"inner_runtime_matches": wrapper == module,
		"io_module_direct_matches": io_write_facade == io_write_direct and io_read_facade == io_read_direct,
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"override_lerp_delta_matches": is_equal_approx(float(override_module.get("construct_color_after", 0.0)), 0.875),
		"module_matches": wrapper == module,
		"construct_color_after_matches": wrapper.get("construct_color_after", null) == module.get("construct_color_after", null),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["io_module_direct_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["override_lerp_delta_matches"] and proof["construct_color_after_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	runtime_proof_state.write_proof("ConstructBuildStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_lerp_delta(_from_value: float, _to_value: float, _progress: float, _source_delta: float) -> float:
	return 0.875

func _construct_build_method_names() -> Dictionary:
	return {
		source_construct_build_state.SOURCE_CONSTRUCT_BUILD_LERP_DELTA_KEY: "proof_lerp_delta",
	}

