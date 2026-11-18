extends Node

const main_scene := preload("res://scenes/Main.tscn")
const source_runtime_owner_turret_registry := preload("res://src/game/SourceRuntimeOwnerTurretRegistry.gd")
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

	# --- Persistence integration (N2249):
	# N2245 built the write/read pure functions on
	# SourcePointDefenseTurretBuildState, but nothing in the
	# port could call them from the PortGame surface. N2249
	# wires them onto that surface with two thin bridge
	# functions on SourceTurretRuntimePortBridge (the
	# TractorBeam precedent, :221/:227, and the ItemTurret
	# precedent, SourceItemTurretBuildPortBridge.gd:68) plus
	# two registry consts. The bridge write wraps the rotation
	# float into the frame the pure function reads
	# (`{"rotation": rotation_value}`); the bridge read passes
	# the saved float straight through -- NO revision
	# parameter, because the Java body never reads `revision`
	# (`public void write(Writes write){` / `super.write(write);`
	# / `write.f(rotation);`, PointDefenseTurret.java:117-121;
	# `public void read(Reads read, byte revision){` /
	# `super.read(read, revision);` / `rotation = read.f();`,
	# PointDefenseTurret.java:124-127). PortGame inherits the
	# bridge via the SourceSsotAccessorPortBridge link in its
	# extends chain, so the proof calls the bridge through the
	# game node (the ItemTurret proof precedent). There is NO
	# save/load stream yet: the proof drives the bridge with
	# synthetic floats, no save file.

	# Bridge write returns the rotation: 145.5 in -> 145.5 out.
	var written: Dictionary = game.source_point_defense_turret_build_write_state(145.5)
	proof["bridge_write_returns_rotation"] = is_equal_approx(float(written.get("rotation", -1.0)), 145.5)

	# Bridge write returns ONLY rotation.
	proof["bridge_write_returns_only_rotation"] = written.size() == 1

	# Bridge read restores the saved rotation unconditionally:
	# saved 200.0 -> 200.0 (no revision guard, unlike N2217).
	var read_saved: Dictionary = game.source_point_defense_turret_build_read_state(200.0)
	proof["bridge_read_restores_rotation"] = is_equal_approx(float(read_saved.get("rotation", -1.0)), 200.0)

	# Bridge read returns ONLY rotation.
	proof["bridge_read_returns_only_rotation"] = read_saved.size() == 1

	# Bridge write-then-read round-trips the value: write
	# 145.5, read the written value back -> 145.5.
	var round_trip: Dictionary = game.source_point_defense_turret_build_read_state(float(written.get("rotation", -1.0)))
	proof["bridge_write_read_round_trip"] = is_equal_approx(float(round_trip.get("rotation", -1.0)), 145.5)

	# The registry consts name the bridge functions.
	proof["registry_consts_match_bridge_names"] = source_runtime_owner_turret_registry.PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_WRITE_STATE == "port_game.source_point_defense_turret_build_write_state" and source_runtime_owner_turret_registry.PORT_GAME_SOURCE_POINT_DEFENSE_TURRET_BUILD_READ_STATE == "port_game.source_point_defense_turret_build_read_state"

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07PointDefenseTurretPersistenceIntegrationProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
