extends Node

const main_scene := preload("res://scenes/Main.tscn")
const dump_state := preload("res://src/game/SourceBuildingItemDumpState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")

var accept_map: Dictionary = {}
var received: Dictionary = {}


func _accept_item(receiver: Variant, item_id: String) -> bool:
	var accepted: Array = accept_map.get(receiver["id"], [])
	return accepted.has("all") or accepted.has(item_id)


func _handle_item(receiver: Variant, item_id: String) -> void:
	var got: Array = received.get(receiver["id"], [])
	got.append(item_id)
	received[receiver["id"]] = got


func _can_dump_reject_r0(receiver: Variant, item_id: String) -> bool:
	return receiver["id"] != "r0"


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

	var accept_hook := Callable(self, "_accept_item")
	var handle_hook := Callable(self, "_handle_item")
	var no_can_dump := Callable()
	var r0 := {"id": "r0"}
	var r1 := {"id": "r1"}

	# --- dump a specific item: first accepting neighbor in cdump order. ---
	accept_map = {"r0": ["copper"], "r1": ["copper"]}
	received = {}
	var specific_first: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3, "lead": 2}, [r0, r1], "copper", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_first_accepting"] = specific_first.get("dumped") == true and specific_first.get("item_id") == "copper" and specific_first.get("receiver_index") == 0 and specific_first.get("cdump_before") == 0 and specific_first.get("cdump_after") == 1 and specific_first.get("items_after", {}).get("copper") == 2 and specific_first.get("removed") == 1 and specific_first.get("reason") == "dumped" and received.get("r0", []) == ["copper"]
	accept_map = {"r0": ["lead"], "r1": ["copper"]}
	received = {}
	var specific_skip: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "copper", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_skips_rejecting"] = specific_skip.get("dumped") == true and specific_skip.get("receiver_index") == 1 and specific_skip.get("cdump_after") == 0 and specific_skip.get("items_after", {}).get("copper") == 2 and received.get("r1", []) == ["copper"]
	accept_map = {"r0": ["lead"], "r1": ["lead"]}
	received = {}
	var specific_none: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "copper", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_no_receiver"] = specific_none.get("dumped") == false and specific_none.get("reason") == "no_receiver" and specific_none.get("cdump_after") == 0 and specific_none.get("items_after", {}).get("copper") == 3 and received.is_empty()
	var specific_not_held: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "lead", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_item_not_held"] = specific_not_held.get("dumped") == false and specific_not_held.get("reason") == "item_not_held" and specific_not_held.get("cdump_after") == 0 and specific_not_held.get("items_after", {}).get("copper") == 3
	var specific_no_block: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "copper", 0, false, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_no_items_block"] = specific_no_block.get("dumped") == false and specific_no_block.get("reason") == "no_items_block" and specific_no_block.get("cdump_after") == 0
	var specific_empty: Dictionary = dump_state.source_building_dump_specific_state({}, [r0, r1], "copper", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_empty_items"] = specific_empty.get("dumped") == false and specific_empty.get("reason") == "empty_items" and specific_empty.get("cdump_after") == 0
	var specific_no_prox: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [], "copper", 0, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_no_proximity"] = specific_no_prox.get("dumped") == false and specific_no_prox.get("reason") == "no_proximity" and specific_no_prox.get("cdump_after") == 0

	# --- dump(null): any item, in content order, per neighbor. ---
	accept_map = {"r0": ["all"], "r1": ["all"]}
	received = {}
	var any_content_order: Dictionary = dump_state.source_building_dump_any_state({"copper": 2, "lead": 1}, [r0, r1], 0, true, ["lead", "copper"], accept_hook, handle_hook, no_can_dump)
	proof["dump_any_content_order_first"] = any_content_order.get("dumped") == true and any_content_order.get("item_id") == "lead" and any_content_order.get("receiver_index") == 0 and any_content_order.get("cdump_after") == 1 and any_content_order.get("items_after", {}).get("lead") == 0 and any_content_order.get("items_after", {}).get("copper") == 2 and received.get("r0", []) == ["lead"]
	var any_skip_unheld: Dictionary = dump_state.source_building_dump_any_state({"copper": 2}, [r0, r1], 0, true, ["silicon", "copper"], accept_hook, handle_hook, no_can_dump)
	proof["dump_any_skips_unheld_item"] = any_skip_unheld.get("dumped") == true and any_skip_unheld.get("item_id") == "copper" and any_skip_unheld.get("items_after", {}).get("copper") == 1
	accept_map = {"r0": ["lead"], "r1": ["copper"]}
	received = {}
	var any_per_item: Dictionary = dump_state.source_building_dump_any_state({"copper": 2, "lead": 1}, [r0, r1], 0, true, ["copper", "lead"], accept_hook, handle_hook, no_can_dump)
	proof["dump_any_per_item_accept"] = any_per_item.get("dumped") == true and any_per_item.get("item_id") == "lead" and any_per_item.get("receiver_index") == 0 and any_per_item.get("cdump_after") == 1 and any_per_item.get("items_after", {}).get("lead") == 0 and any_per_item.get("items_after", {}).get("copper") == 2 and received.get("r0", []) == ["lead"]
	accept_map = {"r0": ["silicon"], "r1": ["silicon"]}
	received = {}
	var any_none: Dictionary = dump_state.source_building_dump_any_state({"copper": 2}, [r0, r1], 0, true, ["copper"], accept_hook, handle_hook, no_can_dump)
	proof["dump_any_no_receiver"] = any_none.get("dumped") == false and any_none.get("reason") == "no_receiver" and any_none.get("cdump_after") == 0 and any_none.get("items_after", {}).get("copper") == 2

	# --- cdump wraps around the proximity array; canDump hook is honored. ---
	accept_map = {"r0": ["copper"], "r1": ["lead"]}
	received = {}
	var wrap: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "copper", 1, true, accept_hook, handle_hook, no_can_dump)
	proof["dump_specific_cdump_wraps"] = wrap.get("dumped") == true and wrap.get("receiver_index") == 0 and wrap.get("cdump_before") == 1 and wrap.get("cdump_after") == 1 and wrap.get("items_after", {}).get("copper") == 2
	accept_map = {"r0": ["copper"], "r1": ["copper"]}
	received = {}
	var can_dump_hook := Callable(self, "_can_dump_reject_r0")
	var can_dump: Dictionary = dump_state.source_building_dump_specific_state({"copper": 3}, [r0, r1], "copper", 0, true, accept_hook, handle_hook, can_dump_hook)
	proof["dump_specific_can_dump_hook"] = can_dump.get("dumped") == true and can_dump.get("receiver_index") == 1 and can_dump.get("cdump_after") == 0 and received.get("r1", []) == ["copper"]

	# --- the dump() entry dispatches on todump null-ness. ---
	accept_map = {"r0": ["all"], "r1": ["all"]}
	received = {}
	var entry_any: Dictionary = game.source_building_dump_state({"copper": 2, "lead": 1}, [r0, r1], null, 0, true, ["lead", "copper"], accept_hook, handle_hook, no_can_dump)
	proof["dump_entry_null_dispatches_any"] = entry_any.get("dumped") == true and entry_any.get("item_id") == "lead" and entry_any.get("receiver_index") == 0
	var entry_specific: Dictionary = game.source_building_dump_state({"copper": 2, "lead": 1}, [r0, r1], "copper", 0, true, ["lead", "copper"], accept_hook, handle_hook, no_can_dump)
	proof["dump_entry_specific_dispatches"] = entry_specific.get("dumped") == true and entry_specific.get("item_id") == "copper" and entry_specific.get("receiver_index") == 0 and entry_specific.get("items_after", {}).get("copper") == 1 and entry_specific.get("items_after", {}).get("lead") == 1

	var state := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("BuildingDumpProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
