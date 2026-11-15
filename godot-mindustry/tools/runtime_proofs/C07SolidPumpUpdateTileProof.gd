extends Node

const main_scene := preload("res://scenes/Main.tscn")
const solid_pump_build_state := preload("res://src/game/SourceSolidPumpBuildState.gd")
const liquid_module_state := preload("res://src/game/SourceLiquidModuleState.gd")
const content_registry_runtime_state := preload("res://src/game/SourceContentRegistryRuntimeState.gd")
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

	var liquid_catalog: Dictionary = content_registry_runtime_state.source_liquid_catalog_state(game.get("content_catalog"))
	var water_id: int = int(liquid_catalog["liquid_id_by_name"].get("water", -1))

	# --- Pure advance (N2220): SolidPumpBuild.updateTile()
	# (SolidPump.java:122-141): liquidDrop = result
	# (SolidPump.java:123), the fraction max(validTiles +
	# boost + attribute.env(), 0) (SolidPump.java:124), the
	# pumping branch (SolidPump.java:126-132), the idle branch
	# (SolidPump.java:133-136), pumpTime += warmup * edelta()
	# (SolidPump.java:138), dumpLiquid(result)
	# (SolidPump.java:140, deferred). source_delta is
	# Time.delta in ticks (1.0 = one tick); pumpAmount is the
	# def constant 0.11f (Blocks.java:2923) and the capacity
	# the def constant 40f (Blocks.java:2925). The amounts
	# below are set through the shared liquid module helper
	# (SourceLiquidModuleState.source_set_state) over a fresh
	# module state, the same store the driver reads.

	# maxPump = min(capacity - typeLiquid(), pumpAmount *
	# delta() * fraction * efficiency) (SolidPump.java:127):
	# fraction 2.0 (valid_tiles 1.5 + boost 0.5) at efficiency
	# 0.5 pumps 0.11 * 1.0 * 2.0 * 0.5 = 0.11 into the store;
	# a store at 39.95 clamps to the 0.05 of headroom left.
	var pump_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var pumped: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 0.5, "valid_tiles": 1.5, "boost": 0.5, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": pump_liquids}, 1.0, 1.0, water_id, 40.0, 0.11)
	var pumped_amount: float = float(liquid_module_state.source_get_state(pump_liquids, water_id).get("amount", -1.0))
	var clamp_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(clamp_liquids, water_id, 39.95)
	var clamped: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 0.5, "valid_tiles": 1.5, "boost": 0.5, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": clamp_liquids}, 1.0, 1.0, water_id, 40.0, 0.11)
	var clamped_amount: float = float(liquid_module_state.source_get_state(clamp_liquids, water_id).get("amount", -1.0))
	proof["max_pump_folds_fraction_efficiency"] = is_equal_approx(float(pumped.get("fraction", -1.0)), 2.0) and is_equal_approx(float(pumped.get("max_pump", -1.0)), 0.11) and is_equal_approx(pumped_amount, 0.11) and is_equal_approx(float(clamped.get("max_pump", -1.0)), 0.05) and is_equal_approx(clamped_amount, 40.0)

	# lastPump = maxPump / Time.delta (SolidPump.java:129):
	# the rate is delta-independent -- a 2-tick delta pumps
	# twice as much (0.22) but reports the same 0.11 rate.
	var rate_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var rate_double: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 0.5, "valid_tiles": 1.5, "boost": 0.5, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": rate_liquids}, 2.0, 1.0, water_id, 40.0, 0.11)
	proof["last_pump_rate_from_max_pump"] = is_equal_approx(float(pumped.get("last_pump", -1.0)), 0.11) and is_equal_approx(float(rate_double.get("max_pump", -1.0)), 0.22) and is_equal_approx(float(rate_double.get("last_pump", -1.0)), 0.11)

	# warmup = Mathf.lerpDelta(warmup, 1f, 0.02f)
	# (SolidPump.java:130): one tick from 0 rises exactly
	# 0.02, and 60 ticks approach one (1 - 0.98^60 = 0.7032).
	var warmup_frame: Dictionary = {"efficiency": 1.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}
	var warmup_first: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state(warmup_frame, 1.0, 1.0, water_id, 40.0, 0.11)
	for iteration in range(60):
		var advanced: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state(warmup_frame, 1.0, 1.0, water_id, 40.0, 0.11)
		warmup_frame["warmup"] = advanced["warmup"]
		warmup_frame["pump_time"] = advanced["pump_time"]
	proof["warmup_approaches_one_when_pumping"] = is_equal_approx(float(warmup_first.get("warmup", -1.0)), 0.02) and float(warmup_frame.get("warmup", -1.0)) > 0.65 and float(warmup_frame.get("warmup", -1.0)) < 1.0

	# pumpTime += warmup * edelta() (SolidPump.java:138), with
	# the NEW warmup (lerpDelta(0.5, 1, 0.02) = 0.51) and
	# edelta() = efficiency * Time.delta * timeScale: at
	# efficiency 0.5 the time rises 0.51 * 0.5 * 1.0 = 0.255,
	# and at timeScale 2.0 it rises 0.51 * 0.5 * 2.0 = 0.51 --
	# while the warmup itself is 0.51 in both cases, because
	# lerpDelta scales by RAW Time.delta, not delta().
	var time_frame: Dictionary = {"efficiency": 0.5, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 0.5, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}
	var time_advanced: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state(time_frame, 1.0, 1.0, water_id, 40.0, 0.11)
	var time_scaled: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state(time_frame, 1.0, 2.0, water_id, 40.0, 0.11)
	proof["pump_time_advances_with_warmup"] = is_equal_approx(float(time_advanced.get("warmup", -1.0)), 0.51) and is_equal_approx(float(time_advanced.get("pump_time", -1.0)), 0.255) and is_equal_approx(float(time_scaled.get("warmup", -1.0)), 0.51) and is_equal_approx(float(time_scaled.get("pump_time", -1.0)), 0.51)

	# The idle branch (SolidPump.java:133-136): a full store
	# (typeLiquid 40.0, not < 40 - 0.001) pumps nothing,
	# lastPump is 0, and warmup decays 1.0 -> 0.98 while
	# pumpTime still advances by the decayed warmup * edelta()
	# (1.0 + 0.98 * 1.0 * 1.0 = 1.98). Zero efficiency pumps
	# nothing either, and pumpTime freezes (edelta is 0).
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(full_liquids, water_id, 40.0)
	var full: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 1.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 1.0, "pump_time": 1.0, "liquids": full_liquids}, 1.0, 1.0, water_id, 40.0, 0.11)
	var full_amount: float = float(liquid_module_state.source_get_state(full_liquids, water_id).get("amount", -1.0))
	var unpowered: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 0.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 1.0, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}, 1.0, 1.0, water_id, 40.0, 0.11)
	proof["no_pump_when_full"] = is_equal_approx(float(full.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(full.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(full.get("warmup", -1.0)), 0.98) and is_equal_approx(float(full.get("pump_time", -1.0)), 1.98) and is_equal_approx(full_amount, 40.0) and is_equal_approx(float(unpowered.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(unpowered.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(unpowered.get("warmup", -1.0)), 0.98) and is_equal_approx(float(unpowered.get("pump_time", -1.0)), 0.0)

	# Frame defaults: an empty frame reads efficiency 0.0
	# (BuildingComp.java:85 `transient float efficiency;`),
	# so the idle branch returns all zeros; a frame with
	# efficiency but no fraction inputs reads fraction 0.0
	# (valid_tiles / boost / attribute_env default 0f), so it
	# pumps nothing while warmup still rises 0.02 and pumpTime
	# advances 0.02 * 1.0 * 1.0 = 0.02.
	var empty: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({}, 1.0, 1.0, water_id, 40.0, 0.11)
	var no_fraction: Dictionary = solid_pump_build_state.source_solid_pump_update_tile_advance_state({"efficiency": 1.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}, 1.0, 1.0, water_id, 40.0, 0.11)
	proof["frame_defaults_zero"] = is_equal_approx(float(empty.get("warmup", -1.0)), 0.0) and is_equal_approx(float(empty.get("pump_time", -1.0)), 0.0) and is_equal_approx(float(empty.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(empty.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(empty.get("fraction", -1.0)), 0.0) and is_equal_approx(float(no_fraction.get("fraction", -1.0)), 0.0) and is_equal_approx(float(no_fraction.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(no_fraction.get("warmup", -1.0)), 0.02) and is_equal_approx(float(no_fraction.get("pump_time", -1.0)), 0.02)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07SolidPumpUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
