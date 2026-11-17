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

	# --- RepairTower setStats() (N2230):
	# RepairTower.setStats() (RepairTower.java:35-41,
	# `public void setStats(){`) adds two stat rows
	# unconditionally (`stats.add(Stat.range, range /
	# tilesize, StatUnit.blocks);` -- :38 -- and
	# `stats.add(Stat.repairSpeed, healAmount * 60f,
	# StatUnit.perSecond);` -- :39).
	# `super.setStats();` (:37) is Block-level stat work
	# (N1696), NOT this slice. Class defaults: range 80f /
	# healAmount 1f (RepairTower.java:21, :24);
	# unit-repair-tower 100f / 1.5f (Blocks.java:6579-6580);
	# tilesize is 8 (Vars.java:135). There is no driver
	# tick line: setStats is a stat-display read, not a
	# tick write (the N2224 RepairTurret setStats
	# precedent); the proof calls the pure function
	# directly with per-def params.

	# Range at the catalog def (100f / 8 = 12.5 blocks).
	var catalog: Dictionary = repair_tower_build_state.source_repair_tower_set_stats_state(100.0, 1.5, 8.0)
	var catalog_stats: Array = catalog.get("stats", [])
	proof["range_in_blocks"] = catalog_stats.size() == 2 and str(catalog_stats[0].get("stat", "")) == "range" and str(catalog_stats[0].get("unit", "")) == "blocks" and is_equal_approx(float(catalog_stats[0].get("value", 0.0)), 12.5)

	# Repair speed at the catalog def (1.5f * 60 = 90 per second).
	proof["repair_speed_per_second"] = catalog_stats.size() == 2 and str(catalog_stats[1].get("stat", "")) == "repairSpeed" and str(catalog_stats[1].get("unit", "")) == "perSecond" and is_equal_approx(float(catalog_stats[1].get("value", 0.0)), 90.0)

	# Class defaults via params (80f / 1f -> 10 blocks / 60
	# per second), proving the function does not hardcode
	# the catalog def.
	var defaults: Dictionary = repair_tower_build_state.source_repair_tower_set_stats_state(80.0, 1.0, 8.0)
	var defaults_stats: Array = defaults.get("stats", [])
	proof["class_defaults_via_params"] = defaults_stats.size() == 2 and is_equal_approx(float(defaults_stats[0].get("value", 0.0)), 10.0) and is_equal_approx(float(defaults_stats[1].get("value", 0.0)), 60.0)

	# No driver tick line: the proof reads the state script
	# source and greps the driver body -- a runtime check,
	# not a hardcoded true.
	var source_text: String = FileAccess.get_file_as_string("res://src/game/SourceRepairTowerBuildState.gd")
	var driver_start: int = source_text.find("static func source_repair_tower_tick_buildings_state")
	var driver_end: int = source_text.find("\nstatic func ", driver_start + 1)
	var driver_body: String = source_text.substr(driver_start, driver_end - driver_start) if driver_end != -1 else source_text.substr(driver_start)
	proof["no_driver_tick_line"] = driver_start != -1 and not driver_body.contains("source_repair_tower_set_stats_state")

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerSetStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
