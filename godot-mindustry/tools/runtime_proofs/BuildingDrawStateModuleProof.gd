extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_building_draw_state_script := preload("res://src/game/SourceBuildingDrawState.gd")
const source_building_draw_generated_state_script := preload("res://src/game/SourceBuildingDrawGeneratedState.gd")
const source_ssot_accessor_runtime_state := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const runtime_proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_building_draw_state_script.default_callbacks_state(game)
	var expected_callbacks := {
		source_building_draw_state_script.SOURCE_BUILDING_DRAW_RANDOM_SEED_INT_KEY: Callable(game, source_building_draw_state_script.SOURCE_BUILDING_DRAW_RANDOM_SEED_INT_FALLBACK),
		source_building_draw_state_script.SOURCE_BUILDING_DRAW_LERP_DELTA_KEY: Callable(game, source_building_draw_state_script.SOURCE_BUILDING_DRAW_LERP_DELTA_FALLBACK),
	}
	var override_callbacks := source_building_draw_state_script.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_building_draw_state_script.SOURCE_BUILDING_DRAW_RANDOM_SEED_INT_KEY, Callable()) == Callable(self, "proof_random_seed_int") \
		and override_callbacks.get(source_building_draw_state_script.SOURCE_BUILDING_DRAW_LERP_DELTA_KEY, Callable()) == Callable(self, "proof_lerp_delta")
	var draw_wrapper := game.source_building_draw_state(3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var draw_module := source_building_draw_state_script.game_draw_state(game, 3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var cached_wrapper := game.source_building_draw_cached_state(3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var cached_module := source_building_draw_state_script.game_draw_cached_state(game, 3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var payload_wrapper := game.source_building_payload_draw_state(true, true, 12.0, 15.0, 3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var payload_module := source_building_draw_state_script.game_payload_draw_state(game, true, true, 12.0, 15.0, 3, true, 4, 7, 64.0, 80.0, true, true, 1)
	var light_wrapper := game.source_building_draw_light_state(true, true, true, "current", 0.9, "light", 0.7, 0.2, 0.25, 0.5, 64.0, 80.0, 3)
	var light_module := source_building_draw_state_script.game_draw_light_state(game, true, true, true, "current", 0.9, "light", 0.7, 0.2, 0.25, 0.5, 64.0, 80.0, 3)
	var rotdeg_wrapper := game.generated_building_comp_rotdeg_bridge_state(1)
	var rotdeg_module := source_building_draw_generated_state_script.generated_rotdeg_bridge_state(1)
	var fog_radius_wrapper := game.generated_building_comp_fog_radius_bridge_state(34.0)
	var fog_radius_module := source_building_draw_generated_state_script.generated_fog_radius_bridge_state(34.0)
	var generated_draw_status_wrapper := game.generated_building_comp_draw_status_bridge_state(true, 2, 3, 64.0, 80.0, 8.0)
	var generated_draw_status_module := source_building_draw_generated_state_script.generated_draw_status_bridge_state(true, 2, 3, 64.0, 80.0, 8.0)
	var generated_drawrot_wrapper := game.generated_building_comp_drawrot_bridge_state(true, true, 3)
	var generated_drawrot_module := source_building_draw_generated_state_script.generated_drawrot_bridge_state(true, true, 3)
	var generated_draw_configure_wrapper := game.generated_building_comp_draw_configure_bridge_state(64.0, 80.0, 3, 8.0)
	var generated_draw_configure_module := source_building_draw_generated_state_script.generated_draw_configure_bridge_state(64.0, 80.0, 3, 8.0)
	var registry_state := source_ssot_accessor_runtime_state.canonical_headquarter_registry_state()
	var proof := {
		"module": "SourceBuildingDrawState",
		"default_callbacks_match": callbacks == expected_callbacks,
		"draw_state_matches": draw_wrapper == draw_module,
		"draw_cached_matches": cached_wrapper == cached_module,
		"payload_draw_matches": payload_wrapper == payload_module,
		"draw_light_matches": light_wrapper == light_module,
		"rotdeg_matches": rotdeg_wrapper == rotdeg_module and bool(rotdeg_wrapper.get("matches", false)),
		"fog_radius_matches": fog_radius_wrapper == fog_radius_module and bool(fog_radius_wrapper.get("matches", false)),
		"generated_draw_status_bridge_matches": generated_draw_status_wrapper == generated_draw_status_module,
		"generated_drawrot_bridge_matches": generated_drawrot_wrapper == generated_drawrot_module and bool(generated_drawrot_wrapper.get("matches", false)),
		"generated_draw_configure_bridge_matches": generated_draw_configure_wrapper == generated_draw_configure_module,
		"module_matches": draw_wrapper == draw_module and cached_wrapper == cached_module and payload_wrapper == payload_module and light_wrapper == light_module and bool(rotdeg_wrapper.get("matches", false)) and bool(fog_radius_wrapper.get("matches", false)),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"override_callbacks_match": override_callbacks_match,
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = proof["module_matches"] and proof["generated_draw_status_bridge_matches"] and proof["generated_drawrot_bridge_matches"] and proof["generated_draw_configure_bridge_matches"] and proof["default_callbacks_match"] and proof["override_callbacks_match"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	print("BUILDING_DRAW_STATE_MODULE_PROOF " + JSON.stringify(proof))
	runtime_proof_state.write_proof("BuildingDrawStateModuleProof", proof)
	game.free()
	await get_tree().process_frame
	get_tree().quit(runtime_proof_state.exit_code(proof))

func proof_random_seed_int(source_seed: int, min_value: int, max_value: int) -> int:
	return int(clampi(source_seed, min_value, max_value))

func proof_lerp_delta(from_value: float, to_value: float, progress: float, source_delta: float) -> float:
	return lerpf(from_value, to_value, clampf(progress * source_delta, 0.0, 1.0))

func _building_draw_method_names() -> Dictionary:
	return {
		source_building_draw_state_script.SOURCE_BUILDING_DRAW_RANDOM_SEED_INT_KEY: "proof_random_seed_int",
		source_building_draw_state_script.SOURCE_BUILDING_DRAW_LERP_DELTA_KEY: "proof_lerp_delta",
	}
