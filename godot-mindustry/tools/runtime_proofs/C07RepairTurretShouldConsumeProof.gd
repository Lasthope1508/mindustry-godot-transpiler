extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- Live tick: the repair turret is a RepairTurret build
	# with a conditional power consumer (repair-point, powerUse
	# 1f; repair-turret, powerUse 5f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/N2170/N2171/
	# N2172/N2173/N2174 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status --
	# the write-back itself is already proven by N2142. The
	# repair turret tick models no other consumers, so with a
	# power consumer the first pass holds only the power row.
	# The shouldConsume gate (N2188, RepairTurret.java:221-222,
	# `return target != null && enabled;`) runs through the pure
	# function source_repair_turret_should_consume_state(frame)
	# over the frame key `has_target`: an absent key means "no
	# observation yet" and preserves the N2174 behavior
	# (should_consume = enabled), never "no target".
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["repair_turret_has_power_consumer"] = bool(blocks_by_id["repair-point"].properties.get("hasPower", false)) and bool(blocks_by_id["repair-point"].properties.get("consumesPower", false)) and bool(blocks_by_id["repair-turret"].properties.get("hasPower", false)) and bool(blocks_by_id["repair-turret"].properties.get("consumesPower", false))

	var repair_turret_cell := Vector2i(28, 21)
	var repair_turret := Sprite2D.new()
	game.add_child(repair_turret)
	game.call("record_placed_block", repair_turret, blocks_by_id["repair-point"], repair_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	repair_turret_build_state.source_repair_turret_bind_frame_state(repair_turret, blocks_by_id["repair-point"])
	var repair_turret_frame: Dictionary = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})

	# Gate blocks without target: has_target=false at half power
	# -- the gate overrides the power fold, efficiency 0
	# (BuildingComp.java:1960 + 1992-1993, `if(!update){` /
	# `efficiency = optionalEfficiency = 0f;`), even though the
	# power row alone would fold 0.5.
	repair_turret_frame["has_target"] = false
	repair_turret_frame["power_status"] = 0.5
	repair_turret_frame["enabled"] = true
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["gate_blocks_without_target"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes with target: has_target=true at half power --
	# the power fold applies, efficiency 0.5.
	repair_turret_frame["has_target"] = true
	repair_turret_frame["power_status"] = 0.5
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["gate_passes_with_target"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when disabled: has_target=true but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable.
	var disabled_gate: Dictionary = repair_turret_build_state.source_repair_turret_should_consume_state({"has_target": true, "enabled": false})
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# Absent key preserves the power fold: NO has_target key at
	# half power -- the gate preserves the N2174 behavior
	# (should_consume = enabled), so efficiency folds the power
	# min 0.5. This pins the RED absent-default decision: null
	# means "no observation yet", not "no target".
	repair_turret_frame.erase("has_target")
	repair_turret_frame["power_status"] = 0.5
	repair_turret_frame["enabled"] = true
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.5)

	# Gate passes with target and no power stamp:
	# has_target=true with power_status absent -- the missing
	# stamp folds to 1.0 (the assembler fold,
	# UnitAssembler.java:469), so efficiency is 1.0.
	repair_turret_frame["has_target"] = true
	repair_turret_frame.erase("power_status")
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["gate_passes_with_target_no_power"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
