extends Node

const main_scene := preload("res://scenes/Main.tscn")
const burst_drill_build_state := preload("res://src/game/SourceBurstDrillBuildState.gd")
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

	# --- Pure senseObject / sense legs (N2298): DrillBuild.senseObject
	# (Drill.java:281-284, `public Object senseObject(LAccess
	# sensor){` / `if(sensor == LAccess.firstItem) return
	# dominantItem;` / `return super.senseObject(sensor);`) returns
	# the dominant item for firstItem and falls through to the
	# caller-passed super result otherwise; DrillBuild.sense
	# (Drill.java:333-336, `public double sense(LAccess sensor){`
	# / `if(sensor == LAccess.progress && dominantItem != null)
	# return progress;` / `return super.sense(sensor);`) returns
	# the raw progress field for the progress sensor with a dominant
	# item and falls through to the caller-passed super result
	# otherwise. The super legs are BuildingComp.senseObject
	# (BuildingComp.java:2128-2137, firstItem leg `case firstItem
	# -> items == null ? null : items.first();`, default `default
	# -> noSensed;`) and BuildingComp.sense (BuildingComp.java:2093,
	# default `default -> Float.NaN; //gets converted to null in
	# logic`, BuildingComp.java:2123) -- both already live (N636 /
	# N1078-N1085) and passed in as explicit params (the
	# N2271/N2277 super-as-param precedent). The sensor spellings
	# are the LAccess enum names `firstItem,` (LAccess.java:8) and
	# `progress,` (:28). `progress` is the DrillBuild field (`public
	# float progress;`, Drill.java:238), advanced in updateTile
	# (N2294) -- NOT the clamped progress() (Drill.java:327-329).
	# The proof calls the pure functions
	# source_drill_sense_object_state(frame, sensor,
	# has_dominant_item, dominant_item, super_sense_object_value)
	# and source_drill_sense_state(frame, sensor,
	# has_dominant_item, progress, super_sense_value,
	# super_sense_value_is_nan) directly with synthetic inputs.
	# There is no dispatch-hook key: the logic-processor dispatch
	# hook waits for its own slice.

	# firstItem returns the dominant item: with a bound dominant
	# item ("beryllium", Drill.java:244, `public Item
	# dominantItem;`) the firstItem sensor reads it back, handled.
	var first_item: Dictionary = burst_drill_build_state.source_drill_sense_object_state({}, "firstItem", true, "beryllium", null)
	proof["sense_object_first_item_returns_dominant_item"] = bool(first_item.get("handled", false)) == true and String(first_item.get("sense_object_value", "")) == "beryllium"

	# firstItem with no dominant item reads null: Java returns
	# dominantItem itself (Drill.java:282), so an unbound drill
	# reads null -- still handled, the value is null, not the
	# super's items.first() (BuildingComp.java:2131).
	var first_item_null: Dictionary = burst_drill_build_state.source_drill_sense_object_state({}, "firstItem", false, null, "sand")
	proof["sense_object_first_item_null_without_dominant_item"] = bool(first_item_null.get("handled", false)) == true and first_item_null.get("sense_object_value", "not-null") == null

	# Other sensors fall through to the super result: "type" with
	# super value "impact-drill" (the block id, BuildingComp
	# senseObject case type) comes back unhandled with the super
	# value; "config" with a null super result comes back unhandled
	# with null.
	var type_fallthrough: Dictionary = burst_drill_build_state.source_drill_sense_object_state({}, "type", true, "beryllium", "impact-drill")
	var config_fallthrough: Dictionary = burst_drill_build_state.source_drill_sense_object_state({}, "config", true, "beryllium", null)
	proof["sense_object_other_sensor_falls_through_to_super"] = bool(type_fallthrough.get("handled", true)) == false and String(type_fallthrough.get("sense_object_value", "")) == "impact-drill" and bool(config_fallthrough.get("handled", true)) == false and config_fallthrough.get("sense_object_value", "not-null") == null

	# Progress returns the RAW progress field with a dominant item:
	# progress 123.5 stays 123.5 -- the clamped progress()
	# (Drill.java:327-329, `return dominantItem == null ? 0f :
	# Mathf.clamp(progress / getDrillTime(dominantItem));`) would
	# read 1.0, so the raw value pins that sense() returns the
	# field (Drill.java:334, `return progress;`), not progress().
	var progress_raw: Dictionary = burst_drill_build_state.source_drill_sense_state({}, "progress", true, 123.5, null, true)
	proof["sense_progress_returns_raw_progress_with_dominant_item"] = bool(progress_raw.get("handled", false)) == true and is_equal_approx(float(progress_raw.get("sense_value", -1.0)), 123.5) and bool(progress_raw.get("sense_value_is_nan", true)) == false

	# Progress without a dominant item falls through: the guard
	# (Drill.java:334, `dominantItem != null`) fails, so the leg
	# returns the super result -- the BuildingComp default NaN
	# (BuildingComp.java:2123), passed here as null with
	# is_nan true.
	var progress_unbound: Dictionary = burst_drill_build_state.source_drill_sense_state({}, "progress", false, 123.5, null, true)
	proof["sense_progress_falls_through_without_dominant_item"] = bool(progress_unbound.get("handled", true)) == false and progress_unbound.get("sense_value", "not-null") == null and bool(progress_unbound.get("sense_value_is_nan", false)) == true

	# Other sensors fall through to the super result: "health"
	# with super value 80.0 (BuildingComp.sense case health,
	# BuildingComp.java:2100) comes back unhandled with 80.0
	# and is_nan false.
	var health_fallthrough: Dictionary = burst_drill_build_state.source_drill_sense_state({}, "health", true, 123.5, 80.0, false)
	proof["sense_other_sensor_falls_through_to_super"] = bool(health_fallthrough.get("handled", true)) == false and is_equal_approx(float(health_fallthrough.get("sense_value", -1.0)), 80.0) and bool(health_fallthrough.get("sense_value_is_nan", true)) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07DrillSenseProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
