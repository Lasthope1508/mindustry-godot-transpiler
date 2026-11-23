extends Node

const main_scene := preload("res://scenes/Main.tscn")
const beam_drill_build_state := preload("res://src/game/SourceBeamDrillBuildState.gd")
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

	# --- BeamDrill outputsItems() (N2417):
	# BeamDrill.outputsItems() (BeamDrill.java:98-100,
	# `public boolean outputsItems(){` with `return true;`)
	# is unconditional: a beam drill always outputs items,
	# overriding the base Block.outputsItems()
	# (Block.java:601-603, `return hasItems;`). The proof
	# calls the pure function directly with synthetic
	# frames (the N2318 canPickup accessor precedent).
	# There is NO driver tick line: outputsItems() is a
	# load-time block predicate, not a per-tick write.

	# An empty frame reads true.
	var outputs_empty: Dictionary = beam_drill_build_state.source_beam_drill_outputs_items_state({})
	proof["outputs_items_true"] = bool(outputs_empty.get("outputs_items", false)) == true

	# A frame that claims hasItems false still reads true:
	# the override ignores the frame.
	var outputs_no_items: Dictionary = beam_drill_build_state.source_beam_drill_outputs_items_state({"has_items": false})
	proof["outputs_items_ignores_frame"] = bool(outputs_no_items.get("outputs_items", false)) == true

	# --- BeamDrill rotatedOutput(int, int) (N2417):
	# BeamDrill.rotatedOutput(int, int)
	# (BeamDrill.java:103-105, `public boolean
	# rotatedOutput(int x, int y){` with `return false;`)
	# is unconditional: a beam drill never has a rotated
	# output, overriding the base Block.rotatedOutput(int,
	# int) (Block.java:615-617, `return rotate;`). x/y
	# arrive as explicit params and are unused by the
	# override. There is NO driver tick line: it is a
	# load-time placement predicate, not a per-tick write.

	# Any tile reads false.
	var rotated_origin: Dictionary = beam_drill_build_state.source_beam_drill_rotated_output_state({}, 0, 0)
	proof["rotated_output_false"] = bool(rotated_origin.get("rotated_output", true)) == false

	# Other coords still read false: the override ignores x/y.
	var rotated_far: Dictionary = beam_drill_build_state.source_beam_drill_rotated_output_state({}, 7, -3)
	proof["rotated_output_ignores_coords"] = bool(rotated_far.get("rotated_output", true)) == false

	# --- BeamDrill icons() (N2417):
	# BeamDrill.icons() (BeamDrill.java:108-110,
	# `public TextureRegion[] icons(){` with `return new
	# TextureRegion[]{region, topRegion};`) pins ONLY the
	# override's two-element return array, region first
	# (the N2312 BurstDrill.icons() twin precedent: the
	# same return line, a different class). region /
	# topRegion arrive as explicit Variant params; region
	# ids ride as strings, as the N2312 proof did with
	# ["impact-drill", "impact-drill-top"]. Both defs
	# share the function (plasma-bore, Blocks.java:3038;
	# large-plasma-bore, Blocks.java:3052); they differ
	# only in the region name the caller passes. There is
	# NO driver tick line: icons() is a load-time region
	# accessor, not a per-tick write.

	# plasma-bore ("plasma-bore", "plasma-bore-top"):
	# ["plasma-bore", "plasma-bore-top"].
	var icons_plasma: Dictionary = beam_drill_build_state.source_beam_drill_icons_state("plasma-bore", "plasma-bore-top")
	var icons_plasma_array: Array = icons_plasma.get("icons", [])
	proof["icons_plasma_bore"] = icons_plasma_array == ["plasma-bore", "plasma-bore-top"]

	# large-plasma-bore ("large-plasma-bore",
	# "large-plasma-bore-top"): ["large-plasma-bore",
	# "large-plasma-bore-top"].
	var icons_large: Dictionary = beam_drill_build_state.source_beam_drill_icons_state("large-plasma-bore", "large-plasma-bore-top")
	var icons_large_array: Array = icons_large.get("icons", [])
	proof["icons_large_plasma_bore"] = icons_large_array == ["large-plasma-bore", "large-plasma-bore-top"]

	# The override returns exactly two regions.
	proof["icons_length_two"] = icons_plasma_array.size() == 2 and icons_large_array.size() == 2

	# --- BeamDrillBuild shouldConsume() (N2417):
	# BeamDrillBuild.shouldConsume()
	# (BeamDrill.java:269-272, `public boolean
	# shouldConsume(){` with `return items.total() <
	# itemCapacity && facingAmount > 0 && enabled;`) is
	# the three-way gate: item-store room, at least one
	# facing tile drilled, and enabled. items.total() /
	# facingAmount / enabled / itemCapacity arrive as
	# explicit params -- no live engine call (the N2398
	# updateTile precedent). There is NO driver tick line
	# here: this slice ports only the pure predicate --
	# the tick driver still runs should_consume=true when
	# enabled and waits for a wiring slice to call it.

	# Room + facing + enabled reads true.
	var consume_open: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state(0, 10, 2, true)
	proof["should_consume_true_when_room_and_facing_and_enabled"] = bool(consume_open.get("should_consume", false)) == true

	# A full item store reads false.
	var consume_full: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state(10, 10, 2, true)
	proof["should_consume_false_when_items_full"] = bool(consume_full.get("should_consume", true)) == false

	# No facing tile reads false.
	var consume_no_facing: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state(0, 10, 0, true)
	proof["should_consume_false_when_no_facing"] = bool(consume_no_facing.get("should_consume", true)) == false

	# Disabled reads false.
	var consume_disabled: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state(0, 10, 2, false)
	proof["should_consume_false_when_disabled"] = bool(consume_disabled.get("should_consume", true)) == false

	# At exactly capacity (items_total == item_capacity)
	# reads false: the gate is a strict less-than.
	var consume_at_capacity: Dictionary = beam_drill_build_state.source_beam_drill_should_consume_state(20, 20, 3, true)
	proof["should_consume_false_at_capacity_boundary"] = bool(consume_at_capacity.get("should_consume", true)) == false

	# The result-key shapes: each pure function returns
	# only its own key.
	var outputs_keys: Array = outputs_empty.keys()
	var rotated_keys: Array = rotated_origin.keys()
	var icons_keys: Array = icons_plasma.keys()
	var consume_keys: Array = consume_open.keys()
	proof["returns_only_expected_keys"] = outputs_keys == ["outputs_items"] and rotated_keys == ["rotated_output"] and icons_keys == ["icons"] and consume_keys == ["should_consume"]

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BeamDrillOutputsItemsRotatedOutputIconsShouldConsumeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
