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
	var proof: Dictionary = {}

	# --- Drill.countOre() sort opener (N2433):
	# `itemArray.sort((item1, item2) -> {` (Drill.java:215)
	# is the call that orders itemArray by the 3-tier
	# comparator (lowPriority -> oreCount -> numeric id,
	# ascending; peek selects the last). The comparator
	# body is already owned at N2010 + N2302; only the
	# opener line is registered here. The GD function
	# already exists (N2010) as
	# `item_array.sort_custom(...)`. Each key drives the
	# sort call itself: the input order differs from the
	# output order on exactly one tier.
	var priority := drill.source_count_ore_state([tile(normal), tile(low)], 1, null)
	proof["sort_orders_by_priority"] = priority["itemArray"] == [low, normal] and priority["returnItem"]["id"] == 2 and priority["returnCount"] == 1
	var amounts := drill.source_count_ore_state([tile(high_id), tile(normal), tile(normal)], 1, null)
	proof["sort_orders_by_amount"] = amounts["itemArray"] == [high_id, normal] and amounts["returnItem"]["id"] == 2 and amounts["returnCount"] == 2
	var tie := drill.source_count_ore_state([tile(high_id), tile(normal)], 1, null)
	proof["sort_orders_by_id_tie"] = tie["itemArray"] == [normal, high_id] and tie["returnItem"]["id"] == 10 and tie["returnCount"] == 1
	var single := drill.source_count_ore_state([tile(normal)], 1, null)
	proof["sort_single_item_unchanged"] = single["itemArray"] == [normal] and single["returnItem"]["id"] == 2 and single["returnCount"] == 1
	var empty := drill.source_count_ore_state([], 1, null)
	proof["sort_empty_stays_empty"] = empty["itemArray"].is_empty() and empty["returnItem"] == null and empty["returnCount"] == 0 and empty["oreCount"].is_empty()
	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillCountOreSortOpenerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
