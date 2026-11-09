extends Node

const main_scene := preload("res://scenes/Main.tscn")
const rules_state := preload("res://src/game/SourceRulesRuntimeState.gd")
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

	# --- defaults: empty rules state is 1.0 x 1.0. ---
	var defaults: Dictionary = rules_state.source_unit_cost_state({}, 1)
	proof["rules_unit_cost_defaults"] = is_equal_approx(float(defaults.get("unit_cost", -1.0)), 1.0)

	# --- global multiplier alone scales the cost. ---
	var global_only: Dictionary = rules_state.source_unit_cost_state({"unitCostMultiplier": 2.0}, 1)
	proof["rules_unit_cost_global"] = is_equal_approx(float(global_only.get("unit_cost", -1.0)), 2.0)

	# --- per-team multiplier compounds with the global one. ---
	var teamed: Dictionary = rules_state.source_unit_cost_state({"unitCostMultiplier": 2.0, "teams": {1: {"unitCostMultiplier": 0.5}}}, 1)
	proof["rules_unit_cost_team"] = is_equal_approx(float(teamed.get("unit_cost", -1.0)), 1.0)

	# --- a different team reads its own multiplier. ---
	var other_team: Dictionary = rules_state.source_unit_cost_state({"unitCostMultiplier": 1.0, "teams": {2: {"unitCostMultiplier": 3.0}}}, 2)
	proof["rules_unit_cost_other_team"] = is_equal_approx(float(other_team.get("unit_cost", -1.0)), 3.0)

	# --- a team with no entry falls back to the global multiplier. ---
	var missing_team: Dictionary = rules_state.source_unit_cost_state({"unitCostMultiplier": 2.0, "teams": {2: {"unitCostMultiplier": 3.0}}}, 5)
	proof["rules_unit_cost_missing_team"] = is_equal_approx(float(missing_team.get("unit_cost", -1.0)), 2.0)

	# --- string team keys (from JSON) resolve the same as int keys. ---
	var string_key: Dictionary = rules_state.source_unit_cost_state({"unitCostMultiplier": 2.0, "teams": {"1": {"unitCostMultiplier": 0.5}}}, 1)
	proof["rules_unit_cost_string_key"] = is_equal_approx(float(string_key.get("unit_cost", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("RulesUnitCostProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
