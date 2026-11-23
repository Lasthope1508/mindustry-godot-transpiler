extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams_state := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- Teams BlockPlan.toString() + TeamData.toString() (N2412):
	# BlockPlan.toString() (Teams.java:507-513) and
	# TeamData.toString() (Teams.java:474-479). One merged
	# slice (main-thread decision 2026-11-22, batch 29
	# slot 2: two debug-only toString methods, 9 exprs,
	# the N1192 toString precedent). The proof calls the
	# pure functions with synthetic inputs (no live tick):
	# the happy paths build the exact Java strings, null
	# prints as "null", and each envelope has exactly one
	# key. Block/config/cores/team are not ported, so
	# they arrive as Variants and print via str().

	# The happy path builds the exact Java string.
	var done: Dictionary = teams_state.source_teams_block_plan_to_string_state(10, 20, 1, "conveyor", "cfg")
	proof["block_plan_to_string_builds_exact_string"] = done.get("to_string", "") == "BlockPlan{x=10, y=20, rotation=1, block=conveyor, config=cfg}"
	proof["block_plan_to_string_returns_only_one_key"] = done.size() == 1

	# Null block and null config print as "null".
	var nulled: Dictionary = teams_state.source_teams_block_plan_to_string_state(3, -4, 0, null, null)
	proof["block_plan_to_string_prints_null_as_null"] = nulled.get("to_string", "") == "BlockPlan{x=3, y=-4, rotation=0, block=null, config=null}"

	# The happy path builds the exact Java string.
	var team_done: Dictionary = teams_state.source_teams_team_data_to_string_state("2 cores", "sharded")
	proof["team_data_to_string_builds_exact_string"] = team_done.get("to_string", "") == "TeamData{cores=2 cores, team=sharded}"
	proof["team_data_to_string_returns_only_one_key"] = team_done.size() == 1

	# Null cores and null team print as "null".
	var team_nulled: Dictionary = teams_state.source_teams_team_data_to_string_state(null, null)
	proof["team_data_to_string_prints_null_as_null"] = team_nulled.get("to_string", "") == "TeamData{cores=null, team=null}"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamsToStringProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
