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

	# --- TeamData liveness (N2374):
	# TeamData.hasCore()+isAlive()+noCores()+core()+hasAI()
	# (Teams.java:450-472,
	# `public boolean hasCore(){` /
	# `return cores.size > 0;` /
	# `public boolean isAlive(){` /
	# `return hasCore();` /
	# `public boolean noCores(){` /
	# `return cores.isEmpty();` /
	# `@Nullable` /
	# `public CoreBuild core(){` /
	# `return cores.isEmpty() ? null : cores.first();` /
	# `public boolean hasAI(){` /
	# `return team.rules().rtsAi || team.rules().buildAi;`).
	# One grouped slice (main-thread decision 2026-11-21, the
	# N2326/N2297 group precedent): isAlive() delegates to
	# hasCore() inside this same group, not an outside dedup.
	# active() (Teams.java:446-448) is NOT ported here: its
	# only line is already the exact_expr of N2074+N2075.
	# The cores arrive as an explicit Array of opaque core
	# refs (the N2330 param precedent); team.rules() arrives
	# as the explicit team_rules dict {rts_ai, build_ai}
	# because Rules is not ported. The proof calls the pure
	# function with synthetic cores Arrays and team_rules
	# dicts (no live tick).

	# Two cores: hasCore true, isAlive true (the delegate),
	# noCores false, core is the FIRST core, hasAI false
	# when neither rule flag is set.
	var with_cores: Dictionary = teams_state.source_team_data_liveness_state(["c1", "c2"], {"rts_ai": false, "build_ai": false})
	proof["has_core_true_with_cores"] = bool(with_cores.get("has_core", false))
	proof["core_first_when_present"] = str(with_cores.get("core", "")) == "c1"
	proof["has_ai_false_when_neither"] = not bool(with_cores.get("has_ai", true))

	# No cores: hasCore false, isAlive false (the delegate),
	# noCores true, core null.
	var empty: Dictionary = teams_state.source_team_data_liveness_state([], {"rts_ai": false, "build_ai": false})
	proof["has_core_false_when_empty"] = not bool(empty.get("has_core", true))
	proof["core_null_when_empty"] = empty.get("core", "not-null") == null
	proof["is_alive_delegates_has_core"] = bool(with_cores.get("is_alive", false)) == bool(with_cores.get("has_core", false)) and bool(empty.get("is_alive", true)) == bool(empty.get("has_core", true))
	proof["no_cores_inverse_of_has_core"] = bool(with_cores.get("no_cores", true)) == (not bool(with_cores.get("has_core", false))) and bool(empty.get("no_cores", false)) == (not bool(empty.get("has_core", true)))

	# hasAI is `team.rules().rtsAi || team.rules().buildAi`:
	# true on rtsAi alone, true on buildAi alone, false on
	# neither (checked above).
	var rts_ai: Dictionary = teams_state.source_team_data_liveness_state([], {"rts_ai": true, "build_ai": false})
	proof["has_ai_rts_ai"] = bool(rts_ai.get("has_ai", false))
	var build_ai: Dictionary = teams_state.source_team_data_liveness_state([], {"rts_ai": false, "build_ai": true})
	proof["has_ai_build_ai"] = bool(build_ai.get("has_ai", false))

	# The result carries only its five keys, in the pinned
	# order has_core, is_alive, no_cores, core, has_ai.
	proof["returns_only_five_keys"] = with_cores.keys().size() == 5 and with_cores.keys()[0] == "has_core" and with_cores.keys()[1] == "is_alive" and with_cores.keys()[2] == "no_cores" and with_cores.keys()[3] == "core" and with_cores.keys()[4] == "has_ai"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TeamDataLivenessProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
