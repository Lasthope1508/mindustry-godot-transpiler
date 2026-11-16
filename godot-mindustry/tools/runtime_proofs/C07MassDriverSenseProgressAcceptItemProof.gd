extends Node

const main_scene := preload("res://scenes/Main.tscn")
const mass_driver_build_state := preload("res://src/game/SourceMassDriverBuildState.gd")
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

	# --- Pure sense + accept (N2208): MassDriverBuild overrides
	# sense (MassDriver.java:224, `public double
	# sense(LAccess sensor){` with `if(sensor ==
	# LAccess.progress) return Mathf.clamp(1f -
	# reloadCounter);`, MassDriver.java:225) over the reload
	# counter (MassDriver.java:117, `public float
	# reloadCounter = 0f;`), which the updateTile advance
	# alone drains (MassDriver.java:143, `reloadCounter =
	# Mathf.clamp(reloadCounter - edelta() / reload);`) and
	# fire() resets (MassDriver.java:291, `reloadCounter =
	# 1f;`). Non-progress sensors fall through to super.sense
	# (MassDriver.java:226, `return super.sense(sensor);`),
	# and the BuildingComp super switch has NO progress case
	# (BuildingComp.java:2093, `public double
	# sense(LAccess sensor){` + 2123, `default -> Float.NaN;
	# //gets converted to null in logic`), so a logic read of
	# `progress` on a mass driver currently returns NaN/null
	# while Java returns the clamped fraction. Sense is a logic
	# read, not a tick write: NO driver tick line belongs here
	# (the N2206 sense precedent), so the proof calls the pure
	# function source_mass_driver_sense_state(frame, sensor)
	# directly with synthetic frames. An absent
	# `reload_counter` key reads 0.0 -- the Java init default
	# (`public float reloadCounter = 0f;`), so a freshly built
	# driver senses 1.0, fully reloaded, NOT NaN. The same
	# slice adds the intake predicate:
	# MassDriverBuild.acceptItem (MassDriver.java:285,
	# `public boolean acceptItem(Building source, Item item){`
	# with `return items.total() < itemCapacity &&
	# linkValid();`, MassDriver.java:287) -- "mass drivers
	# that output only cannot accept items"
	# (MassDriver.java:286). The frame carries the held items
	# as `items_total` (float, absent defaults to 0.0 -- a
	# fresh ItemModule totals 0, `protected int total;`,
	# ItemModule.java:25). The per-def itemCapacity is 120
	# for mass-driver (Blocks.java:2170, `itemCapacity =
	# 120;`), class default 10 (Block.java:75, `public int
	# itemCapacity = 10;`). linkValid() is a world query
	# (`protected boolean linkValid(){` with `if(link == -1)
	# return false;`, MassDriver.java:346-347), so the caller
	# passes `link_valid` in; acceptItem is an intake
	# predicate, not a tick write, so NO driver tick line
	# belongs here either -- the proof calls the pure function
	# source_mass_driver_accept_item_state(frame,
	# item_capacity, link_valid) directly with synthetic
	# frames.

	# Fresh driver senses 1.0 (fully reloaded): an empty frame
	# -- the counter defaults to 0.0f at Java init, so
	# clamp(1 - 0) = 1.0, NOT NaN. This pins the RED
	# absent-default decision.
	var fresh: Dictionary = mass_driver_build_state.source_mass_driver_sense_state({}, "progress")
	proof["sense_progress_fresh_driver_full"] = bool(fresh.get("handled", false)) == true and is_equal_approx(float(fresh.get("sense_value", -1.0)), 1.0) and bool(fresh.get("sense_value_is_nan", true)) == false

	# Counter 1.0 (just fired) senses 0.0: reload_counter=1.0
	# -- fire() resets it to 1f (MassDriver.java:291,
	# `reloadCounter = 1f;`).
	var fired: Dictionary = mass_driver_build_state.source_mass_driver_sense_state({"reload_counter": 1.0}, "progress")
	proof["sense_progress_after_fire_zero"] = bool(fired.get("handled", false)) == true and is_equal_approx(float(fired.get("sense_value", -1.0)), 0.0) and bool(fired.get("sense_value_is_nan", true)) == false

	# Counter 0.5 senses 0.5: half reloaded -- the drain
	# (MassDriver.java:143) moves the counter from 1.0 toward
	# 0.0, so the sensed fraction climbs back to 1.0.
	var half: Dictionary = mass_driver_build_state.source_mass_driver_sense_state({"reload_counter": 0.5}, "progress")
	proof["sense_progress_half_reloaded"] = bool(half.get("handled", false)) == true and is_equal_approx(float(half.get("sense_value", -1.0)), 0.5) and bool(half.get("sense_value_is_nan", true)) == false

	# Non-progress sensor falls through to super.sense:
	# sensor "health" -- handled false, sense_value null,
	# sense_value_is_nan true (the generic laccess wire for
	# "not handled", MassDriver.java:226, `return
	# super.sense(sensor);`).
	var fall_through: Dictionary = mass_driver_build_state.source_mass_driver_sense_state({"reload_counter": 0.5}, "health")
	proof["sense_fall_through_non_progress"] = bool(fall_through.get("handled", true)) == false and fall_through.get("sense_value", -1.0) == null and bool(fall_through.get("sense_value_is_nan", false)) == true

	# Items below capacity with a valid link accepts:
	# items_total=50.0 < item_capacity 120.0 and
	# link_valid true -- the driver takes items.
	var accept: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"items_total": 50.0}, 120.0, true)
	proof["accept_item_below_capacity_with_link"] = bool(accept.get("accept_item", false)) == true

	# Full or unlinked rejects: items_total=120.0 at capacity
	# with a valid link rejects, and items_total=0.0 with no
	# valid link rejects -- both conjuncts must hold
	# (MassDriver.java:287, `return items.total() <
	# itemCapacity && linkValid();`).
	var full: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"items_total": 120.0}, 120.0, true)
	var no_link: Dictionary = mass_driver_build_state.source_mass_driver_accept_item_state({"items_total": 0.0}, 120.0, false)
	proof["accept_item_full_or_no_link_rejects"] = bool(full.get("accept_item", true)) == false and bool(no_link.get("accept_item", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07MassDriverSenseProgressAcceptItemProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
