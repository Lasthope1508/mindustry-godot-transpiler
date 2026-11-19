extends Node

const content_registry_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const main_scene := preload("res://scenes/Main.tscn")
const separator_build_state := preload("res://src/game/SourceSeparatorBuildState.gd")
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

	# --- Pure shouldConsume gate (N2200):
	# SeparatorBuild.shouldConsume() (Separator.java:92-101,
	# `public boolean shouldConsume(){` with `return total <
	# itemCapacity && enabled;`, Separator.java:100): `int total =
	# items.total();` (Separator.java:93), then -- when the block
	# has a ConsumeItems consumer -- the consItems buffer is
	# subtracted (`for(ItemStack stack : consItems.items){` /
	# `total -= items.get(stack.item);`, Separator.java:96-97).
	# The separator def has no consumeItem
	# (Blocks.java:1231-1246), so its consItems is null and
	# nothing is subtracted; the disassembler consumes scrap
	# (`consumeItem(Items.scrap);`, Blocks.java:1263). The
	# capacity is the catalog itemCapacity (`public int
	# itemCapacity = 10;`, Block.java:75, the default;
	# disassembler `itemCapacity = 20;`, Blocks.java:1261).
	var below: Dictionary = separator_build_state.source_separator_should_consume_state({"items": {"copper": 5}, "enabled": true}, [], 10)
	proof["gate_true_below_capacity"] = bool(below.get("should_consume", false)) and int(below.get("total", -1)) == 5

	var full: Dictionary = separator_build_state.source_separator_should_consume_state({"items": {"copper": 10}, "enabled": true}, [], 10)
	proof["gate_false_when_full"] = bool(full.get("should_consume", true)) == false and int(full.get("total", -1)) == 10

	var disabled: Dictionary = separator_build_state.source_separator_should_consume_state({"items": {"copper": 5}, "enabled": false}, [], 10)
	proof["gate_false_when_disabled"] = bool(disabled.get("should_consume", true)) == false

	# The disassembler case: 15 held scrap + 5 copper is a raw
	# total of 20, which would fill capacity 20 -- but the
	# consItems buffer subtracts the held scrap, so the adjusted
	# total is 5 and the gate stays true. Without the subtraction
	# this case would be false, so a true gate proves the buffer.
	var buffered: Dictionary = separator_build_state.source_separator_should_consume_state({"items": {"scrap": 15, "copper": 5}, "enabled": true}, ["scrap"], 20)
	proof["buffer_cons_items_subtracted"] = bool(buffered.get("should_consume", false)) and int(buffered.get("total", -1)) == 5

	# --- Live tick: the separator is a Separator build with a
	# power consumer (consumePower 1.1f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161/
	# N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169 proofs do),
	# not simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back itself
	# is already proven by N2142. The separator tick models no
	# other consumers, so with a power consumer the first pass
	# holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var separator_cell := Vector2i(28, 21)
	var separator := Sprite2D.new()
	game.add_child(separator)
	game.call("record_placed_block", separator, blocks_by_id["separator"], separator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the held items on it).
	separator_build_state.source_separator_bind_frame_state(separator, blocks_by_id["separator"])
	var separator_frame: Dictionary = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	# Supply the later required slag consumer so this fixture isolates the gate/power fold.
	liquid_module_state.source_set_state(separator.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY), int(liquid_catalog["liquid_id_by_name"]["slag"]), 1.0)

	# Full (10 copper at capacity 10): gate false -> efficiency
	# 0 even at half power.
	separator_frame["items"] = {"copper": 10}
	separator_frame["power_status"] = 0.5
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.0)

	# Empty: gate true -> efficiency folds the power min 0.5
	# (the N2169 power fold preserved).
	separator_frame["items"] = {}
	separator_frame["power_status"] = 0.5
	separator_build_state.source_separator_tick_buildings_state(game, 1.0 / 60.0)
	separator_frame = separator.get_meta(separator_build_state.SOURCE_SEPARATOR_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(separator_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SeparatorShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
