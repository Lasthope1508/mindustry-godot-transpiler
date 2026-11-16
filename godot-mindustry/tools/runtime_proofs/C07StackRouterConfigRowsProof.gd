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

	# --- Config / sortItem rows (N2449):
	# StackRouter inherits config(Item)
	# (DuctRouter.java:44, sortItem = item),
	# configClear (:45, sortItem = null),
	# buildConfiguration (:124-127, the
	# ItemSelection.buildTable picker) and
	# configured() (:128-135, super + recache()
	# + renderer.minimap.update(tile) when
	# !headless) from DuctRouter (StackRouter.
	# java:11) and overrides NONE of them. The
	# action is a discriminated input (the
	# N2443 precedent): "set" applies the
	# config(Item) handler, "clear" applies
	# configClear, "none" leaves sortItem
	# untouched (the pure returns the
	# current_sort_item input). The dispatch:
	# configClear registers under void.class
	# (Block.java:922-924) and BuildingComp.
	# configured dispatches null values to
	# void.class (BuildingComp.java:1414-1416),
	# so a null configure clears; a non-null
	# Item dispatches to Item.class
	# (BuildingComp.java:1418). InputHandler.
	# tileConfig calls build.configured
	# unconditionally (InputHandler.java:728),
	# so a configure with the SAME item still
	# recaches + updates the minimap when
	# !headless (the N2443 lesson: NO equality
	# condition). recache() is BuildingComp.
	# recache() (BuildingComp.java:1285-1287),
	# a renderer-side cache invalidation with
	# no pure state of its own -- verified
	# first, so it is a CALL flag. config()
	# returns sortItem (DuctRouter.java:187-189),
	# so the pure's sort_item IS the
	# post-action config() value. The picker is
	# recorded as a CALL record (the N2396 CALL
	# precedent); the UI itself is NOT ported.
	# Pure-only: the tick never calls config /
	# configured / buildConfiguration.
	var surge_alloy: Dictionary = {"name": "surge-alloy", "color": -202802689}
	var copper: Dictionary = {"name": "copper", "color": -642810369}

	# --- Config set: the "set" action applies
	# the config(Item) handler (sortItem = the
	# item) and recaches + updates the minimap
	# when !headless. Setting from null and
	# replacing one item with another both
	# work; the post-action sort_item IS the
	# config() value.
	var set_from_null: Dictionary = stack_router_build_state.source_stack_router_config_state("set", surge_alloy, false, null)
	var set_replace: Dictionary = stack_router_build_state.source_stack_router_config_state("set", surge_alloy, false, copper)
	proof["config_set"] = set_from_null.get("sort_item", null) == surge_alloy and bool(set_from_null.get("recache_called", false)) == true and bool(set_from_null.get("minimap_updated", false)) == true and set_replace.get("sort_item", null) == surge_alloy and bool(set_replace.get("recache_called", false)) == true and bool(set_replace.get("minimap_updated", false)) == true

	# --- Config clear: the "clear" action
	# applies configClear (sortItem = null) and
	# recaches + updates the minimap when
	# !headless, even when the sort item was
	# already null (the handler runs
	# unconditionally).
	var cleared: Dictionary = stack_router_build_state.source_stack_router_config_state("clear", null, false, surge_alloy)
	var cleared_empty: Dictionary = stack_router_build_state.source_stack_router_config_state("clear", null, false, null)
	proof["config_clear"] = cleared.get("sort_item", surge_alloy) == null and bool(cleared.get("recache_called", false)) == true and bool(cleared.get("minimap_updated", false)) == true and cleared_empty.get("sort_item", surge_alloy) == null and bool(cleared_empty.get("recache_called", false)) == true and bool(cleared_empty.get("minimap_updated", false)) == true

	# --- Config none: the "none" action leaves
	# sortItem untouched (the pure returns the
	# current_sort_item input) and recaches /
	# updates nothing -- a set sort item stays
	# set, a null sort item stays null.
	var untouched: Dictionary = stack_router_build_state.source_stack_router_config_state("none", null, false, surge_alloy)
	var untouched_empty: Dictionary = stack_router_build_state.source_stack_router_config_state("none", surge_alloy, false, null)
	proof["config_none"] = untouched.get("sort_item", null) == surge_alloy and bool(untouched.get("recache_called", true)) == false and bool(untouched.get("minimap_updated", true)) == false and untouched_empty.get("sort_item", surge_alloy) == null and bool(untouched_empty.get("recache_called", true)) == false and bool(untouched_empty.get("minimap_updated", true)) == false

	# --- Configured headless: the config
	# handler itself (super.configured) runs
	# regardless of headless -- a headless set
	# still sets sortItem and a headless clear
	# still clears it -- but recache() and the
	# minimap update are inside the !headless
	# guard, so neither runs.
	var set_headless: Dictionary = stack_router_build_state.source_stack_router_config_state("set", surge_alloy, true, null)
	var clear_headless: Dictionary = stack_router_build_state.source_stack_router_config_state("clear", null, true, surge_alloy)
	proof["configured_headless"] = set_headless.get("sort_item", null) == surge_alloy and bool(set_headless.get("recache_called", true)) == false and bool(set_headless.get("minimap_updated", true)) == false and clear_headless.get("sort_item", surge_alloy) == null and bool(clear_headless.get("recache_called", true)) == false and bool(clear_headless.get("minimap_updated", true)) == false

	# --- Configured minimap: a configure with
	# the SAME item still recaches + updates
	# the minimap when !headless -- Java has
	# NO equality check anywhere in the
	# configured chain (InputHandler.
	# tileConfig calls build.configured
	# unconditionally, InputHandler.java:728).
	var same_item: Dictionary = stack_router_build_state.source_stack_router_config_state("set", surge_alloy, false, surge_alloy)
	proof["configured_minimap"] = same_item.get("sort_item", null) == surge_alloy and bool(same_item.get("recache_called", false)) == true and bool(same_item.get("minimap_updated", false)) == true

	# --- Build configuration call: the
	# buildConfiguration CALL record carries
	# the ItemSelection.buildTable method and
	# the PRE-action sort item (the supplier
	# `() -> sortItem` reads the live field at
	# UI-build time, before any configure) --
	# set with a copper current, clear with a
	# surge current, and none with a null
	# current. The UI itself is NOT ported.
	var set_call: Dictionary = set_replace.get("configure_call", {})
	var clear_call: Dictionary = cleared.get("configure_call", {})
	var none_call: Dictionary = untouched_empty.get("configure_call", {})
	proof["build_configuration_call"] = str(set_call.get("method", "")) == "ItemSelection.buildTable" and set_call.get("current_sort_item", null) == copper and str(clear_call.get("method", "")) == "ItemSelection.buildTable" and clear_call.get("current_sort_item", null) == surge_alloy and str(none_call.get("method", "")) == "ItemSelection.buildTable" and none_call.get("current_sort_item", surge_alloy) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackRouterConfigRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
