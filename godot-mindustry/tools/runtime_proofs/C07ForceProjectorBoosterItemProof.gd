extends Node

const main_scene := preload("res://scenes/Main.tscn")
const force_projector_build_state := preload("res://src/game/SourceForceProjectorBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure item row (N2261): ConsumeItems.efficiency
	# (ConsumeItems.java:51-53, `return build.consumeTriggerValid()
	# || build.items.has(items, multiplier.get(build)) ? 1f : 0f;`),
	# BINARY 1/0 -- NOT a ratio like ConsumeLiquid.
	# consumeTriggerValid() base returns false
	# (BuildingComp.java:764-766, `public boolean
	# consumeTriggerValid(){` / `return false;`, and no
	# ForceProjector override -- grep), so the row is 1.0 only
	# when the frame holds every stack: items.has(ItemStack[],
	# float) (ItemModule.java:153-158) requires EVERY stack to
	# hold round(amount * multiplier), with has(item, amount)
	# = get(item) >= amount (ItemModule.java:126-128). The
	# single stack is 1 phaseFabric (Blocks.java:1974,
	# `itemConsumer = consumeItem(Items.phaseFabric).boost();`;
	# consumeItem(item) is ItemStack(item, 1),
	# Block.java:1167-1168). The row is OPTIONAL (.boost() is
	# `return optional(true, true);`, Consume.java:33-35) and
	# folds into the optional pass (BuildingComp.java:
	# 1980-1981), capped by minEfficiency (BuildingComp.java:
	# 1986) -- never the min efficiency, never
	# shouldConsumePower. phaseValid reads the row DIRECTLY
	# (ForceProjector.java:207, `boolean phaseValid =
	# itemConsumer != null && itemConsumer.efficiency(this) >
	# 0;`), so the row also reports item_valid.
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var content_liquid_ids: Array = liquid_catalog.get("content_liquid_ids", [])
	var coolant_props: Dictionary = force_projector_build_state.source_force_projector_liquid_catalog_props_state(catalog)
	var liquid_props_by_id: Dictionary = coolant_props.get("liquid_props_by_id", {})
	var liquid_order: Array = coolant_props.get("liquid_order", [])
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var coolant_amount: float = 0.1
	var item_stacks: Array = [{"item": "phase-fabric", "amount": 1}]

	# Present: exactly 1 phaseFabric -> row 1.0, non-power,
	# item_valid true. Surplus (5) still 1.0 -- the row is
	# binary, not a ratio. No item consumer -> no row at all.
	var present_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, true, item_stacks)
	var surplus_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {"phase-fabric": 5}}, true, item_stacks)
	var no_consumer_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, false, item_stacks)
	proof["item_row_binary_one_when_present"] = bool(present_row.get("has_item_row", false)) and is_equal_approx(float(present_row.get("row", {}).get("result", -1.0)), 1.0) and not bool(present_row.get("row", {}).get("is_power", true)) and bool(present_row.get("item_valid", false)) and is_equal_approx(float(surplus_row.get("row", {}).get("result", -1.0)), 1.0) and bool(surplus_row.get("item_valid", false)) and not bool(no_consumer_row.get("has_item_row", true)) and Dictionary(no_consumer_row.get("row", {"x": 1})).is_empty() and not bool(no_consumer_row.get("item_valid", true))

	# Absent: empty items -> 0.0, item_valid false; 0 held ->
	# 0.0; the wrong item (silicon) -> 0.0.
	var empty_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {}}, true, item_stacks)
	var zero_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {"phase-fabric": 0}}, true, item_stacks)
	var wrong_item_row: Dictionary = force_projector_build_state.source_force_projector_item_consumer_row_state({"items": {"silicon": 10}}, true, item_stacks)
	proof["item_row_zero_when_absent"] = bool(empty_row.get("has_item_row", false)) and is_equal_approx(float(empty_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(empty_row.get("item_valid", true)) and is_equal_approx(float(zero_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(zero_row.get("item_valid", true)) and is_equal_approx(float(wrong_item_row.get("row", {}).get("result", -1.0)), 0.0) and not bool(wrong_item_row.get("item_valid", true))

	# --- Optional fold: the shared machinery mins over BOTH
	# optional rows (BuildingComp.java:1980-1981). Starved
	# coolant (0.5) + fabric present (1.0) -> 0.5; full
	# coolant (1.0) + fabric absent (0.0) -> 0.0. The item
	# row is what zeroes optionalEfficiency when the fabric
	# runs out -- the coolant alone would fold 1.0.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, water_id, 0.5 * coolant_amount)
	var starved_coolant_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": starved_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(full_liquids, water_id, 10.0)
	var full_coolant_row: Dictionary = force_projector_build_state.source_force_projector_coolant_consumer_row_state({"liquids": full_liquids}, true, liquid_props_by_id, liquid_order, coolant_amount, 1.0, 1.0, 1.0)
	var starved_fold: Dictionary = building_efficiency_state.update_consumption_optional_pass_state([starved_coolant_row.get("row", {}), present_row.get("row", {})])
	var dry_fold: Dictionary = building_efficiency_state.update_consumption_optional_pass_state([full_coolant_row.get("row", {}), empty_row.get("row", {})])
	proof["optional_folds_min_of_coolant_and_item"] = is_equal_approx(float(starved_fold.get("optional_efficiency", -1.0)), 0.5) and is_equal_approx(float(dry_fold.get("optional_efficiency", -1.0)), 0.0)

	# --- Pure advance (N2235 + N2261): phaseValid follows the
	# item row (ForceProjector.java:207, `boolean phaseValid =
	# itemConsumer != null && itemConsumer.efficiency(this) >
	# 0;`): present + efficiency 1.0 -> phaseHeat rises
	# (0.0 -> 0.1 at delta 1.0); present + efficiency 0.0 ->
	# phaseHeat decays (0.5 -> 0.45); ABSENT + efficiency 1.0
	# -> phaseValid is still false (the null half of the
	# conjunction), so phaseHeat decays too (0.5 -> 0.45).
	# The explicit params drive the branch here (a proof frame
	# carries no item keys, so the N2261 frame fallback does
	# not apply).
	var valid_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var valid_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(valid_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var invalid_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.5, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var invalid_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(invalid_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 0.0)
	var absent_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.5, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var absent_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(absent_frame, 1.0, 1.0, 0.0, 0.0, [], false, false, 1.0)
	proof["phase_valid_follows_item_row"] = is_equal_approx(float(valid_advanced.get("phase_heat", -1.0)), 0.1) and is_equal_approx(float(invalid_advanced.get("phase_heat", -1.0)), 0.45) and is_equal_approx(float(absent_advanced.get("phase_heat", -1.0)), 0.45)

	# phaseHeat lerps toward num(phaseValid) (ForceProjector.
	# java:209, `phaseHeat = Mathf.lerpDelta(phaseHeat,
	# Mathf.num(phaseValid), 0.1f);`): from 0.0 toward 1.0 ->
	# 0.1; from 1.0 toward 0.0 -> 0.9 (lerpDelta factor
	# clamp(0.1 * delta 1.0) = 0.1).
	var heat_up_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 0.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var heat_up_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(heat_up_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 1.0)
	var heat_down_frame: Dictionary = {"efficiency": 1.0, "team_id": 0, "phase_heat": 1.0, "radscl": 0.0, "warmup": 0.0, "buildup": 0.0, "broken": false, "hit": 0.0}
	var heat_down_advanced: Dictionary = force_projector_build_state.source_force_projector_update_tile_advance_state(heat_down_frame, 1.0, 1.0, 0.0, 0.0, [], false, true, 0.0)
	proof["phase_heat_lerps_toward_phase_valid"] = is_equal_approx(float(heat_up_advanced.get("phase_heat", -1.0)), 0.1) and is_equal_approx(float(heat_down_advanced.get("phase_heat", -1.0)), 0.9)

	# --- Live tick: two placed force-projectors, both with 1.0
	# water at full power (coolant row 1.0, efficiency folds
	# 1.0). The one holding 1 phaseFabric folds
	# optionalEfficiency 1.0 and its phaseHeat rises toward 1
	# (0.0 -> 0.1 in one tick); the one with no fabric folds
	# optionalEfficiency 0.0 (the item row zeroes the optional
	# min) and its phaseHeat stays 0.0. Both keep efficiency
	# 1.0 -- the booster row never touches the min efficiency
	# (BuildingComp.java:1972-1973 runs only over
	# nonOptionalConsumers). The tick driver is called
	# directly (as the N2147/N2148/N2149/N2150/N2153/N2154/
	# N2155/N2156/N2157/N2158/N2159/N2160/N2161/N2162/N2163/
	# N2164/N2165/N2166/N2167/N2168/N2258 proofs do), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The items are set on
	# the frame dict (no live intake fills frame["items"] yet,
	# the Separator precedent -- the row reads the frame
	# as-is); the water amounts are set on the sprite liquids
	# meta store, which the driver syncs into the frame each
	# tick before the fold (the Fracker proof precedent).
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var stocked_cell := Vector2i(28, 21)
	var stocked := Sprite2D.new()
	game.add_child(stocked)
	game.call("record_placed_block", stocked, blocks_by_id["force-projector"], stocked_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(stocked, blocks_by_id["force-projector"])
	var stocked_frame: Dictionary = stocked.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var stocked_liquids: Dictionary = stocked.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(stocked_liquids, water_id, 1.0)
	stocked_frame["power_status"] = 1.0
	stocked_frame["items"] = {"phase-fabric": 1}
	stocked_frame["buildup"] = 0.0
	stocked_frame["broken"] = false

	var dry_cell := Vector2i(20, 10)
	var dry := Sprite2D.new()
	game.add_child(dry)
	game.call("record_placed_block", dry, blocks_by_id["force-projector"], dry_cell)
	force_projector_build_state.source_force_projector_bind_frame_state(dry, blocks_by_id["force-projector"])
	var dry_frame: Dictionary = dry.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	var dry_liquids: Dictionary = dry.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(dry_liquids, water_id, 1.0)
	dry_frame["power_status"] = 1.0
	dry_frame["items"] = {}
	dry_frame["buildup"] = 0.0
	dry_frame["broken"] = false

	force_projector_build_state.source_force_projector_tick_buildings_state(game, 1.0 / 60.0)
	stocked_frame = stocked.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	dry_frame = dry.get_meta(force_projector_build_state.SOURCE_FORCE_PROJECTOR_BUILDING_META_KEY, {})
	proof["live_tick_folds_item_row"] = is_equal_approx(float(stocked_frame.get("optional_efficiency", -1.0)), 1.0) and is_equal_approx(float(stocked_frame.get("phase_heat", -1.0)), 0.1) and is_equal_approx(float(stocked_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(dry_frame.get("optional_efficiency", -1.0)), 0.0) and is_equal_approx(float(dry_frame.get("phase_heat", -1.0)), 0.0) and is_equal_approx(float(dry_frame.get("efficiency", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07ForceProjectorBoosterItemProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
