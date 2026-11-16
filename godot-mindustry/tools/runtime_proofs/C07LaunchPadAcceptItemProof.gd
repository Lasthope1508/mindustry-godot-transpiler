extends Node

const main_scene := preload("res://scenes/Main.tscn")
const launch_pad_build_state := preload("res://src/game/SourceLaunchPadBuildState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Catalog: both defs carry itemCapacity 100
	# (Blocks.java:6793/6803); the catalog carries no
	# acceptMultipleItems key, so the pure takes it as an
	# explicit parameter (launch-pad true, Blocks.java:6796;
	# advanced-launch-pad false, the LaunchPad.java:40 class
	# default). The item order is the catalog
	# item_names_by_id, the content-id order ItemModule.
	# first() scans (ItemModule.java:182-189).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var item_capacity: int = int(blocks_by_id["launch-pad"].properties.get("itemCapacity", 10))
	var item_order: Array = content_registry_state.source_item_catalog_state(catalog).get("item_names_by_id", [])

	# --- Pure acceptItem gate (N2333): LaunchPadBuild.
	# acceptItem (LaunchPad.java:138-140, `return items.
	# total() < itemCapacity && (acceptMultipleItems ||
	# items.total() == 0 || items.first() == item);`) -- total
	# < capacity AND (accept_multiple OR total == 0 OR first
	# == item), the item compared by name string (the N2225
	# precedent -- Java compares Item references).
	var empty_copper: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": {}}, "copper", item_capacity, false, item_order)
	var empty_lead: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": {}}, "lead", item_capacity, false, item_order)
	proof["accepts_when_empty"] = bool(empty_copper.get("accepts", false)) and bool(empty_lead.get("accepts", false))

	var partial_items := {"copper": 50}
	var same_item: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": partial_items}, "copper", item_capacity, false, item_order)
	proof["accepts_same_item_when_partial"] = bool(same_item.get("accepts", false))

	var other_item: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": partial_items}, "lead", item_capacity, false, item_order)
	proof["rejects_other_item_when_partial_single"] = not bool(other_item.get("accepts", true))

	var multiple_item: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": partial_items}, "lead", item_capacity, true, item_order)
	proof["accepts_any_when_multiple_allowed"] = bool(multiple_item.get("accepts", false))

	var full_same: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": {"copper": item_capacity}}, "copper", item_capacity, true, item_order)
	var full_mixed: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": {"copper": item_capacity - 1, "lead": 1}}, "lead", item_capacity, true, item_order)
	proof["rejects_when_full"] = not bool(full_same.get("accepts", true)) and not bool(full_mixed.get("accepts", true))

	# The first item follows the content-id order, not the
	# dict order: with copper and lead both held, the first
	# name in item_order accepts and the other rejects on a
	# single-item pad.
	var mixed_items := {"copper": 3, "lead": 5}
	var first_name := ""
	for candidate in item_order:
		if int(mixed_items.get(str(candidate), 0)) > 0:
			first_name = str(candidate)
			break
	var other_name := "lead" if first_name == "copper" else "copper"
	var first_call: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": mixed_items}, first_name, item_capacity, false, item_order)
	var other_call: Dictionary = launch_pad_build_state.source_launch_pad_accept_item_state({"items": mixed_items}, other_name, item_capacity, false, item_order)
	proof["first_item_uses_content_order"] = first_name != "" and bool(first_call.get("accepts", false)) and not bool(other_call.get("accepts", true))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LaunchPadAcceptItemProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
