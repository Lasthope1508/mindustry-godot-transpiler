extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
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

	# --- Build counter + validate + plan selection (N2272):
	# BuilderComp.updateBuildLogic() (BuilderComp.java:76+),
	# called from BuildTurret.java:225
	# (`unit.updateBuildLogic();`). The counter half:
	# `buildCounter += Time.delta;` (:97, TICKS) with the
	# NaN/Inf guard to 0f (:98) and the 10f clamp (:99),
	# `boolean instant = state.rules.instantBuild &&
	# state.rules.infiniteResources;` (:101), `int maxPerFrame =
	# instant ? plans.size : 10, count = 0;` (:104), the
	# `while((buildCounter >= 1 || instant) && count++ <
	# maxPerFrame && plans.size > 0){` gate (:110). The
	# selection half: validatePlans (:57-74, `Tile tile =
	# world.tile(plan.x, plan.y);`, the three remove branches)
	# then the size > 1 rotation loop (:114-146, `float dst =
	# plan.dst2(this);` in world units from the plan draw
	# position x*8 + block_offset, `boolean within = dst <=
	# finalPlaceDst*finalPlaceDst;` NON-strict, `if(within &&
	# !shouldSkip(plan, core)){`, the bestIndex fallback
	# `if(!foundAny && bestIndex > 0 && !within(buildPlan(),
	# finalPlaceDst)){` with STRICT within). shouldSkip
	# (:246-251): breaking / rotation / derelict-repair /
	# core-null / infinite plans are never skipped; otherwise a
	# stuck plan without full requirements, or any stack short
	# of min(amount, 15) with a positive rounded cost, skips.
	# Placement (:148-222) defers, so the driver runs one plan
	# per tick. The tower sits at world (0, 0) in every fixture
	# below, so a plan at tile x=5 is 40px away (in range), a
	# plan at tile x=20 is 160px away (in range), and a plan at
	# tile x=100 is 800px away (out of range, range 200f).
	# Plan dicts are the test-only mirror of BuildPlan ({x, y,
	# rotation, block, config, breaking, build_is_self} plus
	# the N2272 selection fields stuck / requirements /
	# is_rotation / is_derelict_repair / block_offset); no real
	# Unit / BuildPlan is built -- the port has no live unit,
	# tile lookup, or core inventory state.

	# Counter: 9.5 + 1.0 ticks clamps at 10.0 (the
	# `buildCounter = Math.min(buildCounter, 10f);` clamp),
	# the loop runs with 10 iterations available (floor(10)
	# capped by maxPerFrame 10); 0.5 + 1.0 accumulates to 1.5
	# with 1 iteration available.
	var clamped: Dictionary = build_turret_build_state.source_build_turret_build_counter_state(9.5, 1.0, false, 1, true, true, 1.5, true, false)
	var accumulated: Dictionary = build_turret_build_state.source_build_turret_build_counter_state(0.5, 1.0, false, 2, true, true, 1.5, true, false)
	proof["counter_accumulates_and_clamps"] = float(clamped.get("build_counter", -1.0)) == 10.0 and bool(clamped.get("run_build_loop", false)) and int(clamped.get("iterations_available", -1)) == 10 and int(clamped.get("max_per_frame", -1)) == 10 and float(accumulated.get("build_counter", -1.0)) == 1.5 and bool(accumulated.get("run_build_loop", false)) and int(accumulated.get("iterations_available", -1)) == 1

	# Counter: a NaN counter resets to 0.0 (the
	# `if(Float.isNaN(buildCounter) ||
	# Float.isInfinite(buildCounter)) buildCounter = 0f;`
	# guard), so the loop does not run.
	var nan_value: float = 0.0 / 0.0
	var nan_reset: Dictionary = build_turret_build_state.source_build_turret_build_counter_state(nan_value, 1.0, false, 1, true, true, 1.5, true, false)
	proof["counter_nan_resets_to_zero"] = float(nan_reset.get("build_counter", -1.0)) == 0.0 and not bool(nan_reset.get("run_build_loop", true)) and int(nan_reset.get("iterations_available", -1)) == 0 and int(nan_reset.get("max_per_frame", -1)) == 10

	# Validate: a plan with no tile (tile_exists false) is
	# removed (`tile == null`, :64) while the valid plan
	# survives; the survivor is in range with no core (null
	# core_items means core == null, so shouldSkip is false)
	# and is selected.
	var null_tile_plans: Array = [
		{"x": 1, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false},
		{"x": 5, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false},
	]
	var null_tile_states: Array = [
		{"tile_exists": false, "tile_block": "", "tile_build_exists": false, "tile_build_rotation": 0, "tile_build_x": -1, "tile_build_y": -1, "tile_team_derelict": false, "tile_overlay": "", "tile_floor": "", "block_rotate": true, "block_is_overlay": false, "block_is_floor": false},
		{"tile_exists": true, "tile_block": "air", "tile_build_exists": false, "tile_build_rotation": 0, "tile_build_x": -1, "tile_build_y": -1, "tile_team_derelict": false, "tile_overlay": "", "tile_floor": "", "block_rotate": true, "block_is_overlay": false, "block_is_floor": false},
	]
	var validated: Dictionary = build_turret_build_state.source_build_turret_build_plan_selection_state(null_tile_plans, null_tile_states, null, 0.0, 0.0, 200.0, false, 1.0)
	var validated_plans: Array = validated.get("plans", [])
	var validated_selected: Variant = validated.get("selected", null)
	proof["validate_removes_null_tile_plan"] = validated_plans.size() == 1 and int(validated_plans[0].get("x", -1)) == 5 and validated_selected is Dictionary and int(validated_selected.get("x", -1)) == 5 and bool(validated.get("found_any", false))

	# Validate: a non-breaking plan on an empty tile (air,
	# no build, block rotates) is kept -- no remove branch
	# fires -- and selected as the single in-range plan.
	var kept_plans: Array = [
		{"x": 5, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false},
	]
	var kept_states: Array = [
		{"tile_exists": true, "tile_block": "air", "tile_build_exists": false, "tile_build_rotation": 0, "tile_build_x": -1, "tile_build_y": -1, "tile_team_derelict": false, "tile_overlay": "", "tile_floor": "", "block_rotate": true, "block_is_overlay": false, "block_is_floor": false},
	]
	var kept: Dictionary = build_turret_build_state.source_build_turret_build_plan_selection_state(kept_plans, kept_states, null, 0.0, 0.0, 200.0, false, 1.0)
	var kept_selected: Variant = kept.get("selected", null)
	proof["validate_keeps_valid_plan"] = (kept.get("plans", []) as Array).size() == 1 and kept_selected is Dictionary and int(kept_selected.get("x", -1)) == 5 and bool(kept.get("found_any", false))

	# Selection: the first in-range plan is stuck without core
	# items (shouldSkip true -- stuck && !has(requirements)),
	# so the loop rotates past it (bestIndex 0 tracks it as
	# the closest within plan so far) and picks the next
	# in-range plan, which is not skipped.
	var first_valid_plans: Array = [
		{"x": 20, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": true, "requirements": [{"item": "copper", "amount": 10}], "is_rotation": false, "is_derelict_repair": false},
		{"x": 5, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": false, "requirements": [], "is_rotation": false, "is_derelict_repair": false},
		{"x": 100, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": false, "requirements": [], "is_rotation": false, "is_derelict_repair": false},
	]
	var first_valid: Dictionary = build_turret_build_state.source_build_turret_build_plan_selection_state(first_valid_plans, [], {}, 0.0, 0.0, 200.0, false, 1.0)
	var first_valid_selected: Variant = first_valid.get("selected", null)
	var first_valid_plans_after: Array = first_valid.get("plans", [])
	proof["selection_picks_first_valid_in_range"] = first_valid_selected is Dictionary and int(first_valid_selected.get("x", -1)) == 5 and bool(first_valid.get("found_any", false)) and int(first_valid.get("best_index", -9)) == 0 and first_valid_plans_after.size() == 3 and int(first_valid_plans_after[0].get("x", -1)) == 5

	# Selection fallback: every plan is stuck without core
	# items, so nothing is found; the head plan is out of
	# range, so the `!foundAny && bestIndex > 0 &&
	# !within(buildPlan(), finalPlaceDst)` fallback rotates
	# once toward the nearest in-range plan (tile x=5, 40px),
	# which becomes the selected head.
	var fallback_plans: Array = [
		{"x": 100, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": true, "requirements": [{"item": "copper", "amount": 10}], "is_rotation": false, "is_derelict_repair": false},
		{"x": 5, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": true, "requirements": [{"item": "copper", "amount": 10}], "is_rotation": false, "is_derelict_repair": false},
		{"x": 20, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false, "stuck": true, "requirements": [{"item": "copper", "amount": 10}], "is_rotation": false, "is_derelict_repair": false},
	]
	var fallback: Dictionary = build_turret_build_state.source_build_turret_build_plan_selection_state(fallback_plans, [], {}, 0.0, 0.0, 200.0, false, 1.0)
	var fallback_selected: Variant = fallback.get("selected", null)
	var fallback_plans_after: Array = fallback.get("plans", [])
	proof["selection_fallback_rotates_to_nearest"] = not bool(fallback.get("found_any", true)) and int(fallback.get("best_index", -9)) == 1 and fallback_selected is Dictionary and int(fallback_selected.get("x", -1)) == 5 and fallback_plans_after.size() == 3 and int(fallback_plans_after[0].get("x", -1)) == 5 and int(fallback_plans_after[1].get("x", -1)) == 20 and int(fallback_plans_after[2].get("x", -1)) == 100

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretUpdateBuildLogicProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
