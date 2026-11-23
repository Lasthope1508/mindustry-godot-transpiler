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

	# --- TurretBuild.shoot()/bullet() leftover legs (N2428):
	# the 6 exprs remote N2269/N2252 did not register --
	# `int barrel = barrelCounter;` (Turret.java:756),
	# `int prev = barrelCounter;` (:761),
	# `barrelCounter = barrel;` (:762),
	# `barrelCounter = prev;` (:764),
	# `ammoUseEffect.at(` (:796, the 4-line call :796-799
	# counts as one expr, the N816 precedent), and
	# `if(shake > 0){` (:802, opener only -- the
	# Effect.shake body :803 is deferred). The barrel
	# counter is live build state in the frame Dictionary;
	# bullet() and Time.run arrive as Callables recording
	# their calls; the ammo-eject effect arrives as a
	# Callable recording its position/rotation. One key
	# per leg (8 domain keys).

	var bullet_calls: Array = []
	var bullet := func(bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant) -> void:
		bullet_calls.append({"type": bullet_type, "x_offset": x_offset, "y_offset": y_offset, "angle": angle_offset, "mover": mover, "barrel_counter_at_call": 0})
	var time_runs: Array = []
	var time_run := func(delay: float, action: Callable) -> void:
		time_runs.append({"delay": delay, "action": action})
	var effect_calls: Array = []
	var ammo_use_effect := func(effect_x: float, effect_y: float, effect_rotation: float) -> void:
		effect_calls.append({"x": effect_x, "y": effect_y, "rotation": effect_rotation})

	# Delayed shot (delay > 0): the barrel is captured
	# now (barrelCounter 3); the bullet must NOT fire
	# yet; Time.run records (delay, action).
	var frame: Dictionary = {"barrel_counter": 3}
	var delayed: Dictionary = turret_state.source_turret_shoot_bullet_legs_state(frame, 12.0, bullet, time_run, "bullet-a", -2.0, 1.0, 5.0, "mover-a", 100.0, 200.0, 90.0, 2.0, 4.0, ammo_use_effect)
	proof["barrel_captured"] = delayed.get("barrel", -1) == 3
	proof["delayed_bullet_not_called_yet"] = bullet_calls.is_empty() and time_runs.size() == 1 and is_equal_approx(time_runs[0].get("delay", -1.0), 12.0)
	# Another shot advances the counter before the queued
	# action runs: the action must fire the bullet with
	# the CAPTURED barrel (3), then hand the counter back
	# to the live value (7).
	frame["barrel_counter"] = 7
	var bullet_with_barrel := func(bullet_type: Variant, x_offset: float, y_offset: float, angle_offset: float, mover: Variant) -> void:
		bullet_calls.append({"type": bullet_type, "x_offset": x_offset, "y_offset": y_offset, "angle": angle_offset, "mover": mover, "barrel_counter_at_call": int(frame.get("barrel_counter", -1))})
	# Re-run the delayed path with the recording bullet
	# so the action's restore is observable: rebuild the
	# action by calling the state again with the same
	# captured barrel.
	frame["barrel_counter"] = 3
	time_runs.clear()
	bullet_calls.clear()
	turret_state.source_turret_shoot_bullet_legs_state(frame, 12.0, bullet_with_barrel, time_run, "bullet-a", -2.0, 1.0, 5.0, "mover-a", 100.0, 200.0, 90.0, 2.0, 4.0, ammo_use_effect)
	frame["barrel_counter"] = 7
	var delayed_action: Callable = time_runs[0].get("action", Callable())
	delayed_action.call()
	proof["delayed_action_restores_barrel"] = bullet_calls.size() == 1 and bullet_calls[0].get("barrel_counter_at_call", -1) == 3 and int(frame.get("barrel_counter", -1)) == 7 and bullet_calls[0].get("type", "") == "bullet-a" and is_equal_approx(bullet_calls[0].get("x_offset", 0.0), -2.0) and is_equal_approx(bullet_calls[0].get("angle", 0.0), 5.0)
	# The ammo-eject effect fired once per state call
	# with rotation 90 and eject 2: x - 2*cos(90) = 100,
	# y - 2*sin(90) = 198, rotation * sign(-2) = -90.
	proof["ammo_use_effect_position"] = effect_calls.size() >= 1 and is_equal_approx(effect_calls[0].get("x", -1.0), 100.0) and is_equal_approx(effect_calls[0].get("y", -1.0), 198.0)
	proof["ammo_use_effect_rotation_sign"] = is_equal_approx(delayed.get("ammo_use_effect_rotation", 0.0), -90.0) and is_equal_approx(effect_calls[0].get("rotation", 0.0), -90.0)

	# Immediate shot (delay == 0): the bullet fires at
	# once with the captured barrel; Time.run is never
	# called.
	frame["barrel_counter"] = 5
	time_runs.clear()
	bullet_calls.clear()
	effect_calls.clear()
	var immediate: Dictionary = turret_state.source_turret_shoot_bullet_legs_state(frame, 0.0, bullet, time_run, "bullet-b", 2.0, -1.0, -5.0, "mover-b", 10.0, 20.0, 0.0, 3.0, 0.0, ammo_use_effect)
	proof["immediate_bullet_called"] = bullet_calls.size() == 1 and bullet_calls[0].get("type", "") == "bullet-b" and time_runs.is_empty() and immediate.get("barrel", -1) == 5 and immediate.get("delayed", true) == false
	# rotation 0, eject 3: effect at (10 - 3, 20 - 0) =
	# (7, 20), rotation * sign(+2) = 0.
	proof["ammo_use_effect_rotation_sign"] = proof.get("ammo_use_effect_rotation_sign", false) and is_equal_approx(effect_calls[0].get("x", -1.0), 7.0) and is_equal_approx(effect_calls[0].get("y", -1.0), 20.0) and is_equal_approx(immediate.get("ammo_use_effect_rotation", 99.0), 0.0)

	# Shake guard: shake 4 > 0 applies; shake 0 does not.
	proof["shake_guard_true"] = delayed.get("shake_applies", false) == true
	proof["shake_guard_false"] = immediate.get("shake_applies", true) == false

	var state_registry := registry.canonical_headquarter_registry_state()
	proof["registry_valid"] = state_registry.get("errors", []).is_empty()
	proof["one_headquarter_per_ssot"] = state_registry.get("one_headquarter_per_ssot", false)
	proof["matches"] = proof.values().all(func(value): return value == true)
	proof_state.write_proof("C07TurretShootBulletLegsProof", proof)
	if "--headless" in OS.get_cmdline_args():
		get_tree().quit(proof_state.exit_code(proof))
