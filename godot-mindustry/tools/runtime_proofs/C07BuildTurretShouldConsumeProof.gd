extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const source_building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# --- Live tick: the build tower is a BuildTurret build
	# with a static power consumer (build-tower, consumePower
	# 3f, Blocks.java:2005), placed live; the tick driver is
	# called directly (as the N2184/N2188 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The build-turret tick models no
	# other consumers, so with a power consumer the first pass
	# holds only the power row. The shouldConsume gate (N2201,
	# BuildTurret.java:229-230, `return unit.plans().size > 0
	# && !isHealSuppressed();`) runs through the pure function
	# source_build_turret_should_consume_state(frame) over the
	# frame keys `plans_count` (int) and `heal_suppressed`
	# (bool): an absent plans_count key means "no observation
	# yet" and preserves the N2184 behavior (should_consume =
	# enabled), never "no plans"; an absent heal_suppressed
	# key means "not suppressed" (suppression is a transient
	# timed state, BuildingComp.java:487-489).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["build_turret_has_power_consumer"] = bool(blocks_by_id["build-tower"].properties.get("hasPower", false)) and bool(blocks_by_id["build-tower"].properties.get("consumesPower", false)) and is_equal_approx(float(blocks_by_id["build-tower"].properties.get("consumePower", -1.0)), 3.0)

	var build_turret_cell := Vector2i(30, 21)
	var build_turret := Sprite2D.new()
	game.add_child(build_turret)
	game.call("record_placed_block", build_turret, blocks_by_id["build-tower"], build_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	build_turret_build_state.source_build_turret_bind_frame_state(build_turret, blocks_by_id["build-tower"])
	var build_turret_frame: Dictionary = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})

	# Gate blocks without plans: plans_count=0 at half power
	# -- the gate overrides the power fold, efficiency 0
	# (BuildingComp.java:1960 + 1992-1993, `if(!update){` /
	# `efficiency = optionalEfficiency = 0f;`), even though the
	# power row alone would fold 0.5 (the tower's power draw is
	# STATIC, consumePower 3f, so the row reads 0.5 with no
	# plans -- the gate is the only thing zeroing efficiency).
	build_turret_frame["plans_count"] = 0
	build_turret_frame["power_status"] = 0.5
	build_turret_frame["enabled"] = true
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["gate_blocks_without_plans"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes with plans: plans_count=1 at half power --
	# the power fold applies, efficiency 0.5.
	build_turret_frame["plans_count"] = 1
	build_turret_frame["power_status"] = 0.5
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["gate_passes_with_plans"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when disabled: plans_count=1 but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable.
	var disabled_gate: Dictionary = build_turret_build_state.source_build_turret_should_consume_state({"plans_count": 1, "enabled": false})
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# Absent key preserves the power fold: NO plans_count key at
	# half power -- the gate preserves the N2184 behavior
	# (should_consume = enabled), so efficiency folds the power
	# min 0.5. This pins the RED absent-default decision: null
	# means "no observation yet", not "no plans".
	build_turret_frame.erase("plans_count")
	build_turret_frame["power_status"] = 0.5
	build_turret_frame["enabled"] = true
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when heal suppressed: plans_count=1 at half
	# power but heal_suppressed=true -- the second conjunct
	# (`!isHealSuppressed()`, BuildTurret.java:230;
	# BuildingComp.java:487-489) blocks the gate, efficiency 0.
	build_turret_frame["plans_count"] = 1
	build_turret_frame["heal_suppressed"] = true
	build_turret_frame["power_status"] = 0.5
	build_turret_frame["enabled"] = true
	build_turret_build_state.source_build_turret_tick_buildings_state(game, 1.0 / 60.0)
	build_turret_frame = build_turret.get_meta(build_turret_build_state.SOURCE_BUILD_TURRET_BUILDING_META_KEY, {})
	proof["gate_blocks_when_heal_suppressed"] = is_equal_approx(float(build_turret_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
