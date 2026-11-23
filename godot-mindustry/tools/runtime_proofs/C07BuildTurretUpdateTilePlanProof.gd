extends Node

const main_scene := preload("res://scenes/Main.tscn")
const bridge := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- BuildTurretBuild.updateTile() plan legs (N2423):
	# BuildTurretBuild.updateTile()
	# (BuildTurret.java:121-227) -- the plan search / follow /
	# mimic / validate advance N2184 deferred, 9 distinct
	# exprs, all 0-hit in both ledgers at RED. The pure
	# function takes the follower / control / build-plan
	# observations as explicit bools, the team plan queue as
	# an Array of plan Dictionaries, and the Build.validPlace
	# + infiniteResources/items gate as an explicit Callable.
	# The `Units.nearby` live query is NOT modeled: the
	# function only answers whether mimic starts and whether
	# a candidate's callback returns early. The proof drives
	# the pure function with fixtures (no live tick).

	var duo_plan := {"x": 10, "y": 20, "rotation": 0, "block": "duo", "config": null}
	var scatter_plan := {"x": 30, "y": 40, "rotation": 1, "block": "scatter", "config": null}
	var plans: Array = [duo_plan, scatter_plan]
	var valid_scatter := func(plan: Dictionary) -> bool: return str(plan.get("block", "")) == "scatter"
	var valid_none := func(_plan: Dictionary) -> bool: return false

	# An invalid follower is forgotten (BuildTurret.java:147).
	var invalid_follower: Dictionary = bridge.source_build_turret_update_tile_plan_state(true, false, false, false, [], valid_none, false, Vector2i.ZERO, false, false)
	proof["follower_invalid_clears_following"] = bool(invalid_follower.get("following_cleared", false)) == true

	# A valid follower is kept when nothing else clears it.
	var valid_follower: Dictionary = bridge.source_build_turret_update_tile_plan_state(true, true, false, false, [], valid_none, false, Vector2i.ZERO, false, false)
	proof["valid_follower_kept"] = bool(valid_follower.get("following_cleared", true)) == false

	# The controlled branch forgets everything (:218).
	var controlled: Dictionary = bridge.source_build_turret_update_tile_plan_state(true, true, true, false, [], valid_none, false, Vector2i.ZERO, false, false)
	proof["controlled_clears_following"] = bool(controlled.get("following_cleared", false)) == true

	# The search takes the first plan the validPlace gate
	# accepts (:158-163): duo fails, scatter passes.
	var found: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, true, plans, valid_scatter, false, Vector2i.ZERO, false, false)
	proof["search_finds_first_valid_plan"] = int(found.get("found_index", -2)) == 1 and Dictionary(found.get("found_plan", {})).get("block", "") == "scatter" and str(found.get("found_btype", "")) == "scatter"

	# No valid plan: the search finds nothing and mimic
	# starts (:174).
	var no_plan: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, true, [duo_plan], valid_none, false, Vector2i.ZERO, false, false)
	proof["search_finds_none_starts_mimic"] = int(no_plan.get("found_index", 0)) == -1 and bool(no_plan.get("mimic", false)) == true and Dictionary(no_plan.get("found_plan", {"x": 1})).is_empty()

	# With a build plan there is no search and no mimic.
	var has_plan: Dictionary = bridge.source_build_turret_update_tile_plan_state(true, true, false, false, plans, valid_scatter, false, Vector2i.ZERO, false, false)
	proof["has_plan_skips_search"] = int(has_plan.get("found_index", 0)) == -1 and bool(has_plan.get("mimic", true)) == false

	# Another player breaking the same position removes the
	# request from the team queue (:198); otherwise the queue
	# is untouched.
	var removed: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, false, plans, valid_none, false, Vector2i(10, 20), true, false)
	var kept: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, false, plans, valid_none, false, Vector2i(10, 20), false, false)
	var removed_plans: Array = removed.get("team_plans", [])
	var kept_plans: Array = kept.get("team_plans", [])
	proof["player_breaking_removes_plan"] = removed_plans.size() == 1 and Dictionary(removed_plans[0]).get("block", "") == "scatter" and kept_plans.size() == 2

	# The valid ternary takes the break leg for a break
	# request (:207), the place leg otherwise.
	var breaking: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, false, [], valid_none, true, Vector2i.ZERO, false, false)
	var placing: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, false, [], valid_none, false, Vector2i.ZERO, false, false)
	proof["break_branch_selected"] = bool(breaking.get("valid_break_branch", false)) == true and bool(placing.get("valid_break_branch", true)) == false

	# A mimic candidate's callback returns early once
	# following is already set (:177); otherwise it runs.
	var early: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, true, [duo_plan], valid_none, false, Vector2i.ZERO, false, true)
	var late: Dictionary = bridge.source_build_turret_update_tile_plan_state(false, true, false, true, [duo_plan], valid_none, false, Vector2i.ZERO, false, false)
	proof["mimic_early_return_when_following_set"] = bool(early.get("mimic_early_return", false)) == true and bool(late.get("mimic_early_return", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretUpdateTilePlanProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
