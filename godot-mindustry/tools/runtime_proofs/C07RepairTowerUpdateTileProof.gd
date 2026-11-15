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

	# --- Pure updateTile advance (N2227):
	# RepairTowerBuild.updateTile() (RepairTower.java:57-86) --
	# the refresh cadence + clear (`if(potentialEfficiency > 0
	# && (refresh += Time.delta) >= refreshInterval){` with
	# refreshInterval 6f, then `targets.clear();` and `refresh =
	# 0f;`), the suppression early return
	# (`if(checkSuppression()){ warmup = 0f; return; }`), the
	# heal loop (`target.heal(healAmount * edelta());` per
	# damaged target, with `any = true;`), the warmup lerp
	# (0.08f toward any ? efficiency : 0f), and the
	# totalProgress advance (`totalProgress += Time.delta /
	# circleSpeed;` with circleSpeed 120f). The refresh /
	# totalProgress advances and the warmup lerp use the
	# UNSCALED Time.delta (Arc Mathf.java:430-432, `return
	# lerp(fromValue, toValue, clamp(progress *
	# Time.delta));`); only the heal amount uses the SCALED
	# edelta() (`return efficiency * delta();`,
	# BuildingComp.java:1927-1929, with `return Time.delta *
	# timeScale;`, BuildingComp.java:1922-1924). The live
	# Units.nearby scan is deferred: the refill is a supplied
	# damaged list parameter. A target entry without a
	# `damaged` key counts as damaged (the scan only admits
	# damaged units, RepairTower.java:63-64). All pure calls
	# below use the def heal amount 1.5f (Blocks.java:6580),
	# the class circle speed 120f (RepairTower.java:23), and
	# time_delta 1.0 (one tick at 60fps) unless noted.
	var refresh_at: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"refresh": 5.0, "potential_efficiency": 1.0, "targets": [{"type": "dart"}], "efficiency": 0.0}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}, {"type": "horizon"}])
	var refresh_at_targets: Array = refresh_at.get("targets", [])
	var refresh_before: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"refresh": 0.0, "potential_efficiency": 1.0, "targets": [{"type": "dart"}], "efficiency": 0.0}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}])
	var refresh_before_targets: Array = refresh_before.get("targets", [])
	var refresh_blocked: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"refresh": 5.0, "potential_efficiency": 0.0, "targets": [{"type": "dart"}], "efficiency": 0.0}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}])
	var refresh_default_potential: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"refresh": 5.0, "efficiency": 1.0, "targets": [{"type": "dart"}]}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}])
	var refresh_default_targets: Array = refresh_default_potential.get("targets", [])
	proof["refresh_clears_targets_at_interval"] = is_equal_approx(float(refresh_at.get("refresh", -1.0)), 0.0) and refresh_at_targets.size() == 2 and str(refresh_at_targets[0].get("type", "")) == "flare" and is_equal_approx(float(refresh_before.get("refresh", -1.0)), 1.0) and refresh_before_targets.size() == 1 and str(refresh_before_targets[0].get("type", "")) == "dart" and is_equal_approx(float(refresh_blocked.get("refresh", -1.0)), 5.0) and is_equal_approx(float(refresh_default_potential.get("refresh", -1.0)), 0.0) and refresh_default_targets.size() == 1 and str(refresh_default_targets[0].get("type", "")) == "flare"

	var warmup_healing: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"warmup": 0.0, "efficiency": 0.5, "targets": [{"type": "dart", "damaged": true}]}, 1.5, 120.0, 1.0)
	var warmup_no_targets: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"warmup": 1.0, "efficiency": 0.5, "targets": []}, 1.5, 120.0, 1.0)
	var warmup_undamaged: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"warmup": 1.0, "efficiency": 0.5, "targets": [{"type": "dart", "damaged": false}]}, 1.5, 120.0, 1.0)
	var warmup_pure_ok: bool = is_equal_approx(float(warmup_healing.get("warmup", -1.0)), 0.04) and is_equal_approx(float(warmup_no_targets.get("warmup", -1.0)), 0.92) and is_equal_approx(float(warmup_undamaged.get("warmup", -1.0)), 0.92)

	var suppressed_frame: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"warmup": 1.0, "total_progress": 2.0, "efficiency": 1.0, "potential_efficiency": 1.0, "refresh": 5.0, "targets": [{"type": "dart"}], "heal_suppressed": true}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}])
	var suppressed_targets: Array = suppressed_frame.get("targets", [])
	var suppressed_amounts: Array = suppressed_frame.get("heal_amounts", [-1.0])
	var unsuppressed_frame: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"warmup": 1.0, "total_progress": 2.0, "efficiency": 1.0, "potential_efficiency": 1.0, "refresh": 5.0, "targets": [{"type": "dart"}], "heal_suppressed": false}, 1.5, 120.0, 1.0, 1.0, [{"type": "flare"}])
	proof["warmup_zero_when_suppressed"] = is_equal_approx(float(suppressed_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(suppressed_frame.get("total_progress", -1.0)), 2.0) and suppressed_amounts.is_empty() and is_equal_approx(float(suppressed_frame.get("refresh", -1.0)), 0.0) and suppressed_targets.size() == 1 and str(suppressed_targets[0].get("type", "")) == "flare" and is_equal_approx(float(unsuppressed_frame.get("warmup", -1.0)), 1.0) and float(unsuppressed_frame.get("total_progress", -1.0)) > 2.0

	var progress_frame: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"total_progress": 0.0, "efficiency": 0.0}, 1.5, 120.0, 1.0)
	var progress_long: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"total_progress": 1.0, "efficiency": 0.0}, 1.5, 120.0, 3.0)
	proof["total_progress_advances"] = is_equal_approx(float(progress_frame.get("total_progress", -1.0)), 1.0 / 120.0) and is_equal_approx(float(progress_long.get("total_progress", -1.0)), 1.025)

	var heal_frame: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"efficiency": 0.5, "targets": [{"type": "dart", "damaged": true}, {"type": "flare", "damaged": true}]}, 1.5, 120.0, 1.0)
	var heal_amounts: Array = heal_frame.get("heal_amounts", [])
	var heal_scaled: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"efficiency": 0.5, "targets": [{"type": "dart", "damaged": true}, {"type": "flare", "damaged": true}]}, 1.5, 120.0, 1.0, 2.0)
	var heal_scaled_amounts: Array = heal_scaled.get("heal_amounts", [])
	var heal_class_amount: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"efficiency": 0.5, "targets": [{"type": "dart", "damaged": true}]}, 1.0, 120.0, 1.0)
	var heal_class_amounts: Array = heal_class_amount.get("heal_amounts", [])
	var heal_partial: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"efficiency": 0.5, "targets": [{"type": "dart", "damaged": true}, {"type": "flare", "damaged": false}]}, 1.5, 120.0, 1.0)
	var heal_partial_amounts: Array = heal_partial.get("heal_amounts", [])
	var heal_unpowered: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({"efficiency": 0.0, "targets": [{"type": "dart", "damaged": true}]}, 1.5, 120.0, 1.0)
	var heal_unpowered_amounts: Array = heal_unpowered.get("heal_amounts", [-1.0])
	proof["heal_amounts_fold_heal_amount_edelta"] = heal_amounts.size() == 2 and is_equal_approx(float(heal_amounts[0]), 0.75) and is_equal_approx(float(heal_amounts[1]), 0.75) and heal_scaled_amounts.size() == 2 and is_equal_approx(float(heal_scaled_amounts[0]), 1.5) and heal_class_amounts.size() == 1 and is_equal_approx(float(heal_class_amounts[0]), 0.5) and heal_partial_amounts.size() == 1 and is_equal_approx(float(heal_partial_amounts[0]), 0.75) and heal_unpowered_amounts.is_empty()

	var defaults_frame: Dictionary = repair_tower_build_state.source_repair_tower_update_tile_advance_state({}, 1.5, 120.0, 1.0)
	var defaults_targets: Array = defaults_frame.get("targets", [-1])
	var defaults_amounts: Array = defaults_frame.get("heal_amounts", [-1.0])
	proof["frame_defaults_zero"] = is_equal_approx(float(defaults_frame.get("refresh", -1.0)), 0.0) and is_equal_approx(float(defaults_frame.get("warmup", -1.0)), 0.0) and defaults_targets.is_empty() and defaults_amounts.is_empty() and is_equal_approx(float(defaults_frame.get("total_progress", -1.0)), 1.0 / 120.0)

	# --- Live tick: the repair tower is a RepairTower build
	# with a power consumer (consumePower 1f), placed live;
	# the tick driver is called directly (as the N2147/N2148/
	# N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/
	# N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/
	# N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176 proofs
	# do), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. Half power with one
	# damaged target in range: efficiency folds the power min
	# 0.5 (the N2176 power fold preserved, the N2213 gate
	# open), and the live advance follows it: warmup 0 ->
	# 0.04 toward 0.5, totalProgress 0 -> 1/120, heal amounts
	# [0.75] (healAmount 1.5f * edelta 0.5).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_tower_cell := Vector2i(28, 20)
	var repair_tower := Sprite2D.new()
	game.add_child(repair_tower)
	game.call("record_placed_block", repair_tower, blocks_by_id["unit-repair-tower"], repair_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the targets on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(repair_tower, blocks_by_id["unit-repair-tower"])
	var repair_tower_frame: Dictionary = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})

	repair_tower_frame["targets"] = [{"type": "dart"}]
	repair_tower_frame["power_status"] = 0.5
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	var live_amounts: Array = repair_tower_frame.get("heal_amounts", [])
	proof["warmup_approaches_efficiency_when_healing"] = warmup_pure_ok and is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(repair_tower_frame.get("warmup", -1.0)), 0.04) and is_equal_approx(float(repair_tower_frame.get("total_progress", -1.0)), 1.0 / 120.0) and live_amounts.size() == 1 and is_equal_approx(float(live_amounts[0]), 0.75)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
