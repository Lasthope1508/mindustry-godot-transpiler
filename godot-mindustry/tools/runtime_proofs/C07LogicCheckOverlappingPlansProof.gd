extends Node

const game_loop_state := preload("res://src/game/SourceGameLoopRuntimeState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _ready() -> void:
	var proof: Dictionary = {}

	# --- Logic.checkOverlappingPlans() (Logic.java:255-266):
	# `TeamData data = team.data();` +
	# `Iterator<BlockPlan> it = data.plans.iterator();` +
	# `var bounds = tile.block().bounds(tile.x, tile.y, Tmp.r1);`
	# + `while(it.hasNext()){` + `BlockPlan b = it.next();` +
	# `if(bounds.overlaps(b.block.bounds(b.x, b.y, Tmp.r2))){` +
	# `b.removed = true;` + `it.remove();` — plans whose block
	# bounds overlap the tile block's bounds are marked
	# removed and dropped from the team plans; the rest are
	# kept. Bounds arrive as data (Tmp.r1 / Tmp.r2 are shared
	# temp rects and are not ported). The tile block covers
	# Rect2(0, 0, 2, 2) in every case below.

	# No plan overlaps the tile block -> nothing removed,
	# the one plan is kept.
	var no_overlap := game_loop_state.source_game_loop_check_overlapping_plans_state(
		{"plans": [{"x": 10, "y": 10, "bounds": Rect2(10, 10, 1, 1), "removed": false}]},
		{"bounds": Rect2(0, 0, 2, 2)})
	proof["check_overlapping_plans_no_overlap"] = (no_overlap.get("removed_plans", []) as Array).is_empty() and (no_overlap.get("kept_plans", []) as Array).size() == 1

	# One plan overlaps the tile block -> it is removed
	# (marked removed = true) and nothing is kept.
	var one_overlap := game_loop_state.source_game_loop_check_overlapping_plans_state(
		{"plans": [{"x": 1, "y": 1, "bounds": Rect2(1, 1, 1, 1), "removed": false}]},
		{"bounds": Rect2(0, 0, 2, 2)})
	var one_removed: Array = one_overlap.get("removed_plans", [])
	proof["check_overlapping_plans_one_overlap"] = one_removed.size() == 1 and bool((one_removed[0] as Dictionary).get("removed", false)) == true and (one_overlap.get("kept_plans", []) as Array).is_empty()

	# Three plans, two overlap -> only the overlapping two
	# are removed; the far plan is kept.
	var mixed := game_loop_state.source_game_loop_check_overlapping_plans_state(
		{"plans": [
			{"x": 1, "y": 0, "bounds": Rect2(1, 0, 1, 1), "removed": false},
			{"x": 5, "y": 5, "bounds": Rect2(5, 5, 1, 1), "removed": false},
			{"x": 0, "y": 1, "bounds": Rect2(0, 1, 1, 1), "removed": false},
		]},
		{"bounds": Rect2(0, 0, 2, 2)})
	proof["check_overlapping_plans_mixed"] = (mixed.get("removed_plans", []) as Array).size() == 2 and (mixed.get("kept_plans", []) as Array).size() == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07LogicCheckOverlappingPlansProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
