extends Node

const main_scene := preload("res://scenes/Main.tscn")
const accelerator_build_state := preload("res://src/game/SourceAcceleratorBuildState.gd")
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

	# --- Pure canLaunch gate (N2271): canLaunch()
	# (Accelerator.java:239-240, `return isValid() &&
	# !net.client() && state.isCampaign() && efficiency > 0f
	# && power.graph.getBatteryStored() >=
	# powerBufferRequirement-0.00001f && progress >= 1f &&
	# !launching;`) is a conjunction of an environment half
	# (isValid / net.client / state.isCampaign -- NOT
	# modeled, the port has no net / campaign state) and
	# four tick-state conditions: efficiency > 0f, battery
	# stored >= requirement - 0.00001 (getBatteryStored(),
	# PowerGraph.java:118-127, the enabled-battery total;
	# the requirement is the single-def 1,000,000f,
	# Blocks.java:6826), progress >= 1f (isCoreBuilt,
	# Accelerator.java:153-154) and !launching. The gate
	# returns the conjunction plus one flag per condition.
	var gate_all_ok: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0, 1.0, false, 1000000.0)
	var gate_no_eff: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(0.0, 1000000.0, 1.0, false, 1000000.0)
	var gate_short_battery: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 999999.0, 1.0, false, 1000000.0)
	var gate_boundary_pass: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0 - 0.00001, 1.0, false, 1000000.0)
	var gate_boundary_fail: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0 - 0.00002, 1.0, false, 1000000.0)
	var gate_no_progress: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0, 0.999, false, 1000000.0)
	var gate_launching: Dictionary = accelerator_build_state.source_accelerator_can_launch_state(1.0, 1000000.0, 1.0, true, 1000000.0)
	proof["can_launch_requires_positive_efficiency"] = bool(gate_all_ok.get("can_launch", false)) and bool(gate_all_ok.get("efficiency_ok", false)) and bool(gate_all_ok.get("battery_ok", false)) and bool(gate_all_ok.get("progress_ok", false)) and bool(gate_all_ok.get("not_launching", false)) and bool(gate_no_eff.get("can_launch", true)) == false and bool(gate_no_eff.get("efficiency_ok", true)) == false and bool(gate_no_eff.get("battery_ok", false)) and bool(gate_no_eff.get("progress_ok", false)) and bool(gate_no_eff.get("not_launching", false))

	# The battery boundary is exact in GDScript float64:
	# stored = requirement - 0.00001 passes, requirement -
	# 0.00002 fails (Java evaluates it in float32, where
	# 1_000_000f - 0.00001f rounds to 1_000_000f -- the port
	# keeps the written epsilon; see the driver docstring).
	proof["can_launch_requires_full_battery"] = bool(gate_short_battery.get("can_launch", true)) == false and bool(gate_short_battery.get("battery_ok", true)) == false and bool(gate_boundary_pass.get("can_launch", false)) and bool(gate_boundary_pass.get("battery_ok", false)) and bool(gate_boundary_fail.get("can_launch", true)) == false and bool(gate_boundary_fail.get("battery_ok", true)) == false

	proof["can_launch_requires_progress_one"] = bool(gate_no_progress.get("can_launch", true)) == false and bool(gate_no_progress.get("progress_ok", true)) == false and bool(gate_no_progress.get("efficiency_ok", false)) and bool(gate_no_progress.get("battery_ok", false)) and bool(gate_no_progress.get("not_launching", false))

	proof["can_launch_false_when_launching"] = bool(gate_launching.get("can_launch", true)) == false and bool(gate_launching.get("not_launching", true)) == false and bool(gate_launching.get("efficiency_ok", false)) and bool(gate_launching.get("battery_ok", false)) and bool(gate_launching.get("progress_ok", false))

	# --- Pure launch transition (N2271):
	# buildConfiguration's sector-select branch
	# (Accelerator.java:264-271, re-checked with
	# `if(canLaunch()){`): consume() (BuildingComp.java:
	# 1911-1915; ConsumeItems.trigger removes each
	# requirement stack, ConsumeItems.java:44-48, clamped by
	# ItemModule.remove, ItemModule.java:258-263) removes
	# the core-nucleus requirements (copper 8000 / lead 8000
	# / silicon 5000 / thorium 4000, Blocks.java:3154), then
	# `ItemSeq resources = new ItemSeq();` /
	# `resources.add(items);` / `items.clear();`
	# (Accelerator.java:266-268) snapshots the remainder and
	# empties the store, `power.graph.useBatteries
	# (powerBufferRequirement);` (Accelerator.java:270)
	# drains the battery total by min(stored, needed)
	# (PowerGraph.java:154-167) and `progress = 0f;`
	# (Accelerator.java:271) resets the core. The resources
	# carry only NONZERO remainders: resources.add(items)
	# iterates via ItemModule.each, which visits only
	# nonzero counts (ItemModule.java:100-106), so a
	# fully-consumed stack leaves no entry. The input items
	# dict is NOT mutated.
	var stacks: Array = accelerator_build_state._accelerator_item_stacks_for_block("interplanetary-accelerator")
	var launch_items: Dictionary = {"copper": 9000, "lead": 8000, "silicon": 5000, "thorium": 4000, "surge-alloy": 10}
	var launched: Dictionary = accelerator_build_state.source_accelerator_launch_state(launch_items, 1000000.0, 1000000.0, stacks)
	var launched_resources: Dictionary = launched.get("resources", {})
	proof["launch_clears_items_and_resets_progress"] = bool(launched.get("items", {"x": 1}).is_empty()) and int(launched_resources.get("copper", -1)) == 1000 and bool(launched_resources.has("lead")) == false and bool(launched_resources.has("silicon")) == false and bool(launched_resources.has("thorium")) == false and int(launched_resources.get("surge-alloy", -1)) == 10 and int(launched_resources.size()) == 2 and is_equal_approx(float(launched.get("progress", -1.0)), 0.0) and int(launch_items.get("copper", -1)) == 9000

	# The battery drain is the useBatteries total: new
	# stored = stored - min(stored, requirement), clamped
	# at 0 (the clamp guards the epsilon residue when the
	# gate passed at stored = requirement - 0.00001). The
	# per-battery proportional status scaling
	# (PowerGraph.java:160-165) waits for a battery-list
	# graph slice -- the port graph summary carries only the
	# total, no battery list.
	var drain_full: Dictionary = accelerator_build_state.source_accelerator_launch_state({}, 1500000.0, 1000000.0, stacks)
	var drain_exact: Dictionary = accelerator_build_state.source_accelerator_launch_state({}, 1000000.0, 1000000.0, stacks)
	var drain_boundary: Dictionary = accelerator_build_state.source_accelerator_launch_state({}, 1000000.0 - 0.00001, 1000000.0, stacks)
	var pure_drain: bool = is_equal_approx(float(drain_full.get("battery_stored", -1.0)), 500000.0) and is_equal_approx(float(drain_exact.get("battery_stored", -1.0)), 0.0) and is_equal_approx(float(drain_boundary.get("battery_stored", -1.0)), 0.0)

	# --- Live tick: the accelerator is an Accelerator build
	# with a static power consumer (interplanetary-accelerator,
	# consumePower 10f, Blocks.java:6829), placed live; the
	# tick driver is called directly (as the N2147/N2148/
	# N2149/N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/
	# N2160/N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/
	# N2169/N2170/N2171/N2172/N2173/N2174/N2175/N2176/N2177/
	# N2178/N2179/N2180/N2181/N2182 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The launch is driven by the
	# one-shot frame key `launch_requested` (default false):
	# the driver re-checks canLaunch on the folded
	# efficiency, the frame battery_stored input, the
	# advanced progress and the launching flag, applies the
	# transition only when the gate passes, DISCARDS the
	# resources (Java hands them to
	# universe.updateLaunchResources(resources),
	# Accelerator.java:281 -- no port equivalent) and CLEARS
	# the request in both cases. The battery_stored frame
	# input has no live fill yet (the graph summary computes
	# it but does not stamp it on the building frame), so the
	# proof seeds it directly (the N2223 precedent). The
	# launching flag is never touched by the transition.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var accelerator_cell := Vector2i(30, 21)
	var accelerator := Sprite2D.new()
	game.add_child(accelerator)
	game.call("record_placed_block", accelerator, blocks_by_id["interplanetary-accelerator"], accelerator_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and
	# items on it).
	accelerator_build_state.source_accelerator_bind_frame_state(accelerator, blocks_by_id["interplanetary-accelerator"])
	var accelerator_frame: Dictionary = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})

	# Full power, all four stacks held, progress 1.0, full
	# battery, launch requested: the gate passes, the
	# transition clears the items, drains the battery by the
	# requirement, resets progress to 0.0 and clears the
	# request -- and launching stays false.
	accelerator_frame["power_status"] = 1.0
	accelerator_frame["items"] = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}
	accelerator_frame["progress"] = 1.0
	accelerator_frame["battery_stored"] = 1000000.0
	accelerator_frame["launch_requested"] = true
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var live_items: Dictionary = accelerator_frame.get("items", {"x": 1})
	var live_pass: bool = bool(live_items.is_empty()) and is_equal_approx(float(accelerator_frame.get("progress", -1.0)), 0.0) and is_equal_approx(float(accelerator_frame.get("battery_stored", -1.0)), 0.0) and bool(accelerator_frame.get("launch_requested", true)) == false and bool(accelerator_frame.get("launching", false)) == false
	proof["launch_clears_items_and_resets_progress"] = bool(proof["launch_clears_items_and_resets_progress"]) and live_pass

	# Same setup but a half-full battery: the gate fails, so
	# the request is cleared and NOTHING else changes -- the
	# items stay full, progress stays 1.0, the battery stays
	# half-full, launching stays false.
	accelerator_frame["power_status"] = 1.0
	accelerator_frame["items"] = {"copper": 8000, "lead": 8000, "silicon": 5000, "thorium": 4000}
	accelerator_frame["progress"] = 1.0
	accelerator_frame["battery_stored"] = 500000.0
	accelerator_frame["launch_requested"] = true
	accelerator_build_state.source_accelerator_tick_buildings_state(game, 1.0 / 60.0)
	accelerator_frame = accelerator.get_meta(accelerator_build_state.SOURCE_ACCELERATOR_BUILDING_META_KEY, {})
	var kept_items: Dictionary = accelerator_frame.get("items", {})
	var live_fail: bool = int(kept_items.get("copper", -1)) == 8000 and int(kept_items.get("lead", -1)) == 8000 and int(kept_items.get("silicon", -1)) == 5000 and int(kept_items.get("thorium", -1)) == 4000 and is_equal_approx(float(accelerator_frame.get("progress", -1.0)), 1.0) and is_equal_approx(float(accelerator_frame.get("battery_stored", -1.0)), 500000.0) and bool(accelerator_frame.get("launch_requested", true)) == false and bool(accelerator_frame.get("launching", false)) == false
	proof["launch_drains_battery_by_requirement"] = pure_drain and live_pass and live_fail

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07AcceleratorLaunchProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
