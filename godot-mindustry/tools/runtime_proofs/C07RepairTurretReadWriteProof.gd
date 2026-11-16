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

	# --- Read/write persistence (N2217):
	# RepairPointBuild persists exactly ONE field, its rotation
	# (`public void write(Writes write){` / `super.write(write);`
	# / `write.f(rotation);`, RepairTurret.java:236-239), and
	# restores it only for saves at revision >= 1 (`public void
	# read(Reads read, byte revision){` / `super.read(read,
	# revision);` / `if(revision >= 1){` / `rotation = read.f();`,
	# RepairTurret.java:243-248), because `public byte version(){`
	# returns 1 (RepairTurret.java:252-254). The rotation default
	# is 90.0 (`public float strength, rotation = 90;`,
	# RepairTurret.java:156). Strength is NOT persisted -- it is
	# re-lerped every tick (`strength = Mathf.lerpDelta(strength,
	# healed ? 1f : 0f, 0.08f * Time.delta);`,
	# RepairTurret.java:212) -- and target is NOT persisted
	# either -- it is re-acquired by the 20-tick timer (`target =
	# Units.closest(team, x, y, repairRadius, Unit::damaged);`,
	# RepairTurret.java:216). The proof calls the pure functions
	# with synthetic frames (no live tick, no save file: the
	# persisted value is one float).

	# Write returns the frame's current rotation: 145.5 in ->
	# 145.5 out.
	var written: Dictionary = repair_turret_build_state.source_repair_turret_write_state({"rotation": 145.5})
	proof["write_returns_current_rotation"] = is_equal_approx(float(written.get("rotation", -1.0)), 145.5)

	# Write defaults to 90.0 when the frame carries no rotation
	# (the field default, RepairTurret.java:156).
	var written_default: Dictionary = repair_turret_build_state.source_repair_turret_write_state({})
	proof["write_defaults_to_90_when_absent"] = is_equal_approx(float(written_default.get("rotation", -1.0)), 90.0)

	# Write returns ONLY rotation: strength and target are not
	# persisted, so the result has exactly one key.
	proof["write_returns_only_rotation"] = written.size() == 1

	# Read restores the saved rotation at revision 1: saved
	# 200.0, current 145.5 -> 200.0.
	var read_rev1: Dictionary = repair_turret_build_state.source_repair_turret_read_state({"rotation": 145.5}, 200.0, 1)
	proof["read_restores_saved_rotation_at_revision_1"] = is_equal_approx(float(read_rev1.get("rotation", -1.0)), 200.0)

	# Read restores the saved rotation at revision 2 as well
	# (the guard is >= 1, not == 1): saved 33.0 -> 33.0.
	var read_rev2: Dictionary = repair_turret_build_state.source_repair_turret_read_state({"rotation": 145.5}, 33.0, 2)
	proof["read_restores_saved_rotation_at_revision_2"] = is_equal_approx(float(read_rev2.get("rotation", -1.0)), 33.0)

	# Read keeps the current rotation at revision 0: a revision-0
	# save carries no rotation float, so the turret keeps
	# pointing where it already points (145.5, not 200.0).
	var read_rev0: Dictionary = repair_turret_build_state.source_repair_turret_read_state({"rotation": 145.5}, 200.0, 0)
	proof["read_keeps_current_rotation_at_revision_0"] = is_equal_approx(float(read_rev0.get("rotation", -1.0)), 145.5)

	# Read defaults to 90.0 when the frame has no rotation and
	# revision is 0 (no saved value, no current value).
	var read_rev0_default: Dictionary = repair_turret_build_state.source_repair_turret_read_state({}, 200.0, 0)
	proof["read_defaults_to_90_when_absent_and_revision_0"] = is_equal_approx(float(read_rev0_default.get("rotation", -1.0)), 90.0)

	# The save version is 1 (`public byte version(){` /
	# `return 1;`, RepairTurret.java:252-254).
	proof["version_is_1"] = repair_turret_build_state.REPAIR_TURRET_SAVE_VERSION == 1

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07RepairTurretReadWriteProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
