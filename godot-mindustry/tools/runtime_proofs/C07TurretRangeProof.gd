extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Turret range() / minRange() / trackingRange() accessors
	# (N2526): `public float minRange(){` /
	# `if(peekAmmo() != null){` /
	# `return minRange + peekAmmo().minRangeChange;` /
	# `return minRange;` (Turret.java:334-338) /
	# `public float range(){` /
	# `if(peekAmmo() != null){` /
	# `return range + peekAmmo().rangeChange;` /
	# `return range;` (:340-346) /
	# `public float trackingRange(){` /
	# `return range() + trackingRange - range;` (:348-350),
	# with the init() normalization (`trackingRange =
	# Math.max(range, trackingRange);`, :217-219) folded into
	# the function so a raw catalog trackingRange of 0f (the
	# class default, Turret.java:72 -- no def records it)
	# does not shrink the tracking range below range().
	# `has_peek_ammo` is `peekAmmo() != null`, NOT hasAmmo()
	# (Turret.java:705-708). The proof drives the pure
	# function on exact catalog values (duo range 160,
	# graphite rangeChange 16, ripple range 290 / minRange
	# 50, smite range 300 / trackingRange 420 = 300 * 1.4,
	# malign range 410 / trackingRange 574 = 410 * 1.4 --
	# all exact-binary floats, so the equalities are exact):
	# 1 duo copper (no rangeChange) keeps 160 / 0 / 160,
	# 2 duo graphite adds 16 -> 176 / 0 / 176, 3 duo
	# silicon (no rangeChange) keeps 160 / 0 / 160,
	# 4 ripple keeps minRange 50 with no ammo -> 290 / 50 /
	# 290, 5 smite trackingRange 1.4x -> 300 / 0 / 420,
	# 6 malign trackingRange 1.4x -> 410 / 0 / 574, 7 the
	# no-ammo branch ignores nonzero changes, 8 the
	# minRangeChange fold with ammo (synthetic 8.0 -- no def
	# sets minRangeChange today, so the value exercises the
	# formula only, it is NOT a catalog fact).
	var frame: Dictionary = {}

	# Phase 1: duo copper -- no rangeChange, no minRangeChange.
	var ranges: Dictionary = turret_build_state.source_turret_range_state(frame, 160.0, 0.0, 0.0, true, 0.0, 0.0)
	proof["range_duo_copper_no_change"] = float(ranges.get("range", -1.0)) == 160.0 and float(ranges.get("min_range", -1.0)) == 0.0 and float(ranges.get("tracking_range", -1.0)) == 160.0

	# Phase 2: duo graphite -- rangeChange 16f
	# (Blocks.java:3276).
	ranges = turret_build_state.source_turret_range_state(frame, 160.0, 0.0, 0.0, true, 16.0, 0.0)
	proof["range_duo_graphite_adds_16"] = float(ranges.get("range", -1.0)) == 176.0 and float(ranges.get("min_range", -1.0)) == 0.0 and float(ranges.get("tracking_range", -1.0)) == 176.0

	# Phase 3: duo silicon -- reloadMultiplier 1.5f but no
	# rangeChange (Blocks.java:3259-3295).
	ranges = turret_build_state.source_turret_range_state(frame, 160.0, 0.0, 0.0, true, 0.0, 0.0)
	proof["range_duo_silicon_no_change"] = float(ranges.get("range", -1.0)) == 160.0 and float(ranges.get("min_range", -1.0)) == 0.0 and float(ranges.get("tracking_range", -1.0)) == 160.0

	# Phase 4: ripple -- range 290f, minRange 50f
	# (Blocks.java:4076), no ammo.
	ranges = turret_build_state.source_turret_range_state(frame, 290.0, 50.0, 0.0, false, 0.0, 0.0)
	proof["range_ripple_min_range_50"] = float(ranges.get("range", -1.0)) == 290.0 and float(ranges.get("min_range", -1.0)) == 50.0 and float(ranges.get("tracking_range", -1.0)) == 290.0

	# Phase 5: smite -- range 300, trackingRange = range *
	# 1.4f = 420 (Blocks.java:5913).
	ranges = turret_build_state.source_turret_range_state(frame, 300.0, 0.0, 420.0, false, 0.0, 0.0)
	proof["range_smite_tracking_1_4x"] = float(ranges.get("range", -1.0)) == 300.0 and float(ranges.get("min_range", -1.0)) == 0.0 and float(ranges.get("tracking_range", -1.0)) == 420.0

	# Phase 6: malign -- range 410, trackingRange = range *
	# 1.4f = 574 (Blocks.java:6256).
	ranges = turret_build_state.source_turret_range_state(frame, 410.0, 0.0, 574.0, false, 0.0, 0.0)
	proof["range_malign_tracking_1_4x"] = float(ranges.get("range", -1.0)) == 410.0 and float(ranges.get("min_range", -1.0)) == 0.0 and float(ranges.get("tracking_range", -1.0)) == 574.0

	# Phase 7: no ammo -- nonzero changes are ignored, the
	# def values come through unchanged.
	ranges = turret_build_state.source_turret_range_state(frame, 160.0, 50.0, 0.0, false, 16.0, 8.0)
	proof["range_no_ammo_branch"] = float(ranges.get("range", -1.0)) == 160.0 and float(ranges.get("min_range", -1.0)) == 50.0 and float(ranges.get("tracking_range", -1.0)) == 160.0

	# Phase 8: minRangeChange folds with ammo -- synthetic
	# 8.0 (no def sets minRangeChange today).
	ranges = turret_build_state.source_turret_range_state(frame, 290.0, 50.0, 0.0, true, 0.0, 8.0)
	proof["range_min_range_change_adds_with_ammo"] = float(ranges.get("range", -1.0)) == 290.0 and float(ranges.get("min_range", -1.0)) == 58.0 and float(ranges.get("tracking_range", -1.0)) == 290.0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretRangeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
