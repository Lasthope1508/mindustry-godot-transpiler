extends Node

const main_scene := preload("res://scenes/Main.tscn")
const unit_assembler_module_build_state := preload("res://src/game/SourceUnitAssemblerModuleBuildState.gd")
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

	# --- Pure: the tier accessor (N2348): tier()
	# (UnitAssemblerModule.java:85-86, `public int tier(){` /
	# `return tier;`) returns the block's tier field
	# (`public int tier = 1;`, UnitAssemblerModule.java:22),
	# also surfaced in setStats (`stats.add(Stat.moduleTier,
	# tier);`, UnitAssemblerModule.java:33). The catalog
	# carries no tier key for basic-assembler-module and
	# the def sets no tier (Blocks.java:6566-6573), so the
	# single def keeps the class default: the driver passes
	# it explicitly as tier_default (the N2333
	# acceptMultipleItems precedent) and the pure returns
	# it. The assembler consumes it in checkTier()
	# (UnitAssembler.java:364-378): `modules.sort(b ->
	# b.tier());` then the max-tier walk -- that pure is live
	# since N2133, and the cross-building wiring feeding
	# stamped module tiers into the assembler frame modules
	# list waits for its own slice.
	var class_default: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_tier_state("basic-assembler-module", 1)
	proof["pure_returns_class_default_tier"] = int(class_default.get("tier", -1)) == 1
	var explicit_default: Dictionary = unit_assembler_module_build_state.source_unit_assembler_module_tier_state("basic-assembler-module", 2)
	proof["pure_honors_explicit_default"] = int(explicit_default.get("tier", -1)) == 2

	# --- Live tick: the tier stamp (N2348): the
	# unit-assembler-module is a UnitAssemblerModule build
	# with a power consumer (consumePower 3.5f), placed live;
	# the tick driver is called directly (as the N2168 proof
	# does), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the
	# write-back itself is already proven by N2142. tier is
	# a static class field, not consumption-gated, so the
	# stamp runs every tick whether or not the module is
	# enabled, and overwrites any seeded frame input. One
	# module is ticked sequentially (the N2308 proof
	# pattern), the frame reset between cases.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var unit_assembler_module_cell := Vector2i(28, 21)
	var unit_assembler_module := Sprite2D.new()
	game.add_child(unit_assembler_module)
	game.call("record_placed_block", unit_assembler_module, blocks_by_id["basic-assembler-module"], unit_assembler_module_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to seed the power status +
	# the stale tier + the enabled flag on it).
	unit_assembler_module_build_state.source_unit_assembler_module_bind_frame_state(unit_assembler_module, blocks_by_id["basic-assembler-module"])
	var unit_assembler_module_frame: Dictionary = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})

	unit_assembler_module_frame["power_status"] = 1.0

	# Tick 1: the live tick stamps frame["tier"] == 1 from
	# the class default, with full power.
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["live_tick_stamps_tier"] = is_equal_approx(float(unit_assembler_module_frame.get("efficiency", -1.0)), 1.0) and int(unit_assembler_module_frame.get("tier", -1)) == 1

	# Tick 2: a stale tier seed (99) is OVERWRITTEN by the
	# stamp -- the frame reads the class default again.
	unit_assembler_module_frame["tier"] = 99
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["tier_stamp_overwrites_stale_seed"] = int(unit_assembler_module_frame.get("tier", -1)) == 1

	# Tick 3: the stamp survives a disabled module -- tier
	# is a static class field, not consumption-gated, so the
	# stamp runs even though the power fold and the advance
	# are skipped.
	unit_assembler_module_frame["enabled"] = false
	unit_assembler_module_frame["tier"] = 99
	unit_assembler_module_build_state.source_unit_assembler_module_tick_buildings_state(game, 1.0 / 60.0)
	unit_assembler_module_frame = unit_assembler_module.get_meta(unit_assembler_module_build_state.SOURCE_UNIT_ASSEMBLER_MODULE_BUILDING_META_KEY, {})
	proof["tier_stamp_survives_disabled"] = bool(unit_assembler_module_frame.get("enabled", true)) == false and int(unit_assembler_module_frame.get("tier", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07UnitAssemblerModuleTierStampProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
