extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")


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

	# --- Pure coolant row (N2259): ConsumeLiquidFilter.efficiency
	# (ConsumeLiquidFilter.java:50-55, `float ed = build.edelta();`
	# / `if(ed <= 0.00000001f) return 0f;` / `return liq != null ?
	# Math.min(build.liquids.get(liq) / (amount * ed *
	# multiplier.get(build)), 1f) : 0f;`), folded by the OPTIONAL
	# pass (BuildingComp.java:1979-1981) into optionalEfficiency.
	# Unlike ConsumeLiquid.efficiency the filter ed is NOT
	# multiplied by efficiencyScale. The def amount is 0.16f per
	# frame (Blocks.java:6405, `coolantUse = 0.16f;`) and the
	# multiplier is the Consume default 1f (Consume.java:18).
	# getConsumed (ConsumeLiquidFilter.java:63-76) prefers the
	# current liquid, then the first filter match in content
	# order, else null.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog["liquid_id_by_name"]
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var cryo_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var neoplasm_id: int = int(liquid_id_by_name.get("neoplasm", -1))
	var arkycite_id: int = int(liquid_id_by_name.get("arkycite", -1))
	var gallium_id: int = int(liquid_id_by_name.get("gallium", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var nitrogen_id: int = int(liquid_id_by_name.get("nitrogen", -1))
	var cyanogen_id: int = int(liquid_id_by_name.get("cyanogen", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]
	var liquid_props_by_id: Array = []
	for liquid in catalog.get_many("liquid"):
		liquid_props_by_id.append(liquid.properties)
	var coolant_amount: float = repair_turret_build_state.SOURCE_REPAIR_TURRET_COOLANT_AMOUNT

	# Starved: 0.08 water against 0.16 per frame at edelta 1.0
	# folds to 0.5, the row is not power, and getConsumed picks
	# the current water.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, water_id, 0.08)
	var starved_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": starved_liquids}, true, liquid_props_by_id, coolant_amount, 1.0, 1.0, 1.0)
	var starved_ok: bool = bool(starved_row.get("has_coolant_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and bool(starved_row.get("row", {}).get("is_power", true)) == false and int(starved_row.get("consumed_liquid", -2)) == water_id

	# Current preference: current cryofluid 0.08 wins over 10.0
	# water (the store current is set directly: source_set_state
	# only switches current when the new amount beats the old).
	var pref_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(pref_liquids, water_id, 10.0)
	liquid_module_state.source_set_state(pref_liquids, cryo_id, 0.08)
	pref_liquids["current"] = cryo_id
	var pref_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": pref_liquids}, true, liquid_props_by_id, coolant_amount, 1.0, 1.0, 1.0)
	var pref_ok: bool = is_equal_approx(float(pref_row.get("row", {}).get("result", -1.0)), 0.5) and int(pref_row.get("consumed_liquid", -2)) == cryo_id

	# Content-order fallback: current oil fails the filter, so
	# getConsumed scans content order and picks the 0.08 water
	# (water precedes cryofluid in the catalog).
	var fallback_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(fallback_liquids, water_id, 0.08)
	liquid_module_state.source_set_state(fallback_liquids, oil_id, 10.0)
	var fallback_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": fallback_liquids}, true, liquid_props_by_id, coolant_amount, 1.0, 1.0, 1.0)
	var fallback_ok: bool = is_equal_approx(float(fallback_row.get("row", {}).get("result", -1.0)), 0.5) and int(fallback_row.get("consumed_liquid", -2)) == water_id

	# No coolant: oil alone (current, 10.0) matches nothing, so
	# getConsumed is null and the row folds to 0.0.
	var oil_only_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(oil_only_liquids, oil_id, 10.0)
	var oil_only_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": oil_only_liquids}, true, liquid_props_by_id, coolant_amount, 1.0, 1.0, 1.0)
	var oil_only_ok: bool = is_equal_approx(float(oil_only_row.get("row", {}).get("result", -1.0)), 0.0) and int(oil_only_row.get("consumed_liquid", -2)) == -1

	# Zero edelta: ed <= 0.00000001f returns 0f even with a full
	# store.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, water_id, 10.0)
	var zero_edelta_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": full_liquids}, true, liquid_props_by_id, coolant_amount, 0.0, 1.0, 1.0)
	var zero_edelta_ok: bool = is_equal_approx(float(zero_edelta_row.get("row", {}).get("result", -1.0)), 0.0)
	proof["coolant_row_folds_optional_when_present"] = starved_ok and pref_ok and fallback_ok and oil_only_ok and zero_edelta_ok

	# --- Filter (N2259): ConsumeCoolant.java:12 with the
	# Liquid.java defaults -- only water + cryofluid pass. An
	# empty props dict passes too (every default passes: coolant
	# true, gas false, temp 0.5, flam 0).
	var filter_pass := func(liquid_id: int) -> bool:
		return bool(repair_turret_build_state.source_repair_turret_coolant_filter_state(liquid_props_by_id[liquid_id]).get("passes", false))
	var defaults_pass: bool = bool(repair_turret_build_state.source_repair_turret_coolant_filter_state({}).get("passes", false))
	proof["filter_rejects_non_coolant"] = filter_pass.call(water_id) and filter_pass.call(cryo_id) and defaults_pass and not filter_pass.call(slag_id) and not filter_pass.call(oil_id) and not filter_pass.call(neoplasm_id) and not filter_pass.call(arkycite_id) and not filter_pass.call(gallium_id) and not filter_pass.call(ozone_id) and not filter_pass.call(hydrogen_id) and not filter_pass.call(nitrogen_id) and not filter_pass.call(cyanogen_id)

	# --- Multiplier (N2259): `multiplier = 1f + liquids.current().
	# heatCapacity * coolantMultiplier * optionalEfficiency;`
	# (RepairTurret.java:190, coolantMultiplier 1.6f). Water 0.4
	# -> 1.64, cryofluid 0.9 -> 2.44, Liquid default 0.5 -> 1.8,
	# all at optionalEfficiency 1.0; water at 0.5 -> 1.32; any
	# heat capacity at optionalEfficiency 0 -> 1.0.
	var mult := func(heat_capacity: float, optional_efficiency: float) -> float:
		return float(repair_turret_build_state.source_repair_turret_coolant_multiplier_state(heat_capacity, optional_efficiency).get("multiplier", -1.0))
	proof["multiplier_uses_current_heat_capacity"] = is_equal_approx(mult.call(0.4, 1.0), 1.64) and is_equal_approx(mult.call(0.9, 1.0), 2.44) and is_equal_approx(mult.call(0.5, 1.0), 1.8) and is_equal_approx(mult.call(0.4, 0.5), 1.32) and is_equal_approx(mult.call(0.9, 0.0), 1.0)

	# --- repair-point (N2259): acceptCoolant=false
	# (RepairTurret.java:39), so the pure row reports no row;
	# the live half of this key is checked after the tick below.
	var point_row: Dictionary = repair_turret_build_state.source_repair_turret_coolant_row_state({"liquids": full_liquids}, false, liquid_props_by_id, coolant_amount, 1.0, 1.0, 1.0)
	var repair_point_pure: bool = bool(point_row.get("has_coolant_row", true)) == false

	# --- Live tick: two repair-turrets + one repair-point placed
	# live; the tick driver is called directly (as the N2174 /
	# N2250 proofs do), not simulate_factory, so the graph update
	# does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. Turret A
	# (starved water 0.08, full power) folds optionalEfficiency
	# 0.5 while efficiency stays 1.0 -- the coolant row is
	# OPTIONAL, so it never lowers the min efficiency -- and
	# heals with multiplier 1 + 0.4 * 1.6 * 0.5 = 1.32, so
	# heal_amount = 3.0 * 1.0 * 1.0 * 1.32 = 3.96. Turret B
	# (water 0.32, full power) folds optionalEfficiency 1.0 and
	# the second pass removes 0.16 * 1.0 * 1.0 = 0.16 water,
	# leaving 0.16 (ConsumeLiquidFilter.java:42-47,
	# BuildingComp.java:1999-2000), healing with multiplier 1.64
	# for heal_amount 4.92. Repair-point C (no coolant row)
	# folds optionalEfficiency 1.0 and heals with multiplier 1.0
	# for heal_amount 0.45. The water amounts are set on the
	# sprite liquids meta store (the live LiquidModule), which
	# the driver syncs into the frame each tick.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	# Building positions: tile.drawx()/drawy() with the block
	# offset (Block.java:761) -- 4 for the size-2 repair-turret,
	# 0 for the size-1 repair-point. Each target sits 10 units
	# east of its building (angle 0, rotation 0, within the 30
	# degree heal margin), damaged, in range.
	var turret_a_cell := Vector2i(28, 21)
	var turret_a := Sprite2D.new()
	game.add_child(turret_a)
	game.call("record_placed_block", turret_a, blocks_by_id["repair-turret"], turret_a_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	repair_turret_build_state.source_repair_turret_bind_frame_state(turret_a, blocks_by_id["repair-turret"])
	var turret_a_frame: Dictionary = turret_a.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	# RepairTurret.init sets hasLiquids for acceptCoolant (Java:84-86);
	# initialize that source-backed fixture module before supplying coolant.
	placed_block_state.source_initialize_building_liquids_state(turret_a, true, catalog)
	var turret_a_liquids: Dictionary = turret_a.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(turret_a_liquids, water_id, 0.08)

	var turret_b_cell := Vector2i(20, 10)
	var turret_b := Sprite2D.new()
	game.add_child(turret_b)
	game.call("record_placed_block", turret_b, blocks_by_id["repair-turret"], turret_b_cell)
	repair_turret_build_state.source_repair_turret_bind_frame_state(turret_b, blocks_by_id["repair-turret"])
	var turret_b_frame: Dictionary = turret_b.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	# RepairTurret.init sets hasLiquids for acceptCoolant (Java:84-86);
	# initialize that source-backed fixture module before supplying coolant.
	placed_block_state.source_initialize_building_liquids_state(turret_b, true, catalog)
	var turret_b_liquids: Dictionary = turret_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(turret_b_liquids, water_id, 0.32)

	var point_c_cell := Vector2i(12, 30)
	var point_c := Sprite2D.new()
	game.add_child(point_c)
	game.call("record_placed_block", point_c, blocks_by_id["repair-point"], point_c_cell)
	repair_turret_build_state.source_repair_turret_bind_frame_state(point_c, blocks_by_id["repair-point"])
	var point_c_frame: Dictionary = point_c.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})

	# N2212: the shouldConsume gate (RepairTurret.java:222,
	# `return target != null && enabled;`) closes with no target,
	# so all three hold a target fixture -- otherwise efficiency
	# would read 0. Strength 1.0 and rotation 0.0 so the heal
	# branch runs at full strength on the angle-0 target.
	turret_a_frame["target"] = {"x": 238.0, "y": 172.0, "distance": 10.0, "dead": false, "health": 50.0, "max_health": 100.0}
	turret_b_frame["target"] = {"x": 174.0, "y": 84.0, "distance": 10.0, "dead": false, "health": 50.0, "max_health": 100.0}
	point_c_frame["target"] = {"x": 106.0, "y": 240.0, "distance": 10.0, "dead": false, "health": 50.0, "max_health": 100.0}
	turret_a_frame["strength"] = 1.0
	turret_b_frame["strength"] = 1.0
	point_c_frame["strength"] = 1.0
	turret_a_frame["rotation"] = 0.0
	turret_b_frame["rotation"] = 0.0
	point_c_frame["rotation"] = 0.0

	turret_a_frame["power_status"] = 1.0
	turret_b_frame["power_status"] = 1.0
	point_c_frame["power_status"] = 1.0
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	turret_a_frame = turret_a.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	turret_b_frame = turret_b.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	point_c_frame = point_c.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["live_tick_folds_coolant_row"] = is_equal_approx(float(turret_a_frame.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(turret_a_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(turret_a_frame.get("heal_amount", -1.0)), 3.96)
	turret_b_liquids = turret_b.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_coolant_when_running"] = is_equal_approx(float(turret_b_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(turret_b_frame.get("optional_efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(turret_b_liquids, water_id).get("amount", -1.0)), 0.16) and is_equal_approx(float(turret_b_frame.get("heal_amount", -1.0)), 4.92)
	proof["repair_point_has_no_coolant_row"] = repair_point_pure and is_equal_approx(float(point_c_frame.get("optional_efficiency", -1.0)), 1.0) and is_equal_approx(float(point_c_frame.get("heal_amount", -1.0)), 0.45)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretCoolantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
