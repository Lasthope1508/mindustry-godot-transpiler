extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Live tick: the burst drill is a BurstDrill build
	# with a static power consumer (impact-drill consumePower
	# 160f/60f, eruption-drill consumePower 6f), placed live;
	# the tick driver is called directly (as the N2149/N2191
	# proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The burst
	# drill tick models no other consumers, so with a power
	# consumer the first pass holds only the power row. The
	# shouldConsume gate (N2257, BurstDrill.java:128-129,
	# `public boolean shouldConsume(){` with `return
	# items.total() <= itemCapacity - dominantItems &&
	# enabled;`) runs through the pure function
	# source_burst_drill_should_consume_state(frame,
	# item_capacity) over the frame keys `items_total` (float)
	# and `dominant_items` (int) plus the per-def itemCapacity
	# read from the catalog block properties (impact-drill 40,
	# Blocks.java:3078, `itemCapacity = 40;`; eruption-drill
	# 60, Blocks.java:3107, `itemCapacity = 60;`): an absent
	# key means "no observation yet" and preserves the N2149
	# behavior (should_consume = enabled), never "full". The
	# driver calls the gate BEFORE the consumption setup (the
	# Java order, updateConsumption :2274 reads shouldConsume()
	# at :1960), reading the totals the proof stamped; the
	# ore/dominant binding slice will stamp them live later.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var impact_cell := Vector2i(28, 21)
	var impact_drill := Sprite2D.new()
	game.add_child(impact_drill)
	game.call("record_placed_block", impact_drill, blocks_by_id["impact-drill"], impact_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	burst_drill_build_state.source_burst_drill_bind_frame_state(impact_drill, blocks_by_id["impact-drill"])
	var impact_frame: Dictionary = impact_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})

	# Gate blocks when full: items_total=40 with dominant_items=1
	# against capacity 40 -- 40 <= 40 - 1 is false -- so the
	# gate overrides the power fold, efficiency 0
	# (BuildingComp.java:1960 + 1992-1993, `if(!update){` /
	# `efficiency = optionalEfficiency = 0f;`), even though the
	# power row alone would fold 0.5.
	impact_frame["items_total"] = 40.0
	impact_frame["dominant_items"] = 1
	impact_frame["power_status"] = 0.5
	impact_frame["enabled"] = true
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	impact_frame = impact_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["gate_blocks_when_full"] = is_equal_approx(float(impact_frame.get("efficiency", -1.0)), 0.0)

	# Gate passes with room: items_total=38 with dominant_items=1
	# against capacity 40 -- 38 <= 40 - 1 is true -- so the
	# power fold applies, efficiency 0.5.
	impact_frame["items_total"] = 38.0
	impact_frame["dominant_items"] = 1
	impact_frame["power_status"] = 0.5
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	impact_frame = impact_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["gate_passes_when_room"] = is_equal_approx(float(impact_frame.get("efficiency", -1.0)), 0.5)

	# Gate blocks when disabled: items_total=10 with
	# dominant_items=1 would pass the bound, but enabled=false
	# -- the pure gate reads false, and the shared machinery's
	# disabled branch (update_consumption_disabled_state) zeroes
	# efficiency when the driver runs it with that gate value.
	# This key runs the pure gate plus the machinery directly
	# instead of the live driver: the driver skips the whole
	# consumption block when enabled is false, so a live tick
	# cannot stamp a fresh efficiency -- the gate value and the
	# machinery branch it feeds are the observable.
	var disabled_gate: Dictionary = burst_drill_build_state.source_burst_drill_should_consume_state({"items_total": 10.0, "dominant_items": 1, "enabled": false}, 40.0)
	var disabled_consumption: Dictionary = source_building_efficiency_state.update_consumption_state(true, false, false, true, bool(disabled_gate.get("should_consume", true)), 1.0, [{"result": 0.5, "is_power": true}], [], [], {})
	proof["gate_blocks_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and is_equal_approx(float(disabled_consumption.get("efficiency", -1.0)), 0.0)

	# Absent keys preserve the power fold: NO items_total /
	# dominant_items keys at half power -- the field defaults
	# (0.0 / 0) make the bound read `0 <= 40 - 0`, so the gate
	# preserves the N2149 behavior (should_consume = enabled)
	# and efficiency folds the power min 0.5. This pins the RED
	# absent-default decision: null means "no observation yet",
	# not "full".
	impact_frame.erase("items_total")
	impact_frame.erase("dominant_items")
	impact_frame["power_status"] = 0.5
	impact_frame["enabled"] = true
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	impact_frame = impact_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["gate_absent_preserves_power_fold"] = is_equal_approx(float(impact_frame.get("efficiency", -1.0)), 0.5)

	# Gate passes with room and no power stamp:
	# items_total=10 with dominant_items=1 against capacity 40
	# passes the bound, and the missing power stamp folds to
	# 1.0 (the assembler fold, UnitAssembler.java:469), so
	# efficiency is 1.0.
	impact_frame["items_total"] = 10.0
	impact_frame["dominant_items"] = 1
	impact_frame.erase("power_status")
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	impact_frame = impact_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["gate_passes_with_room_no_power"] = is_equal_approx(float(impact_frame.get("efficiency", -1.0)), 1.0)

	# Eruption def uses capacity 60: items_total=55 with
	# dominant_items=1 against capacity 60 -- 55 <= 60 - 1 is
	# true -- so the power fold applies, efficiency 0.5. This
	# distinguishes the per-def capacity: against the
	# impact-drill capacity 40 the same totals would read
	# 55 <= 40 - 1 as false and efficiency would be 0.0.
	var eruption_cell := Vector2i(34, 21)
	var eruption_drill := Sprite2D.new()
	game.add_child(eruption_drill)
	game.call("record_placed_block", eruption_drill, blocks_by_id["eruption-drill"], eruption_cell)
	burst_drill_build_state.source_burst_drill_bind_frame_state(eruption_drill, blocks_by_id["eruption-drill"])
	var eruption_frame: Dictionary = eruption_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	eruption_frame["items_total"] = 55.0
	eruption_frame["dominant_items"] = 1
	eruption_frame["power_status"] = 0.5
	eruption_frame["enabled"] = true
	burst_drill_build_state.source_burst_drill_tick_buildings_state(game, 1.0 / 60.0)
	eruption_frame = eruption_drill.get_meta(burst_drill_build_state.SOURCE_BURST_DRILL_BUILDING_META_KEY, {})
	proof["gate_eruption_def_uses_capacity_60"] = is_equal_approx(float(eruption_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BurstDrillShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
