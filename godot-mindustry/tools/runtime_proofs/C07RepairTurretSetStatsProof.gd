extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- RepairTurret setStats() (N2224):
	# RepairTurret.setStats() (RepairTurret.java:75-84,
	# `public void setStats(){`) adds two stat rows
	# unconditionally (`stats.add(Stat.range, repairRadius /
	# tilesize, StatUnit.blocks);` -- :77 -- and
	# `stats.add(Stat.repairSpeed, repairSpeed * 60f,
	# StatUnit.perSecond);` -- :78) and, only when the def
	# accepts coolant, replaces the booster row
	# (`if(acceptCoolant){` -- :80 --
	# `stats.remove(Stat.booster);` -- :81 --
	# `stats.add(Stat.booster, StatValues.speedBoosters(
	# Core.bundle.get("bar.strength"), coolantUse,
	# coolantMultiplier, true, this::consumesLiquid));`
	# -- :82). Class defaults: repairRadius 50f /
	# repairSpeed 0.3f / acceptCoolant false / coolantUse 0.5f
	# / coolantMultiplier 1f (RepairTurret.java:32, :33, :40,
	# :42, :45); repair-point 60f / 0.45f (Blocks.java:6389,
	# :6388); repair-turret 145f / 3f / acceptCoolant true /
	# coolantUse 0.16f / coolantMultiplier 1.6f
	# (Blocks.java:6401, :6400, :6404, :6405, :6406); tilesize
	# is 8 (Vars.java:135). There is no driver tick line:
	# setStats is a stat-display read, not a tick write.

	# Range at the class-default radius (50f / 8 = 6.25 blocks).
	var range_default: Dictionary = repair_turret_build_state.source_repair_turret_set_stats_state(50.0, 0.3, false, 0.5, 1.0, 8.0)
	proof["set_stats_range_default_radius"] = is_equal_approx(float(range_default.get("range_blocks", 0.0)), 6.25)

	# Range at the repair-point radius (60f / 8 = 7.5 blocks).
	var range_point: Dictionary = repair_turret_build_state.source_repair_turret_set_stats_state(60.0, 0.45, false, 0.5, 1.0, 8.0)
	proof["set_stats_range_repair_point"] = is_equal_approx(float(range_point.get("range_blocks", 0.0)), 7.5)

	# Range at the repair-turret radius (145f / 8 = 18.125 blocks).
	var range_turret: Dictionary = repair_turret_build_state.source_repair_turret_set_stats_state(145.0, 3.0, true, 0.16, 1.6, 8.0)
	proof["set_stats_range_repair_turret"] = is_equal_approx(float(range_turret.get("range_blocks", 0.0)), 18.125)

	# Repair speed at the class-default rate (0.3f * 60 = 18.0 per second).
	proof["set_stats_repair_speed_default"] = is_equal_approx(float(range_default.get("repair_speed_per_second", 0.0)), 18.0)

	# Repair speed at the repair-point rate (0.45f * 60 = 27.0 per second).
	proof["set_stats_repair_speed_repair_point"] = is_equal_approx(float(range_point.get("repair_speed_per_second", 0.0)), 27.0)

	# Repair speed at the repair-turret rate (3f * 60 = 180.0 per second).
	proof["set_stats_repair_speed_repair_turret"] = is_equal_approx(float(range_turret.get("repair_speed_per_second", 0.0)), 180.0)

	# No booster row at the class default (acceptCoolant false).
	proof["set_stats_booster_absent_default"] = not bool(range_default.get("booster_present", true))

	# Booster row present at the repair-turret def (coolantUse 0.16f, coolantMultiplier 1.6f).
	proof["set_stats_booster_repair_turret"] = bool(range_turret.get("booster_present", false)) and is_equal_approx(float(range_turret.get("booster_coolant_use", 0.0)), 0.16) and is_equal_approx(float(range_turret.get("booster_coolant_multiplier", 0.0)), 1.6)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretSetStatsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
