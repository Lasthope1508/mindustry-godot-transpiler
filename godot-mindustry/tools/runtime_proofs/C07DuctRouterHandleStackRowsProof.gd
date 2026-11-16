extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_router_build_state := preload("res://src/game/SourceStackRouterBuildState.gd")
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

	# --- DuctRouter handleStack / removeStack rows (N2458):
	# StackRouter inherits handleStack
	# (DuctRouter.java:173-177, super adds the
	# stack then current = item) and removeStack
	# (:166-171, super removes the clamped
	# amount then current = null iff item ==
	# current) from DuctRouter (StackRouter.
	# java:11) and overrides NEITHER of them.
	# The super calls are BuildingComp.
	# removeStack (BuildingComp.java:786-792:
	# `if(items == null) return 0;` then
	# `amount = Math.min(amount, items.get(
	# item));` then `items.remove(item,
	# amount);` then `return amount;`) and
	# BuildingComp.handleStack (:795-798:
	# `noSleep();` then `items.add(item,
	# amount);`) -- verified first, so the
	# removed count is the CLAMPED amount
	# min(amount, items.get(item)) and the
	# handle count is the UNCLAMPED add
	# (ItemModule.add just +=, ItemModule.
	# java:234-242, no capacity clamp). The
	# clear is UNCONDITIONAL on the removed
	# amount: DuctRouter.removeStack clears
	# current whenever item == current
	# (DuctRouter.java:168), even when the
	# removed amount is 0 -- there is no
	# removed > 0 guard. The item is null or
	# a Dict {name} (the N2433/N2449
	# precedent); current is the same build
	# field the N2324 target pure reads
	# (`public @Nullable Item current;`,
	# DuctRouter.java:80); the port compares
	# item NAMES (Java `==` on Item is
	# identity, the N2449 precedent).
	# handleItem (DuctRouter.java:179-184,
	# current = item + progress = -1f +
	# items.add(item, 1)) is NOT ported here
	# -- progress = -1f belongs to handleItem,
	# NOT handleStack. Pure-only: the tick
	# never calls handleStack / removeStack.
	var surge_alloy: Dictionary = {"name": "surge-alloy"}
	var copper: Dictionary = {"name": "copper"}

	# --- Handle stack sets current: the
	# "handle_stack" action sets current = the
	# stacked item (DuctRouter.java:175),
	# replacing a different current item and
	# filling a null current alike.
	var set_replace: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("handle_stack", surge_alloy, 5, copper, 3)
	var set_from_null: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("handle_stack", copper, 1, null, 0)
	proof["handle_stack_sets_current"] = set_replace.get("current_after", null) == surge_alloy and set_from_null.get("current_after", null) == copper

	# --- Handle stack adds: the "handle_stack"
	# action adds the whole amount to the store
	# (BuildingComp.handleStack, BuildingComp.
	# java:797, `items.add(item, amount);`,
	# unclamped -- ItemModule.add just +=) and
	# removes nothing (handleStack returns
	# void, so removed_count is 0).
	var added: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("handle_stack", surge_alloy, 5, copper, 3)
	var added_zero: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("handle_stack", copper, 0, null, 4)
	proof["handle_stack_adds"] = int(added.get("items_count_after", -1)) == 8 and int(added.get("removed_count", -1)) == 0 and int(added_zero.get("items_count_after", -1)) == 4 and int(added_zero.get("removed_count", -1)) == 0

	# --- Remove stack clears: the "remove_stack"
	# action clears current to null when the
	# removed item IS the current item
	# (DuctRouter.java:168) -- and the clear
	# is unconditional on the removed amount:
	# a zero-amount removeStack still clears
	# current when item == current.
	var cleared: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 2, surge_alloy, 5)
	var cleared_zero: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 0, surge_alloy, 5)
	proof["remove_stack_clears"] = cleared.get("current_after", surge_alloy) == null and int(cleared.get("removed_count", -1)) == 2 and int(cleared.get("items_count_after", -1)) == 3 and cleared_zero.get("current_after", surge_alloy) == null and int(cleared_zero.get("removed_count", -1)) == 0 and int(cleared_zero.get("items_count_after", -1)) == 5

	# --- Remove stack keeps other: removing a
	# DIFFERENT item leaves current untouched
	# (DuctRouter.java:168, `if(item ==
	# current)` is false) while the store still
	# loses the clamped amount.
	var kept: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 2, copper, 5)
	proof["remove_stack_keeps_other"] = kept.get("current_after", null) == copper and int(kept.get("removed_count", -1)) == 2 and int(kept.get("items_count_after", -1)) == 3

	# --- Remove stack clamp: the removed count
	# is min(amount, items.get(item))
	# (BuildingComp.java:788) -- asking for
	# more than the store holds removes only
	# what is held and empties the count.
	var clamped: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 10, surge_alloy, 3)
	proof["remove_stack_clamp"] = int(clamped.get("removed_count", -1)) == 3 and int(clamped.get("items_count_after", -1)) == 0 and clamped.get("current_after", surge_alloy) == null

	# --- Remove stack return: the super return
	# is the amount ACTUALLY removed
	# (BuildingComp.java:791, `return amount;`
	# after the clamp) -- a partial removal
	# returns the requested amount and a full
	# removal returns the whole held count.
	var partial: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 2, copper, 5)
	var full: Dictionary = stack_router_build_state.source_duct_router_handle_stack_state("remove_stack", surge_alloy, 5, copper, 5)
	proof["remove_stack_return"] = int(partial.get("removed_count", -1)) == 2 and int(partial.get("items_count_after", -1)) == 3 and int(full.get("removed_count", -1)) == 5 and int(full.get("items_count_after", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DuctRouterHandleStackRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
