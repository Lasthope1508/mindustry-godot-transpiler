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

	# --- RepairTower per-def stat rows (N2238):
	# unit-repair-tower range 100f (`range = 100f;`,
	# Blocks.java:6579), healAmount 1.5f (`healAmount = 1.5f;`,
	# Blocks.java:6580), size 2 (`size = 2;`,
	# Blocks.java:6578); class defaults range 80f
	# (`public float range = 80f;`, RepairTower.java:21),
	# healAmount 1f (`public float healAmount = 1f;`,
	# RepairTower.java:24), size 1 (`public int size = 1;`,
	# Block.java:215). There is no driver tick line: a
	# static read (the N2233 range / N2235 ambient volume /
	# N2237 precedent).

	# Stats at the unit-repair-tower def.
	var stats_tower: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("unit-repair-tower")
	proof["stats_unit_repair_tower"] = is_equal_approx(float(stats_tower.get("range", -1.0)), 100.0) and is_equal_approx(float(stats_tower.get("heal_amount", -1.0)), 1.5) and int(stats_tower.get("size", -1)) == 2

	# Stats at an unknown def (class defaults).
	var stats_default: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("unknown-def")
	proof["stats_class_default"] = is_equal_approx(float(stats_default.get("range", -1.0)), 80.0) and is_equal_approx(float(stats_default.get("heal_amount", -1.0)), 1.0) and int(stats_default.get("size", -1)) == 1

	# Stats at the empty id (class defaults).
	var stats_empty: Dictionary = repair_tower_build_state.source_repair_tower_per_def_stats_state("")
	proof["stats_empty_defaults"] = is_equal_approx(float(stats_empty.get("range", -1.0)), 80.0) and is_equal_approx(float(stats_empty.get("heal_amount", -1.0)), 1.0) and int(stats_empty.get("size", -1)) == 1

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTowerBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_tower_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["has_no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_tower_per_def_stats_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerPerDefStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
