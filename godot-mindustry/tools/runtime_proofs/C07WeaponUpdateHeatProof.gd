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

	# --- Weapon.update() leg 3 (N2542): heat decay in the
	# else-branch when NOT (continuous && mount.bullet !=
	# null) (Weapon.java:376, :409-415).
	# `if(continuous && mount.bullet != null){` /
	# `}else{` /
	# `//heat decreases when not firing` /
	# `mount.heat = Math.max(mount.heat - Time.delta * unit.reloadMultiplier / cooldownTime, 0);` /
	# `if(mount.sound != null){` /
	# `mount.sound.update(bulletX, bulletY, false);` /
	# `}` /
	# `}`.
	# Defaults unless noted: heat, delta 1.0,
	# reloadMultiplier 1.0, cooldownTime 20.0, continuous
	# false, bullet absent. The proof drives the pure
	# function through the Weapon facade on exact legs:

	# Phase 1: decay: heat 0.5 -> 0.5 - 1*1/20 = 0.45.
	var heat_state: Dictionary = weapons_state.source_weapon_update_heat_state(0.5, 1.0, 1.0, 20.0, false, false)
	proof["decay"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.45)

	# Phase 2: clamp at 0: heat 0.01 -> 0.01 - 0.05 =
	# -0.04 -> max(-0.04, 0) = 0.
	heat_state = weapons_state.source_weapon_update_heat_state(0.01, 1.0, 1.0, 20.0, false, false)
	proof["clamp_zero"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.0)

	# Phase 3: no decay when the continuous bullet is
	# live: continuous true, bullet present, heat 0.8 ->
	# 0.8 (the else-branch does NOT run).
	heat_state = weapons_state.source_weapon_update_heat_state(0.8, 1.0, 1.0, 20.0, true, true)
	proof["no_decay_continuous_bullet"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.8)

	# Phase 4: cooldownTime param respected: heat 0.6,
	# cooldown 10 -> 0.6 - 1*1/10 = 0.5 (default 20f from
	# Weapon.java:89 is NOT hard-coded in the function).
	heat_state = weapons_state.source_weapon_update_heat_state(0.6, 1.0, 1.0, 10.0, false, false)
	proof["cooldown_time_respected"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.5)

	# Phase 5: heat already 0 stays 0: max(0 - 0.05, 0)
	# = 0.
	heat_state = weapons_state.source_weapon_update_heat_state(0.0, 1.0, 1.0, 20.0, false, false)
	proof["heat_zero_unchanged"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.0)

	# Phase 6: reloadMultiplier scales the decay: heat
	# 0.5, multiplier 2.0 -> 0.5 - 1*2/20 = 0.4.
	heat_state = weapons_state.source_weapon_update_heat_state(0.5, 1.0, 2.0, 20.0, false, false)
	proof["reload_multiplier_scales"] = is_equal_approx(float(heat_state.get("heat", -1.0)), 0.4)

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07WeaponUpdateHeatProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
