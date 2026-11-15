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

	# --- Pure shouldConsume gate (N2215):
	# BuildTurretBuild.shouldConsume()
	# (BuildTurret.java:229-231, `public boolean
	# shouldConsume(){` with `return unit.plans().size > 0 &&
	# !isHealSuppressed();`, BuildTurret.java:230) -- TWO
	# conditions: the builder unit's plan queue must be
	# non-empty AND the building must not be heal-suppressed.
	# The unit is `public BlockUnitc unit =
	# (BlockUnitc)unitType.create(team);` (BuildTurret.java:93)
	# on BuildTurretBuild (`public class BuildTurretBuild
	# extends BaseTurretBuild implements ControlBlock,
	# RotBlock{`, BuildTurret.java:92). isHealSuppressed()
	# (BuildingComp.java:487-489) returns
	# `block.suppressable && Time.time <=
	# healSuppressionTime;`, set through applyHealSuppression
	# (BuildingComp.java:482-485); BuildTurret has
	# `suppressable = true;` (BuildTurret.java:46), so the
	# second term is live, not dead. Unlike the RepairTurret
	# gate (N2212) this one has NO `&& enabled` term, so the
	# pure gate does NOT read frame["enabled"] at all (the
	# driver already runs the machinery only when enabled).
	# The gate reads only the SIZE of frame["plans"], so the
	# present-plans fixture below is a minimal test-only Array
	# of one plan dict -- no real BlockPlan is built; the port
	# has no live plan search / mimic / validate on the
	# building frame yet (the updateTile advance,
	# BuildTurret.java:156-225, waits for its own slice), and
	# no live suppression application yet (applyHealSuppression,
	# BuildingComp.java:482-485, needs game time).
	var with_plans: Dictionary = build_turret_build_state.source_build_turret_should_consume_state({"plans": [{"block": "conveyor", "x": 0, "y": 0}]})
	proof["gate_true_when_plans_nonempty"] = bool(with_plans.get("should_consume", false)) and int(with_plans.get("plan_count", -1)) == 1

	var no_plans: Dictionary = build_turret_build_state.source_build_turret_should_consume_state({"plans": []})
	proof["gate_false_when_plans_empty"] = bool(no_plans.get("should_consume", true)) == false and int(no_plans.get("plan_count", -1)) == 0

	var suppressed_with_plans: Dictionary = build_turret_build_state.source_build_turret_should_consume_state({"plans": [{"block": "conveyor", "x": 0, "y": 0}], "heal_suppressed": true})
	proof["gate_false_when_heal_suppressed"] = bool(suppressed_with_plans.get("should_consume", true)) == false and int(suppressed_with_plans.get("plan_count", -1)) == 1

	# --- Live tick: the build tower is a BuildTurret build
	# with a static power consumer (build-tower,
	# consumePower 3f, Blocks.java:2005), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/
	# N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/
	# N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/N2178/
	# N2179/N2180/N2181/N2182/N2183/N2184 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The build-turret tick models
	# no other consumers, so with a power consumer the first
	# pass holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var build_turret_cell := Vector2i(30, 21)
	var build_turret := Sprite2D.new()
	game.add_child(build_turret)
	game.call("record_placed_block", build_turret, blocks_by_id["build-tower"], build_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the plans on it).
	build_turret_build_state.source_build_turret_bind_frame_state(build_turret, blocks_by_id["build-tower"])
	var build_turret_frame: Dictionary = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})

	# A freshly bound frame carries the plans key defaulting
	# to [] (the builder unit's plan queue starts empty) and
	# the heal_suppressed key defaulting to false -- no plans
	# yet, so the gate reads false and the tower does not
	# consume.
	proof["frame_plans_default_empty"] = build_turret_frame.has("plans") and build_turret_frame["plans"] == [] and build_turret_frame.has("heal_suppressed") and build_turret_frame["heal_suppressed"] == false

	# No plans: gate false -> efficiency 0 even at half power.
	build_turret_frame["plans"] = []
	build_turret_frame["heal_suppressed"] = false
	build_turret_frame["power_status"] = 0.5
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.0)

	# Plans present, not suppressed: gate true -> efficiency
	# folds the power min 0.5 (the N2184 power fold preserved).
	build_turret_frame["plans"] = [{"block": "conveyor", "x": 0, "y": 0}]
	build_turret_frame["heal_suppressed"] = false
	build_turret_frame["power_status"] = 0.5
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
