extends Node

const main_scene := preload("res://scenes/Main.tscn")
const fracker_build_state := preload("res://src/game/SourceFrackerBuildState.gd")
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
	var oil_id: int = int(liquid_catalog["liquid_id_by_name"].get("oil", -1))

	# --- Pure advance (N2224): FrackerBuild.updateTile()
	# (Fracker.java:30-44): while efficiency > 0 the
	# accumulator consumes one sand at itemUseTime
	# (Fracker.java:32-35), super.updateTile() runs the
	# solid-pump advance (Fracker.java:37, reused from N2220
	# with the oil-extractor pump amount 0.25f,
	# Blocks.java:2969), and the accumulator advances by
	# delta() * efficiency (Fracker.java:38); while
	# efficiency is 0 the Fracker decays its own warmup and
	# zeroes lastPump WITHOUT calling super.updateTile(), so
	# pumpTime stands still too (Fracker.java:40-43).
	# source_delta is Time.delta in ticks (1.0 = one tick);
	# the item use time is the def constant 60f
	# (Blocks.java:2974), the pump amount the def constant
	# 0.25f (Blocks.java:2969) and the capacity the def
	# constant 40f (Blocks.java:2971). The amounts below are
	# set through the shared liquid module helper
	# (SourceLiquidModuleState.source_set_state) over a fresh
	# module state, the same store the driver reads.

	# accumulator += delta() * efficiency (Fracker.java:38),
	# with delta() = Time.delta * timeScale: at efficiency
	# 0.5 one tick adds 0.5, and at timeScale 2.0 it adds
	# 1.0 -- while the warmup from super.updateTile() is
	# 0.02 in both cases, because lerpDelta scales by RAW
	# Time.delta, not delta().
	var acc_frame: Dictionary = {"efficiency": 0.5, "accumulator": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}
	var acc_advanced: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state(acc_frame, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var acc_scaled: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state(acc_frame, 1.0, 2.0, oil_id, 40.0, 0.25, 60.0)
	proof["accumulator_advances_with_efficiency"] = is_equal_approx(float(acc_advanced.get("accumulator", -1.0)), 0.5) and is_equal_approx(float(acc_scaled.get("accumulator", -1.0)), 1.0) and is_equal_approx(float(acc_advanced.get("warmup", -1.0)), 0.02) and is_equal_approx(float(acc_scaled.get("warmup", -1.0)), 0.02)

	# consume() at itemUseTime (Fracker.java:32-35): an
	# accumulator at 60.0 consumes one sand (3 -> 2) and
	# subtracts 60, then advances by delta() * efficiency
	# (1.0 * 1.0), landing at 1.0. Below the threshold
	# (59.9) nothing is consumed and the accumulator lands
	# at 60.9. With no sand held the removal clamps to the
	# held count (ItemModule.remove, ItemModule.java:258-263)
	# -- 0 sand stays 0 -- while the accumulator still
	# advances to 1.0.
	var consume_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var consumed: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "accumulator": 60.0, "warmup": 0.0, "pump_time": 0.0, "liquids": consume_liquids, "items": {"sand": 3}}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var consumed_items: Dictionary = consumed.get("items", {})
	var below: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "accumulator": 59.9, "warmup": 0.0, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"]), "items": {"sand": 3}}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var below_items: Dictionary = below.get("items", {})
	var empty: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "accumulator": 60.0, "warmup": 0.0, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"]), "items": {}}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var empty_items: Dictionary = empty.get("items", {})
	proof["consume_at_item_use_time"] = int(consumed_items.get("sand", -1)) == 2 and is_equal_approx(float(consumed.get("accumulator", -1.0)), 1.0) and int(below_items.get("sand", -1)) == 3 and is_equal_approx(float(below.get("accumulator", -1.0)), 60.9) and int(empty_items.get("sand", -1)) == 0 and is_equal_approx(float(empty.get("accumulator", -1.0)), 1.0)

	# super.updateTile() pumps oil through the reused N2220
	# pure function (Fracker.java:37): maxPump = min(capacity
	# - typeLiquid(), pumpAmount * delta() * fraction *
	# efficiency) (SolidPump.java:127) -- fraction 2.0
	# (valid_tiles 1.5 + boost 0.5) at efficiency 0.5 pumps
	# 0.25 * 1.0 * 2.0 * 0.5 = 0.25 into the oil store, with
	# lastPump = maxPump / Time.delta = 0.25; a store at
	# 39.95 clamps to the 0.05 of headroom left.
	var pump_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	var pumped: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 0.5, "accumulator": 0.0, "valid_tiles": 1.5, "boost": 0.5, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": pump_liquids}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var pumped_amount: float = float(liquid_module_state.source_get_state(pump_liquids, oil_id).get("amount", -1.0))
	var clamp_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(clamp_liquids, oil_id, 39.95)
	var clamped: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 0.5, "accumulator": 0.0, "valid_tiles": 1.5, "boost": 0.5, "attribute_env": 0.0, "warmup": 0.0, "pump_time": 0.0, "liquids": clamp_liquids}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var clamped_amount: float = float(liquid_module_state.source_get_state(clamp_liquids, oil_id).get("amount", -1.0))
	proof["super_advance_pumps_oil"] = is_equal_approx(float(pumped.get("fraction", -1.0)), 2.0) and is_equal_approx(float(pumped.get("max_pump", -1.0)), 0.25) and is_equal_approx(pumped_amount, 0.25) and is_equal_approx(float(pumped.get("last_pump", -1.0)), 0.25) and is_equal_approx(float(clamped.get("max_pump", -1.0)), 0.05) and is_equal_approx(clamped_amount, 40.0)

	# The else branch (Fracker.java:40-43): with no
	# efficiency warmup decays 1.0 -> 0.98, lastPump is 0,
	# and -- because super.updateTile() is NOT called --
	# pumpTime stands still at 5.0 and the accumulator
	# stands still at 10.0; nothing is pumped.
	var idle: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 0.0, "accumulator": 10.0, "warmup": 1.0, "pump_time": 5.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	proof["warmup_decays_when_no_efficiency"] = is_equal_approx(float(idle.get("warmup", -1.0)), 0.98) and is_equal_approx(float(idle.get("pump_time", -1.0)), 5.0) and is_equal_approx(float(idle.get("accumulator", -1.0)), 10.0) and is_equal_approx(float(idle.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(idle.get("max_pump", -1.0)), 0.0)

	# lastPump is zero whenever idle, but the two idle paths
	# differ: a full store at efficiency 1.0 still runs
	# super.updateTile(), so its idle branch zeroes lastPump
	# while warmup decays 1.0 -> 0.98, pumpTime advances by
	# the decayed warmup * edelta() (1.0 + 0.98 * 1.0 * 1.0
	# = 1.98) and the accumulator advances to 1.0; with no
	# efficiency at all super never runs, so warmup decays
	# 0.5 -> 0.49 and lastPump is 0.
	var full_liquids: Dictionary = liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])
	liquid_module_state.source_set_state(full_liquids, oil_id, 40.0)
	var full: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "accumulator": 0.0, "valid_tiles": 1.0, "boost": 0.0, "attribute_env": 0.0, "warmup": 1.0, "pump_time": 1.0, "liquids": full_liquids}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var unpowered: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 0.0, "accumulator": 0.0, "warmup": 0.5, "pump_time": 0.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	proof["last_pump_zero_when_idle"] = is_equal_approx(float(full.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(full.get("warmup", -1.0)), 0.98) and is_equal_approx(float(full.get("pump_time", -1.0)), 1.98) and is_equal_approx(float(full.get("accumulator", -1.0)), 1.0) and is_equal_approx(float(unpowered.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(unpowered.get("warmup", -1.0)), 0.49)

	# Frame defaults: an empty frame reads efficiency 0.0
	# (BuildingComp.java:85 `transient float efficiency;`),
	# so the else branch returns all zeros with an empty
	# items dict; a frame with efficiency but no fraction
	# inputs reads fraction 0.0 (valid_tiles / boost /
	# attribute_env default 0f), so it pumps nothing while
	# warmup still rises 0.02, pumpTime advances 0.02 * 1.0
	# * 1.0 = 0.02 and the accumulator advances 1.0.
	var empty_frame: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	var no_fraction: Dictionary = fracker_build_state.source_fracker_update_tile_advance_state({"efficiency": 1.0, "liquids": liquid_module_state.source_initial_state(liquid_catalog["content_liquid_ids"])}, 1.0, 1.0, oil_id, 40.0, 0.25, 60.0)
	proof["frame_defaults_zero"] = is_equal_approx(float(empty_frame.get("accumulator", -1.0)), 0.0) and is_equal_approx(float(empty_frame.get("warmup", -1.0)), 0.0) and is_equal_approx(float(empty_frame.get("pump_time", -1.0)), 0.0) and is_equal_approx(float(empty_frame.get("last_pump", -1.0)), 0.0) and is_equal_approx(float(empty_frame.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(empty_frame.get("fraction", -1.0)), 0.0) and (empty_frame.get("items", null) as Dictionary).is_empty() and is_equal_approx(float(no_fraction.get("fraction", -1.0)), 0.0) and is_equal_approx(float(no_fraction.get("max_pump", -1.0)), 0.0) and is_equal_approx(float(no_fraction.get("warmup", -1.0)), 0.02) and is_equal_approx(float(no_fraction.get("pump_time", -1.0)), 0.02) and is_equal_approx(float(no_fraction.get("accumulator", -1.0)), 1.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07FrackerUpdateTileProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
