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

	# --- Pure plan logic (N2244): the plan-logic half of
	# BuildTurretBuild.updateTile() (BuildTurret.java:141-225).
	# Autonomous (`if(!isControlled()){`, :141) with
	# `unit.updateBuilding(true);` (:142): follower validation
	# (:144-155, `if(!following.isValid() ||
	# !following.activelyBuilding()){` clears following + plans,
	# else plans = [follower's first plan] and `lastPlan =
	# null;`); plan search (:156-173,
	# `}else if(unit.buildPlan() == null && timer(timerTarget,
	# targetInterval)){` with targetInterval 15,
	# `Queue<BlockPlan> blocks = team.data().plans;`,
	# `if(within(block.x * tilesize, block.y * tilesize,
	# range)){`, `unit.addBuild(new BuildPlan(block.x, block.y,
	# block.rotation, block.block, block.config));`,
	# `blocks.addLast(blocks.removeIndex(i));` rotating the
	# picked plan to the tail, `lastPlan = block;`); mimic
	# (:174-188, `Units.nearby(team, x, y, range, u -> {`,
	# `if(u.canBuild() && u.activelyBuilding()){`,
	# `if(build instanceof ConstructBuild && within(build,
	# range)){`, `following = u;`); validation (:189-216,
	# `BuildPlan req = unit.buildPlan();`,
	# `if(!req.breaking && timer.get(timerTarget2, 30f)){`, the
	# break-plan discard with its early `return;`,
	# `boolean valid =` with `!(lastPlan != null &&
	# lastPlan.removed) &&`, `if(!valid){` discarding the first
	# plan); controlled (`}else{ //is being controlled, forget
	# everything`, :217-220); suicide-plan removal (:223,
	# `unit.plans().remove(b -> b.build() == this);`).
	# `unit.updateBuildLogic();` (:225, BuilderComp.java:76+)
	# is NOT called -- the build simulation defers. within is
	# the strict squared-distance check (Arc
	# Position.java:44-46) with tilesize 8 (Vars.java:135) and
	# the build-tower range 200f (Blocks.java:2001). The tower
	# sits at world (0, 0) in every fixture below, so a plan at
	# tile x=5 is 40px away (in range) and a plan at tile
	# x=100 is 800px away (out of range). Plan dicts are the
	# test-only mirror of BuildPlan / BlockPlan ({x, y,
	# rotation, block, config, breaking, build_is_self} /
	# {x, y, rotation, block, config, valid_place, removed});
	# no real Unit / BlockPlan is built -- the port has no
	# live unit, team-plan, nearby-builder, or player state.

	# Follower validation: an invalid follower (valid false)
	# clears following AND the plan queue.
	var follower_invalid: Dictionary = build_turret_build_state.source_build_turret_plan_logic_state({"plans": [{"x": 1, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}], "following": {"id": "u1", "valid": false, "actively_building": true, "first_plan": {"x": 2, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}}, "last_plan": null}, false, false, false, 0.0, 0.0, 200.0, [], [], [], false, true)
	proof["follower_validation_clears_invalid"] = follower_invalid.get("following", "set") == null and (follower_invalid.get("plans", [1]) as Array).is_empty() and str(follower_invalid.get("branch", "")) == "follower_invalid"

	# Plan search: the first in-range placeable team plan is
	# picked (the out-of-range plan is skipped), and the picked
	# plan rotates to the tail of the team queue.
	var team_plans: Array = [
		{"x": 100, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "valid_place": true, "removed": false},
		{"x": 5, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "valid_place": true, "removed": false},
		{"x": 6, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "valid_place": true, "removed": false},
	]
	var searched: Dictionary = build_turret_build_state.source_build_turret_plan_logic_state({"plans": [], "following": null, "last_plan": null}, false, true, false, 0.0, 0.0, 200.0, team_plans, [], [], false, true)
	var searched_plans: Array = searched.get("plans", [])
	var searched_team: Array = searched.get("team_plans", [])
	var searched_last: Variant = searched.get("last_plan", null)
	proof["plan_search_picks_in_range"] = searched_plans.size() == 1 and int(searched_plans[0].get("x", -1)) == 5 and searched_last is Dictionary and int(searched_last.get("x", -1)) == 5 and str(searched.get("branch", "")) == "search_found"
	proof["plan_search_rotates_queue"] = searched_team.size() == 3 and int(searched_team[0].get("x", -1)) == 100 and int(searched_team[1].get("x", -1)) == 6 and int(searched_team[2].get("x", -1)) == 5

	# Mimic: with no team plan to pick, the tower follows the
	# first nearby builder that can build, is actively
	# building, and builds a ConstructBuild in range (the
	# non-builder is skipped).
	var nearby_builders: Array = [
		{"id": "u9", "can_build": false, "actively_building": true, "first_plan": {"x": 3, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}, "build_is_construct": true, "build_x": 24.0, "build_y": 0.0},
		{"id": "u2", "can_build": true, "actively_building": true, "first_plan": {"x": 4, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}, "build_is_construct": true, "build_x": 32.0, "build_y": 0.0},
	]
	var mimicked: Dictionary = build_turret_build_state.source_build_turret_plan_logic_state({"plans": [], "following": null, "last_plan": null}, false, true, false, 0.0, 0.0, 200.0, [], nearby_builders, [], false, true)
	var mimicked_following: Variant = mimicked.get("following", null)
	proof["mimic_follows_nearby_builder"] = mimicked_following is Dictionary and str(mimicked_following.get("id", "")) == "u2" and str(mimicked.get("branch", "")) == "search_mimic"

	# Invalid plan: a removed lastPlan fails the validity gate
	# (`!(lastPlan != null && lastPlan.removed) &&`), so the
	# head plan is discarded and lastPlan is cleared.
	var invalid: Dictionary = build_turret_build_state.source_build_turret_plan_logic_state({"plans": [{"x": 1, "y": 1, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}], "following": null, "last_plan": {"x": 1, "y": 1, "rotation": 0, "block": "conveyor", "config": null, "removed": true}}, false, false, false, 0.0, 0.0, 200.0, [], [], [], false, true)
	proof["invalid_plan_discarded"] = (invalid.get("plans", [1]) as Array).is_empty() and invalid.get("last_plan", "set") == null and bool(invalid.get("plan_discarded", false)) and str(invalid.get("branch", "")) == "validate_invalid"

	# Suicide plan: a plan pointing at the tower itself
	# (build_is_self, the `b.build() == this` mirror) is
	# removed while the other plan survives -- the validation
	# passes first (lastPlan null, request valid), then the
	# suicide filter runs.
	var suicide: Dictionary = build_turret_build_state.source_build_turret_plan_logic_state({"plans": [{"x": 0, "y": 0, "rotation": 0, "block": "build-tower", "config": null, "breaking": false, "build_is_self": true}, {"x": 3, "y": 0, "rotation": 0, "block": "conveyor", "config": null, "breaking": false, "build_is_self": false}], "following": null, "last_plan": null}, false, false, false, 0.0, 0.0, 200.0, [], [], [], false, true)
	var suicide_plans: Array = suicide.get("plans", [])
	proof["suicide_plan_removed"] = suicide_plans.size() == 1 and int(suicide_plans[0].get("x", -1)) == 3 and str(suicide.get("branch", "")) == "validate_ok"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretPlanLogicProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
