extends Node

const main_scene := preload("res://scenes/Main.tscn")
const regen_projector_build_state := preload("res://src/game/SourceRegenProjectorBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const placed_block_state := preload("res://src/game/SourcePlacedBlockState.gd")
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

	# The liquid catalog resolves the consumed liquid's id
	# (the Fracker precedent): the pure row takes the
	# catalog id, the driver resolves it from
	# liquid_id_by_name with the def constant "hydrogen".
	var catalog = game.get("content_catalog")
	var liquid_catalog: Dictionary = content_registry_state.source_liquid_catalog_state(catalog)
	var hydrogen_id: int = int(liquid_catalog["liquid_id_by_name"].get("hydrogen", -1))
	var content_liquid_ids: Array = liquid_catalog["content_liquid_ids"]

	# --- Pure hydrogen row (N2260): ConsumeLiquid.efficiency
	# (ConsumeLiquid.java:42-47, `float ed = build.edelta()
	# * build.efficiencyScale();` with `if(ed <=
	# 0.00000001f) return 0f;` and `return Math.min(build.
	# liquids.get(liquid) / (amount * ed * multiplier.
	# get(build)), 1f);`) folds into the same first-pass min
	# as the power row (BuildingComp.java:1969-1976). In the
	# first pass efficiency is assumed 1f
	# (BuildingComp.java:1964-1965), so edelta is delta() =
	# Time.delta * timeScale (BuildingComp.java:1922-1929)
	# and ed = source_delta * time_scale * efficiency_scale.
	# The single def consumes hydrogen 1f/60f per frame,
	# `consumeLiquid(Liquids.hydrogen, 1f / 60f);`
	# (Blocks.java:2016); the def sets no multiplier, so
	# the default `public Floatf<Building> multiplier = b ->
	# 1f;` (Consume.java:18) applies. The literal 1.0 / 60.0
	# pins the def value independently of the driver's
	# constant, which is itself checked against the literal.
	var starved_liquids: Dictionary = liquid_module_state.source_initial_state(content_liquid_ids)
	liquid_module_state.source_set_state(starved_liquids, hydrogen_id, 0.01)
	var starved_row: Dictionary = regen_projector_build_state.source_regen_projector_liquid_consumer_row_state({"liquids": starved_liquids}, true, hydrogen_id, 1.0 / 60.0, 1.0, 1.0, 1.0)
	proof["hydrogen_row_folds_min_when_starved"] = bool(starved_row.get("has_liquid_row", false)) and is_equal_approx(float(starved_row.get("row", {}).get("result", -1.0)), 0.6) and bool(starved_row.get("row", {}).get("is_power", true)) == false and is_equal_approx(float(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_LIQUID_AMOUNT), 1.0 / 60.0) and str(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_LIQUID) == "hydrogen"

	# --- Pure phaseFabric item row (N2260):
	# ConsumeItems.efficiency (ConsumeItems.java:51-53,
	# `return build.consumeTriggerValid() || build.items.
	# has(items, multiplier.get(build)) ? 1f : 0f;`) is
	# BINARY 1/0, not a ratio: 1 when every stack is held
	# (ItemModule.has, ItemModule.java:153-156, each stack
	# at round(amount * multiplier)), else 0.
	# consumeTriggerValid() is false at the base
	# (BuildingComp.java:764-766). The booster (`return
	# optional(true, true);`, Consume.java:33-35) folds into
	# the optional pass (BuildingComp.java:1980-1981),
	# capped by the min efficiency (BuildingComp.java:1986).
	# The single def consumes one phaseFabric,
	# `consumeItem(Items.phaseFabric).boost();`
	# (Blocks.java:2017).
	var booster_stacks: Array = [{"item": "phase-fabric", "amount": 1}]
	var present_row: Dictionary = regen_projector_build_state.source_regen_projector_item_consumer_row_state({"items": {"phase-fabric": 1}}, booster_stacks, false)
	proof["item_row_binary_one_when_present"] = bool(present_row.get("has_item_row", false)) and is_equal_approx(float(present_row.get("row", {}).get("result", -1.0)), 1.0) and bool(present_row.get("row", {}).get("is_power", true)) == false and str(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BOOSTER_ITEM) == "phase-fabric" and int(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BOOSTER_AMOUNT) == 1

	var absent_row: Dictionary = regen_projector_build_state.source_regen_projector_item_consumer_row_state({"items": {}}, booster_stacks, false)
	proof["phase_fabric_row_folds_optional_when_absent"] = bool(absent_row.get("has_item_row", false)) and is_equal_approx(float(absent_row.get("row", {}).get("result", -1.0)), 0.0) and bool(absent_row.get("row", {}).get("is_power", true)) == false

	# --- Live tick: the regen-projector is a RegenProjector
	# build with a power consumer (regen-projector,
	# consumePower 1f, Blocks.java:2015), a required liquid
	# consumer (hydrogen 1f/60f, Blocks.java:2016) and a
	# phaseFabric booster item (Blocks.java:2017), placed
	# live; the tick driver is called directly (as the
	# N2160/N2214/N2228 proofs do), not simulate_factory, so
	# the graph update does not overwrite the stamped
	# power_status -- the write-back itself is already proven
	# by N2142. The hydrogen amounts are set on the sprite
	# liquids meta store (the live LiquidModule), which the
	# driver syncs into the frame each tick (the Fracker
	# precedent); the phaseFabric count is set on the frame
	# items dict directly (no live intake fills it yet, the
	# Separator precedent). The shouldConsume gate
	# (RegenProjector.java:182, `return anyTargets;`) closes
	# with no targets, so every live tick below holds
	# any_targets true -- the advance recomputes it from the
	# (empty) targets input each tick, so it must be
	# re-stamped before each tick.
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var regen_cell := Vector2i(28, 20)
	var regen := Sprite2D.new()
	game.add_child(regen)
	game.call("record_placed_block", regen, blocks_by_id["regen-projector"], regen_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	regen_projector_build_state.source_regen_projector_bind_frame_state(regen, blocks_by_id["regen-projector"])
	var regen_frame: Dictionary = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var regen_liquids: Dictionary = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})

	# Half power, full hydrogen, booster present: the first
	# pass folds the min 0.5 (power 0.5, hydrogen row capped
	# at 1.0), and the optional pass folds the item row 1.0 --
	# capped by the min efficiency (BuildingComp.java:1986),
	# so optional_efficiency is 0.5, not 1.0.
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 10.0)
	regen_frame["power_status"] = 0.5
	regen_frame["any_targets"] = true
	regen_frame["items"] = {"phase-fabric": 1}
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	proof["optional_capped_by_min_efficiency"] = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 0.5) and is_equal_approx(float(regen_frame.get("optional_efficiency", -1.0)), 0.5)

	# Running: 10.0 hydrogen folds the row to the 1.0 cap,
	# so efficiency is 1.0 and the second pass
	# (BuildingComp.java:1999, `if(update && efficiency >
	# 0){`) removes amount * edelta * multiplier = (1/60) *
	# 1.0 * 1.0 = 1/60 (ConsumeLiquid.java:38), leaving
	# 10.0 - 1/60 in the live store.
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 10.0)
	regen_frame["power_status"] = 1.0
	regen_frame["any_targets"] = true
	regen_frame["items"] = {"phase-fabric": 1}
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	regen_liquids = regen.get_meta(placed_block_state.SOURCE_BUILDING_LIQUIDS_META_KEY, {})
	proof["live_tick_removes_hydrogen_when_running"] = is_equal_approx(float(regen_frame.get("efficiency", -1.0)), 1.0) and is_equal_approx(float(liquid_module_state.source_get_state(regen_liquids, hydrogen_id).get("amount", -1.0)), 10.0 - 1.0 / 60.0)

	# Consumed tick: the optionalTimer sits at 479.0, one
	# tick below the 480.0 use time; with efficiency 1.0 and
	# optionalEfficiency 1.0 the advance adds edelta *
	# optionalEfficiency = 1.0, reaches the threshold and
	# reports consumed (RegenProjector.java:142-144), so the
	# tick removes 1 phaseFabric through consume()
	# (ConsumeItems.trigger, ConsumeItems.java:44-48),
	# leaving 1 of the 2 held.
	liquid_module_state.source_set_state(regen_liquids, hydrogen_id, 10.0)
	regen_frame["power_status"] = 1.0
	regen_frame["any_targets"] = true
	regen_frame["items"] = {"phase-fabric": 2}
	regen_frame["optional_timer"] = 479.0
	regen_projector_build_state.source_regen_projector_tick_buildings_state(game, 1.0 / 60.0)
	regen_frame = regen.get_meta(regen_projector_build_state.SOURCE_REGEN_PROJECTOR_BUILDING_META_KEY, {})
	var held_items: Dictionary = regen_frame.get("items", {})
	proof["consumed_tick_removes_phase_fabric"] = bool(regen_frame.get("consumed", false)) and int(held_items.get("phase-fabric", -1)) == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RegenProjectorSecondConsumersProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
