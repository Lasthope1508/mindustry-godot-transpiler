extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mend_projector_build_state := preload("res://src/game/SourceMendProjectorBuildState.gd")
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

	# --- Pure heal scan (N2242): MendBuild.updateTile() heal
	# branch (MendProjector.java:106-122) -- the realRange fold
	# (`float realRange = range + phaseHeat * phaseRangeBoost;`),
	# the indexer scan predicate (damaged + not heal-suppressed),
	# the heal formula (`other.heal(other.maxHealth() *
	# (healPercent + phaseHeat * phaseBoost) / 100f *
	# efficiency);`), the `any` flag, and the branch-taken flag.
	# The port has no indexer, so the scan takes its candidate
	# list explicit (each candidate: max_health, damaged,
	# heal_suppressed); the N2193 advance already reset the
	# frame charge, so the scan recomputes the crossing from
	# charge_before + heat_after * time_delta * time_scale.
	# All pure calls below use time_delta 1.0 (one tick at
	# 60fps) and the mender defs (reload 200f, range 40f,
	# healPercent 4f, phaseBoost 4f, phaseRangeBoost 20f,
	# Blocks.java:1923-1927) unless noted.
	var charged_frame: Dictionary = {"phase_heat": 0.5, "heat": 1.0, "efficiency": 1.0}
	var range_half: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(charged_frame, [], 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var range_zero: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.0, "heat": 1.0, "efficiency": 1.0}, [], 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var range_projector: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 1.0, "heat": 1.0, "efficiency": 1.0}, [], 249.5, 250.0, 85.0, 11.0, 15.0, 50.0, 1.0)
	proof["real_range_folds_phase_heat"] = is_equal_approx(float(range_half.get("real_range", -1.0)), 50.0) and is_equal_approx(float(range_zero.get("real_range", -1.0)), 40.0) and is_equal_approx(float(range_projector.get("real_range", -1.0)), 135.0)

	var one_target: Array = [{"max_health": 100.0, "damaged": true, "heal_suppressed": false}]
	var heal_full: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state(charged_frame, one_target, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var heal_half_power: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.5, "heat": 1.0, "efficiency": 0.5}, one_target, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var heal_projector: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 1.0, "heat": 1.0, "efficiency": 1.0}, [{"max_health": 200.0, "damaged": true, "heal_suppressed": false}], 249.5, 250.0, 85.0, 11.0, 15.0, 50.0, 1.0)
	var amounts_full: Array = heal_full.get("heal_amounts", [])
	var amounts_half: Array = heal_half_power.get("heal_amounts", [])
	var amounts_projector: Array = heal_projector.get("heal_amounts", [])
	proof["heal_amount_formula"] = bool(heal_full.get("scanned", false)) and bool(heal_full.get("any", false)) and amounts_full.size() == 1 and is_equal_approx(float(amounts_full[0]), 6.0) and amounts_half.size() == 1 and is_equal_approx(float(amounts_half[0]), 3.0) and amounts_projector.size() == 1 and is_equal_approx(float(amounts_projector[0]), 52.0)

	var mixed_damage: Array = [{"max_health": 100.0, "damaged": true, "heal_suppressed": false}, {"max_health": 100.0, "damaged": false, "heal_suppressed": false}]
	var no_damage: Array = [{"max_health": 100.0, "damaged": false, "heal_suppressed": false}]
	var damaged_only: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.0, "heat": 1.0, "efficiency": 1.0}, mixed_damage, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var undamaged_only: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.0, "heat": 1.0, "efficiency": 1.0}, no_damage, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var amounts_damaged: Array = damaged_only.get("heal_amounts", [])
	var amounts_undamaged: Array = undamaged_only.get("heal_amounts", [])
	proof["damaged_only_predicate"] = bool(damaged_only.get("scanned", false)) and bool(damaged_only.get("any", false)) and amounts_damaged.size() == 1 and is_equal_approx(float(amounts_damaged[0]), 4.0) and bool(undamaged_only.get("scanned", false)) and not bool(undamaged_only.get("any", true)) and amounts_undamaged.is_empty()

	var mixed_suppressed: Array = [{"max_health": 100.0, "damaged": true, "heal_suppressed": true}, {"max_health": 100.0, "damaged": true, "heal_suppressed": false}]
	var all_suppressed: Array = [{"max_health": 100.0, "damaged": true, "heal_suppressed": true}]
	var suppressed_mixed: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.0, "heat": 1.0, "efficiency": 1.0}, mixed_suppressed, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var suppressed_all: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.0, "heat": 1.0, "efficiency": 1.0}, all_suppressed, 199.5, 200.0, 40.0, 4.0, 4.0, 4.0, 20.0, 1.0)
	var amounts_mixed_suppressed: Array = suppressed_mixed.get("heal_amounts", [])
	var amounts_all_suppressed: Array = suppressed_all.get("heal_amounts", [])
	proof["heal_suppressed_excluded"] = bool(suppressed_mixed.get("scanned", false)) and bool(suppressed_mixed.get("any", false)) and amounts_mixed_suppressed.size() == 1 and is_equal_approx(float(amounts_mixed_suppressed[0]), 4.0) and bool(suppressed_all.get("scanned", false)) and not bool(suppressed_all.get("any", true)) and amounts_all_suppressed.is_empty()

	var below_reload: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.5, "heat": 1.0, "efficiency": 1.0}, one_target, 10.0, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0)
	var charged_suppressed: Dictionary = mend_projector_build_state.source_mend_projector_heal_scan_state({"phase_heat": 0.5, "heat": 1.0, "efficiency": 1.0}, one_target, 199.5, 200.0, 40.0, 4.0, 4.0, 20.0, 1.0, 1.0, false)
	var amounts_below: Array = below_reload.get("heal_amounts", [])
	var amounts_charged_suppressed: Array = charged_suppressed.get("heal_amounts", [])
	proof["no_scan_below_reload"] = not bool(below_reload.get("scanned", true)) and not bool(below_reload.get("any", true)) and amounts_below.is_empty() and not bool(charged_suppressed.get("scanned", true)) and not bool(charged_suppressed.get("any", true)) and amounts_charged_suppressed.is_empty()

	# --- Live tick: the mender is a MendProjector with a power
	# consumer (consumePower 0.3f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/N2150/
	# N2153/N2154/N2155/N2156 proofs do), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Full power
	# with a charged frame (charge 199.5, heat 1.0): the N2193
	# advance resets the charge to 0, and the N2242 scan runs
	# right after it (scanned true) with the per-def mender
	# params from the block properties (range 40f,
	# phaseRangeBoost 20f) -- with no indexer candidates the
	# live tick heals nothing (any false), so the key proves
	# the scan branch runs and folds the live phase_heat,
	# while the pure keys above prove the heals.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var projector_cell := Vector2i(28, 20)
	var projector := Sprite2D.new()
	game.add_child(projector)
	game.call("record_placed_block", projector, blocks_by_id["mender"], projector_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	mend_projector_build_state.source_mend_projector_bind_frame_state(projector, blocks_by_id["mender"])
	var projector_frame: Dictionary = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})

	projector_frame["power_status"] = 1.0
	projector_frame["charge"] = 199.5
	projector_frame["heat"] = 1.0
	projector_frame["phase_heat"] = 0.0
	mend_projector_build_state.source_mend_projector_tick_buildings_state(game, 1.0 / 60.0)
	projector_frame = projector.get_meta(mend_projector_build_state.SOURCE_MEND_PROJECTOR_BUILDING_META_KEY, {})
	var live_scan: Dictionary = projector_frame.get("last_heal_scan", {})
	var live_phase_heat: float = float(projector_frame.get("phase_heat", -1.0))
	proof["live_tick_scans_when_charged"] = is_equal_approx(float(projector_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(projector_frame.get("charge", -1.0)), 0.0) and bool(live_scan.get("scanned", false)) and not bool(live_scan.get("any", true)) and is_equal_approx(float(live_scan.get("real_range", -1.0)), 40.0 + live_phase_heat * 20.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MendProjectorHealScanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
