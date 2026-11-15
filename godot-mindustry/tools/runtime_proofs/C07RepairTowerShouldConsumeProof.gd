extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_tower_build_state := preload("res://src/game/SourceRepairTowerBuildState.gd")
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

	# --- Pure shouldConsume gate (N2213):
	# RepairTowerBuild.shouldConsume()
	# (RepairTower.java:89-91, `public boolean
	# shouldConsume(){` with `return targets.size > 0;`,
	# RepairTower.java:90) -- the tower consumes only while
	# at least one damaged unit is in range. The field is
	# `public Seq<Unit> targets = new Seq<>();`
	# (RepairTower.java:54) on RepairTowerBuild (`public class
	# RepairTowerBuild extends Building implements Ranged{`,
	# RepairTower.java:46). The gate has NO `&& enabled` --
	# Java returns the bare size check, so the pure gate does
	# NOT read frame["enabled"] at all. The gate reads only
	# the size of frame["targets"], so the present-target
	# fixture below is a list holding one minimal test-only
	# Dictionary -- no real Unit is built; the port has no
	# live target refresh on the building frame yet (the
	# periodic Units.nearby refresh is the updateTile
	# advance, RepairTower.java:57-86, and waits for its own
	# slice).
	var no_targets: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state({"targets": []})
	proof["gate_false_when_targets_empty"] = bool(no_targets.get("should_consume", true)) == false and int(no_targets.get("target_count", -1)) == 0

	var has_targets: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state({"targets": [{"type": "dart"}]})
	proof["gate_true_when_targets_nonempty"] = bool(has_targets.get("should_consume", false)) and int(has_targets.get("target_count", -1)) == 1

	var disabled_no_targets: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state({"targets": [], "enabled": false})
	var disabled_has_targets: Dictionary = repair_tower_build_state.source_repair_tower_should_consume_state({"targets": [{"type": "dart"}], "enabled": false})
	proof["gate_independent_of_enabled"] = bool(disabled_no_targets.get("should_consume", true)) == false and bool(disabled_has_targets.get("should_consume", false))

	# --- Live tick: the repair tower is a RepairTower
	# build with a power consumer (consumePower 1f), placed
	# live; the tick driver is called directly (as the N2147/
	# N2148/N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/
	# N2159/N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/
	# N2168/N2169 proofs do), not simulate_factory, so the
	# graph update does not overwrite the stamped power_status
	# -- the write-back itself is already proven by N2142. The
	# first pass holds the power row AND the N2250 ozone liquid
	# row (consumeLiquid ozone 3f/60f, Blocks.java:6583) -- with
	# an empty ozone store the machinery folds efficiency to 0,
	# so the sprite liquids meta is seeded with ozone 0.1 before
	# EACH live tick below (the N2250 Tower B fill, N2306
	# pattern; ozone 0.1 at full power folds eff 1.0, so at half
	# power eff = min(0.5, 1.0) = 0.5). When the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var ozone_id: int = int(liquid_catalog["liquid_id_by_name"].get("ozone", -1))
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_tower_cell := Vector2i(28, 20)
	var repair_tower := Sprite2D.new()
	game.add_child(repair_tower)
	game.call("record_placed_block", repair_tower, blocks_by_id["unit-repair-tower"], repair_tower_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the targets on it).
	repair_tower_build_state.source_repair_tower_bind_frame_state(repair_tower, blocks_by_id["unit-repair-tower"])
	var repair_tower_frame: Dictionary = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	# Seed ozone 0.1 on the sprite liquids meta (the N2250
	# Tower B fill, N2306 pattern) before the first live tick
	# -- without it the ozone liquid row folds efficiency to 0.
	var repair_tower_liquids: Dictionary = repair_tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(repair_tower_liquids, ozone_id, 0.1)

	# A freshly bound frame carries the targets key defaulting
	# to the empty list (the Java field initializer is `new
	# Seq<>()`) -- no targets yet, so the gate reads false
	# and the tower does not consume.
	proof["frame_targets_default_empty"] = repair_tower_frame.has("targets") and repair_tower_frame["targets"] is Array and repair_tower_frame["targets"].is_empty()

	# No targets: gate false -> efficiency 0 even at half power.
	repair_tower_frame["targets"] = []
	repair_tower_frame["power_status"] = 0.5
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.0)

	# One target in range: gate true -> efficiency folds
	# the power min 0.5 (the N2176 power fold preserved).
	# Re-seed ozone 0.1 before this second live tick -- do
	# not rely on leftovers from the first tick.
	repair_tower_liquids = repair_tower.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	liquid_module_state.source_set_state(repair_tower_liquids, ozone_id, 0.1)
	repair_tower_frame["targets"] = [{"type": "dart"}]
	repair_tower_frame["power_status"] = 0.5
	repair_tower_build_state.source_repair_tower_tick_buildings_state(game, 1.0 / 60.0)
	repair_tower_frame = repair_tower.get_meta(repair_tower_build_state.SOURCE_REPAIR_TOWER_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(repair_tower_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTowerShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
