extends Node

const main_scene := preload("res://scenes/Main.tscn")
const repair_turret_build_state := preload("res://src/game/SourceRepairTurretBuildState.gd")
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

	# --- Pure shouldConsume gate (N2212):
	# RepairPointBuild.shouldConsume()
	# (RepairTurret.java:221-223, `public boolean
	# shouldConsume(){` with `return target != null &&
	# enabled;`, RepairTurret.java:222) -- the gate reads the
	# live target AND the enabled flag. The field is `public
	# Unit target;` (RepairTurret.java:154) on RepairPointBuild
	# (`public class RepairPointBuild extends Building
	# implements Ranged, RotBlock{`, RepairTurret.java:153).
	# Unlike the UnitCargoLoader gate (N2211) this one HAS
	# `&& enabled` -- the pure gate reads frame["enabled"] too
	# (the ItemBridge N2188 precedent). The gate reads only
	# the null-ness of frame["target"], so the present-target
	# fixture below is a minimal test-only Dictionary -- no
	# real Unit is built; the port has no live target acquire
	# on the building frame yet (the Units.closest acquire /
	# clear is the updateTile advance, RepairTurret.java:
	# 187-218, and waits for its own slice).
	var has_target: Dictionary = repair_turret_build_state.source_repair_turret_should_consume_state({"target": {"type": "dart"}})
	proof["gate_true_when_target_present"] = bool(has_target.get("should_consume", false)) and bool(has_target.get("has_target", false))

	var no_target: Dictionary = repair_turret_build_state.source_repair_turret_should_consume_state({"target": null})
	proof["gate_false_when_target_null"] = bool(no_target.get("should_consume", true)) == false and bool(no_target.get("has_target", true)) == false

	var disabled_has_target: Dictionary = repair_turret_build_state.source_repair_turret_should_consume_state({"target": {"type": "dart"}, "enabled": false})
	proof["gate_false_when_disabled"] = bool(disabled_has_target.get("should_consume", true)) == false and bool(disabled_has_target.get("has_target", false))

	# --- Live tick: the repair turret is a RepairTurret build
	# with a conditional power consumer (repair-point, powerUse
	# 1f; repair-turret, powerUse 5f), placed live; the tick
	# driver is called directly (as the N2147/N2148/N2149/
	# N2150/N2153/N2154/N2155/N2156/N2157/N2158/N2159/N2160/
	# N2161/N2162/N2163/N2164/N2165/N2166/N2167/N2168/N2169/
	# N2170/N2171/N2172/N2173/N2174 proofs do), not
	# simulate_factory, so the graph update does not overwrite
	# the stamped power_status -- the write-back itself is
	# already proven by N2142. The repair turret tick models
	# no other consumers, so with a power consumer the first
	# pass holds only the power row; when the gate is false
	# updateConsumption forces efficiency to zero
	# (BuildingComp.java:1960 + 1992).
	var catalog = game.get("content_catalog")
	var blocks_by_id: Dictionary = {}
	for registered_block in catalog.get_many("block"):
		blocks_by_id[registered_block.id] = registered_block

	var repair_turret_cell := Vector2i(28, 21)
	var repair_turret := Sprite2D.new()
	game.add_child(repair_turret)
	game.call("record_placed_block", repair_turret, blocks_by_id["repair-point"], repair_turret_cell)
	# Bind the frame explicitly (the N2149 pattern: the driver
	# binds it on its first tick, but the proof needs the live
	# frame dict before the tick to stamp power_status and set
	# the target on it).
	repair_turret_build_state.source_repair_turret_bind_frame_state(repair_turret, blocks_by_id["repair-point"])
	var repair_turret_frame: Dictionary = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})

	# A freshly bound frame carries the target key defaulting
	# to null (the Java field default) -- no target yet, so
	# the gate reads false and the turret does not consume.
	proof["frame_target_default_null"] = repair_turret_frame.has("target") and repair_turret_frame["target"] == null

	# No target: gate false -> efficiency 0 even at half power.
	repair_turret_frame["target"] = null
	repair_turret_frame["power_status"] = 0.5
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_zero_when_gate_false"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.0)

	# Target present: gate true -> efficiency folds the power
	# min 0.5 (the N2174 power fold preserved).
	repair_turret_frame["target"] = {"type": "dart"}
	repair_turret_frame["power_status"] = 0.5
	repair_turret_build_state.source_repair_turret_tick_buildings_state(game, 1.0 / 60.0)
	repair_turret_frame = repair_turret.get_meta(repair_turret_build_state.SOURCE_REPAIR_TURRET_BUILDING_META_KEY, {})
	proof["efficiency_folds_power_when_gate_true"] = is_equal_approx(float(repair_turret_frame.get("efficiency", -1.0)), 0.5)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
