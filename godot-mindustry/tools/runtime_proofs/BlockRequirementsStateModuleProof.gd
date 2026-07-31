extends Node

const PortGameScript := preload("res://src/game/PortGame.gd")
const source_block_requirements_state := preload("res://src/game/SourceBlockRequirementsState.gd")
const source_ssot_catalog := preload("res://src/generated/SourceSsotCatalog.gd")

func _ready() -> void:
	var game := PortGameScript.new()
	game.load_content_registry()
	game.core_item_capacity = 100
	game.core_items = {"copper": 10}
	game.core_inventory = 10
	var callbacks := source_block_requirements_state.default_callbacks_state(game)
	var expected_callbacks := {
		"core_item_count": Callable(game, "core_item_count"),
	}
	var affordability := source_block_requirements_state.can_afford_state([{"item": "copper", "amount": 1}], 1.0, callbacks.get("core_item_count", Callable()))
	var spend_state := source_block_requirements_state.spend_requirements_state([{"item": "copper", "amount": 1}], 1.0, callbacks.get("core_item_count", Callable()))
	var proof_block := {
		"properties": {
			"requirements": [{"item": "copper", "amount": 2}],
		},
	}
	var game_can_afford_matches := source_block_requirements_state.game_can_afford(game, proof_block) == true
	source_block_requirements_state.game_spend_requirements(game, proof_block)
	var game_spend_matches := int(game.core_items.get("copper", 0)) == 8
	var registry_state := source_ssot_catalog.canonical_headquarter_registry_state()
	var stacks := [
		{"item": {"id": 2, "name": "copper"}, "amount": 2},
		{"item": {"id": 1, "name": "lead"}, "amount": 1},
	]
	var setup_simple_bridge := game.generated_block_setup_requirements_simple_bridge_state("production", stacks)
	var setup_visible_bridge := game.generated_block_setup_requirements_visible_bridge_state("production", "BuildVisibility.shown", stacks)
	var requirements_unlocked_bridge := game.generated_block_requirements_unlocked_bridge_state("production", stacks, true)
	var requirements_simple_bridge := game.generated_block_requirements_simple_bridge_state("production", stacks)
	var requirements_visible_bridge := game.generated_block_requirements_visible_bridge_state("production", "BuildVisibility.shown", stacks)
	var generated_bridge_matches: bool = (
		bool(setup_simple_bridge.get("matches", false))
		and bool(setup_visible_bridge.get("matches", false))
		and bool(requirements_unlocked_bridge.get("matches", false))
		and bool(requirements_simple_bridge.get("matches", false))
		and bool(requirements_visible_bridge.get("matches", false))
	)
	var proof := {
		"module": "BLOCK_REQUIREMENTS_STATE_MODULE_PROOF",
		"default_callbacks_match": callbacks.get("core_item_count", Callable()) == expected_callbacks.get("core_item_count", Callable()),
		"affordability": affordability,
		"spend_state": spend_state,
		"game_can_afford_matches": game_can_afford_matches,
		"game_spend_matches": game_spend_matches,
		"setup_simple_bridge_matches": bool(setup_simple_bridge.get("matches", false)),
		"setup_visible_bridge_matches": bool(setup_visible_bridge.get("matches", false)),
		"requirements_unlocked_bridge_matches": bool(requirements_unlocked_bridge.get("matches", false)),
		"requirements_simple_bridge_matches": bool(requirements_simple_bridge.get("matches", false)),
		"requirements_visible_bridge_matches": bool(requirements_visible_bridge.get("matches", false)),
		"generated_bridge_matches": generated_bridge_matches,
		"one_headquarter_per_ssot": bool(registry_state.get("one_headquarter_per_ssot", false)),
		"registry_valid": bool(registry_state.get("errors", []).is_empty()),
		"registry_headquarter_count": int(registry_state.get("headquarter_count", 0)),
	}
	proof["matches"] = bool(proof.get("default_callbacks_match", false)) and game_can_afford_matches and game_spend_matches and generated_bridge_matches and proof["one_headquarter_per_ssot"] and proof["registry_valid"]
	var proof_json := JSON.stringify(proof)
	print("BLOCK_REQUIREMENTS_STATE_MODULE_PROOF " + proof_json)
	var proof_path := ProjectSettings.globalize_path("res://tools/runtime_proofs/BlockRequirementsStateModuleProof.json")
	var proof_file := FileAccess.open(proof_path, FileAccess.WRITE)
	if proof_file != null:
		proof_file.store_string(proof_json)
	game.free()
	await get_tree().create_timer(60.0).timeout
	get_tree().quit(0)
