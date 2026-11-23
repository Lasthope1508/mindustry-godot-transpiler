extends Node

const main_scene := preload("res://scenes/Main.tscn")
const turret_state := preload("res://src/game/SourceTurretBuildState.gd")
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

	# --- TurretBuild.bullet() shake body (N2435):
	# `Effect.shake(shake, shake, this);` (Turret.java:803),
	# the body of the `if(shake > 0){` guard (:802) that
	# N2428 registered as opener only. Effect.shake
	# (intensity, duration, Position) (Effect.java:210)
	# fires a camera shake of the given intensity for
	# the given duration at the build -- both args are
	# the same `shake` value, and the position is the
	# build itself. Recorded as data in the returned
	# Dictionary (the N2437 runWave precedent). One key
	# per leg (4 domain keys).

	var bullet_calls: Array = []
	var bullet := func(bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant) -> void:
		bullet_calls.append({"type": bullet_type, "x_offset": x_offset, "y_offset": y_offset, "angle": angle_offset, "mover": mover})
	var time_runs: Array = []
	var time_run := func(delay: float, action: Callable) -> void:
		time_runs.append({"delay": delay, "action": action})
	var effect_calls: Array = []
	var ammo_use_effect := func(effect_x: float, effect_y: float, effect_rotation: float) -> void:
		effect_calls.append({"x": effect_x, "y": effect_y, "rotation": effect_rotation})

	# Shake 4 > 0, immediate shot (delay == 0): the
	# shake effect fires with (intensity, duration) =
	# (4, 4) at the build position (100, 200).
	var frame: Dictionary = {"barrel_counter": 3}
	var shaken: Dictionary = turret_state.source_turret_shoot_bullet_legs_state(frame, 0.0, bullet, time_run, "bullet-a", -2.0, 1.0, 5.0, "mover-a", 100.0, 200.0, 90.0, 2.0, 4.0, ammo_use_effect)
	var shake_effect: Dictionary = shaken.get("shake_effect", {})
	proof["shake_effect_applied"] = shaken.get("shake_applies", false) == true and is_equal_approx(shake_effect.get("intensity", -1.0), 4.0) and is_equal_approx(shake_effect.get("duration", -1.0), 4.0) and is_equal_approx(shake_effect.get("x", -1.0), 100.0) and is_equal_approx(shake_effect.get("y", -1.0), 200.0)
	proof["shake_applies_matches_effect"] = shaken.get("shake_applies", false) == true and not shake_effect.is_empty()

	# Shake 2.5: both the intensity and the duration
	# are the same `shake` value -- the distinctive
	# shape of the :803 call (not two independent
	# magnitudes).
	frame["barrel_counter"] = 3
	var half_shaken: Dictionary = turret_state.source_turret_shoot_bullet_legs_state(frame, 0.0, bullet, time_run, "bullet-a", -2.0, 1.0, 5.0, "mover-a", 100.0, 200.0, 90.0, 2.0, 2.5, ammo_use_effect)
	var half_effect: Dictionary = half_shaken.get("shake_effect", {})
	proof["shake_effect_uses_shake_both_args"] = is_equal_approx(half_effect.get("intensity", -1.0), 2.5) and is_equal_approx(half_effect.get("duration", -1.0), 2.5)

	# Shake 0: the guard stays shut and no shake
	# effect is recorded.
	frame["barrel_counter"] = 3
	var calm: Dictionary = turret_state.source_turret_shoot_bullet_legs_state(frame, 0.0, bullet, time_run, "bullet-a", -2.0, 1.0, 5.0, "mover-a", 100.0, 200.0, 90.0, 2.0, 0.0, ammo_use_effect)
	var calm_effect: Dictionary = calm.get("shake_effect", {"intensity": -1.0})
	proof["shake_effect_absent"] = calm.get("shake_applies", true) == false and calm_effect.is_empty()
	proof["shake_applies_matches_effect"] = proof.get("shake_applies_matches_effect", false) and calm.get("shake_applies", true) == false and calm_effect.is_empty()

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShootBulletShakeProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
