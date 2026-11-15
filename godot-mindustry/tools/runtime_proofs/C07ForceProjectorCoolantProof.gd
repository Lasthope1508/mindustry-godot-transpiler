extends Node

const main_scene := preload("res://scenes/Main.tscn")
const force_projector_build_state := preload("res://src/game/SourceForceProjectorBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure coolant row (N2258): ConsumeLiquidFilter.efficiency
	# (ConsumeLiquidFilter.java:50-55, `float ed = build.edelta();`
	# -- NO efficiencyScale factor, unlike ConsumeLiquid -- /
	# `if(ed <= 0.00000001f) return 0f;` / `return liq != null ?
	# Math.min(build.liquids.get(liq) / (amount * ed *
	# multiplier.get(build)), 1f) : 0f;`), with the getConsumed
	# preference (ConsumeLiquidFilter.java:63-76, current liquid
	# first, then content order) and the ConsumeCoolant filter
	# (ConsumeCoolant.java:12, coolant + non-gas + temp <= 0.5 +
	# flammability < 0.1). In the first pass efficiency is
	# assumed 1f (BuildingComp.java:1965), so edelta is delta()
	# = source_delta * time_scale. The amount is the 0.1f class
	# default (ForceProjector.java:43), per frame. The row is
	# OPTIONAL (.boost().update(false), ForceProjector.java:85)
	# and folds into the optional pass (BuildingComp.java:
	# 1979-1981), not the min efficiency.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var coolant_props: Dictionary = force_projector_build_state.source_force_projector_liquid_catalog_props_state(catalog)
	var liquid_props_by_id: Dictionary = coolant_props.get("liquid_props_by_id", {})
	var liquid_order: Array = coolant_props.get("liquid_order", [])
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var slag_id: int = int(liquid_id_by_name.get("slag", -1))
	var oil_id: int = int(liquid_id_by_name.get("oil", -1))
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var neoplasm_id: int = int(liquid_id_by_name.get("neoplasm", -1))
	var arkycite_id: int = int(liquid_id_by_name.get("arkycite", -1))
	var gallium_id: int = int(liquid_id_by_name.get("gallium", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var coolant_amount: float = 0.1

	# Starved: half the per-frame demand of water -> row 0.5,
	# non-power, consumed water; full: plenty of water -> 1.0.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, water_id, 0.5 * coolant_amount)
	var starved_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": starved_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, water_id, 10.0)
	var full_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": full_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	proof["coolant_row_folds_optional_when_present"] = bool(starved_row.get("has_coolant_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.5) and not bool(starved_row.get("row", {}).get("is_power", true)) and int(starved_row.get("consumed_liquid", -1)) == water_id and bool(full_row.get("has_coolant_row", false)) and is_equal_approx(float(full_row.get("row", {}).get("result", -1.0)), 1.0) and int(full_row.get("consumed_liquid", -1)) == water_id

	# No coolant at all: oil (flam 1.2) + slag (temp 1.0) +
	# neoplasm (temp 0.54) + arkycite (flam 0.4) + gallium
	# (coolant=false) + hydrogen (gas) all fail the filter, so
	# getConsumed is null and the row is 0.
	var rejected_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(rejected_liquids, oil_id, 1.0)
	liquid_module_state.source_set_state(rejected_liquids, slag_id, 1.0)
	liquid_module_state.source_set_state(rejected_liquids, neoplasm_id, 1.0)
	liquid_module_state.source_set_state(rejected_liquids, arkycite_id, 1.0)
	liquid_module_state.source_set_state(rejected_liquids, gallium_id, 1.0)
	liquid_module_state.source_set_state(rejected_liquids, hydrogen_id, 1.0)
	var rejected_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": rejected_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	proof["filter_rejects_non_coolant"] = bool(rejected_row.get("has_coolant_row", false)) and rejected_row.get("consumed_liquid", -1) == null and is_equal_approx(float(rejected_row.get("row", {}).get("result", -1.0)), 0.0)

	# getConsumed prefers the current liquid: current cryofluid
	# with water + cryofluid present -> cryofluid. A
	# non-coolant current (oil) falls through to the first
	# liquid in content order that passes: water.
	var current_cryo_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(current_cryo_liquids, water_id, 1.0)
	liquid_module_state.source_set_state(current_cryo_liquids, cryofluid_id, 1.0)
	var current_cryo_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": current_cryo_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	var current_oil_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(current_oil_liquids, water_id, 1.0)
	liquid_module_state.source_set_state(current_oil_liquids, cryofluid_id, 1.0)
	liquid_module_state.source_set_state(current_oil_liquids, oil_id, 2.0)
	var current_oil_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": current_oil_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	proof["get_consumed_prefers_current_liquid"] = int(current_cryo_row.get("consumed_liquid", -1)) == cryofluid_id and int(current_oil_row.get("consumed_liquid", -1)) == water_id

	# --- Pure advance (N2235 + N2258): the buildup scale uses
	# the CURRENT liquid's heatCapacity (ForceProjector.java:230,
	# `liquids.current().heatCapacity` -- current, not the
	# consumed liquid): with cryofluid current (0.9f) the scale
	# is 1.5 * 1.2 * (1 + (0.9 - 0.4) * 0.9) = 2.61, so buildup
	# 100 -> 97.39; with water current (0.4f) the scale is 1.5 *
	# 1.2 = 1.8, so 100 -> 98.2. The coolant inputs arrive on
	# the frame (the N2258 driver stamps them; the advance
	# prefers frame values when present). The advance reports
	# the consumption: 0.1f * edelta (folded efficiency 1.0) =
	# 0.1 of the consumed liquid.
	var cryo_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 100.0, "broken": false, "hit": 0.0, "coolant_present": true, "coolant_efficiency": 1.0, "coolant_heat_capacity": 0.9, "coolant_liquid_id": cryofluid_id, "coolant_amount": coolant_amount}
	var cryo_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(cryo_frame, 1.0, 1.0, 0.0, 0.0, [], false)
	var water_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 100.0, "broken": false, "hit": 0.0, "coolant_present": true, "coolant_efficiency": 1.0, "coolant_heat_capacity": 0.4, "coolant_liquid_id": water_id, "coolant_amount": coolant_amount}
	var water_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(water_frame, 1.0, 1.0, 0.0, 0.0, [], false)
	proof["buildup_scale_uses_current_heat_capacity"] = is_equal_approx(float(cryo_advanced.get("buildup", -1.0)), 97.39) and is_equal_approx(float(water_advanced.get("buildup", -1.0)), 98.2) and int(cryo_advanced.get("coolant_consumed_liquid", -1)) == cryofluid_id and is_equal_approx(float(cryo_advanced.get("coolant_consumed_amount", -1.0)), 0.1)

	# No coolant: the plain cooldownNormal scale (1.5), so
	# buildup 100 -> 98.5, and the advance reports no
	# consumption (liquid -1, amount 0.0).
	var no_coolant_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 100.0, "broken": false, "hit": 0.0}
	var no_coolant_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(no_coolant_frame, 1.0, 1.0, 0.0, 0.0, [], false)
	proof["no_coolant_no_scale"] = is_equal_approx(float(no_coolant_advanced.get("buildup", -1.0)), 98.5) and int(no_coolant_advanced.get("coolant_consumed_liquid", -2)) == -1 and is_equal_approx(float(no_coolant_advanced.get("coolant_consumed_amount", -1.0)), 0.0)

	# --- Live tick: two placed force-projectors, both with 1.0
	# water at full power (efficiency folds 1.0). The one with
	# buildup 100 consumes one frame's demand (0.1f * folded
	# edelta 1.0 = 0.1) in the manual updateTile consume
	# (ForceProjector.java:227-231); the one with buildup 0
	# consumes nothing -- removal only happens inside
	# `if(buildup > 0){`. The tick driver is called directly
	# (as the N2147/N2148/N2149/N2150/N2153/N2154/N2155/N2156/
	# N2157/N2158/N2159/N2160/N2161/N2162/N2163/N2164/N2165/
	# N2166/N2167/N2168 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The water amounts are set on the sprite
	# liquids meta store (the live LiquidModule), which the
	# driver syncs into the frame each tick before the fold
	# (the Fracker proof precedent).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var hot_cell := Vector2i(28, 21)
	var hot := Sprite2D.new()
	game.add_child(hot)
	game.call("record_placed_block", hot, blocks_by_id["force-projector"], hot_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(hot, blocks_by_id["force-projector"])
	var hot_frame: Dictionary = hot.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var hot_liquids: Dictionary = hot.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(hot_liquids, water_id, 1.0)
	hot_frame["power_status"] = 1.0
	hot_frame["buildup"] = 100.0
	hot_frame["broken"] = false

	var cold_cell := Vector2i(20, 10)
	var cold := Sprite2D.new()
	game.add_child(cold)
	game.call("record_placed_block", cold, blocks_by_id["force-projector"], cold_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(cold, blocks_by_id["force-projector"])
	var cold_frame: Dictionary = cold.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var cold_liquids: Dictionary = cold.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(cold_liquids, water_id, 1.0)
	cold_frame["power_status"] = 1.0
	cold_frame["buildup"] = 0.0
	cold_frame["broken"] = false

	force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)
	hot_frame = hot.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	hot_liquids = hot.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	cold_frame = cold.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	cold_liquids = cold.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_consumes_coolant_only_when_buildup"] = is_equal_approx(float(liquid_module_state.source_get_state(hot_liquids, water_id).get("amount", -1.0)), 0.9) and is_equal_approx(float(hot_frame.get("coolant_consumed_amount", -1.0)), 0.1) and is_equal_approx(float(hot_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(cold_liquids, water_id).get("amount", -1.0)), 1.0) and is_equal_approx(float(cold_frame.get("coolant_consumed_amount", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorCoolantProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
