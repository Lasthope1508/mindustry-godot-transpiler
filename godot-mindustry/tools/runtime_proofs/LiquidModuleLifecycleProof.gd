extends Node

const generated_storage := preload("res://src/generated/classes/mindustry/world/modules/LiquidModule.gd")
const storage_proof := preload("res://tools/runtime_proofs/LiquidModuleStorageProof.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func _ready() -> void:
	var module = generated_storage.new()
	var checks: Array = []
	# Golden expectations are independent values from LiquidModule field/method semantics.
	for entry in [[[0], [0.0]], [[0, 1, 2], [0.0, 0.0, 0.0]]]:
		var result = module.java_initialize_state([entry[0]])
		checks.append({"kind": "initial", "input": entry[0], "actual": result.duplicate(true), "matches": result == {"liquids": entry[1], "current": 0, "flow": null}})
	var ids: Array = [0, 1]
	var first = module.java_initialize_state([ids])
	var second = generated_storage.new().java_initialize_state([ids])
	first["liquids"][0] = 4.0
	checks.append({"kind": "independent_instances", "matches": second["liquids"] == [0.0, 0.0] and ids == [0, 1]})
	for entry in [[[2.0, 3.0], 1, 3.0], [[2.0, 3.0], 0, 2.0], [[0.0, 0.0], 1, 0.0]]:
		var state := {"liquids": entry[0].duplicate(), "current": entry[1], "flow": null}
		var before := state.duplicate(true)
		var current = module.java_method_current_4([state])
		var amount = module.java_method_currentAmount_7([state])
		checks.append({"kind": "current_read", "actual": [current, amount], "matches": current["current"] == entry[1] and amount["amount"] == entry[2] and state == before})
	# method, before amounts, before current, liquid ID, amount, after amounts, after current
	var cases := [
		["reset", [2.0, 3.0], 1, 0, 0.5, [0.5, 0.0], 0],
		["reset", [2.0, 3.0], 0, 1, -0.25, [0.0, -0.25], 1],
		["reset", [2.0, 3.0], 1, 0, 0.0, [0.0, 0.0], 0],
		["clear", [2.0, 3.0], 1, 0, 0.0, [0.0, 0.0], 1],
		["clear", [0.0, 0.0], 1, 0, 0.0, [0.0, 0.0], 1],
		["set", [2.0, 3.0], 1, 0, 1.0, [1.0, 3.0], 1],
		["set", [2.0, 3.0], 1, 0, 3.0, [3.0, 3.0], 0],
		["set", [2.0, 3.0], 1, 0, 4.0, [4.0, 3.0], 0],
		["set", [2.0, 3.0], 1, 1, 0.5, [2.0, 0.5], 1],
		["set", [0.0, 0.0], 1, 0, 0.0, [0.0, 0.0], 0],
		["set", [-2.0, -1.0], 1, 0, -1.0, [-1.0, -1.0], 0],
		["set", [-2.0, -1.0], 1, 0, -3.0, [-3.0, -1.0], 1],
		["set", [2.0, 3.0], 0, 1, 2.0, [2.0, 2.0], 1],
	]
	for entry in cases:
		var flow: Array = [17.0]
		var state := {"liquids": entry[1].duplicate(), "current": entry[2], "flow": flow}
		var amounts: Array = state["liquids"]
		var result: Dictionary
		if entry[0] == "reset":
			result = module.java_method_reset_5([state, entry[3], entry[4]])
		elif entry[0] == "set":
			result = module.java_method_set_6([state, entry[3], entry[4]])
		else:
			result = module.java_method_clear_9([state])
		checks.append({"kind": entry[0], "input": entry.slice(1, 5), "actual": result.duplicate(true), "matches": state["liquids"] == entry[5] and state["current"] == entry[6] and is_same(amounts, state["liquids"]) and is_same(flow, state["flow"]) and flow == [17.0] and is_same(result, state)})
	# Reuse the prior proof's consumer fixture, with initialization/reset now from production code.
	var harness := storage_proof.new()
	var actor := storage_proof.StorageConsumer.new()
	actor.storage = module.java_initialize_state([[0, 1]])
	actor.cache_sums = []
	module.java_method_reset_5([actor.storage, 1, 1.25])
	harness.tick(actor)
	var after1: Array = actor.storage["liquids"].duplicate()
	harness.tick(actor)
	var after2: Array = actor.storage["liquids"].duplicate()
	harness.tick(actor)
	var composition: bool = after1 == [0.0, 0.25] and after2 == [0.0, 0.0] and actor.requests == [1.0, 0.25]
	module.java_method_set_6([actor.storage, 1, 0.5])
	harness.tick(actor)
	composition = composition and actor.storage["liquids"] == [0.0, 0.0] and actor.requests == [1.0, 0.25, 0.5]
	module.java_method_clear_9([actor.storage])
	composition = composition and module.java_method_current_4([actor.storage])["current"] == 1 and module.java_method_currentAmount_7([actor.storage])["amount"] == 0.0
	harness.free()
	var registry_state := registry.canonical_headquarter_registry_state()
	var matches: bool = composition and registry_state.get("errors", []).is_empty() and registry_state.get("one_headquarter_per_ssot", false)
	for check in checks:
		matches = matches and check["matches"]
	var proof := {"matches": matches, "case_count": checks.size(), "checks": checks, "initialized_consumption_matches": composition, "registry_valid": registry_state.get("errors", []).is_empty(), "one_headquarter_per_ssot": registry_state.get("one_headquarter_per_ssot", false)}
	proof_state.write_proof("LiquidModuleLifecycleProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
