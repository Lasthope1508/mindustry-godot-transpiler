extends Node

const main_scene := preload("res://scenes/Main.tscn")
const teams := preload("res://src/game/SourceTeamsRuntimeState.gd")
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

	# --- sharded (1) has a core and is active; crux (2) has nothing. ---
	var teams_state := {
		"teams": {
			1: {"cores": ["core-a"], "buildings": [], "units": [], "core_enemies": []},
			2: {"cores": [], "buildings": [], "units": [], "core_enemies": []},
		},
		"active": [1],
		"rules": {"wave_team": 2, "waves": false},
	}

	# --- registering a core activates its team and recomputes enemies. ---
	var register: Dictionary = teams.source_teams_register_core_state(teams_state, 2, "core-b")
	proof["teams_register_core"] = register.get("registered") == true and register.get("active_changed") == true and register.get("active") == [1, 2] and register.get("enemies_by_team") == {1: [2], 2: [1]} and teams_state["teams"][2]["cores"] == ["core-b"] and teams_state["teams"][1]["core_enemies"] == [2] and teams_state["teams"][2]["core_enemies"] == [1]

	# --- registering the same core again is a no-op. ---
	var register_dup: Dictionary = teams.source_teams_register_core_state(teams_state, 2, "core-b")
	proof["teams_register_core_duplicate"] = register_dup.get("registered") == false and register_dup.get("active_changed") == false and register_dup.get("active") == [1, 2] and teams_state["teams"][2]["cores"] == ["core-b"]

	# --- unregistering the last core deactivates the team. ---
	var unregister: Dictionary = teams.source_teams_unregister_core_state(teams_state, 2, "core-b")
	proof["teams_unregister_core"] = unregister.get("unregistered") == true and unregister.get("active_changed") == true and unregister.get("active") == [1] and unregister.get("enemies_by_team") == {1: []} and teams_state["teams"][2]["cores"] == [] and teams_state["teams"][1]["core_enemies"] == []

	# --- unregistering a missing core is a no-op. ---
	var unregister_missing: Dictionary = teams.source_teams_unregister_core_state(teams_state, 2, "core-b")
	proof["teams_unregister_core_missing"] = unregister_missing.get("unregistered") == false and unregister_missing.get("active_changed") == false and unregister_missing.get("active") == [1]

	# --- the wave team stays active even with no cores, via updateEnemies. ---
	teams_state["rules"]["waves"] = true
	var unregister_last: Dictionary = teams.source_teams_unregister_core_state(teams_state, 1, "core-a")
	proof["teams_unregister_wave_team"] = unregister_last.get("unregistered") == true and unregister_last.get("active_changed") == true and unregister_last.get("active") == [2] and unregister_last.get("enemies_by_team") == {2: []}

	# --- neoplastic is active through its units alone. ---
	teams_state["teams"][6] = {"cores": [], "buildings": [], "units": ["unit-a"], "core_enemies": []}
	var register_neo: Dictionary = teams.source_teams_register_core_state(teams_state, 6, "core-c")
	proof["teams_register_neoplastic"] = register_neo.get("registered") == true and register_neo.get("active_changed") == true and register_neo.get("active") == [2, 6] and register_neo.get("enemies_by_team") == {2: [6], 6: [2]}

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("TeamsCoreRegistrationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
