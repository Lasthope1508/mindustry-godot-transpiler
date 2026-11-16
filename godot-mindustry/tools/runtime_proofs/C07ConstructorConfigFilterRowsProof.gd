extends Node

const main_scene := preload("res://scenes/Main.tscn")
const constructor_build_state := preload("res://src/game/SourceConstructorBuildState.gd")
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

	# --- Config / filter rows (N2455):
	# canProduce (Constructor.java:54-56, all
	# 7 conditions in Java order) + config(Block)
	# (:32-37, the progress reset runs BEFORE
	# the canProduce gate) + configClear
	# (:31/:38, recipe = null, no progress
	# reset) + buildConfiguration (:66-70, the
	# ItemSelection.buildTable picker) +
	# config() (:73-75, returns recipe) +
	# setStats (:41-47, Stat.output "@x@ ~ @x@"
	# with [min, min, max, max] + Stat.
	# buildSpeed percent of the RAW buildSpeed).
	# The block is a caller-supplied Dict {name,
	# is_visible, size, is_core_block,
	# is_banned, environment_buildable} (all
	# predicates caller-supplied -- the N2435
	# precedent; the pures never read content /
	# rules) and the filter is an Array of block
	# names (empty = no filter). The config
	# action is a discriminated input (the
	# N2449 precedent): "set" applies the
	# config(Block) handler, "clear" applies
	# configClear, "none" leaves the recipe
	# untouched. The reset-before-gate order
	# (:33 before :34) means a non-producible
	# block still resets progress while the
	# recipe stays put; a set of the SAME block
	# resets nothing. Defs (verified first):
	# constructor (filter 7 walls/containers +
	# beam-node, Blocks.java:6666; buildSpeed
	# 0.6f, :6662; min/max class defaults 1/2)
	# and large-constructor (empty filter, min
	# 3 / max 4, buildSpeed 0.75f,
	# Blocks.java:6675-6677). The picker is
	# recorded as a CALL record (the N2449 CALL
	# precedent); the UI itself is NOT ported.
	# Pure-only: the tick never calls
	# canProduce / config / buildConfiguration
	# / setStats.
	var tungsten_wall_large: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 2, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var hidden_block: Dictionary = {"name": "tungsten-wall-large", "is_visible": false, "size": 2, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var core_block: Dictionary = {"name": "core-shard", "is_visible": true, "size": 2, "is_core_block": true, "is_banned": false, "environment_buildable": true}
	var banned_block: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 2, "is_core_block": false, "is_banned": true, "environment_buildable": true}
	var unbuildable_block: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 2, "is_core_block": false, "is_banned": false, "environment_buildable": false}
	var beam_node: Dictionary = {"name": "beam-node", "is_visible": true, "size": 2, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var copper_wall: Dictionary = {"name": "copper-wall", "is_visible": true, "size": 2, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var empty_filter: Array = []
	var constructor_filter: Array = ["tungsten-wall-large", "beryllium-wall-large", "carbide-wall-large", "reinforced-surge-wall-large", "reinforced-liquid-container", "reinforced-container", "beam-node"]

	# --- Can-produce visible: the visible /
	# core / banned / buildable predicates
	# (Constructor.java:55, terms 1, 4, 5, 6)
	# -- a visible, non-core, unbanned,
	# buildable block produces; an invisible
	# block, a core block, a banned block and
	# a non-buildable block each fail on their
	# own term (all at size 2 inside the
	# constructor 1/2 bounds, empty filter).
	var visible_ok: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, empty_filter)
	var hidden_no: Dictionary = constructor_build_state.source_constructor_can_produce_state(hidden_block, 1, 2, empty_filter)
	var core_no: Dictionary = constructor_build_state.source_constructor_can_produce_state(core_block, 1, 2, empty_filter)
	var banned_no: Dictionary = constructor_build_state.source_constructor_can_produce_state(banned_block, 1, 2, empty_filter)
	var unbuildable_no: Dictionary = constructor_build_state.source_constructor_can_produce_state(unbuildable_block, 1, 2, empty_filter)
	proof["can_produce_visible"] = bool(visible_ok.get("can_produce", false)) == true and bool(hidden_no.get("can_produce", true)) == false and bool(core_no.get("can_produce", true)) == false and bool(banned_no.get("can_produce", true)) == false and bool(unbuildable_no.get("can_produce", true)) == false

	# --- Can-produce size gate: the size bounds
	# (Constructor.java:55, terms 2-3) are
	# INCLUSIVE at both defs -- constructor
	# 1/2 takes size 1 and 2, rejects 0 and 3;
	# large-constructor 3/4 takes size 3 and
	# 4, rejects 2 and 5 (all visible,
	# non-core, unbanned, buildable, empty
	# filter).
	var size_1: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 1, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var size_0: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 0, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var size_3: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 3, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var size_4: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 4, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var size_5: Dictionary = {"name": "tungsten-wall-large", "is_visible": true, "size": 5, "is_core_block": false, "is_banned": false, "environment_buildable": true}
	var gate_min: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_1, 1, 2, empty_filter)
	var gate_max: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, empty_filter)
	var gate_below: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_0, 1, 2, empty_filter)
	var gate_above: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_3, 1, 2, empty_filter)
	var large_min: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_3, 3, 4, empty_filter)
	var large_max: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_4, 3, 4, empty_filter)
	var large_below: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 3, 4, empty_filter)
	var large_above: Dictionary = constructor_build_state.source_constructor_can_produce_state(size_5, 3, 4, empty_filter)
	proof["can_produce_size_gate"] = bool(gate_min.get("can_produce", false)) == true and bool(gate_max.get("can_produce", false)) == true and bool(gate_below.get("can_produce", true)) == false and bool(gate_above.get("can_produce", true)) == false and bool(large_min.get("can_produce", false)) == true and bool(large_max.get("can_produce", false)) == true and bool(large_below.get("can_produce", true)) == false and bool(large_above.get("can_produce", true)) == false

	# --- Can-produce filter: the filter term
	# (Constructor.java:55, term 7) -- an
	# empty filter admits every otherwise
	# producible block; a non-empty filter
	# admits only its members. The constructor
	# def filter (Blocks.java:6666) admits
	# tungsten-wall-large and beam-node but
	# not copper-wall.
	var filter_empty: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, empty_filter)
	var filter_member: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, ["tungsten-wall-large"])
	var filter_other: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, ["beam-node"])
	var def_wall: Dictionary = constructor_build_state.source_constructor_can_produce_state(tungsten_wall_large, 1, 2, constructor_filter)
	var def_node: Dictionary = constructor_build_state.source_constructor_can_produce_state(beam_node, 1, 2, constructor_filter)
	var def_copper: Dictionary = constructor_build_state.source_constructor_can_produce_state(copper_wall, 1, 2, constructor_filter)
	proof["can_produce_filter"] = bool(filter_empty.get("can_produce", false)) == true and bool(filter_member.get("can_produce", false)) == true and bool(filter_other.get("can_produce", true)) == false and bool(def_wall.get("can_produce", false)) == true and bool(def_node.get("can_produce", false)) == true and bool(def_copper.get("can_produce", true)) == false

	# --- Config set: the "set" action applies
	# the config(Block) handler -- a producible
	# block becomes the recipe and progress
	# resets when it differs from the current
	# recipe; setting the SAME block resets
	# nothing; a NON-producible block still
	# resets progress (the :33-before-:34
	# order) while the recipe stays put. The
	# configure_call record carries the
	# ItemSelection.buildTable method and the
	# PRE-action recipe.
	var set_from_null: Dictionary = constructor_build_state.source_constructor_config_state("set", tungsten_wall_large, null, true)
	var set_same: Dictionary = constructor_build_state.source_constructor_config_state("set", tungsten_wall_large, tungsten_wall_large, true)
	var set_blocked: Dictionary = constructor_build_state.source_constructor_config_state("set", tungsten_wall_large, copper_wall, false)
	var set_blocked_null: Dictionary = constructor_build_state.source_constructor_config_state("set", tungsten_wall_large, null, false)
	var set_call: Dictionary = set_from_null.get("configure_call", {})
	proof["config_set"] = set_from_null.get("recipe", null) == tungsten_wall_large and bool(set_from_null.get("progress_reset", false)) == true and set_same.get("recipe", null) == tungsten_wall_large and bool(set_same.get("progress_reset", true)) == false and set_blocked.get("recipe", null) == copper_wall and bool(set_blocked.get("progress_reset", false)) == true and set_blocked_null.get("recipe", tungsten_wall_large) == null and bool(set_blocked_null.get("progress_reset", false)) == true and str(set_call.get("method", "")) == "ItemSelection.buildTable" and set_call.get("current_recipe", tungsten_wall_large) == null

	# --- Config clear: the "clear" action
	# applies configClear (recipe = null) with
	# NO progress reset -- clearing a set
	# recipe and clearing an already-null
	# recipe both leave progress_reset false.
	# The configure_call record still carries
	# the PRE-action recipe.
	var cleared: Dictionary = constructor_build_state.source_constructor_config_state("clear", null, tungsten_wall_large, true)
	var cleared_empty: Dictionary = constructor_build_state.source_constructor_config_state("clear", null, null, true)
	var clear_call: Dictionary = cleared.get("configure_call", {})
	proof["config_clear"] = cleared.get("recipe", tungsten_wall_large) == null and bool(cleared.get("progress_reset", true)) == false and cleared_empty.get("recipe", tungsten_wall_large) == null and bool(cleared_empty.get("progress_reset", true)) == false and str(clear_call.get("method", "")) == "ItemSelection.buildTable" and clear_call.get("current_recipe", null) == tungsten_wall_large

	# --- Stats def: the setStats rows at both
	# defs -- constructor (min 1, max 2,
	# buildSpeed 0.6f) reports output "@x@ ~
	# @x@" with [1, 1, 2, 2] and buildSpeed
	# 0.6 RAW; large-constructor (min 3, max
	# 4, buildSpeed 0.75f) reports [3, 3, 4, 4]
	# and 0.75 RAW; the class defaults (1, 2,
	# 0.4f) report [1, 1, 2, 2] and 0.4 RAW
	# (addPercent formats at display,
	# Stats.java:38).
	var stats_small: Dictionary = constructor_build_state.source_constructor_stats_state(1, 2, 0.6)
	var stats_large: Dictionary = constructor_build_state.source_constructor_stats_state(3, 4, 0.75)
	var stats_default: Dictionary = constructor_build_state.source_constructor_stats_state(1, 2, 0.4)
	var output_small: Dictionary = stats_small.get("output_stat", {})
	var speed_small: Dictionary = stats_small.get("build_speed_stat", {})
	var output_large: Dictionary = stats_large.get("output_stat", {})
	var speed_large: Dictionary = stats_large.get("build_speed_stat", {})
	var speed_default: Dictionary = stats_default.get("build_speed_stat", {})
	proof["stats_def"] = str(output_small.get("key", "")) == "output" and str(output_small.get("format", "")) == "@x@ ~ @x@" and output_small.get("values", []) == [1, 1, 2, 2] and str(speed_small.get("key", "")) == "buildSpeed" and float(speed_small.get("value", 0.0)) == 0.6 and str(output_large.get("key", "")) == "output" and output_large.get("values", []) == [3, 3, 4, 4] and float(speed_large.get("value", 0.0)) == 0.75 and float(speed_default.get("value", 0.0)) == 0.4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ConstructorConfigFilterRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
