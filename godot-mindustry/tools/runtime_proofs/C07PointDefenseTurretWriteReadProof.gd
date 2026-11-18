extends Node

const main_scene := preload("res://scenes/Main.tscn")
const point_defense_turret_build_state := preload("res://src/game/SourcePointDefenseTurretBuildState.gd")
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

	# --- Write/read persistence (N2245):
	# PointDefenseBuild persists exactly ONE field, its rotation
	# (`public void write(Writes write){` / `super.write(write);`
	# / `write.f(rotation);`, PointDefenseTurret.java:117-121),
	# and restores it UNCONDITIONALLY (`public void read(Reads
	# read, byte revision){` / `super.read(read, revision);` /
	# `rotation = read.f();`, PointDefenseTurret.java:124-127)
	# -- there is NO `if(revision >= 1){` guard here, unlike
	# RepairTurret.read() (RepairTurret.java:246-248, the N2217
	# precedent). PointDefenseTurret does NOT override
	# version(), so the save version is the BuildingComp
	# default 0 (`public byte version(){` / `return 0;`,
	# BuildingComp.java:669-671). The rotation default is 90.0
	# (`public float rotation = 90;`, BaseTurret.java:114).
	# Target is NOT persisted -- it is re-acquired by the
	# retarget timer (PointDefenseTurret.java:65-67) -- and
	# reloadCounter is NOT persisted either -- it is recharged
	# every tick (`reloadCounter += edelta();`,
	# PointDefenseTurret.java:79; `public float reloadCounter;`,
	# ReloadTurret.java:26). The proof calls the pure functions
	# with synthetic frames (no live tick, no save file: the
	# persisted value is one float).

	# Write returns the frame's current rotation: 145.5 in ->
	# 145.5 out.
	var written: Dictionary = point_defense_turret_build_state.source_point_defense_turret_write_state({"rotation": 145.5})
	proof["write_returns_current_rotation"] = is_equal_approx(float(written.get("rotation", -1.0)), 145.5)

	# Write defaults to 90.0 when the frame carries no rotation
	# (the field default, BaseTurret.java:114).
	var written_default: Dictionary = point_defense_turret_build_state.source_point_defense_turret_write_state({})
	proof["write_defaults_to_90_when_absent"] = is_equal_approx(float(written_default.get("rotation", -1.0)), 90.0)

	# Write returns ONLY rotation: target and reloadCounter are
	# not persisted, so the result has exactly one key.
	proof["write_returns_only_rotation"] = written.size() == 1

	# Read restores the saved rotation unconditionally: saved
	# 200.0 -> 200.0 (no revision guard, unlike N2217).
	var read_saved: Dictionary = point_defense_turret_build_state.source_point_defense_turret_read_state(200.0)
	proof["read_restores_saved_rotation"] = is_equal_approx(float(read_saved.get("rotation", -1.0)), 200.0)

	# Read restores a second saved value the same way: saved
	# 33.0 -> 33.0 (the restore is not revision-gated).
	var read_second: Dictionary = point_defense_turret_build_state.source_point_defense_turret_read_state(33.0)
	proof["read_restores_saved_rotation_second_value"] = is_equal_approx(float(read_second.get("rotation", -1.0)), 33.0)

	# Read returns ONLY rotation.
	proof["read_returns_only_rotation"] = read_saved.size() == 1

	# Write-then-read round-trips the value: write 145.5, read
	# the written value back -> 145.5.
	var round_trip: Dictionary = point_defense_turret_build_state.source_point_defense_turret_read_state(float(written.get("rotation", -1.0)))
	proof["write_read_round_trip"] = is_equal_approx(float(round_trip.get("rotation", -1.0)), 145.5)

	# The save version is 0: PointDefenseTurret does NOT
	# override version(), so the BuildingComp default applies
	# (`public byte version(){` / `return 0;`,
	# BuildingComp.java:669-671).
	proof["version_is_0"] = point_defense_turret_build_state.POINT_DEFENSE_TURRET_SAVE_VERSION == 0

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
