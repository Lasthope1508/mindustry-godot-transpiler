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

	# --- Weapon dps() (N2534): `public float dps(){` /
	# `return (bullet.estimateDPS() / reload) * shoot.shots * 60f;`
	# (Weapon.java:188-190). `bullet_estimate_dps` is the
	# caller-computed `bullet.estimateDPS()` (N2529) as a
	# float param; `reload` is the weapon reload in frames
	# (`public float reload = 1;`, Weapon.java:75);
	# `shoot_shots` is the ShootPattern shot count
	# (`public int shots = 1;`, ShootPattern.java:9). dps()
	# has NO cache and NO `reload == 0` guard: it
	# recomputes on every call and returns the single key
	# `dps`. The proof drives the pure function through
	# the Weapon facade on exact legs:
	# 1 Java defaults (bullet 1.0 / reload 1 / shots 1 ->
	# 60.0); 2 reload 2.0 (1.0 / 2 / 1 -> 30.0); 3
	# fractional reload 0.5 (1.0 / 0.5 / 1 -> 120.0); 4
	# shots 3 (1.0 / 1 / 3 -> 180.0); 5 shots 0 -> 0.0; 6
	# bullet dps 0.0 -> 0.0; 7 fractional bullet dps 37.5
	# (37.5 / 1 / 1 -> 2250.0 -- the * 60f factor applies,
	# so this is NOT 37.5); 8 large (120.0 / 0.5 / 2 ->
	# 28800.0).

	# Phase 1: Java defaults (bullet 1.0, reload 1.0,
	# shots 1) -> 60.0.
	var dps: Dictionary = weapons_state.source_weapon_dps_state(1.0, 1.0, 1)
	proof["dps_java_defaults"] = is_equal_approx(float(dps.get("dps", -1.0)), 60.0)

	# Phase 2: reload 2.0 (1.0 / 2 / 1) -> 30.0.
	dps = weapons_state.source_weapon_dps_state(1.0, 2.0, 1)
	proof["dps_reload_2"] = is_equal_approx(float(dps.get("dps", -1.0)), 30.0)

	# Phase 3: fractional reload 0.5 (1.0 / 0.5 / 1) ->
	# 120.0.
	dps = weapons_state.source_weapon_dps_state(1.0, 0.5, 1)
	proof["dps_reload_fractional"] = is_equal_approx(float(dps.get("dps", -1.0)), 120.0)

	# Phase 4: shots 3 (1.0 / 1 / 3) -> 180.0.
	dps = weapons_state.source_weapon_dps_state(1.0, 1.0, 3)
	proof["dps_shots_3"] = is_equal_approx(float(dps.get("dps", -1.0)), 180.0)

	# Phase 5: shots 0 -> 0.0.
	dps = weapons_state.source_weapon_dps_state(1.0, 1.0, 0)
	proof["dps_shots_zero"] = is_equal_approx(float(dps.get("dps", -1.0)), 0.0)

	# Phase 6: bullet dps 0.0 -> 0.0.
	dps = weapons_state.source_weapon_dps_state(0.0, 1.0, 1)
	proof["dps_bullet_zero"] = is_equal_approx(float(dps.get("dps", -1.0)), 0.0)

	# Phase 7: fractional bullet dps 37.5 (37.5 / 1 / 1)
	# -> 2250.0 (the * 60f factor applies).
	dps = weapons_state.source_weapon_dps_state(37.5, 1.0, 1)
	proof["dps_bullet_fractional"] = is_equal_approx(float(dps.get("dps", -1.0)), 2250.0)

	# Phase 8: large (120.0 / 0.5 / 2) -> 28800.0.
	dps = weapons_state.source_weapon_dps_state(120.0, 0.5, 2)
	proof["dps_large"] = is_equal_approx(float(dps.get("dps", -1.0)), 28800.0)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponDpsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
