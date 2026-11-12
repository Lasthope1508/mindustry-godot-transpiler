extends Node

const main_scene := preload("res://scenes/Main.tscn")
const factory_build_state := preload("res://src/game/SourceFactoryBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure power row (N2145): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = factory_build_state.source_factory_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = factory_build_state.source_factory_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = factory_build_state.source_factory_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the silicon-smelter is a GenericCrafter with
	# a power consumer (consumePower 0.5, craftTime 40.0), placed
	# live; the tick driver is called directly (as the N2111 proof
	# does), not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["smelter_has_power_consumer"] = bool(blocks_by_id["silicon-smelter"].properties.has("consumePower"))

	var smelter_cell := Vector2i(30, 7)
	var smelter := Sprite2D.new()
	game.add_child(smelter)
	game.call("record_placed_block", smelter, blocks_by_id["silicon-smelter"], smelter_cell)
	var smelter_frame: Dictionary = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	# The item actors need their stacks held (ConsumeItems.
	# efficiency, ConsumeItems.java:52): coal 1 + sand 2, so the
	# power row is the binding min instead of the item rows.
	smelter_frame["items"] = {"coal": 1, "sand": 2}
	var craft_time: float = float(blocks_by_id["silicon-smelter"].properties.get("craftTime", 80.0))
	var time_scale: float = placed_state.time_scale(smelter, placed_state.game_default_time_scale(game))

	# Half power: efficiency folds the power min 0.5, and progress
	# climbs by getProgressIncrease(craftTime) at that efficiency
	# (GenericCrafter.java:238).
	smelter_frame["power_status"] = 0.5
	var progress_before: float = float(smelter_frame.get("progress", 0.0))
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 0.5)
	var expected_half: Dictionary = factory_build_state.source_factory_progress_increase_state(craft_time, 0.5, 1.0 / 60.0, time_scale)
	proof["progress_half_at_half_power"] = is_equal_approx(float(smelter_frame.get("progress", -1.0)) - progress_before, float(expected_half.get("progress_increase", -1.0)))

	# No power: efficiency 0, progress unchanged.
	smelter_frame["power_status"] = 0.0
	progress_before = float(smelter_frame.get("progress", 0.0))
	factory_build_state.source_factory_tick_buildings_state(game, 1.0 / 60.0)
	smelter_frame = smelter.get_meta(factory_build_state.SOURCE_FACTORY_BUILDING_META_KEY, {})
	proof["progress_zero_at_no_power"] = is_equal_approx(float(smelter_frame.get("efficiency", -1.0)), 0.0) and is_equal_approx(float(smelter_frame.get("progress", -1.0)), progress_before)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FactoryPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
