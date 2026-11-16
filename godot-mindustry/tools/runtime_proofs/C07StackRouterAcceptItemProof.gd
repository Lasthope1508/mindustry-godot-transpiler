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

	# --- Pure acceptItem gate (N2332): the StackRouter
	# OVERRIDE (StackRouter.java:89-93), NOT the parent
	# DuctRouter acceptItem (DuctRouter.java:160-164,
	# stricter: current == null && items.total() == 0).
	# The four terms are independent: !unloading, (current
	# == null || item == current), items.total() <
	# itemCapacity, and the facing term
	# (Edges.getFacingEdge(source.tile, tile).relativeTo
	# (tile) == rotation). facing_rel arrives precomputed
	# (the N2324 precedent -- the port has no live tile
	# geometry); -1 means the source is not adjacent, which
	# never equals rotation. Item capacity is 10 (the surge
	# def, StackRouter.java:20 / Block.java:75). The
	# override takes the current item into a PARTIALLY
	# filled router -- the parent would reject it (total
	# != 0) -- so the current-item accept below pins the
	# override, not the parent. acceptItem is an intake
	# gate called by OTHER buildings' dump/offload
	# (BuildingComp.java:1001-1016), never by the router's
	# own tick -- so this proof drives the pure only, with
	# no live tick: there is no call site to wire.
	var idle_empty: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {}, 10, 0, 0)
	var idle_partial_other: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {"lead": 5}, 10, 0, 0)
	var idle_rotation_2: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {}, 10, 2, 2)
	proof["accepts_when_idle_and_facing"] = bool(idle_empty.get("accepts", false)) and bool(idle_partial_other.get("accepts", false)) and bool(idle_rotation_2.get("accepts", false))

	# Unloading rejects even when every other term holds:
	# idle terms + current null + empty store + facing, but
	# unloading true. (The unload branch sets unloading
	# true at the cap, StackRouter.java:38-40 -- a router
	# mid-unload takes nothing.)
	var unloading: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(true, null, "copper", {}, 10, 0, 0)
	var unloading_current: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(true, "copper", "copper", {"copper": 5}, 10, 0, 0)
	proof["rejects_when_unloading"] = not bool(unloading.get("accepts", true)) and not bool(unloading_current.get("accepts", true))

	# A different current item rejects: current lead, incoming
	# copper, idle + under capacity + facing -- the (current
	# == null || item == current) term fails on both arms.
	var differs: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, "lead", "copper", {"lead": 5}, 10, 0, 0)
	var differs_empty_store: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, "lead", "copper", {}, 10, 0, 0)
	proof["rejects_when_current_differs"] = not bool(differs.get("accepts", true)) and not bool(differs_empty_store.get("accepts", true))

	# Full rejects: total == capacity (10) and total above
	# capacity (11) both fail items.total() < itemCapacity;
	# total == capacity - 1 (9) still accepts -- the
	# capacity term is STRICT (<, not <=).
	var full: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {"copper": 10}, 10, 0, 0)
	var overfull: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {"copper": 6, "lead": 5}, 10, 0, 0)
	var one_short: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {"copper": 9}, 10, 0, 0)
	proof["rejects_when_full"] = not bool(full.get("accepts", true)) and not bool(overfull.get("accepts", true)) and bool(one_short.get("accepts", false))

	# Wrong facing rejects: facing_rel 1 against rotation 0,
	# facing_rel 3 against rotation 0, and the non-adjacent
	# -1 facing (Tile.relativeTo returns -1 when the source
	# tile is not adjacent, Tile.java:95-101) against
	# rotation 0 -- -1 never equals any rotation. Facing 2
	# against rotation 2 accepts (pinned in the idle key).
	var facing_side: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {}, 10, 1, 0)
	var facing_other_side: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {}, 10, 3, 0)
	var facing_non_adjacent: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, null, "copper", {}, 10, -1, 0)
	proof["rejects_when_wrong_facing"] = not bool(facing_side.get("accepts", true)) and not bool(facing_other_side.get("accepts", true)) and not bool(facing_non_adjacent.get("accepts", true))

	# The current item accepts when facing: current copper,
	# incoming copper, idle + under capacity + facing. The
	# partially filled store (5 copper of 10) is the
	# override-vs-parent pin: the StackRouter override
	# accepts (current matches, total < capacity) where the
	# parent DuctRouter gate would reject (total != 0).
	var current_match: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, "copper", "copper", {"copper": 5}, 10, 0, 0)
	var current_match_empty: Dictionary = stack_router_build_state.source_stack_router_accept_item_state(false, "copper", "copper", {}, 10, 0, 0)
	proof["accepts_current_item_when_facing"] = bool(current_match.get("accepts", false)) and bool(current_match_empty.get("accepts", false))

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterAcceptItemProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
