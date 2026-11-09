extends Node

const main_scene := preload("res://scenes/Main.tscn")
const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
const drill_consumption_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}
	var game := main_scene.instantiate()
	add_child(game)
	for iteration in range(4):
		await get_tree().process_frame
	game.call("enter_campaign_playable_slice")
	for iteration in range(4):
		await get_tree().process_frame
	game.set_process(false)
	game.set_physics_process(false)

	# --- no rules yet means the Java `new Rules()` defaults. ---
	var empty_rules: Dictionary = rules_state.source_game_rules_state({})["rules"]
	proof["game_rules_empty_default"] = empty_rules == {"unitCostMultiplier": 1.0, "teams": {}}
	var null_rules: Dictionary = rules_state.source_game_rules_state(null)["rules"]
	proof["game_rules_null_default"] = null_rules == {"unitCostMultiplier": 1.0, "teams": {}}

	# --- an existing rules state is returned as-is: the same object,
	# so a mutation through the result is live on the input. ---
	var live_in: Dictionary = {"unitCostMultiplier": 3.0, "teams": {}}
	var live_out: Dictionary = rules_state.source_game_rules_state(live_in)["rules"]
	live_out["unitCostMultiplier"] = 4.0
	proof["game_rules_live_same_object"] = is_equal_approx(float(live_in.get("unitCostMultiplier", -1.0)), 4.0)

	# --- the game itself holds the live rules (Java: Vars.state.rules). ---
	var game_rules: Dictionary = game.get("rules_state")
	proof["game_rules_game_default"] = game_rules == {"unitCostMultiplier": 1.0, "teams": {}}

	# --- mutating the game's rules changes what unitCost reads. ---
	game_rules["unitCostMultiplier"] = 2.0
	var mutated_cost: Dictionary = rules_state.source_unit_cost_state(game.get("rules_state"), 1)
	proof["game_rules_mutation_live"] = is_equal_approx(float(mutated_cost.get("unit_cost", -1.0)), 2.0)

	# --- the drill tick reads the same live rules object. ---
	for iteration in range(4):
		game.call("simulate_factory", 1.0 / 60.0)
	var drill_sprite: Variant = game.call("block_sprite_at_cell", Vector2i(7, 8))
	var frame: Dictionary = drill_sprite.get_meta(drill_consumption_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["game_rules_drill_frame_sees_mutation"] = is_equal_approx(float(frame.get("rules_state", {}).get("unitCostMultiplier", -1.0)), 2.0)
	game_rules["unitCostMultiplier"] = 5.0
	proof["game_rules_drill_frame_live_object"] = is_equal_approx(float(frame.get("rules_state", {}).get("unitCostMultiplier", -1.0)), 5.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("GameRulesStateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
