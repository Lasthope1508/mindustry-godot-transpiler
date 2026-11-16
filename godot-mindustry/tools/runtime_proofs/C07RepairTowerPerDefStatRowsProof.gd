extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- Per-def stat rows (N2490): the VERIFICATION
	# slice -- the values are already constants in
	# the driver header (the N2304 / N2442
	# precedent). The single RepairTower def
	# unit-repair-tower (Blocks.java:6575-6583)
	# sets size 2, range 100f, healAmount 1.5f and
	# requirements graphite 90 / silicon 90 /
	# tungsten 80. An unknown def id falls back to
	# the CLASS defaults (the N2304 fallback
	# precedent): size 1 (Block.java:215), range
	# 80f (RepairTower.java:21), healAmount 1f
	# (RepairTower.java:24) and NO requirements
	# (the Block default is the empty array,
	# Block.java:356). Pure-only: the caller reads
	# it; the advance + shouldConsume pures take
	# these values as caller-supplied inputs and
	# are unchanged.

	# --- Def row: unit-repair-tower -- size 2,
	# range 100f, healAmount 1.5f, requirements
	# graphite 90 / silicon 90 / tungsten 80.
	var tower: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("unit-repair-tower")
	var tower_requirements: Dictionary = tower.get("requirements", {})
	proof["stats_tower"] = int(tower.get("size", -1)) == 2 and is_equal_approx(float(tower.get("range_value", -1.0)), 100.0) and is_equal_approx(float(tower.get("heal_amount", -1.0)), 1.5) and int(tower_requirements.get("graphite", -1)) == 90 and int(tower_requirements.get("silicon", -1)) == 90 and int(tower_requirements.get("tungsten", -1)) == 80

	# --- Class fallback: an unknown def id (and
	# the empty id) returns the CLASS defaults --
	# size 1, range 80f, healAmount 1f, and NO
	# requirements.
	var fallback: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("no-such-def")
	var empty_fallback: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("")
	var fallback_requirements: Dictionary = fallback.get("requirements", {"x": 1})
	var empty_requirements: Dictionary = empty_fallback.get("requirements", {"x": 1})
	proof["stats_class_fallback"] = int(fallback.get("size", -1)) == 1 and is_equal_approx(float(fallback.get("range_value", -1.0)), 80.0) and is_equal_approx(float(fallback.get("heal_amount", -1.0)), 1.0) and fallback_requirements.is_empty() and int(empty_fallback.get("size", -1)) == 1 and is_equal_approx(float(empty_fallback.get("range_value", -1.0)), 80.0) and is_equal_approx(float(empty_fallback.get("heal_amount", -1.0)), 1.0) and empty_requirements.is_empty()

	# --- Heal / range: the def heals 1.5f over
	# 100f while the class defaults heal 1f over
	# 80f -- the def overrides BOTH class fields.
	proof["stats_heal_range"] = is_equal_approx(float(tower.get("heal_amount", -1.0)), 1.5) and is_equal_approx(float(tower.get("range_value", -1.0)), 100.0) and is_equal_approx(float(fallback.get("heal_amount", -1.0)), 1.0) and is_equal_approx(float(fallback.get("range_value", -1.0)), 80.0)

	# --- Requirements: the def dict carries
	# exactly the three items (graphite 90,
	# silicon 90, tungsten 80); the class
	# fallback carries none.
	proof["stats_requirements"] = tower_requirements.size() == 3 and int(tower_requirements.get("graphite", -1)) == 90 and int(tower_requirements.get("silicon", -1)) == 90 and int(tower_requirements.get("tungsten", -1)) == 80 and fallback_requirements.is_empty()

	# --- Size: the def is size 2, the class
	# default is size 1.
	proof["stats_size"] = int(tower.get("size", -1)) == 2 and int(fallback.get("size", -1)) == 1

	# --- Live input: the per-def rows feed the
	# N2428 stats pure as its caller-supplied
	# inputs -- the def range 100f reads 12.5
	# blocks and the def healAmount 1.5f reads 90
	# per second, while the class fallback reads
	# 10 blocks and 60 per second.
	var tower_stats: Dictionary = repair_tower_build_state.source_repair_tower_stats_state(float(tower.get("range_value", 0.0)), float(tower.get("heal_amount", 0.0)), 0.5)
	var fallback_stats: Dictionary = repair_tower_build_state.source_repair_tower_stats_state(float(fallback.get("range_value", 0.0)), float(fallback.get("heal_amount", 0.0)), 0.5)
	var tower_range_blocks: Dictionary = tower_stats.get("range_blocks", {})
	var tower_repair: Dictionary = tower_stats.get("repair_per_second", {})
	var fallback_range_blocks: Dictionary = fallback_stats.get("range_blocks", {})
	var fallback_repair: Dictionary = fallback_stats.get("repair_per_second", {})
	proof["stats_live_input"] = is_equal_approx(float(tower_range_blocks.get("value", -1.0)), 12.5) and is_equal_approx(float(tower_repair.get("value", -1.0)), 90.0) and is_equal_approx(float(fallback_range_blocks.get("value", -1.0)), 10.0) and is_equal_approx(float(fallback_repair.get("value", -1.0)), 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerPerDefStatRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
