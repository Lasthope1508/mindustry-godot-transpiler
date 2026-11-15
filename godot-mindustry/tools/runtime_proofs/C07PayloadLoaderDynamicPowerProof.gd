extends Node

const main_scene := preload("res://scenes/Main.tscn")
const payload_loader_build_state := preload("res://src/game/SourcePayloadLoaderBuildState.gd")
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

	# --- Pure dynamic usage (N2270): init() registers the
	# dynamic consumer (PayloadLoader.java:77-84, guarded by
	# `if(loadPowerDynamic){` with `public boolean
	# loadPowerDynamic = true;`, PayloadLoader.java:27) with
	# the lambda (PayloadLoader.java:80):
	# consumePowerDynamic(basePowerUse, (PayloadLoaderBuild loader) -> loader.shouldConsume() ? (loader.hasBattery() && !loader.exporting ? maxPowerConsumption + basePowerUse : basePowerUse) : 0f);
	# basePowerUse is consPower.usage = 2f (PayloadLoader.
	# java:79, from the def `consumePower(2f);`,
	# Blocks.java:6686); the max is the class constant
	# `public float maxPowerConsumption = 40f;`
	# (PayloadLoader.java:26). The graph queries
	# requestedPower (ConsumePowerDynamic.java:24-25,
	# `return usage.get(entity);`).
	var zero_no_payload: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(false, false, false, 2.0, 40.0)
	var zero_no_payload_battery: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(false, true, false, 2.0, 40.0)
	proof["usage_zero_when_no_payload"] = is_equal_approx(float(zero_no_payload.get("usage", -1.0)), 0.0) and bool(zero_no_payload.get("charging", true)) == false and is_equal_approx(float(zero_no_payload_battery.get("usage", -1.0)), 0.0) and bool(zero_no_payload_battery.get("charging", true)) == false

	var base_no_battery: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(true, false, false, 2.0, 40.0)
	proof["usage_base_when_no_battery"] = is_equal_approx(float(base_no_battery.get("usage", -1.0)), 2.0) and bool(base_no_battery.get("charging", true)) == false

	var charging: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(true, true, false, 2.0, 40.0)
	proof["usage_charging_when_battery_and_not_exporting"] = is_equal_approx(float(charging.get("usage", -1.0)), 42.0) and bool(charging.get("charging", false))

	var base_exporting: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(true, true, true, 2.0, 40.0)
	proof["usage_base_when_exporting"] = is_equal_approx(float(base_exporting.get("usage", -1.0)), 2.0) and bool(base_exporting.get("charging", true)) == false

	# --- Live tick: the payload-loader is a PayloadLoader build
	# with a power consumer (consumePower 2f), placed live; the
	# tick driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/N2161
	# proofs do), not simulate_factory, so the graph update does
	# not overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The driver stamps frame
	# power_usage every tick at fold time, before the advance
	# call, so exporting is the previous tick's value.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var catalog_base: float = float(blocks_by_id["payload-loader"].properties.get("consumePower", -1.0))
	var catalog_charging: Dictionary = payload_loader_build_state.source_payload_loader_dynamic_power_usage_state(true, true, false, catalog_base, 40.0)
	proof["usage_reads_catalog_base_power"] = is_equal_approx(catalog_base, 2.0) and is_equal_approx(float(catalog_charging.get("usage", -1.0)), 42.0)

	var payload_loader_cell := Vector2i(28, 20)
	var payload_loader := Sprite2D.new()
	game.add_child(payload_loader)
	game.call("record_placed_block", payload_loader, blocks_by_id["payload-loader"], payload_loader_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	payload_loader_build_state.source_payload_loader_bind_frame_state(payload_loader, blocks_by_id["payload-loader"])
	var payload_loader_frame: Dictionary = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})

	# A battery payload fixture (the N2231 contract: only
	# block_cons_power_buffered is read for has_battery, plus
	# the capacity / status the advance charges -- capacity
	# 100.0 so one tick charges 0.4 and exporting stays false).
	payload_loader_frame["payload"] = {"block_cons_power_buffered": true, "block_cons_power_capacity": 100.0, "build_power_status": 0.0}
	payload_loader_frame["power_status"] = 1.0

	# Charging: battery held, not exporting -- 42.0.
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var charging_stored: bool = is_equal_approx(float(payload_loader_frame.get("power_usage", -1.0)), 42.0)

	# Exporting: the fold reads the previous tick's exporting
	# flag, set here before the tick -- back to base 2.0.
	payload_loader_frame["exporting"] = true
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var exporting_stored: bool = is_equal_approx(float(payload_loader_frame.get("power_usage", -1.0)), 2.0)

	# No payload: the gate closes -- 0.0.
	payload_loader_frame["payload"] = null
	payload_loader_build_state.source_payload_loader_tick_buildings_state(game, 1.0 / 60.0)
	payload_loader_frame = payload_loader.get_meta(payload_loader_build_state.SOURCE_PAYLOAD_LOADER_BUILDING_META_KEY, {})
	var zero_stored: bool = is_equal_approx(float(payload_loader_frame.get("power_usage", -1.0)), 0.0)

	proof["usage_stored_on_frame_each_tick"] = charging_stored and exporting_stored and zero_stored

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PayloadLoaderDynamicPowerProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
