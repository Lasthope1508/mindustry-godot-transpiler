extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
const building_efficiency_state := preload("res://src/game/SourceBuildingEfficiencyState.gd")
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

	# --- RepairTower ozone consumer (N2229):
	# The ozone liquid consumer (`consumeLiquid(Liquids.ozone,
	# 3f / 60f);`, Blocks.java:6583, amount 0.05f/tick): the
	# ConsumeLiquid.efficiency fold (ConsumeLiquid.java:42-48)
	# into the first pass plus the ConsumeLiquid.update drain
	# (ConsumeLiquid.java:37-38) in the second pass
	# (BuildingComp.java:1969-1976 / 1997-2000). The row folds
	# `float ed = build.edelta() * build.efficiencyScale();`
	# (:43) with the first-pass efficiency assumed 1
	# (BuildingComp.java:1966-1967), so ed = 1.0 * delta *
	# efficiency_scale; the guard `if(ed <= 0.00000001f)
	# return 0f;` (:44) and the cap `return
	# Math.min(build.liquids.get(liquid) / (amount * ed *
	# multiplier.get(build)), 1f);` (:47) run through the
	# generic helper SourceConsumeLiquidState.efficiency_state
	# (the N2007 drill precedent). The drain is
	# `build.liquids.remove(liquid, amount * build.edelta()
	# * multiplier.get(build));` (:38), i.e. 0.05 * folded
	# efficiency * delta per tick, clamped at the stock
	# (LiquidModule.java:125-127, `//cap to prevent negative
	# removal`), and runs only when `update && efficiency >
	# 0` (BuildingComp.java:1997). Absent key "ozone" in
	# frame["liquids"] means NO observation, not an empty
	# tank (the N2191 precedent): the row is skipped, the
	# power-only fold is kept, the drain is 0 and the dict
	# is unchanged. The proof calls the two pure functions
	# source_repair_tower_ozone_row_state(frame, delta) and
	# source_repair_tower_ozone_consume_state(frame, delta)
	# directly with synthetic frames (the N2187 precedent --
	# the driver tick lines land with GREEN). delta 1/60 is
	# one tick, so ed = 1/60, one tick at efficiency 1.0
	# needs 0.05 * (1/60) = 0.0008333 ozone and drains
	# exactly that, and a 0.0004 stock folds to 0.48.
	var delta: float = 1.0 / 60.0

	# Full stock folds to 1.0: stock 1.0 >> 0.0008333
	# needed, so the row result is 1.0 (capped).
	var frame: Dictionary = {"liquids": {"ozone": 1.0}, "efficiency_scale": 1.0}
	var row: Dictionary = repair_tower_build_state.source_repair_tower_ozone_row_state(frame, delta)
	proof["ozone_row_full_stock_efficiency_one"] = bool(row.get("has_ozone_row", false)) and abs(float((row.get("row", {}) as Dictionary).get("result", -1.0)) - 1.0) < 0.0001 and not bool((row.get("row", {}) as Dictionary).get("is_power", true))

	# Partial stock caps the fold: 0.0004 / 0.0008333 = 0.48.
	frame = {"liquids": {"ozone": 0.0004}, "efficiency_scale": 1.0}
	row = repair_tower_build_state.source_repair_tower_ozone_row_state(frame, delta)
	proof["ozone_row_partial_stock_caps_efficiency"] = bool(row.get("has_ozone_row", false)) and abs(float((row.get("row", {}) as Dictionary).get("result", -1.0)) - 0.48) < 0.001

	# Absent ozone keeps the power-only fold: no "liquids"
	# key at all, and an empty liquids dict, both report
	# has_ozone_row false with an empty row -- and folding
	# the power row alone keeps min_efficiency 0.9 with
	# should_consume_power true, so a live tower with no
	# liquid observation keeps healing.
	frame = {}
	row = repair_tower_build_state.source_repair_tower_ozone_row_state(frame, delta)
	var absent_no_key: bool = not bool(row.get("has_ozone_row", true)) and (row.get("row", {}) as Dictionary).is_empty()
	frame = {"liquids": {}}
	row = repair_tower_build_state.source_repair_tower_ozone_row_state(frame, delta)
	var absent_empty_dict: bool = not bool(row.get("has_ozone_row", true)) and (row.get("row", {}) as Dictionary).is_empty()
	var power_only: Dictionary = building_efficiency_state.update_consumption_non_optional_pass_state([{"result": 0.9, "is_power": true}])
	proof["ozone_row_absent_preserves_power_only"] = absent_no_key and absent_empty_dict and abs(float(power_only.get("min_efficiency", -1.0)) - 0.9) < 0.0001 and bool(power_only.get("should_consume_power", false))

	# Drains per tick while efficiency is positive: 0.05 *
	# 1.0 * (1/60) = 0.0008333 out of a 1.0 stock.
	frame = {"efficiency": 1.0, "enabled": true, "liquids": {"ozone": 1.0}}
	var consume: Dictionary = repair_tower_build_state.source_repair_tower_ozone_consume_state(frame, delta)
	var liquids: Dictionary = consume.get("liquids", {})
	proof["ozone_drains_per_tick_while_efficiency_positive"] = abs(float(consume.get("ozone_drained", -1.0)) - 0.0008333) < 0.00001 and abs(float(liquids.get("ozone", -1.0)) - 0.9991667) < 0.00001

	# No drain at zero efficiency: the second-pass gate
	# (`if(update && efficiency > 0){`,
	# BuildingComp.java:1997) blocks the drain, the stock
	# stays 1.0.
	frame = {"efficiency": 0.0, "enabled": true, "liquids": {"ozone": 1.0}}
	consume = repair_tower_build_state.source_repair_tower_ozone_consume_state(frame, delta)
	liquids = consume.get("liquids", {})
	proof["no_drain_when_efficiency_zero"] = abs(float(consume.get("ozone_drained", -1.0)) - 0.0) < 0.0001 and abs(float(liquids.get("ozone", -1.0)) - 1.0) < 0.0001

	# Drain clamps at the stock: 0.0005 on hand is less
	# than the 0.0008333 requested, so only 0.0005 drains
	# and the tank ends at exactly 0.0, never negative.
	frame = {"efficiency": 1.0, "enabled": true, "liquids": {"ozone": 0.0005}}
	consume = repair_tower_build_state.source_repair_tower_ozone_consume_state(frame, delta)
	liquids = consume.get("liquids", {})
	proof["drain_clamps_at_stock"] = abs(float(consume.get("ozone_drained", -1.0)) - 0.0005) < 0.00001 and abs(float(liquids.get("ozone", -1.0)) - 0.0) < 0.0001

	# An observed empty tank clears should_consume_power:
	# stock 0.0 folds to result 0.0, and a non-power row <=
	# 1e-7 clears the flag (`if(cons != block.consPower &&
	# result <= 0.0000001f){`, BuildingComp.java:1972-1974),
	# so the folded min efficiency is 0.0.
	frame = {"liquids": {"ozone": 0.0}, "efficiency_scale": 1.0}
	row = repair_tower_build_state.source_repair_tower_ozone_row_state(frame, delta)
	var ozone_row: Dictionary = row.get("row", {})
	var fold: Dictionary = building_efficiency_state.update_consumption_non_optional_pass_state([{"result": 1.0, "is_power": true}, ozone_row])
	proof["ozone_empty_clears_should_consume_power"] = bool(row.get("has_ozone_row", false)) and abs(float(ozone_row.get("result", -1.0)) - 0.0) < 0.0001 and not bool(fold.get("should_consume_power", true)) and abs(float(fold.get("min_efficiency", -1.0)) - 0.0) < 0.0001

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerOzoneConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
