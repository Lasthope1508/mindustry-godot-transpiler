extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_plan_state := preload("res://src/game/SourceBlockPlanState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	var callbacks := source_block_plan_state.default_callbacks_state(game)
	var expected_callbacks := {
		source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY: Callable(game, source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_FALLBACK),
		source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY: Callable(game, source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_FALLBACK),
	}
	var override_callbacks := source_block_plan_state.default_callbacks_state(self)
	var override_callbacks_match: bool = override_callbacks.get(source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY, Callable()) == Callable(self, "proof_mod_float") \
		and override_callbacks.get(source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY, Callable()) == Callable(self, "proof_plan_rotation_state")
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var is_hidden_bridge := game.generated_block_is_hidden_bridge_state(false, false)
	var plan_rotation_bridge := game.generated_block_plan_rotation_bridge_state(true, false, 3)
	var flip_rotation_bridge := game.generated_block_flip_rotation_bridge_state(1, true, false, true, false)
	var game_flip_rotation := game.source_block_flip_rotation_state(1, true, false, true, false)
	var module_flip_rotation := source_block_plan_state.game_flip_rotation_state(game, 1, true, false, true, false)
	var override_flip_rotation := source_block_plan_state.game_flip_rotation_state(self, 1, true, false, true, false)
	var primitive_override_flip_rotation := source_block_plan_state.flip_rotation_state(1, true, false, true, false, Callable(self, "proof_mod_float"), Callable(self, "proof_plan_rotation_state"))
	var options_before := [{"id": "config-a"}]
	var content_items := [{"id": "copper"}]
	var content_liquids := [{"id": "water"}]
	var plan_configs_bridge := game.generated_block_get_plan_configs_bridge_state(options_before, true, true, content_items, content_liquids)
	var proof := {
		"module": "BLOCK_PLAN_MODULE_PROOF",
		"default_callbacks_match": callbacks == expected_callbacks,
		"override_callbacks_match": override_callbacks_match,
		"is_hidden_bridge": is_hidden_bridge,
		"plan_rotation_bridge": plan_rotation_bridge,
		"flip_rotation_bridge": flip_rotation_bridge,
		"plan_configs_bridge": plan_configs_bridge,
		"is_hidden_bridge_matches": is_hidden_bridge == source_block_plan_state.generated_block_is_hidden_bridge_state(false, false),
		"plan_rotation_bridge_matches": plan_rotation_bridge == source_block_plan_state.generated_block_plan_rotation_bridge_state(true, false, 3),
		"flip_rotation_bridge_matches": flip_rotation_bridge == source_block_plan_state.generated_block_flip_rotation_bridge_state(1, true, false, true, false),
		"game_flip_rotation_matches": game_flip_rotation == module_flip_rotation,
		"override_flip_rotation_matches": override_flip_rotation == primitive_override_flip_rotation,
		"plan_configs_bridge_matches": plan_configs_bridge == source_block_plan_state.generated_block_get_plan_configs_bridge_state(options_before, true, true, content_items, content_liquids),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
	}
	proof["matches"] = proof["default_callbacks_match"] and proof["override_callbacks_match"] and bool(is_hidden_bridge.get("matches", false)) and bool(plan_rotation_bridge.get("matches", false)) and bool(flip_rotation_bridge.get("matches", false)) and bool(plan_configs_bridge.get("matches", false)) and proof["is_hidden_bridge_matches"] and proof["plan_rotation_bridge_matches"] and proof["flip_rotation_bridge_matches"] and proof["game_flip_rotation_matches"] and proof["override_flip_rotation_matches"] and proof["plan_configs_bridge_matches"] and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_PLAN_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockPlanModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)

func proof_mod_float(value: float, divisor: float) -> float:
	return fmod(fmod(value, divisor) + divisor, divisor)

func proof_plan_rotation_state(rotate_value: bool, lock_rotation: bool, rot: int) -> Dictionary:
	return source_block_plan_state.plan_rotation_state(rotate_value, lock_rotation, rot)

func _block_plan_method_names() -> Dictionary:
	return {
		source_block_plan_state.SOURCE_BLOCK_PLAN_MOD_FLOAT_KEY: "proof_mod_float",
		source_block_plan_state.SOURCE_BLOCK_PLAN_ROTATION_KEY: "proof_plan_rotation_state",
	}
