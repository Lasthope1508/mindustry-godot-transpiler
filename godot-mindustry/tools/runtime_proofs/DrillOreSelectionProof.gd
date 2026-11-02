extends Node

const drill := preload("res://src/game/SourceDrillRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

func ore_item(id: int, hardness: int, low_priority: bool) -> Dictionary:
	return {"id": id, "hardness": hardness, "low_priority": low_priority}

func tile(item: Variant, is_static := false) -> Dictionary:
	return {"drop": item, "is_static": is_static}

func _ready() -> void:
	var low := ore_item(30, 0, true)
	var normal := ore_item(2, 1, false)
	var high_id := ore_item(10, 1, false)
	var hard := ore_item(50, 3, false)
	var proof: Dictionary = {}
	proof["null_tile"] = not drill.source_can_mine_state(null, 1, null)["can_mine"]
	proof["static_tile"] = not drill.source_can_mine_state(tile(normal, true), 1, null)["can_mine"]
	proof["no_drop"] = not drill.source_can_mine_state(tile(null), 1, null)["can_mine"]
	proof["hardness_boundary"] = drill.source_can_mine_state(tile(normal), 1, null)["can_mine"] and not drill.source_can_mine_state(tile(hard), 2, null)["can_mine"]
	proof["blocked_and_empty"] = not drill.source_can_mine_state(tile(normal), 1, [2])["can_mine"] and drill.source_can_mine_state(tile(normal), 1, [])["can_mine"]
	var linked: Array = [tile(low), tile(low), tile(low), tile(normal)]
	var before := linked.duplicate(true)
	var priority := drill.source_count_ore_state(linked, 1, null)
	proof["priority_before_amount"] = priority["returnItem"]["id"] == 2 and priority["returnCount"] == 1 and priority["oreCount"] == {30: 3, 2: 1}
	proof["ascending_source_order"] = priority["itemArray"] == [low, normal]
	var amounts := drill.source_count_ore_state([tile(normal), tile(normal), tile(high_id)], 1, null)
	proof["amount_before_id"] = amounts["returnItem"]["id"] == 2 and amounts["returnCount"] == 2
	var tie := drill.source_count_ore_state([tile(normal), tile(high_id)], 1, null)
	var reversed_tie := drill.source_count_ore_state([tile(high_id), tile(normal)], 1, null)
	proof["numeric_id_tie_and_permutation"] = tie["returnItem"]["id"] == 10 and reversed_tie["returnItem"]["id"] == 10
	var low_only := drill.source_count_ore_state([tile(low)], 0, null)
	proof["low_priority_still_mineable"] = low_only["returnItem"]["id"] == 30 and low_only["returnCount"] == 1
	var filtered := drill.source_count_ore_state([null, tile(null), tile(hard), tile(normal, true), tile(normal), tile(high_id)], 1, [10])
	proof["all_gates_composed"] = filtered["returnItem"]["id"] == 2 and filtered["returnCount"] == 1 and filtered["oreCount"] == {2: 1}
	var empty := drill.source_count_ore_state([], 1, null)
	var blocked := drill.source_count_ore_state([tile(normal)], 1, [2])
	proof["empty_and_reset"] = empty["returnItem"] == null and empty["returnCount"] == 0 and empty["oreCount"].is_empty() and empty["itemArray"].is_empty() and blocked["returnItem"] == null and blocked["returnCount"] == 0
	proof["identity_and_immutable_inputs"] = is_same(priority["returnItem"], normal) and is_same(priority["itemArray"][0], low) and linked == before and priority["oreCount"] == {30: 3, 2: 1} and not is_same(empty["oreCount"], blocked["oreCount"])
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("DrillOreSelectionProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
