extends Node

const main_scene := preload("res://scenes/Main.tscn")
const stack_conveyor_build_state := preload("res://src/game/SourceStackConveyorBuildState.gd")
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

	# --- SetStats rows (N2457): StackConveyor.
	# setStats() (StackConveyor.java:64-68)
	# adds stats.add(Stat.itemsMoved, Mathf.
	# round(itemCapacity * speed * 60),
	# StatUnit.itemsSecond) -- the float math is
	# Java-exact: itemCapacity * speed FIRST,
	# then times 60 (left-assoc), then Mathf.
	# round. The class defaults are speed 0f
	# (StackConveyor.java:38) and itemCapacity
	# 10 (StackConveyor.java:52), so the
	# class-default rate is round(10 * 0 * 60)
	# = 0. The plastanium-conveyor def sets
	# speed 4f/60f (Blocks.java:2087) with
	# itemCapacity 10 (Blocks.java:2088), so
	# its rate is round(10 * 4/60 * 60) = 40;
	# the surge-conveyor def sets speed 5f/60f
	# (Blocks.java:2241) with itemCapacity 10
	# (Blocks.java:2242), so its rate is
	# round(10 * 5/60 * 60) = 50. There is NO
	# "stack-conveyor" or "large-stack-conveyor"
	# def in Blocks.java -- plastanium-conveyor
	# and surge-conveyor are the only two
	# StackConveyor defs. Mathf.round(float)
	# (arc Mathf.java:500-502) adds
	# BIG_ENOUGH_ROUND (16384.5f) and
	# truncates, which is floor(v + 0.5) for
	# the non-negative values here -- the port
	# uses int(floor(v + 0.5)) explicitly, so
	# the .5 edge rounds UP exactly like Java.
	# Pure-only: the tick never calls setStats.

	# --- Class default: speed 0f, itemCapacity
	# 10 -- round(10 * 0 * 60) = 0.
	var class_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(10, 0.0)
	proof["stats_class_default"] = int(class_stats.get("items_moved_per_second", -1)) == 0

	# --- Plastanium-conveyor def: speed 4f/60f,
	# itemCapacity 10 -- round(10 * 4/60 * 60)
	# = 40.
	var plastanium_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(10, 4.0 / 60.0)
	proof["stats_plastanium_def"] = int(plastanium_stats.get("items_moved_per_second", -1)) == 40

	# --- Surge-conveyor def: speed 5f/60f,
	# itemCapacity 10 -- round(10 * 5/60 * 60)
	# = 50.
	var surge_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(10, 5.0 / 60.0)
	proof["stats_surge_def"] = int(surge_stats.get("items_moved_per_second", -1)) == 50

	# --- Stat key: the exact Stat token --
	# "itemsMoved" (Stat.java:52) -- and the
	# exact setStats expr the pure records.
	proof["stats_key"] = str(class_stats.get("stat_key", "")) == "itemsMoved" and str(class_stats.get("set_stats_expr", "")) == "stats.add(Stat.itemsMoved, Mathf.round(itemCapacity * speed * 60), StatUnit.itemsSecond);"

	# --- Stat unit: the exact StatUnit token
	# -- "itemsSecond" (StatUnit.java:20).
	proof["stats_unit"] = str(class_stats.get("stat_unit", "")) == "itemsSecond"

	# --- Rounding edge: Mathf.round is
	# floor(v + 0.5) for non-negative v, so
	# the .5 edge rounds UP -- 1 * 0.075 * 60
	# = 4.5 -> 5 and 1 * (2.5/60) * 60 = 2.5
	# -> 3 -- while 1 * 0.07 * 60 = 4.2 -> 4
	# rounds down.
	var half_up: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(1, 0.075)
	var half_up_small: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(1, 2.5 / 60.0)
	var below_half: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(1, 0.07)
	proof["stats_rounding"] = int(half_up.get("items_moved_per_second", -1)) == 5 and int(half_up_small.get("items_moved_per_second", -1)) == 3 and int(below_half.get("items_moved_per_second", -1)) == 4

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackConveyorSetStatsRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
