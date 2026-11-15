extends Node

const main_scene := preload("res://scenes/Main.tscn")
const drill_build_state := preload("res://src/game/SourceDrillConsumptionRuntimeState.gd")
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

	# --- Pure gate (N2204): DrillBuild.shouldConsume()
	# (Drill.java:247, `public boolean shouldConsume(){` with
	# `return items.total() < itemCapacity && enabled &&
	# dominantItem != null;`, Drill.java:248) -- the drill
	# consumes only while its item store is below capacity AND
	# it is enabled AND it has a dominant item. The override
	# INCLUDES the enabled check -- unlike the LaunchPad
	# (N2186) and ShockwaveTower (N2187) overrides -- so the
	# pure function reads all three frame inputs: items (the
	# Building.items ItemModule, frame["items"] keyed by item
	# name, totaled by the shared inventory.items_total
	# helper), enabled (BuildingComp.java:77, `transient
	# boolean enabled = true;`), and dominant_item
	# (Drill.java:244, `public Item dominantItem;`, set by
	# onProximityUpdate, Drill.java:275-277; null when no
	# mineable ore sits under the footprint or after pickup).
	# item_capacity is the block def capacity
	# (block.properties["itemCapacity"], 10 for the
	# laser-drill), passed by the driver -- the frame does not
	# carry it. A missing items dict reads empty; a missing
	# enabled reads true (the Java field default); a missing
	# dominant item reads null (no ore). The dominant item
	# stand-in {"id": 0} mirrors the live frame shape (a dict
	# with an "id" key); the gate only checks null-ness.
	var open_gate: Dictionary = drill_build_state.source_drill_should_consume_state({"items": {"copper": 9}, "enabled": true, "dominant_item": {"id": 0}}, 10)
	proof["gate_open_when_items_below_capacity"] = bool(open_gate.get("should_consume", false)) and open_gate.get("dominant_item", null) != null

	var full_gate: Dictionary = drill_build_state.source_drill_should_consume_state({"items": {"copper": 10}, "enabled": true, "dominant_item": {"id": 0}}, 10)
	proof["gate_closed_when_items_full"] = bool(full_gate.get("should_consume", true)) == false and full_gate.get("dominant_item", null) != null

	var no_ore_gate: Dictionary = drill_build_state.source_drill_should_consume_state({"items": {}, "enabled": true, "dominant_item": null}, 10)
	proof["gate_closed_when_no_dominant_item"] = bool(no_ore_gate.get("should_consume", true)) == false and no_ore_gate.get("dominant_item", {"id": 0}) == null

	var disabled_gate: Dictionary = drill_build_state.source_drill_should_consume_state({"items": {}, "enabled": false, "dominant_item": {"id": 0}}, 10)
	proof["gate_closed_when_disabled"] = bool(disabled_gate.get("should_consume", true)) == false and disabled_gate.get("dominant_item", null) != null

	# --- Live tick: the laser-drill is a base Drill with a power
	# consumer (consumePower 1.1, itemCapacity 10), placed live on
	# copper ore so should_consume is true; the tick driver is
	# called directly (as the N2147 proof does), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The laser-drill's water booster
	# is optional, so with no water the first pass holds only
	# the power row.
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var laser_cell := Vector2i(28, 20)
	var laser := Sprite2D.new()
	game.add_child(laser)
	var terrain := preload("res://src/game/SourceWorldTerrainRuntimeState.gd")
	for occupied in game.call("occupied_cells", laser_cell, blocks_by_id["laser-drill"]):
		terrain.source_set_world_overlay_state(game, occupied.x, occupied.y, catalog.get_by_id("ore-copper"), false)
	game.call("record_placed_block", laser, blocks_by_id["laser-drill"], laser_cell)
	# Bind the frame + dominant item from the ore under the
	# footprint: the overlay mutation binds proximity only when a
	# sprite is already on the cell, and the overlays were set
	# before placement, so bind explicitly here.
	drill_build_state.source_on_proximity_update_state(game, laser, blocks_by_id["laser-drill"])
	var laser_frame: Dictionary = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})

	# Gate open (empty store, ore under the footprint, enabled):
	# half power folds efficiency to 0.5 -- the old N2147
	# behavior, kept.
	laser_frame["power_status"] = 0.5
	drill_build_state.source_tick_state(game, 1.0 / 60.0)
	laser_frame = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_kept_when_gate_open"] = is_equal_approx(float(laser_frame.get("efficiency", -1.0)), 0.5)

	# Gate closed (store filled to itemCapacity 10): efficiency
	# folds to 0 even with full power.
	laser_frame["items"] = {"copper": 10}
	laser_frame["power_status"] = 1.0
	drill_build_state.source_tick_state(game, 1.0 / 60.0)
	laser_frame = laser.get_meta(drill_build_state.SOURCE_DRILL_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_closed"] = is_equal_approx(float(laser_frame.get("efficiency", -1.0)), 0.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
