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

	# --- Weapon.update() leg 1 (N2540): reload / recoil /
	# smoothReload / charge / warmup decay (Weapon.java:293-306).
	# `boolean can = unit.canShoot();` /
	# `float lastReload = mount.reload;` /
	# `mount.reload = Math.max(mount.reload - Time.delta * unit.reloadMultiplier, 0);` /
	# `mount.recoil = Mathf.approachDelta(mount.recoil, 0, unit.reloadMultiplier / recoilTime);` /
	# `if(recoils > 0){` /
	# `if(mount.recoils == null) mount.recoils = new float[recoils];` /
	# `for(int i = 0; i < recoils; i++){` /
	# `mount.recoils[i] = Mathf.approachDelta(mount.recoils[i], 0, unit.reloadMultiplier / recoilTime);` /
	# `}` /
	# `}` /
	# `mount.smoothReload = Mathf.lerpDelta(mount.smoothReload, mount.reload / reload, smoothReloadSpeed);` /
	# `mount.charge = mount.charging && shoot.firstShotDelay > 0 ? Mathf.approachDelta(mount.charge, 1, 1 / shoot.firstShotDelay) : 0;` /
	# `float warmupTarget = (can && mount.shoot) || (continuous && mount.bullet != null) || mount.charging ? 1f : 0f;` /
	# `if(linearWarmup){` /
	# `mount.warmup = Mathf.approachDelta(mount.warmup, warmupTarget, shootWarmupSpeed);` /
	# `}else{` /
	# `mount.warmup = Mathf.lerpDelta(mount.warmup, warmupTarget, shootWarmupSpeed);` /
	# `}`.
	# Defaults unless noted: delta 1.0, reloadMultiplier 1.0,
	# weapon reload 60.0, smoothReloadSpeed 0.15,
	# shootWarmupSpeed 0.1, recoilTime 10.0, recoils 2,
	# firstShotDelay 30.0, linearWarmup false, continuous
	# false, can false, mount.shoot false, mount.charging
	# false, no continuous bullet. The proof drives the pure
	# function through the Weapon facade on exact legs:

	# Phase 1: reload decay: reload 30.0 -> 29.0.
	var decay_state: Dictionary = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["reload_decay"] = is_equal_approx(float(decay_state.get("reload", -1.0)), 29.0)

	# Phase 2: reload clamp at 0: reload 0.5 -> 0.0.
	decay_state = weapons_state.source_weapon_update_decay_state(0.5, 0.0, [], 0.0, 0.0, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["reload_clamp"] = is_equal_approx(float(decay_state.get("reload", -1.0)), 0.0)

	# Phase 3: recoil approach: recoil 1.0, recoilTime 20.0
	# -> 0.95 (approachDelta(1, 0, 1/20) with delta 1.0).
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 1.0, [], 0.0, 0.0, false, false, 0.0, false, 2, 20.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["recoil_approach"] = is_equal_approx(float(decay_state.get("recoil", -1.0)), 0.95)

	# Phase 4: recoils alloc: recoils 2, mount recoils []
	# (Java null) -> [0.0, 0.0] (zeros allocated, then
	# decayed from 0 stays 0).
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	var out_recoils: Array = decay_state.get("recoils", [-1.0])
	proof["recoils_alloc"] = out_recoils.size() == 2 and is_equal_approx(float(out_recoils[0]), 0.0) and is_equal_approx(float(out_recoils[1]), 0.0)

	# Phase 5: recoils decay: recoils 2, [0.5, 0.25],
	# recoilTime 10.0 -> [0.4, 0.15].
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [0.5, 0.25], 0.0, 0.0, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	out_recoils = decay_state.get("recoils", [-1.0])
	proof["recoils_decay"] = out_recoils.size() == 2 and is_equal_approx(float(out_recoils[0]), 0.4) and is_equal_approx(float(out_recoils[1]), 0.15)

	# Phase 6: recoils ignored: recoils -1 (Weapon default,
	# Weapon.java:83), [0.7] -> [0.7] untouched.
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [0.7], 0.0, 0.0, false, false, 0.0, false, -1, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	out_recoils = decay_state.get("recoils", [-1.0])
	proof["recoils_ignored"] = out_recoils.size() == 1 and is_equal_approx(float(out_recoils[0]), 0.7)

	# Phase 7: smoothReload lerps toward the UPDATED
	# reload: smoothReload 0.0, updated reload 29.0 /
	# weapon reload 60.0, speed 0.15 -> 0.0725 (NOT 0.075,
	# which the stale input reload 30.0 would give).
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["smooth_reload"] = is_equal_approx(float(decay_state.get("smooth_reload", -1.0)), 0.0725)

	# Phase 8: charge gate, charging leg: charging,
	# firstShotDelay 30.0 -> approachDelta(0, 1, 1/30) = 1/30.
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, true, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["charge_charging"] = is_equal_approx(float(decay_state.get("charge", -1.0)), 1.0 / 30.0)

	# Phase 9: charge gate, else leg: not charging, charge
	# 0.8 -> exactly 0.0 (old charge NOT kept).
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.8, false, false, 0.0, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["charge_else_zero"] = is_equal_approx(float(decay_state.get("charge", -1.0)), 0.0)

	# Phase 10: warmup approach leg: linearWarmup, can +
	# shoot -> target 1, warmup 0.5, speed 0.1 -> 0.6.
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, false, true, 0.5, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, true, false, true, 1.0, 1.0)
	proof["warmup_approach"] = is_equal_approx(float(decay_state.get("warmup", -1.0)), 0.6)

	# Phase 11: warmup lerp leg: lerp leg, target 0 (can
	# false, shoot false, continuous false, charging
	# false), warmup 0.8, speed 0.1 -> 0.72.
	decay_state = weapons_state.source_weapon_update_decay_state(30.0, 0.0, [], 0.0, 0.0, false, false, 0.8, false, 2, 10.0, 60.0, 0.15, 30.0, 0.1, false, false, false, 1.0, 1.0)
	proof["warmup_lerp"] = is_equal_approx(float(decay_state.get("warmup", -1.0)), 0.72)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponUpdateDecayProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
