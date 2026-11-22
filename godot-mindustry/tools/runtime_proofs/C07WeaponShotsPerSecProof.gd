extends Node

const main_scene := preload("res://scenes/Main.tscn")
const weapons_state := preload("res://src/game/SourceWeaponsState.gd")
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

	# --- Weapon shotsPerSec() (N2535): `public float shotsPerSec(){` /
	# `return shoot.shots * 60f / reload;`
	# (Weapon.java:192-194). `reload` is the weapon reload in frames
	# (`public float reload = 1;`, Weapon.java:75);
	# `shoot_shots` is the ShootPattern shot count
	# (`public int shots = 1;`, ShootPattern.java:9). shotsPerSec()
	# has NO cache and NO `reload == 0` guard: it
	# recomputes on every call and returns the single key
	# `shots_per_sec`. The proof drives the pure function through
	# the Weapon facade on exact legs:
	# 1 Java defaults (reload 1.0, shots 1 -> 60.0);
	# 2 reload 2.0 (2 / 1 -> 30.0); 3 fractional
	# reload 0.5 (0.5 / 1 -> 120.0); 4 shots 3 (1 / 3 ->
	# 180.0); 5 shots 0 -> 0.0; 6 reload 60.0 (60 / 1 ->
	# 1.0); 7 fractional reload 1.5, shots 2 (1.5 / 2 ->
	# 80.0); 8 large (0.5 / 2 -> 240.0).

	# Phase 1: Java defaults (reload 1.0, shots 1) -> 60.0.
	var sps: Dictionary = weapons_state.source_weapon_shots_per_sec_state(1.0, 1)
	proof["sps_java_defaults"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 60.0)

	# Phase 2: reload 2.0 (2 / 1) -> 30.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(2.0, 1)
	proof["sps_reload_2"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 30.0)

	# Phase 3: fractional reload 0.5 (0.5 / 1) -> 120.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(0.5, 1)
	proof["sps_reload_fractional"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 120.0)

	# Phase 4: shots 3 (1 / 3) -> 180.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(1.0, 3)
	proof["sps_shots_3"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 180.0)

	# Phase 5: shots 0 -> 0.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(1.0, 0)
	proof["sps_shots_zero"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 0.0)

	# Phase 6: reload 60.0 (60 / 1) -> 1.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(60.0, 1)
	proof["sps_reload_60"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 1.0)

	# Phase 7: fractional reload 1.5, shots 2 (1.5 / 2) -> 80.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(1.5, 2)
	proof["sps_fractional"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 80.0)

	# Phase 8: large (0.5 / 2) -> 240.0.
	sps = weapons_state.source_weapon_shots_per_sec_state(0.5, 2)
	proof["sps_large"] = is_equal_approx(float(sps.get("shots_per_sec", -1.0)), 240.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponShotsPerSecProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
