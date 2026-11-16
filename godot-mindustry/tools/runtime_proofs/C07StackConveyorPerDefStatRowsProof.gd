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

	# --- Per-def stat rows (N2495): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442
	# precedent). The TWO StackConveyor defs --
	# plastanium-conveyor (Blocks.java:2084-2089:
	# health 90, speed 4f/60f, itemCapacity 10,
	# requirements plastanium 1 / silicon 1 /
	# graphite 1) and surge-conveyor
	# (Blocks.java:2237-2253: health 130, speed
	# 5f/60f, itemCapacity 10, requirements
	# surge-alloy 1 / tungsten 1). NEITHER def sets
	# size (size 1 is the Block class default,
	# Block.java:215) or overrides the glow
	# (glowAlpha 1f / glowColor Pal.redLight,
	# StackConveyor.java:34-35). An unknown def id
	# falls back to the CLASS defaults (the N2304
	# fallback precedent): size 1 (Block.java:215),
	# speed 0f (StackConveyor.java:38),
	# itemCapacity 10 (StackConveyor.java:52),
	# glowAlpha 1f / glowColor Pal.redLight
	# (StackConveyor.java:34-35), NO requirements
	# (the Block default is the empty array,
	# Block.java:356), and health 40 -- the class
	# field is the -1 sentinel (Block.java:190),
	# which Block.init() (Block.java:1378-1394)
	# fills to round(size * size * scaledHealth, 5)
	# = 40. Pure-only: the caller reads it; the
	# advance / draw / stats pures take these
	# values as caller-supplied inputs and are
	# unchanged.

	# --- Def row: surge-conveyor -- size 1, speed
	# 5f/60f, itemCapacity 10, health 130, glowAlpha
	# 1f, glowColor Pal.redLight, requirements
	# surge-alloy 1 / tungsten 1.
	var surge: Dictionary = stack_conveyor_build_state.source_stack_conveyor_per_def_stats_state("surge-conveyor")
	var surge_requirements: Dictionary = surge.get("requirements", {})
	proof["stats_conveyor"] = int(surge.get("size", -1)) == 1 and is_equal_approx(float(surge.get("speed", -1.0)), 5.0 / 60.0) and int(surge.get("item_capacity", -1)) == 10 and int(surge.get("health", -1)) == 130 and is_equal_approx(float(surge.get("glow_alpha", -1.0)), 1.0) and str(surge.get("glow_color", "")) == "Pal.redLight" and surge_requirements.size() == 2 and int(surge_requirements.get("surge-alloy", -1)) == 1 and int(surge_requirements.get("tungsten", -1)) == 1

	# --- Speed / capacity: plastanium-conveyor
	# reels at 4f/60f, surge-conveyor at 5f/60f,
	# the class default is 0f; itemCapacity is 10
	# for both defs and the class.
	var plastanium: Dictionary = stack_conveyor_build_state.source_stack_conveyor_per_def_stats_state("plastanium-conveyor")
	var fallback: Dictionary = stack_conveyor_build_state.source_stack_conveyor_per_def_stats_state("no-such-def")
	proof["stats_speed_capacity"] = is_equal_approx(float(plastanium.get("speed", -1.0)), 4.0 / 60.0) and is_equal_approx(float(surge.get("speed", -1.0)), 5.0 / 60.0) and is_equal_approx(float(fallback.get("speed", -1.0)), 0.0) and int(plastanium.get("item_capacity", -1)) == 10 and int(surge.get("item_capacity", -1)) == 10 and int(fallback.get("item_capacity", -1)) == 10

	# --- Health / glow: plastanium-conveyor has
	# health 90, surge-conveyor 130, the class
	# fallback 40; the glow is glowAlpha 1f /
	# glowColor Pal.redLight for all three -- no
	# def overrides it.
	proof["stats_health_glow"] = int(plastanium.get("health", -1)) == 90 and int(surge.get("health", -1)) == 130 and int(fallback.get("health", -1)) == 40 and is_equal_approx(float(plastanium.get("glow_alpha", -1.0)), 1.0) and is_equal_approx(float(surge.get("glow_alpha", -1.0)), 1.0) and is_equal_approx(float(fallback.get("glow_alpha", -1.0)), 1.0) and str(plastanium.get("glow_color", "")) == "Pal.redLight" and str(surge.get("glow_color", "")) == "Pal.redLight" and str(fallback.get("glow_color", "")) == "Pal.redLight"

	# --- Requirements: plastanium-conveyor
	# carries exactly plastanium 1 / silicon 1 /
	# graphite 1, surge-conveyor exactly
	# surge-alloy 1 / tungsten 1; the class
	# fallback carries none.
	var plastanium_requirements: Dictionary = plastanium.get("requirements", {})
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	proof["stats_requirements"] = plastanium_requirements.size() == 3 and int(plastanium_requirements.get("plastanium", -1)) == 1 and int(plastanium_requirements.get("silicon", -1)) == 1 and int(plastanium_requirements.get("graphite", -1)) == 1 and surge_requirements.size() == 2 and int(surge_requirements.get("surge-alloy", -1)) == 1 and int(surge_requirements.get("tungsten", -1)) == 1 and fallback_requirements.is_empty()

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, speed 0f, itemCapacity 10, health
	# 40, glowAlpha 1f, glowColor Pal.redLight,
	# and NO requirements.
	var empty_fallback: Dictionary = stack_conveyor_build_state.source_stack_conveyor_per_def_stats_state("")
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("speed", -1.0)), 0.0) and int(fallback.get("item_capacity", -1)) == 10 and int(fallback.get("health", -1)) == 40 and is_equal_approx(float(fallback.get("glow_alpha", -1.0)), 1.0) and str(fallback.get("glow_color", "")) == "Pal.redLight" and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("speed", -1.0)), 0.0) and int(empty_fallback.get("item_capacity", -1)) == 10 and int(empty_fallback.get("health", -1)) == 40 and is_equal_approx(float(empty_fallback.get("glow_alpha", -1.0)), 1.0) and str(empty_fallback.get("glow_color", "")) == "Pal.redLight" and empty_requirements.is_empty()

	# --- Live input: the per-def rows feed the
	# N2457 stats pure as its caller-supplied
	# inputs -- plastanium-conveyor reads 40
	# items/second, surge-conveyor 50, the class
	# fallback 0.
	var plastanium_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(int(plastanium.get("item_capacity", 0)), float(plastanium.get("speed", 0.0)))
	var surge_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(int(surge.get("item_capacity", 0)), float(surge.get("speed", 0.0)))
	var fallback_stats: Dictionary = stack_conveyor_build_state.source_stack_conveyor_stats_state(int(fallback.get("item_capacity", 0)), float(fallback.get("speed", 0.0)))
	proof["stats_live_input"] = int(plastanium_stats.get("items_moved_per_second", -1)) == 40 and int(surge_stats.get("items_moved_per_second", -1)) == 50 and int(fallback_stats.get("items_moved_per_second", -1)) == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07StackConveyorPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
