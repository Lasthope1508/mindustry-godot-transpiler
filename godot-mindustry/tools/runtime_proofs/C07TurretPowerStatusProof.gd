extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
const placed_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# --- Pure power row (N2148): ConsumePower.efficiency is
	# build.power.status (ConsumePower.java:39, `return build.
	# power.status;`), folded by the first pass
	# (BuildingComp.java:1969-1976) into the min efficiency; a
	# missing stamp folds to 1.0 before the first graph update,
	# the assembler fold (UnitAssembler.java:469, `float
	# powerStatus = !enabled ? 0f : power == null ? 1f :
	# power.status;`).
	var half_row: Dictionary = turret_build_state.source_turret_power_status_row_state({"power_status": 0.5}, true)
	proof["power_row_half"] = bool(half_row.get("has_power_row", false)) and is_equal_approx(float(half_row.get("row", {}).get("result", -1.0)), 0.5) and bool(half_row.get("row", {}).get("is_power", false))

	var no_consumer: Dictionary = turret_build_state.source_turret_power_status_row_state({"power_status": 0.5}, false)
	proof["power_row_absent_without_consumer"] = bool(no_consumer.get("has_power_row", true)) == false

	var null_row: Dictionary = turret_build_state.source_turret_power_status_row_state({}, true)
	proof["power_row_null_folds_one"] = bool(null_row.get("has_power_row", false)) and is_equal_approx(float(null_row.get("row", {}).get("result", -1.0)), 1.0) and bool(null_row.get("row", {}).get("is_power", false))

	# --- Live tick: the lancer is a PowerTurret with a power
	# consumer (consumePower 6f), placed live by the scenario
	# bootstrap; the tick driver is called directly (as the
	# N2147 proof does), not simulate_factory, so the graph
	# update does not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. The turret
	# tick models no other consumers, so with a power consumer
	# the first pass holds only the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	proof["lancer_has_power_consumer"] = bool(blocks_by_id["lancer"].properties.has("consumePower"))

	var lancer_cell := Vector2i(25, 7)
	var lancer: Variant = game.call("block_sprite_at_cell", lancer_cell)
	proof["lancer_placed_live_sprite"] = lancer != null and str(lancer.get_meta("source_block_id", "")) == "lancer"
	var lancer_frame: Dictionary = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})

	# Half power: efficiency folds the power min 0.5.
	lancer_frame["power_status"] = 0.5
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_min"] = is_equal_approx(float(lancer_frame.get("efficiency", -1.0)), 0.5)

	# No power: efficiency 0.
	lancer_frame["power_status"] = 0.0
	turret_build_state.source_turret_tick_buildings_state(game, 1.0 / 60.0)
	lancer_frame = lancer.get_meta(turret_build_state.SOURCE_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_at_no_power"] = is_equal_approx(float(lancer_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretPowerStatusProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
