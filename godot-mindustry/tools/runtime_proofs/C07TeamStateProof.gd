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

	# --- Team forwards (N2450):
	# Team.items()+data()+core()+active()+isAlive()+isOnlyAI()
	# +needsFlowField()+cores() (Team.java:83-133,
	# `public ItemModule items(){` /
	# `return core() == null ? ItemModule.empty : core().items;` /
	# `public TeamData data(){` /
	# `return state.teams.get(this);` /
	# `@Nullable` /
	# `public CoreBuild core(){` /
	# `return data().core();` /
	# `public boolean active(){` /
	# `return state.teams.isActive(this);` /
	# `public boolean isAlive(){` /
	# `return data().isAlive();` /
	# `public boolean isOnlyAI(){` /
	# `return isAI() && data().players.size == 0;` /
	# `public boolean needsFlowField(){` /
	# `return isAI() && !rules().rtsAi;` /
	# `public Seq<CoreBuild> cores(){` /
	# `return state.teams.cores(this);`). One grouped slice
	# (main-thread decision 2026-11-23, the N2390/N2395 group
	# precedent). The proof calls the pure function with
	# synthetic teams_state dicts (no live tick): two cores
	# with items dicts and no players (AI, no rtsAi) / no
	# cores with one player (AI, rtsAi) / no cores and no
	# players (not AI, no rtsAi).

	# Two cores, no players, AI without rtsAi: items is the
	# FIRST core's items, data is the TeamData dict, core is
	# the first core, active + isAlive true, isOnlyAI true,
	# needsFlowField true, cores is the cores Array.
	var full_state: Dictionary = {"teams": {1: {"cores": [{"items": {"copper": 5}}, {"items": {"lead": 3}}], "players": [], "buildings": []}}, "rules": {"waves": false, "wave_team": -1}, "active": []}
	var full: Dictionary = teams_state.source_team_state(full_state, 1, true, false)
	proof["items_from_first_core"] = (full.get("items", {}) as Dictionary).get("copper", -1) == 5 and not (full.get("items", {}) as Dictionary).has("lead")
	proof["data_returns_team_data"] = (full.get("data", {}) as Dictionary).get("cores", []).size() == 2 and (full.get("data", {}) as Dictionary).get("players", ["x"]).is_empty()
	proof["core_first_when_present"] = (full.get("core", {}) as Dictionary).get("items", {}) == {"copper": 5}
	proof["active_true_with_cores"] = bool(full.get("active", false))
	proof["is_only_ai_true_ai_no_players"] = bool(full.get("is_only_ai", false))
	proof["needs_flow_field_true_ai_no_rts"] = bool(full.get("needs_flow_field", false))
	proof["cores_returns_cores"] = (full.get("cores", []) as Array).size() == 2

	# No cores, one player, AI with rtsAi: items is empty
	# (ItemModule.empty), core null, active + isAlive false,
	# isOnlyAI false (players present), needsFlowField false
	# (rtsAi set).
	var empty_state: Dictionary = {"teams": {2: {"cores": [], "players": [{"ref": "p1"}], "buildings": []}}, "rules": {"waves": false, "wave_team": -1}, "active": []}
	var empty: Dictionary = teams_state.source_team_state(empty_state, 2, true, true)
	proof["items_empty_when_no_core"] = (empty.get("items", {"x": 1}) as Dictionary).is_empty()
	proof["core_null_when_empty"] = empty.get("core", "not-null") == null
	proof["active_false_when_empty"] = not bool(empty.get("active", true))
	proof["is_only_ai_false_with_players"] = not bool(empty.get("is_only_ai", true))
	proof["needs_flow_field_false_when_rts_ai"] = not bool(empty.get("needs_flow_field", true))

	# isAlive delegates to hasCore (cores.size > 0): true
	# with cores, false without.
	proof["is_alive_delegates_has_core"] = bool(full.get("is_alive", false)) == bool(full.get("active", false)) and not bool(empty.get("is_alive", true))

	# Not AI: isOnlyAI + needsFlowField are both false even
	# with no players and no rtsAi.
	var not_ai_state: Dictionary = {"teams": {1: {"cores": [], "players": [], "buildings": []}}, "rules": {"waves": false, "wave_team": -1}, "active": []}
	var not_ai: Dictionary = teams_state.source_team_state(not_ai_state, 1, false, false)
	proof["is_only_ai_false_when_not_ai"] = not bool(not_ai.get("is_only_ai", true))
	proof["needs_flow_field_false_when_not_ai"] = not bool(not_ai.get("needs_flow_field", true))

	# The result carries only its nine keys, in the pinned
	# order items, data, core, active, is_alive, is_only_ai,
	# needs_flow_field, cores, teams_state.
	proof["returns_only_expected_keys"] = full.keys().size() == 9 and full.keys()[0] == "items" and full.keys()[1] == "data" and full.keys()[2] == "core" and full.keys()[3] == "active" and full.keys()[4] == "is_alive" and full.keys()[5] == "is_only_ai" and full.keys()[6] == "needs_flow_field" and full.keys()[7] == "cores" and full.keys()[8] == "teams_state"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamStateProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
