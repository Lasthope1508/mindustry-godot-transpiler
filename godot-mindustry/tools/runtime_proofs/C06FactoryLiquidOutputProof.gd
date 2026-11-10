extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const registry := preload("res://src/game/SourceSsotAccessorRuntimeState.gd")
const proof_state := preload("res://tools/runtime_proofs/RuntimeProofState.gd")


func _fresh_module(max_id: int, pairs: Dictionary) -> Dictionary:
	var amounts: Array = []
	for i in range(max_id + 1):
		amounts.append(0.0)
	for liquid_id in pairs.keys():
		amounts[int(liquid_id)] = float(pairs[liquid_id])
	return {"liquids": amounts, "current": 0, "flow": null}


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

	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var liquid_id_by_name: Dictionary = liquid_catalog.get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))
	var cryofluid_id: int = int(liquid_id_by_name.get("cryofluid", -1))
	var ozone_id: int = int(liquid_id_by_name.get("ozone", -1))
	var hydrogen_id: int = int(liquid_id_by_name.get("hydrogen", -1))
	var max_liquid_id := 0
	for liquid_id in liquid_id_by_name.values():
		max_liquid_id = maxi(max_liquid_id, int(liquid_id))

	# --- registry: the mixer outputs cryofluid 12f/60f per tick
	# (Blocks.java:1170) into a 36.0 liquid capacity with craftTime
	# 120 (Blocks.java:1181); the electrolyzer outputs ozone 4f/60
	# and hydrogen 6f/60 (Blocks.java:1394). ---
	var mixer = blocks_by_id["cryofluid-mixer"]
	proof["liquid_mixer_is_generic_crafter"] = String(mixer.implementation) == "GenericCrafter"
	proof["liquid_mixer_craft_time_120"] = is_equal_approx(float(mixer.properties.get("craftTime", -1.0)), 120.0)
	proof["liquid_mixer_liquid_capacity_36"] = is_equal_approx(float(mixer.properties.get("liquidCapacity", -1.0)), 36.0)
	var mixer_outputs: Array = mixer.properties.get("outputLiquids", [])
	proof["liquid_mixer_output_cryofluid"] = mixer_outputs.size() == 1 and String(mixer_outputs[0].get("liquid", "")) == "cryofluid" and is_equal_approx(float(mixer_outputs[0].get("amount", -1.0)), 12.0 / 60.0)
	var electrolyzer = blocks_by_id["electrolyzer"]
	var electrolyzer_outputs: Array = electrolyzer.properties.get("outputLiquids", [])
	proof["liquid_electrolyzer_output_two_rows"] = electrolyzer_outputs.size() == 2
	proof["liquid_electrolyzer_output_ozone"] = is_equal_approx(float(electrolyzer_outputs[0].get("amount", -1.0)), 4.0 / 60.0) and String(electrolyzer_outputs[0].get("liquid", "")) == "ozone"
	proof["liquid_electrolyzer_output_hydrogen"] = is_equal_approx(float(electrolyzer_outputs[1].get("amount", -1.0)), 6.0 / 60.0) and String(electrolyzer_outputs[1].get("liquid", "")) == "hydrogen"

	# --- warmupTarget: GenericCrafterBuild.warmupTarget()
	# (GenericCrafter.java:287-289) returns 1f; a null block has no
	# target. ---
	var mixer_target: Dictionary = factory_build_state.source_factory_warmup_target_state(mixer)
	proof["liquid_warmup_target_mixer_one"] = is_equal_approx(float(mixer_target.get("warmup_target", -1.0)), 1.0)
	var null_target: Dictionary = factory_build_state.source_factory_warmup_target_state(null)
	proof["liquid_warmup_target_null_zero"] = is_equal_approx(float(null_target.get("warmup_target", -1.0)), 0.0)

	# --- warmup: Mathf.approachDelta(warmup, warmupTarget(),
	# warmupSpeed) (GenericCrafter.java:239) and
	# Mathf.approachDelta(warmup, 0f, warmupSpeed)
	# (GenericCrafter.java:253): approachDelta steps by Time.delta
	# * warmupSpeed, and Time.delta is in seconds, so one second at
	# warmupSpeed 0.019 (GenericCrafter.java:45) moves 0.019. ---
	var warmed_one: Dictionary = factory_build_state.source_factory_warmup_state(0.0, 1.0, 0.019, 1.0)
	proof["liquid_warmup_step_one_second"] = is_equal_approx(float(warmed_one.get("warmup", -1.0)), 0.019)
	var warmed_half: Dictionary = factory_build_state.source_factory_warmup_state(0.5, 1.0, 0.019, 1.0)
	proof["liquid_warmup_step_from_half"] = is_equal_approx(float(warmed_half.get("warmup", -1.0)), 0.519)
	var cooled: Dictionary = factory_build_state.source_factory_warmup_state(0.5, 0.0, 0.019, 1.0)
	proof["liquid_warmup_cools_toward_zero"] = is_equal_approx(float(cooled.get("warmup", -1.0)), 0.481)
	var clamped_target: Dictionary = factory_build_state.source_factory_warmup_state(0.0, 1.0, 0.019, 100.0)
	proof["liquid_warmup_clamps_to_target"] = is_equal_approx(float(clamped_target.get("warmup", -1.0)), 1.0)
	var clamped_zero: Dictionary = factory_build_state.source_factory_warmup_state(1.0, 0.0, 0.019, 100.0)
	proof["liquid_warmup_clamps_to_zero"] = is_equal_approx(float(clamped_zero.get("warmup", -1.0)), 0.0)
	var unchanged: Dictionary = factory_build_state.source_factory_warmup_state(0.5, 1.0, 0.019, 0.0)
	proof["liquid_warmup_zero_seconds_unchanged"] = is_equal_approx(float(unchanged.get("warmup", -1.0)), 0.5)

	# --- liquid output, direct: `float inc =
	# getProgressIncrease(1f);` then each output liquid is handled
	# once per tick, `handleLiquid(this, output.liquid,
	# Math.min(output.amount * inc, liquidCapacity -
	# liquids.get(output.liquid)))`
	# (GenericCrafter.java:241-246); handleLiquid is liquids.add
	# (BuildingComp.java:872-874). An empty mixer gains 0.2
	# cryofluid per tick at inc 1.0; a nearly-full one (35.9/36)
	# scales inc to 0.5 through the N2117 headroom scaling and
	# gains 0.1; a full one gains nothing; a block with no output
	# liquids and a null block output nothing. ---
	var mixer_empty: Dictionary = factory_build_state.source_factory_liquid_output_state(mixer, _fresh_module(max_liquid_id, {}), liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_mixer_empty_inc_one"] = is_equal_approx(float(mixer_empty.get("inc", -1.0)), 1.0)
	proof["liquid_output_mixer_empty_added"] = is_equal_approx(float(Dictionary(mixer_empty.get("added", {})).get("cryofluid", -1.0)), 0.2)
	proof["liquid_output_mixer_empty_current"] = int(Dictionary(mixer_empty.get("liquids_after", {})).get("current", -1)) == cryofluid_id
	var near_full_module: Dictionary = _fresh_module(max_liquid_id, {cryofluid_id: 35.9})
	var mixer_near_full: Dictionary = factory_build_state.source_factory_liquid_output_state(mixer, near_full_module, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_mixer_near_full_inc_half"] = is_equal_approx(float(mixer_near_full.get("inc", -1.0)), 0.5)
	proof["liquid_output_mixer_near_full_added"] = is_equal_approx(float(Dictionary(mixer_near_full.get("added", {})).get("cryofluid", -1.0)), 0.1) and is_equal_approx(float(Array(Dictionary(mixer_near_full.get("liquids_after", {})).get("liquids", []))[cryofluid_id]), 36.0)
	var full_module: Dictionary = _fresh_module(max_liquid_id, {cryofluid_id: 36.0})
	var mixer_full: Dictionary = factory_build_state.source_factory_liquid_output_state(mixer, full_module, liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_mixer_full_inc_zero"] = is_equal_approx(float(mixer_full.get("inc", -1.0)), 0.0)
	proof["liquid_output_mixer_full_added_zero"] = is_equal_approx(float(Dictionary(mixer_full.get("added", {})).get("cryofluid", -1.0)), 0.0)
	var smelter_out: Dictionary = factory_build_state.source_factory_liquid_output_state(blocks_by_id["silicon-smelter"], _fresh_module(max_liquid_id, {}), liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_smelter_inc_zero"] = is_equal_approx(float(smelter_out.get("inc", -1.0)), 0.0)
	proof["liquid_output_smelter_added_empty"] = Dictionary(smelter_out.get("added", {})).is_empty()
	var null_out: Dictionary = factory_build_state.source_factory_liquid_output_state(null, _fresh_module(max_liquid_id, {}), liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_null_block_inc_zero"] = is_equal_approx(float(null_out.get("inc", -1.0)), 0.0)
	var electrolyzer_out: Dictionary = factory_build_state.source_factory_liquid_output_state(electrolyzer, _fresh_module(max_liquid_id, {}), liquid_id_by_name, 1.0, 1.0 / 60.0, 1.0)
	proof["liquid_output_electrolyzer_inc_one"] = is_equal_approx(float(electrolyzer_out.get("inc", -1.0)), 1.0)
	proof["liquid_output_electrolyzer_added"] = is_equal_approx(float(Dictionary(electrolyzer_out.get("added", {})).get("ozone", -1.0)), 4.0 / 60.0) and is_equal_approx(float(Dictionary(electrolyzer_out.get("added", {})).get("hydrogen", -1.0)), 6.0 / 60.0)

	# --- totalProgress, direct: totalProgress += warmup *
	# Time.delta (GenericCrafter.java:259-260); Time.delta is in
	# seconds, not ticks. ---
	var totalled: Dictionary = factory_build_state.source_factory_total_progress_state(0.0, 0.5, 2.0)
	proof["liquid_total_progress_seconds"] = is_equal_approx(float(totalled.get("total_progress", -1.0)), 1.0)
	var totalled_tick: Dictionary = factory_build_state.source_factory_total_progress_state(1.0, 0.25, 1.0 / 60.0)
	proof["liquid_total_progress_tick"] = is_equal_approx(float(totalled_tick.get("total_progress", -1.0)), 1.0 + 0.25 / 60.0)
	var totalled_cold: Dictionary = factory_build_state.source_factory_total_progress_state(5.0, 0.0, 1.0)
	proof["liquid_total_progress_zero_warmup"] = is_equal_approx(float(totalled_cold.get("total_progress", -1.0)), 5.0)

	# --- warmup / liquid output / totalProgress, live: a mixer
	# (35,7) with titanium 5 and water 10.0 and an electrolyzer
	# (40,7) with water 10.0 tick 40 times through
	# simulate_factory. The mixer drains 0.2 water per tick and
	# gains 0.2 cryofluid per tick at inc 1.0; its progress climbs
	# 1/120 per tick and its warmup 0.019/60 per tick (the driver
	# reads the 0.019 class default, warmupSpeed is not in the
	# registry); totalProgress banks warmup * Time.delta each tick.
	# The electrolyzer drains 10/60 water per tick and gains 4/60
	# ozone + 6/60 hydrogen per tick. ---
	var mixer_cell := Vector2i(35, 7)
	var mixer_sprite := Sprite2D.new()
	game.add_child(mixer_sprite)
	game.call("record_placed_block", mixer_sprite, mixer, mixer_cell)
	var mixer_frame: Dictionary = mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_frame["items"] = {"titanium": 5}
	var mixer_module: Dictionary = mixer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(mixer_module, water_id, 10.0, [])
	var electrolyzer_cell := Vector2i(40, 7)
	var electrolyzer_sprite := Sprite2D.new()
	game.add_child(electrolyzer_sprite)
	game.call("record_placed_block", electrolyzer_sprite, electrolyzer, electrolyzer_cell)
	var electrolyzer_module: Dictionary = electrolyzer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(electrolyzer_module, water_id, 10.0, [])
	for iteration in range(40):
		game.call("simulate_factory", 1.0 / 60.0)
	mixer_frame = mixer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	mixer_module = mixer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var electrolyzer_frame: Dictionary = electrolyzer_sprite.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	electrolyzer_module = electrolyzer_sprite.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	var mixer_amounts: Array = mixer_module.get("liquids", [])
	var electrolyzer_amounts: Array = electrolyzer_module.get("liquids", [])
	proof["liquid_live_mixer_water"] = is_equal_approx(float(mixer_amounts[water_id]), 10.0 - 40.0 * 0.2)
	proof["liquid_live_mixer_cryofluid"] = is_equal_approx(float(mixer_amounts[cryofluid_id]), 40.0 * 0.2)
	proof["liquid_live_mixer_progress"] = is_equal_approx(float(mixer_frame.get("progress", -1.0)), 40.0 / 120.0)
	proof["liquid_live_mixer_warmup"] = is_equal_approx(float(mixer_frame.get("warmup", -1.0)), 40.0 * 0.019 / 60.0)
	proof["liquid_live_mixer_total_progress"] = is_equal_approx(float(mixer_frame.get("totalProgress", -1.0)), 0.019 * 820.0 / 3600.0)
	proof["liquid_live_mixer_efficiency_one"] = is_equal_approx(float(mixer_frame.get("efficiency", -1.0)), 1.0)
	proof["liquid_live_mixer_titanium_kept"] = int(Dictionary(mixer_frame.get("items", {})).get("titanium", -1)) == 5
	proof["liquid_live_mixer_current_cryofluid"] = int(mixer_module.get("current", -1)) == cryofluid_id
	proof["liquid_live_electrolyzer_ozone"] = is_equal_approx(float(electrolyzer_amounts[ozone_id]), 40.0 * 4.0 / 60.0)
	proof["liquid_live_electrolyzer_hydrogen"] = is_equal_approx(float(electrolyzer_amounts[hydrogen_id]), 40.0 * 6.0 / 60.0)
	proof["liquid_live_electrolyzer_water"] = is_equal_approx(float(electrolyzer_amounts[water_id]), 10.0 - 40.0 * 10.0 / 60.0)
	proof["liquid_live_electrolyzer_efficiency_one"] = is_equal_approx(float(electrolyzer_frame.get("efficiency", -1.0)), 1.0)
	proof["liquid_live_electrolyzer_warmup"] = is_equal_approx(float(electrolyzer_frame.get("warmup", -1.0)), 40.0 * 0.019 / 60.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C06FactoryLiquidOutputProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
