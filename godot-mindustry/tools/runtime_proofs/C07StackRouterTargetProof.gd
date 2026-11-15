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

	# --- Pure target list (N2324): DuctRouter.target()
	# (DuctRouter.java:139-157), simulated over consecutive
	# calls. Each call snapshots `int dump = cdump;` (:142)
	# and scans `proximity.get((i + dump) % proximity.size)`
	# (:145) from there; the first match wins. incrementDump
	# runs on EVERY scanned iteration -- before the return on
	# a match (:149-150) and at the end of the loop otherwise
	# (:153) -- so each call advances cdump by exactly the
	# number of neighbours scanned (1..size), including the
	# match; a call that scans the whole list without a match
	# returns null and stops the sequence (its advance is a
	# full size, i.e. a no-op modulo size). The match gate
	# (:148) skips the backwards neighbour (rel == (rotation
	# + 2) % 4), a wrong-team neighbour, and a neighbour that
	# rejects the item; the sortItem gate routes the sort item
	# only forward (rel == rotation) and every other item only
	# elsewhere. Neighbour dicts carry rel (relativeTo,
	# precomputed), team, and accepts_item; the router team is
	# an explicit parameter. Rotation 0 here, so backwards is
	# rel 2 and the forward / side rels are 0 / 1 / 3.
	var neighbours_abc: Array = [{"id": "a", "rel": 0, "team": 1, "accepts_item": true}, {"id": "b", "rel": 1, "team": 1, "accepts_item": true}, {"id": "c", "rel": 3, "team": 1, "accepts_item": true}]
	var from_cdump: Dictionary = stack_router_build_state.source_stack_router_target_list_state(neighbours_abc, "copper", null, 0, 1, 1, 1)
	var from_cdump_targets: Array = from_cdump.get("targets", [])
	var wrap: Dictionary = stack_router_build_state.source_stack_router_target_list_state(neighbours_abc, "copper", null, 0, 1, 2, 2)
	var wrap_targets: Array = wrap.get("targets", [])
	var skip_counts: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "a", "rel": 0, "team": 1, "accepts_item": false}, {"id": "b", "rel": 1, "team": 1, "accepts_item": true}, {"id": "c", "rel": 3, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	var skip_counts_targets: Array = skip_counts.get("targets", [])
	var null_current: Dictionary = stack_router_build_state.source_stack_router_target_list_state(neighbours_abc, null, null, 0, 1, 1, 3)
	var empty_neighbours: Dictionary = stack_router_build_state.source_stack_router_target_list_state([], "copper", null, 0, 1, 1, 3)
	var full_scan_null: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "a", "rel": 0, "team": 1, "accepts_item": false}, {"id": "b", "rel": 1, "team": 1, "accepts_item": false}, {"id": "c", "rel": 3, "team": 1, "accepts_item": false}], "copper", null, 0, 1, 1, 2)
	var zero_handoffs: Dictionary = stack_router_build_state.source_stack_router_target_list_state(neighbours_abc, "copper", null, 0, 1, 1, 0)
	proof["target_scans_from_cdump"] = from_cdump_targets.size() == 1 and str(from_cdump_targets[0].get("id", "")) == "b" and int(from_cdump.get("cdump_after", -1)) == 2 and wrap_targets.size() == 2 and str(wrap_targets[0].get("id", "")) == "c" and str(wrap_targets[1].get("id", "")) == "a" and int(wrap.get("cdump_after", -1)) == 1 and skip_counts_targets.size() == 1 and str(skip_counts_targets[0].get("id", "")) == "b" and int(skip_counts.get("cdump_after", -1)) == 2 and Array(null_current.get("targets", ["x"])).is_empty() and int(null_current.get("cdump_after", -1)) == 1 and Array(empty_neighbours.get("targets", ["x"])).is_empty() and int(empty_neighbours.get("cdump_after", -1)) == 1 and Array(full_scan_null.get("targets", ["x"])).is_empty() and int(full_scan_null.get("cdump_after", -1)) == 1 and Array(zero_handoffs.get("targets", ["x"])).is_empty() and int(zero_handoffs.get("cdump_after", -1)) == 1

	# The backwards neighbour (rel == (rotation + 2) % 4) is
	# skipped even when it accepts and shares the team: at
	# rotation 0 the rel-2 neighbour is passed over and the
	# forward neighbour wins, with cdump advancing past the
	# skipped entry; at rotation 1 the rel-3 neighbour is
	# backwards. A list holding only the backwards neighbour
	# matches nothing.
	var backwards_0: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "back", "rel": 2, "team": 1, "accepts_item": true}, {"id": "fwd", "rel": 0, "team": 1, "accepts_item": true}, {"id": "side", "rel": 1, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	var backwards_0_targets: Array = backwards_0.get("targets", [])
	var backwards_1: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "back", "rel": 3, "team": 1, "accepts_item": true}, {"id": "fwd", "rel": 1, "team": 1, "accepts_item": true}, {"id": "side", "rel": 0, "team": 1, "accepts_item": true}], "copper", null, 1, 1, 0, 1)
	var backwards_1_targets: Array = backwards_1.get("targets", [])
	var backwards_only: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "back", "rel": 2, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	proof["target_skips_backwards_neighbour"] = backwards_0_targets.size() == 1 and str(backwards_0_targets[0].get("id", "")) == "fwd" and int(backwards_0.get("cdump_after", -1)) == 2 and backwards_1_targets.size() == 1 and str(backwards_1_targets[0].get("id", "")) == "fwd" and int(backwards_1.get("cdump_after", -1)) == 2 and Array(backwards_only.get("targets", ["x"])).is_empty() and int(backwards_only.get("cdump_after", -1)) == 0

	# A wrong-team neighbour is skipped even when it accepts:
	# the enemy entry is passed over and the ally wins, with
	# cdump advancing past the skipped entry. A list holding
	# only wrong-team neighbours matches nothing.
	var wrong_team: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "enemy", "rel": 0, "team": 2, "accepts_item": true}, {"id": "ally", "rel": 1, "team": 1, "accepts_item": true}, {"id": "ally2", "rel": 3, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	var wrong_team_targets: Array = wrong_team.get("targets", [])
	var wrong_team_only: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "enemy", "rel": 0, "team": 2, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	proof["target_skips_wrong_team"] = wrong_team_targets.size() == 1 and str(wrong_team_targets[0].get("id", "")) == "ally" and int(wrong_team.get("cdump_after", -1)) == 2 and Array(wrong_team_only.get("targets", ["x"])).is_empty() and int(wrong_team_only.get("cdump_after", -1)) == 0

	# A neighbour that rejects the item (accepts_item false)
	# is skipped: two rejecting entries are passed over and
	# the accepting one wins, with cdump advancing by all
	# three scanned entries.
	var rejecting: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "r1", "rel": 0, "team": 1, "accepts_item": false}, {"id": "r2", "rel": 1, "team": 1, "accepts_item": false}, {"id": "ok", "rel": 3, "team": 1, "accepts_item": true}, {"id": "extra", "rel": 0, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	var rejecting_targets: Array = rejecting.get("targets", [])
	proof["target_skips_rejecting_neighbour"] = rejecting_targets.size() == 1 and str(rejecting_targets[0].get("id", "")) == "ok" and int(rejecting.get("cdump_after", -1)) == 3

	# sortItem routing (DuctRouter.java:148): when the sort
	# item IS the current item, only the forward neighbour
	# (rel == rotation) matches and the side neighbour is
	# skipped; when the sort item is a DIFFERENT item, only
	# non-forward neighbours match and the forward neighbour
	# is skipped; with no sort item there is no sort gate and
	# the first neighbour in scan order wins. A sort item
	# equal to current with only a side neighbour matches
	# nothing.
	var sort_is_current: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "side", "rel": 1, "team": 1, "accepts_item": true}, {"id": "fwd", "rel": 0, "team": 1, "accepts_item": true}, {"id": "extra", "rel": 3, "team": 1, "accepts_item": true}], "copper", "copper", 0, 1, 0, 1)
	var sort_is_current_targets: Array = sort_is_current.get("targets", [])
	var sort_is_other: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "fwd", "rel": 0, "team": 1, "accepts_item": true}, {"id": "side", "rel": 1, "team": 1, "accepts_item": true}, {"id": "extra", "rel": 3, "team": 1, "accepts_item": true}], "copper", "lead", 0, 1, 0, 1)
	var sort_is_other_targets: Array = sort_is_other.get("targets", [])
	var sort_none: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "fwd", "rel": 0, "team": 1, "accepts_item": true}, {"id": "side", "rel": 1, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 1)
	var sort_none_targets: Array = sort_none.get("targets", [])
	var sort_no_forward: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "side", "rel": 1, "team": 1, "accepts_item": true}], "copper", "copper", 0, 1, 0, 1)
	proof["target_sort_item_routing"] = sort_is_current_targets.size() == 1 and str(sort_is_current_targets[0].get("id", "")) == "fwd" and int(sort_is_current.get("cdump_after", -1)) == 2 and sort_is_other_targets.size() == 1 and str(sort_is_other_targets[0].get("id", "")) == "side" and int(sort_is_other.get("cdump_after", -1)) == 2 and sort_none_targets.size() == 1 and str(sort_none_targets[0].get("id", "")) == "fwd" and int(sort_none.get("cdump_after", -1)) == 1 and Array(sort_no_forward.get("targets", ["x"])).is_empty() and int(sort_no_forward.get("cdump_after", -1)) == 0

	# The pure target list feeds the N2240 advance directly:
	# the [a, b, a] list for 3 copper hands off 3 in order,
	# drains the current item, and re-picks lead.
	var composed_list: Dictionary = stack_router_build_state.source_stack_router_target_list_state([{"id": "a", "rel": 0, "team": 1, "accepts_item": true}, {"id": "b", "rel": 1, "team": 1, "accepts_item": true}], "copper", null, 0, 1, 0, 3)
	var composed: Dictionary = stack_router_build_state.source_stack_router_update_tile_advance_state({"efficiency": 0.5, "enabled": true, "unloading": true, "current": "copper", "progress": 0.5, "items": {"copper": 3, "lead": 7}}, 6.0, 1.0, 10, composed_list.get("targets", []), ["copper", "lead"])
	var composed_items: Dictionary = composed.get("items", {})
	var composed_ok: bool = int(composed.get("handed_off", -1)) == 3 and Array(composed.get("handed_to", [])) == ["a", "b", "a"] and int(composed_items.get("copper", -1)) == 0 and str(composed.get("current", "")) == "lead" and int(composed_list.get("cdump_after", -1)) == 1

	# --- Live tick: a surge-router placed live at cell (28,
	# 21). The tick driver is called directly (as the N2240
	# proof does), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status. A first
	# tick on the empty store stamps the live team_id (the
	# neighbours below must share it); then the store is
	# seeded unloading with 3 copper + 7 lead, current copper,
	# cdump 0, and two accepting same-team neighbours (a at
	# rel 0, b at rel 1, rotation 0). The tick computes the
	# target list [a, b, a] (cdump 0 -> 1) and passes it into
	# the N2240 advance, which hands off 3 copper in order,
	# re-picks lead, clears unloading, and the tick stamps
	# cdump 1. A second tick re-seeds the same frame charging
	# (not unloading, progress 0, full store, cdump 0): the
	# charge runs (progress 1.5 at eff 1.5), no handoff
	# happens, and cdump stays 0 -- Java calls target() only
	# inside the unload branch, so a charging tick must not
	# rotate cdump.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var stack_router_cell := Vector2i(28, 21)
	var stack_router := Sprite2D.new()
	game.add_child(stack_router)
	game.call("record_placed_block", stack_router, blocks_by_id["surge-router"], stack_router_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and seed
	# the store on it).
	stack_router_build_state.source_stack_router_bind_frame_state(stack_router, blocks_by_id["surge-router"])
	var stack_router_frame: Dictionary = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_team: int = int(stack_router_frame.get("team_id", -1))

	stack_router_frame["items"] = {"copper": 3, "lead": 7}
	stack_router_frame["current"] = "copper"
	stack_router_frame["unloading"] = true
	stack_router_frame["progress"] = 0.5
	stack_router_frame["power_status"] = 0.5
	stack_router_frame["cdump"] = 0
	stack_router_frame["sort_item"] = null
	stack_router_frame["proximity_neighbours"] = [{"id": "a", "rel": 0, "team": live_team, "accepts_item": true}, {"id": "b", "rel": 1, "team": live_team, "accepts_item": true}]
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_handoff_items: Dictionary = stack_router_frame.get("items", {})
	var live_handoff: bool = int(stack_router_frame.get("handed_off", -1)) == 3 and Array(stack_router_frame.get("handed_to", [])) == ["a", "b", "a"] and int(live_handoff_items.get("copper", -1)) == 0 and int(live_handoff_items.get("lead", -1)) == 7 and str(stack_router_frame.get("current", "")) == "lead" and bool(stack_router_frame.get("unloading", true)) == false and int(stack_router_frame.get("cdump", -1)) == 1

	stack_router_frame["items"] = {"copper": 3, "lead": 7}
	stack_router_frame["current"] = "copper"
	stack_router_frame["unloading"] = false
	stack_router_frame["progress"] = 0.0
	stack_router_frame["power_status"] = 0.5
	stack_router_frame["cdump"] = 0
	stack_router_build_state.source_stack_router_tick_buildings_state(game, 1.0 / 60.0)
	stack_router_frame = stack_router.get_meta(stack_router_build_state.SOURCE_STACK_ROUTER_BUILDING_META_KEY, {})
	var live_charging_items: Dictionary = stack_router_frame.get("items", {})
	proof["live_tick_passes_targets_to_advance"] = composed_ok and live_handoff and is_equal_approx(float(stack_router_frame.get("progress", -1.0)), 1.5) and int(stack_router_frame.get("handed_off", -1)) == 0 and Array(stack_router_frame.get("handed_to", ["x"])).is_empty() and int(stack_router_frame.get("cdump", -1)) == 0 and str(stack_router_frame.get("current", "")) == "copper" and int(live_charging_items.get("copper", -1)) == 3 and int(live_charging_items.get("lead", -1)) == 7 and bool(stack_router_frame.get("unloading", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterTargetProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
