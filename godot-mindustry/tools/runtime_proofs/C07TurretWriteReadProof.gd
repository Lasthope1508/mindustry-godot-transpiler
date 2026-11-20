extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_build_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- Write/read/version persistence (N2322): TurretBuild persists
	# exactly TWO fields, its reload counter and its aim rotation
	# (`public void write(Writes write){` / `super.write(write);` /
	# `write.f(reloadCounter);` / `write.f(rotation);`, Turret.java:831-834),
	# restores them only for saves at revision >= 1 (`public void read(Reads read,
	# byte revision){` / `super.read(read, revision);` / `if(revision >= 1){` /
	# `reloadCounter = read.f();` / `rotation = read.f();`, Turret.java:838-844),
	# and reports save version 1 (`public byte version(){` / `return 1;`,
	# Turret.java:848-850). The rotation is the RotComp float aim angle
	# (`@SyncField(false) @SyncLocal float rotation;`, RotComp.java:8), NOT the
	# Building int rotation 0-3 (`transient int rotation;`, BuildingComp.java:69).
	# super.write/read are empty BuildingComp bodies -- only the marker is recorded.
	# readSync() is its own slice. Java write.f is a 32-bit float while GDScript
	# float is 64-bit -- the pure functions add NO rounding epsilon; the proof
	# round-trips float32-safe values exactly and checks the inexact value 0.1
	# with is_equal_approx. The proof calls the pure functions with synthetic
	# frames (no live tick, no save file: the persisted values are two floats).

	# Write with an empty frame (the Java field defaults, ReloadTurret.java:26 /
	# RotComp.java:8): 0.0 / 0.0 in -> 0.0 / 0.0 out.
	var written_defaults: Dictionary = turret_build_state.source_turret_write_state({})
	proof["write_defaults_zero"] = is_equal_approx(float(written_defaults.get("reload_counter", -1.0)), 0.0) and is_equal_approx(float(written_defaults.get("rotation", -1.0)), 0.0)

	# Write 12.5 / 135.0 round-trips through read: write the values, read the
	# stored values back at revision 1 -> 12.5 / 135.0.
	var written: Dictionary = turret_build_state.source_turret_write_state({"reload_counter": 12.5, "rotation": 135.0})
	var read_back: Dictionary = turret_build_state.source_turret_read_state({}, float(written.get("reload_counter", -1.0)), float(written.get("rotation", -1.0)), 1)
	proof["write_round_trips"] = is_equal_approx(float(read_back.get("reload_counter", -1.0)), 12.5) and is_equal_approx(float(read_back.get("rotation", -1.0)), 135.0)

	# Write returns ONLY the two persisted values: nothing else survives save/load.
	proof["write_returns_only_two_keys"] = written.size() == 2

	# Read returns ONLY the two persisted values as well.
	proof["read_returns_only_two_keys"] = read_back.size() == 2

	# Read at revision 0 keeps the frame's current values and ignores the stored
	# ones: frame 3.0 / 45.0 with stored 12.5 / 135.0 at revision 0 -> 3.0 / 45.0.
	var read_old: Dictionary = turret_build_state.source_turret_read_state({"reload_counter": 3.0, "rotation": 45.0}, 12.5, 135.0, 0)
	proof["read_ignores_old_revision"] = is_equal_approx(float(read_old.get("reload_counter", -1.0)), 3.0) and is_equal_approx(float(read_old.get("rotation", -1.0)), 45.0)

	# Read at revision 1 applies the stored values: frame 3.0 / 45.0 with stored
	# 12.5 / 135.0 at revision 1 -> 12.5 / 135.0.
	var read_new: Dictionary = turret_build_state.source_turret_read_state({"reload_counter": 3.0, "rotation": 45.0}, 12.5, 135.0, 1)
	proof["read_applies_at_revision_one"] = is_equal_approx(float(read_new.get("reload_counter", -1.0)), 12.5) and is_equal_approx(float(read_new.get("rotation", -1.0)), 135.0)

	# version() returns 1, the save version; the BuildingComp base returns 0.
	var versioned: Dictionary = turret_build_state.source_turret_version_state({})
	proof["version_returns_one"] = int(versioned.get("version", -1)) == 1

	# The inexact float32 value 0.1 round-trips: Java write.f stores a 32-bit
	# float, GDScript holds a 64-bit float, and the pure functions add no
	# rounding epsilon -- the value survives the round-trip within float32
	# tolerance.
	var written_inexact: Dictionary = turret_build_state.source_turret_write_state({"reload_counter": 0.1, "rotation": 0.1})
	var read_inexact: Dictionary = turret_build_state.source_turret_read_state({}, float(written_inexact.get("reload_counter", -1.0)), float(written_inexact.get("rotation", -1.0)), 1)
	proof["round_trip_inexact_float32_value"] = is_equal_approx(float(read_inexact.get("reload_counter", -1.0)), 0.1) and is_equal_approx(float(read_inexact.get("rotation", -1.0)), 0.1)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretWriteReadProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
