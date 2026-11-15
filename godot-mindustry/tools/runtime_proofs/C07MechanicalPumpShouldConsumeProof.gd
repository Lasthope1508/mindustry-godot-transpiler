extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mechanical_pump_build_state := preload("res://src/game/SourceMechanicalPumpBuildState.gd")
const terrain_state := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
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

	# --- Pure gate (N2205): PumpBuild.shouldConsume()
	# (Pump.java:155, `public boolean shouldConsume(){` with
	# `return liquidDrop != null && liquids.get(liquidDrop) <
	# liquidCapacity - 0.01f && enabled;`, Pump.java:156) --
	# the pump consumes only while it has a liquid drop AND
	# its stored amount of that liquid is below capacity
	# minus 0.01f AND it is enabled. The override INCLUDES
	# the enabled check. liquidDrop is the onProximityUpdate
	# field (Pump.java:114, `public @Nullable Liquid
	# liquidDrop = null;`); the liquids amount is
	# liquids.get(liquidDrop) over the sprite liquids meta
	# (the LiquidModule dict, read through the shared liquid
	# module source_get_state by liquid id, resolved from
	# the drop name through the catalog liquid_id_by_name
	# map); liquidCapacity is a def constant (rotary-pump
	# 80f, Blocks.java:2308). The liquids stand-in mirrors
	# the live module shape ({"liquids": [...], "current":
	# id, "flow": null}) with a one-liquid map; the gate
	# only reads the drop's slot.
	var open_gate: Dictionary = mechanical_pump_build_state.source_mechanical_pump_should_consume_state({"enabled": true}, "water", {"liquids": [10.0], "current": 0, "flow": null}, 80.0, {"water": 0})
	proof["gate_open_when_liquid_below_capacity"] = bool(open_gate.get("should_consume", false)) and str(open_gate.get("liquid_drop", "")) == "water"

	var dry_gate: Dictionary = mechanical_pump_build_state.source_mechanical_pump_should_consume_state({"enabled": true}, null, {"liquids": [0.0], "current": 0, "flow": null}, 80.0, {"water": 0})
	proof["gate_closed_when_no_liquid_drop"] = bool(dry_gate.get("should_consume", true)) == false and dry_gate.get("liquid_drop", "water") == null

	var full_gate: Dictionary = mechanical_pump_build_state.source_mechanical_pump_should_consume_state({"enabled": true}, "water", {"liquids": [80.0], "current": 0, "flow": null}, 80.0, {"water": 0})
	proof["gate_closed_when_liquids_full"] = bool(full_gate.get("should_consume", true)) == false and str(full_gate.get("liquid_drop", "")) == "water"

	var disabled_gate: Dictionary = mechanical_pump_build_state.source_mechanical_pump_should_consume_state({"enabled": false}, "water", {"liquids": [0.0], "current": 0, "flow": null}, 80.0, {"water": 0})
	proof["gate_closed_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and str(disabled_gate.get("liquid_drop", "")) == "water"

	# --- Live tick: the rotary-pump is a Pump with a power
	# consumer (consumePower 0.3f, liquidCapacity 80f),
	# placed live on shallow-water floor so the per-tick
	# proximity scan finds liquidDrop water; the tick driver
	# is called directly (as the N2154 proof does), not
	# simulate_factory, so the graph update does not
	# overwrite the stamped power_status -- the write-back
	# itself is already proven by N2142. The pump tick
	# models no other consumers, so with a power consumer
	# the first pass holds only the power row. The floor is
	# set before placement (the drill-proof pattern), so the
	# scan sees water under the whole size-2 footprint.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block
	var liquid_id_by_name: Dictionary = content_registry_state.source_liquid_catalog_state(catalog).get("liquid_id_by_name", {})
	var water_id: int = int(liquid_id_by_name.get("water", -1))

	var pump_cell := Vector2i(28, 20)
	var shallow_water = catalog.get_by_id("shallow-water")
	for occupied in game.call("occupied_cells", pump_cell, blocks_by_id["rotary-pump"]):
		terrain_state.source_set_world_floor_state(game, occupied.x, occupied.y, shallow_water)
	var pump := Sprite2D.new()
	game.add_child(pump)
	game.call("record_placed_block", pump, blocks_by_id["rotary-pump"], pump_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status on it).
	mechanical_pump_build_state.source_mechanical_pump_bind_frame_state(pump, blocks_by_id["rotary-pump"])
	var pump_frame: Dictionary = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})

	# Gate open (water under the footprint, empty store,
	# enabled): half power folds efficiency to 0.5 -- the old
	# N2154 behavior, kept.
	pump_frame["power_status"] = 0.5
	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	proof["efficiency_kept_when_gate_open"] = is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.5)

	# Gate closed (store filled to liquidCapacity 80): efficiency
	# folds to 0 even with full power.
	var pump_liquids: Dictionary = pump.get_meta("source_building_liquids", {})
	pump_liquids["liquids"][water_id] = 80.0
	pump_frame["power_status"] = 1.0
	mechanical_pump_build_state.source_mechanical_pump_tick_buildings_state(game, 1.0 / 60.0)
	pump_frame = pump.get_meta(mechanical_pump_build_state.SOURCE_MECHANICAL_PUMP_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_closed"] = is_equal_approx(float(pump_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MechanicalPumpShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
