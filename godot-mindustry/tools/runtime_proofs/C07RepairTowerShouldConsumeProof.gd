extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- Live tick: the repair tower is a RepairTower build
	# with a static power consumer (unit-repair-tower,
	# consumePower 1f, Blocks.java:6582), placed live; the tick
	# driver is called directly (as the N2176/N2190 proofs do),
	# not simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is already
	# proven by N2142. The repair tower tick models no other
	# consumers, so with a power consumer the first pass holds
	# only the power row. The shouldConsume gate (N2191,
	# RepairTower.java:89-90, `return targets.size > 0;`) runs
	# through the pure function
	# source_repair_tower_should_consume_state(frame) over the
	# frame key `targets_count` (int, stamped by the N2190
	# refresh on expiry when a nearby_damaged_units observation
	# exists): an absent key means "no observation yet" and
	# preserves the N2176 behavior (should_consume = enabled),
	# never "no targets". The driver calls the gate BEFORE the
	# consumption setup (the Java order, updateConsumption :2274
	# reads shouldConsume() at :1960), reading the targets_count
	# the previous tick's refresh stamped; the refresh itself runs
	# AFTER apply_update_consumption_state and cannot stamp a
	# count on a 1/60s tick (the 6.0s interval is far away), so
	# the proof-stamped count survives the driver call.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_tower_cell := Vector2i(28, 21)
	var repair_tower := Sprite2D.new()
	game.add_child(repair_tower)
	game.call("record_placed_block", repair_tower, blocks_by_id["unit-repair-tower"], repair_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(repair_tower, blocks_by_id["unit-repair-tower"])
	var repair_tower_frame: Dictionary = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})

	# Gate blocks without targets: targets_count=0 at half power
	# -- the gate overrides the power fold, efficiency 0
	# (BuildingComp.java:1960 + 1992-1993, `if(!update){` /
	# `efficiency = optionalEfficiency = 0f;`), even though the
	# power row alone would fold 0.5.
	repair_tower_frame["targets_count"] = 0
	repair_tower_frame["power_status"] = 0.5
	repair_tower_frame["enabled"] = true
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["gate_blocks_without_targets"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes with targets: targets_count=2 at half power --
	# the power fold applies, efficiency 0.5.
	repair_tower_frame["targets_count"] = 2
	repair_tower_frame["power_status"] = 0.5
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["gate_passes_with_targets"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when disabled: targets_count=2 but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable.
	var disabled_gate: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state({"targets_count": 2, "enabled": false})
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# Absent key preserves the power fold: NO targets_count key at
	# half power -- the gate preserves the N2176 behavior
	# (should_consume = enabled), so efficiency folds the power
	# min 0.5. This pins the RED absent-default decision: null
	# means "no observation yet", not "no targets".
	repair_tower_frame.erase("targets_count")
	repair_tower_frame["power_status"] = 0.5
	repair_tower_frame["enabled"] = true
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.5)

	# Gate passes with targets and no power stamp:
	# targets_count=1 with power_status absent -- the missing
	# stamp folds to 1.0 (the assembler fold,
	# UnitAssembler.java:469), so efficiency is 1.0.
	repair_tower_frame["targets_count"] = 1
	repair_tower_frame.erase("power_status")
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["gate_passes_with_targets_no_power"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
