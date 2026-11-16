extends Node

const main_scene := preload("res://scenes/Main.tscn")
const build_turret_build_state := preload("res://src/game/SourceBuildTurretBuildState.gd")
const building_sense_state := preload("res://src/game/SourceBuildingSenseState.gd")
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

	# --- Sense rows (N2437): BuildTurretBuild.sense()
	# (BuildTurret.java:281-287) + senseObject()
	# (BuildTurret.java:289-295). `public double
	# sense(LAccess sensor){` + `case buildX, buildY
	# -> unit.sense(sensor);` + `default ->
	# super.sense(sensor);`, and `public Object
	# senseObject(LAccess sensor){` + `case building,
	# breaking -> unit.senseObject(sensor);` +
	# `default -> super.senseObject(sensor);`. The unit
	# is the live BlockUnitc (`public BlockUnitc unit
	# = (BlockUnitc)unitType.create(team);`,
	# BuildTurret.java:93) -- the pures NEVER query it
	# directly, they take its sensed values
	# caller-supplied. unit.sense(buildX/buildY) is the
	# plan tile coordinate, or -1 when the unit is not
	# building (`case buildX -> isBuilding() ?
	# buildPlan().x : -1;` / `case buildY ->
	# isBuilding() ? buildPlan().y : -1;`,
	# UnitComp.java:290-291). unit.senseObject
	# (building/breaking) is the plan tile's build, or
	# null when the unit is not building that way
	# (`case building -> isBuilding() &&
	# !buildPlan().breaking ? buildPlan().tile().build
	# : null;` / `case breaking -> isBuilding() &&
	# buildPlan().breaking ? buildPlan().tile().build
	# : null;`, UnitComp.java:323-324). super.sense is
	# the BuildingComp switch (BuildingComp.java:
	# 2093-2125, `return switch(sensor){`), already
	# modeled by the port (SourceBuildingSenseState),
	# so the sense pure takes the caller's
	# super.sense result as super_value; null is the
	# default branch (`default -> Float.NaN; //gets
	# converted to null in logic`). super.senseObject
	# is the BuildingComp switch (BuildingComp.java:
	# 2128-2136), already modeled by the port
	# (SourceBuildingSenseState.sense_object_state),
	# so the senseObject pure takes the caller's
	# super.senseObject result as super_value; null is
	# the noSensed default (`default -> noSensed;`,
	# `Object noSensed = new Object();`,
	# Senseable.java:6). Pure-only: the tick never
	# calls sense or senseObject -- sense is called by
	# logic, and the logic call site waits for a
	# logic-executor slice.

	# --- buildX delegate: the unit is building plan
	# (12, 7), so buildX reads the caller-supplied
	# unit plan x 12.0 with the dispatch flag true.
	# When the unit is not building, Java returns -1
	# (UnitComp.java:290) -- the caller supplies the
	# -1, the pure only delegates, and the flag stays
	# true.
	var build_x: Dictionary = build_turret_build_state.source_build_turret_sense_state("buildX", 12.0, 7.0)
	var build_x_idle: Dictionary = build_turret_build_state.source_build_turret_sense_state("buildX", -1.0, -1.0)
	proof["sense_build_x_delegate"] = bool(build_x.get("delegated", false)) and is_equal_approx(float(build_x.get("value", -99.0)), 12.0) and bool(build_x_idle.get("delegated", false)) and is_equal_approx(float(build_x_idle.get("value", -99.0)), -1.0)

	# --- buildY delegate: the unit is building plan
	# (12, 7), so buildY reads the caller-supplied
	# unit plan y 7.0 with the dispatch flag true.
	# The not-building -1 (UnitComp.java:291) rides
	# the same delegation.
	var build_y: Dictionary = build_turret_build_state.source_build_turret_sense_state("buildY", 12.0, 7.0)
	var build_y_idle: Dictionary = build_turret_build_state.source_build_turret_sense_state("buildY", -1.0, -1.0)
	proof["sense_build_y_delegate"] = bool(build_y.get("delegated", false)) and is_equal_approx(float(build_y.get("value", -99.0)), 7.0) and bool(build_y_idle.get("delegated", false)) and is_equal_approx(float(build_y_idle.get("value", -99.0)), -1.0)

	# --- Default super: a non-build sensor returns
	# the caller-supplied super.sense result, not a
	# unit value. health 80.0 (via the modeled
	# BuildingComp health case, `case health ->
	# health;`) and efficiency 0.75 (via `case
	# efficiency -> efficiency;`) both pass through
	# untouched, with the dispatch flag false -- even
	# though the unit values would read 12.0 / 7.0.
	# An unknown sensor with no super value returns
	# null -- the super switch's default branch
	# (`default -> Float.NaN; //gets converted to
	# null in logic`). The default super_value is
	# null, so the caller passes nothing.
	var health_super: Dictionary = building_sense_state.sense_health_process_state(80.0, 100.0, 0.75, 1.0, 0.0, 8.0, false, 0.0)
	var health_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_state("health", 12.0, 7.0, health_super.get("health"))
	var efficiency_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_state("efficiency", 12.0, 7.0, health_super.get("efficiency"))
	var unknown_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_state("not_a_sensor", 12.0, 7.0)
	proof["sense_default_super"] = not bool(health_sensed.get("delegated", true)) and is_equal_approx(float(health_sensed.get("value", -1.0)), 80.0) and not bool(efficiency_sensed.get("delegated", true)) and is_equal_approx(float(efficiency_sensed.get("value", -1.0)), 0.75) and not bool(unknown_sensed.get("delegated", true)) and unknown_sensed.get("value", 0.0) == null

	# --- building delegate: the unit is building a
	# copper-wall plan, so building reads the
	# caller-supplied unit descriptor untouched with
	# the dispatch flag true. When the unit is not
	# building (or is breaking instead), Java returns
	# null (UnitComp.java:323) -- the caller supplies
	# the null, the pure only delegates, and the flag
	# stays true.
	var building_descriptor: Dictionary = {"kind": "building", "block": "copper-wall"}
	var building_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("building", building_descriptor, null)
	var building_idle: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("building", null, null)
	proof["sense_object_building_delegate"] = bool(building_sensed.get("delegated", false)) and building_sensed.get("value", {}) == building_descriptor and bool(building_idle.get("delegated", false)) and building_idle.get("value", {}) == null

	# --- breaking delegate: the unit is breaking a
	# titanium-wall plan, so breaking reads the
	# caller-supplied unit descriptor untouched with
	# the dispatch flag true. When the unit is not
	# breaking, Java returns null (UnitComp.java:324)
	# -- the caller supplies the null, the pure only
	# delegates, and the flag stays true.
	var breaking_descriptor: Dictionary = {"kind": "building", "block": "titanium-wall"}
	var breaking_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("breaking", null, breaking_descriptor)
	var breaking_idle: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("breaking", null, null)
	proof["sense_object_breaking_delegate"] = bool(breaking_sensed.get("delegated", false)) and breaking_sensed.get("value", {}) == breaking_descriptor and bool(breaking_idle.get("delegated", false)) and breaking_idle.get("value", {}) == null

	# --- Default super (object): a non-building /
	# non-breaking sensor returns the caller-supplied
	# super.senseObject result, not a unit value. type
	# reads the build-tower block descriptor (via the
	# modeled BuildingComp type case, `case type ->
	# block;`) with the dispatch flag false -- even
	# though the unit values would read the plan
	# descriptors. An unknown sensor falls through to
	# the super default: the canonical
	# sense_object_state returns value null +
	# no_sensed true for it (`default -> noSensed;`),
	# and the pure passes that null through with the
	# dispatch flag false.
	var tower_descriptor: Dictionary = {"kind": "building", "block": "build-tower"}
	var type_super: Dictionary = building_sense_state.sense_object_state("type", tower_descriptor, false, null, false, null, "", null)
	var type_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("type", building_descriptor, breaking_descriptor, type_super.get("value"))
	var no_sensed_super: Dictionary = building_sense_state.sense_object_state("not_a_sensor", tower_descriptor, false, null, false, null, "", null)
	var unknown_object_sensed: Dictionary = build_turret_build_state.source_build_turret_sense_object_state("not_a_sensor", building_descriptor, breaking_descriptor, no_sensed_super.get("value"))
	proof["sense_object_default_super"] = not bool(type_sensed.get("delegated", true)) and type_sensed.get("value", {}) == tower_descriptor and bool(no_sensed_super.get("no_sensed", false)) and not bool(unknown_object_sensed.get("delegated", true)) and unknown_object_sensed.get("value", {}) == null

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07BuildTurretSenseRowsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
