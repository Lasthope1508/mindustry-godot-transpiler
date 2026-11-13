extends Node

const main_scene := preload("res://scenes/Main.tscn")
const adjacent_build_state := preload("res://src/game/SourceAdjacentFactoryBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	# --- Pure power row (N2146): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = adjacent_build_state.source_adjacent_factory_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = adjacent_build_state.source_adjacent_factory_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = adjacent_build_state.source_adjacent_factory_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the separator is an adjacent factory with a
	# power consumer (consumePower 1.1), placed live; the tick
	# driver is called directly (as the N2145 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The separator's slag actor needs
	# slag held (ConsumeLiquid.efficiency,
	# ConsumeLiquid.java:38-40): with no slag the first pass
	# reads 0 and masks the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["separator_has_power_consumer"] = bool(blocks_by_id["separator"].properties.has("consumePower"))

	var separator_cell := Vector2i(30, 7)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	var separator_frame: Dictionary = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var slag_id: int = int(liquid_catalog["liquid_id_by_name"].get("slag", -1))
	var separator_module: Dictionary = separator.get_meta(placed_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_add_state(separator_module, slag_id, 10.0, [])

	# Half power: efficiency folds the power min 0.5.
	separator_frame["power_status"] = 0.5
	adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	separator_frame["power_status"] = 0.0
	adjacent_build_state.source_adjacent_factory_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(adjacent_build_state.SOURCE_ADJACENT_FACTORY_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AdjacentFactoryPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
